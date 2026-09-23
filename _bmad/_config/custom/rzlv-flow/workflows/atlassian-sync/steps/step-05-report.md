---
stateFile: "{project-root}/_bmad/_memory/atlassian-orchestrator-sidecar/workflow-state.yaml"
---

# Step 5: Report

## STEP GOAL

Provide comprehensive summary of what was created, highlight items needing attention, and mark workflow complete.

## EXECUTION RULES

- ✅ Show counts and links
- ✅ Highlight assumptions that need validation
- ✅ List any pending/failed items
- ✅ Mark workflow complete in state file
- ✅ Provide next steps guidance

---

## SEQUENCE

### 5.1 Generate Summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    ATLASSIAN SYNC COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Jira Tickets:**
• Created: {jira_created}
• Updated: {jira_updated}
• Pending: {jira_pending}
• Failed: {jira_failed}

**Confluence Pages:**
• Created: {confluence_created}
• Updated: {confluence_updated}
• Pending: {confluence_pending}
• Failed: {confluence_failed}

**Root Items:**
• Jira: {root_ticket_key} - {root_ticket_url}
• Confluence: {root_page_title} - {root_page_url}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 5.2 Highlight Assumptions

If any assumptions were made during generation:

```
"**⚠️ Assumptions Made (Please Validate):**

1. **Story Scope** (Confidence: 75%)
   - Assumed "OAuth Integration" includes both Google and GitHub
   - Source: PRD section 3.2 was ambiguous
   - Ticket: PROJ-104

2. **Priority Assignment** (Confidence: 60%)
   - Assigned "High" to authentication stories
   - Rationale: Security-related typically high priority
   - Tickets: PROJ-101, PROJ-102, PROJ-103

3. **Sprint Assignment** (Confidence: 50%)
   - Left unassigned (no sprint context in BMAD docs)
   - Action: Assign during sprint planning

**To update assumptions:**
@atlas correct [ticket-key] [correction details]"
```

### 5.3 Pending Items

If any items need attention:

```
"**📋 Pending Items:**

**Jira (not synced):**
• PROJ-107: Invoice Generation - MCP timeout, retry needed
• PROJ-109: Analytics Charts - Parent failed

**Confluence (not synced):**
• Reporting Dashboard page - Rate limited

**To retry:**
@atlas sync pending"
```

### 5.4 Local File Locations

```
"**📁 Local Files:**

Jira Structure:
  docs/jira/{instance}/{project}/

Confluence Structure:
  docs/confluence/{instance}/{space}/

Workflow State:
  _bmad/_memory/atlassian-orchestrator-sidecar/workflow-state.yaml

**These files are your source of truth. Edit locally, then sync.**"
```

### 5.5 Next Steps

```
"**🎯 Recommended Next Steps:**

1. **Review in Jira:** {jira_board_url}
   - Check ticket descriptions
   - Validate story breakdown
   - Assign to sprints

2. **Review in Confluence:** {confluence_space_url}
   - Check page organization
   - Add additional context
   - Share with team

3. **Daily Workflow:**
   - Use Ace (Agile Companion) for ticket management
   - @ace start-my-day for daily sync
   - @ace focus [ticket-key] to work on tickets

4. **Make Changes:**
   - Edit local files, then @atlas sync
   - Or edit in Jira/Confluence, then @atlas import"
```

### 5.6 Update State - Complete

```yaml
# Final workflow-state.yaml
workflow: atlassian-sync
version: "1.0"
started: "{start_timestamp}"
last_updated: "{now_iso}"
current_step: "step-05-report"
status: "completed"

steps_completed:
  - step-01-setup
  - step-02-generate
  - step-03-confluence
  - step-04-jira
  - step-05-report

context:
  mode: "{mode}"
  jira_instance: "{instance}"
  jira_project: "{project}"
  confluence_space: "{space}"
  
artifacts:
  jira_items_created: {count}
  confluence_pages_created: {count}
  root_jira_key: "{key}"
  root_confluence_page: "{page_id}"

summary:
  total_synced: {count}
  total_pending: {count}
  assumptions_count: {count}
  completed_at: "{now_iso}"
```

---

## COMPLETION

```
"**✅ Workflow Complete!**

Your BMAD documentation is now synced to Atlassian.

[V] View full state file
[H] Show help for ongoing management
[X] Exit"
```

**Workflow ends here.** State file preserved for reference and potential re-runs.
