#!/usr/bin/env python3
"""Convert a QtMeshEditor GLB into a Qt Quick 3D runtime asset.

    import-runtime.py <input.glb> <output_dir> [--name Name] [--balsam PATH]
                      [--one-shot Attack,Hit,Death]

1. Runs Qt's `balsam` (the official, Qt-supported glTF importer) on the GLB. It
   writes `<Name>.qml`, `meshes/*.mesh`, `maps/*.png` and, for rigged models,
   `animations/*.qad` keyframe files driven by QtQuick.Timeline.
2. Patches the generated QML so the game can drive it:
      * `property string clip` selects which named animation clip plays
        (balsam keeps the clip names from the GLB as the Timeline objectName);
      * every clip is disabled unless selected, one-shot clips play once;
      * the mesh Model becomes `pickable` so View3D.pick() hits it;
      * `readonly property var clips` lists the available clip names.
The original GLB is never modified; re-run this script after regenerating it.
"""
import argparse
import os
import re
import shutil
import subprocess
import sys


def find_balsam(explicit):
    if explicit:
        return explicit
    for cand in (os.environ.get("BALSAM"),
                 os.path.expanduser("~/Qt/6.11.1/macos/bin/balsam"),
                 shutil.which("balsam")):
        if cand and os.path.exists(cand):
            return cand
    sys.exit("balsam not found: pass --balsam or set BALSAM")


def patch_qml(path, one_shot):
    src = open(path, encoding="utf-8").read()

    # 1. clip API on the root node
    src = re.sub(r"(Node \{\n\s*id: node\n)",
                 r'\1'
                 '    // --- Ironfang runtime API (added by scripts/import-runtime.py) ---\n'
                 '    property string clip: "Idle"\n'
                 '    readonly property var clips: [__CLIPS__]\n'
                 '    signal clipFinished(string name)\n',
                 src, count=1)

    # 2. every Timeline: enabled/running only when selected
    clips = []

    def patch_timeline(m):
        block = m.group(0)
        name_m = re.search(r'objectName: "([^"]+)"', block)
        if not name_m:
            return block
        name = name_m.group(1)
        clips.append(name)
        loops = "1" if name in one_shot else "Animation.Infinite"
        block = block.replace("enabled: true", f'enabled: node.clip === "{name}"')
        block = block.replace("running: true", f'running: node.clip === "{name}"')
        block = re.sub(r"loops: Animation\.Infinite", f"loops: {loops}", block)
        if name in one_shot:
            block = block.replace(
                f"loops: {loops}",
                f"loops: {loops}\n            onFinished: node.clipFinished(\"{name}\")")
        return block

    src = re.sub(r"    Timeline \{.*?\n    \}\n", patch_timeline, src, flags=re.S)
    src = src.replace("[__CLIPS__]", "[" + ", ".join(f'"{c}"' for c in clips) + "]")

    # 3. pickable mesh
    src = re.sub(r'(\n(\s*)source: "meshes/[^"]+"\n)', r'\1\2pickable: true\n', src)

    open(path, "w", encoding="utf-8").write(src)
    return clips


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("glb")
    ap.add_argument("out_dir")
    ap.add_argument("--name", help="type/file name (default: GLB base name)")
    ap.add_argument("--balsam")
    ap.add_argument("--one-shot", default="Attack,Hit,Death,Gather",
                    help="comma list of clips that play once")
    ap.add_argument("--inline-keyframes", action="store_true",
                    help="balsam --disable-useBinaryKeyframes: keyframes inline in the QML instead of "
                         "animations/*.qad files. Needed when the QML is served over HTTP (Clayground "
                         "Web Runtime): QtQuick.Timeline reads keyframeSource with QFile, local/qrc only.")
    a = ap.parse_args()

    name = a.name or os.path.splitext(os.path.basename(a.glb))[0]
    balsam = find_balsam(a.balsam)
    os.makedirs(a.out_dir, exist_ok=True)

    # balsam names outputs after the input file: stage a copy with the wanted name
    stage = os.path.join(a.out_dir, ".stage")
    os.makedirs(stage, exist_ok=True)
    staged = os.path.join(stage, name + ".glb")
    shutil.copy(a.glb, staged)
    src_dir = os.path.dirname(os.path.abspath(a.glb))
    for f in os.listdir(src_dir):           # external textures referenced by the GLB
        if f.lower().endswith((".png", ".jpg", ".jpeg")):
            shutil.copy(os.path.join(src_dir, f), stage)

    for stale in ("meshes", "maps", "animations"):
        shutil.rmtree(os.path.join(a.out_dir, stale), ignore_errors=True)
    cmd = [balsam, staged, "-o", a.out_dir]
    if a.inline_keyframes:
        cmd.insert(1, "--disable-useBinaryKeyframes")
    subprocess.run(cmd, check=True)
    shutil.rmtree(stage)

    qml = os.path.join(a.out_dir, name + ".qml")
    clips = patch_qml(qml, set(a.one_shot.split(",")))
    n_qad = len(os.listdir(os.path.join(a.out_dir, "animations"))) \
        if os.path.isdir(os.path.join(a.out_dir, "animations")) else 0
    print(f"{qml}: clips={clips} keyframe files={n_qad}")


if __name__ == "__main__":
    main()
