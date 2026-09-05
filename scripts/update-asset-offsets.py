#!/usr/bin/env python3
"""Recompute `footOffset` in app/config/assets.js from the models' bounding boxes.

    python3 scripts/update-asset-offsets.py [--dry-run]

TRELLIS.2 normalises each model to a ~1 unit box centred on its origin, but the exact minimum Y
differs per generation. footOffset (model units) lifts the model so its base sits on y = 0:
footOffset = -minY of the GLB that the runtime asset was imported from (rigged GLB for units,
exported GLB for buildings/props). Run after regenerating or re-rigging models.
"""
import os
import re
import subprocess
import sys

Q = os.environ.get("QTMESH", "/opt/homebrew/bin/qtmesheditor")
ENV = dict(os.environ, QTMESH_NO_TELEMETRY="1")
DRY = "--dry-run" in sys.argv

# assets.js key -> GLB used for the runtime import
SOURCES = {
    "goblin_worker": "assets/rigged/Goblin/Goblin_rigged.glb",
    "orc_warrior": "assets/rigged/Orc/Orc_rigged.glb",
    "orc_archer": "assets/rigged/Orc Archer/Orc Archer_rigged.glb",
    "ironhide_ogre": "assets/rigged/Ogre/Ogre_rigged.glb",
    "clan_fortress": "assets/exported/Clan Fortress/Clan Fortress.glb",
    "enemy_fortress": "assets/exported/Clan Fortress/Clan Fortress.glb",
    "war_foundry": "assets/exported/War Foundry/War Foundry.glb",
    "iron_deposit": "assets/exported/Iron Deposit/Iron Deposit.glb",
    "rocks_large": "assets/exported/Large Rocks/Large Rocks.glb",
    "rocks_small": "assets/exported/Small Rocks/Small Rocks.glb",
    "dead_tree": "assets/exported/Dead Ironwood tree/Dead Ironwood tree.glb",
    "broken_cart": "assets/exported/Broken Cart/Broken Cart.glb",
}


def min_y(glb):
    out = subprocess.run([Q, "info", glb], capture_output=True, text=True, env=ENV).stdout
    m = re.search(r"Bounding Box: \(([-\d.]+), ([-\d.]+), ([-\d.]+)\) to \(([-\d.]+), ([-\d.]+), ([-\d.]+)\)", out)
    return -float(m.group(2)) if m else None


def main():
    p = "app/config/assets.js"
    src = open(p, encoding="utf-8").read()
    for key, glb in SOURCES.items():
        if not os.path.exists(glb):
            print(f"{key:15s} skipped (no {glb})"); continue
        off = min_y(glb)
        if off is None:
            print(f"{key:15s} skipped (no bbox)"); continue
        pat = re.compile(rf"(\b{key}\b[^\n]*?\n?[^}}]*?footOffset:\s*)([-\d.]+)", re.S)
        m = pat.search(src)
        if not m:
            print(f"{key:15s} not found in assets.js"); continue
        old = float(m.group(2))
        src = src[:m.start(2)] + f"{off:.2f}" + src[m.end(2):]
        print(f"{key:15s} footOffset {old:.2f} -> {off:.2f}")
    if not DRY:
        open(p, "w", encoding="utf-8").write(src)
        print("updated", p)


if __name__ == "__main__":
    main()
