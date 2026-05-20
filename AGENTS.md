# AGENTS.md

## About Spec Kit Extras

**Spec Kit Extras** is a collection of four AI agent commands that add delivery-quality disciplines on top of Spec Kit's core workflow. They are engagement-portable — designed to work in any GitHub-hosted project that uses Spec Kit.

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

### Templates Only (no CLI)

Unlike Intent Kit and ADM Kit, Spec Kit Extras has no CLI tool. It is a **template pack** — you copy the command files into your project's agent commands directory. An optional install script handles the copy.

```
speckit-extras/
├── templates/commands/
│   ├── selfreview.md        # /speckit.selfreview
│   ├── pr.md                # /speckit.pr
│   ├── dora.md              # /speckit.dora
│   └── decompose.md         # /speckit.decompose
├── scripts/
│   └── install.sh           # Copy commands to target project
├── docs/                    # Usage documentation
└── memory/
    └── constitution.md      # Quality principles
```

### Installation target directories (per agent)

| Agent | Target |
|-------|--------|
| Claude Code | `.claude/commands/` |
| Gemini CLI | `.gemini/commands/` |
| GitHub Copilot | `.github/agents/` |
| Cursor | `.cursor/commands/` |
| Amazon Q | `.amazonq/prompts/` |
| Windsurf | `.windsurf/workflows/` |

## Implementation Plan

### Phase A: Foundation (current)

- [x] README with all four commands documented
- [x] Command templates for all four commands
- [x] AGENTS.md with development context
- [ ] Install script (bash) — copies commands to target agent directory
- [ ] Install script (powershell)
- [ ] Constitution / memory file

### Phase B: Testing

- [ ] Test fixtures for selfreview (sample diffs + expected findings)
- [ ] Test fixtures for DORA (sample `gh` JSON output + expected metrics)
- [ ] Test fixtures for decompose (sample design doc + expected issues)
- [ ] Test fixtures for PR (sample branch state + expected body)

### Phase C: Multi-agent Support

- [ ] Agent-specific command wrappers (adapt frontmatter/format per agent)
- [ ] Install script supports `--agent` flag for all supported agents

### Phase D: Documentation

- [ ] Usage guide for each command
- [ ] Integration guide (with Spec Kit, Intent Kit, ADM Kit)
- [ ] Examples directory with before/after

## Key Design Decisions

1. **Template pack, not a CLI** — the value is in the AI instructions, not in scaffolding code. Keep distribution simple (copy files).
2. **Self-review is standalone AND embedded in PR** — `/speckit.selfreview` works on its own for iteration; `/speckit.pr` calls it as a mandatory pre-flight.
3. **Closing-claim accuracy is the load-bearing gate** — this single check prevents the "Closes #N" lie that degrades backlog integrity.
4. **DORA uses `gh` CLI only** — no API tokens, no external services, no vendor lock-in.
5. **Decompose is propose-then-confirm** — never creates issues without operator approval.

## What's NOT Included (and why)

| Skill | Reason excluded |
|-------|-----------------|
| Red-team gate/run | Imported concept, not originated here |
| Tier classification (Q0-Q3) | Tied to the red-team gate flow |
| speckit-intent | Superseded by Intent Kit's `/intent.capture` |
| speckit-git-* | Upstream Spec Kit handles git workflow inline in `/speckit.specify` |
| speckit-bolt-* | Upstream Spec Kit has sprint management (`/speckit.sprint`) |
| forge-* skills | Covered by Intent Kit |
| adm-* skills | Covered by ADM Kit |
| react-core-design-system | Client-specific, not portable |
| schroders-brand-guidelines | Client-specific, not portable |
| devops-actions | Vendor-specific CI toolchain guidance |
