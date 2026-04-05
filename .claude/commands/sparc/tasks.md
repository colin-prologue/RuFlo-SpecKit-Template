# SPARC Tasks — User-Story-Organized Task Generation

You are generating implementation tasks from a completed plan. Tasks are organized by user story — not by technical layer — so each story can be developed, tested, and deployed independently.

## Prerequisites
- Read `constitution.md` for rigor level and TDD requirements.
- Read `specs/[feature]-spec.md` — user stories drive the task structure.
- Read `specs/[feature]-plan.md` — architecture and technology decisions drive the task content.
- If either file is missing, stop and tell the user which to create first.

---

## Task Organization Rules

1. **One task list section per user story.** Tasks for US-001 are complete before tasks for US-002 begin (unless marked `[P]`).
2. **TDD order**: For every feature task, the failing test task MUST precede the implementation task. Never reverse this.
3. **`[P]` marker** means this task can run in parallel with other `[P]` tasks in the same story.
4. **`[USN]` tag** links each task to its user story for traceability.
5. **Independent testability**: Before closing a story's tasks, verify the four criteria below.

---

## Task Format

Each task follows this format:

```
- [ ] [P] [US-001] TASK-NNN: [verb phrase describing the work]
  - Acceptance: [how to verify this task is done]
  - Depends on: [TASK-NNN or "none"]
  - Notes: [ADR references, gotchas, or constraints]
```

---

## Task Generation Process

For each user story in the spec (in P1 → P2 → P3 order):

### Step 1 — Story preamble
```
## Story US-00N: [title from spec]
Priority: P[1/2/3]
Independent testability: [confirmed / at-risk — reason]
```

### Step 2 — Setup tasks (shared infrastructure, run once before story tasks)
Only generate these if they don't already exist from a prior story:
- Environment/dependency setup
- Database migrations or schema changes
- Shared test fixtures or factories

### Step 3 — For each functional requirement tied to this story:

**Test task first (always):**
```
- [ ] [US-00N] TASK-NNN: Write failing tests for [requirement FR-NNN]
  - Acceptance: Tests exist, describe the expected behavior, and currently fail
  - Depends on: [setup task or "none"]
  - Notes: Test file: tests/[path]. Cover: [list acceptance scenarios from spec]
```

**Implementation task second:**
```
- [ ] [US-00N] TASK-NNN: Implement [requirement FR-NNN]
  - Acceptance: All tests written in prior task now pass. No new test failures.
  - Depends on: TASK-NNN (test task)
  - Notes: [ADR reference if relevant], [architectural notes from plan]
```

### Step 4 — Integration task (end of each story)
```
- [ ] [US-00N] TASK-NNN: Integration verification for Story US-00N
  - Acceptance: All acceptance scenarios from spec pass end-to-end. Story meets all 4 independent testability criteria.
  - Depends on: [all implementation tasks for this story]
```

### Step 5 — Independent testability check
Before moving to the next story, verify:
- [ ] Story US-00N can be deployed without Story US-00(N+1) being complete
- [ ] Story US-00N delivers value to users independently
- [ ] No hard runtime dependency on sibling stories
- [ ] All acceptance scenarios pass in isolation

If any criterion fails, flag it and propose a task restructuring.

---

## Output Format

Produce `specs/[feature]-tasks.md`:

```markdown
# Implementation Tasks: [Feature Name]
**Spec:** specs/[feature]-spec.md
**Plan:** specs/[feature]-plan.md
**Generated:** [date]
**Total tasks:** [N]
**Estimated parallel opportunities:** [N tasks marked [P]]

---

## Shared Setup
- [ ] TASK-001: [setup task]
  ...

---

## Story US-001: [title]
Priority: P1
Independent testability: confirmed

[tasks...]

---

## Story US-002: [title]
Priority: P1
Independent testability: confirmed

[tasks...]

---

## Cross-Cutting Tasks
[Tasks not tied to a specific story: docs update, changelog, ADR finalization, etc.]

---

## Definition of Done
- [ ] All tasks completed
- [ ] All tests passing
- [ ] Build succeeds
- [ ] All ADRs finalized (no "Draft" status remaining)
- [ ] All LOGs resolved or explicitly deferred with a new LOG entry
- [ ] `constitution.md` still accurate (update if project context changed)
```

---

## After Tasks are Generated

Tell the user:
- Total task count and parallel opportunity count
- Estimated effort (rough, based on task count and complexity signals from the plan)
- Any stories with independent testability concerns
- Any ADRs still in Draft status that need to be finalized before coding begins
- Next step: run `/sparc-review` on the task list (FULL/STANDARD rigor) or `/sparc-implement` to begin
