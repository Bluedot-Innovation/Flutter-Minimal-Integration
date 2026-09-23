# RZLV Flow Installer

This folder contains installation components for the RZLV Flow module.

## Files

| File | Purpose |
|------|---------|
| `installer.js` | BMAD post-install hook (called after module copy) |

## Installation Methods

### 1. Standalone (Recommended)

```bash
npx @groupby/rzlv-flow install
```

This runs [scripts/install.js](../scripts/install.js) which:

1. **MCP Setup** - Configures Atlassian & GitHub MCP servers
2. **Configuration** - Collects Jira project, Confluence space
3. **Module Copy** - Installs to `_bmad-output/bmb-creations/rzlv-flow/`
4. **Activation Files** - Optionally creates `.github/agents/` files
5. **BMAD Trigger** - Optionally runs BMAD installer

### 2. Via BMAD

```bash
npx bmad-method@alpha install
# Select "RZLV Flow" when prompted
```

BMAD handles file copying and calls `installer.js` as a post-install hook.

## Post-Install Hook

The `installer.js` is a BMAD module installer hook with signature:

```javascript
async function install(options) {
  const { projectRoot, config, installedIDEs, logger } = options;
  // Validate MCP servers, report configuration status
  return { success: true, warnings: [] };
}
```

It validates MCP configuration and reports any missing setup.

---

*Part of RZLV Flow - AI Agile Toolkit*
