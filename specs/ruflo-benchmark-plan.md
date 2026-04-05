# Technical Plan: RuFlo Agent Benchmark Experiment

**Feature**: ruflo-benchmark
**Branch**: 001-agent-benchmark
**Date**: 2026-04-05
**Spec**: specs/ruflo-benchmark-spec.md
**Research**: specs/ruflo-benchmark-research.md

---

## Constitution Check

No `constitution.md` exists (LOG_002). Assuming STANDARD rigor.

| Principle | Level | Impact on this plan |
|---|---|---|
| Review gates | STANDARD | Plan proceeds to tasks without spec review gate |
| ADR enforcement | STANDARD | All technology choices must have ADRs before tasks begin — enforced |
| Testing ceremony | STANDARD | Unit tests on scoring logic; integration test on contamination detection |
| PR size | STANDARD | Single PR acceptable |
| Documentation | STANDARD | Plan + spec sufficient; no separate design doc required |

---

## Technical Context

**Runtime**: Claude Code command environment (markdown prompt files executed by Claude Code CLI)
**Language**: No compiled code — experiment is a Claude Code slash command + agent prompts
**Infrastructure**: RuFlo claude-flow MCP tools (hooks_model-route, memory_store/retrieve, agent Task tool)
**External dependencies**:
  - Claude-Root repo at `../Claude-Root` (fixture files and benchmark key — read-only)
  - claude-flow daemon (must be running: `npx @claude-flow/cli@latest daemon start`)
  - `hooks_model-route` MCP tool (tiny-dancer-neural, validated by probe)
  - AgentDB (`memory_store`, `memory_retrieve`) MCP tools (sql.js + HNSW, validated)

**Key constraint**: No source code files — all deliverables are markdown command files,
fixture copies, and generated run reports.

---

## Data Model

All entity names match the spec exactly.

### RunReport
```
gate:           "spec" | "task"
phase:          1 | 2 | 3
state:          "routing-off" | "routing-on" | "cold" | "warm" | "classification"
date:           YYYY-MM-DD
panel:          string[]          # agent names
contamination:  "CLEAN" | "CONTAMINATED"
findings:       Finding[]
scores:         PlantedIssueScore[]
routingTable:   RoutingDecision[] # Phase 1 and 3 only
memoryDelta:    MemoryDelta[]     # Phase 2 only
charEstimates:  AgentCharCount[]  # all phases
```

### Finding
```
agentName:    string
artifact:     "spec" | "tasks"
section:      string              # e.g., "User Stories", "Phase 2"
severity:     "CRITICAL" | "HIGH" | "MEDIUM" | "LOW"
description:  string
modelTier:    "sonnet" | "haiku" | "opus" | "routing-disabled"
estTokensOut: number              # output chars ÷ 4
```

### RoutingDecision
```
agentName:   string               # or issue ID for Phase 3
taskDesc:    string               # what was passed to hooks_model-route
model:       "opus" | "sonnet" | "haiku"
confidence:  number               # 0–1
complexity:  number               # 0–1
uncertainty: number               # 0–1
alternatives: { model, score }[]
```

### PlantedIssueScore
```
id:            string             # e.g., "PROD-1", "SEC-1"
severity:      "CRITICAL" | "HIGH" | "MEDIUM" | "-"
expectedAgent: string
caughtBy:      string | "—"
result:        "Caught" | "Caught (partial)" | "Missed" | "False positive"
notes:         string
```

### MemoryDelta (Phase 2 only)
```
agentName:      string
run1CharsOut:   number
run2CharsOut:   number
delta:          number            # positive = reduction
priorEndorsed:  number            # how many prior findings agent endorsed
priorRevised:   number            # how many prior findings agent revised
newFindings:    number            # net-new findings in run 2
```

---

## Component Architecture

### Component 1: Benchmark Command
**File**: `.claude/commands/sparc/benchmark-run.md`
**Responsibility**: Orchestrates all three phases in sequence. Reads phase argument,
loads fixture, calls routing, spawns agents, stores/retrieves memory, scores, reports.

