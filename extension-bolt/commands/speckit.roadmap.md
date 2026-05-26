---
description: "Generate and maintain project-level roadmap showing bolt timeline, feature dependencies, and overall progress across the project."
---

# Roadmap Command

You are creating and maintaining a **project-level roadmap** that provides visibility across bolts, tracks dependencies, and shows overall project progress.

## Purpose

Generate a roadmap that shows:
1. Project vision and goals
2. Current bolt status
3. Upcoming bolts (planned)
4. Completed bolts (archived)
5. Feature backlog
6. Dependencies and blockers
7. Milestones and success metrics

## Commands

### `/speckit.roadmap` - Generate/Update Roadmap

**Usage**: `/speckit.roadmap`

**Process**:

### Step 1: Gather Project Context

1. **Read constitution**:
   - Extract project vision from `memory/constitution.md`
   - Identify core principles and goals

2. **Scan bolt archives**:
   - List all directories in `bolts/archive/`
   - For each bolt, read `summary.md`
   - Extract: bolt number, name, dates, features, status

3. **Check active bolt**:
   - Read `bolts/active/bolt.md` if exists
   - Extract: current bolt info, features, progress

4. **Scan feature specs**:
   - List all features in `specs/`
   - Identify: completed, in-progress, planned
   - Extract dependencies from plan.md files

### Step 2: Analyze Bolt History

1. **For each completed bolt**:
   - Bolt number and name
   - Duration and dates
   - Features completed
   - Key outcomes
   - Status (✅ Complete)

2. **Calculate project metrics**:
   - Total bolts completed
   - Total features delivered
   - Average velocity (if tracked)
   - Completion trends

### Step 3: Identify Current State

1. **Active bolt**:
   - Bolt number and name
   - Duration and dates
   - Current progress (% complete)
   - Features in progress
   - Blockers or risks

2. **If no active bolt**:
   - Show: "No active bolt"
   - Suggest: "Use `/speckit.bolt start` to begin next bolt"

### Step 4: Plan Future Bolts

1. **Analyze feature backlog**:
   - List features not yet in any bolt
   - Group by priority (P1, P2, P3)
   - Identify dependencies

2. **Suggest upcoming bolts**:
   - Based on feature priorities
   - Consider dependencies
   - Estimate 2-3 future bolts

3. **Tentative bolt planning**:
   - Bolt N+1: High-priority features
   - Bolt N+2: Medium-priority features
   - Bolt N+3: Lower-priority features

### Step 5: Map Dependencies

1. **Scan feature specs**:
   - Look for dependency mentions in plan.md
   - Check for "depends on" or "blocked by" statements

2. **Create dependency map**:
   - Feature X depends on Feature Y
   - External dependencies (APIs, services, approvals)

3. **Identify blockers**:
   - Features blocked by dependencies
   - External blockers (vendor, approval, etc.)

### Step 6: Define Milestones

1. **Extract from bolts**:
   - Major deliverables from bolt summaries
   - Key achievements and outcomes

2. **Project milestones**:
   - MVP milestone (first usable version)
   - Beta milestone (feature complete)
   - GA milestone (production ready)
   - Future milestones

3. **Milestone dates**:
   - Based on bolt timeline
   - Include target dates

### Step 7: Generate Roadmap Document

1. **Use template**: From `templates/roadmap-template.md` (if exists) or create new

2. **Fill sections**:

   **Vision**:
   - High-level project vision
   - What are we building and why?

   **Current Bolt**:
   - Bolt number, name, dates
   - Progress and status
   - Features in progress

   **Upcoming Bolts**:
   - Bolt N+1: Name, dates, planned features
   - Bolt N+2: Name, dates, planned features
   - Bolt N+3: Name, dates, planned features

   **Completed Bolts**:
   - Table of completed bolts
   - Bolt number, name, duration, features, status

   **Feature Backlog**:
   - High priority (P1)
   - Medium priority (P2)
   - Low priority (P3)

   **Dependencies & Blockers**:
   - Internal dependencies
   - External dependencies
   - Current blockers

   **Milestones**:
   - Milestone name, date, description
   - Status (upcoming, achieved)

   **Success Metrics**:
   - Key metrics for project success
   - Current status vs targets

