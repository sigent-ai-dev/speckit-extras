# Spec Kit Extras

**Quality gates and delivery tooling that extend [Spec Kit](https://github.com/github/spec-kit).**

Spec Kit Extras is a collection of AI agent commands that add delivery-quality disciplines on top of Spec Kit's core specify → plan → tasks → implement workflow. These are engagement-portable — drop them into any GitHub-hosted project that uses Spec Kit.

---

## What's Included

| Command | What it does | Works with |
|---------|-------------|------------|
| `/speckit.selfreview` | Rigorous self-review of a PR before requesting human review | Any GitHub repo |
| `/speckit.pr` | Create a PR with closing-claim accuracy gate | Any repo with a PR template |
| `/speckit.dora` | Generate weekly DORA metrics from GitHub data | Any GH repo with PRs + Actions |
| `/speckit.decompose` | Decompose design docs into right-sized GitHub issues | Any repo with design docs |

## Why These Exist

Spec Kit's core workflow ensures features are well-specified and planned. But shipping quality software also requires:

- **Knowing your PR is ready before someone else reviews it** — `selfreview` catches the patterns that waste reviewer time (stubs, contract drift, closing-claim mismatches)
- **PR descriptions that actually explain what's happening** — `pr` generates descriptions from spec docs + git history and validates issue-closing claims
- **Visibility into delivery health** — `dora` computes the four DORA metrics so teams can see if their process is healthy
- **Getting from design to backlog without losing traceability** — `decompose` turns architecture docs, ADRs, and design documents into well-formed issues with acceptance criteria

## Install

Copy the `templates/commands/` files into your project's Spec Kit commands directory:

```bash
# For Claude Code
cp templates/commands/*.md .claude/commands/speckit.*.md

# Or use the install script
./scripts/install.sh --agent claude
```

## Commands

### `/speckit.selfreview`

Performs a structured self-review of the current branch's PR diff before requesting human review. Calibrated to catch the recurring patterns that waste review cycles.

**What it checks:**
- Contract adherence (does implementation match design doc?)
- Issue closing accuracy (does PR fully satisfy every AC of linked issues?)
- Stubs and no-ops (is any function claiming to do something it doesn't?)
- State management (phase transitions atomic? prior state leaking?)
- Error handling (failures visible or silently swallowed?)
- Convention alignment (lint, imports, test patterns)
- Downstream risks (what assumptions do consumers inherit?)

**Severity classification:**
- **C** (Critical) — functionality doesn't do what it claims, breaks something
- **H** (High) — material bug, unsafe pattern, doc/code mismatch
- **M** (Medium) — design concern, missed edge case, convention violation
- **L** (Low) — style, naming, minor clarity
- **I** (Info) — observation, no action needed

**Output:** Markdown report with findings table, contract adherence summary, issue closing assessment, verdict (APPROVE / REQUEST CHANGES / COMMENT), and recommended fixes.

**Action:** Fixes all C and H findings immediately. Fixes M unless documented reason to defer. Notes L for follow-up.

```bash
/speckit.selfreview
/speckit.selfreview #42        # specific PR number
```

---

### `/speckit.pr`

Creates a pull request with a generated description and a closing-claim accuracy gate.

**What it does:**
1. Generates PR title from commit history
2. Generates PR body from spec docs + git log + PR template
3. Validates closing claims — if `Closes #N` is claimed but not every AC of issue N has evidence in the diff, downgrades to `Refs #N` and lists unmet AC
4. Runs `/speckit.selfreview` and posts findings as a PR comment
5. Refuses to open if C-severity findings exist (would block merge anyway)

**The closing-claim accuracy gate** is the load-bearing discipline: PRs that claim to close an issue when acceptance criteria remain unmet get downgraded automatically. This prevents the "Closes #N" lie that leads to issues being closed without full delivery.

```bash
/speckit.pr                    # PR against main
/speckit.pr develop            # PR against develop branch
```

---

### `/speckit.dora`

Generates a weekly DORA metrics snapshot from GitHub API data.

**What it computes:**
- **Deployment Frequency** — successful deployments per day (from workflow runs)
- **Lead Time for Changes** — median time from first commit to merge
- **Change Failure Rate** — fraction of deploys followed by revert within 24h
- **Mean Time to Restore** — median time from failure to green build

**Output:** A Markdown report at `doc/reports/YYYY-MM-DD-weekly-dora.md` with metrics, DORA band classification (Elite/High/Medium/Low), and prior-window comparison.

```bash
/speckit.dora                           # last 7 days
/speckit.dora 2026-05-01..2026-05-14    # explicit window
/speckit.dora --dry-run                 # stdout only, no file write
```

---

### `/speckit.decompose`

Decomposes design documents, ADRs, or architecture docs into reviewed GitHub issues per a structured playbook.

**Three modes:**
1. **Create** (default) — propose-then-confirm. Drafts issues, presents for review, creates on confirmation via `gh issue create`.
2. **Validate** — read-only audit of an existing issue against the decomposition playbook.
3. **Link-back** — append `## Related Work` section to source doc with permanent links to produced issues.

**What it enforces:**
- Every issue has acceptance criteria (rejected without)
- Every issue references the source document it was decomposed from
- Issues are right-sized (XL items must decompose further)
- Multi-axis labels applied (type, priority, size, epic)
- Epic-shaped issues caught and split
- Dependency relationships made explicit

```bash
/speckit.decompose doc/design/my-architecture.md     # Create mode
/speckit.decompose validate #42                       # Validate mode
/speckit.decompose link-back doc/design/arch.md #42 #43 #44  # Link-back
```

---

## Integration with Spec Kit

These commands complement the core Spec Kit workflow:

```
/speckit.specify  →  /speckit.plan  →  /speckit.tasks  →  /speckit.implement
                                                                    │
                                                                    ▼
                                                          /speckit.selfreview
                                                                    │
                                                                    ▼
                                                             /speckit.pr
```

And for project-level planning:

```
Design docs / ADRs  →  /speckit.decompose  →  Issues  →  /speckit.specify (per feature)
```

Weekly health check:

```
/speckit.dora  →  doc/reports/  →  team visibility
```

## Integration with Intent Kit

If you use [Intent Kit](https://github.com/superhighway-factory/intent-kit) upstream:

```
/intent.decompose produces feature list  →  /speckit.decompose creates issues  →  /speckit.specify per issue
```

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

[MIT](./LICENSE)
