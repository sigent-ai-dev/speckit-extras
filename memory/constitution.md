# Spec Kit Extras Constitution

## Core Principles

1. **Self-review before human review** — never ask a human to review something you haven't checked yourself. Catch your own stubs, drift, and convention violations.
2. **Closing claims must be honest** — `Closes #N` means every acceptance criterion is met in this PR. If not, downgrade to `Refs #N`.
3. **Measure what matters** — DORA metrics give teams visibility without opinion. Report facts, let teams draw conclusions.
4. **Right-sized decomposition** — nothing enters a backlog that can't be delivered in ≤ 2 weeks. Split until it fits.
5. **Propose-then-confirm** — never create artefacts (issues, PRs, reports) without human approval.

## Quality Standards

- Self-review findings use the C/H/M/L/I severity scale consistently
- PR bodies are generated from source (spec + git), not hand-written
- DORA reports compute all four metrics or clearly note which are unavailable
- Decomposed issues always have testable acceptance criteria
- All commands work with `gh` CLI (no external dependencies beyond git + gh)
