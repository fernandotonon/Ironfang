#!/usr/bin/env python3
"""Shrink a deploy copy of assets/runtime for the web: PNG textures -> JPEG, QML references
rewritten. Runs on the DEPLOY copy only; the source assets stay PNG.

    python3 scripts/web-optimize-assets.py <deploy_assets_dir> [--quality 84] [--normal-quality 90]

The TRELLIS.2 textures are fully opaque, so JPEG loses nothing the game shows; it cuts the
texture payload roughly 6x (1024² PNG ~1.3-2 MB -> ~200-300 KB).
"""
import argparse
import glob
import os
import re

from PIL import Image, ImageFile

# large progressive/optimised JPEGs need a bigger encoder buffer ("broken data stream" otherwise)
ImageFile.MAXBLOCK = 16 * 1024 * 1024


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("assets_dir")
    ap.add_argument("--quality", type=int, default=84)
    ap.add_argument("--normal-quality", type=int, default=90)
    a = ap.parse_args()

    before = after = 0
    renamed = {}
    for png in glob.glob(os.path.join(a.assets_dir, "**", "maps", "*.png"), recursive=True):
        im = Image.open(png)
        if im.mode == "RGBA" and im.getchannel("A").getextrema()[0] < 250:
            continue                                   # real alpha: keep as PNG
        jpg = png[:-4] + ".jpg"
        q = a.normal_quality if "normal" in os.path.basename(png).lower() else a.quality
        im.convert("RGB").save(jpg, "JPEG", quality=q, optimize=True, subsampling=0 if "normal" in png else 2)
        before += os.path.getsize(png); after += os.path.getsize(jpg)
        os.remove(png)
        renamed[os.path.basename(png)] = os.path.basename(jpg)

    # rewrite texture sources in the balsam QML files
    for qml in glob.glob(os.path.join(a.assets_dir, "**", "*.qml"), recursive=True):
        s = open(qml, encoding="utf-8").read()
        s2 = s
        for old, new in renamed.items():
            s2 = s2.replace(f'"maps/{old}"', f'"maps/{new}"').replace(f'"{old}"', f'"{new}"')
        if s2 != s:
            open(qml, "w", encoding="utf-8").write(s2)
    print(f"textures: {len(renamed)} PNG -> JPEG, {before / 1048576:.1f} MB -> {after / 1048576:.1f} MB")


if __name__ == "__main__":
    main()
