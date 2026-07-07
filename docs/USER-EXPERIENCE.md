# User Experience

## Installation

1. Clone this repository
2. Add the `skills/` directory to your opencode config's `skills.paths`
3. Restart opencode

## Invocation

- `humanize this: [text]` — rewrite mode (default)
- `detect AI patterns in: [text]` — detect mode
- `edit this file: [path]` — edit mode
- `make this sound [voice]: [text]` — voice-calibrated rewrite

## UX principles

- **Zero config** — the skill works without any setup beyond path registration
- **Transparent** — every rewrite includes a diff summary and self-audit
- **Ethical by default** — every output includes a signals-not-proof disclaimer
- **Conservative** — the skill flags patterns but does not over-edit strong writing

See `docs/user-experience/` for detail.
