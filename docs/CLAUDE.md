# GitHub Issue Orchestrator

An AI-powered workflow system where an orchestrator Claude session dispatches GitHub issues to autonomous worker Claude sessions running in tmux windows.

## Architecture

- **Window 0 (Orchestrator)**: Main Claude session where user dispatches issues
- **Window N (Worker)**: Autonomous worker sessions, one per issue, spawned via tmux
- **Monitor Team Members**: Background subagents that manage worker lifecycles

## Commands

### `/dispatch <issue-number>`

Dispatch a GitHub issue to an autonomous worker session:

```
/dispatch 4
```

This will:
1. Fetch issue #4 from GitHub
2. Spawn a Monitor Team Member (background task)
3. Create a new tmux window `issue-4` with a Worker Claude session
4. Worker autonomously implements the issue
5. When complete, worker prints "ISSUE 4 COMPLETE"
6. Monitor detects completion, reports back, and cleans up

## Worker Behavior

Workers run in isolated tmux windows with:
- Full GitHub issue context via system prompt
- Complete repository analysis phase before coding
- Automatic git worktree setup in `.worktrees/issue-<N>/`
- Access to Teams for complex, multi-domain tasks
- Access to git, editing, and code tools
- Requirement to print "ISSUE <N> COMPLETE" when done

### Worker Workflow

Each worker follows this sequence:

1. **Repository Analysis**
   - Explore directory structure and project type
   - Review documentation and architecture
   - Understand coding patterns and conventions

2. **Issue Analysis**
   - Fully understand the requirements
   - Identify affected files and modules
   - Assess complexity (decide if Teams are needed)

3. **Git Worktree Setup**
   - Create `.worktrees/issue-<N>/` with branch `issue/<N>`
   - All work happens in the worktree, never in main directory
   - Prevents conflicts with other concurrent workers

4. **Implementation**
   - Make atomic, focused commits
   - Use Teams for complex, cross-cutting work
   - Test and verify changes

5. **Completion**
   - Print sentinel: `ISSUE <N> COMPLETE`
   - Provide summary of work done

## Monitoring

Monitor Team Members poll the worker window every 30 seconds:

```bash
tmux capture-pane -t "session:issue-N" -p | grep "ISSUE N COMPLETE"
```

When detected, the monitor:
1. Reports completion to orchestrator
2. Extracts work summary from worker output
3. Closes the tmux window

## Concurrent Dispatch

Multiple issues can be dispatched while others are running:

```
/dispatch 4    # spawns issue-4 window, orchestrator stays free
/dispatch 43   # spawns issue-43 window while issue-4 is working
```

Both workers run concurrently in separate tmux windows, each with their own git worktree.

### Git Worktrees

Each worker operates in its own git worktree to prevent conflicts:

```
.worktrees/
├── issue-4/          # Worker 1 works here on issue #4
│   └── [branch: issue/4]
├── issue-43/         # Worker 2 works here on issue #43
│   └── [branch: issue/43]
└── issue-567/        # Worker 3 works here on issue #567
    └── [branch: issue/567]
```

Benefits:
- Multiple branches checked out simultaneously
- No merge conflicts during concurrent work
- Easy to review and merge changes
- Clean isolation between workers

## Using Teams for Complex Work

For large or complex issues, workers can dispatch team agents:

### When to use Teams:
- Multi-file refactors (5+ files across different modules)
- Features spanning multiple domains (web + backend + infra)
- Cross-cutting concerns (logging, error handling, validation)
- Specialized work requiring different expertise

### Example: Complex Feature

**Issue**: "Add API authentication system"

Worker's approach:
1. Analyze repo (understand architecture)
2. Create worktree for issue/X
3. Use Teams:
   - Dispatch `team-web` for frontend token handling
   - Dispatch `team-api` for auth endpoints
   - Dispatch `team-infra` for secrets management
4. Coordinate and integrate results
5. Make final commits in worktree
6. Print completion signal

## Project Conventions

- Commits should reference issue numbers: `Fix issue #4: description`
- Work autonomously without asking for confirmation
- Print completion sentinel exactly as shown: `ISSUE N COMPLETE`
- Use existing tools (Bash, Edit, Read, Write, Glob) for code changes
- Keep changes focused and atomic
