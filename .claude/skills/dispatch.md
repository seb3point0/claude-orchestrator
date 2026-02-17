---
allowed-tools: Bash
---

# Dispatch Issue to New Tmux Window

Execute these bash commands to spawn a worker in a new tmux window:

1. Get issue data:
```bash
gh issue view $ARGUMENTS --json number,title,body,url > /tmp/issue.json
ISSUE_NUMBER=$(jq -r '.number' /tmp/issue.json)
ISSUE_TITLE=$(jq -r '.title' /tmp/issue.json)
ISSUE_BODY=$(jq -r '.body' /tmp/issue.json)
ISSUE_URL=$(jq -r '.url' /tmp/issue.json)
```

2. Spawn worker in new window:
```bash
bash .claude/claude-orchestrator-scripts/spawn-issue-worker.sh \
  "$ISSUE_NUMBER" "$ISSUE_TITLE" "$ISSUE_URL" "$ISSUE_BODY"
```

3. Confirm:
```bash
echo "✓ Worker spawned in new window: issue-$ISSUE_NUMBER"
```

Run each command in order. Do not use Task tool. Only Bash.
