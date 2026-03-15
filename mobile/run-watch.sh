#!/bin/bash
# Run Flutter app with auto-restart on file changes.
# Watches lib/, web/, pubspec.* and restarts the app when you save.
#
# Uses fswatch if installed (brew install fswatch), else polling every 2s.
#
# Usage:
#   ./run-watch.sh
#   ./run-watch.sh --chrome
#   ./run-watch.sh --ios

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check for fswatch (preferred) or use polling fallback
USE_FSWATCH=false
if command -v fswatch &>/dev/null; then
  USE_FSWATCH=true
else
  echo "Note: Install fswatch for instant reload (brew install fswatch)"
  echo "      Using polling fallback (checks every 2s)"
  echo ""
fi

# Load config from .env.remote if it exists
if [ -f .env.remote ]; then
  set -a
  source .env.remote
  set +a
fi

# Parse args
DEVICE="${DEVICE:-android}"
OVERRIDE_IP=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --ios) DEVICE="ios"; shift ;;
    --chrome) DEVICE="chrome"; shift ;;
    --android|--emulator) DEVICE="android"; shift ;;
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

# Resolve API URL (same logic as run-remote.sh)
if [ -n "$OVERRIDE_IP" ]; then
  API_URL="http://$OVERRIDE_IP:8080/api/v1"
elif [ "${USE_LOCAL_BACKEND}" = "true" ]; then
  if [ "$DEVICE" = "android" ] || [ "$DEVICE" = "emulator-5554" ]; then
    API_URL="http://10.0.2.2:8080/api/v1"
  else
    API_URL="http://localhost:8080/api/v1"
  fi
else
  WINDOWS_IP="${WINDOWS_IP:-}"
  if [ -z "$WINDOWS_IP" ]; then
    echo "Set USE_LOCAL_BACKEND=true or WINDOWS_IP in .env.remote"
    exit 1
  fi
  API_URL="http://$WINDOWS_IP:8080/api/v1"
fi

# Resolve device for Android emulator
if [ "$DEVICE" = "android" ]; then
  if flutter devices 2>/dev/null | grep -q "emulator-5554"; then
    DEVICE="emulator-5554"
  fi
fi

echo "→ API: $API_URL"
echo "→ Device: $DEVICE"
echo "→ Watching lib/, web/, pubspec.* — app will restart on save"
echo ""

PID_FILE="$SCRIPT_DIR/.flutter_watch.pid"

_run_flutter() {
  flutter run -d "$DEVICE" --dart-define=API_BASE_URL=$API_URL &
  echo $! > "$PID_FILE"
}

# Cleanup on exit
trap 'kill $(cat "$PID_FILE" 2>/dev/null) 2>/dev/null; pkill -P $$ 2>/dev/null; rm -f "$PID_FILE"; exit' EXIT INT TERM

# Start Flutter
flutter pub get
_run_flutter

_restart_on_change() {
  echo ""
  echo "[$(date +%H:%M:%S)] Change detected — restarting app..."
  kill $(cat "$PID_FILE" 2>/dev/null) 2>/dev/null || true
  sleep 2
  _run_flutter
}

if [ "$USE_FSWATCH" = true ]; then
  # fswatch: instant notification
  fswatch -0 -r -l 0.5 lib/ web/ pubspec.yaml pubspec.lock 2>/dev/null | while read -d "" _; do
    _restart_on_change
  done &
else
  # Polling fallback: check mtimes every 2s (macOS)
  _get_mtime() {
    { find lib web -type f 2>/dev/null; [ -f pubspec.yaml ] && echo pubspec.yaml; [ -f pubspec.lock ] && echo pubspec.lock; } | xargs stat -f %m 2>/dev/null | sort -u | tail -1
  }
  LAST=$(_get_mtime)
  while true; do
    sleep 2
    CURR=$(_get_mtime)
    if [ -n "$CURR" ] && [ "$CURR" != "$LAST" ]; then
      LAST=$CURR
      _restart_on_change
    fi
  done &
fi

# Keep script running until Ctrl+C
wait
