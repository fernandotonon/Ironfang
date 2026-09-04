#!/usr/bin/env bash
# QtMeshEditor: concept image -> game-ready static GLB (TRELLIS.2 backend).
#
#   scripts/generate-models.sh            # every assets/source-images/*.png without a model
#   scripts/generate-models.sh Orc Goblin # only these
#
# Output per model: assets/exported/<Name>/<Name>.glb + .material + 4 PBR PNGs (1024x1024).
# The full-resolution generation sidecar (<Name>_source.qtm3d, ~20 MB) is kept in
# assets/qtmesh-projects/sources/ (gitignored) so textures/LODs can be re-baked later.
#
# Backend on this machine: trellis.cpp (Metal) via QTMESH_TRELLIS2_CLI; only the 512 GGUF
# weights are installed, so --preset high falls back to the 512 pipeline with a warning.
set -uo pipefail
cd "$(dirname "$0")/.."
export QTMESH_NO_TELEMETRY=1
export QTMESH_TRELLIS2_CLI="${QTMESH_TRELLIS2_CLI:-$HOME/trellis.cpp/build-cpu/trellis-cli}"
export QTMESH_TRELLIS2_CLI_MODELS="${QTMESH_TRELLIS2_CLI_MODELS:-$HOME/trellis.cpp/models}"
Q="${QTMESH:-/opt/homebrew/bin/qtmesheditor}"

mkdir -p assets/exported assets/qtmesh-projects/sources assets/qtmesh-projects/logs
if [ $# -gt 0 ]; then names=("$@"); else
    names=(); for f in assets/source-images/*.png; do n="$(basename "${f%.png}")"; names+=("$n"); done
fi

for name in "${names[@]}"; do
    img="assets/source-images/$name.png"
    dir="assets/exported/$name"; out="$dir/$name.glb"
    [ -f "$img" ] || { echo "SKIP $name (no image)"; continue; }
    [ -s "$out" ] && { echo "SKIP $name (exists)"; continue; }
    mkdir -p "$dir"; S=$(date +%s)
    "$Q" generate3d "$img" -o "$out" --backend trellis2 --preset high \
        --target-tris 10000 --texture-size 1024 --remove-bg --seed 42 \
        > "assets/qtmesh-projects/logs/$name.log" 2>&1
    rc=$?
    if [ $rc -eq 0 ] && [ -s "$out" ]; then
        mv "$dir/${name}_source.qtm3d" assets/qtmesh-projects/sources/ 2>/dev/null || true
        python3 scripts/resize-textures-1024.py "$dir" >> "assets/qtmesh-projects/logs/$name.log"
        echo "OK   $name $(( $(date +%s) - S ))s"
    else
        echo "FAIL $name rc=$rc (see assets/qtmesh-projects/logs/$name.log)"; rmdir "$dir" 2>/dev/null
    fi
done
