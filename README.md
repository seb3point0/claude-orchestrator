# Claude Orchestrator

**Dispatch GitHub issues to autonomous Claude workers that implement them in parallel, each in isolated git worktrees with zero conflicts.**

## The Problem

You have 50 GitHub issues to fix. Manually assigning them to team members takes time. Even if you had the capacity, coordinating code review and merging multiple branches is painful. What if you could dispatch all 50 at once and they'd all be worked on simultaneously?

## The Solution

Claude Orchestrator is an automated workflow system that:

1. **Dispatches issues** to autonomous Claude worker sessions
2. **Isolates work** in separate git worktrees (no merge conflicts)
3. **Analyzes your repository** before implementing (workers understand your codebase)
4. **Handles complex issues** by dispatching specialized team agents
5. **Monitors progress** automatically and reports completion

## How It Works

### Simple Example: 3 Issues, 3 Workers

```
You run:
/dispatch 1
/dispatch 2
/dispatch 3

What happens:
├─ Issue #1 → Worker in tmux window "issue-1"
│            ├─ Analyzes your repository
│            ├─ Creates git worktree at .worktrees/issue-1/
│            ├─ Implements the fix
│            └─ Commits to branch issue/1
│
├─ Issue #2 → Worker in tmux window "issue-2"
│            ├─ Analyzes your repository
│            ├─ Creates git worktree at .worktrees/issue-2/
│            ├─ Implements the feature
│            └─ Commits to branch issue/2
│
└─ Issue #3 → Worker in tmux window "issue-3"
             ├─ Analyzes your repository
             ├─ Creates git worktree at .worktrees/issue-3/
             ├─ Implements the change
             └─ Commits to branch issue/3

All three workers run simultaneously.
No conflicts because each has its own worktree and branch.
When each completes, it prints "ISSUE N COMPLETE" and the window closes.
```

## What Makes This Different

### 🔀 Git Worktrees (No Conflicts)
Instead of all workers checking out the same branch, each worker gets its own git worktree on its own branch (`issue/<N>`). This means:
- Multiple workers can work simultaneously
- Zero merge conflicts
- Easy to review each change separately
- Each branch is ready to merge when complete

### 🧠 Repository Analysis
Before touching any code, workers:
- Analyze your project structure
- Read your documentation
- Understand your coding patterns and conventions
- Review existing code style

This ensures the implementation fits your project, not generic AI output.

### 👥 Teams for Complex Issues
If an issue requires work across frontend, backend, and infrastructure, the worker automatically detects this and dispatches team agents. They work in parallel:

```
Issue: "Add OAuth2 authentication"
  ↓
Worker: "This needs 3 different domains"
  ↓
Dispatches teams (work in parallel):
- team-web: Frontend OAuth UI
- team-api: Backend token endpoints
- team-infra: Secrets management
  ↓
All coordinate in the same worktree
  ↓
Result: Complete feature, ready to merge
```

### 🤖 Autonomous & Isolated
Workers operate independently in their own tmux windows. No need for user intervention. When complete, they signal automatically. The monitoring system detects completion and cleans up.

## Installation (1 minute)

### Option A: Installation Script (Recommended)

```bash
cd your-project
bash <(curl -s https://raw.githubusercontent.com/seb3point0/claude-orchestrator/main/install.sh)
```

### Option B: Copy Skill File

```bash
# Copy the skill
curl -s https://raw.githubusercontent.com/seb3point0/claude-orchestrator/main/.claude/skills/orchestrator.md \
  -o your-project/.claude/skills/orchestrator.md

# In Claude:
/orchestrator init
```

### Option C: Manual Setup

```bash
mkdir -p your-project/.claude/commands your-project/scripts

# Copy files
curl -s https://raw.githubusercontent.com/seb3point0/claude-orchestrator/main/.claude/commands/dispatch.md \
  -o your-project/.claude/commands/dispatch.md

curl -s https://raw.githubusercontent.com/seb3point0/claude-orchestrator/main/.claude/scripts/spawn-issue-worker.sh \
  -o your-project/.claude/scripts/spawn-issue-worker.sh

chmod +x your-project/.claude/scripts/spawn-issue-worker.sh
```

## Quick Start (2 minutes)

```bash
# 1. Start tmux session
tmux new-session -s work

# 2. Launch Claude (inside the tmux session)
claude

# 3. In Claude, dispatch an issue
/dispatch 1    # Replace 1 with a real GitHub issue number

# Watch what happens:
# ├─ New tmux window "issue-1" appears
# ├─ Worker analyzes your repository
# ├─ Worker creates worktree at .worktrees/issue-1/
# ├─ Worker implements changes
# ├─ Worker prints: "ISSUE 1 COMPLETE"
# └─ Window closes automatically

# 4. Review the work
git log issue/1
git diff main issue/1

# 5. When ready to merge
git checkout main
git merge --no-ff issue/1 -m "Merge issue #1"

# 6. Dispatch more (they run in parallel)
/dispatch 2
/dispatch 3
/dispatch 4
```

