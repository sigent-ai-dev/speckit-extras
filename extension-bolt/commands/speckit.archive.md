---
description: "Archive completed bolt with high-level summary, extract key decisions, document pivots, and prepare for retrospective."
---

# Bolt Archive Command

## User Input

```text
$ARGUMENTS
```

You **MUST** execute the bolt archive process.

**IMPORTANT**: When prompting for near-complete features, ask about **ONE feature at a time** and wait for the user's response before showing the next feature. This is similar to how `/speckit.clarify` works - sequential questions, not all at once.

## Process

**Do this:**

1. **Check for near-complete features** (In Progress/In Review/Blocked):
   
   a. Read `bolts/active/backlog.md`
   
   b. For each feature with status "In Progress", "In Review", or "Blocked":
      - Check if `specs/<feature-id>/` exists
      - Check if `specs/<feature-id>/spec.md` exists
      - Check if `specs/<feature-id>/planning/plan.md` exists
      - Check if `specs/<feature-id>/planning/tasks.md` exists
      - Count TODO/FIXME/XXX markers in spec.md
   
   c. **Ask the user** for each near-complete feature **ONE AT A TIME**:
      ```
      Feature: <feature-id>
      Name: <feature-name>
      Status: <current-status>
      
      Completion indicators:
        ✅ Spec exists
        ✅ Plan exists
        ✅ Tasks exist
        ⚠️  2 TODO markers
      
      Should this feature be archived as complete? (y/n/skip-all)
      ```
   
   d. **WAIT for user response** before showing the next feature
   
   e. If user responds "skip-all", stop asking and proceed to step 2
   
   f. Collect feature IDs where user answered "y"

2. **Execute archive script** with collected decisions:
   
   Build the command with approved features:
   ```bash
   # Bash
   bash .specify/extensions/bolt/scripts/bash/archive-bolt.sh --archive-features "005-api-lambda-implementation,007-deploy-frontend-aws"
   
   # PowerShell
   pwsh .specify/extensions/bolt/scripts/powershell/archive-bolt.ps1 -ArchiveFeatures "005-api-lambda-implementation,007-deploy-frontend-aws"
   ```
   
   Or if no additional features:
   ```bash
   # Bash
   bash .specify/extensions/bolt/scripts/bash/archive-bolt.sh
   
   # PowerShell
   pwsh .specify/extensions/bolt/scripts/powershell/archive-bolt.ps1
   ```
   
   The script will:
   - Archive features marked "Done/Completed/✅" automatically
   - Archive features from --archive-features parameter (if provided)
   - Move specs to archive directory
   - Generate summary, decisions, features.md, retrospective.md

3. **Report results** to the user:
   - Number of features archived
   - Archive location
   - Next steps (retrospective, new bolt)

### Step 1: Verify Active Bolt

1. **Check for active bolt**:
   - Verify `bolts/active/bolt.md` exists
   - If not found, error: "No active bolt to archive."

2. **Read bolt metadata**:
   - Bolt number
   - Bolt name
   - Start and end dates
   - Bolt goal
   - Features list

### Step 2: Determine Archive Location

1. **Create archive directory**:
   - Format: `bolts/archive/bolt-[NUMBER]-[slug]/`
   - Slug: lowercase, hyphenated version of bolt name
   - Example: `bolts/archive/bolt-001-foundation/`

2. **Create directory structure**:
   ```
   bolts/archive/bolt-[NUMBER]-[slug]/
   ├── summary.md         (generated)
   ├── decisions.md       (extracted)
   ├── retrospective.md   (template)
   └── features.md        (list)
   ```

### Step 3: Generate Bolt Summary

1. **Use template**: Copy from `templates/bolt-summary-template.md`

2. **Fill in metadata**:
   - Bolt number, name, duration
   - Start and end dates
   - Archived date (today)

3. **Analyze completed features**:
   - Read each feature spec from `specs/[feature-id]/`
   - Extract: feature name, status, completion date
   - Identify: completed, partial, carried over

4. **Generate executive summary**:
   - Summarize what was accomplished (2-3 paragraphs)
   - Assess bolt goal achievement
   - Highlight major accomplishments and challenges

5. **Calculate metrics**:
   - Features planned vs completed
   - Completion rate
   - Velocity (if tracked)

6. **Add custom summary** (if provided in `$ARGUMENTS`):
   - Prepend to executive summary
   - Use as additional context

### Step 4: Extract Key Decisions

1. **Scan feature specs**:
   - Look for decision sections in `specs/[feature-id]/plan.md`
   - Look for pivot notes in `specs/[feature-id]/COMPLETION_SUMMARY.md`
   - Check `bolts/active/decisions.md` for recorded decisions

