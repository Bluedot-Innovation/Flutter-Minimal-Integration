# Confluence File Structure - Local Documentation Pattern

**Version:** 1.0.0  
**Applies To:** Atlassian Orchestrator (Atlas)  
**Pattern:** Leaf Bundle Structure with FCMP Sync  
**Source of Truth:** `core/suite-structure.yaml` (confluence section)

---

## Overview

This document defines the **local file structure** for Confluence documentation managed by RZLV Flow agents. All Confluence pages are stored locally as Markdown files following a consistent pattern, then synced to Confluence via MCP tools.

**Key Principle:** Every Confluence page is a **directory** containing an `index.md` file (Leaf Bundle pattern). This enables easy hierarchy expansion without restructuring.

---

## Directory Structure

```
docs/confluence/{atlassian_instance}/{space}/
│
├── {initiative-name}/                    # Initiative root page
│   ├── index.md                          # Initiative Overview page
│   │
│   ├── strategic-context/
│   │   └── index.md                      # Business goals and product vision
│   │
│   ├── technical-architecture/
│   │   └── index.md                      # System design and tech decisions
│   │
│   ├── decisions/
│   │   └── index.md                      # Consolidated decision logs
│   │
│   ├── research-and-findings/
│   │   └── index.md                      # User research and discoveries
│   │
│   ├── assumptions/
│   │   └── index.md                      # Assumptions with confidence levels
│   │
│   └── implementation-guidance/
│       └── index.md                      # High-value technical guides
│
└── {another-initiative}/
    └── ...
```

---

## Leaf Bundle Pattern

### Why Folders, Not Files?

**DO NOT create:**
```
docs/confluence/company/DOCS/strategic-context.md  ❌ WRONG
```

**DO create:**
```
docs/confluence/company/DOCS/strategic-context/index.md  ✅ CORRECT
```

**Rationale:**
- Child pages can be added later without restructuring
- Consistent pattern for all page types
- Matches Confluence's hierarchical structure
- Assets (images, attachments) stay with their page

---

## Metadata Format (YAML Frontmatter)

Every `index.md` MUST include this frontmatter:

```yaml
---
# Confluence Sync State
confluence_page_id: null           # Populated after first sync
confluence_space_key: "SPACEKEY"   # Target Confluence space
confluence_title: "Page Title"     # Exact title in Confluence
confluence_url: null               # Populated after first sync
parent_page_id: null               # Parent page ID (null for root)

# Sync Metadata
sync_status: "draft"               # draft | synced | modified | pending_sync | conflict
last_synced: null                  # ISO timestamp of last sync
version: 0                         # Optimistic locking version

# BMAD Integration
jira_initiative_key: "PROJ-100"    # Related Jira initiative/epic
bmad_docs_referenced:              # Source BMAD docs used
  - "docs/prd/index.md"
  - "docs/architecture/system-design.md"
---

# {Page Title}

{Page content in Markdown}
```

### Metadata After Sync

After successful Confluence sync, the frontmatter is updated:

```yaml
---
confluence_page_id: "123456789"
confluence_space_key: "DOCS"
confluence_title: "Strategic Context"
confluence_url: "https://company.atlassian.net/wiki/spaces/DOCS/pages/123456789"
parent_page_id: "987654321"

sync_status: "synced"
last_synced: "2026-01-07T14:30:00Z"
version: 1
---
```

---

## Link Conventions

### Internal Confluence Links

Use Confluence Web UI path format:

```markdown
[Page Title](/wiki/display/SPACEKEY/Page+Title)
```

**Rules:**
- Replace spaces with `+`
- Remove special characters like `&`
- Do NOT use relative file paths (`./folder/file.md`)
- Do NOT use ID-based URLs in content

**Examples:**
```markdown
[Strategic Context](/wiki/display/DOCS/Strategic+Context)
[Technical Architecture](/wiki/display/DOCS/Technical+Architecture)
[Agile Practices Guide](/wiki/display/DOCS/Agile+Practices+Guide)
```

### Jira Ticket Links

Link to related Jira tickets:

```markdown
[PROJ-123: Ticket Title](https://{instance}.atlassian.net/browse/PROJ-123)
```

### External Links

Standard markdown:

```markdown
[BMAD Documentation](https://github.com/...)
```

---

## Sync Status Values

| Status | Meaning | Next Action |
|--------|---------|-------------|
| `draft` | Created locally, never synced | Create page in Confluence |
| `synced` | Local matches Confluence | No action unless modified |
| `modified` | Local changes since last sync | FCMP required before push |
| `pending_sync` | Ready to sync, awaiting connection | Push when ready |
| `sync_failed` | Sync attempt failed | Review error, retry |
| `conflict` | Both local and remote changed | Manual merge required |

---

## Page Ownership

