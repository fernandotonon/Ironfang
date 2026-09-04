#!/usr/bin/env bash
# Publish the static WebAssembly build to GitHub Pages (gh-pages branch).
#
#   scripts/build-wasm.sh            # produces deploy/multithread
#   scripts/deploy-pages.sh [--dry-run]
#
# GitHub Pages cannot set COOP/COEP headers; the bundled coi-serviceworker.js supplies them
# (one automatic reload on the first visit). Pages serves .wasm as application/wasm and gzips
# it on the wire. Enable Pages once in the repo settings: Source = "Deploy from a branch",
# branch gh-pages, folder /(root).
set -euo pipefail
cd "$(dirname "$0")/.."
SRC="deploy/multithread"
[ -f "$SRC/ironfang.wasm" ] || { echo "run scripts/build-wasm.sh first"; exit 1; }
DRY=0; [ "${1:-}" = "--dry-run" ] && DRY=1

WT="$(mktemp -d)/gh-pages"
if git show-ref --verify --quiet refs/heads/gh-pages; then
    git worktree add -q "$WT" gh-pages
else
    git worktree add -q --detach "$WT"
    git -C "$WT" checkout -q --orphan gh-pages
    git -C "$WT" rm -rfq . 2>/dev/null || true
fi
find "$WT" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -R "$SRC"/. "$WT"/
touch "$WT/.nojekyll"                       # serve files verbatim (no Jekyll processing)
cp THIRD_PARTY_LICENSES.md "$WT/"
mkdir -p "$WT/LICENSES" && cp LICENSE "$WT/LICENSES/Ironfang-MIT.txt" \
    && cp external/clayground/LICENSE "$WT/LICENSES/Clayground-MIT.txt"

git -C "$WT" add -A
if git -C "$WT" diff --cached --quiet; then echo "gh-pages already up to date"; else
    git -C "$WT" commit -q -m "Deploy Ironfang web build $(git rev-parse --short HEAD)

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
fi
if [ $DRY -eq 1 ]; then echo "dry run: not pushing. Worktree: $WT"; exit 0; fi
git -C "$WT" push -q origin gh-pages
git worktree remove --force "$WT"
echo "Pushed gh-pages. Site: https://$(git remote get-url origin | sed -E 's#.*github.com[:/]([^/]+)/([^/.]+).*#\1.github.io/\2#')/"
