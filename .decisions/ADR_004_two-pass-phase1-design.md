# ADR_004: Two-Pass Design for Phase 1 Routing Comparison

**Status:** Accepted
**Date:** 2026-04-05
**Deciders:** Benchmark maintainer
**Related spec:** specs/ruflo-benchmark-spec.md — US-001, FR-010, SC-001
**Related LOGs:** LOG_002 (rigor assumption)

---

## Context

Phase 1 must compare tokens-per-caught-issue with model routing enabled vs. disabled.
The original spec assumed a Claude-Root STANDARD run file would provide the routing-off
baseline. Probe confirmed: no Claude-Root run file contains token counts. A new baseline
must be established within RuFlo itself.

Three options: (A) two-pass within a single benchmark run (routing-off then routing-on),
(B) single-pass with routing-on only and no comparison, (C) defer Phase 1 until a
routing-off run is completed in a separate session.

## Decision

**We will run two sequential passes on the spec fixture in Phase 1 — pass A with
routing disabled (all agents default to Sonnet) and pass B with routing enabled
(each agent's model tier determined by hooks_model-route) — because this produces
a within-experiment controlled comparison using identical fixture, panel, and scorer.**

## Rationale

Option B (single pass, no comparison) answers no efficiency question — it produces
routing decisions and catch rates but has no baseline to compare against. Option C
(separate session) introduces session-state variance: AgentDB may have accumulated
entries between sessions, context differs, and the comparison is no longer controlled.
Two-pass within the same command invocation ensures the fixture, panel composition,
scoring logic, and session state are identical across both passes.

The cost is one additional Sonnet-tier panel run (pass A). This is the minimum cost
to answer the primary efficiency question.

## Alternatives Considered

| Option | Why rejected |
|---|---|
| Use Claude-Root run as baseline | No token counts in any Claude-Root run file (confirmed by inspection) |
| Single pass, routing-on only | Produces no efficiency comparison — SC-001 cannot be satisfied |
| Separate session for pass A | Introduces uncontrolled variance between passes |

## Consequences

**Becomes easier:**
- Controlled within-experiment comparison; fixture and panel held constant
- Both passes scored against same benchmark key; catch-rate delta also observable

**Becomes harder:**
- Phase 1 consumes ~2× the tokens of a single panel run
- Pass A and pass B must be clearly labeled in the run report to prevent confusion

**Constraints introduced:**
- Pass A must complete before pass B; pass B routing decisions may be informed
  by the routing router's behavior, not by pass A findings (no cross-contamination)
- Run report naming: `YYYY-MM-DD-spec-phase1-routing-off.md` and
  `YYYY-MM-DD-spec-phase1-routing-on.md`

## Validation

Phase 1 succeeds when both run reports exist and the tokens-per-caught-issue comparison
row is populated. If routing-on pass catches fewer issues than routing-off, that is a
finding (not a failure) and must be reported, not suppressed.

## Amendment History

| Date | Change | Reason |
|---|---|---|
| 2026-04-05 | Created | Forced by absence of token counts in Claude-Root baseline |
