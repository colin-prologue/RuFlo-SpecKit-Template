# ADR_007: Character-Count Proxy for Token Measurement

**Status:** Accepted
**Date:** 2026-04-05
**Deciders:** Benchmark maintainer
**Related spec:** specs/ruflo-benchmark-spec.md — FR-002, FR-006, SC-001, SC-005
**Related LOGs:** none

---

## Context

The spec requires per-agent token counts (input + output) to calculate
tokens-per-caught-issue and memory delta. No RuFlo MCP tool exposes Claude API
token usage. `hooks_post-task` has no token field. Network-level interception of
Claude API calls is not feasible within the Claude Code command environment.

Four options were considered in research.md. The choice must produce a metric that
is consistent within the experiment (routing-on vs routing-off comparison is valid)
even if it is not comparable to external benchmarks.

## Decision

**We will measure input and output text length in characters and divide by 4 as a
token estimate (~4 characters per token for English text) because this is consistent
within a single experiment, requires no external tooling, and is sufficient to answer
the routing efficiency question.**

## Rationale

The primary comparison is routing-on vs. routing-off within Phase 1, using identical
fixtures and panel prompts. Character-count estimates have the same systematic bias
in both passes, so the ratio between them is valid. The memory delta comparison in
Phase 2 is also within-experiment. Cross-experiment comparisons (to Claude-Root or
to other tools) are explicitly not attempted in this experiment.

For input tokens: the benchmark command knows the exact prompt text sent to each
agent (fixture + system instructions + prior memory context). Character count of
that text is measurable and consistent. For output tokens: the agent's full response
text is the output; character count is measurable.

## Alternatives Considered

| Option | Why rejected |
|---|---|
| Exact token counts via Claude API | Not accessible within Claude Code command environment |
| Word-count proxy | Less accurate than character-count; ~1.3 words/token is more variable than ~4 chars/token |
| Drop token metric entirely | Loses SC-001 and SC-002; tokens-per-caught-issue is the primary efficiency signal |
| External instrumentation | Not feasible without modifying the Claude Code environment |

## Consequences

**Becomes easier:**
- Token proxy is measurable by any command that can count string length
- Consistent across all passes within this experiment

**Becomes harder:**
- Results cannot be stated in absolute tokens — must be stated as "estimated tokens"
  or "character units"
- Not directly comparable to Claude API billing or Claude-Root results

**Constraints introduced:**
- All run reports must label the metric as "estimated tokens (characters ÷ 4)"
- Comparisons across different model versions or different fixture texts are invalid
- The ~4 chars/token ratio is an approximation; actual ratio varies by content type

## Validation

Validated if Phase 1 routing-on pass shows a meaningfully different character-count
estimate from routing-off pass (i.e., routing to haiku-tier agents produces shorter
or differently-distributed output than Sonnet-only). If both passes produce identical
character counts, either routing had no effect or the proxy is insensitive — investigate.

## Amendment History

| Date | Change | Reason |
|---|---|---|
| 2026-04-05 | Created | No direct token API available in RuFlo MCP tools |
