#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.32.5"
FLUTTER_ROOT="$HOME/flutter"
FLUTTER_BIN="$FLUTTER_ROOT/bin"
PROJECT_DIR="$(pwd)"

if [ ! -x "$FLUTTER_BIN/flutter" ]; then
  mkdir -p "$HOME"
  cd "$HOME"

  curl -fsSL -o flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  tar -xf flutter.tar.xz
  rm -f flutter.tar.xz
fi

export PATH="$FLUTTER_BIN:$PATH"

flutter config --enable-web
flutter --version

cd "$PROJECT_DIR"
flutter pub get
flutter build web --release --base-href /
