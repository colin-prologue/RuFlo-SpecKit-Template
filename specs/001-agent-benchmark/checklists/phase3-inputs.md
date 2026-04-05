# Phase 3: Router Classification Input Descriptions

These are the task descriptions passed to hooks_model-route — one per issue.
Written to match what a pre-screener would receive: concise task description only,
not the full fixture text. Do NOT contain planted issue IDs verbatim.

---

## DEL-1 Input

```
Review a task list and verify that for each user story, test tasks appear before
the implementation tasks they cover. Check that each test task has a lower task ID
than its corresponding implementation task. Flag any story where implementation
precedes its test.
```

**Reasoning demand**: structural — compare task ID numbers; no inference about
business logic or cross-system behavior required.

---

## DEL-2 Input

```
Review a list of tasks marked as parallel-safe. For each pair of parallel tasks,
check whether they write to the same file. Flag any pair of parallel tasks that
would produce a write conflict on the same file path.
```

**Reasoning demand**: structural — pattern match task descriptions for file path overlap;
no inference about dependencies or execution ordering required.

---

## ARCH-3 Input

```
Review an implementation task list organized into phases. Identify any tasks in
later phases that depend on tasks from earlier phases where the dependency is not
explicitly documented in a task's dependency field. Trace the full dependency chain
and describe any hidden cross-phase ordering constraints that could cause failures
if phases are executed independently.
```

**Reasoning demand**: reasoning — must trace a multi-hop dependency chain (T009 → T011
→ T015/T016) across phase boundaries; requires reading task content and inferring
implicit dependencies, not just checking explicit fields.

---

## FALSE-3 Input

```
Review a task list and check whether each implementation task has a corresponding
test task. Flag any implementation task that appears to lack test coverage. Consider
all available test tasks and integration tests listed in the task list and in any
accompanying notes before flagging.
```

**Reasoning demand**: reasoning — requires reading the notes section at the bottom of
the task list to understand that T017 (full test suite) and T012 (integration tests)
provide coverage; a surface-level check will raise a false positive.