## Real-World Examples

### Example 1: Bug Fix (Simple)
```
Issue: "Fix typo in error message"
/dispatch 42

Worker:
├─ Analyzes repo (2 sec)
├─ Creates worktree (1 sec)
├─ Finds typo (5 sec)
├─ Fixes it (2 sec)
├─ Commits (2 sec)
└─ Complete in 1 minute
```

### Example 2: New Feature (Complex)
```
Issue: "Add dark mode to application"

Worker:
├─ Analyzes repo
├─ Detects: "Needs UI + backend + theme config"
├─ Dispatches 3 team agents (work in parallel)
│  ├─ team-web: Dark mode UI components
│  ├─ team-api: Dark mode preference API
│  └─ team-infra: Theme configuration
└─ All complete in ~8 minutes (vs 25 solo)
```

### Example 3: Batch Processing (Scale)
```
You have 20 issues to fix:
/dispatch 1
/dispatch 2
/dispatch 3
... (dispatch all 20)
/dispatch 20

Result:
- All 20 workers run simultaneously
- Each in own tmux window
- Each with own worktree
- Each on its own branch
- 20 independent implementations happening at the same time
- When all done: 20 branches ready to review and merge
```

## How to Review Work

After a worker completes:

```bash
# See what changed
git log issue/1
git diff main issue/1
git show issue/1:src/changed-file.js

# If it looks good, merge it
git checkout main
git merge --no-ff issue/1

# If you want to make changes first
git checkout issue/1
# ... make edits ...
git commit -am "Fix minor issues"
git checkout main
git merge --no-ff issue/1

# Cleanup (optional)
git worktree remove .worktrees/issue-1
git branch -d issue/1
```

## Requirements

- **tmux** - Terminal multiplexer
- **gh** - GitHub CLI (authenticated)
- **claude** - Claude Code CLI
- **git 2.7.0+** - For worktree support
- **bash** - Shell

## Architecture

```
Your Repository
├── Main branch
├── .claude/
│   ├── commands/dispatch.md    ← Dispatch command
│   └── skills/orchestrator.md  ← Setup skill
├── scripts/
│   └── spawn-issue-worker.sh   ← Worker spawner
└── .worktrees/
    ├── issue-1/  (branch: issue/1)  ← Worker 1
    ├── issue-2/  (branch: issue/2)  ← Worker 2
    └── issue-3/  (branch: issue/3)  ← Worker 3
```

Each worker operates in its own `.worktrees/issue-<N>/` directory on its own `issue/<N>` branch. No conflicts between workers. All branches are ready to merge independently.

## Troubleshooting

**"No tmux session"**
```bash
# Orchestrator must run inside tmux
tmux new-session -s work
claude  # Inside the session
```

**"/dispatch command not found"**
- Ensure `.claude/commands/dispatch.md` exists
- Restart Claude

**"gh not authenticated"**
```bash
gh auth login
```

**"Worker didn't create worktree"**
```bash
# Check git version (must be 2.7.0+)
git --version

# Test worktree creation manually
git worktree add test-branch .worktrees/test origin/main
```

## FAQ

**Q: Can I use this with an existing Claude setup?**
A: Yes! It integrates seamlessly.

**Q: What if I have 50 issues?**
A: Dispatch all 50. They run concurrently, each with its own worker and worktree.

**Q: Do workers understand my codebase?**
A: Yes! They analyze your repo structure, documentation, and patterns before implementing.

**Q: What about merge conflicts?**
A: There are none! Each worker uses its own git worktree on its own branch.

**Q: Can workers handle complex issues?**
A: Yes! They automatically dispatch team agents for multi-domain work.

**Q: How long do issues take?**
A: Simple issues: 1-5 minutes. Complex issues: 5-20 minutes (teams work in parallel).

**Q: Do I need to review the work?**
A: Yes. Each issue is on a separate branch. Review with `git diff main issue/<N>` before merging.

## More Information

For detailed documentation, see the `docs/` folder:
- `ARCHITECTURE.md` - System design and data flow
- `TEAMS-GUIDE.md` - Using teams for complex issues
- `INTEGRATION.md` - Detailed integration guide
- And more...

## License

MIT

---

**Ready to try it?** Start with [Installation](#installation-1-minute) above.
