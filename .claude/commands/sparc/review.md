---
name: sparc-review
description: Three-phase adversarial review — independent analysis, devil's advocate challenge, synthesis judge with preserved minority findings, hard gate with PROCEED/REVISE/OVERRIDE decision
---

# SPARC Review

## Role
Prevent groupthink through strict phase separation. Agents cannot see each other's findings until the designated synthesis step.

## Memory
```javascript
mcp__claude-flow__memory_retrieve { key: "governance-rigor", namespace: "governance" }
mcp__claude-flow__memory_search { pattern: "review-[artifact]", namespace: "reviews", limit: 2 }
```

Identify what is being reviewed (spec / plan / tasks / code) and load the artifact.

## Reviewer Panels by Artifact

**Spec:** requirements-analyst · domain-expert · risk-analyst · (security-reviewer at FULL)
**Plan:** systems-architect · security-reviewer · delivery-reviewer · (operations-reviewer at FULL)
**Tasks:** delivery-reviewer · qa-reviewer · scope-reviewer
**LIGHTWEIGHT:** 2 reviewers, skip Phase B

## Phase A — Independent Analysis
Each reviewer produces: Findings · Concerns · Recommendations · Blockers. Reviewers do not see each other's output. Collect all reports silently.

## Phase B — Devil's Advocate (skip at LIGHTWEIGHT)
Build consensus summary first: findings that appear in **2+ independent reports**.
Assign one devil's advocate (always Opus, always full rigor regardless of project level).
Give the devil's advocate **only the consensus summary**, not the full reports.
Instruction: "Challenge this consensus. What is it getting wrong? What important findings are absent? What minority position, if true, would invalidate it?"

## Phase C — Synthesis Judge
Receives: all Phase A reports + consensus summary + devil's advocate challenge.
Produces structured report: consensus findings · minority findings (explicitly preserved) · active disagreements · blind spots · blockers · recommendations (before-proceed / before-implementation / nice-to-have) · suggested ADRs · suggested LOGs · gate recommendation (PROCEED/REVISE/RE-REVIEW).

Rule: **minority position with strong evidence outranks majority with weak evidence**.

## Gate Decision
Present synthesis report and ask user to choose:
- **[P] PROCEED** — minor findings become follow-up tasks
- **[R] REVISE** — address blockers, resubmit for review
- **[V] RE-REVIEW** — major concerns warrant full new review after revision
- **[O] OVERRIDE** — creates `LOG_NNN_override-[artifact]-[date].md` documenting accepted risk

## Memory Store
```javascript
mcp__claude-flow__memory_store {
  key: "review-[artifact]-[date]",
  value: "gate decision, blockers found, suggested ADRs/LOGs",
  namespace: "reviews"
}
```
