# AI Output Humanizer

An opencode skill that audits and rewrites content to remove AI writing patterns. Three modes (rewrite, detect, edit), voice calibration from sample or named profiles, iterate-to-convergence with self-audit, and explicit ethics framing.

Synthesizes detection patterns from conorbronsdon/avoid-ai-writing, blader/humanizer, brandonwise/humanizer, stephenturner/skill-deslop, and lguz/humanize-writing-skill.

## Quick start

1. Install the skill by adding its path to your opencode config's `skills.paths`
2. Invoke with: "humanize this: [text]" or "detect AI patterns in: [text]"
3. For file editing: "edit this file: [path]"

See `skills/ai-output-humanizer/SKILL.md` for full usage.
