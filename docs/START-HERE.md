# START HERE 🚀

Quick reference for everything you need to know about the Claude Orchestrator.

---

## What Is This?

**Claude Orchestrator** is a system for autonomous GitHub issue resolution using:
- 🤖 Autonomous workers in tmux windows (one per issue)
- 🔀 Git worktrees for isolated, concurrent work
- 👥 Claude Teams for complex multi-domain issues
- 📊 Smart monitoring that detects completion automatically

**Result**: Dispatch 100 GitHub issues and they all work concurrently without conflicts.

---

## 3 Ways to Use This

### 1. Right Now (This Project)

**Test it locally in this repository:**

```bash
# Start tmux session
tmux new-session -s test

# Launch Claude (inside tmux)
claude

# In Claude, test dispatch
/dispatch 1    # Test with real GitHub issue #1
```

See it work in real-time.

### 2. Add to Your Project (Easy)

**Option A: Copy orchestrator skill** (30 seconds)
```bash
cp .claude/skills/orchestrator.md your-project/.claude/skills/
cd your-project
tmux new-session
claude
/orchestrator init
/dispatch 1
```

**Option B: Run installation script** (1 minute)
```bash
cd your-project
bash ../claude-orchestrator/install.sh
/dispatch 1
```

**Option C: Manual setup** (5 minutes)
See `INTEGRATION.md`

### 3. Distribute to Others

Choose a distribution method:
- **Skill** — Share `.claude/skills/orchestrator.md`
- **Installation script** — Share `install.sh`
- **NPM package** — Publish to npm registry
- **GitHub template** — Make repo a template
- **Integration guide** — Share `INTEGRATION.md`

See `PACKAGE-OPTIONS.md` for details.

---

## File Structure

```
claude-orchestrator/
│
├── 🎯 CORE SYSTEM (What makes it work)
│   ├── .claude/commands/dispatch.md        ← /dispatch command
│   ├── .claude/skills/orchestrator.md      ← /orchestrator skill
│   └── scripts/spawn-issue-worker.sh       ← Worker spawner
│
├── 📖 DOCUMENTATION (How to use it)
│   ├── README.md                           ← Main documentation
│   ├── QUICKSTART.md                       ← 5-minute start
│   ├── TEAMS-GUIDE.md                      ← Using teams
│   ├── ARCHITECTURE.md                     ← System design
│   └── CLAUDE.md                           ← Project conventions
│
├── 📦 DISTRIBUTION (How to package it)
│   ├── INTEGRATION.md                      ← Add to your project
│   ├── DISTRIBUTION.md                     ← Packaging guide
│   ├── PACKAGE-OPTIONS.md                  ← Which option for you
│   └── CHANGELOG.md                        ← What's new
│
├── ⚙️ SETUP (Getting started)
│   ├── setup.sh                            ← Setup script
│   └── .gitignore
│
└── 📍 YOU ARE HERE
    └── START-HERE.md
```

---

## Quick Facts

| Aspect | Details |
|--------|---------|
| **Worker Isolation** | Each worker runs in separate tmux window with own git worktree |
| **Concurrent Issues** | Unlimited (system limited) |
| **Setup Time** | 1-5 minutes depending on method |
| **Prerequisites** | tmux, gh CLI, claude, git 2.7.0+ |
| **Teams Support** | Yes, for complex issues |
| **Repo Analysis** | Yes, workers understand your code before touching it |
| **Git Worktrees** | Yes, all at `.worktrees/issue-<N>/` |
| **Automation** | Full—workers operate autonomously |
| **Monitoring** | Automatic—system detects completion |

---

## Try It Now (5 Minutes)

```bash
# 1. Start tmux
tmux new-session -s demo

# 2. Launch Claude
claude

# 3. Try dispatch (use real issue number)
/dispatch 1

# 4. Watch worker window
# - New window "issue-1" appears
# - Worker analyzes repo
# - Worker creates worktree
# - Worker implements changes
# - When done: "ISSUE 1 COMPLETE"

# 5. Review changes
git log issue/1
git diff main issue/1
```

---

## Common Questions

### Q: How do I add this to my project?
**A:** See `INTEGRATION.md`. Quick version:
```bash
cp .claude/skills/orchestrator.md your-project/.claude/skills/
cd your-project && tmux new && claude && /orchestrator init
```

### Q: Can I use this with my existing Claude setup?
**A:** Yes! The orchestrator integrates seamlessly. See `INTEGRATION.md`.

### Q: How do I distribute this to my team?
**A:** See `PACKAGE-OPTIONS.md`. Options:
- Share the skill file
- Use installation script
- Publish to npm
- Make a GitHub template

### Q: What if I have 100 issues?
**A:** Dispatch them all:
```
/dispatch 1
/dispatch 2
/dispatch 3
... (all run concurrently)
/dispatch 100
```
Each worker gets own window + worktree. No conflicts.

### Q: Can workers work on complex issues?
**A:** Yes! Workers can dispatch team agents:
```
Worker analyzes: "Needs frontend + backend"
→ Dispatches team-web + team-api
→ Teams work in parallel
→ Worker coordinates
→ Done faster
```

### Q: How do I review the work?
**A:** After worker completes:
```bash
git log issue/<N>
git diff main issue/<N>
git show issue/<N>:changed-file.js
git merge issue/<N>    # When ready to merge
```

