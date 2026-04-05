# Research: RuFlo Agent Benchmark Experiment

**Feature**: ruflo-benchmark
**Date**: 2026-04-05
**Branch**: 001-agent-benchmark

---

## 1. hooks_model-route — Routing Infrastructure

**Source**: Live probe, 2026-04-05

**Implementation**: `tiny-dancer-neural` — local neural classifier, not a cloud call.
**Latency**: 1.5ms inference time.
**Output fields**: `model`, `confidence`, `uncertainty`, `complexity`, `reasoning`,
`alternatives[]`, `inferenceTimeUs`, `costMultiplier`.

**Probe result on spec-review task**:
```
task: "Analyze a feature specification for missing user personas and auth gaps in a REST API"
model: opus | complexity: 0.38 | confidence: 0.57 | uncertainty: 0.53
alternatives: sonnet (0.76), haiku (0.24)
```

**Notable findings**:
- Confidence 57%, uncertainty 53% — the router is not crisp at 38% complexity; this is
  a borderline zone. Sonnet was the highest-scoring alternative (0.76) but the router
  chose opus. With `preferCost: true` set, it still chose opus.
- Keyword `analyze` triggered "High-complexity indicators" despite moderate overall complexity.
  The reasoning string reveals the classification basis — useful for Phase 3 accuracy analysis.
- `hooks_model-stats` tracks aggregate distribution and circuit breaker state, available
  for inclusion in run reports.

**Implication for Phase 1**: The router's recommendation and the "correct" routing choice
may diverge. Phase 1 should record both the recommendation and the confidence score, not
just treat the recommendation as ground truth.

**Implication for Phase 3**: At 38% complexity with 57% confidence, the router is in an
uncertain zone for moderate reasoning tasks. DEL-1/DEL-2 (structural pattern matching)
should score well below 0.4; ARCH-3 (multi-step inference) should score above 0.5.
FALSE-3 (requires reading a notes section) is a deliberate trap — low confidence is expected.

---

## 2. AgentDB (memory_store / memory_retrieve / memory_search) — Memory Layer

**Source**: Live observation, 2026-04-05

**Backend**: sql.js + HNSW (384-dimension embeddings).
**Store time**: ~90ms per entry.
**Retrieval**: by exact key within namespace, or by semantic HNSW search.
**Namespace granularity**: key is unique per namespace; there is no sub-namespace.
  Per-agent storage requires distinct keys (e.g., `phase1-run1-security-reviewer-findings`).

**OQ-04 resolution**: Per-key-per-namespace is sufficient for Phase 2. Each Phase A agent
gets its own key. Run 2 agents retrieve by key before generating new findings.

**Implication for Phase 2**: Agent prompts for run 2 must include the retrieved prior
findings as context ("In a prior run on this same fixture, you found: [retrieved value].
Review the fixture again and indicate which prior findings you still endorse, which you
revise, and any new findings."). The token delta between run 1 output and run 2 output
is the memory delta signal.

**Risk**: If run 2 agents simply re-state prior findings without new reasoning, output
token count may drop (good for the metric) but detection quality could degrade. FR-009
(flag diverging catch rates) exists to catch this.

---

## 3. Token Counting — No Direct API

**Source**: Schema inspection of all available RuFlo MCP tools.

No RuFlo tool exposes Claude API token usage counts. `hooks_post-task` parameters are
`taskId, agent, quality, success, task` — no token field. No MCP tool returns
`input_tokens` or `output_tokens` from the underlying Claude API call.

**Options considered**:
1. **Character-count proxy**: measure input prompt length + output text length in characters;
   divide by ~4 for a token estimate. Consistent within a single run; sufficient for
   routing-on vs routing-off comparison.
2. **Word-count proxy**: less accurate, same limitations.
3. **External instrumentation**: intercept Claude API calls at the network layer.
   Not feasible within the Claude Code command environment.
4. **Defer metric entirely**: report only catch-rate and routing decisions; drop
   tokens-per-caught-issue. Loses the primary efficiency signal.

**Decision**: Character-count proxy (option 1). See ADR_007.

**Known limitation**: Character-count estimates are not comparable to Claude-Root runs
(which also had no token counts). The within-experiment comparison (routing-on vs off)
is valid; cross-experiment absolute comparisons are not.

---

## 4. Scoring Mechanism

**Source**: Claude-Root ADR-006 review; probe results.

Command-embedded scoring is the only viable architecture. Post-processing (reading an
existing output file and scoring it separately) cannot satisfy the requirement to tag
Phase A findings by agent before Phase B/C, and requires coordination between command
output format and a separate scorer's expectations.

Claude-Root's ADR-006 reached the same conclusion for the same reasons. The RuFlo
version adds routing-decision tagging alongside agent-name tagging — same pattern,
one additional field.

---

## 5. WASM Agents — Not Zero-LLM

**Source**: wasm_agent_create schema inspection + probe.

`wasm_agent_create` has a `model` parameter defaulting to `anthropic:claude-sonnet-4-20250514`.
WASM agents provide filesystem sandboxing (virtual FS, no OS access) and optionally a
gallery template (coder/researcher/tester/reviewer/security/swarm). They still invoke Claude.

The "Tier 1 / $0 / Skip LLM" description in CLAUDE.md is either aspirational or refers
to a future capability not yet exposed via MCP tools. Phase 3's original design (zero-LLM
pre-screener for mechanical issues) cannot be implemented as specified.

**Redesign**: Phase 3 uses `hooks_model-route` to classify each task-gate planted issue
description by complexity. This tests whether the router's complexity model aligns with
the known reasoning demand of each issue type — a tractable and independently valuable question.

---

## 6. Panel Composition — STANDARD

**Source**: Claude-Root benchmark precedent; spec A-06.

STANDARD panel: security-reviewer + systems-architect + devils-advocate.
- security-reviewer: catches auth gaps, IDOR vectors, rate-limit misconfigurations
- systems-architect: catches schema decisions, undocumented dependencies, phase ordering
- devils-advocate: challenges consensus, raises false positives, cross-examines Phase A

At spec gate: security-reviewer and systems-architect are both Phase A; devils-advocate
is Phase B. Note: Claude-Root STANDARD spec run used product-strategist + devils-advocate
(no security-reviewer or systems-architect) — their STANDARD panel composition differs.

**Implication**: The RuFlo STANDARD panel is different from Claude-Root's. Catch-rate
comparisons must note the panel composition difference; SEC-1 (expected: security-reviewer)
should be Caught by RuFlo STANDARD but was Missed by Claude-Root STANDARD.

---

## 7. Fixture Stability

**Source**: Claude-Root repo, branch `000-review-benchmark`, commit history check.

Fixtures are in a separate repo on a named feature branch. They were created for the
April 2026 calibration runs and have not been modified since. Reuse is safe.
The benchmark key lists 4 spec-gate issues (PROD-1, PROD-2, SEC-1, FALSE-1) and
4 task-gate issues (DEL-1, DEL-2, ARCH-3, FALSE-3).
