# Tasks: RuFlo Agent Benchmark Experiment

**Spec**: specs/ruflo-benchmark-spec.md
**Plan**: specs/ruflo-benchmark-plan.md
**Branch**: 001-agent-benchmark
**Rigor**: STANDARD

**Total tasks**: 22
**Parallel opportunities**: 5
**ADRs in Draft**: 0 (all Accepted)

---

## Format

```
- [ ] [P] [US-NNN] TASK-NNN: verb phrase
  - Acceptance: how to verify done
  - Depends on: TASK-NNN or "none"
  - Notes: constraints, ADR refs
```

`[P]` = can run in parallel with other `[P]` tasks in the same group.
TDD order is enforced: test/expectation task always precedes the run it validates.

---

## Shared Setup

These tasks are prerequisites for all three stories. Complete before any story begins.

- [ ] [US-001] TASK-001: Create specs/001-agent-benchmark/ directory structure
  - Acceptance: `specs/001-agent-benchmark/fixture/`, `specs/001-agent-benchmark/runs/`, and `specs/001-agent-benchmark/checklists/` directories exist
  - Depends on: none
  - Notes: Never save to root folder per CLAUDE.md; all benchmark artifacts live under `specs/001-agent-benchmark/`

- [ ] [US-001] TASK-002: Copy fixture files verbatim from Claude-Root
  - Acceptance: `specs/001-agent-benchmark/fixture/spec.md` and `specs/001-agent-benchmark/fixture/tasks.md` exist and are byte-for-byte identical to `../Claude-Root/specs/000-review-benchmark/fixture/spec.md` and `fixture/tasks.md`; no modifications made
  - Depends on: TASK-001
  - Notes: Reuse without modification per spec FR-001; these are the planted-issue fixtures

- [ ] [US-001] TASK-003: Copy and label benchmark-key.md as maintainer-only
  - Acceptance: `specs/001-agent-benchmark/benchmark-key.md` exists, contains all 12 planted issue entries from Claude-Root, and has a prominent MAINTAINER-ONLY header warning; file is listed in `.gitignore` or marked with a comment warning against sharing
  - Depends on: TASK-001
  - Notes: Benchmark key must NEVER be passed to any Phase A agent prompt (FR-003, ADR_003); contamination detection depends on this isolation

---

## US-003 — Router Classification Accuracy (Phase 3)

**Run Phase 3 before Phase 1.** Four `hooks_model-route` calls costing ~6ms total validates
the routing infrastructure before any expensive panel run is committed.

**Independent testability**: Deployable alone ✓ · No runtime dependency on US-001 or US-002 ✓

- [ ] [US-003] TASK-004: Write Phase 3 expected-outcome checklist
  - Acceptance: `specs/001-agent-benchmark/checklists/phase3-expected.md` exists and contains: (a) expected complexity threshold per issue (DEL-1 < 0.4, DEL-2 < 0.4, ARCH-3 > 0.5, FALSE-3 = "low confidence expected"), (b) expected model recommendation per issue (DEL-1 → haiku, DEL-2 → haiku, ARCH-3 → sonnet or opus, FALSE-3 → any), (c) definition of a classification error for each issue
  - Depends on: TASK-001
  - Notes: This is the "failing test" — write expected outputs before running; scoring pass compares actuals against this checklist; ADR_006

- [ ] [US-003] TASK-005: Write Phase 3 issue description inputs
  - Acceptance: `specs/001-agent-benchmark/checklists/phase3-inputs.md` exists with four concise task descriptions — one per issue — written as a pre-screener would receive them (task description only, not the full fixture text); descriptions do not contain planted issue IDs verbatim
  - Depends on: TASK-001
  - Notes: DEL-1: "compare task IDs to verify test tasks precede implementation tasks for each user story"; DEL-2: "detect tasks marked parallel that write to the same file"; ARCH-3: "trace cross-phase task dependencies to identify hidden ordering constraints"; FALSE-3: "check whether implementation tasks have corresponding test tasks, considering notes and integration test coverage"

