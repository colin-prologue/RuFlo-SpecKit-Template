# SPARC Implement — Guided Implementation

You are executing the implementation phase. Work through tasks in `specs/[feature]-tasks.md` in order, following TDD discipline and checking for extensions before beginning.

## Prerequisites
- Read `constitution.md` for rigor levels.
- Read `specs/[feature]-tasks.md`. If it doesn't exist, stop and tell the user to run `/sparc-tasks` first.
- Read `specs/[feature]-spec.md` and `specs/[feature]-plan.md` for context.
- Check for `extensions.yml` (see below).

---

## Step 1 — Extensions Check

Before writing any code, check if `extensions.yml` exists at the project root or in `config/`.

If it exists, read it. It may define mandatory or optional pre-implementation hooks:

```yaml
# extensions.yml format
hooks:
  pre-implementation:
    - name: security-scan
      type: mandatory        # mandatory = block if fails | optional = warn only
      command: npm run security-scan
      on-failure: block

    - name: accessibility-check
      type: optional
      command: npm run a11y-check
      on-failure: warn

    - name: ux-review
      type: mandatory
      prompt: "Has UX reviewed the spec and plan for Story US-001?"
      on-failure: block
```

Run all `mandatory` hooks. If any fail:
- Show the failure output
- Ask the user: "This mandatory pre-implementation check failed. How would you like to proceed?"
- Do NOT continue implementation until the user explicitly confirms or the check passes.

Run `optional` hooks. If they fail, display a warning but continue.

If `extensions.yml` does not exist, skip this step silently.

---

## Step 2 — Checklist Verification

Before starting tasks, verify:

- [ ] All ADRs referenced in the plan are finalized (not Draft status)
- [ ] All `must resolve before Phase 1` LOGs are resolved
- [ ] `constitution.md` is still accurate (has the project context changed?)
- [ ] Build currently passes (`npm run build` or equivalent)
- [ ] Test suite currently passes with no pre-existing failures

If any checklist item fails, show it to the user and ask how to proceed. Do not begin implementation with a broken baseline.

---

## Step 3 — Task Execution

Work through tasks in order. For each task:

1. **Mark in progress**: Update the task checkbox to `[-]` (in-progress marker) before starting
2. **Read the task acceptance criteria** before writing any code
3. **For test tasks**: Write the test first. Run it. Confirm it fails for the right reason (not a syntax error — the test should run and fail because the feature doesn't exist yet).
4. **For implementation tasks**: Write the minimum code to make the tests pass. Do not add functionality beyond what the tests require.
5. **After each task**: Run the full test suite to confirm no regressions. If a regression occurs, fix it before moving to the next task.
6. **Mark complete**: Update the task checkbox to `[x]` when the acceptance criteria are met.

### TDD discipline
- Red (failing test) → Green (passing) → Refactor is the only allowed sequence
- Never write implementation before the failing test exists
- The test must fail for the right reason before implementation begins

### Staying in scope
- Implement only what the current task requires
- If you notice something unrelated that could be improved, add it as a note at the bottom of the task file — do not implement it now
- If a task reveals a gap in the spec or plan, create a LOG entry and flag it to the user before proceeding

---

## Step 4 — Story Completion Verification

After the final task in each story:

Run the independent testability check:
- [ ] Story can be deployed without next story being complete
- [ ] Story delivers user value independently
- [ ] No hard runtime dependency on sibling stories
- [ ] All acceptance scenarios from spec pass in isolation

If all four pass, tell the user: "Story US-00N is complete and independently deployable."

If any fail, flag the specific criterion and the task(s) that caused it.

---

## Step 5 — Feature Completion

When all tasks are complete:

1. Run the full Definition of Done checklist from `specs/[feature]-tasks.md`
2. Run the build: if it fails, fix it before declaring completion
3. Run all tests: if any fail, fix them before declaring completion
4. Confirm all ADRs are finalized
5. Confirm all blocking LOGs are resolved

Tell the user:
- Feature is complete and what was delivered
- Any LOGs deferred to a future phase (with LOG reference numbers)
- Any observations about the spec/plan that should be captured in a retro
- Next step: `/sparc-audit` to verify doc-code consistency, or `/sparc-retro` if this was a full phase