**Invocation**: `/sparc-benchmark-run [phase] [--gate spec|task] [--state routing-off|routing-on|cold|warm|classification]`

**Internal flow per phase:**
```
Phase 1 (routing-off):
  1. Load fixture/spec.md (do NOT load benchmark-key.md)
  2. For each Phase A agent: call hooks_model-route → record recommendation → invoke agent at Sonnet (ignore recommendation)
  3. Collect findings with agent-name tags
  4. Run Phase B (devils-advocate) with tagged Phase A output
  5. Run Phase C (synthesis) with full tagged output
  6. Contamination check → score → generate report → save to runs/

Phase 1 (routing-on):
  Same as routing-off but step 2 uses hooks_model-route recommendation as the actual model tier

Phase 2 (cold):
  Same as Phase 1 routing-on but also: after Phase A, store each agent's findings to AgentDB

Phase 2 (warm):
  Same as cold but step 2 prepends: retrieve prior findings for this agent from AgentDB → inject into agent prompt

Phase 3 (classification):
  For each task-gate issue description (4 calls):
    Call hooks_model-route with issue description → record all output fields
  Generate Router Classification Table
  Save to runs/
```

### Component 2: Fixture Store
**Directory**: `specs/001-agent-benchmark/fixture/`
**Files**: `spec.md`, `tasks.md` — copied verbatim from Claude-Root
**Responsibility**: Stable, unmodified benchmark artifacts. Never include benchmark-key.md here.

### Component 3: Benchmark Key
**File**: `specs/001-agent-benchmark/benchmark-key.md`
**Responsibility**: Ground truth scoring table. Maintainer-only. Never passed to Phase A agent prompts.
**CONTAMINATION RULE**: If any Phase A finding contains a verbatim issue ID (PROD-1, SEC-1, etc.), abort scoring and flag as CONTAMINATED.

### Component 4: Run Reports
**Directory**: `specs/001-agent-benchmark/runs/`
**Naming**: `YYYY-MM-DD-<gate>-phase<N>-<state>.md`
**Examples**:
  - `2026-04-05-spec-phase1-routing-off.md`
  - `2026-04-05-spec-phase1-routing-on.md`
  - `2026-04-05-spec-phase2-cold.md`
  - `2026-04-05-spec-phase2-warm.md`
  - `2026-04-05-task-phase3-classification.md`

### Component 5: Scoring Logic (embedded in command)
**Responsibility**: Rule-based Caught / Caught (partial) / Missed classification per planted issue.
**Rules** (FR-004):
  1. Caught: finding references correct artifact section AND core problem area
  2. Caught (partial): correct artifact, incorrect framing or partial problem identification
  3. Missed: no finding addresses the planted issue
  4. False Positive (for FALSE-* entries): finding raises the trap as definitive HIGH/MEDIUM without hedging

---

## API Contracts / Tool Interfaces

### hooks_model-route
```
input:  { task: string, preferCost?: boolean }
output: { model, confidence, complexity, uncertainty, reasoning, alternatives[], inferenceTimeUs }
used:   before each Phase A agent invocation (Phase 1, 2); for each issue description (Phase 3)
```

### memory_store (AgentDB)
```
input:  { key: "phase2-run1-{agent-name}-findings", value: string, namespace: "benchmark/spec-fixture" }
output: { success, hasEmbedding, storedAt }
used:   after Phase 2 run 1 Phase A completes (3 calls — one per agent)
```

### memory_retrieve (AgentDB)
```
input:  { key: "phase2-run1-{agent-name}-findings", namespace: "benchmark/spec-fixture" }
output: { value, found }
used:   at start of Phase 2 run 2 Phase A (3 calls — one per agent before spawning)
```

### Phase A Agent (Task tool)
```
input:  system prompt + fixture text + (Phase 2 warm only) prior findings context
        model: omitted (routing-off) | "haiku"|"sonnet"|"opus" (routing-on, set from hooks_model-route recommendation)
output: tagged findings list — each row prefixed with [AGENT_NAME] and [MODEL_TIER]
agents: security-reviewer, systems-architect, devils-advocate (Phase B)
```

