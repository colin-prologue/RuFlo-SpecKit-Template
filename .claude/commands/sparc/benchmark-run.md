# /sparc-benchmark-run

Run a RuFlo agent benchmark experiment phase. Measures model routing efficiency,
AgentDB memory warm-up effect, and router classification accuracy against planted-issue
fixtures copied from Claude-Root.

**Usage**: `/sparc-benchmark-run [phase] [state]`
- `1 routing-off` — Phase 1: full STANDARD panel, all agents at Sonnet (no routing)
- `1 routing-on`  — Phase 1: full STANDARD panel, adjusted routing per ADR_008
- `2 cold`        — Phase 2: full STANDARD panel + AgentDB store after Phase A
- `2 warm`        — Phase 2: full STANDARD panel + AgentDB retrieve before Phase A
- `3 classification` — Phase 3: router classification probe only (no panel)

**ADRs**: ADR_003 (command-embedded scoring), ADR_004 (two-pass Phase 1),
           ADR_005 (AgentDB per-agent keys), ADR_006 (Phase 3 redesign),
           ADR_007 (character-count proxy), ADR_008 (adjusted routing strategy)

---

## Pre-Run Checks

Before every run:
1. Confirm `specs/001-agent-benchmark/fixture/spec.md` exists (do NOT load benchmark-key.md yet)
2. Confirm `specs/001-agent-benchmark/fixture/tasks.md` exists
3. Confirm `specs/001-agent-benchmark/benchmark-key.md` exists (will load ONLY during scoring pass)
4. Confirm claude-flow daemon is running: `npx @claude-flow/cli@latest daemon status`
5. Note today's date for run report filename

---

## Phase 1 — Routing-Off Pass

**Question**: What is the character-count proxy for tokens-per-caught-issue with all Sonnet agents?

### Step 1 — Load fixture
Read `specs/001-agent-benchmark/fixture/spec.md` into memory. Do NOT read benchmark-key.md.

### Step 2 — Call hooks_model-route for all Phase A agents (log only — do not act on recommendations)
For each agent below, call `mcp__claude-flow__hooks_model-route` with the task description.
Record model, confidence, complexity, uncertainty, and top alternative. This is for logging only — all agents will run at Sonnet in the routing-off pass.

- security-reviewer task: "Analyze a feature specification for authentication gaps, IDOR vulnerabilities, missing authorization requirements, and security design flaws at system boundaries"
- systems-architect task: "Analyze a feature specification for missing user personas, priority ordering issues, implicit assumptions, and gaps in scope definition"

### Step 3 — Spawn Phase A agents (both at Sonnet, in parallel)

Spawn the following two agents simultaneously using the Task tool. Set `model: "sonnet"` explicitly for both.

**security-reviewer** (model: sonnet):
```
You are a security reviewer analyzing a feature specification for a web application.
Your role is to identify authentication gaps, authorization flaws, IDOR attack vectors,
missing security requirements, and any security design issues.

Analyze the following feature specification. For each finding, output a row in this format:
[security-reviewer] [TIER: sonnet] SEVERITY: description of finding, referencing the
specific section of the spec where the issue exists.

Do not reference any benchmark key, issue IDs, or scoring criteria. Analyze the spec as
if you were reviewing it for the first time.

--- SPEC BEGINS ---
[INSERT FULL CONTENTS OF specs/001-agent-benchmark/fixture/spec.md HERE]
--- SPEC ENDS ---
```

**systems-architect** (model: sonnet):
```
You are a systems architect reviewing a feature specification for a web application.
Your role is to identify missing user personas, priority inversions, scope gaps,
implicit assumptions that should be explicit, and structural issues in the specification.

Analyze the following feature specification. For each finding, output a row in this format:
[systems-architect] [TIER: sonnet] SEVERITY: description of finding, referencing the
specific section of the spec where the issue exists.

Do not reference any benchmark key, issue IDs, or scoring criteria. Analyze the spec as
if you were reviewing it for the first time.

--- SPEC BEGINS ---
[INSERT FULL CONTENTS OF specs/001-agent-benchmark/fixture/spec.md HERE]
--- SPEC ENDS ---
```

