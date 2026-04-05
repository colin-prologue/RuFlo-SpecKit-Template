# SPARC Plan — Technical Planning with ADR Enforcement

You are creating the technical plan for a specified feature. Planning is the bridge between specification and implementation. It translates WHAT (spec) into HOW (architecture + decisions).

## Prerequisites
- Read `constitution.md` for rigor level.
- Read the feature spec from `specs/[feature]-spec.md`. If it doesn't exist, stop and tell the user to run `/sparc-specify` first.
- Read `specs/roadmap.md` for sequencing context.
- Count existing ADRs in `.decisions/` to determine the next ADR number.

---

## Phase 1 — Research Pass

For every technology choice, third-party library, or architectural pattern the spec implies, spawn a research agent to investigate:

- What are the candidate options?
- What are the tradeoffs?
- What do the docs say about our use case?
- Are there known issues or gotchas?
- What does the existing codebase already use (if any)?

Produce `specs/[feature]-research.md` with findings organized by decision topic.

**ADR HARD STOP**: Before proceeding to Phase 2, every technology choice or significant architectural decision in `research.md` MUST have a corresponding ADR file created in `.decisions/`. This is not optional. If any technology choice lacks an ADR, halt and create the ADR before continuing.

Create ADRs using the template at `.decisions/templates/ADR_template.md`. Fill in all sections. Use the next available sequential number (ADRs and LOGs share a counter — check both `.decisions/ADR_*.md` and `.decisions/LOG_*.md` files to find the next number).

---

## Phase 2 — Plan Document

Produce `specs/[feature]-plan.md`:

```markdown
# Technical Plan: [Feature Name]
**Status:** Draft
**Spec reference:** specs/[feature]-spec.md
**Created:** [date]

## Constitution Check
| Principle | Rigor | Impact on this plan |
|---|---|---|
| TDD | [level] | [how testing will be handled] |
| Security by Default | [level] | [security measures included] |
| Documentation Currency | [level] | [what docs will be updated] |
| Decision Transparency | [level] | [ADRs created: list them] |

## Technical Context
- **Language & runtime:** [from constitution / codebase]
- **Existing patterns to follow:** [list relevant patterns from codebase]
- **Infrastructure constraints:** [deployment target, limits]
- **Dependencies on other systems:** [list]

## Data Model
[Entity definitions matching the canonical names from the spec exactly]

| Entity | Fields | Constraints | Notes |
|---|---|---|---|
| [name from spec] | [fields] | [constraints] | |

## API Contracts
[For any public or internal APIs being created or modified]

### [Endpoint or interface name]
- **Method/signature:** [details]
- **Input:** [schema]
- **Output:** [schema]
- **Error cases:** [list]
- **Auth:** [mechanism]

## Component Architecture
[How the implementation is structured — components, modules, services]

[Text diagram or component list with responsibilities]

## Technology Decisions
| Decision | Choice | ADR |
|---|---|---|
| [e.g. "ORM for database access"] | [e.g. "Prisma"] | ADR_NNN |

## Security Considerations
[Based on Security by Default rigor level from constitution]
- [ ] Input validation at: [list boundaries]
- [ ] Authentication: [mechanism]
- [ ] Authorization: [checks required]
- [ ] Data sanitization: [where needed]
- [ ] Secrets management: [how credentials are handled]

## Testing Strategy
[Based on TDD rigor level from constitution]
- Unit test targets: [list]
- Integration test targets: [list]
- E2E test targets: [list]
- Test infrastructure: [tools, mocks needed]

## Open Questions (LOG references)
| Question | LOG | Must resolve before | Owner |
|---|---|---|---|
| [question] | LOG_NNN | [phase 1/2/3] | [person] |

## Phase Breakdown
[High-level implementation phases — detailed tasks come from /sparc-tasks]

**Phase 1 (Story US-001):** [description]
**Phase 2 (Story US-002):** [description]
```

---

## ADR Creation Instructions

For every technology decision, create `.decisions/ADR_NNN_[topic].md` using the template. Key sections:
- **Context**: Why this decision needed to be made
- **Decision**: What was decided
- **Rationale**: Why this option over alternatives
- **Alternatives considered**: Brief note on each rejected option and why
- **Consequences**: What becomes easier and harder as a result
- **Related**: References to spec, LOG entries, other ADRs

Cross-reference each ADR from the plan's Technology Decisions table.

---

## LOG Creation Instructions

For every open question, uncertainty, or challenge that is NOT a decision, create `.decisions/LOG_NNN_[topic].md`. LOGs are for:
- Open questions that block a decision
- Challenges to a decision already made
- Risks being tracked
- Assumptions being monitored

---

## After Plan is Complete

Tell the user:
- How many ADRs were created and what decisions they capture
- How many LOGs are open and which are blocking
- Whether any open questions must be resolved before implementation begins (these are "must resolve before Phase 1" LOGs)
- Next step: run `/sparc-review` on the plan (recommended at FULL/STANDARD rigor), or `/sparc-tasks` to generate tasks
