#!/usr/bin/env node
// Mechanical regex-scan engine (node). One of the four catalog engines; the
// reference implementation, because the catalog's canonical regex flavor is
// JavaScript. Parses ../references/regex-scan.md at run time and never
// duplicates patterns into code.
//
// Contract (identical across engines): engine [file|-] [--json]
// Exit: 0 within gate; 1 gate violation; 2 usage or catalog parse error.
//
// Run: node scan.mjs input.txt
//      cat input.txt | node scan.mjs --json
import { readFileSync } from "node:fs";

// SCAN_CATALOG env override exists for the parity tests (corrupt-copy cases);
// production always uses the catalog that ships next to the engine.
const CATALOG = process.env.SCAN_CATALOG
  ?? new URL("../../references/regex-scan.md", import.meta.url);
let md;
try {
  md = readFileSync(CATALOG, "utf8");
} catch (e) {
  console.error(`scan: catalog not found: ${CATALOG.href}`);
  process.exit(2);
}

// ---------------------------------------------------------------- parse ---//
const entries = [];
let parseError = null;
{
  let sev = null, title = null, kind = null, buf = null;
  const flush = () => {
    if (title == null) return;
    if (buf !== null) {
      entries.push({ title, sev, kind: "regex", source: buf.join("\n") });
    } else if (sev === "LIMIT" || sev === "SOFT") {
      entries.push({ title, sev, kind: "judgment", source: null });
    } else if (sev === "HARD" && title.includes("Em dash")) {
      entries.push({ title, sev, kind: "literal", source: null });
    } else {
      parseError = `HARD section without a fence: "${title}"`;
    }
    title = null; buf = null;
  };
  for (const raw of md.split("\n")) {
    const m = raw.match(/^## (HARD|LIMIT|SOFT) patterns\s*$/);
    if (m) { flush(); sev = m[1]; continue; }
    if (title !== null && /^```/.test(raw)) {
      if (buf === null) { buf = []; }
      else { entries.push({ title, sev, kind: "regex", source: buf.join("\n") }); title = null; buf = null; }
      continue;
    }
    if (title !== null && buf !== null) { buf.push(raw); continue; }
    if (/^### /.test(raw)) { flush(); title = raw.slice(4).trim(); buf = null; continue; }
    if (title !== null) continue; // prose before an opening fence
  }
  flush();
}
if (parseError) { console.error(`scan: catalog parse error: ${parseError}`); process.exit(2); }
if (entries.length === 0) { console.error("scan: catalog parse error: no pattern sections found"); process.exit(2); }

const display = (t) => t.split(" — ")[0];
const limitMax = (t) => { const m = t.match(/LIMIT (\d+)/); return m ? Number(m[1]) : null; };
for (const e of entries) { e.name = display(e.title); e.max = e.sev === "LIMIT" ? limitMax(e.title) : null; }

// ---------------------------------------------------------------- input ---//
const args = process.argv.slice(2);
let json = false, file = null, sawFile = false;
for (const a of args) {
  if (a === "--json") json = true;
  else if (a === "-") { if (sawFile) die2("multiple input files"); file = "-"; sawFile = true; }
  else if (a.startsWith("--")) die2(`unknown option: ${a}`);
  else { if (sawFile) die2("multiple input files"); file = a; sawFile = true; }
}
function die2(msg) { console.error(`scan: ${msg}`); process.exit(2); }

let text;
try {
  if (file === null) {
    if (process.stdin.isTTY) die2("no input file and stdin is a terminal (usage: engine [file|-] [--json])");
    text = readFileSync(0, "utf8");
  } else if (file === "-") {
    text = readFileSync(0, "utf8");
  } else {
    text = readFileSync(file, "utf8");
  }
} catch (e) {
  die2(`cannot read input: ${e.message}`);
}

// ----------------------------------------------------------------- scan ---//
const lineStarts = [0];
for (let i = 0; i < text.length; i++) if (text.charCodeAt(i) === 10) lineStarts.push(i + 1);
const lc = (idx) => {
  let lo = 0, hi = lineStarts.length - 1;
  while (lo < hi) { const mid = (lo + hi + 1) >> 1; if (lineStarts[mid] <= idx) lo = mid; else hi = mid - 1; }
  return { line: lo + 1, col: idx - lineStarts[lo] + 1 };
};
const clip = (s) => {
  s = s.replace(/\n/g, "⏎");
  return s.length > 64 ? s.slice(0, 61) + "..." : s;
};

const results = [];
let violation = false;
for (const e of entries) {
  if (e.kind === "judgment") {
    results.push({ name: e.name, severity: e.sev, count: null, judged: true, spans: [] });
    continue;
  }
  let hits;
  if (e.kind === "literal") {
    hits = [...text.matchAll(/—|--/g)];
  } else {
    let re;
    try {
      re = new RegExp(e.source, "gi");
    } catch (err) {
      console.error(`scan: catalog parse error: pattern "${e.name}" does not compile: ${err.message}`);
      process.exit(2);
    }
    hits = [...text.matchAll(re)];
  }
  const spans = hits.map((h) => {
    const s = lc(h.index), en = lc(h.index + h[0].length);
    return { start: s, end: en, text: clip(h[0]) };
  });
  results.push({ name: e.name, severity: e.sev, count: hits.length, judged: false, spans });

  if (e.sev === "HARD" && hits.length > 0) violation = true;
  if (e.sev === "LIMIT" && e.max !== null && hits.length > e.max) violation = true;
}

// --------------------------------------------------------------- output ---//
function textReport() {
  const w = Math.max(...results.map((r) => r.name.length));
  const out = [];
  for (const r of results) {
    const label = r.judged ? "JUDGMENT REQUIRED" : `${r.count} ${r.count === 1 ? "hit" : "hits"}`;
    out.push(`${r.severity}  ${r.name.padEnd(w)}  ${label}`);
    for (const s of r.spans) {
      out.push(`  L${s.start.line} col${s.start.col}-L${s.end.line} col${s.end.col}  "${s.text}"`);
    }
  }
  return out.join("\n") + "\n";
}

if (json) {
  process.stdout.write(JSON.stringify(results) + "\n");
} else {
  process.stdout.write(textReport());
}
process.exitCode = violation ? 1 : 0;