Record the full output of each agent. Count input characters (fixture + prompt) and output characters for each agent separately.

### Step 4 — Spawn Phase B (devils-advocate) at Sonnet

**devils-advocate** (model: sonnet):
```
You are a devil's advocate reviewing the findings from a security reviewer and
systems architect. Your role is to challenge weak findings, escalate overlooked
issues, and identify any concerns the Phase A reviewers missed.

Phase A findings:
[INSERT ALL PHASE A FINDINGS HERE, with agent name tags intact]

The original feature specification:
[INSERT FULL CONTENTS OF specs/001-agent-benchmark/fixture/spec.md HERE]

Output your analysis in this format:
[devils-advocate] [TIER: sonnet] SEVERITY: finding description. Reference the
specific section of the spec.
```

### Step 5 — Synthesis (Phase C) at Sonnet

**synthesis-judge** (model: sonnet):
```
You are a synthesis judge. Consolidate the Phase A and Phase B findings into a
structured review report. Identify overlapping findings and give each a verdict:
"Redundant" or "Different angle — keep both".

Phase A + Phase B findings:
[INSERT ALL TAGGED FINDINGS HERE]

Output:
1. Executive Summary (2-3 sentences)
2. Critical & High Findings (consolidated)
3. Medium Findings
4. Overlap Clusters table: | Finding Topic | Agents | Verdict |
```

### Step 6 — Contamination Check

BEFORE loading benchmark-key.md, scan ALL Phase A findings (steps 3 output only) for
verbatim planted issue IDs: PROD-1, PROD-2, SEC-1, FALSE-1, ARCH-1, ARCH-2, SEC-2,
FALSE-2, DEL-1, DEL-2, ARCH-3, FALSE-3.

- Match full IDs only (e.g., "SEC-1" not "SEC")
- If any full ID found verbatim: output "CONTAMINATION DETECTED — run invalidated"
  Do NOT proceed to scoring. Prompt user to re-run with clean context.
- If no full IDs found: output "CONTAMINATION CHECK: CLEAN" and proceed.

### Step 7 — Scoring Pass (load benchmark-key.md NOW)

Read `specs/001-agent-benchmark/benchmark-key.md`. Apply scoring rules to Phase A findings only
(Phase B/C findings are synthesis, not primary detection):

For each spec-gate planted issue (PROD-1, PROD-2, SEC-1, FALSE-1):
- Caught: Phase A finding references correct spec section + core problem area
- Caught (partial): correct spec section, wrong framing or partial problem
- Missed: no Phase A finding addresses the planted issue
- False Positive (FALSE-*): raised as definitive HIGH/MEDIUM without hedging language

### Step 8 — Character Count + Metrics

Calculate for each Phase A agent:
- Input chars: count characters in (fixture text + system prompt sent to agent)
- Output chars: count characters in agent's full response
- Estimated tokens: (input chars + output chars) ÷ 4

Calculate:
- Total Phase A estimated tokens: sum across all agents
- Issues caught (full + partial): count from scoring table
- Tokens-per-caught-issue: total estimated tokens ÷ issues caught

### Step 9 — Save Run Report

Save to `specs/001-agent-benchmark/runs/YYYY-MM-DD-spec-phase1-routing-off.md`

Report sections:
1. Header (gate, phase, state, date, panel, contamination status)
2. Routing Recommendations Log (from step 2 — logged but not acted on)
3. Phase A Findings (tagged, full text)
4. Phase B Findings
5. Synthesis Summary
6. Overlap Clusters Table
7. Contamination Check Result
8. Miss Rate Table (PROD-1, PROD-2, SEC-1, FALSE-1 × Caught/Caught partial/Missed)
9. False Positive Table
10. Unique Contribution by Agent table
11. Character Count Table (per agent: input chars, output chars, estimated tokens)
12. Tokens-per-caught-issue

---

## Phase 1 — Routing-On Pass

**Identical to routing-off EXCEPT for Step 2 and Step 3.**

### Step 2 (modified) — Call hooks_model-route AND apply adjusted routing (ADR_008)

