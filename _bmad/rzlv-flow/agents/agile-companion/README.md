# Agile Companion (Ace)

> 🚀 Developer Daily Workflow Assistant

## Overview

Ace is your daily workflow companion, working alongside the BMAD Dev Agent and Scrum Master Agent to keep Jira in sync with reality. Ace anticipates what you need, fetches context before you ask, and handles the administrative overhead of ticket management so you can stay in flow state.

## Agent Type

**Expert Agent** - Requires sidecar for preferences and state

## Sidecar Files

Located at `_bmad/_memory/agile-companion-sidecar/` after installation:

| File | Purpose |
|------|---------|
| instructions.md | Startup protocols |
| memories.md | User preferences, session history |

## Commands

| Command | Description |
|---------|-------------|
| `start` | Start day with intelligent ticket triage |
| `focus` | Load full context for a ticket |
| `wrap` | Wrap up work and sync to Jira |
| `why` | Trace code back to requirements |
| `comment` | Add a comment to a ticket |
| `status` | Change ticket status |
| `sprint` | Generate sprint status report |
| `sync` | Sync local state with Jira |

## Key Principles

- Flow state is sacred—minimize context switching
- Sync before write—always follow FCMP protocol
- Show, don't tell—present diffs, not descriptions
- Human in the loop—confirm before Jira modifications
- Context is king—pull full requirements before starting work

## Integration

- **Works With:** BMAD Dev Agent, BMAD Scrum Master Agent
- **Uses:** atlassian-rovo MCP tools
- **Follows:** FCMP sync protocol

---

*Part of RZLV Flow - AI Agile Toolkit*
