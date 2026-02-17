# Integration Guide: Adding Orchestrator to Your Project

How to integrate the Claude Orchestrator into an existing Claude project.

## Quick Start (5 minutes)

### Method 1: Skill Installation (Easiest)

```bash
# 1. Copy the orchestrator skill to your project
cp /path/to/claude-orchestrator/.claude/skills/orchestrator.md \
   your-project/.claude/skills/

# 2. Launch Claude in your project
cd your-project
tmux new-session -s work
claude

# 3. In Claude, run
/orchestrator init

# 4. Done! Ready to dispatch issues
/dispatch 1
```

### Method 2: Manual Installation

```bash
# 1. Create directories
mkdir -p your-project/.claude/commands
mkdir -p your-project/scripts

# 2. Copy core files
cp claude-orchestrator/.claude/commands/dispatch.md \
   your-project/.claude/commands/

cp claude-orchestrator/scripts/spawn-issue-worker.sh \
   your-project/scripts/
chmod +x your-project/scripts/spawn-issue-worker.sh

# 3. Copy documentation (optional but recommended)
cp claude-orchestrator/{CLAUDE.md,TEAMS-GUIDE.md,README.md} \
   your-project/

# 4. Done!
cd your-project
tmux new-session -s work
claude
/dispatch 1
```

### Method 3: Installation Script

```bash
# Run the orchestrator's setup script
cd your-project
bash ../claude-orchestrator/setup.sh

# Or combine paths
bash /path/to/claude-orchestrator/setup.sh
```

---

## Detailed Integration

### Step 1: Verify Prerequisites

Before integrating, ensure your project has:

```bash
# Check Claude Code
claude --version

# Check tmux
tmux -V

# Check GitHub CLI (and authenticate)
gh auth status

# Check git version (2.7.0+)
git --version

# Check working git repository
git log -1 --oneline
```

If any are missing, install them first.

### Step 2: Copy Files

#### Option A: Copy Everything

```bash
# Copy the entire orchestrator structure
cp -r claude-orchestrator/.claude your-project/
cp -r claude-orchestrator/scripts your-project/
cp claude-orchestrator/*.md your-project/

# Make scripts executable
chmod +x your-project/scripts/*.sh
```

#### Option B: Minimal Installation (Just the essentials)

```bash
# Only the files needed to dispatch
mkdir -p your-project/.claude/commands
mkdir -p your-project/scripts

cp claude-orchestrator/.claude/commands/dispatch.md \
   your-project/.claude/commands/

cp claude-orchestrator/scripts/spawn-issue-worker.sh \
   your-project/scripts/
chmod +x your-project/scripts/spawn-issue-worker.sh

# Documentation (recommended)
cp claude-orchestrator/CLAUDE.md your-project/
cp claude-orchestrator/TEAMS-GUIDE.md your-project/
```

#### Option C: Git Submodule

```bash
# Add as submodule
cd your-project
git submodule add https://github.com/username/claude-orchestrator orchestrator-system

# Create symlinks
ln -s orchestrator-system/.claude/commands .claude/commands
ln -s orchestrator-system/scripts scripts

# Or copy files
cp orchestrator-system/.claude/commands/dispatch.md .claude/commands/
cp orchestrator-system/scripts/spawn-issue-worker.sh scripts/
```

### Step 3: Verify Installation

```bash
# Check files exist
ls -la .claude/commands/dispatch.md
ls -la scripts/spawn-issue-worker.sh

# Check executable
ls -la scripts/spawn-issue-worker.sh | grep -q 'x' && echo "✓ Executable"

# Test git integration
git worktree list  # Should be empty initially

# Optional: Dry run
bash scripts/spawn-issue-worker.sh --help 2>/dev/null || echo "Script ready"
```

### Step 4: Customize (Optional)

Edit files for your project's needs:

#### Customize Worker Model

Edit `scripts/spawn-issue-worker.sh`:

```bash
# Find this line:
claude --append-system-prompt ... --model sonnet

# Change to:
claude --append-system-prompt ... --model opus      # More capable
claude --append-system-prompt ... --model haiku     # Faster
```

#### Customize Worktree Location

Edit `scripts/spawn-issue-worker.sh`:

