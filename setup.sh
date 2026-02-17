#!/usr/bin/env bash
# Setup script for Claude Orchestrator
# Run this to initialize the orchestrator in your project

set -e

echo "🚀 Claude Orchestrator Setup"
echo "============================"
echo ""

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

# Verify gh auth
if ! gh auth status &> /dev/null; then
    echo "✗ GitHub CLI not authenticated. Run: gh auth login"
    exit 1
fi

echo "✓ All prerequisites found"
echo ""

# Create directories
echo "📁 Creating directories..."
mkdir -p .claude/commands scripts
echo "✓ Directories created"
echo ""

# Copy files if not already present
echo "📄 Setting up files..."

copy_if_missing() {
    local src=$1
    local dst=$2
    if [ -f "$dst" ]; then
        echo "  ℹ $dst already exists"
    else
        cp "$src" "$dst"
        echo "  ✓ $dst created"
    fi
}

# Try to copy from orchestrator directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

copy_if_missing "$SCRIPT_DIR/.claude/commands/dispatch.md" ".claude/commands/dispatch.md"

if [ ! -f "scripts/spawn-issue-worker.sh" ]; then
    cp "$SCRIPT_DIR/scripts/spawn-issue-worker.sh" "scripts/spawn-issue-worker.sh"
    chmod +x "scripts/spawn-issue-worker.sh"
    echo "  ✓ scripts/spawn-issue-worker.sh created (executable)"
else
    echo "  ℹ scripts/spawn-issue-worker.sh already exists"
fi

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

# Environment check
echo "🔧 Environment configuration..."
if [ -z "$CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" ]; then
    echo "⚠️  CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS not set"
    echo "   To enable team features, run:"
    echo "   export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1"
    echo ""
fi

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Start a tmux session: tmux new-session -s orchestrator"
echo "2. Launch Claude: claude"
echo "3. Dispatch an issue: /dispatch 1"
echo ""
echo "See QUICKSTART.md for detailed instructions"
