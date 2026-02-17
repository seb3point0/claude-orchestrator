# System Architecture

Detailed explanation of the Claude Orchestrator system design.

## Components

### 1. Orchestrator (Main Session)

**Location**: Window 0 of tmux session
**Role**: Dispatch coordinator
**Language**: Claude Code (main session)

The orchestrator:
- Receives dispatch commands from user: `/dispatch 123`
- Fetches issue metadata via `gh` CLI
- Spawns Monitor Team Members (background agents)
- Reports to user when issues complete
- Can accept new dispatch commands immediately (non-blocking)

### 2. Monitor Team Member

**Role**: Lifecycle manager for a single issue
**Type**: Background subagent (Claude, general-purpose)
**Lifetime**: Spawned per dispatch, runs in background

Each monitor:
- Receives issue context from orchestrator
- Calls `scripts/spawn-issue-worker.sh` to start worker
- Polls tmux window every 30 seconds
- Detects completion via sentinel string: `ISSUE <N> COMPLETE`
- Reports completion back to orchestrator
- Cleans up: kills the worker's tmux window
- Exits

### 3. Worker Claude Session

**Location**: Dedicated tmux window (e.g., `issue-123`)
**Role**: Autonomous issue resolver
**Type**: Independent Claude Code session
**Workspace**: Git worktree at `.worktrees/issue-<N>/`

Each worker:
- Launches with full issue context in system prompt
- Performs repository analysis before coding
- Creates git worktree for isolated work
- Can dispatch team agents for complex tasks
- Has access to file editing, bash, git tools
- Works without user intervention
- Must print exactly: `ISSUE <N> COMPLETE` when done
- Can run arbitrarily long (no timeout)

### 4. Team Agents (Optional)

**Dispatched by**: Worker Claude sessions
**Role**: Specialized expertise for complex tasks
**Type**: Background subagents (like monitors)

Team agents handle:
- Frontend/backend/infra specialized work
- Large refactors spanning multiple files
- Cross-cutting concerns
- Parallel task execution

## Data Flow

```
User Input (orchestrator window)
    ↓
/dispatch 123
    ↓
[Orchestrator Claude]
    ├─ gh issue view 123 --json number,title,body,url
    ├─ → Returns: {number: 123, title: "...", body: "...", url: "..."}
    └─ [Task tool] → Spawn Monitor Team Member
        ↓
    [Monitor Team Member (background)]
        ├─ bash scripts/spawn-issue-worker.sh 123 "title" "url" "body"
        │  └─ Creates tmux window issue-123
        │  └─ Launches Claude in that window
        │  └─ Sends initial task message
        ├─ sleep 30
        ├─ tmux capture-pane -t session:issue-123 -p | grep "ISSUE 123 COMPLETE"
        │  → NOT FOUND
        ├─ sleep 30
        ├─ tmux capture-pane -t session:issue-123 -p | grep "ISSUE 123 COMPLETE"
        │  → FOUND!
        ├─ Extract summary from output
        ├─ [SendMessage to Orchestrator]: "Issue #123 complete. Branch: issue/123. Commits: ..."
        ├─ tmux kill-window -t session:issue-123
        └─ Exit
    ↓
[Orchestrator Claude]
    └─ Reports to user: "Issue #123 complete!"
```

## Git Worktree Strategy

### Why Worktrees?

Multiple workers need to work on different branches simultaneously without conflicts. Git worktrees allow:
- Multiple branches checked out at the same time
- Isolated working directories per branch
- Easy switching between work contexts
- Clean integration when work is done

### Worktree Structure

```
repo/
├── .                          ← Main worktree (main branch)
├── .worktrees/
│   ├── issue-123/             ← Worker 1 (branch: issue/123)
│   ├── issue-456/             ← Worker 2 (branch: issue/456)
│   └── issue-789/             ← Worker 3 (branch: issue/789)
```

### Worker Workflow with Worktrees

