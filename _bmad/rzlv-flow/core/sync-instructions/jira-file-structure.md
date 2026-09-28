# Jira File Structure - Unified Hierarchy

**Version:** 1.0.0  
**Applies To:** Atlassian Orchestrator, Agile Companion  
**Pattern:** Shared Hierarchical Structure with Clear Ownership  
**Source of Truth:** `core/suite-structure.yaml`

---

## Overview

Both **Atlassian Orchestrator** and **Agile Companion** use the **same hierarchical structure** in `docs/jira/{instance}/{project}/`. This ensures:
- Single source of truth for sync state
- Natural parent-child navigation  
- No duplicate files or conflicting structures
- Clear ownership rules within each ticket folder

---

## Directory Structure

```
docs/jira/{instance}/{project}/
│
├── epic-name/                           # Epic folder (kebab-case)
│   ├── epic.md                          # Epic sync state + metadata
│   ├── _docs/                           # Generated documentation (Orchestrator)
│   │   ├── technical-architecture.md
│   │   ├── decisions.md
│   │   └── strategic-context.md
│   │
│   └── stories/
│       ├── PROJ-123/                    # Story folder
│       │   ├── PROJ-123.md              # Story sync state (BOTH agents)
│       │   ├── _docs/                   # Generated story docs (Orchestrator)
│       │   ├── _work/                   # Developer notes (Agile Companion, gitignored)
│       │   │   ├── notes.md
│       │   │   ├── scratch.md
│       │   │   └── checklist.md
│       │   │
│       │   └── subtasks/
│       │       └── PROJ-124/            # Subtask folder
│       │           ├── PROJ-124.md      # Subtask sync state
│       │           └── _work/           # Subtask dev notes
│       │
│       └── PROJ-125/
│           └── PROJ-125.md
│
├── another-epic/
│   └── ...
│
└── _orphans/                            # Stories without epic (yet)
    └── PROJ-200/
        ├── PROJ-200.md                  # Story sync state
        └── _work/                       # Developer notes
```

---

## File Ownership Rules

| Path | Owner | Purpose | Synced | Gitignored |
|------|-------|---------|--------|------------|
| `{ticket}.md` | Both | Sync state | Yes | No |
| `_docs/` | Orchestrator | Generated docs | No | No |
| `_work/` | Agile Companion | Dev notes | No | Yes |
| `subtasks/` | Both | Hierarchy | Partial | No |

---

## Sync State Format

Every ticket file uses this YAML frontmatter:

```yaml
---
sync:
  jira_key: "PROJ-123"
  jira_ari: "ari:cloud:jira:a1b2c3d4:issue/10001"
  status: "In Progress"
  assignee: "john.doe@company.com"
  priority: "High"
  story_points: 3
  last_synced: "2025-12-11T10:30:00Z"
  version: 42

structure:
  type: "story"
  parent: "../epic.md"
  epic: "PROJ-120"

agile_companion:
  last_focused: "2025-12-11T08:00:00Z"
  working_branch: "feature/PROJ-123"
  local_commits: 3

orchestrator:
  generated_at: "2025-12-10T14:00:00Z"
  confluence_page_id: "123456789"
  confluence_url: "https://..."
---

# Ticket Summary

## Description
{Description from Jira}

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
```

---

## Smart Creation Rules

| Rule | Condition | Action |
|------|-----------|--------|
| Epic Exists | Epic structure found | Use existing, add agent folders |
| Epic Missing | No epic structure | Create in `_orphans/`, move later |
| Parent Requested | User asks for parent | Fetch parent, create structure, move |
| Subtasks Requested | User asks for subtasks | Create `subtasks/` folder, populate |

---

**Key Principle:** One structure, clear ownership, safe FCMP sync.
