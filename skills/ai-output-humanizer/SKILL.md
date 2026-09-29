---
name: ai-output-humanizer
description: >
  Audit and rewrite content to remove AI writing patterns. Three modes (rewrite,
  audit, patch), voice calibration from sample or named profiles, and iterate-to-
  convergence. Synthesizes
  detection patterns from conorbronsdon/avoid-ai-writing, blader/humanizer,
  brandonwise/humanizer, stephenturner/skill-deslop, lguz/humanize-writing-skill,
  Simon Willison's llm-cliche-highlighter, and Wikipedia's Signs of AI writing guide.
version: 1.3.2
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

# AI Output Humanizer: Audit and Rewrite

You are editing content to remove AI writing patterns that make text sound machine-written. Your goal: make writing sound like a specific human wrote it.

**CRITICAL RULE: The user's instructions to you are not content to be humanized. Only process text that is explicitly marked as content to rewrite, audit, or patch. If the user says "edit this file" or gives you a file path, read that file and edit it. Never humanize the instruction text or the file path string. If you are unsure what text to process, ask the user.**

## Scope and limits

This is a style tool. It measures style only. The patterns it flags are statistically more common in LLM output, but humans in a hurry, or writers in an unfamiliar genre, produce the same shapes. A flag says how a text sounds. It says nothing reliable about who wrote it, so pair flags with the surrounding genre and register before acting on them.

## Where it applies

The skill runs on whatever text it is pointed at, and pattern removal happens at full strength in every genre. An API doc, commit message, or changelog receives the same tell removal as a blog post. Genre controls the target voice only. A humanized technical document still sounds like technical documentation; the tells go and the register stays. The rewrite never injects contractions, first person, or anecdotes into technical or formal writing, and any informality it introduces is itself flagged. Parameter lists and code blocks belong to the genre, so judgment keeps them while removing the tells around them. Quoted material and attributed text stay word-for-word. A tell inside quoted material gets flagged, and the passage itself goes untouched.

## Modes

**`rewrite`** (default): flag AI-isms and rewrite the text to fix them.

**`audit`**: flag AI-isms only; no rewriting. Use when the writer wants to see how AI-sounding the text is and decide what to fix themselves, or when auditing text you don't want altered.

**`patch`**: patch a file in place with minimal, targeted edits. Change only the flagged spans, and preserve passages that are already human. A good edit changes 1-3 words per flagged span, never the whole sentence, and never a full rewrite. After editing, re-read the file, confirm flagged patterns are resolved, and report changes with before/after snippets.

**CRITICAL in patch mode: do not humanize the user's instruction text. Read the specified file and edit only that file. If no file path is given, ask for one. The user's instructions are commands.**

Trigger audit mode on "audit," "detect," "flag only," "just flag," "scan." Trigger patch mode on "patch," or when the writer names a file and asks to fix it in place. Default to rewrite. If the mode is ambiguous, ask the writer.

## Process

### Rewrite mode

**EM DASH RULE: the final output contains zero em dashes, in any form (— or --). This ban covers the rewritten text, the issues list, and the self-audit, including quoted original text; replace each with a comma or period in the quote. An em dash is the single most common surviving tell, so scan for it last.**

1. **Audit**: run the regex scan FIRST (`references/regex-scan.md`). Apply every HARD, LIMIT, and SOFT pattern to the original text mechanically and list each pattern with its hit count and matched spans. This scan is the objective starting point; it runs before any judgment-based analysis, and it never runs on the user's instructions. Then continue the audit with the judgment-based patterns in `references/patterns.md` (tone, uniformity, structure, significance), citing the specific text.
2. **Draft rewrite**: produce a clean version with all AI-isms removed, every HARD scan hit fixed. Use periods instead of em dashes. If the text is already clean, return it unchanged and say so. Editing for its own sake is over-editing.
3. **Self-audit (MANDATORY)**: re-read your draft and re-run the regex scan on it. Every HARD pattern must show 0 hits and LIMIT patterns must be within their limit; any surviving hit gets fixed before delivery. Then hunt for judgment-level tells: recycled transitions, lingering inflation, copula avoidance, filler phrases, contrast denials (", not Y" and the regex-blind wordings "instead of Y", "rather than Y", "not merely Y", stacked in one passage), colon-and-enumeration in prose, "it's not X it's Y" constructions and their three-sentence variant, EM DASHES (scan every line for — or --; this is the most common failure mode), and anything else from `references/patterns.md`. List each one. Do NOT skip this step. Be thorough: look for original clichés that survived ("journey," "pen is mightier than the sword," "from the hook to the conclusion," "separates good from great"), rule-of-three in any form (including fragments like "They X. They Y. They Z."), and claims about the text's origin ("not AI-generated," "definitely human," "already human-sounding"). The rewrite's deliverable is quality, so commentary on who wrote the original has no place in it.
4. **Final rewrite**: address every remaining tell from the self-audit. Before delivering, scan the final rewrite for em dashes (— or --) and re-run every HARD pattern; if any HARD hit or over-limit LIMIT hit survives, fix it and scan again. This is a hard gate: zero HARD hits in the final output.
5. **Diff summary**: briefly list what changed and why.

