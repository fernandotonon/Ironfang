#!/usr/bin/env bash
# Assemble a no-build-step deployment: Clayground Web Runtime files + Ironfang QML + assets.
#
#   scripts/pack-web-runtime.sh <runtime_dir> [out_dir=deploy/web-runtime]
#
# <runtime_dir> holds clayground.wasm/.js, qtloader.js, coi-serviceworker.js, index.html,
# LICENSES/ and RUNTIME-MANIFEST.json - i.e. an unzipped clayground-starter.zip from a
# Clayground release, or <clayground build-wasm>/clayground-starter. The runtime must link
# QtQuick.Timeline and QtQuick3D.AssetUtils (Clayground >= 2026.7) for animated units.
set -euo pipefail
cd "$(dirname "$0")/.."
RT="${1:?runtime dir}"; OUT="${2:-deploy/web-runtime}"
[ -f "$RT/clayground.wasm" ] || { echo "no clayground.wasm in $RT"; exit 1; }
rm -rf "$OUT"; mkdir -p "$OUT"
cp "$RT"/clayground.wasm "$RT"/clayground.js "$RT"/qtloader.js "$RT"/coi-serviceworker.js "$RT"/index.html "$OUT"/
cp "$RT"/RUNTIME-MANIFEST.json "$OUT"/ 2>/dev/null || true
[ -d "$RT/LICENSES" ] && cp -R "$RT/LICENSES" "$OUT"/
# the game: runtime entry point + the same QML/JS the compiled app uses
cp web-runtime/Main.qml "$OUT"/
cp app/IronfangGame.qml app/GameWorld.qml app/RtsCamera.qml app/UnitView.qml app/BuildingView.qml app/Projectile.qml app/HealthBar3D.qml app/Hud.qml app/Frontend.qml app/Storage.qml app/Loc.qml app/AudioController.qml app/AssetShowcase.qml app/qmldir "$OUT"/
mkdir -p "$OUT/scripts" "$OUT/config" "$OUT/missions" "$OUT/i18n" && cp app/scripts/*.js "$OUT/scripts/" && cp app/config/*.js "$OUT/config/" && cp app/missions/*.js "$OUT/missions/" && cp app/i18n/*.js "$OUT/i18n/"
mkdir -p "$OUT/assets" && cp -R assets/runtime "$OUT/assets/" && cp -R assets/audio "$OUT/assets/"
# files Qt opens with QFile (meshes, textures, .qad keyframes): the app shell preloads them
# into the runtime's in-memory filesystem (/game/<path>) from this manifest
( cd "$OUT" && find assets -type f ! -name '.DS_Store' | sort | python3 -c 'import json,sys; print(json.dumps([l.strip() for l in sys.stdin], indent=0))' > assets-manifest.json )
echo "manifest: $(python3 -c "import json; print(len(json.load(open('$OUT/assets-manifest.json'))))") files"
sed -i '' 's|<title>My Clayground Game</title>|<title>Ironfang: First Siege</title>|' "$OUT/index.html" 2>/dev/null || true
touch "$OUT/.nojekyll"
du -sh "$OUT" | cut -f1; echo "Serve: python3 scripts/serve.py $OUT"
