# Atlassian Sync Workflow

> Transform BMAD documentation into Jira/Confluence structure

## Overview

This workflow bridges BMAD documentation with Atlassian systems. It can work with whatever BMAD docs exist—from a simple Product Brief to full PRD + Epics.

**Agent:** Atlas (Atlassian Orchestrator)  
**Entry Points:**
- Post-workflow hook after `*create-epics-and-stories`
- Manual: `@atlas orchestrate`

## Workflow Steps

| Step | Name | Purpose | State Key |
|------|------|---------|-----------|
| 1 | Setup | Detect mode, confirm targets, load context | `step-01-setup` |
| 2 | Generate Structure | Create local Jira/Confluence folder hierarchy | `step-02-generate` |
| 3 | Sync Confluence | Create/update Confluence pages (get IDs) | `step-03-confluence` |
| 4 | Sync Jira | Create/update Jira tickets with Confluence links | `step-04-jira` |
| 5 | Report | Summary with links and validation notes | `step-05-report` |

## Entry Modes

Atlas auto-detects the appropriate mode:

| Mode | Trigger | What Happens |
|------|---------|--------------|
| **NEW** | Fresh BMAD docs | Full creation workflow |
| **IMPORT** | Jira key provided | Import existing ticket structure |
| **CONTINUE** | In existing folder | Add to existing structure |
| **SYNC_CONFLUENCE** | Jira exists, no docs | Create Confluence docs only |

## State File

Progress is tracked in `_bmad/_memory/atlassian-orchestrator-sidecar/workflow-state.yaml`:

```yaml
workflow: atlassian-sync
started: "2026-01-07T10:30:00Z"
current_step: step-02-generate
steps_completed:
  - step-01-setup
context:
  mode: NEW
  jira_instance: company
  jira_project: PROJ
  confluence_space: DOCS
  source_docs:
    - docs/epics.md
    - docs/prd.md
```

## Resume Capability

If interrupted, resume with:
```
@atlas orchestrate
```

Atlas will:
1. Check for existing workflow-state.yaml
2. Offer to continue or restart
3. Resume from last completed step

## Available BMAD Docs

Atlas can work with whatever exists:

| Available | Capability |
|-----------|------------|
| Product Brief only | High-level Epics with assumptions |
| PRD | Detailed Epics with acceptance criteria |
| PRD + Architecture | Technical context, Story-level breakdown |
| PRD + Epics.md | Full hierarchy with PM-approved scope |

---

*Part of RZLV Flow - AI Agile Toolkit*
