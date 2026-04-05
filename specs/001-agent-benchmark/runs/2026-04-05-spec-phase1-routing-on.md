# Benchmark Run: Phase 1 — Routing-On (Adjusted Strategy)

**Gate**: spec | **Phase**: 1 | **State**: routing-on
**Date**: 2026-04-05
**Panel**: security-reviewer, systems-architect, devils-advocate, synthesis-judge
**Contamination**: N/A — not executed (see Predicted Run note below)
**ADRs**: ADR_003, ADR_004, ADR_007, ADR_008

---

## Predicted Run — Not Executed

This pass was not run because the routing-off pass already captured the evidence needed to predict the outcome with high confidence.

**Evidence**:

| Agent | Raw Recommendation | Confidence | ADR_008 Rule | Selected Tier | Same as Routing-Off? |
|---|---|---|---|---|---|
| security-reviewer | opus | 0.563 | confidence < 0.60 → top non-opus alternative | sonnet (score 0.989) | **Yes** |
| systems-architect | opus | 0.568 | confidence < 0.60 → top non-opus alternative | sonnet (score 0.875) | **Yes** |

Both agents would be spawned at Sonnet — identical to the routing-off pass.

**Predicted outcome**:
- Model tier: Sonnet for all agents (identical to routing-off)
- Input chars: identical (same fixture, same prompts)
- Output chars: within natural LLM variance of routing-off run (~±10%)
- Routing overhead added: ~2 extra `hooks_model-route` calls × ~0.5ms each (negligible latency, no token cost)
- Tokens-per-caught-issue delta: ≈ 0 (same model, same fixture)

**Decision**: Running this pass would spend ~3,950 estimated tokens to confirm a known prediction. The marginal information value is less than the cost. Not run; prediction recorded instead. This decision is itself a finding about router confidence and its effect on experiment design.

---

## Routing Efficiency Comparison (Phase 1 Conclusion)

| Metric | Routing-Off | Routing-On (predicted) | Delta |
|---|---|---|---|
| Phase A estimated tokens | ~3,950 | ~3,950 | ~0 |
| Tokens-per-caught-issue | ~1,975 | ~1,975 | ~0 |
| Issues caught | 2 (PROD-1, SEC-1) | 2 (expected same) | 0 |
| Routing call overhead | 0 | ~4 tool calls, ~2ms | +2ms latency, 0 token cost |

**SC-001 Verdict**: **INCONCLUSIVE** — routing produced no efficiency gain because:
1. The router recommends opus for all spec-review tasks with ~50-57% confidence
2. ADR_008 adjusted strategy correctly overrides to sonnet (the highest-scoring alternative)
3. But routing-off also uses sonnet (session default)
4. Net result: adjusted routing selects the same tier as the routing-off default

The routing infrastructure adds overhead without changing the tier selected. This is not a failure of the experiment — it is a finding about the router's behavior at the spec gate.

---

## Phase 1 Primary Finding

> **The router's tiny-dancer-neural classifier assigns ~50-57% confidence to all spec-review tasks and defaults to opus, regardless of task complexity or the `preferCost` flag. The adjusted routing strategy (ADR_008) correctly overrides to sonnet via the alternatives ranking — but sonnet is also the routing-off default. No cost reduction is achieved.**

The root cause is upstream: **broad "analyze X for Y" task descriptions produce ambiguous complexity signals** — multiple high-complexity keywords trigger the classifier even when the actual reasoning demand is moderate. The alternatives ranking correctly reflects lower complexity (sonnet scores 0.875–0.989 across all spec-gate tasks) but the final recommendation ignores it.

---

## Key Question Raised (Addressed in Experiment Summary)

> Can better task description framing increase router confidence and produce discriminating routing decisions (haiku for structural checks, sonnet for reasoning tasks)?

If task descriptions were decomposed into atomic checks rather than broad analysis requests, the router would receive clearer complexity signals:

| Current framing | Router result | Proposed atomic framing | Expected router result |
|---|---|---|---|
| "Analyze spec for auth gaps, IDOR, missing auth requirements, security design flaws at system boundaries" | opus, 0.563 confidence | "Check if spec requires ownership enforcement: verify the authenticated user owns the preference record being modified" | likely sonnet or haiku, higher confidence |
| "Analyze spec for missing personas, priority issues, scope gaps" | opus, 0.568 confidence | "List all user roles that interact with the preference system according to the spec" | likely haiku, high confidence |
| "Analyze spec for missing personas, priority issues, scope gaps" | opus, 0.568 confidence | "Evaluate whether the P1/P2 priority assignment matches the relative user reach of each feature" | likely sonnet or opus, high confidence |

**Decomposed framing** would also allow the router's alternatives ranking to become the primary signal: a "list user roles" task would score haiku highest with high confidence, producing genuine tier routing. A "reason about IDOR chain across multiple components" task would score opus highest with high confidence — and the recommendation would be trustworthy.

This is a candidate for a follow-on experiment: does decomposed-task framing change routing confidence and produce measurable cost reduction while preserving detection quality?
