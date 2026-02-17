#!/usr/bin/env bash
# Local setup script for Claude Orchestrator
# Run this from inside your project directory with the orchestrator repo nearby
# Example: bash ../claude-orchestrator/setup.sh

set -e

echo "🚀 Claude Orchestrator Setup"
echo "============================"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check we're in a git repo
if ! git rev-parse --git-dir &> /dev/null; then
    echo "✗ Not in a git repository"
    exit 1
fi

echo "✓ In git repository"
echo ""

# Copy .claude folder
echo "📁 Copying .claude folder..."
cp -r "$SCRIPT_DIR/.claude" .
echo "✓ .claude folder copied"
echo ""

# Make spawner executable
chmod +x .claude/scripts/spawn-issue-worker.sh
echo "✓ Permissions set"
echo ""

echo "✅ Setup complete!"
echo ""
echo "Your project now has:"
echo "  .claude/commands/dispatch.md"
echo "  .claude/scripts/spawn-issue-worker.sh"
echo "  .claude/skills/orchestrator.md"
echo ""
echo "Next steps:"
echo "1. Start a tmux session: tmux new-session -s work"
echo "2. Launch Claude: claude"
echo "3. Dispatch an issue: /dispatch 1"
