# Follow-On Experiment: Decomposed Task Framing

**Logged**: 2026-04-05
**Source**: Phase 1 finding — router confidence too low to discriminate tiers with broad task descriptions
**Principle**: Tokens are not wasted by volume — they're wasted when a cheaper model would have produced equivalent output. Sonnet doing structural checks is waste. Opus reasoning through multi-component attack chains is appropriate spend.

---

## Hypothesis

Decomposing review agent tasks into typed atomic descriptions (structural check / enumeration / reasoning / judgment) will:
1. Increase router confidence above 0.70 for most tasks, enabling discriminating routing decisions
2. Route structural and enumeration tasks to haiku without quality loss
3. Route reasoning and judgment tasks to sonnet/opus with high confidence
4. Reduce total tokens spent on tasks where a cheaper model is sufficient
5. Maintain or improve catch rate by allocating expensive reasoning budget to issues that require it

This is different from the Phase 1 experiment (which tested whether routing-on reduced cost vs. routing-off). This experiment tests whether **better upstream framing changes what the router can do**.

---

## Proposed Design

### Fixture
Same spec fixture (fixture/spec.md). Same benchmark key. Spec gate only (4 planted issues).

### Panel
Same STANDARD panel composition, but each agent receives a decomposed task list instead of a single broad instruction.

### Task Decomposition Per Agent

**security-reviewer** receives 4 discrete tasks:
1. [structural] "Verify the spec requires that the preference API endpoint enforces that the authenticated user owns the preference record being modified"
2. [structural] "Verify the spec defines security properties for the unsubscribe token: expiry, single-use enforcement, and user binding"
3. [reasoning] "Explain what attack is possible if a preference API allows any authenticated user to read or modify any user's preferences, given the dependency on the Auth service for session validation"
4. [judgment] "Evaluate whether the audit logging deferral in OQ-1 creates acceptable risk given the sensitivity of CRITICAL_ALERT preferences"

**systems-architect** receives 4 discrete tasks:
1. [enumeration] "List every user role that interacts with the notification preference system according to the spec"
2. [structural] "Identify whether the P1 and P2 priority assignments appear in any section of the spec with a stated rationale tied to user reach or business impact"
3. [structural] "Check whether the Constraints section and User Story 2 are mutually consistent regarding modification of existing notification delivery pipelines"
4. [reasoning] "Explain what implementation problem arises from push notification preferences being deployed before email notification preferences, given the spec's partial rollout scenario"

### Routing Predictions
- Tasks 1-2 of each agent (structural/enumeration): expect complexity < 0.40, confidence > 0.70, haiku routing
- Tasks 3-4 (reasoning/judgment): expect complexity > 0.50, confidence > 0.70, sonnet/opus routing
- If predictions hold: ~50% of Phase A tasks run at haiku, ~50% at sonnet/opus

### Metrics
- Router confidence per task (primary: expect > 0.70 for all decomposed tasks)
- Tier distribution (expect haiku for structural, sonnet/opus for reasoning)
- Catch rate vs. Phase 1 routing-off baseline (must not regress)
- Total estimated tokens (may be higher or lower — not the primary metric)
- Quality-per-token: (issues caught) ÷ (tokens on reasoning tasks only)

### Success Criteria
- SC-A: Router confidence > 0.70 for ≥ 6 of 8 decomposed tasks
- SC-B: ≥ 2 tasks route to haiku (structural/enumeration tasks)
- SC-C: Catch rate ≥ Phase 1 routing-off baseline (2 of 3 scorable issues)
- SC-D: Decomposed-task haiku runs produce findings equivalent to the corresponding broad-framing sonnet runs for structural issues (qualitative comparison)

---

## Design Note: Consolidation Pass

Decomposed tasks require a consolidation step — individual task agents see only one question each and miss cross-cutting issues. The consolidation agent receives all atomic findings and identifies interactions (e.g., "the IDOR finding and the audit logging deferral combine into an attack chain"). This is equivalent to Phase B (devils-advocate) in the current protocol but framed as synthesis rather than adversarial challenge.

The consolidation pass runs at sonnet/opus (complex synthesis). Its cost partially offsets the haiku savings from structural tasks. Net savings are real but smaller than per-task estimates suggest.

---

## Why This Is Worth Running

Phase 1 showed the router's alternatives ranking is already correct — sonnet scores highest for moderate tasks, haiku scores near zero because task descriptions are too broad. Decomposed framing is the missing piece that would make the alternatives ranking actionable. This experiment tests whether the routing infrastructure can be made useful with minimal changes to the agent command design.