1. Worker spawns in tmux window
2. Worker runs: `git worktree add --track -b issue/<N> .worktrees/issue-<N> origin/main`
3. Worker changes: `cd .worktrees/issue-<N>`
4. Worker makes changes and commits
5. Main repo directory stays clean for other operations
6. When done: changes are on branch `issue/<N>` ready to merge

### Cleanup

After work completes:
```bash
git worktree remove .worktrees/issue-<N>  # Removes worktree
# Branch remains for merging/review
```

## Repository Analysis Phase

Before any coding, every worker:

1. **Explores structure**
   - What's the project type? (web app, library, CLI, etc.)
   - Directory organization? (src/, lib/, components/, etc.)
   - Main entry points and core modules

2. **Reads documentation**
   - README.md, ARCHITECTURE.md, CONTRIBUTING.md
   - Build process, testing setup
   - Deployment and release procedures

3. **Understands patterns**
   - Coding style and conventions
   - Commit message format
   - Error handling patterns
   - Testing requirements

4. **Checks for team structure**
   - Are there team agents defined? (.claude/skills/)
   - Which domains are specialized?
   - When to delegate to teams?

This ensures workers write code consistent with your project.

## Concurrency Model

### Without Teams (Sequential)

If orchestrator waits for each monitor to complete:
```
User: /dispatch 1
Orchestrator: → Monitor (waits for completion) → 5 minutes
User: /dispatch 2  ← Blocked, cannot proceed
```

### With Teams (Concurrent)

Orchestrator spawns monitors in background:
```
User: /dispatch 1
Orchestrator: → Monitor 1 (background) → immediately ready
User: /dispatch 2
Orchestrator: → Monitor 2 (background) → immediately ready
User: /dispatch 3
Orchestrator: → Monitor 3 (background) → immediately ready
(All three workers run concurrently)
```

## Polling Strategy

Monitors use **sequential polling** instead of a single loop:

**Why not a bash while loop?**
- Bash commands have a 2-minute timeout
- Long-running issues would exceed this
- Sequential tool calls have no timeout between calls

**Sequential polling steps:**
```
Turn 1: Bash tool - check tmux for completion signal
Turn 2: Bash tool - sleep 30 seconds
Turn 3: Bash tool - check tmux for completion signal
Turn 4: Bash tool - sleep 30 seconds
... repeat until completion detected
```

Each turn is a separate API call with no timeout between them.

## Completion Detection

### Sentinel String

Workers print: `ISSUE 123 COMPLETE`

This is:
- Unique and unlikely to appear accidentally
- Captured via `tmux capture-pane | grep`
- Reliable indicator of completion

### Why tmux capture-pane?

Instead of files or network calls:
- No file I/O required
- No shared state
- Works with isolated tmux windows
- Quick and reliable

```bash
tmux capture-pane -t "session:window" -p | grep "ISSUE 123 COMPLETE"
```

- `-t`: target window
- `-p`: print to stdout
- Grep: search for sentinel

## System Prompt Injection

Workers receive their task via system prompt:

```
claude --append-system-prompt "You are a worker for issue #123. Issue: ...
Instructions:
1. Implement changes
2. Make commits
3. Print: ISSUE 123 COMPLETE
..."
```

Benefits:
- No files to create or read
- Context passed securely
- Worker has all needed info immediately

## Error Handling

### Issue not found
```
Orchestrator: gh issue view 999 --json ...
→ Error: Could not resolve to an Issue
Orchestrator reports to user: "Issue #999 not found"
```

### Tmux session not found
```
Orchestrator: Not running in tmux
Scripts/spawn-issue-worker.sh: tmux display-message fails
Monitor reports: "Error: Must run orchestrator inside tmux session"
```

### Worker crashes
```
Monitor polls for 30s increments
Waits up to N cycles (configurable)
If worker never prints sentinel, monitor eventually times out
Reports: "Worker did not complete within timeout"
```

## Scalability

### Number of concurrent workers

Limited by:
- System resources (each Claude process needs memory)
- tmux window limit (usually very high)
- GitHub API rate limits (gh CLI)

Typical: 4-10 concurrent workers on a modern machine

