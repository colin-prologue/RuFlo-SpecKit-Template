---
name: sparc-tasks
description: User-story-organized task generation — [USN] story tags, [P] parallel markers, TDD order enforced (failing test before implementation), independent testability verification per story
---

# SPARC Tasks

## Role
Generate implementation tasks organized by user story, not technical layer. TDD order is enforced: failing test task always precedes implementation task.

## Memory
```javascript
mcp__claude-flow__memory_retrieve { key: "governance-rigor", namespace: "governance" }
mcp__claude-flow__memory_retrieve { key: "spec-[feature]-summary", namespace: "specs" }
mcp__claude-flow__memory_retrieve { key: "plan-[feature]-summary", namespace: "decisions" }
```

Requires `specs/[feature]-spec.md` and `specs/[feature]-plan.md`. Stop if either missing.

## Task Format
```
- [ ] [P] [US-001] TASK-NNN: [verb phrase]
  - Acceptance: [how to verify done]
  - Depends on: [TASK-NNN or "none"]
  - Notes: [ADR refs, constraints]
```

`[P]` = can run parallel with other `[P]` tasks in same story. `[USN]` links to story.

## Generation Process (per story, P1 → P2 → P3 order)

For each story:
1. Story preamble with independent testability status
2. Shared setup tasks (only if not already created by prior story)
3. For each FR tied to this story: **test task first** (write failing test, confirm it fails for the right reason) then **implementation task** (minimum code to pass the test)
4. Integration verification task (all acceptance scenarios pass end-to-end)
5. Verify 4 independent testability criteria before next story. Flag and restructure if any fail.

## Output File
Write `specs/[feature]-tasks.md` with: total task count · parallel opportunity count · shared setup section · story sections · cross-cutting tasks (docs, changelog, ADR finalization) · Definition of Done checklist.

## Memory Store
```javascript
mcp__claude-flow__memory_store {
  key: "tasks-[feature]-summary",
  value: "task count, parallel opportunities, stories with testability concerns",
  namespace: "specs"
}
```

Close: task count + parallel opportunities · any stories with independent testability concerns · ADRs still in Draft · next: `/sparc-review` (FULL/STANDARD) or `/sparc-implement`.
