---
name: sparc-retro
description: Structured retrospective — assumption review table (Validated/Invalidated/Partial/Untested), roadmap impact analysis, LOGs for invalidated assumptions, ReasoningBank update
---

# SPARC Retro

## Role
Validate or invalidate the assumptions from the spec before they silently shape the next phase. Feed learnings back into the roadmap and ReasoningBank.

## Memory
```javascript
mcp__claude-flow__memory_retrieve { key: "governance-rigor", namespace: "governance" }
mcp__claude-flow__memory_retrieve { key: "spec-[feature]-summary", namespace: "specs" }
mcp__claude-flow__memory_search { pattern: "retro", namespace: "reasoningbank", limit: 3 }
```

Ask which feature/phase this retro covers if not specified.

## Phase 1 — Assumption Review

For every assumption in the spec's assumptions section, classify:
- **Validated** — implementation confirmed it correct
- **Invalidated** — implementation proved it wrong  
- **Partially validated** — correct in some cases, not others
- **Untested** — implementation didn't exercise this assumption

For each Invalidated/Partially validated: what was actually true · does this change any Phase 2/3 roadmap items · create a LOG entry.

## Phase 2 — Interactive Questions (one at a time)

1. What happened during implementation that you didn't expect?
2. Which tasks took significantly longer or shorter than expected? Why?
3. Looking at the spec, plan, and tasks retroactively — what was missing, ambiguous, or wrong?
4. Did implementation do anything not in the spec, or skip anything that was?
5. Was there a phase you'd skip/shorten or wish you'd spent more time on?
6. Did any low-risk assumptions matter? Any high-risk ones that were fine?

## Phase 3 — Roadmap Impact

For each Invalidated/Partially validated assumption, assess roadmap items:
- Impact: none · delays · scope change · viability at risk · cancel
- Recommendation: keep / revise scope / defer / cancel / requires new spec

## Phase 4 — Updates

- Update assumption classifications in the spec (add status tag + one-line note)
- Update `specs/roadmap.md`: priority changes · scope changes · new discoveries · killed features · revised effort estimates
- Create `LOG_NNN_invalidated-assumption-[topic].md` for each invalidated assumption
- Create `ADR_NNN_[decision]-post-implementation.md` for any undocumented implementation decisions

## Memory Store
```javascript
// Validated patterns — increase confidence
mcp__claude-flow__memory_store {
  key: "retro-validated-[topic]-[date]",
  value: "what was validated and why it worked",
  namespace: "reasoningbank"
}

// Invalidated assumptions — flag as risk
mcp__claude-flow__memory_store {
  key: "retro-invalidated-[topic]-[date]",
  value: "what was assumed vs. what was true — watch for this next time",
  namespace: "reasoningbank"
}

// Effort calibration — improve future estimates
mcp__claude-flow__memory_store {
  key: "retro-effort-[area]-[date]",
  value: "what took longer/shorter than expected and why",
  namespace: "reasoningbank"
}
```

Write `docs/retro-[feature]-[date].md`: assumption review table · roadmap impact summary · top 3 actionable learnings · new ADRs/LOGs created · ReasoningBank entries stored.

Close: validated vs. invalidated summary · roadmap items at risk · whether constitution needs updating (team/risk context changed) · next: `/sparc-brainstorm` or `/sparc-specify` for next phase.
