# Claude Orchestrator

**Autonomous GitHub issue resolution at scale.** Dispatch issues to autonomous worker Claude sessions that run concurrently in isolated git worktrees.

## What It Does

```
/dispatch 1    → Worker starts in Window 1 (issue-1)
/dispatch 2    → Worker starts in Window 2 (issue-2)
/dispatch 3    → Worker starts in Window 3 (issue-3)
               ↓
           [All work concurrently]
               ↓
Worker 1 → Analyzes repo → Creates worktree → Implements → ISSUE 1 COMPLETE
Worker 2 → Analyzes repo → Creates worktree → Implements → ISSUE 2 COMPLETE
Worker 3 → Analyzes repo → Creates worktree → Implements → ISSUE 3 COMPLETE
```

**Key features:**
- 🤖 Autonomous workers in tmux windows
- 🔀 Git worktrees for isolated concurrent work (zero conflicts)
- 👥 Claude Teams for complex multi-domain issues
- 📊 Automatic completion detection
- ⚙️ Full repository analysis before implementation

## Quick Start (5 minutes)

### Installation

**Option 1: Installation Script (Recommended)**

```bash
cd your-project
bash <(curl -s https://raw.githubusercontent.com/YOUR-USERNAME/claude-orchestrator/main/install.sh)
```

**Option 2: Copy Skill File**

```bash
# Copy orchestrator skill
curl -s https://raw.githubusercontent.com/YOUR-USERNAME/claude-orchestrator/main/.claude/skills/orchestrator.md \
  -o your-project/.claude/skills/orchestrator.md

# Then in Claude
/orchestrator init
```

**Option 3: Manual Setup**

```bash
mkdir -p your-project/.claude/commands your-project/scripts

# Copy files
cp .claude/commands/dispatch.md your-project/.claude/commands/
cp scripts/spawn-issue-worker.sh your-project/scripts/
chmod +x your-project/scripts/spawn-issue-worker.sh
```

### Use It

```bash
# Start tmux session
tmux new-session -s work

# Launch Claude (inside tmux)
claude

# Dispatch your first issue
/dispatch 1    # Replace with real issue number

# Watch it work
# - New window "issue-1" appears
# - Worker analyzes repo
# - Worker creates worktree at .worktrees/issue-1/
# - Worker implements changes
# - When done: prints "ISSUE 1 COMPLETE"
# - Window closes automatically

# Dispatch more (they run in parallel)
/dispatch 2
/dispatch 3
```

## How It Works

### Worker Workflow

1. **Analyze Repository** - Understand structure, patterns, conventions
2. **Analyze Issue** - Understand what needs to be done
3. **Create Worktree** - Isolated git worktree at `.worktrees/issue-<N>/`
4. **Implement** - Make changes (can dispatch teams for complex work)
5. **Complete** - Commits and signals done

### For Complex Issues

Workers automatically detect complex issues and dispatch team agents:

```
Issue: "Add OAuth2 authentication system"
  ↓
Worker: "Needs frontend + backend + infrastructure"
  ↓
Dispatch teams (in parallel):
  - team-web: OAuth UI and callbacks
  - team-api: Token endpoints
  - team-infra: Secrets configuration
  ↓
All work concurrently, worker coordinates
  ↓
Result: Complete feature, ready to merge
```

## Requirements

- **tmux** - Terminal multiplexer
- **gh** - GitHub CLI (authenticated)
- **claude** - Claude Code CLI
- **git 2.7.0+** - For worktree support
- **bash** - Shell

## After Setup

```bash
# Review the work
git log issue/1
git diff main issue/1

# When ready to merge
git checkout main
git merge --no-ff issue/1 -m "Merge issue #1"

# Dispatch more issues (they run in parallel)
/dispatch 2
/dispatch 3
/dispatch 4
```

## Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - 5-minute walkthrough
- **[docs/](docs/)** - Detailed documentation:
  - `ARCHITECTURE.md` - System design
  - `TEAMS-GUIDE.md` - Using teams for complex issues
  - `CLAUDE.md` - Project conventions
  - `INTEGRATION.md` - Integration guide
  - And more...

## Examples

### Simple Fix (Solo Worker)

```
Issue: "Fix typo in README"
/dispatch 123
# Worker fixes, commits, done
# Time: 2 minutes
```

### Complex Feature (Teams)

```
Issue: "Add real-time notifications"
/dispatch 456
# Worker analyzes: "Needs frontend + backend + infrastructure"
# Worker dispatches 3 team agents (work in parallel)
# Teams complete their parts
# Worker integrates and commits
# Time: 10 minutes (vs 30 solo)
```

### Batch of Issues (Concurrent Workers)

```
/dispatch 1
/dispatch 2
/dispatch 3
/dispatch 4
/dispatch 5

# All 5 workers run simultaneously
# Each in own tmux window
# Each with own git worktree
# No conflicts, fully parallel
```

## Architecture

```
Main Repository
├── .claude/
│   ├── commands/dispatch.md      ← /dispatch command
│   └── skills/orchestrator.md    ← /orchestrator init skill
├── scripts/
│   └── spawn-issue-worker.sh     ← Worker spawner
├── .worktrees/
│   ├── issue-1/                  ← Worker 1 workspace
│   ├── issue-2/                  ← Worker 2 workspace
│   └── issue-3/                  ← Worker 3 workspace
└── [main repo files]
```

Workers operate in `.worktrees/issue-<N>/` on branch `issue/<N>`, preventing any conflicts.

## Troubleshooting

**"No tmux session"**
```bash
tmux new-session -s work
claude  # Inside the tmux session
```

**"gh not authenticated"**
```bash
gh auth login
```

**"/dispatch command not found"**
- Ensure `.claude/commands/dispatch.md` exists
- Restart Claude

**"Worker not creating worktree"**
```bash
git --version  # Must be 2.7.0+
git worktree add test-branch .worktrees/test origin/main  # Manual test
```

See [docs/INTEGRATION.md](docs/INTEGRATION.md) for more troubleshooting.

## FAQ

**Q: Can I use this with an existing Claude setup?**
A: Yes! It integrates seamlessly into any project.

**Q: What if I have 50 issues to dispatch?**
A: Dispatch them all—they run concurrently. Each gets its own worker, worktree, and git branch.

**Q: Can workers handle complex issues?**
A: Yes! They automatically detect complexity and dispatch specialized team agents.

**Q: What happens to the worktrees?**
A: They persist after completion for review. Clean up with: `git worktree remove .worktrees/issue-<N>`

**Q: Can I review the work before merging?**
A: Yes! Each issue is on a separate branch (`issue/<N>`). Review with `git diff main issue/<N>` before merging.

## Installation Methods

| Method | Time | Best For |
|--------|------|----------|
| Script | 1 min | Quick setup |
| Skill | 30 sec | Claude users |
| Manual | 5 min | Advanced setup |
| GitHub Template | 0 sec | New projects |

Pick your method above or see [docs/INTEGRATION.md](docs/INTEGRATION.md).

## What's New (v2.0)

- ✅ Git worktrees for concurrent isolation
- ✅ Full repository analysis phase
- ✅ Claude Teams integration
- ✅ Automatic complexity detection

See [docs/CHANGELOG.md](docs/CHANGELOG.md) for full details.

## Getting Help

- **Quick questions?** See FAQ above
- **Step-by-step guide?** See [QUICKSTART.md](QUICKSTART.md)
- **System design?** See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- **Complex issues?** See [docs/TEAMS-GUIDE.md](docs/TEAMS-GUIDE.md)
- **Integration issues?** See [docs/INTEGRATION.md](docs/INTEGRATION.md)

## License

MIT

---

**Ready to try it?** Start with the [Quick Start](#quick-start-5-minutes) section above.
