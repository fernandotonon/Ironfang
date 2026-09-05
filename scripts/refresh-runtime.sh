#!/usr/bin/env bash
# Bring assets/runtime, config metadata and docs in line with the exported/rigged GLBs.
#
#   scripts/refresh-runtime.sh            # everything that exists
#   scripts/refresh-runtime.sh --no-rig   # skip re-rigging (use the rigged GLBs as they are)
#
# * units whose exported GLB is newer than their rigged GLB are re-rigged (scripts/rig-unit.sh);
#   Goblin and Orc Archer are hand-adjusted and are never re-rigged automatically
# * every runtime folder is re-imported with balsam (scripts/import-runtime.py)
# * app/config/assetmeta.js, footOffset values and docs/asset-manifest.md are regenerated
set -uo pipefail
cd "$(dirname "$0")/.."
export QTMESH_NO_TELEMETRY=1
RIG=1; [ "${1:-}" = "--no-rig" ] && RIG=0

# name : runtime folder : type name : rig? (extra clip)
ASSETS=(
  "Goblin:goblin:Goblin:manual"
  "Orc Archer:orc_archer:OrcArcher:manual"
  "Orc:orc:Orc:rig"
  "Ogre:ogre:Ogre:rig"
  "Clan Fortress:clan_fortress:ClanFortress:static"
  "War Foundry:war_foundry:WarFoundry:static"
  "Iron Deposit:iron_deposit:IronDeposit:static"
  "Large Rocks:large_rocks:LargeRocks:static"
  "Small Rocks:small_rocks:SmallRocks:static"
  "Dead Ironwood tree:dead_tree:DeadIronwoodtree:static"
  "Broken Cart:broken_cart:BrokenCart:static"
  "Arrow:arrow:Arrow:static"
)

for spec in "${ASSETS[@]}"; do
  IFS=: read -r name folder type mode <<<"$spec"
  exported="assets/exported/$name/$name.glb"
  rigged="assets/rigged/$name/${name}_rigged.glb"
  case "$mode" in
    static)
      [ -f "$exported" ] || { echo "-- $name: no export yet, keeping current runtime"; continue; }
      echo "== import static $name"; python3 scripts/import-runtime.py "$exported" "assets/runtime/$folder" --name "$type" | tail -1 | cut -c1-100 ;;
    rig)
      [ -f "$exported" ] || { echo "-- $name: no export yet, keeping current runtime"; continue; }
      if [ $RIG -eq 1 ] && { [ ! -f "$rigged" ] || [ "$exported" -nt "$rigged" ]; }; then
        echo "== rig $name"; scripts/rig-unit.sh "$name" 2>&1 | grep -E "^  [A-Z]|rror" | tr '\n' ' '; echo
      fi
      [ -f "$rigged" ] || { echo "-- $name: no rig, skipping"; continue; }
      echo "== import rigged $name"; python3 scripts/import-runtime.py "$rigged" "assets/runtime/$folder" --name "$type" | tail -1 | cut -c1-100 ;;
    manual)
      [ -f "$rigged" ] || continue
      echo "== import rigged (hand-adjusted) $name"; python3 scripts/import-runtime.py "$rigged" "assets/runtime/$folder" --name "$type" | tail -1 | cut -c1-100 ;;
  esac
done

python3 scripts/gen-asset-meta.py
python3 scripts/update-asset-offsets.py | grep -E "->|updated"
python3 scripts/gen-asset-manifest.py
echo "runtime refreshed: $(du -sh assets/runtime | cut -f1)"
