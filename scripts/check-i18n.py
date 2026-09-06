#!/usr/bin/env python3
"""Localization completeness check (run by ctest and by hand).

    python3 scripts/check-i18n.py            # exit 1 on any problem

* every `Loc.tr("key")` / `tr("key")` literal used in app/**/*.qml and app/**/*.js exists in en.js
* every key of en.js exists in every other language table and vice versa (no missing, no stray)
* mission texts (objective text, trigger message/showDialogue text, outcome, briefing) that look
  like keys (contain a dot and no space) must exist too
"""
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
I18N = os.path.join(ROOT, "app", "i18n")


def load_table(path):
    src = open(path, encoding="utf-8").read()
    keys = {}
    for m in re.finditer(r'^\s*"((?:[^"\\]|\\.)*)"\s*:\s*"((?:[^"\\]|\\.)*)"\s*,?\s*$', src, re.M):
        if m.group(1) in keys:
            print(f"{os.path.basename(path)}: duplicate key {m.group(1)!r}")
        keys[m.group(1)] = m.group(2)
    return keys


def used_keys():
    keys = set()
    files = glob.glob(os.path.join(ROOT, "app", "**", "*.qml"), recursive=True) + \
            glob.glob(os.path.join(ROOT, "app", "**", "*.js"), recursive=True)
    for f in files:
        if "/i18n/" in f:
            continue
        src = open(f, encoding="utf-8").read()
        for m in re.finditer(r'\btr\(\s*"([^"]+)"', src):
            k = m.group(1)
            if k.endswith(".") or "." not in k:      # dynamic prefix ("difficulty." + d) - checked by the enumerations below
                continue
            keys.add(k)
        if "/missions/" in f:
            for m in re.finditer(r'\b(?:text|intro|outro|victory|defeat|title|description|speaker)\s*:\s*"([a-z0-9_]+(?:\.[a-z0-9_]+)+)"', src):
                keys.add(m.group(1))
    return keys


def main():
    tables = {os.path.splitext(os.path.basename(p))[0]: load_table(p) for p in sorted(glob.glob(os.path.join(I18N, "*.js")))}
    if "en" not in tables:
        print("no app/i18n/en.js"); return 1
    problems = 0
    en = tables["en"]
    for lang, table in tables.items():
        if lang == "en":
            continue
        missing = sorted(set(en) - set(table))
        stray = sorted(set(table) - set(en))
        for k in missing:
            print(f"{lang}: missing key {k!r}"); problems += 1
        for k in stray:
            print(f"{lang}: key {k!r} not in en"); problems += 1
        for k, v in table.items():
            if k in en and v.strip() == "":
                print(f"{lang}: empty translation for {k!r}"); problems += 1
    used = used_keys()
    # enumerations behind dynamic prefixes
    for d in ("story", "warrior", "warchief"):
        used.add("difficulty." + d); used.add("difficulty." + d + ".note")
    for m in ("iron", "steel", "gold", "none"):
        used.add("medal." + m)
    balance = open(os.path.join(ROOT, "app", "config", "balance.js"), encoding="utf-8").read()
    units = re.search(r"var units = \{(.*?)\n\}", balance, re.S).group(1)
    buildings = re.search(r"var buildings = \{(.*?)\n\}", balance, re.S).group(1)
    for t in re.findall(r"^\s*(\w+):\s*\{", units, re.M):
        used.add("unit." + t)
    for t in re.findall(r"^\s*(\w+):\s*\{", buildings, re.M):
        used.add("building." + t)
    campaign = open(os.path.join(ROOT, "app", "missions", "campaign.js"), encoding="utf-8").read()
    for k in re.findall(r'(?:titleKey|taglineKey):\s*"([^"]+)"', campaign):
        used.add(k)
    for k in sorted(used - set(en)):
        print(f"en: key {k!r} used in sources but not defined"); problems += 1
    # placeholders must match between languages
    for lang, table in tables.items():
        for k, v in table.items():
            if k in en and set(re.findall(r"\{(\w+)\}", v)) != set(re.findall(r"\{(\w+)\}", en[k])):
                print(f"{lang}: placeholder mismatch in {k!r}"); problems += 1
    print(f"i18n: {len(en)} keys, {len(tables)} languages, {len(used)} keys referenced, {problems} problem(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
