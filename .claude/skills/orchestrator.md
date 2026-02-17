---
allowed-tools: Bash, Read, Write
---

# Claude Orchestrator Setup Skill

Initialize and manage the GitHub Issue Orchestrator in your project.

## Usage

```
/orchestrator init      # Initialize orchestrator in this project
/orchestrator status    # Show orchestrator status
/orchestrator check     # Verify all prerequisites
/orchestrator help      # Show this help
```

## What It Does

The orchestrator enables autonomous GitHub issue resolution using:
- **Concurrent workers** in tmux windows (one per issue)
- **Git worktrees** for isolated work (no conflicts)
- **Claude Teams** for complex multi-domain issues
- **Smart monitoring** that detects completion automatically

## Installation

When you run `/orchestrator init`, it will:

1. ✅ Check prerequisites (tmux, gh, claude, git)
2. ✅ Create `.claude/commands/dispatch.md` (dispatch command)
3. ✅ Create `scripts/spawn-issue-worker.sh` (worker spawner)
4. ✅ Add documentation files
5. ✅ Verify installation
6. ✅ Show next steps

## After Installation

Dispatch issues from the orchestrator:

```
/dispatch 123    # Start worker for issue #123
/dispatch 456    # Start worker for issue #456 (runs concurrently)
```

Each worker:
- Gets full issue context
- Analyzes the repository
- Creates isolated git worktree
- Implements changes
- Can dispatch teams for complex work
- Signals completion automatically

## Requirements

- **tmux** - Terminal multiplexer for windows
- **gh** - GitHub CLI (authenticated)
- **claude** - Claude Code CLI
- **git 2.7.0+** - For git worktree support
- **bash** - Shell

## Documentation

After installation, see:
- `QUICKSTART.md` — 5-minute quick start
- `README.md` — Full documentation
- `TEAMS-GUIDE.md` — Using teams for complex issues
- `ARCHITECTURE.md` — System design details
- `CLAUDE.md` — Project conventions

## Quick Start (After Init)

```bash
# 1. Start tmux session
tmux new-session -s orchestrator

# 2. Launch Claude (in tmux)
claude

# 3. Dispatch an issue
/dispatch 1

# 4. Watch it work
#    - New tmux window "issue-1" appears
#    - Worker analyzes repo
#    - Worker creates worktree
#    - Worker implements changes
#    - When done: prints "ISSUE 1 COMPLETE"
#    - Monitor closes window automatically

# 5. Review changes
git log issue/1
git diff main issue/1
```

## Examples

### Simple Bug Fix

```
/dispatch 42
# Worker: Creates worktree, analyzes, fixes bug, commits
# Time: ~2 minutes
# Result: Branch issue/42 with fix ready to merge
```

### Complex Feature (Uses Teams)

```
/dispatch 99
# Worker: Analyzes "Needs frontend + backend + infrastructure"
# Worker: Dispatches team-web, team-api, team-infra
# Teams: Work in parallel on their parts
# Coordination: Worker integrates results
# Time: ~10 minutes
# Result: Branch issue/99 with complete feature ready to merge
```

### Concurrent Issues

```
/dispatch 1
/dispatch 2
/dispatch 3
# All three workers run simultaneously
# Each in own tmux window with own worktree
# No conflicts, no interference
# All complete independently
```

## Troubleshooting

**"Command not found"**
- Make sure .claude/skills/orchestrator.md exists
- Restart Claude Code

**"No tmux session"**
- Run: tmux new-session -s work
- Then: claude (inside tmux)

**"gh not authenticated"**
- Run: gh auth login
- Configure GitHub CLI access

**"Worker not working"**
- Check worker window: tmux list-windows
- View logs: tmux capture-pane -t session:issue-1 -p
- See QUICKSTART.md troubleshooting

## Configuration

### Worker Model

Edit `scripts/spawn-issue-worker.sh`:
- Change `--model sonnet` to `--model opus` for more capable
- Change to `--model haiku` for faster (less capable)

### Polling Interval

Edit `.claude/commands/dispatch.md`:
- Default: 30 seconds
- Change for faster/slower monitoring

### Worktree Location

Default: `.worktrees/issue-N/`
- Edit `scripts/spawn-issue-worker.sh` to customize

### Team Dispatch Criteria

Edit `scripts/spawn-issue-worker.sh` system prompt:
- Modify "When to use Teams" section
- Adjust complexity thresholds

## Architecture

```
Orchestrator (main Claude session in Window 0)
  ├─ /dispatch 123
  │  └─ Monitor Team Member (background)
  │     └─ Creates tmux window "issue-123"
  │        └─ Worker Claude session
  │           ├─ Analyzes repo
  │           ├─ Creates worktree .worktrees/issue-123/
  │           ├─ Implements changes
  │           ├─ (Optional) Dispatches teams
  │           └─ Prints: ISSUE 123 COMPLETE
  │
  └─ /dispatch 456
     └─ [Same for issue #456]
```

## Concurrent Execution

Multiple issues run simultaneously:

```
Time 0s:   /dispatch 1 → worker-1 starts (Window 1)
           /dispatch 2 → worker-2 starts (Window 2)
           /dispatch 3 → worker-3 starts (Window 3)

Time 30s:  worker-1: Creating worktree...
           worker-2: Analyzing repo...
           worker-3: Fetching issue...

Time 120s: worker-1: ISSUE 1 COMPLETE
           Monitor-1: Detects, reports, closes window

Time 180s: worker-2: ISSUE 2 COMPLETE
           Monitor-2: Detects, reports, closes window

Time 240s: worker-3: ISSUE 3 COMPLETE
           Monitor-3: Detects, reports, closes window
```

All three work independently without conflicts.

## Performance Notes

- **Repository analysis**: 1-2 minutes (ensures quality)
- **Simple issue**: 3-5 minutes
- **Complex issue (with teams)**: 10-20 minutes
- **Concurrent scaling**: Linear (3 issues ≈ 3x time, not 9x)

## Security

- Workers run in isolated tmux windows
- Each worker gets own git worktree
- Changes on separate branches (easy to review)
- No automatic merging (human review required)
- Secrets/credentials should be in .env (not committed)

## Next Steps After Init

1. **Try a simple issue**
   ```
   /dispatch 1
   ```

2. **Monitor it**
   ```
   tmux list-windows
   tmux capture-pane -t session:issue-1 -p
   ```

3. **Review results**
   ```
   git log issue/1
   git diff main issue/1
   ```

4. **Dispatch more issues** (they run concurrently)
   ```
   /dispatch 2
   /dispatch 3
   ```

5. **For complex issues**, worker will automatically use teams

## Support

- Check QUICKSTART.md for quick issues
- Check README.md for detailed docs
- Check TEAMS-GUIDE.md for complex issues
- Check ARCHITECTURE.md for system design
- Check DISTRIBUTION.md for integration options

## Version

Current: v2.0.0 (with Teams & Worktrees support)

See CHANGELOG.md for what's new.

---

**Ready to get started?** Run `/orchestrator init` now!