**Routing mechanism**: The Agent tool `model` parameter accepts "sonnet" | "opus" | "haiku"
and overrides the session default. Routing-on means the benchmark command sets this parameter
per agent from the `hooks_model-route` recommendation. Since the caller sets the model
explicitly, the tier used is known without requiring return-value confirmation.
Routing-off omits the parameter entirely (all agents inherit Sonnet from session).

---

## Technology Decisions

| Decision | Choice | ADR |
|---|---|---|
| Scoring architecture | Command-embedded (not post-processing) | ADR_003 |
| Phase 1 baseline design | Two-pass: routing-off then routing-on | ADR_004 |
| AgentDB storage granularity | Per-agent key within shared namespace | ADR_005 |
| Phase 3 design | Router classification accuracy (not WASM pre-pass) | ADR_006 |
| Token measurement | Character-count proxy (chars ÷ 4) | ADR_007 |

---

## Security Considerations

- **Benchmark key isolation**: benchmark-key.md must never appear in any agent prompt.
  The command must load it only after Phase A/B/C complete, for the scoring pass only.
- **Contamination detection**: scan all Phase A findings for verbatim planted issue IDs
  before scoring. Full ID match only (e.g., `PROD-1` not `PROD`).
- **AgentDB contamination risk**: benchmark key must never be stored in AgentDB.
  Only Phase A agent findings (which must already be contamination-clean) are stored.
- **No secrets**: fixture files contain synthetic content only; no credentials, no PII.
- **Fixture integrity**: fixtures are read-only copies from Claude-Root; do not modify.

---

## Testing Strategy

### Unit Tests
- **Scoring logic**: given a finding text and a planted issue description, assert
  Caught / Caught (partial) / Missed classification matches expected result.
  Test all three scoring outcomes plus false-positive detection.
  File: `tests/scoring-logic.test.md` (prompt-based test cases)

- **Contamination detection**: given a Phase A output containing "PROD-1" verbatim,
  assert the run is flagged CONTAMINATED and scoring is aborted.
  File: `tests/contamination-detection.test.md`

### Integration Tests
- **Phase 3 standalone**: run the 4 `hooks_model-route` calls on the task-gate issue
  descriptions before running Phase 1. This validates the router is available and
  returns expected fields. Cost: 4 tool calls (~6ms total).

### End-to-End
- **Phase 1 routing-off pass**: the first full panel run serves as functional validation
  of the full command flow (fixture loading → agent spawning → scoring → report save).
  Run this before Phase 1 routing-on to confirm the pipeline works.

---

## Implementation Order

The following order minimizes wasted work if a phase fails:

1. **Setup**: create fixture directory, copy files from Claude-Root, verify benchmark key
2. **Phase 3 probe**: run 4 classification calls (validates hooks_model-route before committing to full panel runs)
3. **Scoring logic test**: verify contamination detection and scoring rules with synthetic inputs
4. **Phase 1 routing-off**: first full panel run; establishes character-count baseline and validates full pipeline
5. **Phase 1 routing-on**: second full panel run; primary comparison data
6. **Phase 2 cold**: same as routing-on + AgentDB store; validates memory write
7. **Phase 2 warm**: retrieves from AgentDB; validates memory read + delta measurement

If Phase 3 classification test shows router misclassifies ARCH-3 as haiku-tier, note the
finding but proceed — it is a result to report, not a blocker.

---

## Open Questions

| ID | Question | Blocks | Must resolve before |
|---|---|---|---|
| OQ-01 | Does the Task tool expose model version in its return value, allowing confirmation that routing-on agents actually ran on the recommended tier? | FR-002 accuracy | RESOLVED — Agent tool has a `model` parameter ("sonnet"\|"opus"\|"haiku") that the benchmark command sets explicitly from the hooks_model-route recommendation; caller sets the tier so confirmation from return value is unnecessary |
| LOG-002 | Rigor level assumed without constitution.md | Panel composition, review gates | Implementation — run /sparc-constitution before tasks begin |
