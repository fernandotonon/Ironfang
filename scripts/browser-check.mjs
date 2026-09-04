#!/usr/bin/env node
// Headless-Chrome smoke test for the WebAssembly build, driven over the DevTools protocol
// (no npm dependencies - Node 22's built-in WebSocket and fetch are enough).
//
//   node scripts/browser-check.mjs <url> [--seconds 40] [--out shot.png] [--chrome PATH]
//
// Prints every console message (Qt routes qDebug/qWarning to console.*), reports
// crossOriginIsolated / SharedArrayBuffer availability, download sizes from the network
// events, and saves a screenshot at the end. Exit code 1 on uncaught errors or Qt fatals.
import { spawn } from "node:child_process";
import { writeFileSync } from "node:fs";

const args = process.argv.slice(2);
const url = args.find(a => !a.startsWith("--")) ?? "http://localhost:8080/index.html";
const opt = (name, def) => { const i = args.indexOf(name); return i >= 0 ? args[i + 1] : def; };
const seconds = Number(opt("--seconds", 40));
const out = opt("--out", "browser-check.png");
const chrome = opt("--chrome", process.env.CHROME ?? "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome");
const port = 9333;

const proc = spawn(chrome, [
  "--headless=new", `--remote-debugging-port=${port}`, "--window-size=1280,800",
  "--no-first-run", "--user-data-dir=/tmp/ironfang-chrome-profile", "--enable-unsafe-swiftshader",
  "--ignore-gpu-blocklist", "--use-angle=metal", "--enable-webgl", "--mute-audio", "about:blank",
], { stdio: "ignore" });

const sleep = ms => new Promise(r => setTimeout(r, ms));
let id = 0; const pending = new Map(); let ws;
const send = (method, params = {}) => new Promise((res, rej) => {
  const msgId = ++id; pending.set(msgId, { res, rej }); ws.send(JSON.stringify({ id: msgId, method, params }));
});

let fatal = false; const bytes = {}; let t0;
try {
  let targets;
  for (let i = 0; i < 50; ++i) { try { targets = await (await fetch(`http://127.0.0.1:${port}/json`)).json(); break; } catch { await sleep(200); } }
  const page = targets.find(t => t.type === "page");
  ws = new WebSocket(page.webSocketDebuggerUrl);
  await new Promise(r => ws.onopen = r);
  ws.onmessage = (ev) => {
    const m = JSON.parse(ev.data);
    if (m.id && pending.has(m.id)) { const p = pending.get(m.id); pending.delete(m.id); m.error ? p.rej(m.error) : p.res(m.result); return; }
    if (m.method === "Runtime.consoleAPICalled") {
      const text = m.params.args.map(a => a.value ?? a.description ?? "").join(" ");
      const t = ((Date.now() - t0) / 1000).toFixed(1);
      console.log(`[${t}s] console.${m.params.type}: ${text}`);
      if (/Qt Fatal|Qt Critical|RuntimeError|Aborted\(/.test(text)) fatal = true;
    } else if (m.method === "Runtime.exceptionThrown") {
      console.log("EXCEPTION:", m.params.exceptionDetails.text, m.params.exceptionDetails.exception?.description ?? "");
      fatal = true;
    } else if (m.method === "Network.loadingFinished") {
      bytes[m.params.requestId] = m.params.encodedDataLength;
    } else if (m.method === "Network.responseReceived") {
      names[m.params.requestId] = m.params.response.url.split("/").pop();
    }
  };
  const names = {};
  await send("Runtime.enable"); await send("Network.enable"); await send("Page.enable");
  t0 = Date.now();
  await send("Page.navigate", { url });
  await sleep(seconds * 1000);
  const iso = await send("Runtime.evaluate", { expression: "JSON.stringify({iso: window.crossOriginIsolated, sab: typeof SharedArrayBuffer !== 'undefined', ua: navigator.userAgent})", returnByValue: true });
  console.log("isolation:", iso.result.value);
  const mem = await send("Runtime.evaluate", { expression: "performance.memory ? JSON.stringify({usedJSHeapMB: Math.round(performance.memory.usedJSHeapMB ?? performance.memory.usedJSHeapSize/1048576)}) : 'n/a'", returnByValue: true });
  console.log("js heap:", mem.result.value);
  let total = 0;
  for (const [rid, n] of Object.entries(bytes)) { total += n; if (n > 100000) console.log(`download ${names[rid] ?? rid}: ${(n / 1048576).toFixed(1)} MB`); }
  console.log(`total transferred: ${(total / 1048576).toFixed(1)} MB`);
  const shot = await send("Page.captureScreenshot", { format: "png" });
  writeFileSync(out, Buffer.from(shot.data, "base64"));
  console.log("screenshot:", out);
} catch (e) {
  console.error("browser-check failed:", e); fatal = true;
} finally {
  proc.kill("SIGKILL");
}
console.log(fatal ? "RESULT: errors in console" : "RESULT: no fatal console errors");
process.exit(fatal ? 1 : 0);
