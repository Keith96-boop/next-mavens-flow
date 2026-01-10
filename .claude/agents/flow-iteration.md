---
name: flow-iteration
description: DEPRECATED - This agent is no longer used. The /flow command now coordinates specialist agents directly since subagents cannot spawn other subagents.
tools: Read, Bash, Task, AskUserQuestion
model: inherit
color: yellow
permissionMode: default
skills: []
---

# Maven Flow Iteration Agent - DEPRECATED

## Status: DEPRECATED

This agent definition is **no longer used** in Maven Flow.

## Reason for Deprecation

**Subagents cannot spawn other subagents in Claude Code CLI.**

From the Claude Code documentation:

> "The premise of this tool is to spin off a sub-agent that will have the same access to tools as your main agent (**except that it cannot spawn another sub-task**) and reports back the results."

The original architecture was:
```
Main Claude
  ↓
/flow (command)
  ↓
Task tool → flow-iteration (SUBAGENT)
  ↓
Task tool → specialist agents (FAILS - subagents can't spawn subagents!)
```

## New Architecture

The `/flow` slash command (running in main Claude context) now coordinates ALL specialist agent spawning directly:

```
Main Claude
  ↓
/flow (command) ← ALL coordination happens here
  ↓
  ├─→ Task tool → development (for Step 1)
  ├─→ Task tool → refactor (for Step 3)
  ├─→ Task tool → quality (for Step 5)
  ├─→ Task tool → security (for Step 8)
  ↓
  After all specialists complete, continue to next story
```

## How It Works Now

See `.claude/commands/flow.md` for the complete updated architecture.

The `/flow` command now:
1. Scans for incomplete PRDs
2. For each incomplete story, reads the `mavenSteps` array
3. **Directly spawns specialist agents** using the Task tool:
   - Step 1, 2, 7, 9 → `Task(subagent_type="development")`
   - Step 3, 4, 6 → `Task(subagent_type="refactor")`
   - Step 5 → `Task(subagent_type="quality")`
   - Step 8, 10 → `Task(subagent_type="security")`
4. Waits for each agent to complete
5. Runs quality checks, commits, updates PRD
6. Continues to next story automatically

## Migration Notes

If you were using this agent in any custom workflows or scripts, please update them to:

- Use `/flow start` instead of spawning flow-iteration
- The /flow command handles all story processing and agent coordination
- Refer to `flow.md` for the complete command documentation

---

*Last updated: 2025-01-10*
*Reason: Architectural limitation - subagents cannot spawn other subagents*
