# Retro: 001-Agent-Benchmark

**Date**: 2026-04-05
**Feature**: RuFlo Agent Benchmark Experiment (3 phases + decomposed follow-on)
**Rigor**: STANDARD

---

## Assumption Review Table

| # | Assumption | Status | Notes |
|---|---|---|---|
| A-01 | Fixture files stable | **Validated** | Used verbatim across all runs |
| A-02 | Claude-Root token baseline available | **Invalidated** (pre-caught) | No token counts in Claude-Root; Phase 1 redesigned before implementation |
| A-03 | Model tier observable via routing call | **Validated** | `hooks_model-route` works; explicit call required; became foundation of ADR_008 |
| A-04 | AgentDB per-agent granularity | **Validated** | Per-key per-namespace storage worked exactly as needed |
| A-05 | WASM is zero-LLM | **Invalidated** (pre-caught) | WASM invokes Claude; Phase 3 redesigned; ADR_006 |
| A-06 | STANDARD rigor appropriate | **Partially validated** | Worked at STANDARD; constitution never run; LOG_002 open |
| A-07 (implicit) | Decomposed framing raises confidence above 0.70 | **Invalidated** | Confidence floor at 0.51–0.57 regardless of framing; LOG_009 |
| A-08 (implicit) | Warm memory reduces output tokens | **Invalidated** | Warm increased output +13%; value is quality (PROD-2 caught), not volume; LOG_010 |
| A-09 (implicit) | Char-count proxy sufficient cross-tier | **Partially validated** | Adequate same-tier; fails for haiku vs. sonnet price comparison; LOG_011 |

**Validated**: 3 · **Invalidated**: 4 (2 pre-caught, 2 in execution) · **Partially validated**: 2 · **Untested**: 0

---

## Roadmap Impact Summary

| Assumption | Impact | Action |
|---|---|---|
| A-02 invalidated | None — handled before implementation | No change |
| A-05 invalidated (WASM) | Cancel "WASM pre-pass" roadmap item until zero-LLM path exists | Cancelled (roadmap item 006) |
| A-07 invalidated (confidence floor) | Revise any "improve routing via framing" roadmap item | Revised: ADR_008 alternatives ranking is the durable path |
| A-08 invalidated (warm = fewer tokens) | Reframe experiment 002 success criteria to quality preservation, not volume reduction | Roadmap item 002 updated |
| A-09 partial (char proxy) | New experiment 004 to add price-per-run metric | New roadmap item 004 |

---

## Top 3 Actionable Learnings

**1. Ask "is this correct?" not "is this present?" for quality-class findings**
PROD-2 was missed by every Phase A agent because tasks were framed as presence checks ("does P1/P2 rationale exist?"). It was caught when the framing became a correctness check ("does this rationale reflect user reach?"). This applies to any spec review: structural tasks must be designed to expose the defect, not just confirm existence.

**2. ADR_008 alternatives ranking is more reliable than confidence for routing**
The router's confidence output has a floor (~0.51–0.57) that doesn't respond to task framing. The alternatives ranking correctly identifies haiku-appropriate tasks (structural tasks score haiku > 0.50 in alternatives, complexity < 0.25). Use alternatives, not confidence, as the routing signal. This is already encoded in ADR_008 but should be the default mental model for any new routing decision.

**3. Warm memory is a quality lever — evaluate it on catch rate, not token count**
Warm injection increases input tokens substantially. The value is in what the re-examination surfaces (PROD-2 partial catch, 7 new findings). Evaluate future warm-memory experiments by asking "did warm catch anything cold missed?" and "did warm miss anything cold caught?" — not by comparing output char counts.

---

## New ADRs / LOGs Created

| # | Type | Topic |
|---|---|---|
| LOG_009 | LOG | Router confidence floor not improvable via task framing |
| LOG_010 | LOG | Warm memory increases token volume; value is quality improvement |
| LOG_011 | LOG | Char-count proxy insufficient for cross-tier price comparison |

---

## ReasoningBank Entries Stored

- `retro-invalidated-router-confidence-2026-04-05` (reasoningbank)
- `retro-invalidated-warm-memory-token-reduction-2026-04-05` (reasoningbank)
- `retro-validated-agentdb-per-agent-keys-2026-04-05` (reasoningbank)
- `retro-validated-phase3-first-ordering-2026-04-05` (reasoningbank)
- `retro-effort-decomposed-overhead-2026-04-05` (reasoningbank)

---

## Constitution Status

LOG_002 (rigor assumed without constitution.md) remains open. Run `/sparc-constitution` before starting experiment 002. If rigor level changes, panel composition in `benchmark-run.md` must be updated.

---

## Next Steps

1. `/sparc-constitution` — close LOG_002 before next experiment
2. Experiment 002: summarized warm injection (ready to run)
3. Experiment 003: correctness-framed haiku PROD-2 check (ready to run, low cost)
4. Experiment 004: price-per-run metric in ADR_007 (code change to benchmark-run.md)
