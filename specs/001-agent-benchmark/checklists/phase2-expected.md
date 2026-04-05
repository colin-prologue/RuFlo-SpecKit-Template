# Phase 2: Memory Warm-Up Expected Outcomes

Written before running — these are the "failing tests."
**Updated framing**: The goal is not token reduction. The goal is better detection quality
for the tokens spent. A warm agent that writes more but catches more is a good outcome.

---

## Primary Question (Updated)

Does warm AgentDB memory improve detection quality (catch rate) for equivalent or
better token efficiency? Not: does it reduce output token count.

---

## Expected Warm-Run Behavior

| Agent | Expected warm behavior | Quality outcome | Token outcome |
|---|---|---|---|
| security-reviewer | References prior IDOR finding; may deepen analysis of CRITICAL_ALERT suppression chain; may identify new angles on unsubscribe token | Catch rate ≥ cold run; possibly catches PROD-2 if memory triggers re-examination of priority framing | May increase (deeper) or decrease (skip known) |
| systems-architect | References prior admin persona and pipeline conflict findings; may spend more time on PROD-2 (priority reversal) since that was the missed issue | PROD-2 catch rate improvement is the key outcome to watch | Likely similar to cold |

---

## Success Conditions (Quality-First)

| Condition | Verdict |
|---|---|
| Warm catches an issue cold missed (PROD-2 is the candidate) | **Strong positive** — memory improved detection quality |
| Warm catches same issues as cold, output token count lower | **Positive** — memory reduced waste without quality loss |
| Warm catches same issues as cold, output token count same | **Neutral** — memory adds no value but no harm; overhead not justified |
| Warm misses an issue cold caught | **Negative** — memory context caused an agent to skip a finding it would otherwise have raised |

---

## PROD-2 Watch

PROD-2 (priority reversal: email reaches all web users, push is mobile-only) was missed
in Phase 1 routing-off. It was also Caught (partial) in Claude-Root STANDARD — but only
because the product-strategist framed it from a user-reach angle. Neither security-reviewer
nor systems-architect caught it in Phase 1.

If warm memory includes a prior systems-architect finding about "partial rollout risk from
P1/P2 ordering," the warm run may prompt systems-architect to revisit the priority framing
from a different angle. This is the most testable quality improvement hypothesis for Phase 2.

---

## Memory Contamination Risk

The AgentDB warm-up context must contain only prior Phase A findings — not benchmark-key.md,
not scoring results, not issue IDs. The contamination check (FR-003) must run on warm-run
Phase A output before scoring, same as cold. Stored findings from cold run have already
passed a contamination check, so injection risk is low but not zero (an agent could
pattern-match prior findings against known IDs if the findings are descriptive enough).

---

## Failure Mode Definition

A quality degradation finding (SC-002 fail): warm run misses any issue that cold run caught.
The specific issue and the prior finding that was injected must both be documented — this
helps diagnose whether memory context interfered with independent analysis.
