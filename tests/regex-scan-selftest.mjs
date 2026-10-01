#!/usr/bin/env node
// Deterministic test suite for the regex scan tooling. Three layers:
//
//   1. Pattern self-test — parses every fenced regex out of
//      skills/ai-output-humanizer/references/regex-scan.md, compiles it
//      (gi flags), and asserts expected hit / no-hit samples. No LLM; the
//      inline parse doubles as the catalog-structure validator.
//      Run: node tests/regex-scan-selftest.mjs
//
//   2. Engine parity — scans the same fixtures with every catalog engine
//      available on this host (node, python3, perl, and powershell if
//      installed) and asserts byte-identical text reports and equal exit
//      codes. The reference engine is node: the catalog flavor is JS.
//
//   3. Dispatcher behavior — scan.sh tiering: --engine passthrough, degraded
//      subset (SKIPPED set must match the mechanical triage exactly), exit-3
//      ask-user path under an empty PATH, and corrupt-catalog exit 2 via the
//      SCAN_CATALOG override.
import { readFileSync, writeFileSync, unlinkSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import path from "node:path";
import os from "node:os";

const md = readFileSync(
  new URL("../skills/ai-output-humanizer/references/regex-scan.md", import.meta.url),
  "utf8",
);

// Sections: "### <title>" ... first fenced code block = the pattern regex.
const sections = [];
for (const m of md.matchAll(/^### (.+)$/gm)) {
  const start = m.index + m[0].length;
  const next = md.indexOf("\n### ", start) === -1 ? md.length : md.indexOf("\n### ", start);
  const fence = md.slice(start, next).match(/```\n(.+?)\n```/s);
  if (fence) sections.push({ name: m[1].trim(), re: new RegExp(fence[1], "gi"), source: fence[1] });
}

if (process.argv.includes("--list")) {
  sections.forEach((s, i) => console.log(`${i}: ${s.name}`));
  process.exit(0);
}

// name-fragment -> [ [text, minHits], ... ]
const CASES = [
  ["one-line contrast", [
    ["It is not a bug, it is a feature.", 1],
    ["Speed matters more than polish.", 0],
  ]],
  ["split sentence", [
    ["This is not about speed. It is about clarity.", 1],
    ["The rollout was smooth and the export landed.", 0],
  ]],
  ["Three-sentence variant", [
    ["Writing is about vocabulary. It is not. Writing is about structure.", 1],
    ["It's about shipping. It's not. It's about being read.", 1],
    ["It is about vocabulary. It is about structure.", 0],
    ["It is not finished, but it is ready to show.", 0],
  ]],
  ["Not just X", [
    ["It is not just about speed, but about trust.", 1],
    ["Not bad for a Tuesday.", 0],
  ]],
  ["Not X, but Y", [
    ["It is not a fix, but a workaround.", 1],
    ["Speed matters more than polish.", 0],
  ]],
  ["Negation chains", [
    ["No fluff, no filler here.", 1],
    ["No config file needed.", 0],
  ]],
  ["Did not X", [
    ["He did not flinch, did not blink.", 1],
    ["He did not blink at all.", 0],
  ]],
  ["Corrective definition", [
    ["Don't call it a rewrite. Call it a rescue.", 1],
    ["Call it a rescue: every test passes.", 0],
  ]],
  ["Superlative totalizers", [
    ["Consistency is the entire game.", 1],
    ["That is the whole point of the review.", 1],
    ["It was the entire day.", 1],
    ["We shipped the whole feature.", 0],
  ]],
  ["punchline", [
    ["The punchline is that nobody reads it.", 1],
    ["The line landed.", 0],
  ]],
  ["not nothing", [
    ["The gains were modest, but that is not nothing.", 1],
    ["Nothing in the report changed.", 0],
  ]],
  ["is real", [
    ["The improvement is real, and it shows in the numbers.", 1],
    ["That loss is worth naming.", 1],
    ["He works in real estate.", 0],
  ]],
  ["Performative honesty", [
    ["Look, the rollout was fine.", 1],
    ["I will not pretend it was smooth; sit with that.", 2],
    ["You already know the answer.", 1],
    ["Turns out nobody reads the changelog.", 1],
    ["You do not have to take my word for it.", 1],
    ["Honestly, it was fine to be honest about it.", 2],
  ]],
  ["the part", [
    ["That is the part a schedule can not capture.", 1],
    ["The only estimate I trust is the small one.", 1],
    ["Peer code review is dead.", 1],
    ["That is why the export button mattered.", 1],
    ["We rebuilt the tool from scratch.", 0],
  ]],
  ["Significance inflation", [
    ["Their attendance stands as a testament to the curators.", 1],
    ["Feedback plays a pivotal role in every release.", 1],
    ["They adapted to an ever-evolving landscape.", 1],
    ["Their attendance rose.", 0],
  ]],
  ["Didactic hedging", [
    ["It is important to note that timing shifted.", 1],
    ["It should be noted that timing shifted.", 1],
    ["Note that timing shifted.", 0],
  ]],
  ["Promotional boilerplate", [
    ["The studio boasts a rooftop; a hidden gem, really.", 1],
    ["Nestled in a converted warehouse.", 1],
    ["The studio has a rooftop.", 0],
  ]],
  ["Chatbot leftovers", [
    ["As of my last update, pricing changed. I hope this helps!", 2],
    ["knowledge cutoff limits this claim", 1],
    ["utm_source=openai", 1],
    ["Pricing changed in March.", 0],
  ]],
  ["participle tails", [
    ["Attendance rose, reflecting the appeal of the show.", 1],
    ["Attendance rose after the redesign.", 0],
  ]],
  ["Vague attribution", [
    ["Experts argue the shift was overdue.", 1],
    ["Industry reports indicate steady growth.", 1],
    ["Dana Chen at Acme argues the shift was overdue.", 0], // named-source attribution evades the regex by design; judgment pass assesses it
  ]],
  ["Despite-challenges formula", [
    ["Despite these challenges, they ship. Only time will tell.", 2],
    ["Shipping slipped a week.", 0],
  ]],
  ["Stranded auxiliary", [
    ["The tool died; the data didn't.", 1],
    ["The tool died, and the data was archived.", 0],
  ]],
  ["AI vocabulary words", [
    ["a seamless, ever-evolving tapestry", 2],
    ["a smooth, changing story", 0],
  ]],
  ["Trailing denial", [
    ["A style tool, not an authorship test.", 1],
    ["The flag exists, but the parser ignores it.", 0],
  ]],
  ["Colon-and-enumeration", [
    ["The shapes are everywhere: sentences that signal importance, rhythm applied by rule, and facts dressed as turning points.", 1],
    ["Ingredients: flour, water, salt.", 0],
  ]],
  ["Assumed-context labels", [
    ["Option C was the winner.", 1],
    ["Plan 2 covers the migration.", 1],
    ["Option A, the streaming migration, was the winner.", 1],
    ["This option works well.", 0],
    ["We compared three approaches.", 0],
  ]],
];

let fails = 0;
for (const [frag, samples] of CASES) {
  const sec = sections.find((s) => s.name.includes(frag));
  if (!sec) { console.log(`FAIL section not found: ${frag}`); fails++; continue; }
  for (const [text, min] of samples) {
    sec.re.lastIndex = 0;
    const hits = [...text.matchAll(sec.re)].length;
    const ok = min === 0 ? hits === 0 : hits >= min;
    console.log(`${ok ? "PASS" : "FAIL"} [${sec.name}] ${JSON.stringify(text)} (min=${min}, got=${hits})`);
    if (!ok) fails++;
  }
}

// Literal-search patterns with no regex fence in the md: em dash / double hyphen.
const em = [["— dash here", 1], ["-- double hyphen", 1], ["plain text", 0]];
for (const [text, min] of em) {
  const hits = (text.match(/—|--/g) || []).length;
  const ok = min === 0 ? hits === 0 : hits >= min;
  console.log(`${ok ? "PASS" : "FAIL"} [em dash literal] ${JSON.stringify(text)}`);
  if (!ok) fails++;
}

console.log(`\n${CASES.length} sections checked, ${sections.length} regexes compiled, ${fails} failures`);

// =========================================================== parity layer ===//
const here = fileURLToPath(new URL(".", import.meta.url));
const root = path.resolve(here, "..");
const skillDir = path.join(root, "skills", "ai-output-humanizer");
const toolsDir = path.join(skillDir, "tools");

const FIXTURES = [
  { file: path.join(root, "tests", "scan-fixtures", "clean.txt"), expectExit: 0 },
  { file: path.join(root, "tests", "scan-fixtures", "seeded.txt"), expectExit: 1,
    counts: { "Em dash / double hyphen": 2, '"It\'s not X, it\'s Y" (one-line contrast)': 1, '"It\'s not X. It\'s Y." (split sentence)': 1, "Negation chains (\"no X, no Y\")": 1, "Superlative totalizers": 1, "Didactic hedging": 1, "Vague attribution to unnamed authorities": 1, "Stranded auxiliary contrast": 1 } },
  { file: path.join(root, "tests", "scan-fixtures", "utf8.txt"), expectExit: 0 },
  { file: path.join(root, "tests", "superset", "inputs", "tc07-split-its-not.txt"), expectExit: 1, degradedExit: 4, // its only hit (three-sentence variant) is exactly the pattern degraded mode skips
    // The tc07 input uses the apostrophe form ("It's not. It's about…"), which
    // the split-sentence regex is deliberately blind to (it matches the "is
    // not" spelling); the three-sentence variant and judgment pass own it.
    counts: { "Three-sentence variant (\"It's about X. It's not. It's about Y.\")": ">=1" } },
  { file: path.join(root, "tests", "superset", "inputs", "tc01-happy-path.txt"), expectExit: 1,
    counts: { "Em dash / double hyphen": ">=1" } },
];

const ENGINES = [
  { key: "node", cmd: "node", file: path.join(toolsDir, "engines", "scan.mjs") },
  { key: "python3", cmd: "python3", file: path.join(toolsDir, "engines", "scan.py") },
  { key: "perl", cmd: "perl", file: path.join(toolsDir, "engines", "scan.pl") },
];

function run(cmd, args, opts = {}) {
  const r = spawnSync(cmd, args, {
    encoding: "utf8",
    input: opts.stdin !== undefined ? opts.stdin : "",
    env: opts.env,
  });
  return { status: r.status, stdout: r.stdout || "", stderr: r.stderr || "", error: r.error };
}

// Reference vector comes from the node engine (always present in dev).
function engineVector(mode) {
  return (fixture) => {
    const j = run(mode.cmd, [mode.file, fixture.file, "--json"]);
    if (j.status === null) return null; // runtime absent
    let parsed;
    try { parsed = JSON.parse(j.stdout); } catch { return { broken: true }; }
    return parsed;
  };
}

const available = ENGINES.filter((e) => {
  const probe = spawnSync(e.cmd, [e.file, "--json"], { encoding: "utf8", input: "" });
  return probe.status !== null && !probe.error && probe.status !== 2 && probe.status !== 127 && !/ENOENT/.test(String(probe.error));
});

console.log(`\n--- engine parity: ${available.map((e) => e.cmd).join(", ")} ---`);

const refEngine = available[0];
{
  // Byte-identical text reports across engines, per fixture.
  for (const fx of FIXTURES) {
    const outs = available.map((e) => run(e.cmd, [e.file, fx.file]));
    const base = outs[0];
    let same = true;
    for (let i = 1; i < outs.length; i++) {
      if (outs[i].stdout !== base.stdout || outs[i].status !== base.status) same = false;
    }
    const exitOk = base.status === fx.expectExit;
    console.log(`${same && exitOk ? "PASS" : "FAIL"} parity ${path.basename(fx.file)}: exit=${base.status} (want ${fx.expectExit}) ${same ? "identical across engines" : "ENGINES DIVERGE"}`);
    if (!(same && exitOk)) fails++;
    if (!exitOk) fails++;

    // Count assertions for the reference engine.
    if (fx.counts && !Number.isNaN(base.status)) {
      let parsed;
      try { parsed = JSON.parse(run(refEngine.cmd, [refEngine.file, fx.file, "--json"]).stdout); } catch { parsed = []; }
      const byName = Object.fromEntries(parsed.map((r) => [r.name, r.count]));
      for (const [nm, want] of Object.entries(fx.counts)) {
        const got = byName[nm] ?? 0;
        const ok = typeof want === "number" ? got === want : want === ">=1" ? got >= 1 : false;
        console.log(`${ok ? "PASS" : "FAIL"} count [${nm}] got=${got} want=${want}`);
        if (!ok) fails++;
      }
    }
  }

  // Corrupt catalog -> exit 2 (SCAN_CATALOG override).
  {
    const tmp = path.join(os.tmpdir(), `scan-corrupt-${process.pid}.md`);
    const corrupt = md.replace(/### "The punchline is"\n```\n[^\n]*\n```/, '### "The punchline is"');
    writeFileSync(tmp, corrupt);
    const r = run(refEngine.cmd, [refEngine.file, "-"], { stdin: "plain text\n", env: { ...process.env, SCAN_CATALOG: tmp } });
    const ok = r.status === 2 && /parse error/.test(r.stderr);
    console.log(`${ok ? "PASS" : "FAIL"} corrupt catalog -> exit 2 (got ${r.status})`);
    if (!ok) fails++;
    unlinkSync(tmp);
  }

  // Degraded subset: counts equal engine counts for scanned names; SKIPPED set == triage set.
  console.log("\n--- degraded subset (scan.sh --degraded) ---");
  {
    const triageSkipped = sections
      .filter((s) => {
        const src = s.source || "";
        return src.includes("(?=") || src.includes("(?!") || /\\[0-9]/.test(src) || /\\u[0-9A-Fa-f]{4}/.test(src);
      })
      .map((s) => s.name.split(" — ")[0])
      .sort();

    for (const fx of FIXTURES) {
      const d = run("sh", [path.join(toolsDir, "scan.sh"), "--degraded", fx.file]);
      // Parse blocks: "SEV  name  N hit(s)" / "SKIPPED" / "JUDGMENT REQUIRED".
      const scanned = new Map(), skipped = [];
      const normName = (n) => n.split(" — ")[0];
      for (const m of d.stdout.matchAll(/^(HARD|LIMIT|SOFT)  (.+?)  (\d+) hits?$/gm)) scanned.set(normName(m[2]), Number(m[3]));
      for (const m of d.stdout.matchAll(/^(?:HARD|LIMIT|SOFT)  (.+?)  SKIPPED/gm)) skipped.push(normName(m[1].trim()));
      const refVec = engineVector(refEngine)(fx);
      const refByName = new Map((refVec || []).map((r) => [r.name, r.count]));
      // Degraded exit: 4 when the scanned subset is within gate (even if
      // skipped patterns would have flagged), 1 when a scanned pattern
      // violates, 2 on parse error.
      const wantDegraded = fx.degradedExit !== undefined ? fx.degradedExit : (fx.expectExit === 0 ? 4 : fx.expectExit);
      let ok = d.status === wantDegraded;
      let detail = `exit=${d.status}`;
      for (const [nm, count] of scanned) {
        if (refByName.get(nm) !== count) { ok = false; detail += ` mismatch[${nm}]: degraded=${count} engine=${refByName.get(nm)}`; }
      }
      const skipSorted = skipped.slice().sort();
      const sameSkips = JSON.stringify(skipSorted) === JSON.stringify(triageSkipped);
      console.log(`${ok && sameSkips ? "PASS" : "FAIL"} degraded ${path.basename(fx.file)}: ${detail} skipped=${skipped.length} ${sameSkips ? "triage==expected" : "TRIAGE MISMATCH: " + JSON.stringify({ skipSorted, triageSkipped })}`);
      if (!(ok && sameSkips)) fails++;
    }
  }

  // Dispatcher: exit-3 ask-user path under an empty PATH; --engine passthrough.
  console.log("\n--- dispatcher behavior ---");
  {
    const envEmpty = { ...process.env, PATH: "" };
    const r3 = run("/bin/sh", [path.join(toolsDir, "scan.sh"), FIXTURES[0].file], { env: envEmpty });
    if (r3.status === null) {
      console.log("SKIP exit-3 ask-user (no /bin/sh on this host)");
    } else {
      const ok = r3.status === 3 && r3.stdout === "" && /no supported runtime/.test(r3.stderr) && /ask the user/.test(r3.stderr);
      console.log(`${ok ? "PASS" : "FAIL"} exit-3 ask-user (got ${r3.status})`);
      if (!ok) fails++;
    }

    for (const e of available) {
      const rr = run("sh", [path.join(toolsDir, "scan.sh"), "--engine", e.key, FIXTURES[2].file]);
      const direct = run(e.cmd, [e.file, FIXTURES[2].file]);
      const ok = rr.status === direct.status && rr.stdout === direct.stdout;
      console.log(`${ok ? "PASS" : "FAIL"} dispatch --engine ${e.key} == direct`);
      if (!ok) fails++;
    }
  }
}

console.log(`\nPARITY+DISPATCH LAYER: ${available.length} engines on this host, total failures=${fails}`);
process.exitCode = fails ? 1 : 0;