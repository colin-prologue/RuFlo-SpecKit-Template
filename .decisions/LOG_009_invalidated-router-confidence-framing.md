---
type: LOG
status: Open
date: 2026-04-05
feature: 001-agent-benchmark
---

# LOG_009: Invalidated Assumption — Router Confidence Not Improvable via Task Framing

## What Was Assumed

The decomposed task framing follow-on experiment assumed that providing atomic, typed task descriptions (structural / enumeration / reasoning / judgment) to `hooks_model-route` would increase router confidence above 0.70, enabling direct haiku routing recommendations with high confidence.

## What Was Actually True

Router confidence returned 0.514–0.568 across all 8 decomposed task descriptions — identical to the 0.56–0.57 range for broad-framing Phase 1 descriptions. Confidence did not increase. The `tiny-dancer-neural` classifier appears to have a systematic confidence floor near 0.50 that is independent of task description quality or specificity.

Decomposed framing **did** produce lower complexity scores for structural tasks (0.236–0.241 vs. 0.437–0.505 for broad framing), and the alternatives ranking correctly identified haiku as the top non-opus tier for those tasks. The ADR_008 mechanism (use alternatives when confidence < 0.60) is the correct routing path — but it works via the alternatives ranking, not via confidence-driven recommendation.

## Implications

- Improving router confidence above 0.70 requires retraining `tiny-dancer-neural`, not refining task descriptions
- ADR_008's alternatives ranking is the durable mechanism for tier routing in this classifier
- Any future routing improvements should be evaluated on whether they change the alternatives ranking, not the confidence score
- The complexity score signal is meaningful (structural tasks score lower as expected); confidence score is not a reliable routing signal at the current classifier version

## Resolution Needed Before

Any roadmap item that relies on "confidence > 0.70 as routing gate" must be revised. Replace confidence threshold with alternatives-ranking threshold (e.g., "use haiku if haiku scores > 0.50 in alternatives and complexity < 0.30").

## Cross-references

ADR_008 — adjusted routing strategy (mitigation already in place)
`specs/001-agent-benchmark/runs/2026-04-05-spec-followon-decomposed.md` — SC-A FAIL evidence