- [ ] [US-003] TASK-006: Run Phase 3 router classification probe
  - Acceptance: `specs/001-agent-benchmark/runs/YYYY-MM-DD-task-phase3-classification.md` exists and contains a Router Classification Table with all four issue IDs, their `hooks_model-route` outputs (complexity, model, confidence, uncertainty), and a classification verdict (correct / error) per the TASK-004 checklist
  - Depends on: TASK-004, TASK-005
  - Notes: Call `hooks_model-route` once per description from TASK-005; record full output including `alternatives[]`; no panel agents spawned; total cost ~4 tool calls; ADR_006

- [ ] [US-003] TASK-007: Verify Phase 3 results and record findings
  - Acceptance: Run report updated with: (a) each issue marked correct or classification error, (b) any classification errors documented with the actual vs. expected complexity score, (c) an interpretation note on whether Phase 1 routing-on results should be treated with caution given any errors found
  - Depends on: TASK-006
  - Notes: Classification errors are findings to report, not blockers; if ARCH-3 routes to haiku, note this prominently in Phase 1 routing-on report as a potential quality risk; SC-003

---

## US-001 — Model Routing Efficiency (Phase 1)

**Prerequisite**: TASK-006 (Phase 3 probe) must complete first so classification findings
can inform interpretation of Phase 1 routing decisions.

**Independent testability**: Deployable alone ✓ · No runtime dependency on US-002 ✓

- [ ] [P] [US-001] TASK-008: Write contamination detection test cases
  - Acceptance: `specs/001-agent-benchmark/checklists/contamination-test.md` exists with: (a) a synthetic Phase A output containing "PROD-1" verbatim → expected result: CONTAMINATED flag, scoring aborted; (b) a synthetic output containing "PROD" but not "PROD-1" → expected result: CLEAN; (c) a synthetic output containing the planted issue description without the ID → expected result: CLEAN
  - Depends on: TASK-001
  - Notes: Contamination rule: full ID match only (e.g., `PROD-1` not `PROD`); FR-003, ADR_003; can run in parallel with TASK-009

- [ ] [P] [US-001] TASK-009: Write Phase 1 scoring expectations
  - Acceptance: `specs/001-agent-benchmark/checklists/phase1-scoring-expected.md` exists with: (a) expected catch result per spec-gate issue using STANDARD panel (PROD-1 → Caught by systems-architect or security-reviewer, PROD-2 → Caught partial, SEC-1 → Caught by security-reviewer, FALSE-1 → devils-advocate may raise as FP); (b) note that RuFlo STANDARD panel differs from Claude-Root STANDARD (security-reviewer is present here, was absent in Claude-Root run); (c) expected FALSE-1 false-positive risk is medium since devils-advocate is in panel
  - Depends on: TASK-001
  - Notes: RuFlo STANDARD includes security-reviewer; SEC-1 should be Caught (was Missed in Claude-Root STANDARD); this is the primary detection quality difference to watch; ADR_004

- [ ] [US-001] TASK-010: Write benchmark command — Phase 1 routing-off flow
  - Acceptance: `.claude/commands/sparc/benchmark-run.md` exists and contains complete instructions for Phase 1 routing-off pass: (a) load fixture/spec.md, do NOT load benchmark-key.md; (b) call `hooks_model-route` for each Phase A agent and log recommendation, but spawn all agents at Sonnet (model override omitted); (c) collect findings tagged `[AGENT_NAME] [MODEL_TIER: sonnet]`; (d) run Phase B (devils-advocate) with tagged Phase A output; (e) run Phase C (synthesis); (f) contamination check against benchmark-key; (g) rule-based scoring; (h) measure input+output character counts per agent; (i) save report to runs/
  - Depends on: TASK-008, TASK-009
  - Notes: Command-embedded scoring per ADR_003; character-count proxy per ADR_007; routing recommendations logged but not acted on in this pass

- [ ] [US-001] TASK-011: Run Phase 1 routing-off pass and verify contamination detection
  - Acceptance: (a) `specs/001-agent-benchmark/runs/YYYY-MM-DD-spec-phase1-routing-off.md` exists with full panel output, contamination status CLEAN, scoring table, character-count estimates per agent; (b) contamination test cases from TASK-008 verified inline (command correctly identifies CONTAMINATED vs CLEAN synthetic inputs)
  - Depends on: TASK-010, TASK-002, TASK-003
  - Notes: This is the functional validation of the full pipeline — if this run fails structurally, fix before running routing-on pass; FR-005, FR-006

