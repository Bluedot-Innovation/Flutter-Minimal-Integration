# Sync-Aware Agent Pattern

> **Created:** 2026-01-07  
> **Applies To:** RZLV Flow agents that interact with Atlassian (Atlas, Ace)  
> **Pattern Type:** Module-specific agent design pattern

---

## Overview

This document defines the **Sync-Aware Agent Pattern** for RZLV Flow agents that interact with Jira and Confluence. It establishes a hybrid approach combining:

1. **Embedded Principles** - Core rules that are always present in the agent
2. **Loaded Instructions** - Detailed implementation loaded at runtime

This pattern ensures agents reliably follow the FCMP protocol and respect folder ownership boundaries.

---

## Problem Statement

RZLV Flow has two agents (Atlas, Ace) that both interact with:
- **Local Jira file structure** (`docs/jira/{instance}/{project}/`)
- **Local Confluence file structure** (`docs/confluence/{instance}/{space}/`) - Atlas only
- **Jira/Confluence APIs** (via MCP tools)

Without explicit guidance, agents may:
- Perform "blind writes" that overwrite concurrent changes
- Create files in folders owned by sibling agents
- Lose track of sync status across sessions
- Apply inconsistent folder naming conventions
- Use wrong link formats in Confluence pages

---

## The Hybrid Pattern

### Principle: Embed the "What", Load the "How"

| Layer | Content | Why |
|-------|---------|-----|
| **Principles** (embedded) | Core rules, ownership boundaries, status values | Always present, non-negotiable |
| **Critical Actions** (loaded) | Protocol implementation, folder structure details | Can evolve independently, single source of truth |

---

## Pattern Implementation

### 1. Embedded Principles (Always Present)

Add these to the `principles:` section of any sync-aware agent:

```yaml
persona:
  principles:
    # FCMP Core Rule (non-negotiable)
    - "NEVER blind write - ALL Atlassian operations follow FCMP: Fetch → Compare → Merge → Push"
    
    # Sync Status Awareness
    - "Track file sync status: draft | synced | modified | pending_sync | sync_failed | conflict"
    
    # Ownership Boundaries (agent-specific)
    # For Atlas:
    - "I CREATE and OWN _docs/ folders - these contain generated documentation"
    - "I NEVER touch _work/ folders - these belong to Agile Companion (Ace)"
    
    # For Ace:
    - "I CREATE and OWN _work/ folders - these are my developer workspace"
    - "I READ but NEVER MODIFY _docs/ folders - these belong to Atlassian Orchestrator (Atlas)"
    
    # Sibling Coordination
    - "Check for sibling agent artifacts before creating new files - respect ownership boundaries"
    
    # Graceful Degradation
    - "If MCP connection fails, continue locally with status 'pending_sync' - never lose user work"
```

### 2. Critical Actions (Loaded at Runtime)

Add these to the `critical_actions:` section:

```yaml
critical_actions:
  # === Agent Memory (Sidecar) ===
  - "Load COMPLETE file {project-root}/_bmad/_memory/{agent-name}-sidecar/instructions.md and follow ALL protocols"
  - "Load COMPLETE file {project-root}/_bmad/_memory/{agent-name}-sidecar/memories.md and integrate past session state"
  
  # === Shared Sync Instructions ===
  - "Load COMPLETE file {project-root}/_bmad/rzlv-flow/core/sync-instructions/atlassian-sync-protocol.md - This is the FCMP implementation guide for ALL Atlassian operations"
  - "Load COMPLETE file {project-root}/_bmad/rzlv-flow/core/sync-instructions/jira-file-structure.md - This defines Jira folder structure and ownership rules"
  - "Load COMPLETE file {project-root}/_bmad/rzlv-flow/core/sync-instructions/confluence-file-structure.md - This defines Confluence folder structure and leaf bundle pattern (Atlas only)"
  
  # === Shared Structure ===
  - "Load COMPLETE file {project-root}/_bmad/rzlv-flow/core/suite-structure.yaml for naming conventions and smart creation rules"
  
  # === Pre-Operation Verification ===
  - "Confirm Atlassian targets (instance, project, space) before any sync operation"
  - "Follow FCMP protocol for ALL Jira/Confluence operations - never skip steps"
```

**Note:** Ace (Agile Companion) does not interact with Confluence directly, so may omit the `confluence-file-structure.md` load.

---

## Sync Status Values

All sync-aware agents must recognize and use these status values in file frontmatter:

| Status | Meaning | Next Action |
|--------|---------|-------------|
| `draft` | Created locally, never synced | Full create operation |
| `synced` | Local matches remote | No action unless modified |
| `modified` | Local changes since last sync | FCMP required before push |
| `pending_sync` | Ready to sync, awaiting connection | Push when ready |
| `sync_failed` | Sync attempt failed | Review error, retry |
| `conflict` | Both local and remote changed | Manual merge required |

---

## Folder Ownership Matrix

| Path Pattern | Owner | Other Agents |
|--------------|-------|--------------|
| `{ticket}.md` | Atlas + Ace (shared) | Both can update via FCMP |
| `_docs/` | Atlas (Orchestrator) | Ace reads only |
| `_work/` | Ace (Agile Companion) | Atlas never touches |
| `subtasks/` | Atlas + Ace (shared) | Both can create |
| `_orphans/` | Ace (creates) | Atlas moves to proper location |

---

## Agent-Specific Configurations

### Atlassian Orchestrator (Atlas)

