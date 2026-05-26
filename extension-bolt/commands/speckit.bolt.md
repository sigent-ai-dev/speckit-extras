---
description: "Create and manage bolts - group features into time-boxed development cycles with goals, capacity planning, and progress tracking."
---

# Bolt Management Command

## User Input

```text
$ARGUMENTS
```

You **MUST** execute the bolt command based on the user input.

## Commands

The user's input will be one of these commands. **Execute the corresponding action immediately:**

### `/speckit.bolt start "Bolt Name" --duration 2w`

**Do this:**

1. Extract bolt name and duration from `$ARGUMENTS`

2. **Ask for Bolt Goal** (interactive):
   - Ask: "What is the high-level goal for this bolt? What are you trying to achieve?"
   - Wait for user response
   - Store response as `BOLT_GOAL`
   - Example: "Enable users to authenticate and access personalized dashboards with role-based permissions"

3. **Ask for Success Criteria** (interactive):
   - Ask: "What are 3-5 measurable outcomes that indicate bolt success? Provide them as a list."
   - Wait for user response
   - Store response as list of criteria
   - Format as pipe-separated string: `criterion1|criterion2|criterion3`
   - Example: `Users can authenticate via OIDC with <2s login time|API response time < 200ms|Zero critical security vulnerabilities`

4. Execute the create-bolt script with goal and criteria:
   ```bash
   # Bash
   bash .specify/extensions/bolt/scripts/bash/create-bolt.sh --duration "2w" --goal "$BOLT_GOAL" --criteria "$CRITERIA_STRING" "Bolt Name"
   
   # PowerShell
   pwsh .specify/extensions/bolt/scripts/powershell/create-bolt.ps1 -Duration "2w" -Goal "$BOLT_GOAL" -Criteria "$CRITERIA_STRING" "Bolt Name"
   ```
   
   Note: The criteria string should be pipe-separated (|) for multiple criteria

5. Report success to the user:
   ```
   ✅ Bolt [NUMBER] created: [NAME]
   Duration: [START_DATE] - [END_DATE] ([DURATION])
   
   Goal: [BOLT_GOAL]
   
   Success Criteria:
   [List of criteria]
   
   Next steps:
   - Add features: /speckit.bolt add <feature-id>
   - View status: /speckit.bolt status
   ```

### `/speckit.bolt add <feature-ids>`

**Do this:**

1. Extract feature IDs from `$ARGUMENTS` (space-separated)
2. For each feature ID:
   - Check if `specs/<feature-id>/` exists
   - Check if already in `bolts/active/backlog.md`
   - If valid and not duplicate, extract feature name from `specs/<feature-id>/spec.md`
   - Append to backlog: `| <feature-id> | <name> | P1 | Not Started | | |`
3. Report which features were added and which were skipped

### `/speckit.bolt status`

**Do this:**

1. Read `bolts/active/bolt.md` to get bolt info
2. Read `bolts/active/backlog.md` to count features by status
3. Calculate completion percentage
4. Display formatted status with progress and blockers

### `/speckit.bolt complete`

**Do this:**

1. Execute the archive-bolt script:
   ```bash
   # Bash
   bash .specify/extensions/bolt/scripts/bash/archive-bolt.sh
   
   # PowerShell
   pwsh .specify/extensions/bolt/scripts/powershell/archive-bolt.ps1
   ```
2. Answer any interactive prompts about near-complete features
3. Parse the script output and report success/failure to the user

1. **Check for active bolt**:
   - If `bolts/active/bolt.md` exists, warn user and ask to complete it first
   - Suggest: `/speckit.bolt complete` or `/speckit.archive`

2. **Determine bolt number**:
   - Count existing archives in `bolts/archive/`
   - Next bolt number = count + 1 (e.g., bolt-001, bolt-002)

3. **Create bolt structure**:
   ```
   bolts/active/
   ├── bolt.md       (from templates/bolt-template.md)
   ├── backlog.md      (empty, will be populated)
   └── decisions.md    (empty, will be populated)
   ```

4. **Fill bolt template**:
   - Replace `[NUMBER]` with bolt number
   - Replace `[NAME]` with provided bolt name
   - Replace `[DURATION]` with provided duration or default "2 weeks"
   - Set `[START_DATE]` to today
   - Calculate `[END_DATE]` based on duration
   - Replace `$ARGUMENTS` with user's full input

5. **Initialize backlog.md**:
   ```markdown
   # Bolt [NUMBER] Backlog
   
   ## Features
   
   No features added yet. Use `/speckit.bolt add <feature-id>` to add features.
   
   ## Notes
   
   [Bolt planning notes]
   ```

