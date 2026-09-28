---
nextStepFile: "{installed_path}/steps/step-04-jira.md"
stateFile: "{project-root}/_bmad/_memory/atlassian-orchestrator-sidecar/workflow-state.yaml"
---

# Step 3: Sync to Confluence

## STEP GOAL

Create Confluence pages from local structure, capturing page IDs for Jira linking.

## EXECUTION RULES

- ✅ Follow FCMP protocol for all operations
- ✅ Create parent pages before children
- ✅ Store page IDs in local metadata.yaml
- ✅ Handle MCP failures gracefully
- 🚫 NEVER proceed to Jira sync without Confluence IDs (or explicit skip)

---

## SEQUENCE

### 3.1 Pre-Sync Check

Verify MCP availability:

```
"**Checking Confluence Access...**

MCP Status: {available|unavailable}
Instance: {instance}.atlassian.net
Space: {space}
Parent Page: {parent_page_title} ({page_id})

[S] Start sync
[L] Generate locally only (skip sync)
[C] Cancel"
```

If MCP unavailable:
```
"⚠️ MCP not available. I can:

[L] Generate local Confluence structure (sync manually later)
[R] Retry connection
[C] Cancel workflow"
```

### 3.2 Sync Pages (Parent-First)

Follow FCMP protocol for each page:

```
"**Syncing to Confluence...**

[1/8] Project Overview
  → FETCH: Checking if page exists...
  → CREATE: New page created
  → ID: 123456789
  ✅ Synced

[2/8] Architecture
  → FETCH: Page exists (ID: 987654321)
  → COMPARE: Local is newer
  → MERGE: Updating content...
  → PUSH: Updated
  ✅ Synced

[3/8] Requirements
  → FETCH: Checking...
  → CREATE: New page
  → ID: 111222333
  ✅ Synced

Progress: ████████░░ 3/8 pages"
```

### 3.3 Update Local Metadata

After each successful sync, update metadata.yaml:

```yaml
sync:
  status: synced
  local_version: 1
  remote_version: 1
  last_synced: "2026-01-07T14:30:00Z"
  confluence_page_id: "123456789"
  confluence_url: "https://{instance}.atlassian.net/wiki/spaces/{space}/pages/123456789"
```

### 3.4 Handle Failures

If a page fails:

```
"⚠️ Failed to sync: {page_title}
Error: {error_message}

[R] Retry this page
[S] Skip and continue
[A] Abort sync (local files preserved)"
```

On skip, mark in metadata:
```yaml
sync:
  status: pending
  error: "{error_message}"
  last_attempt: "{timestamp}"
```

### 3.5 Prepare Confluence Links for Jira

Generate link mapping:

```yaml
# confluence-links.yaml (temporary)
links:
  - epic: "user-authentication"
    confluence_pages:
      - title: "Authentication Architecture"
        id: "123456789"
        url: "https://..."
      - title: "Auth Requirements"
        id: "234567890"
        url: "https://..."
```

Report:

```
"**Confluence Sync Complete**

✅ Synced: {success_count} pages
⚠️ Pending: {pending_count} pages
❌ Failed: {failed_count} pages

**Pages Created:**
• Project Overview: {url}
• Architecture: {url}
• Requirements: {url}
• Epic: User Authentication: {url}
• Epic: Payment Processing: {url}
• ...

These links will be embedded in Jira tickets.

[C] Continue to Jira sync
[V] View all page URLs
[R] Retry failed pages"
```

### 3.6 Update State

```yaml
# Update workflow-state.yaml
current_step: "step-03-confluence"
steps_completed:
  - step-01-setup
  - step-02-generate
  - step-03-confluence

artifacts:
  confluence_pages_created: {count}
  confluence_sync_status:
    synced: {count}
    pending: {count}
    failed: {count}
```

---

## COMPLETION CRITERIA

- [ ] All Confluence pages attempted
- [ ] Page IDs stored in local metadata
- [ ] Link mapping generated for Jira
- [ ] State file updated
- [ ] User selected Continue (or Skip)

**On Continue:** Load and execute {nextStepFile}
