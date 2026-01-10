#!/usr/bin/env node
/**
 * Pre-Task Hook: Validates PRD files exist before spawning Maven Flow specialist agents
 *
 * This hook runs before Task tool calls to Maven Flow specialist agents.
 * It validates when spawning:
 * - development-agent
 * - refactor-agent
 * - quality-agent
 * - security-agent
 * - prd-update (requires PRD files exist)
 *
 * Usage: Called by Claude Code via PreToolUse hook in flow.md
 */

const fs = require('fs');
const path = require('path');

// Maven Flow specialist agent types that require PRD validation
const MAVEN_FLOW_AGENTS = [
  'development-agent',
  'refactor-agent',
  'quality-agent',
  'security-agent',
  'prd-update',
  // Legacy name for backward compatibility
  'flow-iteration'
];

function main() {
  try {
    // Parse TOOL_INPUT environment variable
    const toolInput = process.env.TOOL_INPUT || '{}';
    let input;

    try {
      input = JSON.parse(toolInput);
    } catch (parseError) {
      // TOOL_INPUT is not valid JSON, exit silently
      process.exit(0);
    }

    // Only validate Maven Flow agent spawns
    if (!input.subagent_type || !MAVEN_FLOW_AGENTS.includes(input.subagent_type)) {
      process.exit(0);
    }

    // Get working directory from Claude or use current directory
    const workingDir = process.cwd();

    // Check if docs/ directory exists
    const docsDir = path.join(workingDir, 'docs');
    if (!fs.existsSync(docsDir)) {
      console.error('Error: No docs/ directory found. Create a PRD first using the flow-prd skill.');
      process.exit(3); // Exit code 3 tells Claude to block the tool
    }

    // Check if any PRD files exist
    const prdFiles = fs.readdirSync(docsDir)
      .filter(f => f.startsWith('prd-') && f.endsWith('.json'));

    if (prdFiles.length === 0) {
      console.error('Error: No PRD files found in docs/. Create a PRD first using the flow-prd skill.');
      process.exit(3); // Exit code 3 tells Claude to block the tool
    }

    // Validation passed
    process.exit(0);

  } catch (error) {
    // Log error but don't block execution
    // This prevents the hook from breaking the flow if something unexpected happens
    if (process.env.DEBUG) {
      console.error('Hook error:', error.message);
    }
    process.exit(0);
  }
}

main();
