# Distribution & Integration Guide

How to package and integrate the orchestrator into any Claude project.

## Recommended Approach: Hybrid

**Primary**: Skill-based initialization + supporting files
**Secondary**: Installation script
**Tertiary**: NPM package or template

This guide covers all approaches.

---

## Option A: Skill-Based Integration (RECOMMENDED)

### Overview

Create a main orchestrator skill that initializes and manages the system. Users add it to their project and invoke `/orchestrator init`.

### File Structure

```
.claude/
├── skills/
│   └── orchestrator.md        ← Main orchestrator skill
├── commands/
│   └── dispatch.md            ← Dispatch command
└── templates/
    ├── spawn-issue-worker.sh  ← Worker spawner template
    ├── CLAUDE.md              ← Project docs
    ├── TEAMS-GUIDE.md         ← Teams guide
    └── ...
```

### Skill Implementation

Create `.claude/skills/orchestrator.md`:

```markdown
---
allowed-tools: Bash, Read, Write, Glob
---

# Orchestrator Management Skill

Initialize and manage the GitHub Issue Orchestrator system.

## Commands

- `/orchestrator init` — Initialize orchestrator in this project
- `/orchestrator status` — Show orchestrator status
- `/orchestrator docs` — Show documentation

## Implementation

[Handles setup, validation, documentation]
```

### User Integration

```bash
# 1. User copies skill to their project
cp orchestrator.md their-project/.claude/skills/

# 2. User invokes skill
/orchestrator init

# 3. Skill sets up everything:
#    - Creates .claude/commands/dispatch.md
#    - Creates scripts/spawn-issue-worker.sh
#    - Creates project docs
#    - Verifies prerequisites
#    - Shows next steps
```

### Pros
- ✅ Single `/orchestrator` command namespace
- ✅ Skill can manage multiple orchestrator operations
- ✅ Feels native to Claude Code
- ✅ Can customize during init
- ✅ Easily discoverable

### Cons
- ⚠️ Requires users to manually copy skill
- ⚠️ Skill file needs to embed or reference templates

---

## Option B: Installation Script (EASIEST)

### Overview

Single bootstrap script that users run to set up everything.

### File Structure

```
claude-orchestrator/
├── install.sh                 ← Single installation script
├── templates/
│   ├── dispatch.md
│   ├── spawn-issue-worker.sh
│   ├── CLAUDE.md
│   └── ...
└── docs/
```

### Installation Script

Create `install.sh`:

```bash
#!/usr/bin/env bash
set -e

echo "🚀 Installing Claude Orchestrator..."

# Check prerequisites
check_prerequisites() {
    # Verify tmux, gh, claude, git
    # Exit if missing
}

# Copy files
copy_files() {
    mkdir -p .claude/commands scripts
    cp templates/dispatch.md .claude/commands/
    cp templates/spawn-issue-worker.sh scripts/
    chmod +x scripts/spawn-issue-worker.sh
    # Copy docs
}

# Verify setup
verify_setup() {
    # Check files exist
    # Verify executability
    # Test basic functionality
}

check_prerequisites
copy_files
verify_setup

echo "✅ Orchestrator installed!"
echo "Next: tmux new-session -s work && claude"
```

### User Integration

```bash
# 1. Clone/download orchestrator repo
git clone https://github.com/username/claude-orchestrator

# 2. Go to their project
cd my-project

# 3. Run install script
bash ../claude-orchestrator/install.sh

# 4. Done! Ready to use
/dispatch 1
```

### Pros
- ✅ Simplest for users (single command)
- ✅ No manual file copying
- ✅ Automatic verification
- ✅ Clear progress output
- ✅ Easy to automate

### Cons
- ⚠️ Requires orchestrator repo accessible
- ⚠️ Different workflow for different platforms

---

## Option C: NPM Package

### Overview

Distribute as npm package for easy installation.

### File Structure

```
claude-orchestrator/
├── package.json
├── bin/
│   └── install.js             ← CLI entry point
├── templates/
│   ├── dispatch.md
│   ├── spawn-issue-worker.sh
│   └── ...
├── lib/
│   └── installer.js           ← Installation logic
└── README.md
```

### package.json

```json
{
  "name": "@anthropic/claude-orchestrator",
  "version": "2.0.0",
  "description": "GitHub Issue Orchestrator for Claude Code",
  "bin": {
    "claude-orchestrator": "./bin/install.js"
  },
  "files": [
    "bin",
    "lib",
    "templates"
  ],
  "scripts": {
    "install": "node bin/install.js"
  }
}
```

### User Integration

```bash
# 1. Install package
npm install --save-dev @anthropic/claude-orchestrator

# 2. Run installation
npx claude-orchestrator init

# 3. Or auto-run on install
# (package.json postinstall hook)

# 4. Done!
/dispatch 1
```

### Pros
- ✅ Standard npm workflow
- ✅ Version management
- ✅ Easy distribution (npm registry)
- ✅ Can manage dependencies
- ✅ Auto-updates possible

### Cons
- ⚠️ Requires npm
- ⚠️ More setup for non-JS projects
- ⚠️ Need to publish to npm registry

---

## Option D: GitHub Template Repository

### Overview

Make orchestrator repo a GitHub template that users can use as starter.

### Setup

```
github.com/username/claude-orchestrator

Repository settings:
- Check "Template repository"
- Add topic "claude-code"
- Add "generator" topic
```

### User Integration

```bash
# 1. Click "Use this template" on GitHub
# 2. Create new repo from template
# 3. Clone and use immediately
#    (Everything already set up)

/dispatch 1
```

### Pros
- ✅ Simplest GitHub UX
- ✅ No installation needed
- ✅ Works immediately
- ✅ Easy to fork and customize

