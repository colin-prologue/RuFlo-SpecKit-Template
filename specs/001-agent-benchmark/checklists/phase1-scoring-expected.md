# Phase 1: Scoring Expectations

Written before Phase 1 runs — these are the expected detection outcomes.
Scoring pass compares actual catches against this checklist.

---

## STANDARD Panel Composition (RuFlo)

- **Phase A**: security-reviewer, systems-architect
- **Phase B**: devils-advocate
- **Phase C**: synthesis judge

**Critical difference from Claude-Root STANDARD**: Claude-Root's STANDARD panel was
product-strategist + devils-advocate (no security-reviewer). RuFlo's STANDARD includes
security-reviewer but not product-strategist. This changes expected catch rates significantly.

---

## Expected Catch Results (Spec Gate)

| Planted Issue | Severity | Expected Catching Agent | Expected Result | Rationale |
|---|---|---|---|---|
| PROD-1 | HIGH | product-strategist | **Missed** | product-strategist is NOT in RuFlo STANDARD panel; systems-architect or devils-advocate may catch it but it is not their specialty — flag if caught |
| PROD-2 | MEDIUM | product-strategist | **Missed or Caught (partial)** | Same reason as PROD-1; if systems-architect raises the priority inversion via architectural impact, score as Caught (partial) |
| SEC-1 | HIGH | security-reviewer | **Caught** | security-reviewer IS in RuFlo STANDARD; this is the primary detection quality improvement over Claude-Root STANDARD (which missed SEC-1) |
| FALSE-1 | — | none | **Watch devils-advocate** | Claude-Root DA raised this as MEDIUM false positive in both STANDARD and LIGHTWEIGHT; expect same behavior here |

---

## Contrast with Claude-Root STANDARD Results

| Issue | Claude-Root STANDARD | RuFlo STANDARD Expected | Delta |
|---|---|---|---|
| PROD-1 | Caught (product-strategist) | Missed | Regression — no product-strategist in panel |
| PROD-2 | Caught (partial) | Missed or Caught (partial) | Neutral |
| SEC-1 | Missed | Caught | Improvement — security-reviewer added |
| FALSE-1 | False positive (DA) | False positive (DA) | No change expected |

**Net**: RuFlo STANDARD trades PROD-1 detection for SEC-1 detection. Which panel is "better"
depends on whether product gaps or security gaps are the higher priority for the use case.

---

## Token / Character Count Expectations

### Routing-Off Pass (all Sonnet)
- 3 Phase A agent calls, each receiving full fixture/spec.md (~3,500 chars) + system prompt
- Estimated input chars per agent: ~4,500 (fixture + prompt instructions)
- Total Phase A input estimate: ~13,500 chars (~3,375 tokens)
- Output expected: 300–800 chars of findings per agent
- Tokens-per-caught-issue baseline: depends on how many issues are Caught

### Routing-On Pass (adjusted routing per ADR_008)
- Same fixture input; model tier per agent determined by hooks_model-route + adjustment
- Expected tier per agent: likely sonnet for both Phase A agents (router confidence ~50-57%)
- If all agents use sonnet: cost identical to routing-off; efficiency delta = routing call overhead only
- If any agent uses haiku: input processing cheaper; output may be shorter (quality question)
- Routing call overhead: ~4 calls × ~2ms = negligible latency; no token cost

---

## Scoring Rule Verification

Before running, verify the command applies these rules:

**Caught**: finding references correct artifact section + core problem area
- Example: "[security-reviewer] The spec's auth service dependency does not include a
  requirement that the endpoint verify the caller owns the preferences being modified"
  → Caught for SEC-1 (correct artifact: spec, correct problem: ownership enforcement gap)

**Caught (partial)**: correct artifact, wrong framing
- Example: "[systems-architect] The auth service dependency seems underspecified"
  → Caught (partial) for SEC-1 (correct artifact section, too vague)

**Missed**: no finding addresses the planted issue
- No finding mentions ownership enforcement or IDOR at the preference endpoint → Missed for SEC-1

**False Positive (FALSE-*)**: raised as definitive HIGH/MEDIUM without hedging
- "[devils-advocate] The absence of a master toggle is a HIGH gap" → False positive for FALSE-1
- "[devils-advocate] The master toggle deferral may need justification" → NOT a false positive (hedged)
