---
name: atlassian-sync
description: "Transform BMAD documentation into Jira/Confluence structure with full traceability"
agent: atlassian-orchestrator
installed_path: "{project-root}/_bmad/rzlv-flow/workflows/atlassian-sync"
state_file: "{project-root}/_bmad/_memory/atlassian-orchestrator-sidecar/workflow-state.yaml"
---

# Atlassian Sync Workflow

**Goal:** To transform BMAD documentation (PRD, Architecture, Epics) into structured Jira ticket hierarchies and Confluence documentation with full bidirectional sync capability.

**Agent:** Atlas (Atlassian Orchestrator) drives this workflow. The workflow provides structure and state; Atlas provides intelligence and execution.

## WORKFLOW ARCHITECTURE

### Core Principles

- **Agent-Driven**: Atlas orchestrates, workflow provides resumable structure
- **State Persistence**: Progress saved to workflow-state.yaml for resume
- **Graceful Degradation**: MCP failures don't block local generation
- **FCMP Protocol**: All sync operations follow Fetch-Compare-Merge-Push

### Step Processing Rules

1. **CHECK STATE**: Load workflow-state.yaml if exists
2. **OFFER RESUME**: If in-progress, ask to continue or restart
3. **EXECUTE STEP**: Run current step to completion
4. **SAVE STATE**: Update workflow-state.yaml before next step
5. **HANDLE ERRORS**: On failure, save state and allow retry

---

## INITIALIZATION SEQUENCE

### 1. Check for Existing State

```yaml
# If workflow-state.yaml exists and workflow != "completed":
"I found an in-progress Atlassian Sync workflow.

Current state:
• Step: {current_step}
• Mode: {context.mode}
• Target: {context.jira_instance}/{context.jira_project}

[C] Continue from where we left off
[R] Restart fresh
[V] View current state details"
```

### 2. Fresh Start (No State or Restart)

Load and execute {installed_path}/steps/step-01-setup.md

---

## STEP SEQUENCE

| Step | File | Purpose |
|------|------|---------|
| 1 | step-01-setup.md | Detect mode, confirm targets, load BMAD docs |
| 2 | step-02-generate.md | Create local folder structure |
| 3 | step-03-confluence.md | Sync to Confluence (get page IDs) |
| 4 | step-04-jira.md | Sync to Jira with Confluence links |
| 5 | step-05-report.md | Summary and validation |

---

## STATE FILE SCHEMA

```yaml
# workflow-state.yaml
workflow: atlassian-sync
version: "1.0"
started: "{iso_timestamp}"
last_updated: "{iso_timestamp}"
current_step: "step-01-setup"
status: "in-progress"  # in-progress | completed | failed

steps_completed: []

context:
  mode: null          # NEW | IMPORT | CONTINUE | SYNC_CONFLUENCE
  jira_instance: null
  jira_project: null
  confluence_space: null
  confluence_parent: null
  source_docs: []
  
artifacts:
  jira_items_created: 0
  confluence_pages_created: 0
  local_files_generated: []
  
errors: []
```

---

## ENTRY POINTS

### 1. Post-Workflow Hook (Automatic)

After `*create-epics-and-stories` completes, user is prompted to activate Atlas.
See: post-workflow-hook.yaml

### 2. Manual Activation

```
@atlas orchestrate
```

### 3. Resume

```
@atlas orchestrate
# Atlas checks for workflow-state.yaml and offers to continue
```

---

## ERROR HANDLING

### MCP Failure
- Save state with error details
- Continue with local generation
- Mark items as "pending-sync"
- User can retry sync later with `@atlas sync`

### Validation Failure
- Report specific issues
- Allow user to fix and continue
- Don't roll back completed work

### User Abort
- Save current state
- All local files preserved
- Resume anytime with `@atlas orchestrate`
