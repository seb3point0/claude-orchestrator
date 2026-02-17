#!/usr/bin/env bash
# Claude Orchestrator Setup Script
# Run this from inside your project directory
# Example: bash ../claude-orchestrator/setup.sh

set -e

echo "🚀 Claude Orchestrator Setup"
echo "============================"
echo ""

# Get the directory where this script is located (orchestrator repo)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check we're in a git repository
if ! git rev-parse --git-dir &> /dev/null; then
    echo "✗ Error: Not in a git repository"
    echo "  Please run this script from inside your project directory"
    exit 1
fi

echo "✓ In git repository"
echo ""

# Ensure .claude directory exists
if [ ! -d ".claude" ]; then
    mkdir -p .claude
    echo "✓ Created .claude directory"
else
    echo "✓ .claude directory exists"
fi

echo ""
echo "📁 Setting up Claude Orchestrator files..."
echo ""

# Create subdirectories if they don't exist
mkdir -p .claude/commands
mkdir -p .claude/skills
mkdir -p .claude/claude-orchestrator-scripts

# Copy dispatch command
if [ -f ".claude/commands/dispatch.md" ]; then
    echo "  ℹ .claude/commands/dispatch.md already exists"
else
    cp "$SCRIPT_DIR/.claude/commands/dispatch.md" .claude/commands/
    echo "  ✓ .claude/commands/dispatch.md"
fi

# Copy orchestrator skill
if [ -f ".claude/skills/orchestrator.md" ]; then
    echo "  ℹ .claude/skills/orchestrator.md already exists"
else
    cp "$SCRIPT_DIR/.claude/skills/orchestrator.md" .claude/skills/
    echo "  ✓ .claude/skills/orchestrator.md"
fi

# Copy dispatch skill
if [ -f ".claude/skills/dispatch.md" ]; then
    echo "  ℹ .claude/skills/dispatch.md already exists"
else
    cp "$SCRIPT_DIR/.claude/skills/dispatch.md" .claude/skills/
    echo "  ✓ .claude/skills/dispatch.md"
fi

# Copy orchestrator scripts
if [ -f ".claude/claude-orchestrator-scripts/spawn-issue-worker.sh" ]; then
    echo "  ℹ .claude/claude-orchestrator-scripts/spawn-issue-worker.sh already exists"
else
    cp "$SCRIPT_DIR/.claude/claude-orchestrator-scripts/spawn-issue-worker.sh" \
       .claude/claude-orchestrator-scripts/
    echo "  ✓ .claude/claude-orchestrator-scripts/spawn-issue-worker.sh"
fi

# Set permissions
chmod +x .claude/claude-orchestrator-scripts/spawn-issue-worker.sh
echo ""
echo "✓ Permissions set"
echo ""

echo "✅ Setup complete!"
echo ""
echo "Your .claude folder now has:"
echo "  ├── commands/"
echo "  │   └── dispatch.md"
echo "  ├── skills/"
echo "  │   ├── orchestrator.md (initialization)"
echo "  │   └── dispatch.md (dispatch command)"
echo "  └── claude-orchestrator-scripts/"
echo "      └── spawn-issue-worker.sh"
echo ""
echo "Next steps:"
echo "1. Start a tmux session: tmux new-session -s orchestrator"
echo "2. Launch Claude: claude"
echo "3. Dispatch an issue: /dispatch 1"
echo ""
echo "To learn more, see: https://github.com/seb3point0/claude-orchestrator"
