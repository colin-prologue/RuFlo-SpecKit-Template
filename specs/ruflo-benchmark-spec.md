# Feature Specification: RuFlo Agent Benchmark Experiment

**Feature Branch**: `001-agent-benchmark`
**Created**: 2026-04-05
**Status**: Complete — retro run 2026-04-05
**Rigor**: STANDARD (assumed — no constitution.md exists; single maintainer, research context, no PII, low blast radius)

## Decision Records

| # | Type | File | Title | Status |
|---|---|---|---|---|
| LOG-002 | Question | `.decisions/LOG_002_benchmark-rigor-assumption.md` | Rigor level assumed without constitution | Open |

---

## Problem Statement

The Claude-Root review-panel benchmark established a repeatable method for measuring whether
adversarial review agents catch planted issues in synthetic fixtures. That benchmark ran all
agents on the same model, repeated the full fixture context per agent, and offered no mechanism
for learning across runs — resulting in high token cost per insight. RuFlo adds three
capabilities that should improve this economics: a 3-tier model router (WASM/Haiku/Sonnet),
an HNSW-indexed AgentDB that persists agent findings across runs, and a WASM pre-screener
that handles mechanical checks without invoking an LLM. This experiment measures whether
those capabilities meaningfully reduce cost-per-caught-issue without degrading detection
quality — producing a data-backed answer before committing to RuFlo as the benchmark
infrastructure for ongoing panel tuning.

---

## User Stories

### US-001 — Measure Model Routing Efficiency at the Spec Gate (P1)

**As a** benchmark maintainer,
**I want to** run a STANDARD review panel against the spec fixture with RuFlo model routing
enabled and compare tokens-per-caught-issue against the Claude-Root STANDARD baseline,
**So that** I can determine whether automatic tier routing (Haiku for routine analysis,
Sonnet for complex reasoning) reduces cost without degrading issue detection.

**Priority**: P1 — this is the primary efficiency hypothesis; everything else depends on
first establishing whether routing helps or hurts.

**Acceptance Scenarios**:

1. **Given** the spec fixture and benchmark-key exist, **when** a STANDARD panel runs with
   routing enabled, **then** each Phase A agent call is tagged with its assigned model tier
   (WASM / Haiku / Sonnet) in the run report, and a tokens-per-caught-issue figure is
   calculated and compared against the Claude-Root STANDARD baseline from
   `2026-04-03-spec-STANDARD-run1.md`.
2. **Given** the routing-enabled run completes, **when** an agent is assigned to Haiku,
   **then** its catch rate for the issues in its specialty (PROD-* for product-strategist,
   SEC-* for security-reviewer) is recorded — not just total catches — so per-agent routing
   quality is independently assessable.
3. **Given** the run report, **when** a Phase A agent call is missing its model-tier tag,
   **then** the scoring pass flags that agent's findings as "routing unverified" and excludes
   them from the routing efficiency calculation (findings still count toward catch rate).
4. **Error path**: **Given** model routing is unavailable or returns an error, **then** the
   run falls back to Sonnet for all agents, the report notes "routing disabled — fallback
   used," and the run is scored normally (routing metrics are omitted, detection metrics
   are preserved).

**Independent testability**: Deployable alone ✓ · Delivers value alone (answers Phase 1
question) ✓ · No hard runtime dependency on US-002 or US-003 ✓ · All scenarios pass in
isolation ✓

---

### US-002 — Measure AgentDB Memory Warm-Up Effect (P1)

**As a** benchmark maintainer,
**I want to** run the spec fixture twice — once cold (no prior AgentDB entries) and once warm
(after Phase A findings from run 1 are stored in AgentDB) — and compare Phase A token use
between the two runs,
**So that** I can quantify whether persisted prior-run memory reduces the tokens agents need
to generate findings on a repeated fixture.

**Priority**: P1 — directly addresses the token efficiency concern; if memory warm-up
provides no reduction, the AgentDB integration adds overhead without benefit.

**Acceptance Scenarios**:

1. **Given** no AgentDB entries exist for the spec fixture namespace, **when** run 1
   (cold) completes, **then** Phase A output token counts per agent are recorded in the
   run report, and Phase A findings are stored to AgentDB under namespace
   `benchmark/spec-fixture`.
