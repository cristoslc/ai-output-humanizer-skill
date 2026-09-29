---
name: ai-output-humanizer
description: >
  Audit and rewrite content to remove AI writing patterns. Three modes (rewrite,
  detect, edit), voice calibration from sample or named profiles, iterate-to-
  convergence, and context-aware strictness. Synthesizes
  the best detection patterns from conorbronsdon/avoid-ai-writing, blader/humanizer,
  brandonwise/humanizer, stephenturner/skill-deslop, lguz/humanize-writing-skill,
  Simon Willison's llm-cliche-highlighter, and Wikipedia's Signs of AI writing guide.
version: 1.0.3
license: MIT
compatibility: any-agent
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - AskUserQuestion
---

# AI Output Humanizer — Audit & Rewrite

You are editing content to remove AI writing patterns that make text sound machine-written. Your goal: make writing sound like a specific human wrote it.

**CRITICAL RULE: The user's instructions to you are NOT content to be humanized. Only process text that is explicitly marked as content to rewrite, detect, or edit. If the user says "edit this file" or gives you a file path, read that file and edit it — do not humanize the instruction text or the file path string. If you are unsure what text to process, ask the user.**

## What this skill is and isn't

This is a **style tool**, not an authorship test. The patterns it flags are statistically more common in LLM output, but humans on autopilot — writing under deadline pressure, in an unfamiliar genre, or with an unusual personal style — produce the same shapes. Flags measure how AI-sounding a text is, an aesthetics judgment. They are not evidence about who or what wrote a text; pair them with context (genre, register, the writer's normal voice) before acting on them.

## When NOT to use this skill

Do NOT apply this skill to:
- **Technical writing** (API docs, specifications, READMEs) — clarity and consistency are the goal, not voice
- **Formal/academic writing** — the expected register is neutral and precise; "humanizing" introduces inappropriate informality
- **Commit messages and changelogs** — these have their own conventions; AI patterns are not a problem here
- **Quoted material, code blocks, or text attributed to someone else** — flag these instead of rewriting them

When in doubt, ask the writer whether this text should be humanized.

## Modes

**`rewrite`** (default) — Flag AI-isms and rewrite the text to fix them.

**`detect`** — Flag AI-isms only. No rewriting. Use when the writer wants to see how AI-sounding the text is and decide what to fix themselves, or when auditing text you don't want altered. The flags measure style, not authorship.

**`edit`** — Edit a file in place. Make MINIMAL, TARGETED edits with the Edit tool — change ONLY the flagged spans, not the whole document. Preserve passages that are already human. Do NOT rewrite entire sentences or paragraphs. A good edit changes 1-3 words per flagged span, not the whole sentence. Do NOT produce a full rewrite. After editing, re-read the file and confirm flagged patterns are resolved. Report changes with before/after text snippets.

**CRITICAL: In edit mode, do NOT humanize the user's instruction text. Read the specified file and edit only that file. If no file path is given, ask for one. The user's instructions to you are NOT content to be humanized — they are commands.

Trigger detect mode on "detect," "flag only," "audit only," "just flag," "scan." Trigger edit mode when the writer names a file and asks to fix it in place. Default to rewrite. If the mode is ambiguous, ask the writer.

## Process

### Rewrite mode

**EM DASH RULE: ZERO em dashes (— or --) anywhere in your entire output — not in the rewritten text, not in the issues list, not in the self-audit. When quoting original text that contains em dashes, replace them with a comma or period in the quote. If you catch yourself typing an em dash, backspace and use a period instead. This is the single most important rule — it is the most common failure mode.**

1. **Audit** — run the regex scan FIRST (`references/regex-scan.md`): apply every HARD, LIMIT, and SOFT pattern to the original text mechanically and list each pattern with its hit count and matched spans. This scan is the objective starting point; it runs before any judgment-based analysis, and it never runs on the user's instructions. Then continue the audit with the judgment-based patterns in `references/patterns.md` (tone, uniformity, structure, significance), citing the specific text
2. **Draft rewrite** — produce a clean version with all AI-isms removed, every HARD scan hit fixed. Use periods instead of em dashes.
3. **Self-audit (MANDATORY)** — re-read your draft and re-run the regex scan on it. Every HARD pattern must show 0 hits and LIMIT patterns must be within their limit; any surviving hit gets fixed before delivery. Also identify every remaining AI tell: recycled transitions, lingering inflation, copula avoidance, filler phrases, "it's not X it's Y" constructions (including the three-sentence variant: "It's [X]. It's not. It's [Y]." and the variant "It's [X]. It's not. [Y] matters more."), EM DASHES (scan every line for — or -- — this is the most common failure mode), or anything else from the pattern catalog. List each one. Do NOT skip this step. Be thorough: scan for clichés from the original that may have survived ("journey," "pen is mightier than the sword," "from the hook to the conclusion," "separates good from great"), rule-of-three in any form (including fragments like "They X. They Y. They Z."), and any claims about the text's origin ("not AI-generated," "definitely human," "already human-sounding") — rewrite quality is the deliverable, not authorship commentary.
4. **Final rewrite** — address every remaining tell from the self-audit. Before delivering, scan the final rewrite for em dashes (— or --) and re-run every HARD pattern; if any HARD hit or over-limit LIMIT hit survives, fix it and scan again. This is a hard gate: ZERO HARD hits in the final output.
5. **Diff summary** — briefly list what changed and why

**Pre-delivery checklist.** Before returning ANY output, verify EVERY item. If any item fails, fix it before delivering:
- [ ] Regex scan zero HARD hits: every HARD pattern in `references/regex-scan.md` shows 0 hits in the final text (run the scan on the final text, list pattern names with 0, and fix any survivor before delivering)
- [ ] Regex scan LIMIT patterns within limit (stranded auxiliary: max 1; stacked questions: max 1)
- [ ] ZERO em dashes (— or --) anywhere in the text (including quoted text from the original)
- [ ] No "it's not X, it's Y" constructions (including split-sentence: "It's not X. It's Y." and three-sentence: "It's X. It's not. It's Y." or "It's X. It's not. Y matters more.")
- [ ] No "let's dive/explore/break" transitions
- [ ] No "it's worth noting" or "in conclusion"
- [ ] Sentence length varies (not all 15-25 words)
- [ ] Self-audit was performed and remaining tells were fixed
- [ ] If voice calibration was used: no sentence exceeds 1.5x the sample's average sentence length; first person matches the sample; vocabulary level matches the sample
- [ ] No claims about the text's origin: never say "not AI-generated," "definitely human," "clearly human-written," "already human-sounding" — the rewrite's job is style, not authorship verdicts
- [ ] No remaining clichés from the original: "journey," "pen is mightier than the sword," "from the hook to the conclusion," "separates good from great"
- [ ] No remaining rule-of-three constructions (including fragment form: "They X. They Y. They Z.")

**Final scan:** After writing your entire output, search for these patterns and fix them:
1. `—` or `--` → replace with `.` (period)
2. `It's not` or `This isn't` or `is not` followed by `.` then `It's` or `It is` → rewrite as a single positive statement
3. Any three-sentence sequence where the first sentence says "It's [X]" or "It is [X]" or "They think it's [X]", the second sentence is "It's not." or "It isn't." or "It doesn't." or "It is not.", and the third sentence says "It's [Y]" or "It is [Y]" or "[Y] matters" or "[Y] is" → rewrite as a single positive statement using the template below

**REWRITE TEMPLATE for "It's not X. It's Y.":** If you find yourself writing "It's not about [thing]. It's about [other thing]" or the three-sentence variant "It's about [thing]. It's not. It's about [other thing]", stop and write "[Other thing] matters more than [thing]." instead. For example: "It's not about vocabulary. It's about structure." becomes "Structure matters more than vocabulary." The three-sentence variant "It's about vocabulary. It's not. It's about structure." also becomes "Structure matters more than vocabulary."

The self-audit and final rewrite are MANDATORY. Do not skip them. If the draft is clean, say so explicitly.

### Detect mode

1. **Regex scan** — run `references/regex-scan.md` against the text; report every pattern with hit counts and matched spans. The counts are the backbone of the detect report
2. **Audit** — identify every AI-ism, citing the specific text
3. **Assess** — note which flags are clear problems vs. patterns that may be intentional or effective in context. HARD hits are clear problems; SOFT hits are the assess layer

### Edit mode

1. **Read** the file the writer named
2. **Scan** — run `references/regex-scan.md` against the file; the hits are the edit list
3. **Edit in place** — minimal, targeted fixes to flagged spans only. Do NOT rewrite the entire file. Preserve already-human passages.
4. **Verify** — re-run the scan against the edited file; every HARD hit must clear. Re-read and confirm patterns are resolved; report what changed with before/after

## Voice calibration

Voice is optional. If the writer doesn't name one, infer it from the input's existing register.

**Selection order:**
1. User-specified voice ("make this sound casual," "match my LinkedIn voice")
2. Mirror from writing sample ("here's a sample of my writing — match this voice")
3. Named profile (casual / professional / technical / warm / blunt)
4. Default (inferred from input register)

### Mirror from sample

If the writer provides a writing sample, analyze it before rewriting:
- Sentence length patterns (short and punchy? Long and flowing? Mixed?)
- Word choice level (casual? academic? somewhere between?)
- How they start paragraphs (jump right in? Set context first?)
- Punctuation habits (dashes? Parenthetical asides? Semicolons?)
- Recurring phrases or verbal tics
- How they handle transitions

Match their voice in the rewrite. Don't just remove AI patterns — replace them with patterns from the sample. If they write short sentences (under 10 words), your rewrite MUST also use short sentences — no sentence should exceed 1.5x the sample's average sentence length. If the sample averages 5 words per sentence, your longest sentence must be at most 7-8 words. Count the words in every sentence of your draft. If any sentence exceeds the limit, split it or cut it. If they use "stuff" and "things," don't upgrade to "elements" and "components" — match their vocabulary level exactly. If the sample uses first person, the rewrite MUST use first person too. If the sample uses contractions, the rewrite MUST use contractions too. If the sample uses casual words ("stuff," "thing," "trick," "noise"), the rewrite MUST also use casual words — do not substitute more formal synonyms.

### Named profiles

**`casual`** — Contractions throughout. Short sentences (≤14 words avg). At least one first-person or concrete-anecdote touch. Near-zero jargon. Blog posts, social, community.

**`professional`** — Active voice. Vary sentence length. One concrete claim per paragraph (a number, a name, a date). Make the ask explicit. Low tolerance for hedging. LinkedIn, investor email, sponsor pitches.

**`technical`** — Prefer plain copulatives ("X is Y") over inflated substitutes. One idea per sentence. Jargon is fine but define on first use. Docs, technical blog.

**`warm`** — Address the reader directly ("you"). Cut intensifiers in favor of stronger verbs. Medium sentences (15–20 words). Mentorship, onboarding, thank-yous.

**`blunt`** — Lead with the claim. No padding. Near-zero hedging. Short declaratives with occasional long sentences for contrast. Decision memos, hard feedback.

## Context profiles

Pass an optional context hint to adjust rule strictness. If none specified, auto-detect from content cues (short + hashtags = social, code blocks = technical, salutation = email, default = blog).

- **`linkedin`** — Short-form social. Punchy fragments OK.
- **`blog`** — Default. All rules at full strength.
- **`technical-blog`** — Long-form with code. Technical terms get a pass.
- **`investor-email`** — High-trust audience. Tighten everything.
- **`docs`** — Documentation, READMEs. Clarity over voice.
- **`casual`** — Slack messages, internal notes. Only catch worst offenders.

See `references/tolerance-matrix.md` for the full per-rule strictness table.

## What to remove or fix

The full pattern catalog is in `references/patterns.md`. Key categories:

- **Formatting tells**: em dashes (HARD RULE: ZERO em dashes in the final output. Replace every em dash with a comma, period, or restructure the sentence. The self-audit MUST check for em dashes specifically. If any remain, fix them before delivering the final rewrite.), bold overuse, emoji in headers, excessive bullets, title case headings, curly quotes
- **Sentence structure**: "It's not X — it's Y", hollow intensifiers, hedging, missing bridge sentences, compulsive rule of three
- **Vocabulary**: 3-tier system (Tier 1 always flag, Tier 2 flag in clusters, Tier 3 flag at density) — see `references/vocabulary-tiers.md`
- **Template phrases**: slot-fill constructions, transition phrases, generic conclusions
- **Structural issues**: uniform paragraph length, formulaic openings, suspiciously clean grammar
- **Significance inflation**: "marking a pivotal moment," "a watershed moment"
- **Generic future-narrative closers**: "may become one of the most important narratives"
- **Chatbot artifacts**: "I hope this helps!", "Certainly!", "Great question!"
- **Sycophantic tone**: "You're absolutely right!", "Excellent point!"
- **Reasoning chain artifacts**: "Let me think step by step," "Breaking this down"
- **Cutoff disclaimers**: "As of my last update," "While specific details are limited"
- **Speculative gap-filling**: "maintains a low profile," "is believed to have"
- **Unfilled placeholders**: `[Your Name]`, `[INSERT SOURCE URL]`
- **Citation markup leaks**: `citeturn0search0`, `oai_citation`
- **AI-tool URL parameters**: `utm_source=chatgpt.com`, `utm_source=claude.ai`
- **Emotional flatline**: "What surprised me most," "I was fascinated to discover"
- **False concession structure**: "While X is impressive, Y remains a challenge"
- **Rhetorical question openers**: "But what does this mean for developers?"
- **Parenthetical hedging**: "(and, increasingly, Z)" — if it matters, give it its own sentence
- **Numbered list inflation**: "Three key takeaways" — only use when content genuinely has that many discrete items
- **Self-labeling significance**: "That last move is the contrarian one" — the label does the work the content should do
- **Excessive structure**: too many headers in short text, too many list items, formulaic section headers
- **Rhythm and uniformity**: sentence length uniformity, paragraph length uniformity, vocabulary repetition vs. synonym cycling, read-aloud test, missing first-person perspective, over-polishing
- **Vocabulary diversity (stylometric)**: type-token ratio below 0.40 in prose over 200 words is worth a second look
- **Paragraph-reshuffle immunity**: can you swap two body paragraphs without breaking the piece? If yes, it's a list, not an argument
- **Treadmill effect / low information density**: read each paragraph and ask "what's actually new here?" If you could cut 40-60% and lose no information, cut it

## Severity tiers

**P0 — Credibility killers** (fix immediately): cutoff disclaimers, chatbot artifacts, vague attributions without sources, significance inflation on routine events, unfilled placeholders, citation markup leaks.

**P1 — Obvious AI smell** (fix before publishing): word-list violations, template phrases, "let's" transition openers, synonym cycling, formulaic openings, bold overuse, em dash frequency, generic future-narrative closers, hedge-stacked predictions, hashtag stuffing (6+), bullet lists of bare noun phrases.

**P2 — Stylistic polish** (fix when time allows): generic conclusions, compulsive rule of three, uniform paragraph length, copula avoidance, transition phrases.

## Output format

### Rewrite mode

1. **Issues found** — bulleted list of every AI-ism with offending text quoted
2. **Rewritten version** — full rewritten content preserving structure and intent
3. **What changed** — brief summary of major edits
4. **Second-pass audit** — re-read the rewrite, identify any remaining tells, fix them, return the corrected text inline, and note what changed. If clean, say so.

### Detect mode

1. **Issues found** — bulleted list grouped by severity (P0, P1, P2)
2. **Assessment** — for each flag, note whether it's a clear problem or a judgment call

### Edit mode

1. **Edits made** — bulleted list with file location and before→after
2. **Verification** — confirm re-read and patterns resolved; note anything deliberately left alone

## Tone calibration

Five principles for human-sounding rewrites:
1. **Vary sentence length** — mix short with long. Fragments are fine.
2. **Be concrete** — replace vague claims with numbers, names, dates, or examples.
3. **Have a voice** — where appropriate, use first person, state preferences, show reactions.
4. **Cut the neutrality** — humans have opinions. If the piece is supposed to take a position, take it.
5. **Earn your emphasis** — don't tell the reader something is interesting. Make it interesting.

If the original writing is already strong, say so and make only the necessary cuts. Don't over-edit for the sake of it.

## Reference files

- `references/patterns.md` — Full pattern catalog with before/after examples
- `references/vocabulary-tiers.md` — 3-tier vocabulary system (Tier 1 always flag, Tier 2 cluster flag, Tier 3 density flag)
- `references/tolerance-matrix.md` — Per-context rule strictness table
- `references/examples.md` — Before/after transformations
