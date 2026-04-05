---
name: sparc-brainstorm
description: Six-phase structured ideation — prior art scan gate, four-agent divergent ideation, MoSCoW prioritization, dependency mapping, roadmap generation
---

# SPARC Brainstorm

## Role
Structured ideation before specification. Prior art scan is a hard gate — no ideas generated until it completes.

## Memory
```javascript
mcp__claude-flow__memory_retrieve { key: "governance-rigor", namespace: "governance" }
mcp__claude-flow__memory_search { pattern: "brainstorm", namespace: "specs", limit: 3 }
```

Ask: "What problem or feature are we brainstorming?" if not already stated.

## Six Phases

**1 — Problem Definition** Write `specs/brainstorm-problem.md`: problem statement · root cause · scope boundaries (in/out) · success definition · constraints.

**2 — Prior Art Scan (HARD GATE)** Search for existing tools/libraries, prior attempts in this codebase, industry patterns, known failures. Write `specs/brainstorm-priorart.md`: what exists · gaps remaining · tried-and-failed · compatibility constraints. All ideation agents receive this summary. Do not start Phase 3 until complete.

**3 — Divergent Ideation** Four agents, each gets the problem statement + prior art summary. Instruction: generate only, no evaluation yet.
- **Visionary** — 3-5 ambitious ideas, 2-3 years ahead, ignore current constraints
- **User Advocate** — 3-5 ideas from user workflow backwards
- **Technologist** — 3-5 practical ideas using existing stack/patterns
- **Provocateur** — 3-5 contrarian ideas, challenge the problem framing itself

Collect all to `specs/brainstorm-ideas.md` organized by agent.

**4 — Convergent Prioritization** Apply MoSCoW + effort (1-5) to each idea. Priority score = (MoSCoW weight × 3) / effort (Must=4, Should=3, Could=2). Top 3-5 across Must+Should become roadmap candidates.

**5 — Dependency Mapping** For top candidates: prerequisites · enables · conflicts · natural build order.

**6 — Roadmap** Write/update `specs/roadmap.md`: phases with feature name, effort score, assumptions, success criteria. Parking lot and killed ideas sections. Update `specs/brainstorm-notes.md` with session summary.

## Memory Store
```javascript
mcp__claude-flow__memory_store {
  key: "brainstorm-[feature]-summary",
  value: "top candidates + key assumptions",
  namespace: "specs"
}
```

Close: top 3 ideas + rationale · Provocateur insights worth discussing · highest-risk assumptions · next: `/sparc-specify`.
