---
allowed-tools: Bash, Task
---

Dispatch GitHub issue $ARGUMENTS to an autonomous worker session.

## Implementation

1. **Fetch issue data** using `gh issue view $ARGUMENTS --json number,title,body,url`
2. **Spawn a Monitor Team Member** via the Task tool with:
   - `subagent_type: general-purpose`
   - `run_in_background: true`
   - Pass issue number, title, url, and body as context
3. **Monitor Team Member tasks**:
   - Call `bash .claude/claude-orchestrator-scripts/spawn-issue-worker.sh <ISSUE_NUMBER> "<TITLE>" "<URL>" "<BODY>"`
   - Poll `tmux capture-pane` every 30 seconds for "ISSUE <N> COMPLETE"
   - When detected, extract completion summary and report back
   - Clean up: `tmux kill-window -t "<SESSION>:issue-<N>"`
4. **Respond to user**: "Dispatched issue #N to a worker. Window 'issue-N' will appear shortly."

## Error Handling

- If issue not found, report gh CLI error clearly
- If tmux session not found, report that orchestrator must run inside tmux
