# SPARC Specify — Structured Feature Specification

You are creating a rigorous, structured specification for a feature before any implementation begins. The spec is the contract between intent and code.

## Prerequisites
- Read `constitution.md` to understand rigor levels. FULL = all sections required with quality gate validation. STANDARD = all sections required. LIGHTWEIGHT = user stories + acceptance criteria minimum.
- Read `specs/roadmap.md` if it exists to understand context.
- Ask the user: "Which feature are we specifying?" if not already clear.
- Ask at most 3 clarifying questions before drafting. Do not ask more — make reasonable assumptions and flag them explicitly.

---

## Spec File Location

Create `specs/[feature-slug]-spec.md` where `feature-slug` is a kebab-case name derived from the feature.

---

## Spec Template

Produce a spec with these sections:

```markdown
# Feature Specification: [Feature Name]
**Status:** Draft
**Author:** [user name if known, else "Team"]
**Created:** [date]
**Last Updated:** [date]
**Roadmap phase:** [Phase N from roadmap, or "ad hoc"]

---

## 1. Problem Statement
[One paragraph: what problem does this solve, for whom, and why now?]

## 2. User Stories

### Story US-001: [Short title]
**Priority:** P1 / P2 / P3
**As a** [user type]
**I want to** [action]
**So that** [outcome/value]

**Acceptance Scenarios:**

**Scenario 1: [Happy path name]**
- Given [precondition]
- When [action]
- Then [expected outcome]

**Scenario 2: [Edge case or error path]**
- Given [precondition]
- When [action]
- Then [expected outcome]

**Independent Testability Check:**
- [ ] Can be deployed without Story US-002 being complete
- [ ] Delivers value to users independently
- [ ] No hard runtime dependency on sibling stories
- [ ] All acceptance scenarios pass in isolation

[Repeat for each user story. Minimum 1, maximum 5 per spec.]

## 3. Functional Requirements

| ID | Requirement | Priority | Story |
|---|---|---|---|
| FR-001 | [requirement — verb phrase, not implementation] | P1 | US-001 |
| FR-002 | ... | | |

Note: Requirements must be implementation-agnostic. ✓ "System returns results within user's patience threshold" ✗ "API responds in < 200ms"

## 4. Success Criteria

Measurable, technology-agnostic outcomes that define "done":

- [ ] [Criterion 1 — quantified where possible, user-outcome focused]
- [ ] [Criterion 2]
- [ ] [Criterion N]

## 5. Key Entities & Concepts
[Data model sketch or domain concept glossary. Names used here become canonical — all ADRs, code, and tasks must use these names.]

| Entity | Description | Key attributes |
|---|---|---|
| [Name] | [what it is] | [attribute list] |

## 6. Edge Cases & Error Paths
- [Edge case 1]: [how it should behave]
- [Edge case 2]: [how it should behave]

## 7. Explicit Assumptions
[Every assumption that, if false, would invalidate part of this spec]
1. [Assumption] — Risk: [low/medium/high] — Validation method: [how to verify]

## 8. Out of Scope
[Explicit list of things this spec does NOT cover, to prevent scope creep]

## 9. Open Questions (LOG references)
| Question | Owner | LOG reference | Status |
|---|---|---|---|
| [question] | [person] | LOG_NNN | Open |

## 10. Decision References
| Decision | ADR reference |
|---|---|
| [decision made in this spec] | ADR_NNN (to be created in /sparc-plan) |
```

---

## Quality Gate Validation

After drafting, check every item in this list. Iterate up to 3 times before presenting to the user. Flag any items that cannot be satisfied and explain why.

**User Stories**
- [ ] Each story follows "As a / I want / So that" format
- [ ] Each story has at least 2 acceptance scenarios (happy path + error/edge)
- [ ] All 4 independent testability criteria checked for each story
- [ ] Stories are prioritized P1/P2/P3

**Functional Requirements**
- [ ] Each requirement uses a verb phrase (not noun phrase)
- [ ] No implementation details (no framework names, no specific technologies)
- [ ] Each requirement is independently testable
- [ ] Each requirement maps to at least one user story

**Success Criteria**
- [ ] Each criterion is measurable (contains a metric or observable outcome)
- [ ] Each criterion is technology-agnostic (no stack-specific terms)
- [ ] Each criterion is user/business focused (not engineering focused)
- [ ] Each criterion can be verified without knowing the implementation

**Assumptions**
- [ ] Every assumption has a risk level and validation method
- [ ] No assumption is obvious or trivially true

---

## After Spec is Complete

Tell the user:
- Which quality gate items required iteration and what changed
- Which assumptions carry the highest risk
- Open questions that need resolution before planning
- Next step: run `/sparc-review` for spec review, or `/sparc-plan` to proceed directly (only recommended at LIGHTWEIGHT rigor)
