#!/usr/bin/env python3
"""Write the deployable index.html for the web build from web/index.template.html.

    make-web-index.py <deploy_dir> [app_name]

The template is Ironfang's own shell (loading screen with the turntable sprite, real download
and asset-preload progress, COOP/COEP service-worker shim, ?args= program arguments, mobile
viewport). It replaces Qt's generated <app>.html, which stays in the deploy dir for reference.
Placeholders: @WASM_BYTES@ / @WASM_MB@ (size of <app>.wasm), @HAS_MANIFEST@ (ironfang-assets.json present).
"""
import os
import shutil
import sys

d = sys.argv[1]
app = sys.argv[2] if len(sys.argv) > 2 else "ironfang"
root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

wasm = os.path.join(d, f"{app}.wasm")
size = os.path.getsize(wasm) if os.path.exists(wasm) else 0
manifest = os.path.exists(os.path.join(d, "ironfang-assets.json"))

html = open(os.path.join(root, "web", "index.template.html"), encoding="utf-8").read()
html = (html.replace("@WASM_BYTES@", str(size))
            .replace("@WASM_MB@", f"{size / 1048576:.0f}")
            .replace("@HAS_MANIFEST@", "true" if manifest else "false"))
open(os.path.join(d, "index.html"), "w", encoding="utf-8").write(html)
shutil.copy(os.path.join(root, "web", "loading-ironfang.webp"), os.path.join(d, "loading-ironfang.webp"))
print(f"wrote {os.path.join(d, 'index.html')} (wasm {size / 1048576:.1f} MB, manifest={manifest})")
