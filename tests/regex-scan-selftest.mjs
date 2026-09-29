#!/usr/bin/env node
// Deterministic self-test for the regex scan patterns.
// Parses every fenced regex out of skills/ai-output-humanizer/references/regex-scan.md,
// compiles it (gi flags) plus a few literal-search patterns, and asserts expected
// hit / no-hit samples. No LLM involved; runs in milliseconds.
// Run: node tests/regex-scan-selftest.mjs
import { readFileSync } from "node:fs";

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
  if (fence) sections.push({ name: m[1].trim(), re: new RegExp(fence[1], "gi") });
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
process.exitCode = fails ? 1 : 0;