2. **Given** run 1 findings are stored in AgentDB, **when** run 2 (warm) runs the same
   fixture with agents instructed to retrieve prior findings before generating new ones,
   **then** Phase A output token counts are recorded and compared against run 1, and a
   "memory delta" (positive = reduction, negative = overhead added) is reported per agent.
3. **Given** both runs complete, **when** catch rates differ between cold and warm,
   **then** the difference is flagged and the specific diverging issues are identified —
   warm memory should not degrade detection; any degradation is a finding.
4. **Error path**: **Given** AgentDB retrieval fails during run 2, **then** the agent
   proceeds without memory context, the report notes "AgentDB unavailable — cold fallback,"
   and the run is scored as a cold run (memory delta is recorded as null).

**Independent testability**: Deployable alone ✓ · Delivers value alone ✓ · Sequentially
depends on run 1 completing before run 2, but no dependency on US-001 or US-003 ✓ ·
All scenarios pass in isolation ✓

---

### US-003 — Measure Model Router Complexity Classification Accuracy at the Task Gate (P2)

**As a** benchmark maintainer,
**I want to** call `hooks_model-route` on a description of each task-gate planted issue
and record whether the router's complexity score and model recommendation matches the
known reasoning demand of each issue,
**So that** I can determine whether the router correctly classifies low-complexity mechanical
issues (DEL-1: TDD ordering, DEL-2: parallel write conflict) as haiku-tier and
high-complexity reasoning issues (ARCH-3: multi-step cross-phase dependency inference)
as sonnet/opus-tier — without running a full benchmark panel.

**Note**: Originally designed as a WASM zero-LLM pre-pass. Probe confirmed `wasm_agent_create`
still invokes Claude (provides filesystem sandboxing only). Redesigned as a router
classification accuracy test — same gate, same issues, lower token cost, more tractable question.

**Priority**: P2 — depends conceptually on US-001 establishing routing behavior; no runtime
dependency on US-001 or US-002.

**Acceptance Scenarios**:

1. **Given** the four task-gate planted issue descriptions (DEL-1, DEL-2, ARCH-3, FALSE-3),
   **when** `hooks_model-route` is called once per issue description, **then** each call
   returns a complexity score, model recommendation, and confidence score, and the report
   includes a Router Classification Table mapping each issue ID to those values.
2. **Given** the Router Classification Table, **when** DEL-1 (compare task IDs for ordering)
   and DEL-2 (detect two parallel tasks writing the same file) are evaluated, **then** both
   return complexity scores below 0.4 and recommend haiku — structural pattern-matching tasks
   with no multi-step inference required.
3. **Given** the Router Classification Table, **when** ARCH-3 (trace a T009→T011→T015/T016
   dependency chain across phase boundaries) is evaluated, **then** it returns a complexity
   score above 0.5 and recommends sonnet or opus — a haiku recommendation for ARCH-3 is
   logged as a classification error.
4. **Given** FALSE-3 (requires reading a notes section to avoid a false positive), **when**
   the router evaluates it, **then** the confidence score is recorded regardless of
   recommendation — low confidence on FALSE-3 is an expected and interesting result.
5. **Error path**: **Given** `hooks_model-route` is unavailable, **then** the report notes
   "router unavailable," Phase 3 metrics are omitted, and catch-rate scoring from any
   accompanying panel run is preserved.

**Independent testability**: Deployable alone ✓ · Delivers value alone ✓ · No runtime
dependency on US-001 or US-002 ✓ · All scenarios pass in isolation ✓

---

## Functional Requirements