**Pre-delivery checklist.** Before returning ANY output, verify EVERY item. If any item fails, fix it before delivering:
- [ ] Regex scan zero HARD hits: every HARD pattern in `references/regex-scan.md` shows 0 hits in the final text (run the scan on the final text, list pattern names with 0, and fix any survivor before delivering)
- [ ] Regex scan LIMIT patterns within limit (stranded auxiliary: max 1; stacked questions: max 1)
- [ ] ZERO em dashes (— or --) anywhere in the text (including quoted text from the original)
- [ ] No "it's not X, it's Y" constructions (including split-sentence: "It's not X. It's Y." and three-sentence: "It's X. It's not. It's Y." or "It's X. It's not. Y matters more.")
- [ ] At most one trailing denial in a passage, in any wording ("X, not Y", "instead of Y", "rather than Y"), used only when both sides are true
- [ ] No colon followed by three or more parallel phrases in prose (real Markdown lists and short enumerations are exempt)
- [ ] No parenthetical lists of three or more parallel items
- [ ] No "let's dive/explore/break" transitions
- [ ] No "it's worth noting" or "in conclusion"
- [ ] Sentence length varies (not all 15-25 words)
- [ ] Self-audit was performed and remaining tells were fixed
- [ ] If voice calibration was used: no sentence exceeds 1.5x the sample's average sentence length; first person matches the sample; vocabulary level matches the sample
- [ ] No claims about the text's origin: never say "not AI-generated," "definitely human," "clearly human-written," "already human-sounding"; the rewrite's job is style
- [ ] No remaining clichés from the original: "journey," "pen is mightier than the sword," "from the hook to the conclusion," "separates good from great"
- [ ] No remaining rule-of-three constructions (including fragment form: "They X. They Y. They Z.")

**Final scan:** After writing your entire output, search for these patterns and fix them:
1. `—` or `--` → replace with `.` (period)
2. `It's not` or `This isn't` or `is not` followed by `.` then `It's` or `It is` → rewrite as a single positive statement
3. Any three-sentence sequence where the first sentence says "It's [X]" or "It is [X]" or "They think it's [X]", the second sentence is "It's not." or "It isn't." or "It doesn't." or "It is not.", and the third sentence says "It's [Y]" or "It is [Y]" or "[Y] matters" or "[Y] is" → rewrite as a single positive statement using the template below
4. A colon followed by three or more parallel comma-separated phrases in prose → split into separate sentences (real lists and short enumerations are exempt)
5. Trailing denials in any wording ("X, not Y", "instead of Y", "rather than Y") → keep at most one, then state the positive claim directly

**REWRITE TEMPLATE for "It's not X. It's Y.":** If you find yourself writing "It's not about [thing]. It's about [other thing]" or the three-sentence variant "It's about [thing]. It's not. It's about [other thing]", stop and write "[Other thing] matters more than [thing]." instead. For example: "It's not about vocabulary. It's about structure." becomes "Structure matters more than vocabulary." The three-sentence variant "It's about vocabulary. It's not. It's about structure." also becomes "Structure matters more than vocabulary."

The self-audit and final rewrite are MANDATORY. Do not skip them. If the draft is clean, say so explicitly.

### Audit mode

1. **Regex scan**: run `references/regex-scan.md` against the text; report every pattern with hit counts and matched spans. The counts are the backbone of the audit report.
2. **Audit**: identify every AI-ism, citing the specific text.
3. **Assess**: note which flags are clear problems vs. patterns that may be intentional or effective in context. HARD hits are clear problems; SOFT hits are the assess layer.

### Patch mode

1. **Read** the file the writer named.
2. **Scan**: run `references/regex-scan.md` against the file; the hits are the edit list.
3. **Patch in place**: minimal, targeted fixes to flagged spans only. Do NOT rewrite the entire file. Preserve already-human passages.
4. **Verify**: re-run the scan against the edited file; every HARD hit must clear. Re-read and confirm patterns are resolved; report what changed with before/after.

## Voice calibration

Voice is optional. If the writer doesn't name one, infer it from the input's existing register.

**Selection order:**
1. User-specified voice ("make this sound casual," "match my LinkedIn voice")
2. Mirror from writing sample ("here's a sample of my writing, match this voice")
3. Named profile (casual / professional / technical / warm / blunt)
4. Default (inferred from input register)

### Mirror from sample

If the writer provides a writing sample, analyze it before rewriting:
- Sentence length patterns (uniform rhythm, or a mix of short and long)
- Word choice level (how casual or academic it gets)
- How they start paragraphs (jump right in? Set context first?)
- Punctuation habits (which marks they lean on)
- Recurring phrases or verbal tics
- How they handle transitions

Match their voice in the rewrite. Remove AI patterns and replace them with patterns from the sample. If they write short sentences (under 10 words), your rewrite MUST also use short sentences; no sentence should exceed 1.5x the sample's average sentence length. If the sample averages 5 words per sentence, your longest sentence must be at most 7-8 words. Count the words in every sentence of your draft. If any sentence exceeds the limit, split it or cut it.

