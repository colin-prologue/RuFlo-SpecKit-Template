# ADR_003: Command-Embedded Scoring Architecture

**Status:** Accepted
**Date:** 2026-04-05
**Deciders:** Benchmark maintainer
**Related spec:** specs/ruflo-benchmark-spec.md — FR-004, FR-006
**Related LOGs:** none

---

## Context

The benchmark must score Phase A agent findings against a known benchmark key after
each run. Two architectures are possible: (1) a post-processor reads saved output from
a standard review run and scores it separately, or (2) the benchmark command runs the
review and scoring in a single workflow. The choice affects whether agent-name tagging
and routing-decision tagging can be captured before findings reach Phase B/C.

This mirrors Claude-Root's ADR-006, which resolved the same question for the same reasons.
The RuFlo version adds one additional tagging requirement: model-tier routing decisions
alongside agent-name tags.

## Decision

**We will use command-embedded scoring because post-processing cannot satisfy the tagging
requirements and would require fragile coordination between command output format and a
separate scoring step.**

## Rationale

Post-processing requires the Phase A output to be saved in a format the scorer can parse,
with agent names and routing decisions embedded — but that format is only guaranteed if the
command that produces the output is designed to embed them. The two approaches converge:
a well-designed command embeds tags, and a post-processor reads them. The command-embedded
approach skips the file-coordination step and keeps scoring logic colocated with the
tagging instructions that make scoring possible.

The routing-decision tagging requirement (new in RuFlo vs. Claude-Root) strengthens this
choice: `hooks_model-route` must be called before each Phase A agent invocation, and its
output must be associated with that agent's findings. This association is only reliable
within the same command execution that spawns the agent.

## Alternatives Considered

| Option | Why rejected |
|---|---|
| Post-processing | Cannot reliably tag Phase A findings with agent names and routing decisions before Phase B without also modifying the review command — at which point you have a command-embedded approach anyway |
| LLM-based scoring | Introduces non-determinism into the measurement instrument; ruled out by FR-004 |

## Consequences

**Becomes easier:**
- Agent-name and routing-tier tags are available in a single pass
- Contamination check can run immediately after Phase A, before Phase B

**Becomes harder:**
- The benchmark command is longer and more complex than a standard review command
- Behavioral difference from unmodified review (additive tags only) is an acknowledged limitation

**Constraints introduced:**
- All scoring logic must live inside the benchmark command prompt
- Benchmark command must not be used as a standard review command (tags alter agent behavior marginally)

## Validation

If Phase A findings arrive at the scoring pass without agent-name or routing-tier tags,
the command design has failed. Validated when every finding row in the run report carries
both tags and scoring completes without "routing unverified" or "agent unknown" flags.

## Amendment History

| Date | Change | Reason |
|---|---|---|
| 2026-04-05 | Created | Initial decision |
