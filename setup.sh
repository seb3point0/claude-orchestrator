#!/usr/bin/env bash
# Setup script for Claude Orchestrator
# Downloads and installs from GitHub

set -e

echo "🚀 Claude Orchestrator Setup"
echo "============================"
echo ""

# Configuration
REPO_URL="https://raw.githubusercontent.com/Seb3.0/claude-orchestrator/main"
BRANCH="main"

# Check prerequisites
echo "✓ Checking prerequisites..."

if ! command -v claude &> /dev/null; then
    echo "✗ Claude Code CLI not found. Install it first:"
    echo "  https://github.com/anthropics/claude-code"
    exit 1
fi

if ! command -v tmux &> /dev/null; then
    echo "✗ tmux not found. Install it:"
    echo "  macOS: brew install tmux"
    echo "  Linux: apt-get install tmux"
    exit 1
fi

if ! command -v gh &> /dev/null; then
    echo "✗ GitHub CLI not found. Install it:"
    echo "  macOS: brew install gh"
    echo "  Linux: https://github.com/cli/cli/releases"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo "✗ GitHub CLI not authenticated. Run: gh auth login"
    exit 1
fi

if ! git rev-parse --git-dir &> /dev/null; then
    echo "✗ Not in a git repository"
    exit 1
fi

echo "✓ All prerequisites found"
echo ""

# Create directories
echo "📁 Creating directories..."
mkdir -p .claude/commands scripts
echo "✓ Directories created"
echo ""

# Download and setup files
echo "📄 Setting up files..."

# Download dispatch command
curl -s "$REPO_URL/.claude/commands/dispatch.md" -o .claude/commands/dispatch.md
echo "  ✓ .claude/commands/dispatch.md created"

# Download worker spawner script
curl -s "$REPO_URL/scripts/spawn-issue-worker.sh" -o scripts/spawn-issue-worker.sh
chmod +x scripts/spawn-issue-worker.sh
echo "  ✓ scripts/spawn-issue-worker.sh created (executable)"

echo ""

# Verify setup
echo "✓ Verifying setup..."
if [ ! -f ".claude/commands/dispatch.md" ]; then
    echo "✗ .claude/commands/dispatch.md not found"
    exit 1
fi

if [ ! -x "scripts/spawn-issue-worker.sh" ]; then
    echo "✗ scripts/spawn-issue-worker.sh not executable"
    exit 1
fi

echo "✓ All files verified"
echo ""

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Start a tmux session: tmux new-session -s orchestrator"
echo "2. Launch Claude: claude"
echo "3. Dispatch an issue: /dispatch 1"
echo ""
echo "See README: https://github.com/Seb3.0/claude-orchestrator"
