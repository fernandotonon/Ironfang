#!/usr/bin/env python3
"""Pre-matte concept images for TRELLIS.2: subject opaque, background AND its soft drop shadow
transparent.

    python3 scripts/prematte.py <in.png> <out.png> [--threshold 60] [--preview out_preview.png]

Why: the concept art is a figure on a plain grey backdrop with a soft shadow. QtMeshEditor's
3.37 matte protects thin limbs with a colour-distance mask, which also keeps the shadow, and
TRELLIS then builds a slab under the model. Feeding an RGBA image (no --remove-bg) sidesteps
that. Pure PIL: background colour = median of the border pixels; background = everything the
edges can flood-fill through pixels whose max channel distance to that colour is <= threshold
(the shadow is ~30-50 away, the subject >= 60); enclosed regions (armour highlights, gaps)
stay opaque; small specks are removed and the edge is feathered by one pixel.
"""
import argparse
import statistics
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFilter


def prematte(src, threshold=60):
    im = Image.open(src).convert("RGB")
    w, h = im.size
    px = im.load()
    border = [px[x, y] for x in range(0, w, 4) for y in (0, 1, h - 2, h - 1)] + \
             [px[x, y] for y in range(0, h, 4) for x in (0, 1, w - 2, w - 1)]
    bg = tuple(int(statistics.median(c[i] for c in border)) for i in range(3))

    # max channel distance to the background colour
    diff = ImageChops.difference(im, Image.new("RGB", im.size, bg))
    r, g, b = diff.split()
    dist = ImageChops.lighter(ImageChops.lighter(r, g), b)
    # background candidates = low distance; paint them 0, the rest 255 (subject candidates)
    cand = dist.point(lambda v: 0 if v <= threshold else 255).convert("L")
    # flood the true background from the border: candidates connected to the edge become 128
    seeds = [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1), (w // 2, 0), (w // 2, h - 1), (0, h // 2), (w - 1, h // 2)]
    for x in range(0, w, max(1, w // 24)):
        seeds += [(x, 0), (x, h - 1)]
    for y in range(0, h, max(1, h // 24)):
        seeds += [(0, y), (w - 1, y)]
    for s in seeds:
        if cand.getpixel(s) == 0:
            ImageDraw.floodfill(cand, s, 128)
    # alpha: everything not reached by the flood is subject (enclosed low-contrast pixels too)
    alpha = cand.point(lambda v: 0 if v == 128 else 255)
    # remove specks / thin shadow slivers, then restore size, then feather
    alpha = alpha.filter(ImageFilter.MinFilter(5)).filter(ImageFilter.MaxFilter(5))
    alpha = alpha.filter(ImageFilter.GaussianBlur(0.8))
    out = im.copy()
    out.putalpha(alpha)
    coverage = sum(1 for v in alpha.getdata() if v > 128) / (w * h)
    return out, bg, coverage


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("src"); ap.add_argument("dst")
    ap.add_argument("--threshold", type=int, default=60)
    ap.add_argument("--preview", help="write the matte composited over magenta for a visual check")
    a = ap.parse_args()
    out, bg, cov = prematte(a.src, a.threshold)
    out.save(a.dst, optimize=True)
    if a.preview:
        prev = Image.new("RGB", out.size, (255, 0, 255))
        prev.paste(out, (0, 0), out)
        prev.thumbnail((700, 700))
        prev.save(a.preview)
    print(f"{a.dst}: bg={bg} threshold={a.threshold} subject coverage={cov:.1%}")
    if cov < 0.05 or cov > 0.9:
        print("warning: implausible coverage - check the preview", file=sys.stderr)


if __name__ == "__main__":
    main()
