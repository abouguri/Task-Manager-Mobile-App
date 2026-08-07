#!/usr/bin/env bash
set -euo pipefail

# Keep in step with the SDK the app is developed against. Drifting apart means
# a build that passes locally can still fail here — pubspec.lock is resolved by
# whichever version runs, and deprecations land between releases.
FLUTTER_VERSION="3.44.8"
FLUTTER_ROOT="$HOME/flutter"
FLUTTER_BIN="$FLUTTER_ROOT/bin"
PROJECT_DIR="$(pwd)"

# The SDK is cached between builds, so presence alone isn't enough to trust it:
# after a version bump the cache still holds the old SDK, and a guard that only
# checks for the binary would keep building on it forever. Stamp what we
# installed and re-download whenever the pin moves.
STAMP="$FLUTTER_ROOT/.installed-version"

if [ ! -x "$FLUTTER_BIN/flutter" ] ||
   [ "$(cat "$STAMP" 2>/dev/null || true)" != "$FLUTTER_VERSION" ]; then
  echo "Installing Flutter $FLUTTER_VERSION"
  rm -rf "$FLUTTER_ROOT"
  mkdir -p "$HOME"
  cd "$HOME"

  curl -fsSL -o flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  tar -xf flutter.tar.xz
  rm -f flutter.tar.xz

  echo "$FLUTTER_VERSION" >"$STAMP"
else
  echo "Reusing cached Flutter $FLUTTER_VERSION"
fi

export PATH="$FLUTTER_BIN:$PATH"

git config --global --add safe.directory "$FLUTTER_ROOT"

flutter config --enable-web
flutter --version

cd "$PROJECT_DIR"
flutter pub get
# The public demo has no persistent storage, so it would otherwise open to an
# empty app. DEMO_SEED fills it with sample content on load. Set here and
# nowhere else: local builds and every real install start empty.
flutter build web --release --base-href / --dart-define=DEMO_SEED=true