| ID | Requirement | Story |
|---|---|---|
| FR-001 | The experiment MUST use the existing fixture files from Claude-Root (`fixture/spec.md`, `fixture/tasks.md`) and their corresponding benchmark-key entries without modification | US-001, US-002, US-003 |
| FR-002 | Each run report MUST record per-agent token counts (input + output) and the model tier used for each agent call | US-001, US-002 |
| FR-003 | The benchmark-key MUST NOT be passed to any Phase A agent prompt; a contamination check MUST run before scoring (same rule as Claude-Root FR-003) | US-001, US-002, US-003 |
| FR-004 | Scoring MUST be rule-based: Caught / Caught (partial) / Missed — no LLM judgment in the scoring pass | US-001, US-002, US-003 |
| FR-005 | Run reports MUST be saved to `specs/001-agent-benchmark/runs/` with the naming convention `YYYY-MM-DD-<gate>-<phase>-<state>.md` (e.g., `2026-04-05-spec-phase1-routing.md`) | US-001, US-002, US-003 |
| FR-006 | The tokens-per-caught-issue metric MUST be calculated as: total tokens across all Phase A agent calls ÷ count of planted issues scored "Caught" or "Caught (partial)" | US-001, US-002 |
| FR-007 | Phase 2 MUST store Phase A findings to AgentDB under namespace `benchmark/spec-fixture` after run 1 completes, and retrieve them at the start of run 2's Phase A | US-002 |
| FR-008 | The Router Classification Table MUST map each task-gate planted issue ID (DEL-1, DEL-2, ARCH-3, FALSE-3) to its `hooks_model-route` output: complexity score, recommended model, and confidence score | US-003 |
| FR-009 | Any planted issue scored differently between Phase 2 run 1 (cold) and run 2 (warm) MUST be flagged in the report with the diverging finding highlighted | US-002 |
| FR-010 | Phase 1 MUST run two back-to-back passes on the spec fixture: pass A with routing disabled (all Sonnet) and pass B with routing enabled; the tokens-per-caught-issue comparison uses pass A as the baseline — Claude-Root run files serve as catch-rate reference only (no token data recorded there) | US-001 |

---

## Success Criteria

| ID | Criterion | Measurable Outcome |
|---|---|---|
| SC-001 | Model routing reduces cost | Phase 1 routing-enabled pass uses fewer tokens-per-caught-issue than the routing-disabled pass; OR the report explains why not; Claude-Root run is catch-rate reference only (no token baseline available there) |
| SC-002 | Memory warm-up effect is quantified | Phase 2 produces a memory delta per agent — positive (reduction), negative (overhead), or zero — for every Phase A agent in both runs |
| SC-003 | Router classification accuracy is known | Phase 3 produces a Router Classification Table; DEL-1 and DEL-2 score below 0.4 complexity and recommend haiku; ARCH-3 scores above 0.5 and recommends sonnet/opus; any deviation is logged as a classification error |
| SC-004 | Detection quality is not degraded | Catch rate across all phases is ≥ the Claude-Root STANDARD spec baseline (PROD-1: Caught, PROD-2: Caught partial, SEC-1: Caught) |
| SC-005 | Experiment is self-funding | Total tokens consumed across all 4 runs is less than 2× a single Claude-Root FULL spec run (the experiment cost must not exceed the insight value) |

---

## Key Entities

| Name | Definition |
|---|---|
| **Fixture** | A synthetic, realistic artifact (spec.md or tasks.md) with known planted issues, copied from Claude-Root |
| **Benchmark Key** | The scoring table mapping planted issue IDs to severity, expected catcher, and false-positive flag — never passed to Phase A agents |
| **Planted Issue** | A deliberately embedded flaw with a known ID (PROD-1, SEC-1, DEL-1, etc.), severity, and expected catching agent |
| **Phase A Agent** | A specialist reviewer agent that analyzes the fixture independently and produces tagged findings |
| **Run Report** | The saved output of one benchmark run: findings, scores, token counts, model tiers, and efficiency metrics |
| **Tokens-per-Caught-Issue** | Total Phase A tokens ÷ issues scored Caught or Caught (partial); primary efficiency metric |
| **Memory Delta** | Change in Phase A output token count from cold run to warm run; positive = reduction |
| **Triage Decision** | WASM pre-screener's routing choice for a given issue: handle locally (zero LLM) or escalate |
| **Contamination** | Any Phase A finding containing a verbatim planted issue ID (e.g., `PROD-1`) — invalidates the run |

---

## Edge Cases & Error Paths