3. **Save to**: `bolts/roadmap.md`

### Step 8: Generate Visual Timeline (Optional)

Create ASCII timeline:
```
Project Timeline
================

Bolt 001 [========] Complete (Oct 1-15)
Bolt 002 [========] Complete (Oct 16-31)
Bolt 003 [====----] In Progress (Nov 1-15)
Bolt 004 [--------] Planned (Nov 16-30)
           ^
           Today
```

### Step 9: Output Summary

Display:
```
📊 Project Roadmap Updated

Location: bolts/roadmap.md

Summary:
- Completed bolts: [N]
- Current bolt: [Bolt X: Name]
- Upcoming bolts: [M] planned
- Feature backlog: [P] features
- Blockers: [B] active blockers

Milestones:
- [Milestone 1]: [Status]
- [Milestone 2]: [Status]

Next steps:
1. Review roadmap for accuracy
2. Update bolt plans as needed
3. Address blockers
```

---

### `/speckit.roadmap view` - View Roadmap

**Usage**: `/speckit.roadmap view`

**Process**:

1. **Check if roadmap exists**:
   - Look for `bolts/roadmap.md`
   - If not found, suggest: `/speckit.roadmap` to generate

2. **Display roadmap**:
   - Show full roadmap content
   - Highlight current bolt
   - Show upcoming bolts

3. **Summary stats**:
   - Total bolts
   - Current progress
   - Next milestone

---

## Roadmap Structure

```markdown
# Project Roadmap: [PROJECT_NAME]

**Last Updated**: [DATE]
**Project Status**: [Active/On Hold/Complete]

## Vision

[High-level vision - what are we building and why?]

## Current Bolt

**Bolt [NUMBER]**: [NAME]
**Duration**: [START] - [END]
**Status**: [In Progress/Planning/Complete]

[Brief summary of current bolt goals]

**Features**:
- [Feature 1]
- [Feature 2]

## Upcoming Bolts

### Bolt [N+1]: [NAME] (Planned)
**Target**: [DATE_RANGE]
**Focus**: [High-level focus area]

**Planned Features**:
- [Feature 1]
- [Feature 2]

### Bolt [N+2]: [NAME] (Tentative)
**Target**: [DATE_RANGE]
**Focus**: [High-level focus area]

## Completed Bolts

| Bolt | Name | Duration | Features | Status |
|--------|------|----------|----------|--------|
| 001 | Foundation | 2w | 5 | ✅ Complete |
| 002 | Core Features | 2w | 8 | ✅ Complete |

## Feature Backlog

### High Priority (P1)
- [ ] [Feature name] - [Brief description]

### Medium Priority (P2)
- [ ] [Feature name] - [Brief description]

### Low Priority (P3)
- [ ] [Feature name] - [Brief description]

## Dependencies & Blockers

- [Dependency 1]: [Description and status]
- [Blocker 1]: [Description and mitigation]

## Milestones

- **[Milestone 1]**: [DATE] - [Description]
- **[Milestone 2]**: [DATE] - [Description]

## Success Metrics

- [Metric 1]: [Target]
- [Metric 2]: [Target]
```

## Integration with Other Commands

### `/speckit.bolt start` Integration
- Update roadmap when new bolt starts
- Move bolt from "Upcoming" to "Current"

### `/speckit.archive` Integration
- Update roadmap when bolt completes
- Move bolt from "Current" to "Completed"

### `/speckit.specify` Integration
- Add new features to backlog
- Update feature counts

## Notes

- Roadmap is living document - update regularly
- Roadmap shows high-level view, not detailed specs
- Use roadmap for stakeholder communication
- Update after each bolt completion
- Review and adjust upcoming bolts as needed

{SCRIPT}
