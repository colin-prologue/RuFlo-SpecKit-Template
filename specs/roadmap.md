# RuFlo SpecKit — Project Roadmap

**Last updated**: 2026-04-05
**Maintained by**: Benchmark maintainer
**Update trigger**: After each retro or major phase completion

---

## Active Experiments

| # | Feature | Status | Priority | Notes |
|---|---|---|---|---|
| 001 | Agent Benchmark (routing + memory + decomposed framing) | **Complete** | — | All 3 phases + follow-on run; merged to main 2026-04-05 |

---

## Next Experiments (Prioritized)

### 002 — Summarized Warm Injection (Phase 2 Optimization)

**Hypothesis**: Injecting a 3–5 sentence summary of prior findings instead of full text preserves the PROD-2 warm catch while reducing injection input overhead ~60–70%.

**Why now**: LOG_010 identified injection overhead as the dominant cost driver in Phase 2 warm runs. This is a direct efficiency optimization with a clear test: does warm-summarized still catch PROD-2 partial?

**Design**: Phase 2 warm variant — same fixture, same agents, same AgentDB keys, but inject summarized prior findings (~200–300 chars per agent) instead of full text (~2,800–3,400 chars per agent).

**Success criteria**: PROD-2 partial catch maintained; input tokens reduced ≥ 40% vs. full-injection warm run.

**Blocked by**: Nothing. Ready to run.

---

### 003 — Correctness-Framed Haiku Structural Check for PROD-2

**Hypothesis**: Reframing the P1/P2 structural task as a binary correctness check ("Is email the primary channel for web users without the mobile app? If yes, does P2 assignment reflect that?") catches PROD-2 at haiku, closing the SC-D gap from experiment 001 follow-on.

**Why now**: The follow-on showed haiku caught SEC-1 equivalently to sonnet for a binary presence check. PROD-2 was missed because the task asked "is rationale present?" not "is rationale correct?" A correctness-framed binary question may be within haiku's capability.

**Design**: 2 haiku tasks, spec fixture, no panel — pure structural check. Score against PROD-2 benchmark key criteria.

**Success criteria**: PROD-2 scored Caught or Caught (partial); haiku duration < 15 seconds; output correct.

**Blocked by**: Nothing. Low-cost, fast to run.

---

### 004 — Price-Per-Run Metric (ADR_007 Extension)

**Hypothesis**: Adding a tier-aware pricing table to ADR_007 changes the economics interpretation of decomposed-framing experiments — haiku tasks are cheaper than token counts suggest.

**Why now**: LOG_011. The char-count proxy misleads on cross-tier experiments. Need a pricing calculation before 003 or any future decomposed-framing run to correctly evaluate cost vs. quality trade-offs.

**Design**: Update ADR_007 with a pricing table (verify current Anthropic rates at run time). Add price-per-run calculation to the benchmark-run command.

**Success criteria**: Next decomposed-framing run report includes both token count and estimated cost per agent.

**Blocked by**: Nothing. Code change to benchmark-run.md.

---

### 005 — Plan Gate Benchmark (Deferred)

**Status**: Deferred — out of scope for experiment 001 per spec.

**Why deferred**: Adding the plan gate increases fixture complexity and run count before the spec gate dynamics are fully understood. Complete experiments 002–004 first.

**Revisit trigger**: After summarized injection (002) and correctness-check haiku (003) establish the efficiency baseline for spec gate runs.

---

### 006 — WASM Zero-LLM Pre-Pass (Cancelled pending capability)

**Status**: Cancelled — WASM agents invoke Claude Sonnet (LOG_009, ADR_006).

**Revisit trigger**: RuFlo adds a zero-LLM execution mode for WASM agents (e.g., `model: null` or `model: "wasm-only"` parameter). Until then, any "WASM pre-screening" feature is architecturally blocked.

---

## Validated Patterns (Carry Forward)

| Pattern | Source | Apply to |
|---|---|---|
| ADR_008: Use alternatives ranking when confidence < 0.60 | Experiment 001 | Every project using `hooks_model-route` |
| Phase 3 first ordering: run router classification before full panel | Experiment 001 | Any multi-phase benchmark |
| Consolidation directive: "assess whether priority assignments reflect user reach" | Experiment 001 | Any synthesis/review agent prompt |
| Contamination check before scoring | Claude-Root + Experiment 001 | Every benchmark run |
| Quality-first framing for warm memory evaluation | Experiment 001 | Any AgentDB warm-up experiment |

---

## Open LOGs Affecting Roadmap

| LOG | Topic | Blocks |
|---|---|---|
| LOG_002 | Rigor assumed STANDARD without constitution.md | Constitution should run before experiment 002 |
| LOG_009 | Router confidence floor not improvable via framing | Routing experiments must use alternatives ranking, not confidence threshold |
| LOG_010 | Warm memory = quality lever, not efficiency lever | Experiment 002 framing and success criteria |
| LOG_011 | Char-count proxy insufficient for cross-tier | Experiment 003 and 004 metrics |