- **WASM unavailable (all phases)**: Fall back to Sonnet; note in report; exclude routing/triage metrics; detection metrics preserved.
- **AgentDB unavailable (Phase 2 run 2)**: Proceed as cold run; note in report; memory delta recorded as null.
- **Model routing unavailable (Phase 1)**: Fall back to Sonnet; note in report; exclude routing efficiency metrics; detection metrics preserved.
- **Contamination detected**: Abort scoring; flag run as invalid; prompt re-run with clean context — same rule as Claude-Root.
- **Warm run (Phase 2) shows degraded catch rate**: Flag the diverging issues; do not suppress; this is a finding about memory interference, not a run error.
- **Claude-Root baseline file unreadable**: Phase 1 omits the baseline comparison row; SC-001 is scored as "inconclusive — baseline unavailable."
- **FALSE-3 trap at task gate (Phase 3)**: WASM must not route FALSE-3 to WASM confidently — the trap requires reading the notes section, which implies reasoning. A WASM routing decision on FALSE-3 is logged as a triage error.

---

## Explicit Assumptions

| # | Assumption | Risk | Validation Method |
|---|---|---|---|
| A-01 | Claude-Root's fixture files (fixture/spec.md, fixture/tasks.md) are stable and have not been modified since the April 3 calibration runs | LOW — files are in a separate repo on a named branch | **VALIDATED** — used verbatim across all runs without issues |
| A-02 | The Claude-Root STANDARD spec baseline (`2026-04-03-spec-STANDARD-run1.md`) contains a token count that can be used as comparison denominator | HIGH — confirmed: no token counts appear in any Claude-Root run file | **INVALIDATED (pre-caught)** — Phase 1 redesigned as routing-on vs. routing-off internal comparison before any tokens burned |
| A-03 | RuFlo model routing can be observed — i.e., the model tier used for each agent call is accessible | RESOLVED — `hooks_model-route` returns model, confidence, complexity score, and alternatives per call; explicit call required before each Phase A agent invocation | **VALIDATED** — works as documented; explicit call pattern became foundation for ADR_008 |
| A-04 | AgentDB stores and retrieves findings at a granularity that allows per-agent context injection at Phase A start | MEDIUM — retrieval may return full namespace dump rather than agent-specific prior findings | **VALIDATED** — per-agent keys in shared namespace work exactly as needed; ADR_005 resolved |
| A-05 | WASM booster pre-screening can be invoked as a distinct step before Phase A LLM agents run, not just as an optimization inside agent execution | RESOLVED (false premise) — `wasm_agent_create` has a `model` param defaulting to Claude Sonnet; WASM agents still invoke Claude and provide filesystem sandboxing only | **INVALIDATED (pre-caught)** — Phase 3 redesigned before tokens burned; LOG_006 / ADR_006 |
| A-06 | Rigor is STANDARD — two Phase A specialists (security-reviewer + systems-architect) plus devil's advocate; no constitution.md exists to confirm | LOW for this experiment — if constitution sets different rigor, panel composition changes | **PARTIALLY VALIDATED** — experiment ran successfully at STANDARD; LOG_002 open; constitution not run |

---

## Out of Scope

- Plan gate benchmark (deferred to a follow-on experiment after Phase 1–3 results are known)
- Multi-run statistical averaging (single runs only; variance is an acknowledged limitation per Claude-Root precedent)
- Modifying or extending the fixture artifacts — fixtures are used as-is from Claude-Root
- New planted issues not already defined in Claude-Root's benchmark-key
- Comparing RuFlo topology modes (hierarchical vs. mesh) — deferred; adds run count without answering the primary question
- Benchmarking agents outside the STANDARD panel composition

---

## Open Questions

| ID | Question | Blocks | Owner |
|---|---|---|---|
| OQ-01 | Does `2026-04-03-spec-STANDARD-run1.md` contain per-agent token counts? If not, what denominator does Phase 1 use for the baseline comparison? | SC-001 | Maintainer — read file before Phase 1 |
| OQ-02 | Is model tier metadata available in `hooks_post-task` output, or does it require a separate MCP call? | FR-002, A-03 | RESOLVED — `hooks_post-task` has no tier field; tier must be captured via explicit `hooks_model-route` call before each agent invocation |
| OQ-03 | Can WASM pre-screening be invoked as an explicit pre-pass (before Phase A LLM calls), or is it only an internal routing optimization? | FR-008, A-05 | RESOLVED (false premise) — WASM agents still invoke Claude; Phase 3 redesigned as router classification accuracy test using `hooks_model-route` |
| OQ-04 | What namespace granularity does AgentDB support — can findings be stored per-agent within a namespace, or only per-namespace? | FR-007, A-04 | Resolve during plan phase |
