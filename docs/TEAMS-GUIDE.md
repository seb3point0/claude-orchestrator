# Teams Integration Guide

How worker agents use Claude Teams for complex issues.

## Overview

For simple issues, workers handle everything. For complex issues spanning multiple domains, workers can dispatch specialized team agents to work in parallel.

## When to Use Teams

### Simple Issues (Worker Handles Alone)

```
"Fix typo in README"
"Add new CLI flag to existing command"
"Update dependency version"
"Refactor single module"
```

**Process**: Analyze → Modify → Commit → Done

### Complex Issues (Dispatch Teams)

```
"Add OAuth2 authentication system"
"Migrate database from PostgreSQL to MongoDB"
"Implement real-time notifications"
"Refactor API and frontend together"
```

**Process**: Analyze → Create worktree → Dispatch teams → Coordinate → Commit → Done

## Architecture

```
┌─────────────────────────────────────────┐
│   Worker Claude (in tmux window)        │
│   ├─ Analyzes issue                     │
│   ├─ Creates worktree                   │
│   ├─ Decides: "Need teams"              │
│   ├─ Dispatches teams (background)      │
│   ├─ Coordinates results                │
│   └─ Makes final commit                 │
└─────────────────────────────────────────┘
          ↓
    [Teams working in parallel]
    ├─ team-web (frontend)
    ├─ team-api (backend)
    └─ team-infra (infrastructure)
```

## Example: OAuth2 Authentication

### Issue Description

"Add OAuth2 authentication to the app. Users should be able to sign in with Google and GitHub. Credentials should be securely stored. Frontend needs a login page and user profile page. Backend needs to handle token exchange and user creation."

### Worker's Analysis

**Complexity Check**:
- ✓ Spans frontend (UI, routing, state)
- ✓ Spans backend (auth endpoints, database)
- ✓ Spans infrastructure (secrets, credentials)
- ✓ Affects multiple modules
- **→ Use Teams**

### Worker's Approach

```bash
# 1. Worker starts in issue-auth window
# 2. Creates worktree
git worktree add --track -b issue/oauth2 .worktrees/issue-oauth2 origin/main
cd .worktrees/issue-oauth2

# 3. Analyzes repo structure
ls -la
# Sees: frontend/, backend/, infra/

# 4. Creates coordination document (optional)
echo "## OAuth2 Implementation Tasks
# - Frontend: Login page, callback handler, user profile
# - Backend: /auth/callback endpoint, token storage, user service
# - Infra: Google/GitHub OAuth credentials, environment variables
# " > OAUTH2_TASKS.md

# 5. Dispatches teams via Task tool
```

**Task 1: Dispatch team-web**
```
task:
  subagent_type: team-web
  description: Implement OAuth2 frontend
  prompt: |
    You're working on issue #123: OAuth2 authentication.
    Worktree: /repo/.worktrees/issue-oauth2
    Your task (team-web):
    1. Create login page with Google/GitHub buttons
    2. Handle OAuth callbacks at /auth/callback
    3. Store tokens securely in browser
    4. Add user profile page showing logged-in user
    5. Commit changes in the worktree
```

**Task 2: Dispatch team-api**
```
task:
  subagent_type: team-api
  description: Implement OAuth2 backend
  prompt: |
    You're working on issue #123: OAuth2 authentication.
    Worktree: /repo/.worktrees/issue-oauth2
    Your task (team-api):
    1. Create User model with OAuth fields
    2. Implement POST /auth/callback endpoint
    3. Implement token validation middleware
    4. Create user creation/lookup logic
    5. Commit changes in the worktree
```

**Task 3: Dispatch team-infra**
```
task:
  subagent_type: team-infra
  description: Configure OAuth2 secrets
  prompt: |
    You're working on issue #123: OAuth2 authentication.
    Worktree: /repo/.worktrees/issue-oauth2
    Your task (team-infra):
    1. Create .env.example with OAuth credential placeholders
    2. Update CI/CD to handle OAuth environment variables
    3. Document secrets management process
    4. Ensure prod/staging/dev configurations work
    5. Commit changes in the worktree
```

### Execution Timeline

```
T=0s    Worker: Creates worktree, analyzes, dispatches teams
T=0s    team-web starts: Creates frontend components
T=0s    team-api starts: Creates backend endpoints
T=0s    team-infra starts: Configures secrets
T=60s   team-web: "Login page done, callback handler done"
T=90s   team-api: "OAuth endpoints ready, token storage done"
T=120s  team-infra: "Secrets configured, env files updated"
T=150s  Worker: Reviews all changes, integrates, makes final commit
T=160s  Worker: Prints "ISSUE 123 COMPLETE"
T=162s  Monitor: Detects completion, reports back
```

## Team Agent Responsibilities

