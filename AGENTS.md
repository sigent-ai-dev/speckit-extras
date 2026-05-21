# AGENTS.md

## About Spec Kit Extras

**Spec Kit Extras** is a Spec Kit extension that adds delivery-quality disciplines on top of Spec Kit's core workflow. It provides four commands for self-review, PR creation, DORA metrics, and design decomposition. Distributed as a Spec Kit extension or standalone commands for 15 AI coding agents.

## Commands

| Command | What it does |
|---------|-------------|
| `/speckit.selfreview` | Structured self-review with C/H/M/L/I severity classification |
| `/speckit.pr` | PR creation with closing-claim accuracy gate + self-review |
| `/speckit.dora` | DORA metrics from `gh` CLI data |
| `/speckit.decompose` | Design docs → right-sized GitHub issues |

## Development Context

This project uses Spec Kit to develop itself. The commands are template-driven (AI agent instructions in Markdown), not code-heavy. The value lives in the command templates — keep them precise, actionable, and portable.

## Architecture

### Spec Kit Extension + Standalone Fallback

Primary distribution is as a Spec Kit extension (`.specify/extensions/extras/`). Standalone install for projects not using the full Spec Kit framework.

```
speckit-extras/
├── extension/
│   ├── extension.yml           # Spec Kit extension manifest
│   └── commands/
│       ├── speckit.selfreview.md
│       ├── speckit.pr.md
│       ├── speckit.dora.md
│       └── speckit.decompose.md
├── templates/commands/         # Source templates (Claude Code format)
│   ├── selfreview.md
│   ├── pr.md
│   ├── dora.md
│   └── decompose.md
├── scripts/
│   └── install.sh              # Extension or standalone install
└── memory/
    └── constitution.md         # Quality principles
```

### Supported Agents (15)

| Agent | Directory | Format |
|-------|-----------|--------|
| Claude Code | `.claude/commands/` | Markdown |
| Gemini CLI | `.gemini/commands/` | TOML |
| GitHub Copilot | `.github/agents/` | Markdown |
| Cursor | `.cursor/commands/` | Markdown |
| Qwen Code | `.qwen/commands/` | TOML |
| opencode | `.opencode/command/` | Markdown |
| Codex CLI | `.codex/commands/` | Markdown |
| Windsurf | `.windsurf/workflows/` | Markdown |
| Kilo Code | `.kilocode/rules/` | Markdown |
| Auggie CLI | `.augment/rules/` | Markdown |
| Roo Code | `.roo/rules/` | Markdown |
| CodeBuddy CLI | `.codebuddy/commands/` | Markdown |
| Amazon Q Developer | `.amazonq/prompts/` | Markdown |
| Amp | `.agents/commands/` | Markdown |
| SHAI | `.shai/commands/` | Markdown |

### Extension Hooks

Declared in `extension.yml`:

| Hook | Triggers |
|------|----------|
| `after_implement` | Runs `/speckit.selfreview` automatically |
| `after_checklist` | Runs `/speckit.selfreview` automatically |

## Key Design Decisions

1. **Extension-first distribution** — primary install path is via Spec Kit's extension system, giving hook integration and per-agent command registration for free.
2. **Standalone fallback** — `install.sh --standalone` for projects that don't use Spec Kit.
3. **Format conversion** — TOML agents (Gemini, Qwen) get automatic format conversion at install time.
4. **Self-review is standalone AND embedded in PR** — `/speckit.selfreview` works on its own; `/speckit.pr` calls it as a mandatory pre-flight.
5. **Closing-claim accuracy is the load-bearing gate** — prevents the "Closes #N" lie.
6. **DORA uses `gh` CLI only** — no API tokens, no external services.
7. **Decompose is propose-then-confirm** — never creates issues without operator approval.

## What's NOT Included (and why)

| Skill | Reason excluded |
|-------|-----------------|
| Red-team gate/run | Imported concept, not originated here |
| Tier classification (Q0-Q3) | Tied to the red-team gate flow |
| speckit-intent | Superseded by Intent Kit's `/intent.capture` |
| speckit-git-* | Upstream Spec Kit handles git workflow inline |
| speckit-bolt-* | Upstream Spec Kit has sprint management |
| forge-* skills | Covered by Intent Kit |
| adm-* skills | Covered by ADM Kit |
