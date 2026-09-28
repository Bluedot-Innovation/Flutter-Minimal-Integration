# RZLV Flow

> AI Agile Toolkit for BMAD Method

[![npm version](https://img.shields.io/npm/v/@groupby/rzlv-flow.svg)](https://www.npmjs.com/package/@groupby/rzlv-flow)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

RZLV Flow bridges BMAD documentation workflows with Jira and Confluence. It provides:

- **Context Preservation** — Meeting discussions captured with full nuance, not just summaries
- **BMAD ↔ Atlassian Bridge** — Bidirectional sync between local docs and Jira/Confluence
- **Flow State Protection** — Developers stay focused while ticket admin happens automatically
- **Full Traceability** — Complete lineage from context → requirements → tickets

## Prerequisites

- **Node.js 18+**
- **VS Code** with GitHub Copilot extension
- **Atlassian Account** (Jira Cloud and/or Confluence)
- **BMAD Method** 6.0.0 or higher

## Installation

### Step 1: Install the Module

Run from a shared location (e.g., `~/Projects/`):

```bash
npx @groupby/rzlv-flow install
```

This will:
- Configure **Atlassian MCP** server (auto-created)
- Optionally configure **GitHub MCP** server (for PR features)
- Copy the module to `./rzlv-flow/`

### Step 2: Install BMAD in Your Project

Navigate to your project and run:

```bash
cd ~/Projects/your-app
npx bmad-method@alpha install
```

When prompted:
1. Enter the relative path to rzlv-flow (e.g., `../rzlv-flow`)
2. Select "RZLV Flow" in the module selection
3. Enter your Jira project key (e.g., `PROJ`)
4. Enter your Confluence space key (optional)

### Step 3: Reload VS Code

After installation, reload VS Code to activate the agents:
- Press `Cmd+Shift+P` → "Developer: Reload Window"

## Agents

### 🎙️ Lexa — Context Analyst

**Purpose:** Transforms meeting transcripts into structured context documents that preserve the full nuance of discussions.

**Activate:** Select `@rzlv-flow-context-analyst` in GitHub Copilot Chat

**Commands:**

| Command | Description |
|---------|-------------|
| `*analyze` | Process a meeting transcript |
| `*structure` | Extract structure from unformatted notes |
| `*help` | Show all available commands |

**Example:**

```
@rzlv-flow-context-analyst
Here's the transcript from today's planning meeting:
[paste transcript]
```

**Output:** Creates a structured context document in `docs/context/` ready for handoff to BMAD PM Agent.

---

### 🎯 Atlas — Atlassian Orchestrator

**Purpose:** Converts finalized BMAD Epics into Jira ticket hierarchies and Confluence documentation using safe FCMP (Fetch-Compare-Merge-Push) synchronization.

**Activate:** Select `@rzlv-flow-atlassian-orchestrator` in GitHub Copilot Chat

**Commands:**

| Command | Description |
|---------|-------------|
| `*sync` | Synchronize local docs with Jira/Confluence |
| `*create` | Create new tickets from Epic document |
| `*fetch` | Pull current state from Jira |
| `*diff` | Show differences between local and remote |
| `*help` | Show all available commands |

**Example:**

```
@rzlv-flow-atlassian-orchestrator
Sync this epic to Jira: docs/planning-artifacts/epic-user-auth.md
```

**Output:** Creates/updates Jira Epics, Stories, and Tasks with full traceability links.

---

### 🚀 Ace — Agile Companion

**Purpose:** Daily workflow companion for developers. Manages Jira ticket interactions while protecting your flow state.

**Activate:** Select `@rzlv-flow-agile-companion` in GitHub Copilot Chat

**Commands:**

| Command | Description |
|---------|-------------|
| `*start` | Start your day — shows assigned tickets |
| `*focus [ticket]` | Enter focus mode on a specific ticket |
| `*update [status]` | Quick status update without leaving VS Code |
| `*wrap` | End of day — summarize work, prep for tomorrow |
| `*help` | Show all available commands |

**Example:**

```
@rzlv-flow-agile-companion
*start
```

**Output:** Shows your sprint tickets, suggests priorities, helps manage transitions.

## Workflow: Atlassian Sync

The module includes a post-workflow hook that triggers after BMAD's epic creation workflow.

### Entry Points

1. **Automatic (Post-Workflow Hook):** Triggers after BMAD PM Agent completes epic creation
2. **Manual:** Invoke Atlas directly with `*sync` command

### 5-Step FCMP Process

```
1. FETCH     → Pull current state from Jira
2. COMPARE   → Diff local documents vs Jira tickets
3. REVIEW    → User confirms proposed changes
4. MERGE     → Resolve any conflicts
5. PUSH      → Apply changes to Jira
```

### Resume Capability

If interrupted, the workflow can resume from the last completed step. State is preserved in the agent sidecar.

## Configuration

After installation, configuration is stored in `_bmad/rzlv-flow/config.yaml`:

```yaml
# Atlassian Settings
jira_project: "PROJ"        # Your Jira project key
confluence_space: "DOCS"    # Your Confluence space (optional)

# Behavior Settings
behavior:
  confirm_before_sync: true    # Require confirmation before pushing
  auto_sync: false             # Auto-sync on epic creation
  default_confidence_threshold: 70
  show_diffs: true             # Show detailed diffs
```

### MCP Server Configuration

The installer configures MCP servers in VS Code's `mcp.json`:

- **atlassian-rovo** — Jira and Confluence API access
- **github** (optional) — For PR creation features

## Module Structure

```
rzlv-flow/
├── agents/
│   ├── context-analyst/           # Lexa
│   │   ├── context-analyst.agent.md
│   │   └── README.md
│   ├── atlassian-orchestrator/    # Atlas
│   │   ├── atlassian-orchestrator.agent.md
│   │   ├── prompts/
│   │   └── README.md
│   └── agile-companion/           # Ace
│       ├── agile-companion.agent.md
│       ├── prompts/
│       └── README.md
├── core/
│   ├── suite-structure.yaml       # Shared configuration
│   └── sync-instructions/         # FCMP protocol docs
├── sidecar-templates/             # Runtime state templates
├── workflows/
│   └── create-epics-and-stories/  # Post-workflow hook
├── _module-installer/             # BMAD integration
├── scripts/
│   └── install.js                 # npm installer
├── module.yaml                    # BMAD module definition
├── config.yaml                    # Configuration template
└── package.json                   # npm package
```

## Troubleshooting

### Agents not appearing in Copilot

1. Ensure BMAD installation completed successfully
2. Check `.github/agents/` contains `rzlv-flow-*.agent.md` files
3. Reload VS Code window

### MCP Connection Issues

1. Check `~/Library/Application Support/Code/User/mcp.json`
2. Verify `atlassian-rovo` server is configured
3. Re-run installer to recreate MCP configuration

### Jira Sync Failures

1. Verify your Atlassian account has API access
2. Check the Jira project key is correct
3. Use `*fetch` to test connection before sync

## Development Status

- [x] Module structure created
- [x] Installer configured
- [x] Agents implemented
- [x] Workflows implemented
- [ ] Full integration testing
- [ ] npm package published

## Contributing

To extend this module:

1. Add new agents using BMAD's `create-agent` workflow
2. Add new workflows using BMAD's `create-workflow` workflow
3. Update `module.yaml` if adding config fields
4. Test with `npm link` before publishing

## Requirements

- BMAD Method version 6.0.0 or higher
- Node.js 18+
- VS Code with GitHub Copilot
- Atlassian Cloud account

## Author

Created by **GroupBy Inc.**

## License

MIT