6. **Initialize decisions.md**:
   ```markdown
   # Bolt [NUMBER] Decisions
   
   Document key decisions made during this bolt.
   
   ## Decision Log
   
   No decisions recorded yet.
   ```

7. **Output**:
   - Confirm bolt created
   - Show bolt number, name, duration
   - Suggest next steps: add features, define goals

---

### `/speckit.bolt add` - Add Features to Bolt

**Usage**: `/speckit.bolt add 001-feature-name 002-another-feature`

**Arguments**: One or more feature IDs (space-separated)

**Process**:

1. **Verify active bolt exists**:
   - Check `bolts/active/bolt.md`
   - If not found, error: "No active bolt. Use `/speckit.bolt start` first."

2. **For each feature ID**:
   
   a. **Validate feature exists**:
      - Check if `specs/[feature-id]/` directory exists
      - If not found, warn: "Feature [feature-id] not found in specs/, skipping"
      - Continue to next feature
   
   b. **Check if already in backlog**:
      - Search `bolts/active/backlog.md` for feature ID
      - If found, skip with message: "Feature [feature-id] already in bolt"
   
   c. **Extract feature name**:
      - Read `specs/[feature-id]/spec.md`
      - Find line matching `# Feature Specification: [NAME]`
      - Extract feature name, or use "Unknown" if not found
   
   d. **Add to backlog.md**:
      - Append to the features table:
        ```markdown
        | [feature-id] | [Feature Name] | P1 | Not Started | | |
        ```
      - If backlog has "No features added yet" message, replace it with the table header first

3. **Output summary**:
   ```
   ✅ Added 2 features to Bolt [NUMBER]:
     - 001-feature-name: Feature Title
     - 002-another-feature: Another Title
   
   Current bolt backlog: 5 features
   ```

**Example**:
```bash
/speckit.bolt add 001-auth 002-dashboard 003-api
```

---

### `/speckit.bolt status` - View Bolt Status

**Usage**: `/speckit.bolt status`

**Process**:

1. **Check for active bolt**:
   - If no active bolt, show: "No active bolt. Use `/speckit.bolt start` to begin."

2. **Read bolt.md**:
   - Extract bolt number, name, duration, dates
   - Parse features table
   - Calculate progress metrics

3. **Display status**:
   ```
   Bolt [NUMBER]: [NAME]
   Duration: [START] - [END] ([X] days remaining)
   
   Progress:
   - Features: [X] total, [Y] complete, [Z] in progress
   - Completion: [N]%
   
   Features:
   [Table of features with status]
   
   Recent Decisions: [Count]
   ```

4. **Highlight blockers**:
   - Show any features marked as "Blocked"
   - Suggest actions

---

### `/speckit.bolt complete` - Complete Bolt

**Usage**: `/speckit.bolt complete`

**Process**:

1. **Verify active bolt**:
   - Check `bolts/active/bolt.md` exists
   - If not, error: "No active bolt to complete."

2. **Trigger archival**:
   - Call `/speckit.archive` internally
   - This will:
     - Generate bolt summary
     - Move to archive
     - Extract decisions
     - Create retrospective template

3. **Output**:
   - Confirm bolt completed
   - Show archive location
   - Suggest: `/speckit.retrospective` to conduct retrospective

---

## Integration with Existing Commands

### `/speckit.specify` Integration

When creating a new feature, optionally link to active bolt:

```
After creating feature spec, ask:
"Add this feature to the current bolt? (y/n)"

If yes:
- Run `/speckit.bolt add [feature-id]`
- Update bolt backlog
```

### `/speckit.implement` Integration

When implementing features, update bolt progress:

```
After completing feature implementation:
- Update bolt.md feature status to "Complete"
- Update bolt metrics
- Check if bolt goal achieved
```

## Notes

- Only one active bolt at a time
- Features can be added/removed during bolt
- Bolt duration is flexible (can be extended)
- Decisions are captured automatically from feature specs
- Use `/speckit.archive` to manually archive without completing

{SCRIPT}

## Script Integration

The `/speckit.bolt start` command uses the `create-bolt` script to handle:
- Bolt number calculation
- Directory creation
- Template copying and variable replacement
- File initialization

**Script Location**:
- Bash: `.specify/extensions/bolt/scripts/bash/create-bolt.sh`
- PowerShell: `.specify/extensions/bolt/scripts/powershell/create-bolt.ps1`

**Usage**:
```bash
# Bash
./.specify/extensions/bolt/scripts/bash/create-bolt.sh --json --duration 2w "Bolt Name"

# PowerShell
./.specify/extensions/bolt/scripts/powershell/create-bolt.ps1 -Json -Duration 2w "Bolt Name"
```

{SCRIPT}
