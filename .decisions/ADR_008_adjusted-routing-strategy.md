# ADR_008: Adjusted Routing Strategy — Alternatives Ranking When Confidence < 0.60

**Status:** Accepted
**Date:** 2026-04-05
**Deciders:** Benchmark maintainer
**Related spec:** specs/ruflo-benchmark-spec.md — US-001, FR-002
**Related LOGs:** none
**Supersedes:** none (extends ADR_004)

---

## Context

Phase 3 classification probe revealed that `hooks_model-route` recommends opus for every
task regardless of complexity score. DEL-2 had a complexity score of 0.373 (correctly
below the haiku threshold) but the final recommendation was still opus. The `preferCost`
flag had no effect. Sonnet was the highest-scoring alternative in 3 of 4 calls (scores
0.746–0.976) yet was never selected as the recommendation.

The router's final model selection appears biased toward opus when confidence is below
~0.70, ignoring the alternatives ranking that correctly reflects the complexity estimate.

Two approaches for Phase 1 routing-on were considered:

**Option A**: Use router recommendation as-is (all opus). Tests Sonnet vs. opus quality+cost.
**Option B**: When confidence < 0.60, use the highest-scoring non-opus alternative instead
of the final recommendation. Tests whether the alternatives ranking produces better routing
decisions than the biased final recommendation.

## Decision

**We will use the highest-scoring non-opus alternative when router confidence is below 0.60,
because the Phase 3 data shows the alternatives ranking is a more accurate reflection of
task complexity than the final recommendation, and this produces the hypothesis the
experiment was designed to test: does correct tier routing reduce cost?**

## Rationale

If routing-on simply uses the router's opus recommendation for all agents, the comparison
becomes Sonnet (routing-off) vs. opus (routing-on) — an inverted cost comparison where
"routing" makes things more expensive. This is a valid finding about the router's behavior,
but it bypasses the experiment's primary question: can routing reduce cost without degrading
detection quality?

Option B tests a corrected routing policy: trust the alternatives ranking when the final
recommendation is uncertain. For the spec-gate agents, this will likely select sonnet
(which scores 0.76–0.98 in alternatives for review tasks). This produces a direct
Sonnet vs. Sonnet comparison where routing adds overhead but not model-tier benefit —
or, if the router does recommend haiku for simple agent tasks, a genuine cost reduction.

Either outcome is informative. Option B produces richer data than Option A.

## Routing Logic for Phase 1 Routing-On Pass

```
For each Phase A agent:
  1. Call hooks_model-route(taskDescription)
  2. If confidence >= 0.60: use model recommendation as-is
  3. If confidence < 0.60: use highest-scoring alternative where model != "opus" and model != "inherit"
  4. If no non-opus alternative scores > 0.20: fall back to sonnet
  5. Spawn agent with model = selected tier
  6. Log: taskDesc, raw recommendation, confidence, selected tier, selection reason
```

**Confidence threshold**: 0.60 chosen because all four Phase 3 calls fell below 0.60
(range: 0.498–0.568). This threshold is where the router's uncertainty is high enough
that the alternatives ranking is more informative than the recommendation.

## Consequences

**Becomes easier:**
- Tests the alternatives ranking as a routing signal — adds interpretive value
- Produces a more honest efficiency comparison than the biased opus default
- Documents the router's behavior (opus bias at low confidence) as a finding

**Becomes harder:**
- Routing logic is more complex (two-step: recommendation then alternatives check)
- Phase 1 run report must log both the raw recommendation AND the selected tier for
  each agent, so the routing adjustment is transparent and auditable

**Constraints introduced:**
- The routing adjustment must be documented in the run report ("adjusted from opus to
  sonnet via alternatives ranking, confidence 0.57")
- SC-001 verdict must reference ADR_008 — the efficiency comparison uses adjusted routing,
  not raw routing

## Validation

Phase 1 routing-on report shows per-agent selected tier with selection reason
(recommendation accepted / adjusted via alternatives). If all agents select sonnet
via adjustment, the comparison is Sonnet vs. Sonnet — document overhead cost of routing
calls as the efficiency delta. If any agent selects haiku, the original hypothesis is tested.

## Amendment History

| Date | Change | Reason |
|---|---|---|
| 2026-04-05 | Created | Phase 3 probe revealed opus bias; routing strategy adjusted |