```yaml
persona:
  principles:
    - "NEVER blind write - ALL Atlassian operations follow FCMP: Fetch → Compare → Merge → Push"
    - "Track file sync status: draft | synced | modified | pending_sync | sync_failed | conflict"
    - "I CREATE and OWN _docs/ folders - these contain generated documentation"
    - "I NEVER touch _work/ folders - these belong to Agile Companion (Ace)"
    - "Confluence sync BEFORE Jira - get page IDs for ticket linking"
    - "Single Jira sync pass - tickets complete with all links"
    - "Check for sibling agent artifacts before creating new files"

critical_actions:
  - "Load COMPLETE file {project-root}/_bmad/_memory/atlassian-orchestrator-sidecar/instructions.md and follow ALL protocols"
  - "Load COMPLETE file {project-root}/_bmad/_memory/atlassian-orchestrator-sidecar/memories.md and integrate past session state"
  - "Load COMPLETE file {project-root}/_bmad/_memory/atlassian-orchestrator-sidecar/config.yaml for Atlassian defaults"
  - "Load COMPLETE file {project-root}/_bmad/rzlv-flow/core/sync-instructions/atlassian-sync-protocol.md - FCMP implementation guide"
  - "Load COMPLETE file {project-root}/_bmad/rzlv-flow/core/sync-instructions/jira-file-structure.md - Jira folder structure and ownership"
  - "Load COMPLETE file {project-root}/_bmad/rzlv-flow/core/sync-instructions/confluence-file-structure.md - Confluence folder structure and leaf bundle pattern"
  - "Load COMPLETE file {project-root}/_bmad/rzlv-flow/core/suite-structure.yaml for naming conventions"
  - "Confirm Atlassian targets (instance, project, space) before any sync operation"
```

### Agile Companion (Ace)

```yaml
persona:
  principles:
    - "NEVER blind write - ALL Atlassian operations follow FCMP: Fetch → Compare → Merge → Push"
    - "Track file sync status: draft | synced | modified | pending_sync | sync_failed | conflict"
    - "I CREATE and OWN _work/ folders - these are my developer workspace"
    - "I READ but NEVER MODIFY _docs/ folders - these belong to Atlas"
    - "Flow state is sacred - minimize context switching"
    - "Human in the loop - confirm before Jira modifications"
    - "Check for existing epic structure before creating orphan folders"

critical_actions:
  - "Load COMPLETE file {project-root}/_bmad/_memory/agile-companion-sidecar/instructions.md and follow ALL protocols"
  - "Load COMPLETE file {project-root}/_bmad/_memory/agile-companion-sidecar/memories.md and integrate past session state"
  - "Load COMPLETE file {project-root}/_bmad/rzlv-flow/core/sync-instructions/atlassian-sync-protocol.md - FCMP implementation guide"
  - "Load COMPLETE file {project-root}/_bmad/rzlv-flow/core/sync-instructions/jira-file-structure.md - Jira folder structure and ownership"
  # Note: Ace does NOT load confluence-file-structure.md - only Atlas manages Confluence
  - "Load COMPLETE file {project-root}/_bmad/rzlv-flow/core/suite-structure.yaml for naming conventions"
  - "ALWAYS present options as numbered lists for user selection"
```

---

## File Location Reference

### Development Time (Module Source)
```
_bmad-output/bmb-creations/rzlv-flow/
├── agents/
│   ├── atlassian-orchestrator/atlassian-orchestrator.agent.yaml
│   └── agile-companion/agile-companion.agent.yaml
├── core/
│   ├── suite-structure.yaml
│   ├── sync-aware-agent-pattern.md       # This document
│   └── sync-instructions/
│       ├── atlassian-sync-protocol.md    # FCMP protocol details
│       ├── jira-file-structure.md        # Jira folder structure & ownership
│       └── confluence-file-structure.md  # Confluence folder structure & leaf bundle
└── sidecar-templates/
    ├── atlassian-orchestrator-sidecar/
    └── agile-companion-sidecar/
```

### Runtime (After Installation)
```
_bmad/
├── rzlv-flow/
│   ├── agents/                            # Compiled agents
│   └── core/
│       ├── suite-structure.yaml
│       └── sync-instructions/
│           ├── atlassian-sync-protocol.md
│           ├── jira-file-structure.md
│           └── confluence-file-structure.md
└── _memory/
    ├── atlassian-orchestrator-sidecar/    # Atlas's persistent state
    └── agile-companion-sidecar/           # Ace's persistent state
```

---

## Validation Checklist

When creating or reviewing a sync-aware agent, verify:

- [ ] **Principles** include FCMP core rule
- [ ] **Principles** include sync status values
- [ ] **Principles** specify folder ownership (what I own, what I don't touch)
- [ ] **Principles** include sibling coordination
- [ ] **Critical Actions** load sidecar files explicitly
- [ ] **Critical Actions** load atlassian-sync-protocol.md
- [ ] **Critical Actions** load jira-file-structure.md
- [ ] **Critical Actions** load confluence-file-structure.md (Atlas only)
- [ ] **Critical Actions** load suite-structure.yaml
- [ ] **Prompts** reference FCMP where sync operations occur

---

## Pattern Evolution

This pattern may evolve as RZLV Flow matures. Updates should be made to:
1. This document (pattern definition)
2. Both agent files (if principles change)
3. Sync instruction files (if protocol changes)

The hybrid approach ensures core rules are never accidentally removed while allowing implementation details to evolve.

---

*This pattern was established during BMB migration Step 6 (Agent Creation) to ensure consistent sync behavior across RZLV Flow agents.*
