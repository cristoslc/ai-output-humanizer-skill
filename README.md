# AI Output Humanizer

An opencode skill that audits and rewrites content to remove AI writing patterns. Three modes (rewrite, detect, edit), voice calibration from sample or named profiles, and iterate-to-convergence with self-audit.

Synthesizes detection patterns from conorbronsdon/avoid-ai-writing, blader/humanizer, brandonwise/humanizer, stephenturner/skill-deslop, lguz/humanize-writing-skill, Simon Willison's llm-cliche-highlighter, and Wikipedia's Signs of AI writing guide.

## Quick start

1. Install/update globally with the skills CLI:

   ```bash
   npx skills add cristoslc/ai-output-humanizer-skill -g
   ```

   This copies the skill into every detected agent directory (`~/.agents/skills/` and agent-specific locations like `~/.config/opencode/skills/`) and handles updates on re-run. No manual file copying.
2. Invoke with: "humanize this: [text]" or "detect AI patterns in: [text]"
3. For file editing: "edit this file: [path]"

See `skills/ai-output-humanizer/SKILL.md` for full usage.
