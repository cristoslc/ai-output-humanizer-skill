# Superset Skill Test Cases

Eight test cases for non-deterministic evaluation of the ai-output-humanizer skill.

## Test cases

### TC-01: Happy path (standard rewrite)

**Input:** AI-slop blog post saturated with patterns (em dashes, "it's not X it's Y", "let's dive in", "it's worth noting", "in conclusion", rule of three, filler phrases).

**Expected behavior:** Output reads as human-written. No em dashes. No "it's not X it's Y" constructions. No "let's" transitions. No "it's worth noting." No "in conclusion." Varied sentence length. Concrete details replace vague claims.

**Judge criteria:**
- No em dashes present
- No "it's not X it's Y" constructions
- No "let's dive/explore/break" transitions
- No "it's worth noting" or "in conclusion"
- Sentence length varies (not all 15-25 words)
- Reads as a person wrote it (subjective, 1-5 scale, pass >= 3)

### TC-02: Detect mode (flag only)

**Input:** Same AI-slop blog post as TC-01.

**Expected behavior:** Output identifies and lists AI patterns without rewriting the text. The original text is preserved. Patterns are grouped by severity.

**Judge criteria:**
- Original text is preserved (not rewritten)
- At least 3 AI patterns are identified
- Patterns are grouped or categorized
- No rewritten version is produced

### TC-03: Edit mode (in-place)

**Input:** A short file path (simulated) with AI-slop text. The skill should make minimal, targeted edits.

**Expected behavior:** Only flagged spans are changed. Already-human passages are left untouched. Changes are reported.

**Judge criteria:**
- Changes are minimal (not a full rewrite)
- Already-human passages are preserved
- Changes are reported with before/after
- Flagged patterns are resolved

### TC-04: Voice calibration

**Input:** AI-slop text + a writing sample with a distinctive voice (short sentences, casual register, first-person opinions).

**Expected behavior:** Output matches the sample's voice — short sentences, casual register, first-person perspective. Does not "upgrade" the sample's vocabulary.

**Judge criteria:**
- Output matches the sample's sentence length pattern
- Output matches the sample's register (casual)
- First-person perspective is present where appropriate
- Vocabulary is not upgraded beyond the sample's level

### TC-05: Opt-out (when NOT to use)

**Input:** Technical documentation text (API reference, parameter docs, README-style content) that contains some AI patterns but is primarily technical reference.

**Expected behavior:** The skill recognizes this as technical writing and does NOT apply humanization. Or if it does, changes are minimal and preserve the technical register.

**Judge criteria:**
- Technical terms are preserved
- The output is not made informal/casual
- Changes (if any) are minimal
- The skill acknowledges the opt-out context

### TC-06: Convergence (iterate)

**Input:** AI-slop text with heavy pattern density (5+ vocabulary hits, 3+ pattern categories, uniform structure).

**Expected behavior:** The skill produces a rewrite, then self-audits and fixes remaining tells. The final output has fewer patterns than the first pass.

**Judge criteria:**
- A second-pass audit is performed
- Remaining tells from the first pass are fixed
- The final output has fewer patterns than the first pass
- The process is reported (what changed in the second pass)

### TC-07: Ethics framing

**Input:** Text that could be non-native English writing (grammatical quirks, unusual word choices, but no obvious AI patterns).

**Expected behavior:** The skill acknowledges the probabilistic nature of detection. It does not over-flag. It frames output as "signals, not proof."

**Judge criteria:**
- The output includes or references the ethics framing
- False positives are acknowledged as possible
- The skill does not make definitive claims about AI authorship
- Non-native English patterns are handled with care

### TC-08: Adversarial (non-native English)

**Input:** Text written by a non-native English speaker (grammatical errors, unusual constructions, but human-written).

**Expected behavior:** The skill is conservative — it flags fewer patterns and acknowledges that the patterns may be second-language constructions rather than AI tells.

**Judge criteria:**
- Fewer than 3 patterns are flagged (conservative)
- The output acknowledges possible second-language origin
- The original meaning is preserved
- The skill does not "correct" non-native grammar aggressively
