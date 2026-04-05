# Claude Code Template

A project template combining [RuFlo](https://github.com/ruvnet/claude-flow) agent orchestration with a structured spec-driven workflow. Every feature follows a consistent path from idea to shipped code, with built-in checks and balances at each step.

---

## Setup

**Requirements:** Node.js 18+, Claude Code CLI

```bash
# 1. Use this template on GitHub, then clone your new repo
git clone https://github.com/your-org/your-project && cd your-project

# 2. Install claude-flow
claude mcp add claude-flow -- npx -y @claude-flow/cli@latest

# 3. Verify environment (runs automatically on first session open, or manually)
npx @claude-flow/cli@latest doctor --fix

# 4. Open in Claude Code — the session start check runs automatically
```

On first open, Claude Code will verify the environment, start the claude-flow daemon, and create the required directories. You'll see `[SETUP]` output in the session hook.

---

## First thing to do in any new project

Before writing any code, calibrate governance for your project:

```
/sparc-constitution
```

This runs a short interview (≈5 minutes) and produces a `constitution.md` that sets the rigor level for all downstream workflow steps. A solo prototype gets a lightweight process; a team product handling sensitive data gets full rigor. All subsequent commands read from this file.

---

## The Workflow

Features follow this path. Each step is a gate — the next step depends on the previous one completing.

```
Idea → Brainstorm → Specify → Review → Plan → Review → Tasks → Review → Implement → Audit → Retro
```

### Step-by-step

**1. Brainstorm** *(optional but recommended for new features)*
```
/sparc-brainstorm
```
Prior art scan first, then structured ideation with four perspectives (Visionary, User Advocate, Technologist, Provocateur). Produces a prioritized roadmap.

**2. Specify**
```
/sparc-specify
```
Structured feature spec: user stories in Given/When/Then format, functional requirements (FR-NNN), measurable success criteria, edge cases, explicit assumptions. Runs a quality gate validation before presenting the draft.

**3. Review the spec**
```
/sparc-review
```
Three-phase adversarial review. Reviewers analyze independently (no cross-contamination), a devil's advocate challenges the consensus, a synthesis judge produces the final report with minority findings preserved. You choose: **Proceed / Revise / Re-review / Override**. An Override creates a LOG entry documenting the accepted risk.

**4. Plan**
```
/sparc-plan
```
Translates the spec into technical decisions: data model, API contracts, component architecture. **Hard stop**: any technology choice without a corresponding ADR in `.decisions/` blocks this step. All decisions are recorded before implementation begins.

**5. Review the plan**
```
/sparc-review
```
Same three-phase protocol, architecture-focused panel.

**6. Generate tasks**
```
/sparc-tasks
```
Tasks organized by user story (not technical layer), with parallel markers `[P]` and story tags `[US-001]`. TDD order is enforced: failing test task always precedes implementation task. Each story is independently deployable.

**7. Review tasks** *(FULL rigor only)*
```
/sparc-review
```

**8. Implement**
```
/sparc-implement
```
Checks `extensions.yml` for pre-implementation gates, verifies the build baseline is clean, then works through tasks in TDD order. Marks each task complete only when its acceptance criteria pass.

**9. Audit**
```
/sparc-audit
```
Bidirectional consistency check: Docs→Code (spec coverage, ADR compliance, contract compliance) and Code→Docs (undocumented decisions, architectural patterns, dead code). Produces a health score (A–F) across five dimensions.

**10. Retro**
```
/sparc-retro
```
Reviews every assumption from the spec — Validated / Invalidated / Partially / Untested. Updates the roadmap based on what implementation revealed. Feeds findings into the ReasoningBank so future features benefit from what was learned.

---

## Decision Records

All decisions live in `.decisions/` as version-controlled markdown files. ADRs and LOGs share a sequential counter.

```
.decisions/
  ADR_001_[topic].md    # Technology choice or architectural decision
  LOG_002_[topic].md    # Open question, risk, or tracked assumption
  ADR_003_[topic].md
  templates/
    ADR_template.md
    LOG_template.md
```

**ADR** = a decision made. Use when you've chosen between options.
**LOG** = a question open. Use for uncertainties, challenges, or risks being tracked.

The plan step will not proceed past architecture until every technology choice has an ADR. This is enforced, not advisory.

---

## Project Structure

```
your-project/
├── constitution.md          # Governance calibration (created by /sparc-constitution)
├── CLAUDE.md                # Behavioral rules for Claude Code
├── .decisions/              # ADRs and LOGs — checked into version control
│   └── templates/
├── specs/                   # All spec-driven artifacts
│   ├── roadmap.md
│   ├── [feature]-spec.md
│   ├── [feature]-plan.md
│   ├── [feature]-tasks.md
│   └── brainstorm-notes.md
├── docs/                    # Documentation and audit reports
├── src/                     # Source code
└── tests/                   # Test files
```

---

## Command Reference

| Command | When to use |
|---|---|
| `/sparc-constitution` | Start of any new project, or when team/risk context changes |
| `/sparc-brainstorm` | Before specifying a new feature or phase |
| `/sparc-specify` | Before any planning or implementation |
| `/sparc-review` | After spec, plan, and tasks (rigor level determines which) |
| `/sparc-plan` | After spec is reviewed and approved |
| `/sparc-tasks` | After plan is reviewed and approved |
| `/sparc-implement` | After tasks are generated (and reviewed at FULL rigor) |
| `/sparc-audit` | After implementation, before closing a feature |
| `/sparc-retro` | After completing a phase or major feature |

---

## Rigor Levels

The constitution sets each principle to FULL, STANDARD, or LIGHTWEIGHT based on your answers to questions about team size, data sensitivity, blast radius, and delivery constraints. This controls:

- How many review agents run in `/sparc-review`
- Which review steps are mandatory vs. optional
- PR size limits and documentation requirements
- Testing ceremony depth

A solo prototype might skip the review steps entirely. A team product handling PII runs the full three-phase adversarial protocol at every gate.

---

## Powered by

- [RuFlo / claude-flow](https://github.com/ruvnet/claude-flow) — agent orchestration, persistent memory (AgentDB + HNSW), model routing, ReasoningBank
- Claude-Root spec-driven workflow — constitution, adversarial review, ADR/LOG traceability, user-story tasks
