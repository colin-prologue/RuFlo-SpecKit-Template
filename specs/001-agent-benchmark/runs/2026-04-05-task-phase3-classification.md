# Benchmark Run: Phase 3 — Router Classification Accuracy
**Gate**: task | **Phase**: 3 | **State**: classification
**Date**: 2026-04-05
**Tool**: hooks_model-route (tiny-dancer-neural)
**Panel**: none — router probe only (4 tool calls, no agents spawned)
**Contamination**: N/A (no Phase A agents)

---

## Router Classification Table

| Issue ID | Complexity | Model Rec. | Confidence | Uncertainty | Expected Model | Expected Complexity | Verdict |
|---|---|---|---|---|---|---|---|
| DEL-1 | 0.570 | opus | 0.498 | 0.746 | haiku | < 0.40 | **CLASSIFICATION ERROR** |
| DEL-2 | 0.373 | opus | 0.567 | 0.530 | haiku | < 0.40 | **CLASSIFICATION ERROR** |
| ARCH-3 | 0.488 | opus | 0.568 | 0.472 | sonnet/opus | > 0.50 | **CLASSIFICATION ERROR** |
| FALSE-3 | 0.612 | opus | 0.539 | 0.589 | any | any | recorded (no verdict) |

---

## Scoring Against Checklist (specs/001-agent-benchmark/checklists/phase3-expected.md)

### DEL-1 — CLASSIFICATION ERROR
- **Expected**: complexity < 0.40, model = haiku
- **Actual**: complexity 0.570, model = opus
- **Diagnosis**: DEL-1 is a structural TDD-order check (compare task IDs). The router scored it at 57% complexity — treating sequential ID comparison as reasoning-heavy. Haiku scored 0 in alternatives (completely ruled out). Sonnet was highest-scoring alternative (0.860) but router chose opus despite sonnet dominating the alternatives table.
- **Risk for Phase 1**: routing-on will assign DEL-1 analysis to opus — the most expensive tier, for a mechanical task. No quality benefit; pure cost overhead.

### DEL-2 — CLASSIFICATION ERROR
- **Expected**: complexity < 0.40, model = haiku
- **Actual**: complexity 0.373, model = opus
- **Diagnosis**: DEL-2 complexity score (0.373) IS below the 0.40 threshold — the complexity classifier is correct. But the router still recommends opus. The alternatives show haiku at 0.253 (plausible) but the final decision ignores the complexity signal and defaults to opus. This is a routing logic failure, not a complexity scoring failure. The complexity model and the routing decision are decoupled in a way that produces a wrong outcome despite correct complexity estimation.
- **Risk for Phase 1**: same as DEL-1 — opus will be assigned for a structural check.

### ARCH-3 — CLASSIFICATION ERROR
- **Expected**: complexity > 0.50, model = sonnet or opus
- **Actual**: complexity 0.488, model = opus
- **Diagnosis**: Complexity score (0.488) is just below the 0.50 threshold. Model recommendation (opus) is acceptable (not haiku). This is a boundary case — the complexity score is close to threshold and the model recommendation is reasonable. This is a partial error: complexity threshold missed (0.488 < 0.50) but model recommendation is correct direction. Sonnet scored 0.976 (highest alternative) yet opus was chosen.
- **Risk for Phase 1**: negligible — opus is a valid choice for ARCH-3. The complexity underscore may indicate the description framing was too concise.

### FALSE-3 — recorded, no verdict
- **Actual**: complexity 0.612, model = opus, confidence 0.539
- **Observation**: Highest complexity score of the four (0.612), despite being a "reads notes section" task. The keyword "integration" triggered a high-complexity indicator. Confidence 0.539 — correctly uncertain. No classification error defined; this is a data point for router behavior analysis.

---

## Key Finding: Router Has a Strong Bias Toward Opus

Across all four calls, the router recommended **opus in every case**, regardless of complexity score. The alternatives table correctly scores haiku higher for low-complexity tasks (DEL-2: haiku 0.253) but the final routing decision ignores this. The router appears to have a systematic bias: when complexity is uncertain (confidence ~50-57%), it defaults to opus rather than following the alternatives ranking.

**Observed pattern**:
- Low complexity (DEL-2: 0.373) + low confidence (0.567) → opus
- Medium complexity (DEL-1: 0.570) + low confidence (0.498) → opus
- Medium complexity (ARCH-3: 0.488) + medium confidence (0.568) → opus

This is consistent with the initial probe (spec-review task: complexity 0.38 → opus). The router appears to use opus as a safe default when confidence is below ~0.70.

---

## Implications for Phase 1

This is a significant finding for the routing-on vs routing-off comparison:

1. **Routing-on will likely produce identical or higher costs than routing-off** because the router defaults to opus for all agents regardless of task complexity. The routing-off pass uses Sonnet as default; the routing-on pass will use opus (more expensive). The cost comparison may invert the expected finding.

2. **The efficiency hypothesis may not be testable with the current router** — if the router never recommends haiku for any spec-review task, there is no cost reduction to measure. Phase 1 routing-on results should be interpreted with this context.

3. **Sonnet is the highest-scoring alternative in 3 of 4 calls** yet is never chosen. The router's selection function appears to weight opus more heavily than the alternatives ranking suggests. This is the primary behavioral anomaly to document.

4. **The `preferCost: true` flag had no effect** in the initial probe either — this flag may not be implemented in the tiny-dancer-neural backend or may not override the opus bias at low confidence.

---

## SC-003 Verdict

**FAIL** — DEL-1 and DEL-2 did not route to haiku as expected. DEL-2 complexity score was correct (< 0.40) but model recommendation was opus. ARCH-3 complexity score was below threshold (0.488 vs > 0.50 expected) but model recommendation (opus) is acceptable direction.

The router does not correctly translate complexity scores into model tier recommendations for the task-gate issues tested.

---

## Recommendation

**Proceed with Phase 1** — but amend Phase 1 routing-on expectations:
- Expect routing-on to use opus for all or most agents (not the haiku/sonnet mix originally anticipated)
- The routing-off (Sonnet) vs routing-on (opus) comparison will test: does opus produce better catch rates than Sonnet? Not: does haiku produce adequate catch rates at lower cost?
- This is still a valid comparison — it just tests a different hypothesis than originally designed
- Document the router bias in the experiment summary as a finding about RuFlo's model routing behavior

---

## Raw Router Output

```json
DEL-1:  { model: "opus", confidence: 0.498, uncertainty: 0.746, complexity: 0.570, sonnet_score: 0.860 }
DEL-2:  { model: "opus", confidence: 0.567, uncertainty: 0.530, complexity: 0.373, haiku_score: 0.253 }
ARCH-3: { model: "opus", confidence: 0.568, uncertainty: 0.472, complexity: 0.488, sonnet_score: 0.976 }
FALSE-3:{ model: "opus", confidence: 0.539, uncertainty: 0.589, complexity: 0.612, sonnet_score: 0.776 }
```
