/**
 * BMAD Post-Install Hook for RZLV Flow
 * 
 * This installer is called by BMAD after the module files are copied.
 * It handles RZLV Flow-specific setup that BMAD doesn't do automatically.
 * 
 * @param {Object} options - Options provided by BMAD
 * @param {string} options.projectRoot - Root directory of the project
 * @param {Object} options.config - Module configuration from BMAD
 * @param {string[]} options.installedIDEs - List of IDEs being installed for
 * @param {Object} options.logger - BMAD logger instance
 */
async function install(options) {
  const { projectRoot, config = {}, installedIDEs = [], logger } = options;
  
  // Create a safe logger that handles missing methods gracefully
  const fallbackLog = {
    info: msg => console.log(`ℹ ${msg}`),
    success: msg => console.log(`✓ ${msg}`),
    warn: msg => console.log(`⚠ ${msg}`),
    error: msg => console.log(`✗ ${msg}`)
  };
  
  const log = {
    info: (logger && typeof logger.info === 'function') ? logger.info.bind(logger) : fallbackLog.info,
    success: (logger && typeof logger.success === 'function') ? logger.success.bind(logger) : fallbackLog.success,
    warn: (logger && typeof logger.warn === 'function') ? logger.warn.bind(logger) : fallbackLog.warn,
    error: (logger && typeof logger.error === 'function') ? logger.error.bind(logger) : fallbackLog.error
  };
  
  log.info('RZLV Flow post-install hook running...');
  
  // Check IDE compatibility - MCP only works with VS Code-based editors
  const supportedIDEs = ['vscode', 'cursor', 'windsurf'];
  const hasVSCodeIDE = installedIDEs.some(ide => supportedIDEs.includes(ide.toLowerCase()));
  
  // Skip MCP checks for non-VS Code IDEs
  if (!hasVSCodeIDE && installedIDEs.length > 0) {
    log.info('Non-VS Code IDE detected - skipping MCP server checks');
    log.info('MCP servers are only available for VS Code, Cursor, and Windsurf');
    return {
      success: true,
      mcp_servers: { atlassian: null, github: null },
      warnings: [],
      skipped_mcp: true
    };
  }
  
  // Check if MCP servers are configured (only for VS Code-based IDEs)
  const fs = require('fs');
  const path = require('path');
  
  // Detect WSL2 environment
  function isWSL() {
    return process.platform === 'linux' && (
      (process.env.WSL_DISTRO_NAME) ||
      (process.env.WSLENV) ||
      (fs.existsSync('/proc/version') && 
       fs.readFileSync('/proc/version', 'utf-8').toLowerCase().includes('microsoft'))
    );
  }
  
  function getMcpConfigPath() {
    const homeDir = process.env.HOME || process.env.USERPROFILE;
    if (process.platform === 'darwin') {
      return path.join(homeDir, 'Library', 'Application Support', 'Code', 'User', 'mcp.json');
    } else if (process.platform === 'win32') {
      return path.join(homeDir, 'AppData', 'Roaming', 'Code', 'User', 'mcp.json');
    } else {
      // Linux and WSL2: VS Code reads from ~/.config/Code/User/mcp.json
      // NOT from ~/.config/GitHub Copilot/mcp.json
      return path.join(homeDir, '.config', 'Code', 'User', 'mcp.json');
    }
  }
  
  if (isWSL()) {
    log.info('WSL2 environment detected');
  }
  
  function findMcpServer(config, pattern) {
    if (!config.servers) return null;
    for (const [name, serverConfig] of Object.entries(config.servers)) {
      if (serverConfig.args && Array.isArray(serverConfig.args)) {
        if (serverConfig.args.some(arg => arg.includes(pattern))) {
          return name;
        }
      }
    }
    return null;
  }
  
  // Platform warning for Windows
  if (process.platform === 'win32') {
    log.info('Windows detected - MCP support is experimental');
  }
  
  const mcpPath = getMcpConfigPath();
  let mcpConfig = { servers: {} };
  
  try {
    if (fs.existsSync(mcpPath)) {
      mcpConfig = JSON.parse(fs.readFileSync(mcpPath, 'utf-8'));
    }
  } catch (e) {
    // Silently handle - MCP config may not exist
  }
  
  const atlassianServer = findMcpServer(mcpConfig, 'mcp.atlassian.com');
  const githubServer = findMcpServer(mcpConfig, 'server-github');
  
  // Only show info, not warnings - MCP is optional
  const notes = [];
  
  if (!atlassianServer) {
    notes.push('Atlassian MCP not configured (optional for Jira/Confluence integration)');
  }
  
  if (notes.length > 0) {
    log.info('MCP servers are optional. To configure later:');
    log.info('  Run: npx @groupby/rzlv-flow install');
  } else {
    log.success('RZLV Flow MCP servers configured');
  }
  
  // Report detected MCP servers (info only, not warnings)
  if (atlassianServer || githubServer) {
    log.info('Detected MCP Servers:');
    if (atlassianServer) log.info(`  Atlassian: ${atlassianServer}`);
    if (githubServer) log.info(`  GitHub: ${githubServer}`);
  }
  
  // Return configuration for BMAD
  return {
    success: true,
    mcp_servers: {
      atlassian: atlassianServer,
      github: githubServer
    },
    warnings: []  // No warnings - MCP is optional
  };
}

module.exports = { install };