```bash
# Find this line:
WINDOW_NAME="issue-${ISSUE_NUMBER}"

# Change to:
WINDOW_NAME="work-${ISSUE_NUMBER}"  # Custom naming
```

#### Customize Team Thresholds

Edit `scripts/spawn-issue-worker.sh` system prompt:

```markdown
**When to use Teams:**
- Change "5+ files" to your project's needs
- Adjust "large refactors" criteria
- Add domain-specific guidance
```

#### Project-Specific Conventions

Edit `CLAUDE.md` with your:
- Commit message format
- Branch naming conventions
- Testing requirements
- Code review process
- Project structure specifics

### Step 5: Test It Out

```bash
# 1. Start tmux session
tmux new-session -s orchestrator

# 2. Launch Claude (inside tmux)
claude

# 3. In Claude window, test dispatch
/dispatch 1    # Use a real issue number

# 4. Verify worker window created
tmux list-windows
# Should show: "issue-1" window

# 5. Watch it work
tmux capture-pane -t orchestrator:issue-1 -p

# 6. When complete
# Worker prints: ISSUE 1 COMPLETE
# Monitor closes the window

# 7. Review changes
git log issue/1
git diff main issue/1
```

---

## Project-Specific Integration

### For Node.js / JavaScript Projects

```bash
# Add to your project
npm install --save-dev claude-orchestrator  # (if published to npm)

# Or copy files
cp -r ../claude-orchestrator/scripts .
cp -r ../claude-orchestrator/.claude .

# The worker will:
# - Detect package.json
# - Understand npm/TypeScript/Jest setup
# - Follow existing code style
# - Run tests as needed
```

### For Python Projects

```bash
# Copy orchestrator
cp -r ../claude-orchestrator/scripts .
cp -r ../claude-orchestrator/.claude .

# The worker will:
# - Detect setup.py / pyproject.toml
# - Understand project structure
# - Follow PEP 8 conventions
# - Run pytest/tests as needed
```

### For Monorepos

```bash
# Copy to monorepo root
cp -r ../claude-orchestrator/scripts .
cp -r ../claude-orchestrator/.claude .

# The worker will:
# - Create worktrees at root: .worktrees/issue-N/
# - Access all packages
# - Make cross-package changes
# - Coordinate dependencies
```

### For Microservices

```bash
# Option A: One orchestrator at repo root
# (Recommended)
# All services share orchestrator
# Workers can span multiple services

# Option B: Orchestrator per service
# Copy to each service directory
# Each has own dispatch workflow
```

---

## Updating Your Installation

### When Claude Orchestrator Updates

```bash
# Option 1: Re-copy files
cd your-project
cp -r ../claude-orchestrator/.claude/commands .claude/
cp ../claude-orchestrator/scripts/spawn-issue-worker.sh scripts/

# Option 2: If using submodule
cd your-project
git submodule update --remote orchestrator-system

# Option 3: Manual merge
# Compare your files with updated orchestrator
# Merge any improvements
```

---

## Verification Checklist

After integration, verify:

- [ ] `.claude/commands/dispatch.md` exists
- [ ] `scripts/spawn-issue-worker.sh` exists
- [ ] Script is executable: `ls -la scripts/spawn-issue-worker.sh | grep x`
- [ ] Can launch Claude: `tmux new && claude`
- [ ] `/dispatch` command is recognized
- [ ] GitHub CLI authenticated: `gh auth status`
- [ ] Git is ready: `git status`
- [ ] Documentation updated with project specifics

### Verification Commands

```bash
# All in one
echo "Checking orchestrator installation..."
[ -f ".claude/commands/dispatch.md" ] && echo "✓ dispatch.md" || echo "✗ dispatch.md missing"
[ -x "scripts/spawn-issue-worker.sh" ] && echo "✓ worker script executable" || echo "✗ worker script not executable"
gh auth status &>/dev/null && echo "✓ gh authenticated" || echo "✗ gh not authenticated"
git rev-parse --git-dir &>/dev/null && echo "✓ git repo" || echo "✗ not a git repo"
command -v tmux &>/dev/null && echo "✓ tmux installed" || echo "✗ tmux not installed"
command -v claude &>/dev/null && echo "✓ claude installed" || echo "✗ claude not installed"
```

---

## Troubleshooting Integration

### "dispatch.md not found"

