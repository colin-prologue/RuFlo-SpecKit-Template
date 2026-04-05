---
name: sparc-audit
description: Bidirectional doc-code consistency audit — three passes (Docs→Code, Code→Docs, Crosscheck), five-dimension health score (A–F), proactive ADR recommendations for undocumented decisions
---

# SPARC Audit

## Role
Surface drift between documentation and code before it becomes technical debt. Three passes, graded health score, proactive ADR recommendations for decisions embedded in code.

## Memory
```javascript
mcp__claude-flow__memory_retrieve { key: "governance-rigor", namespace: "governance" }
mcp__claude-flow__memory_search { pattern: "ADR", namespace: "decisions", limit: 20 }
mcp__claude-flow__memory_search { pattern: "audit", namespace: "audits", limit: 2 }
```

Ask which feature or scope to audit if not specified. Default: full project.

## Pass 1 — Docs → Code

| Check | Flag on failure |
|---|---|
| Each finalized ADR reflected in code | `ADR_DRIFT` |
| Each user story has a passing test | `SPEC_GAP` |
| Implementation matches spec behavior | `SPEC_DRIFT` |
| Architecture matches plan structure | `PLAN_DRIFT` |
| Completed tasks have observable evidence | `TASK_UNVERIFIED` |
| API implementations match defined contracts | `CONTRACT_DRIFT` |

## Pass 2 — Code → Docs

| Check | Flag on finding |
|---|---|
| Dependencies not in any ADR or plan | `UNDOCUMENTED_DEPENDENCY` |
| Design patterns not described in plan | `UNDOCUMENTED_ARCHITECTURE` |
| Public APIs not documented in spec/plan | `UNDOCUMENTED_API` |
| Build/test commands in CLAUDE.md still accurate | `CLAUDEMD_STALE` |
| Exported symbols with no callers | `DEAD_CODE` |
| Hardcoded values representing implicit decisions | `IMPLICIT_DECISION` |

## Pass 3 — Consistency Crosscheck (FULL rigor only)
- Same concept named differently across spec/plan/code/tests → `NAMING_DRIFT`
- Same error handled inconsistently across modules → `ERROR_HANDLING_DIVERGENCE`
- Same logic implemented multiple times → `DUPLICATE_IMPL`

## Health Score

| Dimension | Weight | Basis |
|---|---|---|
| ADR Compliance | 25% | `ADR_DRIFT` count |
| Spec Coverage | 25% | % of acceptance scenarios with passing tests |
| Documentation Freshness | 20% | `PLAN_DRIFT` + `CLAUDEMD_STALE` |
| Code Consistency | 15% | `NAMING_DRIFT` + `DUPLICATE_IMPL` |
| Decision Tracking | 15% | `IMPLICIT_DECISION` + `UNDOCUMENTED_ARCHITECTURE` |

A = 0 flags · B = 1-2 minor · C = 3-5 or 1 major · D = 6+ or 2+ major · F = critical `ADR_DRIFT` or security issue

## Output
Write `docs/audit-[date].md`: health score table · findings by flag type (critical → high → medium → low) · recommended new ADRs for decisions found in code · recommended new LOGs · cleanup candidates.

## Memory Store
```javascript
mcp__claude-flow__memory_store {
  key: "audit-[date]-result",
  value: "overall grade, critical flags, recommended ADRs",
  namespace: "audits"
}
```

Close: overall grade · most critical findings · what to fix before next feature · next: `/sparc-retro`.
