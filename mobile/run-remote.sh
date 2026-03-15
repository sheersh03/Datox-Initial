#!/bin/bash
# Run Flutter app - supports local (Mac) or remote (Windows) backend
#
# Config in .env.remote:
#   USE_LOCAL_BACKEND=true   → Mac local (localhost:8080)
#   USE_LOCAL_BACKEND=false  → Windows remote (WINDOWS_IP:8080)
#
# Usage:
#   ./run-remote.sh
#   ./run-remote.sh --chrome
#   ./run-remote.sh --ios
#   ./run-remote.sh 192.168.1.105   # override: use this IP (ignores USE_LOCAL_BACKEND)

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Load config from .env.remote if it exists
if [ -f .env.remote ]; then
  set -a
  source .env.remote
  set +a
fi

# Parse args: IP and/or --ios/--chrome/--android/--emulator
DEVICE="${DEVICE:-android}"
OVERRIDE_IP=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --ios)
      DEVICE="ios"
      shift
      ;;
    --chrome)
      DEVICE="chrome"
      shift
      ;;
    --android|--emulator)
      DEVICE="android"
      shift
      ;;
    -*)
      echo "Unknown option: $1"
      exit 1
      ;;
    *)
      OVERRIDE_IP="$1"
      shift
      ;;
  esac
done

# Resolve API URL
if [ -n "$OVERRIDE_IP" ]; then
  API_URL="http://$OVERRIDE_IP:8080/api/v1"
  echo "→ API: $API_URL (override)"
elif [ "${USE_LOCAL_BACKEND}" = "true" ]; then
  if [ "$DEVICE" = "android" ] || [ "$DEVICE" = "emulator-5554" ]; then
    API_URL="http://10.0.2.2:8080/api/v1"
  else
    API_URL="http://localhost:8080/api/v1"
  fi
  echo "→ API: $API_URL (local backend)"
else
  WINDOWS_IP="${WINDOWS_IP:-}"
  if [ -z "$WINDOWS_IP" ]; then
    echo "USE_LOCAL_BACKEND is false but WINDOWS_IP not set."
    echo "Edit .env.remote: set WINDOWS_IP=your.windows.ip"
    echo "Or set USE_LOCAL_BACKEND=true for Mac local backend."
    exit 1
  fi
  API_URL="http://$WINDOWS_IP:8080/api/v1"
  echo "→ API: $API_URL (Windows remote)"
fi

echo "→ Device: $DEVICE"
echo ""

# Quick connectivity check (skip for local)
if [ -z "$OVERRIDE_IP" ] && [ "${USE_LOCAL_BACKEND}" != "true" ] && command -v curl &>/dev/null; then
  HEALTH_URL="${API_URL%/api/v1}/health"
  if ! curl -s -o /dev/null -w "%{http_code}" --connect-timeout 2 "$HEALTH_URL" 2>/dev/null | grep -qE '^[23]'; then
    echo "⚠️  Could not reach API. Make sure infra is running and firewall allows port 8080."
    echo "   Continuing anyway..."
    echo ""
  fi
fi

flutter pub get
# When DEVICE=android, use emulator-5554 if available
if [ "$DEVICE" = "android" ]; then
  if flutter devices 2>/dev/null | grep -q "emulator-5554"; then
    DEVICE="emulator-5554"
  fi
fi
flutter run -d "$DEVICE" --dart-define=API_BASE_URL=$API_URL