| Path Pattern | Owner | Operations |
|--------------|-------|------------|
| `docs/confluence/**/*.md` | Atlas (Orchestrator) | Create, Update, Sync (bulk) |
| Page metadata updates | Atlas (Orchestrator) | After each sync |
| Page content from BMAD | Atlas (Orchestrator) | Generate from _docs/ |
| Working documents | Ace (Agile Companion) | Publish from _work/, Fetch single pages |

### Agent Responsibilities

**Atlas (Atlassian Orchestrator):**
- Bulk Confluence sync (epic → full page hierarchy)
- Generate pages from BMAD docs (_docs/ folders)
- Maintain page structure and navigation

**Ace (Agile Companion):**
- Publish individual working documents (implementation guides, notes)
- Fetch/download specific pages for local reference
- Link Confluence pages to Jira tickets
- Search Confluence for existing documentation

**Both agents MUST:**
- Follow FCMP protocol for all operations
- Use Leaf Bundle pattern (folder/index.md)
- Update frontmatter metadata after sync
- Never blind-write to Confluence

---

## FCMP Protocol for Confluence

Before updating any Confluence page:

### 1. FETCH
```
1. Read local index.md, extract confluence_page_id and version
2. Fetch current page from Confluence via MCP
3. Store remote state for comparison
```

### 2. COMPARE
```
1. Compare local content vs remote content
2. Compare local.version vs remote.version
3. If remote is newer: CONFLICT DETECTED → proceed to MERGE
```

### 3. MERGE
```
If conflict detected:
1. Show user side-by-side diff
2. Present options: Keep Local | Keep Remote | Manual Merge
3. User decides resolution
4. Update local file with merged content
```

### 4. PUSH
```
1. Update Confluence page via MCP
2. On success: Update local frontmatter with new version, sync timestamp
3. On conflict (409): Re-run FCMP from FETCH
```

---

## Content Organization Rules

### Source Priority

1. **BMAD Documents First** - PRD, Architecture, domain docs (primary)
2. **Agent Enrichment Below** - Generated context from `_docs/` folders
3. **Manual Additions** - User edits (preserve, don't overwrite)

### Smart Filtering

**DO include:**
- Substantial technical guides
- Decision logs with context
- Validated assumptions
- User research findings

**DO NOT include:**
- Every `_docs/` file verbatim
- Temporary notes
- Work-in-progress content
- Implementation minutiae

---

## Integration with Jira Structure

Confluence pages link back to Jira tickets:

```
docs/jira/{instance}/{project}/          # Jira ticket structure
    epic-name/
        _docs/                           # Source for Confluence pages
            technical-architecture.md    → Confluence: Technical Architecture
            decisions.md                 → Confluence: Decisions
            assumptions-log.md           → Confluence: Assumptions

docs/confluence/{instance}/{space}/      # Confluence page structure
    epic-name/
        technical-architecture/index.md  # Generated from _docs/
        decisions/index.md               # Generated from _docs/
        assumptions/index.md             # Generated from _docs/
```

**Sync Order (Critical):**
1. Create Confluence pages first
2. Store `confluence_page_id` in local files
3. Add Confluence links to Jira ticket descriptions
4. Sync Jira tickets with links

---

## Best Practices

1. **Leaf Bundles Always** - Every page is a folder with `index.md`
2. **Metadata Immediately** - Update frontmatter right after sync
3. **Link Format Strict** - Use `/wiki/display/SPACE/Title` format only
4. **Version Control** - Commit after confirmed changes
5. **FCMP Always** - Never blind-write to Confluence
6. **Navigation Focus** - Include cross-references and breadcrumbs
7. **Keep Updated** - Re-sync when source BMAD docs change

---

## Quick Reference

```
┌─────────────────────────────────────────────────────────────┐
│                CONFLUENCE FILE STRUCTURE                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Location:     docs/confluence/{instance}/{space}/          │
│                                                             │
│  Pattern:      Leaf Bundle (folder/index.md)                │
│                                                             │
│  Metadata:     YAML frontmatter with confluence_*           │
│                                                             │
│  Links:        /wiki/display/SPACE/Page+Title               │
│                                                             │
│  Sync:         FCMP protocol (Fetch-Compare-Merge-Push)     │
│                                                             │
│  Owner:        Atlas (Atlassian Orchestrator) only          │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│  ⚠️  NEVER create standalone .md files                      │
│  ⚠️  ALWAYS update metadata after sync                      │
│  ⚠️  ALWAYS use /wiki/display/ link format                  │
│  ✓  Create Confluence BEFORE Jira (get page IDs)            │
│  ✓  Commit after each confirmed sync                        │
└─────────────────────────────────────────────────────────────┘
```

---

*This document ensures consistent local Confluence file management across RZLV Flow agents.*
