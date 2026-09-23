---
nextStepFile: "{installed_path}/steps/step-05-report.md"
stateFile: "{project-root}/_bmad/_memory/atlassian-orchestrator-sidecar/workflow-state.yaml"
---

# Step 4: Sync to Jira

## STEP GOAL

Create Jira tickets from local structure with embedded Confluence links, following parent-first order.

## EXECUTION RULES

- ✅ Follow FCMP protocol for all operations
- ✅ Create parent tickets before children (Initiative → Epic → Story)
- ✅ Embed Confluence links in descriptions
- ✅ Store ticket keys in local metadata.yaml
- ✅ Single sync pass - tickets complete on creation
- 🚫 NEVER create orphan tickets (parent must exist first)

---

## SEQUENCE

### 4.1 Pre-Sync Check

Verify MCP availability and Confluence readiness:

```
"**Checking Jira Access...**

MCP Status: {available|unavailable}
Instance: {instance}.atlassian.net
Project: {project}

Confluence Links Ready: {yes|partial|no}
• {count} pages with IDs
• {pending_count} pages pending

[S] Start Jira sync
[L] Generate locally only
[C] Cancel"
```

### 4.2 Enrich Descriptions with Confluence Links

Before sync, update each content.md with documentation links:

```markdown
## Documentation

| Document | Link |
|----------|------|
| Architecture | [View in Confluence]({confluence_url}) |
| Requirements | [View in Confluence]({confluence_url}) |
| Epic Details | [View in Confluence]({confluence_url}) |
```

### 4.3 Sync Tickets (Parent-First)

```
"**Syncing to Jira...**

[1/16] Initiative: RZLV Flow Platform
  → FETCH: Checking if exists...
  → CREATE: New Initiative
  → KEY: PROJ-100
  ✅ Created

[2/16] Epic: User Authentication (parent: PROJ-100)
  → FETCH: Checking...
  → CREATE: New Epic
  → KEY: PROJ-101
  ✅ Created

[3/16] Story: Login Form (parent: PROJ-101)
  → FETCH: Checking...
  → CREATE: New Story
  → KEY: PROJ-102
  ✅ Created

Progress: ████░░░░░░ 3/16 tickets"
```

### 4.4 Update Local Metadata

After each successful sync:

```yaml
jira:
  type: Story
  key: "PROJ-102"
  status: draft
  project: "PROJ"
  instance: "company"
  parent_key: "PROJ-101"

sync:
  status: synced
  local_version: 1
  remote_version: 1
  last_synced: "2026-01-07T15:00:00Z"
  jira_url: "https://{instance}.atlassian.net/browse/PROJ-102"
```

### 4.5 Handle Failures

If a ticket fails:

```
"⚠️ Failed to create: {ticket_title}
Error: {error_message}
Parent: {parent_key}

[R] Retry this ticket
[S] Skip and continue (children will also skip)
[A] Abort (completed tickets preserved)"
```

On skip, mark in metadata and skip all children:
```yaml
sync:
  status: pending
  error: "{error_message}"
  skipped_reason: "parent_failed"  # For children
```

### 4.6 Link Summary

After sync, display ticket hierarchy:

```
"**Jira Hierarchy Created:**

PROJ-100: RZLV Flow Platform (Initiative)
├── PROJ-101: User Authentication (Epic)
│   ├── PROJ-102: Login Form (Story)
│   ├── PROJ-103: Password Reset (Story)
│   └── PROJ-104: OAuth Integration (Story)
├── PROJ-105: Payment Processing (Epic)
│   ├── PROJ-106: Stripe Integration (Story)
│   └── PROJ-107: Invoice Generation (Story)
└── PROJ-108: Reporting Dashboard (Epic)
    └── PROJ-109: Analytics Charts (Story)
```

### 4.7 Update State

```yaml
# Update workflow-state.yaml
current_step: "step-04-jira"
steps_completed:
  - step-01-setup
  - step-02-generate
  - step-03-confluence
  - step-04-jira

artifacts:
  jira_items_created: {count}
  jira_sync_status:
    synced: {count}
    pending: {count}
    failed: {count}
  root_ticket: "PROJ-100"
```

---

## COMPLETION CRITERIA

- [ ] All tickets attempted in parent-first order
- [ ] Ticket keys stored in local metadata
- [ ] Confluence links embedded in descriptions
- [ ] State file updated
- [ ] User selected Continue

**On Continue:** Load and execute {nextStepFile}
