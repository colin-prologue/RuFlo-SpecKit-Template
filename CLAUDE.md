# Claude Code Configuration - RuFlo V3

## Behavioral Rules (Always Enforced)

- Do what has been asked; nothing more, nothing less
- NEVER create files unless they're absolutely necessary for achieving your goal
- ALWAYS prefer editing an existing file to creating a new one
- NEVER proactively create documentation files (*.md) or README files unless explicitly requested
- NEVER save working files, text/mds, or tests to the root folder
- Never continuously check status after spawning a swarm — wait for results
- ALWAYS read a file before editing it
- NEVER commit secrets, credentials, or .env files

## File Organization

- NEVER save to root folder — use the directories below
- Use `/src` for source code files
- Use `/tests` for test files
- Use `/docs` for documentation and markdown files
- Use `/config` for configuration files
- Use `/scripts` for utility scripts
- Use `/examples` for example code

## Project Architecture

- Follow Domain-Driven Design with bounded contexts
- Keep files under 500 lines
- Use typed interfaces for all public APIs
- Prefer TDD London School (mock-first) for new code
- Use event sourcing for state changes
- Ensure input validation at system boundaries

### Project Config

- **Topology**: hierarchical-mesh
- **Max Agents**: 15
- **Memory**: hybrid
- **HNSW**: Enabled
- **Neural**: Enabled

## Spec-Driven Workflow (Claude-Root Integration)

### Governing Principles
All feature work follows this workflow. Each step is a gate — do not skip forward.

| Step | Command | Gate |
|---|---|---|
| 0. Calibrate governance | `/sparc-constitution` | Once per project (or when context changes) |
| 1. Ideate | `/sparc-brainstorm` | Optional but recommended for new features |
| 2. Specify | `/sparc-specify` | Required before planning |
| 3. Review spec | `/sparc-review` | Required at FULL/STANDARD rigor |
| 4. Plan | `/sparc-plan` | Required before tasks |
| 5. Review plan | `/sparc-review` | Required at FULL/STANDARD rigor |
| 6. Generate tasks | `/sparc-tasks` | Required before implementation |
| 7. Review tasks | `/sparc-review` | Required at FULL rigor |
| 8. Implement | `/sparc-implement` | Execute tasks in TDD order |
| 9. Audit | `/sparc-audit` | After implementation |
| 10. Retro | `/sparc-retro` | After each phase |

### Hard Rules (Never Violate)
- ALWAYS run `/sparc-constitution` before starting work on a new project
- NEVER proceed past planning without at least one ADR per technology choice
- All decisions live in `.decisions/` as `ADR_NNN_*.md` or `LOG_NNN_*.md`
- ADRs and LOGs share a sequential counter — check both to get the next number
- Review phases are hard gates: user must choose PROCEED / REVISE / RE-REVIEW / OVERRIDE
- OVERRIDE always creates a LOG entry documenting the accepted risk
- Task order is fixed: write failing test → implement → verify → next task

### Decision Record Conventions
- `.decisions/ADR_NNN_*.md` — technology choices and architectural decisions
- `.decisions/LOG_NNN_*.md` — open questions, challenges, risks, tracked assumptions
- Shared sequential counter: ADR_001, LOG_002, ADR_003 (not separate sequences)
- Cross-reference every ADR and LOG from the artifact where the decision was made

### Spec File Conventions
- `specs/[feature]-spec.md` — feature specification
- `specs/[feature]-plan.md` — technical plan
- `specs/[feature]-research.md` — research findings
- `specs/[feature]-tasks.md` — implementation tasks
- `specs/roadmap.md` — project roadmap (maintained by brainstorm + retro)
- `specs/brainstorm-notes.md` — brainstorm session notes
- `constitution.md` — project governance calibration (at project root)

## Build & Test

```bash
# Build
npm run build

# Test
npm test

# Lint
npm run lint
```

- ALWAYS run tests after making code changes
- ALWAYS verify build succeeds before committing

## Security Rules

- NEVER hardcode API keys, secrets, or credentials in source files
- NEVER commit .env files or any file containing secrets
- Always validate user input at system boundaries
- Always sanitize file paths to prevent directory traversal
- Run `npx @claude-flow/cli@latest security scan` after security-related changes

## Concurrency: 1 MESSAGE = ALL RELATED OPERATIONS

- All operations MUST be concurrent/parallel in a single message
- Use Claude Code's Task tool for spawning agents, not just MCP
- ALWAYS batch ALL todos in ONE TodoWrite call (5-10+ minimum)
- ALWAYS spawn ALL agents in ONE message with full instructions via Task tool
- ALWAYS batch ALL file reads/writes/edits in ONE message
- ALWAYS batch ALL Bash commands in ONE message

## Swarm Orchestration

- MUST initialize the swarm using CLI tools when starting complex tasks
- MUST spawn concurrent agents using Claude Code's Task tool
- Never use CLI tools alone for execution — Task tool agents do the actual work
- MUST call CLI tools AND Task tool in ONE message for complex work

### 3-Tier Model Routing (ADR-026)

