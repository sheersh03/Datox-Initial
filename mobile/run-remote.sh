#!/bin/bash
# Run Flutter app pointing to remote API (Windows machine running infra)
#
# Setup (one-time):
#   cp .env.remote.example .env.remote
#   # Edit .env.remote: set WINDOWS_IP=your.windows.ip
#
# Usage:
#   ./run-remote.sh              # uses .env.remote or prompts
#   ./run-remote.sh 192.168.1.105
#   ./run-remote.sh --ios         # run on iOS simulator
#   ./run-remote.sh 192.168.1.105 --ios

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
      WINDOWS_IP="$1"
      shift
      ;;
  esac
done

WINDOWS_IP="${WINDOWS_IP:-}"
if [ -z "$WINDOWS_IP" ]; then
  echo "No Windows IP configured."
  echo ""
  echo "Option 1: Create .env.remote with your Windows IP:"
  echo "  cp .env.remote.example .env.remote"
  echo "  # Edit .env.remote: WINDOWS_IP=192.168.1.105"
  echo ""
  echo "Option 2: Pass IP as argument:"
  echo "  ./run-remote.sh 192.168.1.105"
  echo ""
  echo "Option 3: Use env var:"
  echo "  WINDOWS_IP=192.168.1.105 ./run-remote.sh"
  exit 1
fi

API_URL="http://$WINDOWS_IP:8080/api/v1"
echo "→ API: $API_URL"
echo "→ Device: $DEVICE"
echo ""

# Quick connectivity check
if command -v curl &>/dev/null; then
  if ! curl -s -o /dev/null -w "%{http_code}" --connect-timeout 2 "http://$WINDOWS_IP:8080/health" 2>/dev/null | grep -qE '^[23]'; then
    echo "⚠️  Could not reach API at $WINDOWS_IP:8080"
    echo "   Make sure infra is running on Windows and firewall allows port 8080."
    echo "   Continuing anyway..."
    echo ""
  fi
fi

flutter pub get
# When DEVICE=android, use emulator-5554 if available, else let Flutter pick
if [ "$DEVICE" = "android" ]; then
  if flutter devices 2>/dev/null | grep -q "emulator-5554"; then
    DEVICE="emulator-5554"
  fi
fi
flutter run -d "$DEVICE" --dart-define=API_BASE_URL=$API_URL
