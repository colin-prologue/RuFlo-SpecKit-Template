# SPARC Brainstorm — Structured Ideation Workflow

You are running a structured brainstorming session before any specification work begins. Follow the six phases in order. Do not skip the prior art scan (Phase 2) — it is a hard gate before ideation.

## Prerequisites
- Read `constitution.md` if it exists. It calibrates how many brainstorming agents to spawn and how rigorous the prioritization phase should be.
- Ask the user: "What problem or feature are we brainstorming?" if not already stated.

---

## Phase 1 — Problem Definition

Before any ideas, deeply define the problem:

1. **Problem statement**: What specific problem are we solving? Who experiences it? When?
2. **Root cause**: What is the underlying cause (not just the symptom)?
3. **Scope boundaries**: What is explicitly IN scope? What is explicitly OUT of scope?
4. **Success definition**: How would we know the problem is solved? What does "done" look like?
5. **Constraints**: Budget, time, technical, organizational constraints that shape the solution space.

Produce a `specs/brainstorm-problem.md` with these five sections filled in.

---

## Phase 2 — Prior Art Scan (HARD GATE)

Before any ideation, research what already exists. This phase MUST complete before Phase 3 begins.

Search for:
- Existing libraries, frameworks, or tools that solve this problem
- Prior attempts in this codebase (search `specs/`, `docs/`, git history for similar terms)
- Industry patterns or established approaches for this problem type
- Known failures or anti-patterns to avoid

Produce a `specs/brainstorm-priorart.md` containing:
- **What exists today**: tools/libraries/approaches that address this
- **Gaps remaining**: what none of them adequately solve
- **Tried and failed**: known approaches that didn't work and why
- **Constraints from prior art**: anything the solution must be compatible with

**Share the prior art summary with all ideation agents in Phase 3.** No agent should propose something already covered without explicitly addressing why their approach is better.

---

## Phase 3 — Divergent Ideation (Four Agents)

Spawn four specialized perspectives simultaneously. Each receives:
- The problem statement from Phase 1
- The prior art summary from Phase 2
- The instruction: **generate ideas only, no evaluation, no feasibility filtering yet**

**Agent 1 — The Visionary**
Generate 3–5 ambitious, forward-looking solutions. Think 2–3 years ahead. Ignore current technical constraints. Focus on what SHOULD exist if anything were possible.

**Agent 2 — The User Advocate**
Generate 3–5 solutions centered entirely on user experience and pain reduction. Start from the user's workflow and work backwards. What would make this delightful?

**Agent 3 — The Technologist**
Generate 3–5 solutions leveraging specific technical capabilities: existing libraries, architectural patterns, language features, or infrastructure already in place. Practical and buildable.

**Agent 4 — The Provocateur**
Generate 3–5 deliberately contrarian ideas. Challenge the problem framing itself. What if the problem doesn't need solving? What if we solve the opposite? What if we remove a constraint everyone assumes is fixed?

Collect all ideas into `specs/brainstorm-ideas.md` organized by agent perspective. Do not evaluate yet.

---

## Phase 4 — Convergent Prioritization

Now evaluate. Apply MoSCoW + effort scoring to each idea.

**MoSCoW classification:**
- **Must Have**: Directly solves the core problem, no workaround exists
- **Should Have**: High value, acceptable workaround exists short-term
- **Could Have**: Nice to have, low cost, easily deferred
- **Won't Have (now)**: Out of scope for current phase, but worth recording

**Effort scoring (1–5):**
- 1 = hours
- 2 = days
- 3 = 1–2 weeks
- 4 = month
- 5 = quarter+

**Priority score = (MoSCoW weight × 3) / effort**
- Must=4, Should=3, Could=2, Won't=0

Sort ideas by priority score within each MoSCoW bucket. The top 3–5 ideas across Must + Should become candidates for the roadmap.

---

## Phase 5 — Dependency Mapping

For the top candidates, identify:
- **Prerequisite dependencies**: What must exist before this idea can be implemented?
- **Enables**: What future capabilities does this idea unlock?
- **Conflicts**: Does this idea constrain or rule out any other ideas?
- **Sequencing**: Given dependencies, what is the natural build order?

Draw a simple dependency graph in the output (text-based is fine).

---

## Phase 6 — Roadmap Generation

Produce or update `specs/roadmap.md` with:

```markdown
# Feature Roadmap

## Phase 1 (Current)
### [Idea name] — Must Have, Effort: [N]
**What**: [one-sentence description]
**Why**: [value delivered]
**Assumptions**: [list of assumptions that must be true for this to work]
**Success criteria**: [how we'll know it's done]

## Phase 2 (Next)
...

## Parking Lot (Won't Have Now)
- [idea] — [brief reason for deferral]

## Killed Ideas
- [idea] — [why it was ruled out]
```

Also update `specs/brainstorm-notes.md` with session summary: date, participants, key insights, strongest dissents, open questions.

---

## Closing

Tell the user:
- Top 3 prioritized ideas and why they ranked highest
- Any ideas from the Provocateur that challenged the problem framing worth discussing
- Key assumptions in the roadmap that could invalidate the plan if wrong
- Next step: run `/sparc-specify` on the Phase 1 feature to begin structured specification