```bash
# Check path
ls -la .claude/commands/

# If missing, copy it
cp ../claude-orchestrator/.claude/commands/dispatch.md .claude/commands/

# Restart Claude
# Exit and re-launch
```

### "Worker script is not executable"

```bash
# Fix permissions
chmod +x scripts/spawn-issue-worker.sh

# Verify
ls -la scripts/spawn-issue-worker.sh
# Should show: -rwxr-xr-x
```

### "/dispatch command not recognized"

```bash
# Ensure tmux + Claude launched correctly
tmux list-sessions      # See your sessions
tmux new-window         # Create a new window in the session
claude                  # Launch Claude in that window

# Type /dispatch
# If still not recognized:
# - Check .claude/commands/ has dispatch.md
# - Restart Claude completely
```

### "No tmux session found"

```bash
# Orchestrator must run inside tmux
tmux new-session -s orchestrator
claude  # Launch inside the tmux session

# Then:
/dispatch 1
```

### "gh issue view fails"

```bash
# Check GitHub CLI auth
gh auth status
gh auth login    # Re-authenticate if needed

# Check repo access
gh issue list    # Try listing issues

# Check issue exists
gh issue view 1  # Replace 1 with real issue number
```

### "Worker doesn't create worktree"

```bash
# Check git version
git --version    # Must be 2.7.0+

# Check worktree status
git worktree list

# Manual test
git worktree add --track -b test-branch .worktrees/test origin/main
# If this works, the infrastructure is fine

# Check worker output
tmux capture-pane -t orchestrator:issue-1 -p | head -20
```

---

## Integration Examples

### Example 1: Simple Integration

**My-Project structure:**
```
my-project/
├── src/
├── tests/
├── .git
└── .claude/
    └── commands/
        └── dispatch.md    ← Added
scripts/
    └── spawn-issue-worker.sh    ← Added
```

**Steps:**
```bash
cd my-project
mkdir -p .claude/commands scripts
cp ~/claude-orchestrator/.claude/commands/dispatch.md .claude/commands/
cp ~/claude-orchestrator/scripts/spawn-issue-worker.sh scripts/
chmod +x scripts/spawn-issue-worker.sh

# Ready!
tmux new-session -s dev
claude
/dispatch 1
```

### Example 2: Monorepo Integration

**Monorepo structure:**
```
monorepo/
├── services/
│   ├── api/
│   ├── web/
│   └── worker/
├── shared/
├── .git
├── .claude/
│   └── commands/
│       └── dispatch.md
└── scripts/
    └── spawn-issue-worker.sh
```

**Steps:**
```bash
cd monorepo
# (Same as simple integration)
# Workers can now span multiple services
/dispatch 1    # Issue affecting api/ service
/dispatch 2    # Issue affecting multiple services
/dispatch 3    # Infrastructure issue
# All work in parallel
```

### Example 3: Submodule Integration

**Setup:**
```bash
cd my-project
git submodule add https://github.com/username/claude-orchestrator orchestrator
bash orchestrator/setup.sh    # Copies files and sets up
```

**Benefits:**
- Automatic updates: `git submodule update --remote`
- Version controlled
- Easy to customize locally

---

## Next Steps After Integration

1. **Dispatch your first issue**
   ```bash
   /dispatch 1
   ```

2. **Monitor it**
   - Watch tmux window appear
   - See repo analysis happen
   - See worktree creation
   - See implementation

3. **Review the work**
   ```bash
   git log issue/1
   git diff main issue/1
   git show issue/1:changed-file.js
   ```

4. **Merge when ready**
   ```bash
   git checkout main
   git merge --no-ff issue/1 -m "Merge issue #1"
   ```

5. **Dispatch more issues**
   ```bash
   /dispatch 2
   /dispatch 3
   /dispatch 4
   ```

6. **For complex issues**, orchestrator automatically uses teams

---

## Support

- **QUICKSTART.md** — Quick 5-minute walkthrough
- **README.md** — Full documentation
- **TEAMS-GUIDE.md** — Using teams for complex work
- **ARCHITECTURE.md** — System design
- **TROUBLESHOOTING** — Common issues

---

## Questions?

- See DISTRIBUTION.md for packaging options
- See CHANGELOG.md for what's new
- Check CLAUDE.md for project conventions
- Review ARCHITECTURE.md for deep technical details
