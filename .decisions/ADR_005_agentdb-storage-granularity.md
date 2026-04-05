# ADR_005: AgentDB Storage Granularity for Phase 2

**Status:** Accepted
**Date:** 2026-04-05
**Deciders:** Benchmark maintainer
**Related spec:** specs/ruflo-benchmark-spec.md — US-002, FR-007
**Related LOGs:** none (OQ-04 resolved)

---

## Context

Phase 2 stores Phase A findings after run 1 (cold) and retrieves them at the start of
run 2 (warm) so agents can reference prior findings before generating new ones. AgentDB
uses a key-per-namespace model; there is no sub-namespace. Two storage strategies are
possible: (A) one key per agent (each agent's findings stored and retrieved separately),
or (B) one key for all Phase A findings combined.

OQ-04 from the spec asked whether AgentDB supports per-agent granularity within a
namespace — it does, via distinct keys.

## Decision

**We will store each Phase A agent's findings under a distinct key within namespace
`benchmark/spec-fixture` because per-agent retrieval allows each agent in run 2 to
receive only its own prior findings, preserving Phase A independence and preventing
cross-agent contamination of the warm-up context.**

## Rationale

If all three agents' findings are stored under a single key, each agent in run 2 receives
every other agent's prior findings as context — effectively reading Phase B/C material
before Phase A runs. This would contaminate the warm-up signal by introducing cross-agent
information that Phase A agents should not have. Per-agent keys isolate each agent's warm-up
context to its own prior findings only, matching the independence requirement of Phase A.

Key naming convention: `{phase}-{run}-{agent-name}-findings` (e.g.,
`phase2-run1-security-reviewer-findings`) within namespace `benchmark/spec-fixture`.

## Alternatives Considered

| Option | Why rejected |
|---|---|
| Single key for all Phase A findings | Agents in run 2 receive other agents' prior findings; contaminates Phase A independence |
| Separate namespaces per agent | Unnecessary complexity; key isolation within one namespace is sufficient |
| Store full Phase A + Phase B/C output | Exceeds warm-up scope; run 2 Phase A agents should not see synthesis output |

## Consequences

**Becomes easier:**
- Phase A independence preserved in run 2
- Memory delta is measurable per agent (not just aggregate)
- Easy to inspect stored findings per agent for debugging

**Becomes harder:**
- Three store calls after run 1 (one per agent) instead of one
- Three retrieve calls at the start of run 2 (one per agent)

**Constraints introduced:**
- Run 2 agent prompts must include only the retrieved findings for that specific agent
- Benchmark key must never be stored in AgentDB (contamination risk if retrieved during run 2)

## Validation

Validated when run 2 agents demonstrably reference prior findings in their output
(e.g., "In a prior run I found X; I confirm / revise this finding") and the memory
delta table shows per-agent token count comparisons.

## Amendment History

| Date | Change | Reason |
|---|---|---|
| 2026-04-05 | Created | Resolves OQ-04 |