### Cons
- ⚠️ Creates new repo (not integration into existing)
- ⚠️ Best for new projects only
- ⚠️ Harder to update existing projects

---

## Option E: Git Submodule

### Overview

Add orchestrator as git submodule to any project.

### User Integration

```bash
# 1. Add as submodule
git submodule add https://github.com/username/claude-orchestrator orchestrator

# 2. Initialize
bash orchestrator/install.sh

# 3. Done!
/dispatch 1
```

### Pros
- ✅ Version controlled
- ✅ Easy updates (git submodule update)
- ✅ Works with existing projects
- ✅ Can customize locally

### Cons
- ⚠️ Submodule complexity
- ⚠️ Extra git operations
- ⚠️ Potential merge conflicts

---

## Recommendation: Multi-Channel Distribution

**Best practice is to support multiple installation methods:**

### Channel 1: Skill (Easiest for Claude Users)
```
# Users with Claude Code already working
/orchestrator init
```

### Channel 2: Installation Script (Most Reliable)
```bash
# Users who want direct control
bash ./install.sh
```

### Channel 3: NPM Package (Most Professional)
```bash
# JavaScript/Node.js projects
npm install @anthropic/claude-orchestrator
```

### Channel 4: GitHub Template (Best for New Projects)
```
# New projects: Use template repository
```

### Channel 5: Documentation (Manual Integration)
```
# Advanced users: Follow INTEGRATION.md guide
```

---

## Implementation: Skill-Based (Recommended Primary)

### `.claude/skills/orchestrator.md`

```markdown
---
allowed-tools: Bash, Read, Write, Glob
---

# Claude Orchestrator Setup

Set up the GitHub Issue Orchestrator system in your project.

## Quick Start

\`\`\`bash
/orchestrator init
\`\`\`

This will:
1. Create `.claude/commands/dispatch.md`
2. Create `scripts/spawn-issue-worker.sh`
3. Add project documentation
4. Verify prerequisites (tmux, gh, claude)

## Commands

- `init` — Initialize orchestrator (default)
- `status` — Show orchestrator status
- `check` — Verify prerequisites
- `help` — Show this help

## Usage After Setup

\`\`\`
/dispatch 123    # Dispatch issue #123
/dispatch 456    # Dispatch another issue
\`\`\`

## Documentation

- `CLAUDE.md` — Project conventions
- `README.md` — Full documentation
- `TEAMS-GUIDE.md` — Using teams
- `QUICKSTART.md` — Quick start guide
```

### Implementation Logic

The skill would:

1. Parse command (init, status, check, help)
2. If init:
   - Verify tmux, gh, claude installed
   - Check git repository
   - Create directories
   - Copy template files
   - Show summary
3. If status:
   - Check if orchestrator installed
   - Show version
   - List dispatch commands
4. If check:
   - Verify all prerequisites
   - Report any issues
5. If help:
   - Show documentation

---

## Distribution Checklist

When packaging for distribution, include:

- [ ] Clear installation instructions
- [ ] Prerequisites verification
- [ ] Template files (all 7 files)
- [ ] Setup/initialization logic
- [ ] Documentation (README, QUICKSTART, TEAMS-GUIDE, etc.)
- [ ] Error handling and validation
- [ ] Version management
- [ ] Update mechanism
- [ ] Troubleshooting guide
- [ ] Examples and use cases

---

## Recommended Implementation Path

### Phase 1: Current (v2.0)
- ✅ Complete standalone system in repository
- ✅ Installation script (setup.sh)
- ✅ Full documentation

### Phase 2: Skills Integration (Next)
- Create `.claude/skills/orchestrator.md` for initialization
- Create skill commands for common operations
- Distribute as part of orchestrator repo

### Phase 3: NPM Package (Future)
- Package for npm distribution
- Version management
- Publish to @anthropic namespace
- CI/CD for updates

### Phase 4: GitHub Templates (Future)
- Create template repository
- Use for new projects
- Maintain parity with npm package

---

## Quick Integration Guide

For users who want to integrate NOW:

### 1. Copy Files to Project

```bash
# From orchestrator repo to your project
cp -r .claude/commands .claude/
cp -r scripts .
cp CLAUDE.md TEAMS-GUIDE.md README.md .
chmod +x scripts/spawn-issue-worker.sh
```

### 2. Or Use Installation Script

```bash
# Download and run
bash <(curl -s https://raw.githubusercontent.com/username/claude-orchestrator/main/install.sh)
```

### 3. Or Add as Submodule

```bash
git submodule add https://github.com/username/claude-orchestrator orchestrator
bash orchestrator/install.sh
```

### 4. Verify Setup

```bash
# Check files
ls -la .claude/commands/dispatch.md
ls -la scripts/spawn-issue-worker.sh

# Check setup
tmux new-session -s test && claude
/dispatch 1
```

---

## Publishing Strategy

### GitHub
- Main repository
- Open source
- Community contributions
- Issues/discussions

### NPM Registry
- `@anthropic/claude-orchestrator`
- Semantic versioning
- Easy updates
- Dependency management

### Claude Code Marketplace
- If/when available
- One-click installation
- Built-in discovery

### Documentation
- Full website
- Video tutorials
- Integration guides
- Example projects

---

## Versioning

Current: `v2.0.0` (Teams & Worktrees)

Semantic versioning:
- `2.x.x` — Feature releases (new capabilities)
- `2.0.x` — Patch releases (bug fixes)
- `3.0.0` — Major breaking changes

---

## Support & Updates

For distribution, plan:
- Issue tracking on GitHub
- Community support via discussions
- Automated updates via npm
- Security patches process
- Deprecation notices

