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
# Backend on this machine: trellis.cpp (Metal) with the 512 and 1024-cascade GGUF weights.
# PRESET defaults to "fast" (= the 512 pipeline): "balanced" (1024) and "high" (1536) both hang
# in a Metal command buffer that never completes on this 24 GB Mac (2026-09-05), so the cascade
# is not usable here yet. Everything else (10k tris, 1024 textures, bake, matte) is unchanged.
set -uo pipefail
cd "$(dirname "$0")/.."
export QTMESH_NO_TELEMETRY=1
# trellis-cli: the fork build with --dump-post (QtMeshEditor's raw-mesh handshake). The CLI
# bundled by the 3.37.x dev build does not know --dump-post yet, so it is not used here.
export QTMESH_TRELLIS2_CLI="${QTMESH_TRELLIS2_CLI:-$HOME/trellis.cpp/build-cpu/trellis-cli}"
export QTMESH_TRELLIS2_CLI_MODELS="${QTMESH_TRELLIS2_CLI_MODELS:-$HOME/trellis.cpp/models}"
# prefer a local development build of QtMeshEditor when present (newest TRELLIS.2 pipeline)
DEV_Q="$HOME/QtMeshEditor/build_local/bin/QtMeshEditor.app/Contents/MacOS/QtMeshEditor"
Q="${QTMESH:-$([ -x "$DEV_Q" ] && echo "$DEV_Q" || echo /opt/homebrew/bin/qtmesheditor)}"
echo "using $Q ($($Q --version 2>/dev/null | head -1)), trellis-cli $QTMESH_TRELLIS2_CLI, preset ${PRESET:-fast}"

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
    "$Q" generate3d "$img" -o "$out" --backend trellis2 --preset "${PRESET:-fast}" \
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
