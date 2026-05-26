---
description: "Conduct a bolt retrospective to understand decisions, identify improvements, and clarify unclear choices. Similar to /speckit.clarify but focused on past bolt analysis."
---

# Bolt Retrospective Command

You are conducting a **bolt retrospective** to help the team understand decisions made during the bolt, identify improvements, and clarify any unclear choices or pivots.

## Context

This command is similar to `/speckit.clarify` but focused on **retrospective analysis** rather than forward-looking clarification. The goal is to:

1. **Understand past decisions** - Why were certain choices made?
2. **Identify patterns** - What worked well and what didn't?
3. **Clarify pivots** - Why did plans change and what was learned?
4. **Generate improvements** - What concrete actions will improve future bolts?
5. **Preserve knowledge** - Document context for future reference

## Prerequisites

Before running this command, ensure:

- [ ] Bolt has been completed or is near completion
- [ ] Bolt summary has been generated (via `/speckit.archive`)
- [ ] Team members are available for retrospective discussion
- [ ] Bolt artifacts exist in `bolts/active/` or `bolts/archive/bolt-NNN/`

## Input

**Arguments**: $ARGUMENTS

If arguments specify a bolt number (e.g., "bolt-001"), conduct retrospective for that archived bolt.
If no arguments, conduct retrospective for the most recently completed bolt.

## Process

### Step 1: Locate Bolt Artifacts

1. **Check for bolt specification**:
   - If `$ARGUMENTS` contains bolt number: Read `bolts/archive/bolt-NNN/`
   - Otherwise: Read `bolts/active/bolt.md` or most recent archive

2. **Gather bolt context**:
   - Read `bolt.md` - Original plan, goals, features
   - Read `summary.md` - What was actually accomplished
   - Read `decisions.md` - Key decisions made during bolt
   - Read feature specs from `specs/NNN-feature-name/` for completed features

3. **Identify areas needing clarification**:
   - Decisions that seem unclear or lack rationale
   - Pivots that changed the bolt direction
   - Features that were dropped or carried over
   - Unexpected challenges or blockers

### Step 2: Structured Retrospective Questions

Ask clarifying questions in these categories. **Similar to `/speckit.clarify`, ask questions sequentially and wait for answers before proceeding.**

#### Category 1: Bolt Goal & Outcomes

1. **Q: Was the bolt goal achieved? Why or why not?**
2. **Q: Which features were completed vs planned? What changed?**
3. **Q: What was the most valuable thing delivered this bolt?**

#### Category 2: Decision Clarification

For each major decision in `decisions.md`:

1. **Q: Why did we choose [X] over [Y]?**
2. **Q: What information did we have when making this decision?**
3. **Q: What were the consequences of this decision?**

#### Category 3: Pivot Analysis

For each pivot or course correction:

1. **Q: When did we realize we needed to pivot?**
2. **Q: What led to this pivot?**
3. **Q: How did the pivot affect the bolt?**

#### Category 4: Process & Workflow

1. **Q: What worked well in our process this bolt?**
2. **Q: What didn't work well in our process?**
3. **Q: Were there any surprises or unexpected challenges?**

#### Category 5: Technical Practices

1. **Q: What technical decisions are we happy with?**
2. **Q: What technical decisions are we questioning?**
3. **Q: What technical debt did we create and why?**

#### Category 6: Team & Collaboration

1. **Q: How was team morale and energy this bolt?**
2. **Q: How well did we collaborate?**
3. **Q: What did team members learn this bolt?**

### Step 3: Generate Retrospective Document

1. **Create retrospective file**:
   - If active bolt: `bolts/active/retrospective.md`
   - If archived bolt: `bolts/archive/bolt-NNN/retrospective.md`

2. **Use template**: Copy from `templates/retrospective-template.md`

3. **Fill in all sections** with answers from the structured questions

4. **Prioritize action items**:
   - High priority: Must do next bolt
   - Medium priority: Do within 2-3 bolts
   - Low priority: Nice to have

### Step 4: Update Bolt Summary

1. **Add retrospective highlights to summary**:
   - Update `summary.md` with key retrospective insights
   - Link to full retrospective document

2. **Update decisions.md with clarifications**:
   - Add clarifying context to unclear decisions
   - Document lessons learned for each decision

### Step 5: Create Action Items

1. **Generate actionable improvements**:
   - Each action item must have:
     - Specific description
     - Owner
     - Success criteria
     - Effort estimate

2. **Link to next bolt**:
   - High-priority actions should be added to next bolt planning

## Output Format

Generate a complete retrospective document with:

1. **Executive Summary**: Top 3 insights, action items, experiments
2. **Detailed Sections**: All questions, answers, and analysis
3. **Action Plan**: Prioritized action items and experiments
4. **Team Recognition**: Specific shout-outs and achievements

## Notes

- This is a **facilitated conversation**, not a one-shot generation
- Ask questions sequentially and wait for answers
- Dig deeper when answers are vague or unclear
- Focus on understanding "why" not just "what"
- Create psychological safety - focus on systems, not individuals
- Generate concrete, actionable improvements

{SCRIPT}
