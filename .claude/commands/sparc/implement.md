---
name: sparc-implement
description: TDD-ordered task execution with extensions.yml pre-implementation gates, baseline verification, Red-Green-Refactor discipline, story-level independent testability check
---

# SPARC Implement

## Role
Execute tasks from `specs/[feature]-tasks.md` in strict TDD order. Never write implementation before the failing test exists.

## Memory
```javascript
mcp__claude-flow__memory_retrieve { key: "governance-rigor", namespace: "governance" }
mcp__claude-flow__memory_retrieve { key: "tasks-[feature]-summary", namespace: "specs" }
mcp__claude-flow__memory_retrieve { key: "plan-[feature]-summary", namespace: "decisions" }
```

Requires `specs/[feature]-tasks.md`. Stop and run `/sparc-tasks` first if missing.

## Pre-flight

**1 — Extensions check:** If `extensions.yml` exists (project root or `config/`), run all `mandatory` hooks. Block if any fail — ask user how to proceed. Run `optional` hooks, warn only if they fail.

**2 — Baseline check:** All ADRs finalized · blocking LOGs resolved · build passes · test suite passes with no pre-existing failures. Show any failures to user and ask how to proceed before starting.

## Task Execution

For each task in order:
- Mark in progress `[-]` before starting
- **Test tasks:** write test → run it → confirm it fails for the right reason (not a syntax error)
- **Implementation tasks:** write minimum code to pass the tests only — nothing beyond what tests require
- After each task: run full test suite, fix any regressions before next task
- Mark complete `[x]` when acceptance criteria met
- If a task reveals a spec/plan gap: create a LOG entry, flag to user, await direction

## Story Completion Check
After last task in each story, verify 4 independent testability criteria. Report pass/fail per criterion.

## Completion
Run Definition of Done checklist from `specs/[feature]-tasks.md`. Confirm: build passes · all tests pass · all ADRs finalized · blocking LOGs resolved.

## Memory Store
```javascript
mcp__claude-flow__memory_store {
  key: "impl-[feature]-complete",
  value: "stories delivered, deferred LOGs, observations for retro",
  namespace: "specs"
}
```

Close: what was delivered · deferred LOGs with references · retro observations · next: `/sparc-audit`.
