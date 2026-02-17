---
allowed-tools: Bash
---

# Dispatch GitHub Issue to Worker

Dispatch a GitHub issue to an autonomous worker that runs in a separate tmux window.

**Usage:** `/dispatch <issue-number>`

**Example:** `/dispatch 123`

## What This Does

1. Fetches GitHub issue #$ARGUMENTS
2. Spawns a new tmux window (e.g., "issue-123")
3. Launches Claude in that window with the issue context
4. Worker runs autonomously in that window
5. Reports completion

## How to Use

In Claude (inside tmux):

```
/dispatch 123
```

This will:
- Create a new tmux window named "issue-123"
- Launch Claude in that window
- Worker will have the full issue context
- You'll see "Worker launched in window 'issue-123'"

## Check Progress

In another tmux pane/window:

```bash
tmux list-windows                              # See all windows
tmux capture-pane -t orchestrator:issue-123 -p # See worker output
```

## When Done

Worker prints: `ISSUE 123 COMPLETE`

Then the window closes automatically.

## Multiple Issues

Dispatch as many as you want - they all run simultaneously:

```
/dispatch 1
/dispatch 2
/dispatch 3
/dispatch 4
```

Each runs in its own window with its own worktree. No conflicts!

## What the Worker Does

In its tmux window:
1. Analyzes your repository
2. Creates `.worktrees/issue-123/` on branch `issue/123`
3. Implements the fix
4. Commits changes
5. Prints completion signal

You'll see all of this in the worker's tmux window in real-time.

## Implementation Details

The dispatch skill runs:

```bash
# 1. Fetch issue data
gh issue view $ARGUMENTS --json number,title,body,url

# 2. Get values from output
ISSUE_NUMBER=$(...)
ISSUE_TITLE=$(...)
ISSUE_BODY=$(...)
ISSUE_URL=$(...)

# 3. Spawn worker in new tmux window
bash .claude/claude-orchestrator-scripts/spawn-issue-worker.sh \
  "$ISSUE_NUMBER" "$ISSUE_TITLE" "$ISSUE_URL" "$ISSUE_BODY"

# 4. Report to user
echo "Worker started in window 'issue-$ISSUE_NUMBER'"
```

That's all! The worker then runs autonomously in its window.