For each Phase A agent, call `mcp__claude-flow__hooks_model-route`. Then:
- If confidence >= 0.60: use the recommended model tier
- If confidence < 0.60: use the highest-scoring alternative where model ≠ "opus" and model ≠ "inherit"; if none scores > 0.20, use "sonnet"

Log per agent: raw recommendation, confidence, selected tier, selection reason
("recommendation accepted" or "adjusted to [tier] via alternatives ranking, confidence [X]")

### Step 3 (modified) — Spawn Phase A agents with selected model tiers

Same prompts as routing-off, but set `model` parameter to the selected tier per agent.
Update the [TIER: X] tag in each finding to reflect the actual tier used.

### Report additions (routing-on only)
Add a **Routing Decision Table** between the header and Phase A findings:
| Agent | Task Description | Raw Recommendation | Confidence | Selected Tier | Selection Reason |

Save to `specs/001-agent-benchmark/runs/YYYY-MM-DD-spec-phase1-routing-on.md`

Add a **Routing Efficiency Comparison** section at the end comparing:
- Routing-off tokens-per-caught-issue (from routing-off report)
- Routing-on tokens-per-caught-issue
- Delta and interpretation (per ADR_008: if both use sonnet, note routing adds overhead only)

---

## Phase 2 — Cold Pass

**Identical to Phase 1 routing-on EXCEPT:**

After Step 3 (Phase A complete), before Step 4 (Phase B):

### Step 3b — Store Phase A findings to AgentDB (ADR_005)

Call `mcp__claude-flow__memory_store` for each Phase A agent:
- security-reviewer: key = `phase2-run1-security-reviewer-findings`, namespace = `benchmark/spec-fixture`, value = full agent output text
- systems-architect: key = `phase2-run1-systems-architect-findings`, namespace = `benchmark/spec-fixture`, value = full agent output text

Log: store success, hasEmbedding, storedAt for each.

Do NOT store benchmark-key.md content or any scoring results.

Save to `specs/001-agent-benchmark/runs/YYYY-MM-DD-spec-phase2-cold.md`
Add AgentDB Store Confirmation section (3 store results).

---

## Phase 2 — Warm Pass

**Identical to Phase 2 cold EXCEPT for Step 2 (before spawning Phase A agents):**

### Step 2b — Retrieve prior findings from AgentDB

Call `mcp__claude-flow__memory_retrieve` for each Phase A agent:
- security-reviewer: key = `phase2-run1-security-reviewer-findings`, namespace = `benchmark/spec-fixture`
- systems-architect: key = `phase2-run1-systems-architect-findings`, namespace = `benchmark/spec-fixture`

If retrieval fails for an agent: proceed without prior context; note "AgentDB unavailable for [agent] — running cold" in report.

### Step 3 (modified) — Inject prior findings into Phase A agent prompts

Prepend to each agent's prompt (before the spec text):
```
In a prior run on this same feature specification, you found the following issues:
[INSERT RETRIEVED FINDINGS FOR THIS AGENT]

Review the specification again. For each prior finding: state whether you endorse it,
revise it, or retract it, and why. Then add any new findings you identify.
Output format: [agent-name] [TIER: X] SEVERITY: finding. Indicate (PRIOR-ENDORSED),
(PRIOR-REVISED: [what changed]), (PRIOR-RETRACTED: [reason]), or (NEW) for each finding.
```

### Report additions (warm only)
Add **Memory Delta Table** at the end:
| Agent | Run1 Output Chars | Run2 Output Chars | Delta | Delta % | Prior Endorsed | Prior Revised | New Findings |

Save to `specs/001-agent-benchmark/runs/YYYY-MM-DD-spec-phase2-warm.md`

---

## Phase 3 — Classification (already run — see runs/2026-04-05-task-phase3-classification.md)

This phase is complete. Results documented in the run report above.
If re-running: call `mcp__claude-flow__hooks_model-route` once per description in
`specs/001-agent-benchmark/checklists/phase3-inputs.md`. Score against
`specs/001-agent-benchmark/checklists/phase3-expected.md`.