### Q: What if a worker crashes?
**A:** Monitor detects non-completion and reports back. You can:
- Check worker window: `tmux capture-pane -t session:issue-1 -p`
- Debug the issue
- Restart worker manually
- See troubleshooting in `README.md`

---

## Next Steps

### Immediate (Now)

1. ✅ **Understand the system**
   - Read this file (you're doing it!)
   - Skim `README.md` (5 min read)

2. ✅ **Try it out** (if you want)
   - Follow "Try It Now" section above
   - Watch a worker in action

3. ✅ **Choose integration method**
   - Read `PACKAGE-OPTIONS.md`
   - Decide: Skill? Script? NPM? Template?

### Short-term (This week)

1. ✅ **Add to your project**
   - Follow `INTEGRATION.md`
   - Verify with checklist
   - Dispatch your first real issue

2. ✅ **Customize for your project**
   - Edit `CLAUDE.md` with your conventions
   - Update `scripts/spawn-issue-worker.sh` if needed
   - Test with 2-3 real issues

3. ✅ **Share with team**
   - Follow `PACKAGE-OPTIONS.md`
   - Choose distribution method
   - Point team to documentation

### Medium-term (Next month)

1. ✅ **Package for distribution**
   - If using NPM: Set up package.json
   - If using templates: Enable GitHub template
   - If using scripts: Set up CI/CD

2. ✅ **Build examples**
   - Document team usage patterns
   - Create example issues and results
   - Show team agent coordination

3. ✅ **Community**
   - Share on GitHub
   - Contribute improvements
   - Help others integrate

---

## Reading Guide

**Based on what you want to do:**

### "I want to try it now"
- Read: `QUICKSTART.md` (5 min)

### "I want to understand how it works"
- Read: `ARCHITECTURE.md` (15 min)
- Read: `TEAMS-GUIDE.md` (20 min)

### "I want to add it to my project"
- Read: `INTEGRATION.md` (10 min)
- Follow: Step-by-step instructions

### "I want to distribute it"
- Read: `PACKAGE-OPTIONS.md` (10 min)
- Read: `DISTRIBUTION.md` (15 min)
- Choose: Which distribution method

### "I want to understand everything"
- Read: `README.md` (full overview)
- Read: `ARCHITECTURE.md` (system design)
- Read: `TEAMS-GUIDE.md` (advanced usage)
- Read: `INTEGRATION.md` (implementation)
- Read: `PACKAGE-OPTIONS.md` (distribution)

---

## Key Concepts

### Git Worktrees

Each worker operates in an isolated worktree:

```
repo/
├── .worktrees/
│   ├── issue-1/        ← Worker 1 works here
│   ├── issue-2/        ← Worker 2 works here
│   └── issue-3/        ← Worker 3 works here
```

**Benefits:**
- Multiple branches checked out simultaneously
- No merge conflicts between workers
- Easy to review and merge when done

### Repository Analysis

Before coding, every worker:
1. Explores your repository structure
2. Reads your documentation
3. Understands your coding patterns
4. Analyzes project conventions

**Result:** Workers write code that fits your project perfectly.

### Claude Teams

For complex issues, workers dispatch specialized team agents:

```
Issue: "Add OAuth2 authentication"
  ↓
Worker: "This needs frontend + backend + infrastructure"
  ↓
Dispatch:
  - team-web (frontend)
  - team-api (backend)
  - team-infra (infrastructure)
  ↓
Work in parallel (~50% faster)
  ↓
Coordinated and integrated
```

### Completion Detection

Workers print a sentinel string when done:
```
ISSUE <N> COMPLETE
```

Monitor detects this and:
- Reports back to orchestrator
- Closes the worker window
- Makes space for next issue

---

## Architecture (Simple Version)

```
Window 0 (Orchestrator)
└─ User: /dispatch 1
   ├─ Monitor (background)
   │  └─ Window 1 (Worker)
   │     ├─ Analyzes repo
   │     ├─ Creates worktree
   │     ├─ Implements changes
   │     └─ Prints: ISSUE 1 COMPLETE
   │
   └─ User: /dispatch 2
      ├─ Monitor (background)
      │  └─ Window 2 (Worker)
      │     ├─ Analyzes repo
      │     ├─ Creates worktree
      │     ├─ Implements changes
      │     └─ Prints: ISSUE 2 COMPLETE
```

All concurrent. No conflicts. Fully automated.

---

## Support & Docs

| Need | See |
|------|-----|
| Quick 5-min start | `QUICKSTART.md` |
| Full documentation | `README.md` |
| System architecture | `ARCHITECTURE.md` |
| Using teams | `TEAMS-GUIDE.md` |
| Adding to project | `INTEGRATION.md` |
| Distributing | `PACKAGE-OPTIONS.md` |
| What's new | `CHANGELOG.md` |
| Project conventions | `CLAUDE.md` |

---

## TL;DR

```bash
# Add to your project
cp .claude/skills/orchestrator.md your-project/.claude/skills/

# Use it
cd your-project
tmux new-session
claude
/orchestrator init
/dispatch 1

# It works!
```

---

## Ready?

1. **Try it now** → Run through `QUICKSTART.md`
2. **Add to project** → Follow `INTEGRATION.md`
3. **Distribute** → Check `PACKAGE-OPTIONS.md`
4. **Go deep** → Read `ARCHITECTURE.md` and `TEAMS-GUIDE.md`

**Questions?** Everything is documented in the files listed above.

**Let's go! 🚀**
