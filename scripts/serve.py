#!/usr/bin/env python3
"""Static server for testing the WebAssembly build the way a real host serves it.

    python3 scripts/serve.py <dir> [--port 8080]

* Cross-Origin-Opener-Policy / Cross-Origin-Embedder-Policy headers -> SharedArrayBuffer,
  which multithreaded Qt WebAssembly (needed for Qt Quick 3D) requires.
* application/wasm MIME type for .wasm files.
* No caching, so a rebuilt file is what the browser loads.
GitHub Pages cannot send these headers; there the bundled coi-serviceworker.js injects them.
"""
import argparse
import os
import sys
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer


class Handler(SimpleHTTPRequestHandler):
    extensions_map = {
        **SimpleHTTPRequestHandler.extensions_map,
        ".wasm": "application/wasm",
        ".js": "text/javascript",
        ".mjs": "text/javascript",
        ".qml": "text/plain; charset=utf-8",
        ".mesh": "application/octet-stream",
        ".qad": "application/octet-stream",
        ".json": "application/json",
    }

    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cross-Origin-Resource-Policy", "same-origin")
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def log_message(self, fmt, *args):
        sys.stderr.write("%s %s\n" % (self.address_string(), fmt % args))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("directory")
    ap.add_argument("--port", type=int, default=8080)
    a = ap.parse_args()
    os.chdir(a.directory)
    srv = ThreadingHTTPServer(("127.0.0.1", a.port), Handler)
    print(f"Serving {os.getcwd()} at http://localhost:{a.port}/  (COOP/COEP on, no cache)")
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
