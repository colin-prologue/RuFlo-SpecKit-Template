# Phase 3: Router Classification Expected Outcomes

**Written before running** — this is the "failing test."
Scoring pass compares actual hooks_model-route outputs against these thresholds.

---

## Expected Complexity Thresholds

| Issue ID | Issue Type | Reasoning Demand | Expected Complexity | Expected Model | Classification Error If... |
|---|---|---|---|---|---|
| DEL-1 | TDD ordering violation | Structural — compare task IDs to verify test precedes implementation | < 0.40 | haiku | complexity ≥ 0.40 OR model = sonnet/opus |
| DEL-2 | Parallel write conflict | Structural — detect two [P]-marked tasks targeting the same file | < 0.40 | haiku | complexity ≥ 0.40 OR model = sonnet/opus |
| ARCH-3 | Cross-phase dependency chain | Reasoning — trace T009→T011→T015/T016 across phase boundaries | > 0.50 | sonnet or opus | complexity ≤ 0.50 OR model = haiku |
| FALSE-3 | False positive trap | Reasoning — requires reading notes section to avoid raising a false concern | any | any | N/A — low confidence is expected and interesting; no target threshold |

---

## Classification Error Definitions

**DEL-1 error**: Router assigns complexity ≥ 0.40 or recommends sonnet/opus.
Interpretation: router is treating a mechanical ID-comparison task as requiring reasoning.
Risk: routing-on pass will unnecessarily spend Sonnet tokens on a haiku-tier check.

**DEL-2 error**: Router assigns complexity ≥ 0.40 or recommends sonnet/opus.
Interpretation: router is treating a file-name pattern-match as requiring reasoning.
Risk: same as DEL-1.

**ARCH-3 error**: Router assigns complexity ≤ 0.50 or recommends haiku.
Interpretation: router underestimates a multi-hop inference task.
Risk: routing-on pass assigns ARCH-3 analysis to haiku, which may miss the cross-phase
dependency — degrading detection quality on ARCH-3-type issues.

**FALSE-3 note**: No classification error defined. Low confidence (< 0.60) on FALSE-3 is
consistent with the task requiring contextual reading. Record confidence score for analysis.

---

## Interpretation Notes

- If ARCH-3 routes to haiku: flag this finding prominently in Phase 1 routing-on report.
  The routing-on pass may miss ARCH-3-type planted issues, making the routing-off vs routing-on
  catch rate comparison more meaningful (not just a cost comparison, but a quality tradeoff).
- If DEL-1 and DEL-2 both route to haiku correctly: strong signal that the router can
  distinguish mechanical from reasoning tasks at the task gate. Positive evidence for
  using routing in Phase 1.
- Router confidence < 0.60 on any issue: note in report; treat routing recommendation
  as uncertain; Phase 1 routing-on results for low-confidence decisions should be
  interpreted with caution.
