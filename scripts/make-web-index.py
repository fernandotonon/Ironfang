#!/usr/bin/env python3
"""Turn Qt's generated <app>.html into the deployable index.html.

    make-web-index.py <deploy_dir> [app_name]

* adds the coi-serviceworker.js shim (COOP/COEP for hosts that cannot set headers)
* lets the page pass program arguments to the app:  index.html?args=--autotest%20--no-models
* sets the page title
"""
import os
import re
import sys

d = sys.argv[1]
app = sys.argv[2] if len(sys.argv) > 2 else "ironfang"
html = open(os.path.join(d, f"{app}.html"), encoding="utf-8").read()

shim = '<script src="coi-serviceworker.js"></script>\n'
if "coi-serviceworker" not in html:
    html = re.sub(r"(<head[^>]*>)", r"\1\n" + shim, html, count=1)

args_js = ("arguments: (new URLSearchParams(location.search).get('args') || '')"
           ".split(' ').filter(Boolean),\n")
if "URLSearchParams(location.search).get('args')" not in html:
    html = html.replace("qtLoad({", "qtLoad({\n                    " + args_js, 1)

html = html.replace(f"<title>{app}</title>", "<title>Ironfang: First Siege</title>")
open(os.path.join(d, "index.html"), "w", encoding="utf-8").write(html)
print(f"wrote {os.path.join(d, 'index.html')}")
