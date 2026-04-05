---
name: sparc-specify
description: Structured feature specification — user stories with Given/When/Then scenarios, FR-NNN requirements, measurable success criteria, quality gate validation
---

# SPARC Specify

## Role
Produce a structured, implementation-agnostic feature spec with built-in quality validation before presenting to the user.

## Memory
```javascript
mcp__claude-flow__memory_retrieve { key: "governance-rigor", namespace: "governance" }
mcp__claude-flow__memory_search { pattern: "roadmap", namespace: "specs", limit: 1 }
```

Ask at most **3** clarifying questions before drafting. State assumptions explicitly in the spec rather than asking.

## Spec File
Create `specs/[feature-slug]-spec.md`. FULL rigor = all sections required + quality gate. STANDARD = all sections. LIGHTWEIGHT = user stories + acceptance criteria minimum.

## Required Sections
1. **Problem Statement** — one paragraph, what/for whom/why now
2. **User Stories** — each with: `As a / I want / So that`, minimum 2 acceptance scenarios (happy path + error), P1/P2/P3 priority, independent testability check (4 criteria)
3. **Functional Requirements** — `FR-NNN` IDs, verb phrases, no implementation details, maps to story
4. **Success Criteria** — measurable, technology-agnostic, user/business outcome focused
5. **Key Entities** — canonical names (all downstream artifacts must match)
6. **Edge Cases & Error Paths**
7. **Explicit Assumptions** — each with risk level + validation method
8. **Out of Scope**
9. **Open Questions** — LOG reference table

Independent testability criteria per story: deployable alone · delivers value alone · no hard runtime dependency on sibling stories · all acceptance scenarios pass in isolation.

## Quality Gate (iterate up to 3× before presenting)
- [ ] Requirements use verb phrases, no framework/language names
- [ ] Every requirement independently testable
- [ ] Success criteria are measurable and technology-agnostic
- [ ] Every assumption has a risk level and validation method
- [ ] Acceptance scenarios cover both happy path and error path

## Memory Store
```javascript
mcp__claude-flow__memory_store {
  key: "spec-[feature]-summary",
  value: "user stories, key entities, top-risk assumptions",
  namespace: "specs"
}
```

Close: quality gate iterations needed · highest-risk assumptions · open questions to resolve · next: `/sparc-review` (recommended) or `/sparc-plan` (LIGHTWEIGHT only).
