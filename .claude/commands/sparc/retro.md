# SPARC Retro — Structured Retrospective & Assumption Review

You are running a post-implementation retrospective. The core mechanic is assumption review: for each assumption recorded in specs, verify whether it was validated or invalidated by what actually happened. This prevents future phases from being built on assumptions that implementation proved wrong.

## Prerequisites
- Read `constitution.md`.
- Read `specs/[feature]-spec.md` for the assumption list (Section 7).
- Read `specs/roadmap.md` for the full roadmap assumptions.
- Read `docs/audit-*.md` (latest) if available for context.
- Ask which feature/phase this retro covers if not specified.

---

## Phase 1 — Assumption Review

For every assumption listed in the spec's Section 7, classify it:

| Status | Meaning |
|---|---|
| **Validated** | Implementation confirmed this assumption was correct |
| **Invalidated** | Implementation proved this assumption wrong |
| **Partially validated** | Assumption was correct in some cases but not others |
| **Untested** | Implementation did not exercise this assumption |

For each **Invalidated** or **Partially validated** assumption:
- What actually turned out to be true instead?
- Does this change the viability of any Phase 2 or Phase 3 roadmap items?
- Should this generate a new LOG entry to track the revised understanding?

---

## Phase 2 — Interactive Questions

Ask the user these questions one at a time:

1. **Surprises**: "What happened during implementation that you didn't expect? (anything — technical, process, scope, performance)"

2. **Difficulty calibration**: "Which tasks took significantly longer than expected? Which were faster? What caused the discrepancy?"

3. **Quality of artifacts**: "Looking at the spec, plan, and tasks retroactively — what was missing, ambiguous, or wrong that slowed you down? What was particularly useful?"

4. **Scope drift**: "Did the implementation end up doing anything not in the spec? Anything in the spec that didn't get implemented? Any decisions made during coding that should have been in an ADR?"

5. **Process**: "Was there a phase you'd skip or shorten for the next feature at this project's rigor level? Was there a phase you wish you'd spent more time on?"

6. **Risks realized**: "Did any of the risks you assumed were low turn out to matter? Did any high-risk items turn out to be fine?"

---

## Phase 3 — Roadmap Impact Analysis

For each Invalidated or Partially validated assumption, analyze the roadmap:

```
Roadmap item: [Phase 2 or 3 feature]
Affected by: Assumption [N] was invalidated
Impact: [none / delays / scope change / viability at risk / cancel]
Recommendation: [keep as-is / revise scope / defer / cancel / requires new spec]
```

Also check: Do any surprises from Phase 2 questions affect roadmap items?

---

## Phase 4 — Updates

### Update roadmap.md

Based on the assumption review and roadmap impact analysis, update `specs/roadmap.md`:

- **Priority changes**: Move items up or down based on validated/invalidated assumptions
- **Scope changes**: Update descriptions to reflect what was learned
- **New discoveries**: Add items that emerged during implementation
- **Killed features**: Move items to "Killed Ideas" with reason
- **Revised effort estimates**: Update based on difficulty calibration from Phase 2

### Update assumption list in spec

For each assumption in the spec, add a `[Validated/Invalidated/Partial/Untested]` tag and a one-line note.

### Create LOGs for invalidated assumptions

For each invalidated assumption:
```
.decisions/LOG_NNN_invalidated-assumption-[topic].md
Content: What was assumed, what was discovered, how this changes Phase 2+
```

### Create new ADRs for undocumented decisions

For any decision made during implementation that was never recorded in an ADR (often surfaced by the audit or by the scope drift question):
```
.decisions/ADR_NNN_[decision]-post-implementation.md
```

---

## Phase 5 — ReasoningBank Update

Store the retro findings in AgentDB to inform future features:

```bash
# Store validated patterns (increase confidence in this approach)
npx @claude-flow/cli@latest memory store \
  --key "retro-validated-[topic]-[date]" \
  --value "[what was validated and why it worked]" \
  --namespace reasoningbank

# Store invalidated assumptions (reduce confidence, flag as risk)
npx @claude-flow/cli@latest memory store \
  --key "retro-invalidated-[topic]-[date]" \
  --value "[what was assumed, what was actually true, watch for this next time]" \
  --namespace reasoningbank

# Store difficulty calibration (improve future effort estimates)
npx @claude-flow/cli@latest memory store \
  --key "retro-effort-[area]-[date]" \
  --value "[what took longer/shorter than expected and why]" \
  --namespace reasoningbank
```

---

## Output

Produce `docs/retro-[feature]-[date].md` with:
- Assumption review table (all assumptions with status and notes)
- Roadmap impact summary (what changed and why)
- Key learnings (top 3 most actionable insights)
- New ADRs created
- New LOGs created
- ReasoningBank entries stored

Tell the user:
- Summary of what was validated vs. invalidated
- Whether any roadmap items are at risk and what to do about them
- Whether the constitution should be updated (if project context has materially changed — e.g., compliance requirements emerged, team size changed, blast radius became higher)
- Next step: `/sparc-brainstorm` or `/sparc-specify` for the next phase feature