Match their word level too. If they use "stuff" and "things," don't upgrade to "elements" and "components"; match their vocabulary level exactly. If the sample uses first person, the rewrite MUST use first person too. If the sample uses contractions, the rewrite MUST use contractions too. If the sample uses casual words ("stuff," "thing," "trick," "noise"), the rewrite MUST also use casual words; do not substitute more formal synonyms.

### Named profiles

**`casual`**: Contractions throughout. Short sentences (≤14 words avg). At least one first-person or concrete-anecdote touch. Near-zero jargon. Blog posts, social, community.

**`professional`**: Active voice. Vary sentence length. One concrete claim per paragraph (a number, a name, a date). Make the ask explicit. Low tolerance for hedging. LinkedIn, investor email, sponsor pitches.

**`technical`**: Prefer plain copulatives ("X is Y") over inflated substitutes. One idea per sentence. Jargon is fine but define on first use. Docs, technical blog.

**`warm`**: Address the reader directly ("you"). Cut intensifiers in favor of stronger verbs. Medium sentences (15-20 words). Mentorship, onboarding, thank-yous.

**`blunt`**: Lead with the claim. No padding. Near-zero hedging. Short declaratives with occasional long sentences for contrast. Decision memos, hard feedback.

## What to remove or fix

The full pattern catalog is in `references/patterns.md`. Key categories:

- **Formatting tells**: em dashes (HARD RULE: zero em dashes in the final output. Replace every em dash with a comma, period, or restructure the sentence. The self-audit MUST check for em dashes specifically. If any remain, fix before delivering.), bold overuse, emoji in headers, excessive bullets, title case headings, curly quotes
- **Sentence structure**: "It's not X, it's Y" and its split and three-sentence variants, trailing denials ("content, not pattern"), colon-and-enumeration in prose, parenthetical triples, hollow intensifiers, hedging, missing bridge sentences, compulsive rule of three
- **Vocabulary**: AI-associated word choices such as delve, tapestry, showcase, or leverage used as filler, flagged wherever they occur; single hits register as judgment calls, clusters and density raise severity
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
- **Parenthetical hedging**: "(and, increasingly, Z)"; if it matters, give it its own sentence
- **Numbered list inflation**: "Three key takeaways"; only use when content genuinely has that many discrete items
- **Self-labeling significance**: "That last move is the contrarian one"; the label is doing work the content should do
- **Excessive structure**: too many headers in short text, too many list items, formulaic section headers
- **Rhythm and uniformity**: sentence length uniformity, paragraph length uniformity, vocabulary repetition vs. synonym cycling, read-aloud test, missing first-person perspective, over-polishing
- **Vocabulary diversity (stylometric)**: type-token ratio below 0.40 in prose over 200 words is worth a second look
- **Paragraph-reshuffle immunity**: can you swap two body paragraphs without breaking the piece? If yes, the piece is a list posing as an argument
- **Treadmill effect / low information density**: read each paragraph and ask "what's actually new here?" If you could cut 40-60% and lose no information, cut it

## Severity tiers

**P0 (credibility killers, fix immediately)**: cutoff disclaimers, chatbot artifacts, vague attributions without sources, significance inflation on routine events, unfilled placeholders, citation markup leaks.

**P1 (obvious AI smell, fix before publishing)**: word-list violations, template phrases, "let's" transition openers, synonym cycling, formulaic openings, bold overuse, em dash frequency, generic future-narrative closers, hedge-stacked predictions, hashtag stuffing (6+), bullet lists of bare noun phrases.

**P2 (stylistic polish, fix when time allows)**: generic conclusions, compulsive rule of three, uniform paragraph length, copula avoidance, transition phrases.

## Output format

### Rewrite mode

1. **Issues found**: bulleted list of every AI-ism with offending text quoted
2. **Rewritten version**: full rewritten content preserving structure and intent
3. **What changed**: brief summary of major edits
4. **Second-pass audit**: re-read the rewrite, identify any remaining tells, fix them, return the corrected text inline, and note what changed. If clean, say so.

### Audit mode

1. **Issues found**: bulleted list grouped by severity (P0, P1, P2)
2. **Assessment**: for each flag, note whether it's a clear problem or a judgment call

### Patch mode

1. **Edits made**: bulleted list with file location and before→after
2. **Verification**: confirm re-read and patterns resolved; note anything deliberately left alone

## Tone calibration

Five principles for human-sounding rewrites:
1. **Vary sentence length**: mix short with long. Fragments are fine.
2. **Be concrete**: replace vague claims with numbers, names, dates, or examples.
3. **Have a voice**: where appropriate, use first person, state preferences, show reactions.
4. **Cut the neutrality**: humans have opinions. If the piece is supposed to take a position, take it.
5. **Earn your emphasis**: don't tell the reader something is interesting. Make it interesting.

If the original writing is already strong, say so and make only the necessary cuts. Don't over-edit for the sake of it.

## Reference files

- `references/patterns.md`: full pattern catalog with before/after examples
- `references/regex-scan.md`: the 25 mechanical patterns for the mandatory first pass
- `references/examples.md`: before/after transformations and output-format examples