### Very long issues

Sequential polling supports arbitrary durations:
- Monitor can wait hours/days if needed
- Each 30s poll is independent
- No cumulative timeout

## Security Considerations

### Isolation

Each worker:
- Runs in separate tmux window
- Separate Claude process (separate context)
- Can't see other windows or sessions
- Can't access orchestrator's memory

### Code execution

Workers can run arbitrary bash:
- `git clone`, `npm install`, `python scripts/`, etc.
- Should only be used in trusted environments
- Consider sandboxing if processing untrusted issues

### Issue content injection

Issue body is part of system prompt:
- Malicious issue could try to override instructions
- Workers should validate system prompt integrity
- Consider trimming/validating issue body length

## Teams Integration

### What are Teams?

Claude Teams provide specialized agents for different domains (web, admin, platform, infrastructure). Workers can dispatch team agents to handle complex, specialized tasks.

### When Workers Use Teams

**Simple issues** (change a few files, single concern):
```
Worker → Analyze → Implement → Commit → Done
```

**Complex issues** (span multiple domains or large refactors):
```
Worker → Analyze → Determine complexity
  ↓
  Spawn team-web for frontend
  Spawn team-api for backend
  Spawn team-infra for infrastructure
  ↓
Coordinate work → Integrate → Commit → Done
```

### Example: Authentication System

Issue: "Add OAuth2 authentication"

Worker's approach:
1. Analyze repo structure
2. Create worktree for issue/auth
3. Determine this needs:
   - Frontend: OAuth callback UI
   - Backend: Token endpoints
   - Infra: Secrets management
4. Dispatch team agents:
   - `team-web`: Implement OAuth flow UI
   - `team-api`: Implement token endpoints
   - `team-infra`: Configure secrets
5. Coordinate all changes in the worktree
6. Make final integrated commit
7. Print completion signal

### Team Agent Communication

Team agents receive:
- Worktree path (where to work)
- Issue context (what they're solving)
- Coordination context (what other teams are doing)

Teams can:
- Make changes in the worker's worktree
- Coordinate with each other
- Ask the main worker for clarifications
- Complete their specialized work independently

### Benefits

- **Specialization**: Each team has domain expertise
- **Parallelism**: Teams work concurrently
- **Coordination**: Main worker integrates and validates
- **Scalability**: Handle arbitrarily complex issues
- **Reusability**: Team agents can be reused across issues

## Files and Directories

```
.
├── .claude/
│   └── commands/
│       └── dispatch.md          ← /dispatch command definition
├── scripts/
│   └── spawn-issue-worker.sh    ← Spawns worker in tmux
├── CLAUDE.md                     ← Project conventions
├── README.md                     ← Full documentation
├── QUICKSTART.md                 ← Quick start guide
├── ARCHITECTURE.md               ← This file
└── .gitignore
```

## Configuration Points

### Worker system prompt
Edit: `scripts/spawn-issue-worker.sh`
Modify: `SYSTEM_PROMPT` variable

### Worker model
Edit: `scripts/spawn-issue-worker.sh`
Change: `--model sonnet` to `--model opus`, etc.

### Monitor polling interval
Edit: `.claude/commands/dispatch.md`
Change: `sleep 30` value in monitor prompt

### Completion timeout
Edit: `.claude/commands/dispatch.md`
Add max attempts check to monitor logic

## Future Enhancements

### Potential improvements:

1. **Worker output capture**
   - Save worker terminal output to file
   - Report detailed summary including logs

2. **Worker result validation**
   - Verify commits were made
   - Check branch exists
   - Validate code quality

3. **Issue dependency graph**
   - Dispatch multiple issues
   - Run in dependency order
   - Example: Issue #2 requires #1 to complete first

4. **Worker failure recovery**
   - Detect worker crash
   - Restart or escalate
   - Report failure details

5. **Metrics and monitoring**
   - Track issue completion time
   - Success/failure rates
   - Performance trends

6. **Web dashboard**
   - View all dispatched issues
   - Live status updates
   - Historical analytics