- [ ] [US-001] TASK-012: Extend benchmark command with routing-on flow
  - Acceptance: `benchmark-run.md` updated with routing-on path: (a) call `hooks_model-route` for each Phase A agent task description; (b) spawn each agent with `model: [recommendation]` from the route result; (c) tag findings `[AGENT_NAME] [MODEL_TIER: {actual-model}]`; (d) character counts recorded per agent; (e) routing decision table included in report (agent, taskDesc, model, confidence, complexity)
  - Depends on: TASK-011
  - Notes: Agent tool `model` parameter ("sonnet"|"opus"|"haiku") sets actual tier; caller sets tier so confirmation is not needed from return value (OQ-01 resolved); ADR_003, ADR_004

- [ ] [US-001] TASK-013: Run Phase 1 routing-on pass
  - Acceptance: `specs/001-agent-benchmark/runs/YYYY-MM-DD-spec-phase1-routing-on.md` exists with: (a) Routing Decision Table (one row per Phase A agent: taskDesc, model, confidence, complexity); (b) character-count estimates per agent; (c) contamination status CLEAN; (d) scoring table
  - Depends on: TASK-012
  - Notes: Model tiers used are known (set explicitly via model param); ADR_004

- [ ] [US-001] TASK-014: Calculate routing efficiency comparison and close US-001
  - Acceptance: A comparison section added to `specs/001-agent-benchmark/runs/YYYY-MM-DD-spec-phase1-routing-on.md` (or a separate summary file) containing: (a) tokens-per-caught-issue for routing-off pass; (b) tokens-per-caught-issue for routing-on pass; (c) delta and interpretation; (d) catch-rate comparison between passes (any detection quality change flagged); (e) SC-001 verdict (routing reduced cost / did not / inconclusive)
  - Depends on: TASK-011, TASK-013
  - Notes: Tokens-per-caught-issue = total Phase A chars ÷ 4 ÷ count of Caught+Caught(partial); ADR_007; cross-reference Phase 3 classification findings if any routing decisions were to unexpected tiers

---

## US-002 — AgentDB Memory Warm-Up (Phase 2)

**Prerequisite**: TASK-013 (Phase 1 routing-on) complete; Phase 2 cold uses same routing-on
flow as Phase 1 routing-on plus AgentDB store step.

**Independent testability**: Deployable alone (after US-001 pipeline is validated) ✓ ·
Sequentially depends on run 1 before run 2, but no runtime dependency on US-003 ✓

- [ ] [US-002] TASK-015: Write Phase 2 memory delta expectations
  - Acceptance: `specs/001-agent-benchmark/checklists/phase2-expected.md` exists with: (a) expected warm-run behavior per agent (agent should reference prior findings, use fewer output chars, not degrade catch rate); (b) definition of a meaningful delta (> 10% reduction in output chars is meaningful; ≤ 10% is noise); (c) failure mode definition (warm run misses an issue that cold run caught = degradation finding)
  - Depends on: TASK-001
  - Notes: ADR_005; warm-up context injected per agent independently to preserve Phase A isolation

- [ ] [US-002] TASK-016: Extend benchmark command with Phase 2 cold flow (AgentDB store)
  - Acceptance: `benchmark-run.md` updated with Phase 2 cold path: after Phase A completes, call `memory_store` once per agent with key `phase2-run1-{agent-name}-findings`, value = agent's full findings text, namespace `benchmark/spec-fixture`; report includes confirmation of 3 store calls with `success: true` and `hasEmbedding: true`
  - Depends on: TASK-015, TASK-012
  - Notes: Per-agent keys preserve Phase A independence per ADR_005; benchmark key must NOT be stored; cold pass uses routing-on model tiers

- [ ] [US-002] TASK-017: Run Phase 2 cold pass and verify AgentDB writes
  - Acceptance: (a) `specs/001-agent-benchmark/runs/YYYY-MM-DD-spec-phase2-cold.md` exists with full panel output, character counts, scoring table, and 3 AgentDB store confirmations; (b) three entries exist in AgentDB namespace `benchmark/spec-fixture` (one per agent)
  - Depends on: TASK-016, TASK-002, TASK-003
  - Notes: If any store call fails, note in report and treat run 2 as partial-warm (use only successful stores); SC-002