Each team agent receives:
- **Worktree path**: Where to work (`.worktrees/issue-oauth2/`)
- **Issue context**: Full issue description and requirements
- **Domain focus**: What they're responsible for
- **Integration points**: How their work connects

Team agents must:
1. Make changes in the specified worktree (never main repo)
2. Make atomic commits with issue number reference
3. Report completion and summary back
4. Not interfere with other teams' work areas

## Coordination Patterns

### Pattern 1: Sequential Teams

If teams have dependencies (B needs A to finish first):

```python
# Worker code (pseudocode)
dispatch(team-database, ...)  # Create schema first
await(team-database-complete)
dispatch(team-api, ...)       # API depends on schema
await(team-api-complete)
dispatch(team-web, ...)       # Frontend depends on API
```

### Pattern 2: Parallel Teams

If teams can work independently:

```python
# Worker code (pseudocode)
dispatch(team-frontend, ...)
dispatch(team-backend, ...)
dispatch(team-infra, ...)
# All run concurrently
await_all()
```

### Pattern 3: Coordinated Teams

If teams need to share information:

```python
# Worker code (pseudocode)
# Create shared spec document
write("API_SPEC.md", api_design)

# Teams reference it
dispatch(team-frontend, context="See API_SPEC.md")
dispatch(team-backend, context="See API_SPEC.md")

await_all()
integrate_results()
```

## Best Practices

### 1. Clear Domain Boundaries

Define what each team handles:
- **team-web**: Frontend UI, routing, client state
- **team-api**: Backend endpoints, business logic, database
- **team-infra**: Secrets, env config, CI/CD, deployment

### 2. Atomic Commits

Each team makes focused commits:
```
[team-web] issue #123: Add OAuth login page
[team-api] issue #123: Add /auth/callback endpoint
[team-infra] issue #123: Configure OAuth secrets
```

### 3. Integration Points

Document how pieces fit together:
```
Frontend → POST /auth/callback → Backend
Backend → Lookup credentials → Infra
Infra → Provide secrets to Backend
```

### 4. Testing

Teams should validate their own work:
- **team-web**: Manual testing in browser
- **team-api**: Unit tests for new endpoints
- **team-infra**: Verify env configs load correctly

Worker then runs integration tests.

## Examples

### Example 1: Simple Issue (No Teams)

```
Issue: "Add dark mode to settings"

Worker:
1. Analyzes: Single module (settings page)
2. Finds: CSS and JavaScript to modify
3. Makes changes directly
4. Tests in browser
5. Commits: "[issue #42] Add dark mode toggle"
6. Done
```

### Example 2: Medium Issue (Minimal Teams)

```
Issue: "Add user preferences API endpoint"

Worker:
1. Analyzes: Backend work (mostly)
2. Sees: Needs tiny frontend adjustment
3. Handles backend personally
4. Dispatches team-web: "Update settings UI to use new API"
5. Waits for team-web to finish
6. Integrates, makes final commit
7. Done
```

### Example 3: Large Issue (Multiple Teams)

```
Issue: "Implement real-time chat feature"

Worker:
1. Analyzes: Needs WebSocket support, UI, backend, infra
2. Dispatches teams (all parallel):
   - team-web: Chat UI, WebSocket client
   - team-api: Chat endpoints, message storage
   - team-infra: WebSocket server config, database
3. Coordinates: Ensures all teams work together
4. Integrates: Makes final commit combining all changes
5. Done
```

## Troubleshooting

### Team Doesn't Commit Changes

- Check team received correct worktree path
- Verify team ran `cd .worktrees/issue-<N>` before making changes
- Look for team error messages

### Teams Conflict with Each Other

- Define clear file/module boundaries upfront
- Document integration points
- Have teams commit to different files if possible

### Worker Doesn't See Team Changes

- Verify teams are working in the worktree
- Check git log: `git log issue/<N>`
- Pull team commits: `git fetch`

### Completion Signal Not Detected

- Worker must print `ISSUE <N> COMPLETE` after teams finish and final commit is made
- Teams should print progress but not the completion signal
- Only the main worker signals completion

## Performance Considerations

### Team Parallelism

```
Without teams:
  Worker: 10 minutes (does everything)

With teams:
  team-web: 3 minutes
  team-api: 4 minutes
  team-infra: 2 minutes
  Parallel execution: ~4 minutes total
  Worker coordination: 1 minute
  Total: ~5 minutes (50% faster!)
```

### When NOT to Use Teams

- Small, single-file changes
- Single-module work
- Quick bug fixes
- If overhead > benefit

### When to Use Teams

- Multi-file changes (5+)
- Cross-cutting concerns
- Complex architectures
- If parallel work saves time

## Future Enhancements

- **Team dependencies**: Specify teams that must complete before others start
- **Team communication**: Teams exchange information (APIs, schemas)
- **Team validation**: Teams verify each other's work
- **Metrics**: Track team performance and time to completion
