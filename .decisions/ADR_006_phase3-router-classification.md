# ADR_006: Phase 3 as Router Classification Accuracy Test

**Status:** Accepted
**Date:** 2026-04-05
**Deciders:** Benchmark maintainer
**Related spec:** specs/ruflo-benchmark-spec.md — US-003, FR-008, SC-003
**Related LOGs:** none (A-05 resolved as false premise)

---

## Context

Phase 3 was originally designed to test whether a WASM pre-screener could handle
mechanical task-gate issues (DEL-1, DEL-2) without LLM involvement, routing them to
a zero-cost tier. Probe of `wasm_agent_create` revealed that WASM agents still invoke
Claude (model parameter defaults to `claude-sonnet-4-20250514`). The zero-LLM
pre-screening tier is not accessible via current RuFlo MCP tools.

An alternative question is tractable with the same tools already required for Phase 1:
does `hooks_model-route` correctly classify task-gate planted issues by complexity?
DEL-1 and DEL-2 are structural pattern-matching tasks (no multi-step inference);
ARCH-3 requires tracing a dependency chain across phase boundaries. These have known
reasoning demands, making them valid test inputs for the router's complexity classifier.

## Decision

**We will redesign Phase 3 as a router classification accuracy test — calling
`hooks_model-route` once per task-gate planted issue description and evaluating whether
the complexity scores and model recommendations align with the known reasoning demands —
because this is independently valuable, requires no additional panel runs, and uses
tools already validated in Phase 1.**

## Rationale

The original WASM pre-screening question is blocked by a false premise in the tooling.
The router classification question is not blocked, is answerable in 4 tool calls (no
panel run), and produces a concrete output: do low-complexity mechanical issues score
below the haiku threshold, and do high-complexity reasoning issues score above it? This
is a necessary precondition for trusting routing decisions in Phase 1 — if the router
misclassifies reasoning-heavy issues as haiku-tier, Phase 1's routing-on pass will
degrade detection quality, and Phase 3 explains why.

## Alternatives Considered

| Option | Why rejected |
|---|---|
| WASM zero-LLM pre-screening | Not implementable — WASM agents still call Claude (confirmed by probe) |
| Full panel run at task gate with tier tagging | Adds a third full panel run for a gate we decided to minimize; Phase 3's question is answerable without a panel run |
| Drop Phase 3 entirely | Loses the router accuracy signal; if routing is wrong on task-type issues, it may also be wrong on spec-type issues in Phase 1 |

## Consequences

**Becomes easier:**
- Phase 3 costs 4 tool calls instead of a full panel run (~100× cheaper)
- Results are available before Phase 1 runs, enabling informed routing decisions
- Provides interpretive context for Phase 1 routing confidence scores

**Becomes harder:**
- Phase 3 no longer measures detection quality at the task gate — it measures routing
  classification accuracy only; task gate catch rate is not tested in this experiment

**Constraints introduced:**
- Phase 3 issue descriptions must be written to match what a pre-screener would receive
  (concise task description, not the full fixture text)
- Classification errors (ARCH-3 routed to haiku) must be reported as findings,
  not treated as run failures

## Validation

Phase 3 succeeds when all four issue descriptions return a complexity score and model
recommendation. Success criterion (SC-003): DEL-1 and DEL-2 below 0.4 complexity
recommending haiku; ARCH-3 above 0.5 recommending sonnet/opus. Any deviation is logged
as a classification error and used to interpret Phase 1 routing decisions.

## Amendment History

| Date | Change | Reason |
|---|---|---|
| 2026-04-05 | Created | WASM zero-LLM pre-screening not implementable; redesigned from probe results |