- [ ] [US-002] TASK-018: Extend benchmark command with Phase 2 warm flow (AgentDB retrieve)
  - Acceptance: `benchmark-run.md` updated with Phase 2 warm path: before spawning each Phase A agent, call `memory_retrieve` for that agent's key; inject retrieved findings into agent prompt as: "In a prior run on this same fixture, you found: [retrieved text]. Review the fixture again. For each prior finding: endorse, revise, or retract. Then add any new findings."; record retrieval success/failure per agent
  - Depends on: TASK-017
  - Notes: Inject per-agent only (not other agents' findings) per ADR_005; if retrieval fails for an agent, that agent runs cold and delta is recorded as null for that agent; FR-007, FR-009

- [ ] [US-002] TASK-019: Run Phase 2 warm pass
  - Acceptance: `specs/001-agent-benchmark/runs/YYYY-MM-DD-spec-phase2-warm.md` exists with: (a) character counts per agent; (b) for each agent: prior-findings-endorsed count, prior-findings-revised count, new-findings count; (c) contamination status CLEAN; (d) scoring table
  - Depends on: TASK-018
  - Notes: Warm agents should reference prior findings explicitly; if no agent references prior findings, AgentDB injection may have failed — investigate before calculating delta

- [ ] [US-002] TASK-020: Calculate memory delta and close US-002
  - Acceptance: Memory Delta Table added to warm run report (or summary file) with: (a) per-agent output char delta (run 1 vs run 2); (b) per-agent delta % (positive = reduction); (c) catch-rate comparison (any issue missed in warm that was caught cold = flagged as degradation); (d) SC-002 verdict (memory warm-up reduced output chars / no effect / degraded detection)
  - Depends on: TASK-019, TASK-017
  - Notes: ADR_005; "meaningful delta" threshold from TASK-015 checklist; FR-009 (flag diverging catches)

---

## Cross-Cutting Tasks

- [ ] [P] TASK-021: Confirm all ADRs are Accepted and cross-referenced
  - Acceptance: All five ADRs (ADR_003–ADR_007) have status "Accepted"; each is referenced in the relevant run report or command comment where the decision is implemented
  - Depends on: TASK-014
  - Notes: No Draft ADRs remain; this is a housekeeping gate before the experiment is considered complete

- [ ] [P] TASK-022: Write experiment summary and update specs/ruflo-benchmark-spec.md assumptions
  - Acceptance: A brief summary section added to `specs/001-agent-benchmark/runs/` as `experiment-summary.md` covering: (a) SC-001 through SC-005 verdicts; (b) unexpected findings (routing to wrong tier, memory degradation, classification errors); (c) recommendations for follow-on work (plan gate, statistical runs, fixture refresh criteria); (d) any assumptions that were invalidated during the experiment
  - Depends on: TASK-020, TASK-021
  - Notes: Claude-Root catch-rate comparison for SC-004: Claude-Root STANDARD caught PROD-1, PROD-2 (partial), missed SEC-1; RuFlo STANDARD should catch all three (security-reviewer is present)

---

## Definition of Done

- [ ] All 22 tasks completed
- [ ] Five run reports exist in `specs/001-agent-benchmark/runs/` (phase1-routing-off, phase1-routing-on, phase2-cold, phase2-warm, phase3-classification)
- [ ] All planted issue scores recorded (PROD-1, PROD-2, SEC-1, FALSE-1 at spec gate; Router Classification Table at task gate)
- [ ] No CONTAMINATED runs (all contamination checks CLEAN)
- [ ] SC-001 through SC-005 each have an explicit verdict in the experiment summary
- [ ] All ADRs ADR_003–ADR_007 status = Accepted
- [ ] LOG_002 (rigor assumption) updated with outcome — resolved or escalated after experiment
- [ ] `specs/ruflo-benchmark-spec.md` Assumptions table updated to reflect probe findings (A-03, A-05 resolved)
- [ ] No working files saved to project root
