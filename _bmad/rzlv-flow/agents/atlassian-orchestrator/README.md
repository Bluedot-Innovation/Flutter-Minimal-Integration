# Atlassian Orchestrator (Atlas)

> 🎯 Requirements to Jira/Confluence Orchestrator

## Overview

Atlas transforms PM-finalized Epics into structured Jira ticket hierarchies and Confluence documentation. Triggered AFTER the PM Agent completes the requirements workflow, Atlas bridges BMAD documentation with Atlassian systems.

## Agent Type

**Expert Agent** - Requires sidecar for configuration and state

## Sidecar Files

Located at `_bmad/_memory/atlassian-orchestrator-sidecar/` after installation:

| File | Purpose |
|------|---------|
| config.yaml | Atlassian instance settings |
| instructions.md | Startup protocols |
| memories.md | Session state, operation history |
| doc-type-mapping.yaml | BMAD → Confluence mapping |
| confluence-*.md | Page templates |

## Commands

| Command | Description |
|---------|-------------|
| `orchestrate` | Full workflow: BMAD docs → Jira + Confluence |
| `import` | Import existing Jira ticket structure |
| `confluence` | Create Confluence docs for existing Jira |
| `continue` | Add to existing structure |
| `correct` | Process PM corrections |
| `status` | Check sync status |

## Key Principles

- BMAD documentation is PRIMARY—never replace, only enrich
- Confluence sync BEFORE Jira (get page IDs for linking)
- Single Jira sync pass (complete tickets)
- Follow FCMP protocol for all updates
- Document ALL assumptions with confidence levels

## Integration

- **Triggered By:** PM Agent workflow completion
- **Uses:** atlassian-rovo MCP tools
- **Follows:** FCMP sync protocol

---

*Part of RZLV Flow - AI Agile Toolkit*
