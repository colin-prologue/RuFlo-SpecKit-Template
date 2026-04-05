---
type: LOG
status: Open
date: 2026-04-05
feature: 001-agent-benchmark
---

# LOG_010: Invalidated Assumption — Warm Memory Reduces Output Token Volume

## What Was Assumed

Phase 2 of the benchmark assumed that warm AgentDB memory would reduce Phase A output token volume — agents with prior findings already in context would generate shorter outputs by endorsing priors rather than regenerating them. "Memory delta = positive = reduction" was the success framing in SC-002.

## What Was Actually True

Warm Phase A output increased by +13% (+800 chars) vs. cold. Warm input increased by ~50–60% per agent due to prior findings injection. Total estimated token cost increased ~40%.

The value of warm memory is in detection quality, not volume reduction:
- PROD-2 (missed cold) was caught (partial) warm — systems-architect re-examined P1/P2 ordering via a new angle (regulatory risk)
- 7 new findings added (3 security, 4 architecture)
- 1 prior finding retracted (OQ-2 cross-reference — improved accuracy)
- No quality regression — all cold catches were endorsed warm

## Root Cause of Framing Error

The spec's SC-002 framing encoded a false model of how warm memory works: "less to generate = shorter output." In practice, warm injection prompts re-examination, which produces more output (new angles, endorsements, revisions) not less.

## Corrected Framing

Warm memory is a **quality lever**, not an **efficiency lever**. Evaluate warm memory on:
- Catch rate delta (did warm catch anything cold missed?)
- New finding signal quality (are new findings actionable?)
- Quality degradation absence (did warm miss anything cold caught?)

Token cost of warm memory has two components:
1. Input overhead from injection (dominant — prior findings text prepended to each prompt)
2. Output growth from re-examination (secondary — new findings add output chars)

## Optimization Path

Summarized injection (3–5 sentence summary per agent vs. full prior findings text) would reduce input overhead ~60–70% while preserving re-examination benefit. This is the correct follow-on experiment, not another full cold vs. warm comparison.

## Cross-references

`specs/001-agent-benchmark/runs/2026-04-05-spec-phase2-warm.md` — SC-002 evidence
`specs/001-agent-benchmark/checklists/phase2-expected.md` — quality-first reframing (mid-experiment correction)
