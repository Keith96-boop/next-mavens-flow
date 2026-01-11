# MCP Tools Reference for Maven Flow Agents

This document provides comprehensive reference for all MCP tools available to Maven Flow specialist agents. Each agent file contains a concise summary; see this file for detailed usage instructions.

---

## 1. Supabase MCP (Database Operations)

**Available to:** development-agent, security-agent (when specified in PRD story's `availableMcpTools`)

**Use for:**
- Creating tables
- Adding columns
- Running migrations
- Querying data
- Setting up relationships
- Verifying RLS (Row Level Security) policies
- Checking database permissions

**How to use:**
- Use the Supabase MCP tools directly from your available tool set
- Look for tools with `supabase` prefix or database-related names
- **Do NOT** write custom fetch() calls or use the Supabase REST API directly
- The exact tool names may vary - use what's available in your tool set

**Before using Supabase MCP:**
1. **CONFIRM the Supabase project ID** - Check environment files, config files
2. **NEVER assume** - Always verify the project ID before operations
3. **Common locations:** `.env.local`, `.env`, `supabase/config.toml`, `src/lib/supabase.ts`

```bash
# Check for project ID first
grep -r "SUPABASE_PROJECT_ID" .env* src/lib/ 2>/dev/null
grep -r "supabase" . --include="*.ts" --include="*.js" --include="*.tsx" | head -5

# If not found, ASK THE USER for the Supabase project URL/ID
```

---

## 2. Chrome DevTools (Web Application Testing)

**Available to:** All agents (for web app testing)

**Use for:**
- React/Next.js/Vue web app testing
- Debugging UI issues
- Checking console errors
- Inspecting network requests
- Testing auth flows
- Checking token storage

**How to use:**
1. Start the dev server (e.g., `pnpm dev`)
2. Open Chrome browser
3. Navigate to `http://localhost:3000` (or appropriate port)
4. Open Chrome DevTools (F12 or Right-click → Inspect)
5. Test the functionality
6. Check Console tab for errors
7. Check Network tab for API calls
8. Verify DOM elements in Elements tab
9. Check Application tab for token storage (security testing)
10. Test auth flows (login, logout, session management)

---

## 3. Web Search Prime (Research)

**Available to:** All agents

**Use for:**
- Research best practices
- Find documentation for libraries
- Look up error messages
- Check for updated APIs
- Verify implementation approaches
- Security research (OWASP, vulnerabilities)
- Design pattern research

**When to use:**
```
❌ DON'T GUESS: "I think this might work like..."
✅ DO RESEARCH: Use web-search-prime to find the correct approach

Examples:
- "How do I use Supabase MCP with TypeScript?"
- "Best practices for ESLint configuration in Next.js 15"
- "Error: 'Cannot find module @shared/ui'"
- "OWASP best practices for authentication in 2025"
- "Supabase RLS policies security guide"
```

---

## 4. Web Reader (Documentation Reading)

**Available to:** All agents

**Use for:**
- Reading documentation pages
- Extracting code examples from docs
- Parsing API references
- Security documentation
- Design guidelines

---

## Story-Level MCP Assignment

**CRITICAL:** MCP tools are assigned PER STORY in the PRD JSON's `availableMcpTools` object, not at the PRD level.

**When you are spawned as an agent:**
1. Check your available tool set - the MCP tools you have access to will be visible
2. Use the MCP tools that are available to you
3. The story configuration specifies which MCP servers you can access
4. The exact tool names are discovered dynamically - use what you see available

**Example story configuration:**
```json
{
  "id": "US-001",
  "mavenSteps": [1, 7],
  "availableMcpTools": {
    "development-agent": [
      { "mcp": "supabase" },
      { "mcp": "web-search-prime" }
    ]
  }
}
```

**This means:**
- You have access to Supabase MCP and Web Search Prime MCP servers
- When you check your available tools, you'll see the specific tools from these servers
- Use the tools that appear in your tool set - don't hardcode specific tool names

---

## MCP Tool Pattern Reference

**Note:** This is a general reference. The exact tool names available to you depend on what MCP servers are configured in your environment. When working on a story, check your available tool set to see what MCP tools you have access to.

| MCP Server | Use For Steps | Typical Use Case | Primary Agents |
|------------|---------------|------------------|----------------|
| supabase | 7, 8, 10 | Database operations | development, security |
| postgres, mysql, mongo | 7, 8, 10 | Database operations | development, security |
| web-search, search | All steps | Research, documentation | All agents |
| web-reader, fetch | All steps | Reading web content | All agents |
| chrome, browser, puppeteer | Testing | Browser automation | All agents |
| vercel, wrangler, cloudflare | 9 | Deployment | development |
| figma, design | 11 | UI/UX design | design |

---

## Checking Available MCPs

```bash
# List all configured MCP servers
claude mcp list

# Get detailed info about a specific MCP server
claude mcp get <server-name>
```
