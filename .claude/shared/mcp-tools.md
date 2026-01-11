# MCP Tools Reference for Maven Flow Agents

This document provides reference for MCP tools used in Maven Flow.

---

## How MCP Assignment Works

**Simple and direct:**

1. **PRD specifies MCPs per step:**
   ```json
   {
     "id": "US-001",
     "mavenSteps": [1, 7],
     "mcpTools": {
       "step1": ["supabase"],
       "step7": ["supabase", "web-search"]
     }
   }
   ```

2. **Flow tells agent:** "Use these MCPs: supabase"

3. **Agent:** Uses the MCP tools they have available

---

## Common MCPs

| MCP Name | Use For | Examples |
|----------|---------|----------|
| supabase | Database operations | Query tables, create schemas, run migrations |
| web-search | Research | Find documentation, look up errors |
| web-reader | Read web pages | Parse docs, extract examples |
| chrome-devtools | Browser testing | Test web apps, check console |
| playwright | Browser automation | Automated browser testing |
| vercel | Deployment | Deploy to Vercel |
| wrangler | Deployment | Deploy to Cloudflare |
| figma | Design | Design-to-code workflow |

---

## For Agents

**When you're told to use an MCP:**

1. Check if that MCP is in your available tools
2. If yes → use it
3. If no → use standard tools (Read, Write, Bash, etc.)

**Example:**
```
Task: "Use supabase MCP to verify products table"

Agent:
✓ Looks for supabase MCP tools
✓ Uses them to query the table
✓ Reports results
```

---

## PRD Configuration

**In your PRD JSON, specify MCPs per step:**

```json
{
  "userStories": [
    {
      "id": "US-001",
      "title": "Create products table",
      "mavenSteps": [1, 7],
      "mcpTools": {
        "step1": ["supabase"],
        "step7": ["supabase", "web-search"]
      }
    }
  ]
}
```

**Key points:**
- `mcpTools` is optional (omit if no MCPs needed)
- Specify step-by-step which MCPs to use
- Agent will figure out how to use them
