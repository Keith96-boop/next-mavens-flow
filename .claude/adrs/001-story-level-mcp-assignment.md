# ADR-001: Story-Level MCP Tool Assignment

**Status:** Accepted

**Date:** 2025-01-11

## Context

When implementing Maven Flow, we faced a critical decision about how to assign MCP (Model Context Protocol) tools to specialist agents:

**Problem:**
- If MCP tools are assigned at the PRD level, all stories inherit the same tools
- As context grows large during flow execution, agents may "forget" which tools are available
- Agents may hallucinate tool availability or use inappropriate tools
- Lack of granular control leads to confusion and errors

**Observed Issues:**
- Agents struggling to identify available tools in large contexts
- Inconsistent tool usage across stories
- Difficulty debugging which tools should be used for specific tasks

## Decision

**MCP tools are assigned PER STORY in the PRD JSON's `availableMcpTools` object, NOT at the PRD level.**

Each story specifies exactly which MCP tools each agent can use:

```json
{
  "id": "US-001",
  "title": "Add status field to tasks table",
  "mavenSteps": [1, 7],
  "availableMcpTools": {
    "development-agent": [
      { "mcp": "supabase", "tools": ["supabase_query", "supabase_exec"] }
    ]
  }
}
```

**Key Principles:**
1. **Story-level specificity**: Each story lists its exact MCP tool requirements
2. **Agent-level granularity**: Different agents may have different tools for the same story
3. **Explicit declaration**: No automatic tool discovery during execution
4. **Context isolation**: Reduces confusion as context grows

## Consequences

**Benefits:**
- **Context Isolation**: Each story has its own specific MCP tools, reducing confusion as context grows
- **Precision**: Agents know exactly which tools to use for that specific story
- **No Hallucination**: Prevents agents from "forgetting" which tools are available in large contexts
- **Granular Control**: Different stories can use different subsets of MCP tools
- **Debuggability**: Easy to see which tools are available for each story

**Trade-offs:**
- **More manual work**: PRD creators must specify tools for each story
- **Larger PRD files**: Each story includes MCP tool configuration
- **Potential for errors**: Incorrect tool specification must be caught during PRD review

## Alternatives Considered

### Alternative 1: PRD-Level MCP Assignment
**Description:** Assign MCP tools once at the PRD level, all stories inherit them.

**Rejected because:**
- Causes context overload as all stories share the same tool list
- Agents may use inappropriate tools for specific tasks
- No granular control per story

### Alternative 2: Automatic MCP Discovery
**Description:** Automatically discover available MCP tools using `claude mcp list` during flow execution.

**Rejected because:**
- Creates architecture confusion (3 competing discovery mechanisms)
- Agents may hallucinate tool availability in large contexts
- Unpredictable behavior as MCP configuration changes

### Alternative 3: Dynamic Tool Assignment
**Description:** Allow agents to dynamically request tools as needed during execution.

**Rejected because:**
- Subagents cannot spawn other subagents (Claude Code CLI limitation)
- Creates complex coordination problems
- Difficult to audit and debug

## Implementation

**PRD JSON Structure:**
```json
{
  "project": "Project Name",
  "mcpDiscovery": {
    "lastScanned": "2025-01-11T14:00:00Z",
    "configuredMCPs": { /* informational metadata */ }
  },
  "userStories": [
    {
      "id": "US-001",
      "mavenSteps": [1, 7],
      "availableMcpTools": {
        "development-agent": [
          { "mcp": "supabase", "tools": ["supabase_query"] }
        ]
      }
    }
  ]
}
```

**Flow Processing:**
1. Read story's `mavenSteps` array
2. For each step, check story's `availableMcpTools` for that agent
3. Spawn agent with ONLY the tools listed for that story
4. Agent knows exactly which MCP tools to use

## References

- `.claude/shared/mcp-tools.md` - MCP tools reference documentation
- `.claude/skills/flow-convert/SKILL.md` - PRD conversion instructions
- `.claude/commands/flow.md` - Flow command documentation
