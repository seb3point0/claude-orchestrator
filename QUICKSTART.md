# Quick Start Guide

Get the orchestrator up and running in 5 minutes.

## 1. Prerequisites

Ensure you have:
- Claude Code CLI installed: `claude --version`
- tmux installed: `tmux -V`
- GitHub CLI configured: `gh auth status`
- In a git repository with GitHub issues

## 2. Initialize Orchestrator

From the repository root, run:

```bash
# Copy orchestrator files to your repo
cp -r /path/to/claude-orchestrator/.claude .
cp -r /path/to/claude-orchestrator/scripts .
```

Or initialize manually:
```bash
mkdir -p .claude/commands scripts
# Copy the files from claude-orchestrator
```

## 3. Start Tmux Session

```bash
tmux new-session -s work
```

## 4. Launch Claude Orchestrator

In the tmux session:
```bash
claude
```

You should see Claude Code prompt in Window 0.

## 5. Dispatch Your First Issue

In Claude (Window 0), type:
```
/dispatch 1
```

(Replace `1` with a real issue number in your repo)

## 6. Watch It Work

1. A new tmux window `issue-1` appears
2. Claude analyzes the repository structure
3. Claude creates a git worktree at `.worktrees/issue-1/`
4. Claude works autonomously in the worktree
5. For complex issues, Claude may dispatch team agents
6. When done, worker prints: `ISSUE 1 COMPLETE`
7. Window closes automatically

## 7. Check Results

After worker completes:
- Worktree created: `.worktrees/issue-1/`
- New branch created: `issue/1`
- Changes committed to that branch
- Check commits: `git log issue/1`
- Review changes: `git diff main issue/1`
- Back in Window 0 (orchestrator), you see completion message
- Ready to dispatch another issue

**Note**: The worktree remains after completion for review. Clean up later:
```bash
git worktree remove .worktrees/issue-1
```

## Dispatch Multiple Issues

```
/dispatch 2
/dispatch 3
/dispatch 4
```

All run concurrently in separate windows!

## Troubleshooting

**Q: "/dispatch command not found"**
- Ensure `.claude/commands/dispatch.md` exists
- Restart Claude Code

**Q: "No tmux session found"**
- Launch `tmux new-session -s work` first
- Then `claude` inside that session

**Q: Worker window appears but nothing happens**
- Check `scripts/spawn-issue-worker.sh` is executable: `chmod +x scripts/spawn-issue-worker.sh`
- Verify `gh issue view <number>` works

**Q: Monitor never completes**
- Check worker window manually: `tmux capture-pane -t work:issue-1 -p`
- Verify worker is printing: `ISSUE 1 COMPLETE`

## Next Steps

- Review `CLAUDE.md` for project conventions
- Read `README.md` for detailed documentation
- Check `scripts/spawn-issue-worker.sh` to customize worker behavior
- Modify `.claude/commands/dispatch.md` to adjust orchestrator logic
