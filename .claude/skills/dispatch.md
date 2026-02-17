---
allowed-tools: Bash
---

# /dispatch - Spawn Worker in New Tmux Window

**DO NOT USE TASK TOOL. Only use Bash.**

When you type `/dispatch 28`, run this single bash command:

```bash
ISSUE_DATA=$(gh issue view $ARGUMENTS --json number,title,body,url) && \
ISSUE_NUMBER=$(echo "$ISSUE_DATA" | jq -r '.number') && \
ISSUE_TITLE=$(echo "$ISSUE_DATA" | jq -r '.title') && \
ISSUE_BODY=$(echo "$ISSUE_DATA" | jq -r '.body') && \
ISSUE_URL=$(echo "$ISSUE_DATA" | jq -r '.url') && \
bash .claude/claude-orchestrator-scripts/spawn-issue-worker.sh "$ISSUE_NUMBER" "$ISSUE_TITLE" "$ISSUE_URL" "$ISSUE_BODY"
```

## What This Does

1. Fetches issue data from GitHub
2. Parses the JSON into variables
3. Calls the spawn script with those variables
4. Creates a NEW tmux window for the worker
5. Worker runs IN THAT WINDOW (not in this one)

## CRITICAL

- Use ONLY Bash tool
- Do NOT use Task tool
- Do NOT spawn background agent
- Run the complete command as shown above
- Everything is piped together with && so it all executes as one command

## Result

New tmux window "issue-X" will be created and worker will run there.
