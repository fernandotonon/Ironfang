#!/usr/bin/env bash
# QtMeshEditor: static GLB -> rigged + animated unit GLB with game-standard clip names.
#
#   scripts/rig-unit.sh <Name> [extra_action:ClipName ...]
#
#   Input : assets/exported/<Name>/<Name>.glb   (from scripts/generate-models.sh)
#   Output: assets/rigged/<Name>/<Name>_rigged.glb  (+ textures copied alongside)
#
# Clips: Idle, Walk, Attack, Hit, Death are always added. Extra pairs add more, e.g.
#   scripts/rig-unit.sh Goblin farmloop:Gather
# Actions come from QtMeshEditor's bundled permissive motion library (`qtmesh anim --generate`);
# list them with:  qtmesh anim x.glb --generate zzz   (the error prints every action).
# NOTE: never pass --variant, it indexes the whole library rather than one action.
set -euo pipefail
cd "$(dirname "$0")/.."
export QTMESH_NO_TELEMETRY=1
Q="${QTMESH:-/opt/homebrew/bin/qtmesheditor}"

NAME="$1"; shift
IN="assets/exported/$NAME/$NAME.glb"
OUT_DIR="assets/rigged/$NAME"
[ -f "$IN" ] || { echo "missing $IN"; exit 1; }
mkdir -p "$OUT_DIR"
WORK="$(mktemp -d)"
cp "assets/exported/$NAME"/*.png "$WORK/" 2>/dev/null || true

echo "== rig + skin (Pinocchio template, offline)"
"$Q" rig "$IN" --skeleton humanoid --skin --algo pinocchio --up-axis y -o "$WORK/r0.glb" --json | tail -1

CLIPS=("idle:Idle:3" "walk:Walk:1" "attack:Attack:1.5" "hit:Hit:0.8" "death:Death:2.5")
for extra in "$@"; do CLIPS+=("${extra%%:*}:${extra##*:}:2"); done

prev="$WORK/r0.glb"; i=0
for spec in "${CLIPS[@]}"; do
    IFS=: read -r action clip dur <<<"$spec"
    i=$((i+1))
    echo "== generate $action ($dur s)"
    "$Q" anim "$prev" --generate "$action" --duration "$dur" -o "$WORK/a$i.glb" --json | tail -1
    prev="$WORK/a$i.glb"
done
for spec in "${CLIPS[@]}"; do
    IFS=: read -r action clip dur <<<"$spec"
    i=$((i+1))
    "$Q" anim "$prev" --rename "generated_$action" "$clip" -o "$WORK/a$i.glb" >/dev/null
    prev="$WORK/a$i.glb"
done

cp "$prev" "$OUT_DIR/${NAME}_rigged.glb"
cp "${prev%.glb}.material" "$OUT_DIR/${NAME}_rigged.material" 2>/dev/null || true
cp "assets/exported/$NAME"/*.png "$OUT_DIR/" 2>/dev/null || true
rm -rf "$WORK"
echo "== clips in $OUT_DIR/${NAME}_rigged.glb"
"$Q" anim "$OUT_DIR/${NAME}_rigged.glb" --list
