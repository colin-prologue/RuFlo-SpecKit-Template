---
name: sparc-plan
description: Technical planning with ADR hard-stop enforcement — research pass, technology decisions, data model, API contracts, architecture. Blocks if any tech choice lacks an ADR.
---

# SPARC Plan

## Role
Translate spec into architecture and decisions. Every technology choice must have an ADR before Phase 2 begins — this is enforced, not advisory.

## Memory
```javascript
mcp__claude-flow__memory_retrieve { key: "governance-rigor", namespace: "governance" }
mcp__claude-flow__memory_retrieve { key: "spec-[feature]-summary", namespace: "specs" }
mcp__claude-flow__memory_search { pattern: "ADR", namespace: "decisions", limit: 10 }
```

Requires `specs/[feature]-spec.md`. Stop and tell user to run `/sparc-specify` first if missing.
Count existing files in `.decisions/` (both ADR_* and LOG_*) to determine next sequential number.

## Phase 1 — Research Pass
For every technology choice, library, or architectural pattern the spec implies, research: candidate options · tradeoffs · codebase precedents · known gotchas. Write `specs/[feature]-research.md`.

**ADR HARD STOP:** Before Phase 2, every technology choice in research.md needs a `.decisions/ADR_NNN_[topic].md`. Create missing ADRs now using `.decisions/templates/ADR_template.md`. ADRs and LOGs share one sequential counter.

## Phase 2 — Plan Document
Write `specs/[feature]-plan.md` with:
- **Constitution Check** — rigor level per principle and its impact on this plan
- **Technical Context** — language/runtime, patterns to follow, infrastructure constraints, external dependencies
- **Data Model** — entity names must match the spec exactly
- **API Contracts** — method/signature, input, output, error cases, auth
- **Component Architecture** — modules/services with responsibilities
- **Technology Decisions table** — decision · choice · ADR reference
- **Security Considerations** — input validation points, auth mechanism, data sanitization, secrets handling
- **Testing Strategy** — unit/integration/e2e targets and tools
- **Open Questions** — LOG reference table with "must resolve before Phase N" column

## Memory Store
```javascript
mcp__claude-flow__memory_store {
  key: "plan-[feature]-summary",
  value: "tech choices, ADRs created, open LOGs, component list",
  namespace: "decisions"
}
```

Close: ADRs created and decisions captured · open LOGs and which block implementation · next: `/sparc-review` (recommended at FULL/STANDARD) or `/sparc-tasks`.
