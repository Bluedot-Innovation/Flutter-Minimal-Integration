---
nextStepFile: "{installed_path}/steps/step-03-confluence.md"
stateFile: "{project-root}/_bmad/_memory/atlassian-orchestrator-sidecar/workflow-state.yaml"
---

# Step 2: Generate Structure

## STEP GOAL

Create local folder structure for Jira tickets and Confluence pages based on loaded BMAD documentation.

## EXECUTION RULES

- ✅ Follow Jira file structure from core/sync-instructions/jira-file-structure.md
- ✅ Follow Confluence structure from core/sync-instructions/confluence-file-structure.md
- ✅ Use leaf bundle pattern (content.md + metadata.yaml per item)
- ✅ Generate _docs/ folders with source context
- 🚫 NEVER create tickets/pages yet - only local files

---

## SEQUENCE

### 2.1 Parse Source Structure

From epics.md (or inferred from PRD):

```
"**Parsing BMAD Documentation...**

Detected hierarchy:
• Initiative: {initiative_title or 'None - starting at Epic level'}
• Epics: {epic_count}
• Stories: {story_count}
• Tasks: {task_count}

Scope level: {highest_level} → {lowest_level}"
```

### 2.2 Generate Jira Folder Structure

Create local structure following jira-file-structure.md:

```
docs/jira/{instance}/{project}/
├── _project.md                    # Project-level context
├── {initiative-slug}/             # If initiative exists
│   ├── content.md                 # Initiative description
│   ├── metadata.yaml              # Jira fields, sync status
│   ├── _docs/                     # PM context (Atlas owns)
│   │   └── source-context.md      # Traceability to BMAD docs
│   └── epics/
│       └── {epic-slug}/
│           ├── content.md
│           ├── metadata.yaml
│           ├── _docs/
│           └── stories/
│               └── {story-slug}/
│                   ├── content.md
│                   ├── metadata.yaml
│                   └── _work/     # Dev notes (Ace owns)
```

Report progress:

```
"**Generating Jira Structure...**

Created:
• 1 Initiative folder
• 3 Epic folders
• 12 Story folders

Each item has:
• content.md - Description, AC, context
• metadata.yaml - Jira fields, sync status
• _docs/ - Traceability to source BMAD docs

[V] View generated structure
[C] Continue to Confluence structure"
```

### 2.3 Generate Confluence Structure

Create local structure following confluence-file-structure.md:

```
docs/confluence/{instance}/{space}/
├── _space.md                      # Space-level config
├── {project-name}/                # Project parent page
│   ├── content.md                 # Project overview
│   ├── metadata.yaml              # Page ID, sync status
│   ├── architecture/
│   │   └── content.md             # From architecture.md
│   ├── requirements/
│   │   └── content.md             # From prd.md
│   └── epics/
│       └── {epic-name}/
│           ├── content.md         # Epic details
│           └── stories.md         # Story summaries for this epic
```

Report:

```
"**Generating Confluence Structure...**

Created:
• 1 Project overview page
• 1 Architecture page
• 1 Requirements page
• 3 Epic detail pages
• 3 Story summary pages

Total: {page_count} pages ready for sync

[V] View page structure
[C] Continue to Confluence sync"
```

### 2.4 Generate Content Files

For each Jira item, create content.md with:

```markdown
# {Title}

## Description
{Description from BMAD source}

## Acceptance Criteria
{BDD format from epics.md or generated from PRD}

## Technical Notes
{From architecture.md if relevant}

## Documentation
<!-- Confluence links will be added after sync -->

---
*Generated from: {source_doc_path}*
*Traceability: {link_to_bmad_doc}*
```

For each metadata.yaml:

```yaml
jira:
  type: "{Epic|Story|Task}"
  key: null  # Populated after sync
  status: draft
  project: "{project}"
  instance: "{instance}"
  parent_key: null

sync:
  status: pending  # pending | synced | modified | conflict
  local_version: 1
  remote_version: null
  last_synced: null
  confluence_page_id: null

traceability:
  source_file: "{bmad_doc_path}"
  source_section: "{section_heading}"
  generated_at: "{timestamp}"
  generated_by: atlassian-orchestrator
```

### 2.5 Update State

```yaml
# Update workflow-state.yaml
current_step: "step-02-generate"
steps_completed:
  - step-01-setup
  - step-02-generate
  
artifacts:
  jira_items_created: 0
  confluence_pages_created: 0
  local_files_generated:
    - "docs/jira/{instance}/{project}/..."
    - "docs/confluence/{instance}/{space}/..."
```

---

## COMPLETION CRITERIA

- [ ] Jira folder structure created
- [ ] Confluence folder structure created
- [ ] All content.md files populated
- [ ] All metadata.yaml files initialized
- [ ] _docs/ folders with source context
- [ ] State file updated
- [ ] User selected Continue

**On Continue:** Load and execute {nextStepFile}
