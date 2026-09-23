---
nextStepFile: "{installed_path}/steps/step-02-generate.md"
stateFile: "{project-root}/_bmad/_memory/atlassian-orchestrator-sidecar/workflow-state.yaml"
---

# Step 1: Setup

## STEP GOAL

Detect entry mode, confirm Atlassian targets, and load all available BMAD documentation.

## EXECUTION RULES

- ✅ Detect mode automatically based on context
- ✅ Confirm targets before any operations
- ✅ Load ALL available BMAD docs
- ✅ Save state before proceeding
- 🚫 NEVER proceed without target confirmation

---

## SEQUENCE

### 1.1 Detect Entry Mode

Analyze the current context to determine mode:

| Condition | Mode | Action |
|-----------|------|--------|
| Fresh BMAD docs, no local Jira structure | **NEW** | Full creation |
| User provides Jira key (e.g., "PROJ-123") | **IMPORT** | Fetch and create local |
| Already in docs/jira/{instance}/{project}/ folder | **CONTINUE** | Add to existing |
| Local Jira structure exists, no Confluence | **SYNC_CONFLUENCE** | Create docs only |

```
"I've analyzed your context.

**Detected Mode:** {mode}
**Reason:** {detection_reason}

Is this correct?
[Y] Yes, proceed
[N] No, I want a different mode"
```

### 1.2 Confirm Atlassian Targets

Present current configuration:

```
"**Atlassian Targets:**

• Jira Instance: {instance}.atlassian.net
• Jira Project: {project}
• Confluence Space: {space}
• Confluence Parent Page: {parent_page_id or 'Root'}

[1] Proceed with these targets
[2] Change Jira target
[3] Change Confluence target
[4] Change both
[C] Cancel workflow"
```

If user selects 2, 3, or 4: Prompt for new values and re-confirm.

### 1.3 Load BMAD Documentation

Scan for and load available docs:

```yaml
scan_paths:
  - "{bmad_output}/*product*brief*.md"
  - "{bmad_output}/*prd*.md"
  - "{bmad_output}/*architecture*.md"
  - "{bmad_output}/*ux*.md"
  - "{bmad_output}/*epics*.md"
```

Report what was found:

```
"**BMAD Documentation Loaded:**

✅ epics.md (PRIMARY - contains Epic/Story structure)
✅ prd.md (Requirements and acceptance criteria)
✅ architecture.md (Technical context)
⚠️ ux.md (Not found - will skip UX linking)

**Ready to generate structure from:**
• 3 Epics
• 12 Stories
• 24 Acceptance Criteria items

[C] Continue to structure generation
[A] Add more source documents
[V] View loaded content summary"
```

### 1.4 Save State

Before proceeding, write initial state:

```yaml
# workflow-state.yaml
workflow: atlassian-sync
version: "1.0"
started: "{now_iso}"
last_updated: "{now_iso}"
current_step: "step-01-setup"
status: "in-progress"

steps_completed:
  - step-01-setup

context:
  mode: "{detected_mode}"
  jira_instance: "{instance}"
  jira_project: "{project}"
  confluence_space: "{space}"
  confluence_parent: "{parent_id}"
  source_docs:
    - "{list of loaded docs}"

artifacts:
  jira_items_created: 0
  confluence_pages_created: 0
  local_files_generated: []

errors: []
```

---

## COMPLETION CRITERIA

- [ ] Mode detected and confirmed
- [ ] Atlassian targets confirmed
- [ ] BMAD docs loaded and summarized
- [ ] State file created/updated
- [ ] User selected Continue

**On Continue:** Load and execute {nextStepFile}