| Tier | Handler | Latency | Cost | Use Cases |
|------|---------|---------|------|-----------|
| **1** | Agent Booster (WASM) | <1ms | $0 | Simple transforms (var→const, add types) — Skip LLM |
| **2** | Haiku | ~500ms | $0.0002 | Simple tasks, low complexity (<30%) |
| **3** | Sonnet/Opus | 2-5s | $0.003-0.015 | Complex reasoning, architecture, security (>30%) |

- Always check for `[AGENT_BOOSTER_AVAILABLE]` or `[TASK_MODEL_RECOMMENDATION]` before spawning agents
- Use Edit tool directly when `[AGENT_BOOSTER_AVAILABLE]`

## Swarm Configuration & Anti-Drift

- ALWAYS use hierarchical topology for coding swarms
- Keep maxAgents at 6-8 for tight coordination
- Use specialized strategy for clear role boundaries
- Use `raft` consensus for hive-mind (leader maintains authoritative state)
- Run frequent checkpoints via `post-task` hooks
- Keep shared memory namespace for all agents

```bash
npx @claude-flow/cli@latest swarm init --topology hierarchical --max-agents 8 --strategy specialized
```

## Swarm Execution Rules

- ALWAYS use `run_in_background: true` for all agent Task calls
- ALWAYS put ALL agent Task calls in ONE message for parallel execution
- After spawning, STOP — do NOT add more tool calls or check status
- Never poll TaskOutput or check swarm status — trust agents to return
- When agent results arrive, review ALL results before proceeding

## V3 CLI Commands

### Core Commands

| Command | Subcommands | Description |
|---------|-------------|-------------|
| `init` | 4 | Project initialization |
| `agent` | 8 | Agent lifecycle management |
| `swarm` | 6 | Multi-agent swarm coordination |
| `memory` | 11 | AgentDB memory with HNSW search |
| `task` | 6 | Task creation and lifecycle |
| `session` | 7 | Session state management |
| `hooks` | 17 | Self-learning hooks + 12 workers |
| `hive-mind` | 6 | Byzantine fault-tolerant consensus |

### Quick CLI Examples

```bash
npx @claude-flow/cli@latest init --wizard
npx @claude-flow/cli@latest agent spawn -t coder --name my-coder
npx @claude-flow/cli@latest swarm init --v3-mode
npx @claude-flow/cli@latest memory search --query "authentication patterns"
npx @claude-flow/cli@latest doctor --fix
```

## Available Agents (60+ Types)

### Core Development
`coder`, `reviewer`, `tester`, `planner`, `researcher`

### Specialized
`security-architect`, `security-auditor`, `memory-specialist`, `performance-engineer`

### Swarm Coordination
`hierarchical-coordinator`, `mesh-coordinator`, `adaptive-coordinator`

### GitHub & Repository
`pr-manager`, `code-review-swarm`, `issue-tracker`, `release-manager`

### SPARC Methodology
`sparc-coord`, `sparc-coder`, `specification`, `pseudocode`, `architecture`

## Memory Commands Reference

```bash
# Store (REQUIRED: --key, --value; OPTIONAL: --namespace, --ttl, --tags)
npx @claude-flow/cli@latest memory store --key "pattern-auth" --value "JWT with refresh" --namespace patterns

# Search (REQUIRED: --query; OPTIONAL: --namespace, --limit, --threshold)
npx @claude-flow/cli@latest memory search --query "authentication patterns"

# List (OPTIONAL: --namespace, --limit)
npx @claude-flow/cli@latest memory list --namespace patterns --limit 10

# Retrieve (REQUIRED: --key; OPTIONAL: --namespace)
npx @claude-flow/cli@latest memory retrieve --key "pattern-auth" --namespace patterns
```

## Quick Setup

```bash
# 1. Add the core RuFlo MCP (required)
claude mcp add claude-flow -- npx -y @claude-flow/cli@latest
npx @claude-flow/cli@latest daemon start
npx @claude-flow/cli@latest doctor --fix

# 2. Set environment variables for optional MCPs (in your shell profile or .env)
# GitHub MCP — enables github:* commands (PR manager, code-review-swarm, issue-tracker)
export GITHUB_TOKEN=ghp_your_token_here

# Postgres MCP — enables direct DB access during implementation (omit if using SQLite only)
export DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# SQLite MCP — enabled by default at ./data/local.db (no env var needed)
```

**MCP servers included in this template** (activate automatically when env vars are set):
- `github` — GitHub API via `GITHUB_TOKEN`
- `sequential-thinking` — structured reasoning (no credentials needed)
- `postgres` — database access via `DATABASE_URL`
- `sqlite` — local SQLite at `./data/local.db` (no credentials needed)

## Claude Code vs CLI Tools

- Claude Code's Task tool handles ALL execution: agents, file ops, code generation, git
- CLI tools handle coordination via Bash: swarm init, memory, hooks, routing
- NEVER use CLI tools as a substitute for Task tool agents

## Support

- Documentation: https://github.com/ruvnet/claude-flow
- Issues: https://github.com/ruvnet/claude-flow/issues
