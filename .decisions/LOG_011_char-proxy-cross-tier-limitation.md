---
type: LOG
status: Open
date: 2026-04-05
feature: 001-agent-benchmark
---

# LOG_011: Partially Validated — Character-Count Proxy Insufficient for Cross-Tier Cost Comparison

## What Was Assumed

ADR_007's character-count proxy (chars ÷ 4 ≈ tokens) is sufficient for comparing token efficiency across benchmark runs.

## What Was Actually True

The proxy is adequate for comparing runs where all agents use the same model tier (e.g., Phase 1 routing-off vs. Phase 2 cold, both all-sonnet). It fails for cross-tier comparisons where haiku and sonnet agents produce similar token volumes but at 15× different prices.

In the decomposed follow-on experiment: 2 haiku tasks and 6 sonnet tasks were compared against 2 broad-framing sonnet tasks. The "decomposed costs 107% more tokens" finding is misleading — the 2 haiku tasks (~2,350 tokens) cost ~$0.00047 at haiku rates vs. ~$0.007 if run at sonnet. The token count comparison made decomposed look worse; a price comparison would partially close the gap.

## Resolution Needed

Before next decomposed-framing experiment, implement a price-per-run calculation:
- Add a pricing table to ADR_007 (haiku: ~$0.0002/k input, ~$0.001/k output; sonnet: ~$0.003/k input, ~$0.015/k output; opus: ~$0.015/k input, ~$0.075/k output — verify current Anthropic pricing at run time)
- Calculate per-agent cost using tier-aware pricing, not just token count
- Report both token count (for volume comparison) and estimated cost (for efficiency comparison)

## Impact

Does not invalidate any Phase 1/2/3 findings (all those runs used same-tier agents). Does affect decomposed follow-on economics interpretation. Any future experiment mixing tiers must use price-per-run, not token-count proxy.

## Cross-references

ADR_007 — character-count proxy (needs pricing table extension)
`specs/001-agent-benchmark/runs/2026-04-05-spec-followon-decomposed.md` — Token Efficiency Analysis section
