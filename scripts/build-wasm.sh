#!/usr/bin/env bash
# Build Ironfang for Qt WebAssembly and assemble a static-hosting directory (deploy/).
#
#   scripts/build-wasm.sh [--single] [--debug]
#
# Requirements (see docs/feasibility-report.md):
#   * Qt 6.11.1 wasm kit:   QT_WASM_ROOT (default ~/Qt/6.11.1/wasm_multithread)
#   * Emscripten 4.0.7:     EMSDK (default ~/emsdk-qt6) - the exact version Qt 6.11 expects
#   * Host Qt for tools:    QT_HOST_ROOT (default ~/Qt/6.11.1/macos)
set -euo pipefail
cd "$(dirname "$0")/.."

FLAVOUR=multithread
BUILD_TYPE=Release
for a in "$@"; do
    case "$a" in
        --single) FLAVOUR=singlethread ;;
        --debug)  BUILD_TYPE=Debug ;;
        *) echo "unknown arg $a"; exit 2 ;;
    esac
done

EMSDK="${EMSDK:-$HOME/emsdk-qt6}"
QT_WASM_ROOT="${QT_WASM_ROOT:-$HOME/Qt/6.11.1/wasm_$FLAVOUR}"
QT_HOST_ROOT="${QT_HOST_ROOT:-$HOME/Qt/6.11.1/macos}"
BUILD_DIR="build-wasm-$FLAVOUR"
DEPLOY_DIR="deploy/$FLAVOUR"

# shellcheck disable=SC1091
source "$EMSDK/emsdk_env.sh" >/dev/null
echo "emcc: $(emcc --version | head -1)"
echo "Qt wasm kit: $QT_WASM_ROOT"

"$QT_WASM_ROOT/bin/qt-cmake" -S . -B "$BUILD_DIR" -G Ninja \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DBUILD_TESTING=OFF \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_IGNORE_PREFIX_PATH=/usr/local \
    -DQT_HOST_PATH="$QT_HOST_ROOT"
cmake --build "$BUILD_DIR" --target ironfang -j"$(sysctl -n hw.ncpu 2>/dev/null || nproc)"

# ---- deploy directory: everything a static host needs -------------------------------------
rm -rf "$DEPLOY_DIR"; mkdir -p "$DEPLOY_DIR"
cp "$BUILD_DIR"/bin/ironfang.{html,js,wasm} "$BUILD_DIR"/bin/qtloader.js "$DEPLOY_DIR/"
[ -f "$BUILD_DIR/bin/qtlogo.svg" ] && cp "$BUILD_DIR/bin/qtlogo.svg" "$DEPLOY_DIR/"
[ -f "$BUILD_DIR/bin/ironfang.worker.js" ] && cp "$BUILD_DIR/bin/ironfang.worker.js" "$DEPLOY_DIR/"
cp external/clayground/docs/coi-serviceworker.js "$DEPLOY_DIR/"
# index.html = Qt's generated shell + COOP/COEP service-worker shim + ?args= support
python3 scripts/make-web-index.py "$DEPLOY_DIR" ironfang
du -sh "$DEPLOY_DIR"/* | sed 's|^|  |'
echo
echo "Deploy dir ready: $DEPLOY_DIR"
echo "Serve it:         python3 scripts/serve.py $DEPLOY_DIR"