2. **For each decision, extract**:
   - Decision title
   - Context (why decision was needed)
   - Options considered
   - Decision made
   - Rationale
   - Impact on project
   - Related features

3. **Identify pivots**:
   - Compare original plan vs actual outcome
   - Document: original plan, change, reason, outcome, lessons

4. **Write to decisions.md**:
   - Organize by importance
   - Include full context
   - Link to related feature specs

### Step 5: Document Lessons Learned

1. **Extract from feature specs**:
   - Look for "lessons learned" sections
   - Check completion summaries
   - Review implementation notes

2. **Categorize**:
   - What went well
   - What could be improved
   - Action items for next bolt

3. **Add to summary.md**:
   - Include in "Lessons Learned" section
   - Generate action items

### Step 6: Create Features List

1. **Generate features.md**:
   ```markdown
   # Bolt [NUMBER] Features
   
   ## Completed Features
   
   | Feature ID | Feature Name | Spec | Status |
   |------------|--------------|------|--------|
   | 001-auth   | Authentication | [spec](../../specs/001-auth/spec.md) | ✅ Complete |
   
   ## Partial Features
   
   [List features partially completed]
   
   ## Carried Over
   
   [List features moved to next bolt]
   ```

2. **Link to specs**:
   - Relative paths to feature specs
   - Include completion status

### Step 7: Create Retrospective Template

1. **Copy template**: From `templates/retrospective-template.md`

2. **Pre-fill sections**:
   - Bolt number and name
   - Date range
   - Completed features list
   - Known decisions (for clarification)
   - Known pivots (for analysis)

3. **Save to**: `bolts/archive/bolt-[NUMBER]-[slug]/retrospective.md`

4. **Mark as template**:
   - Add note: "Run `/speckit.retrospective` to conduct retrospective"

### Step 8: Move Bolt to Archive

1. **Copy files**:
   - Move `bolts/active/bolt.md` to archive
   - Move `bolts/active/decisions.md` to archive (if exists)
   - Move `bolts/active/backlog.md` to archive (if exists)

2. **Clean up active directory**:
   - Remove `bolts/active/` contents
   - Leave directory empty for next bolt

3. **Update roadmap** (if exists):
   - Mark bolt as complete in `bolts/roadmap.md`
   - Update project status

### Step 9: Output Summary

Display:
```
✅ Bolt [NUMBER] archived successfully!

Location: bolts/archive/bolt-[NUMBER]-[slug]/

Summary:
- Features completed: [X] of [Y]
- Key decisions: [N]
- Pivots: [M]

Files created:
- summary.md - High-level bolt summary
- decisions.md - Key decisions and pivots
- features.md - Feature list with links
- retrospective.md - Retrospective template

Next steps:
1. Review summary.md for accuracy
2. Run `/speckit.retrospective` to conduct retrospective
3. Run `/speckit.bolt start` to begin next bolt
```

## Example Output Structure

```
bolts/archive/bolt-001-foundation/
├── summary.md
│   ├── Executive Summary
│   ├── Bolt Goal Achievement
│   ├── Completed Features
│   ├── Key Decisions
│   ├── Pivots & Course Corrections
│   ├── Bolt Metrics
│   ├── Lessons Learned
│   └── Next Bolt Preview
│
├── decisions.md
│   ├── Decision 1: [Title]
│   ├── Decision 2: [Title]
│   └── ...
│
├── features.md
│   ├── Completed Features (with links)
│   ├── Partial Features
│   └── Carried Over
│
├── retrospective.md (template)
│   └── [Pre-filled with bolt context]
│
└── [Original bolt files]
    ├── bolt.md
    ├── backlog.md
    └── decisions.md
```

## Notes

- Archive can be run anytime (doesn't require bolt completion)
- Custom summary text in `$ARGUMENTS` is optional
- Decisions are extracted automatically from feature specs
- Retrospective template is created but not filled (use `/speckit.retrospective`)
- Archive is immutable - don't modify after creation

{SCRIPT}

## Script Integration

The `/speckit.archive` command uses the `archive-bolt` script to handle:
- Archive directory creation
- File moving and copying
- Feature spec scanning
- Summary generation
- Template processing

**Script Location**:
- Bash: `.specify/extensions/bolt/scripts/bash/archive-bolt.sh`
- PowerShell: `.specify/extensions/bolt/scripts/powershell/archive-bolt.ps1`

**Usage**:
```bash
# Bash
./.specify/extensions/bolt/scripts/bash/archive-bolt.sh --json --summary "Custom summary text"

# PowerShell
./.specify/extensions/bolt/scripts/powershell/archive-bolt.ps1 -Json -Summary "Custom summary text"
```

{SCRIPT}
