# Atlassian Bi-Directional Sync Protocol

**Version:** 1.0.0  
**Applies To:** All agents in RZLV Flow  
**Pattern:** Fetch-Compare-Merge-Push (FCMP)

---

## Overview

This document defines the **standardized sync instruction patterns** that ALL agents must follow when interacting with Jira and Confluence. These are not code libraries—they are instruction patterns that agents execute during their workflows.

## Core Principle: Never Blind Write

> **CRITICAL:** Agents must NEVER write to Jira/Confluence without first fetching the current remote state. This prevents data loss from concurrent edits.

---

## The FCMP Protocol

### 1. FETCH - Get Remote State

Before any modification, fetch the current state:

```yaml
fetch_instructions:
  jira_ticket:
    - Call: mcp_atlassian-rovo_fetch(id: "ari:cloud:jira:{cloudId}:issue/{issueId}")
    - Extract: summary, description, status, comments, updated_at, version
    - Store: remote_state.jira.{ticket_key}
    
  confluence_page:
    - Call: mcp_atlassian-rovo_fetch(id: "ari:cloud:confluence:{cloudId}:page/{pageId}")
    - Extract: title, body, version, updated_at
    - Store: remote_state.confluence.{page_id}
    
  on_fetch_failure:
    - Log: "⚠️ Could not fetch remote state for {resource}"
    - Action: STOP and prompt user
    - Never: Proceed with blind write
```

### 2. COMPARE - Detect Changes

Compare local changes against fetched remote state:

```yaml
compare_instructions:
  check_for_conflicts:
    - Compare: local.updated_at vs remote.updated_at
    - Compare: local.version vs remote.version
    - If remote is newer: CONFLICT DETECTED
    
  conflict_scenarios:
    no_conflict:
      condition: "remote.version == local.last_known_version"
      action: "Proceed to PUSH"
      
    remote_changed:
      condition: "remote.version > local.last_known_version"
      action: "Proceed to MERGE"
      
    both_changed:
      condition: "local has changes AND remote has changes"
      action: "Proceed to MERGE with user confirmation"
      
  output_to_user:
    - Show: Side-by-side diff (local vs remote)
    - Highlight: Conflicting sections
    - Ask: "Remote has changed. How would you like to proceed?"
```

### 3. MERGE - Resolve Conflicts

When conflicts are detected, guide user through resolution:

```yaml
merge_instructions:
  strategies:
    auto_merge:
      when: "Changes are in different sections"
      action: "Combine both changes automatically"
      confirm: "Auto-merged changes in different sections. Review?"
      
    prefer_remote:
      when: "User selects 'Keep remote'"
      action: "Discard local changes, use remote"
      confirm: "Local changes will be discarded. Confirm?"
      
    prefer_local:
      when: "User selects 'Keep local'"
      action: "Overwrite remote with local"
      confirm: "Remote changes will be overwritten. Confirm?"
      
    manual_merge:
      when: "User selects 'Manual merge'"
      action: "Present both versions for manual editing"
      output: "Combined document for user editing"
```

### 4. PUSH - Write to Remote

Only after successful fetch-compare-merge cycle:

```yaml
push_instructions:
  pre_push_checklist:
    - Verify: fetch completed successfully
    - Verify: no unresolved conflicts
    - Verify: user confirmed changes (if required)
    
  jira_update:
    - Call: Appropriate MCP update tool
    - Include: version field for optimistic locking
    - On success: Update local.version, local.synced_at
    - On conflict (409): Re-run FETCH-COMPARE-MERGE
    
  confluence_update:
    - Call: MCP confluence update tool
    - Include: version for conflict detection
    - On success: Update local frontmatter
    - On conflict: Re-run FETCH-COMPARE-MERGE
    
  post_push:
    - Update local file: Set status to "synced"
    - Update local file: Store new version number
    - Log: "✓ Synced {resource} at {timestamp}"
```

---

## Sync Status Values

All local files tracking Atlassian resources use these status values:

| Status | Meaning | Action |
|--------|---------|--------|
| `draft` | Created locally, never synced | Full create operation needed |
| `synced` | Local matches remote | No action unless local changes |
| `modified` | Local changes since last sync | FCMP protocol required |
| `pending_sync` | Ready to sync | Push when ready |
| `sync_failed` | Attempted sync failed | Review error, retry |
| `conflict` | Both local and remote changed | Manual merge required |

---

## Quick Reference

```
┌─────────────────────────────────────────────────────────────┐
│                    FCMP PROTOCOL                            │
├─────────────────────────────────────────────────────────────┤
│  1. FETCH    →  Get current remote state                    │
│  2. COMPARE  →  Local vs Remote, detect conflicts           │
│  3. MERGE    →  Resolve any conflicts with user             │
│  4. PUSH     →  Write to remote after 1-2-3 complete        │
├─────────────────────────────────────────────────────────────┤
│  ⚠️  NEVER do blind writes                                  │
│  ⚠️  ALWAYS show diffs for updates                          │
│  ⚠️  ALWAYS preserve user's remote edits                    │
└─────────────────────────────────────────────────────────────┘
```

---

*This protocol ensures zero data loss across all RZLV Flow agents.*
