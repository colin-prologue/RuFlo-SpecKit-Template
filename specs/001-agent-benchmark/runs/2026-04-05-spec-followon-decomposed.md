# Follow-On Experiment: Decomposed Task Framing

**Gate**: spec | **State**: decomposed-task-framing
**Date**: 2026-04-05
**Panel**: security-reviewer (haiku×1, sonnet×1), systems-architect (haiku×1, sonnet×1), consolidation (sonnet)
**Contamination**: CLEAN
**Reference**: experiment-followon-log.md
**Baseline**: 2026-04-05-spec-phase1-routing-off.md (~3,950 Phase A est. tokens, 2/3 catch rate)

---

## Hypothesis

Decomposing review agent tasks into typed atomic descriptions (structural/enumeration/reasoning/judgment) will:
1. Increase router confidence above 0.70, enabling discriminating routing
2. Route structural and enumeration tasks to haiku without quality loss
3. Maintain or improve catch rate (≥ 2/3 scorable issues)

---

## Routing Classification Results (8 Decomposed Tasks)

| # | Type | Agent | Task Description | Raw Model | Confidence | Complexity | ADR_008 Tier |
|---|---|---|---|---|---|---|---|
| 1 | structural | sec-rev | Verify ownership enforcement on preference endpoint | sonnet | 0.523 | 0.236 | **haiku** |
| 2 | structural | sec-rev | Verify unsubscribe token security properties defined | opus | 0.567 | 0.336 | sonnet |
| 3 | reasoning | sec-rev | Explain IDOR attack given Auth service dependency | opus | 0.566 | 0.319 | sonnet |
| 4 | judgment | sec-rev | Evaluate audit logging deferral risk (OQ-1) | opus | 0.567 | 0.340 | sonnet |
| 5 | enumeration | sys-arch | List every user role in the spec | opus | 0.566 | 0.315 | sonnet |
| 6 | structural | sys-arch | Identify P1/P2 rationale in spec sections | sonnet | 0.514 | 0.241 | **haiku** |
| 7 | structural | sys-arch | Check Constraints vs. US2 consistency | opus | 0.566 | 0.299 | sonnet |
| 8 | reasoning | sys-arch | Explain partial rollout implementation problem | opus | 0.568 | 0.432 | sonnet |

**SC-A verdict (confidence > 0.70 for ≥ 6/8)**: **FAIL** — 0 of 8 tasks exceed 0.70 confidence. Range: 0.514–0.568.

**SC-B verdict (≥ 2 tasks route to haiku)**: **PASS via ADR_008** — Tasks 1 and 6 route to haiku because haiku is the top-scoring non-opus alternative (0.528 and 0.519 respectively). Routing is via alternatives ranking, not direct recommendation.

**Key routing observation**: Decomposed framing produced lower complexity scores for structural tasks (0.236, 0.241) vs. broad-framing Phase 1 (0.437–0.505). The complexity signal differentiates task types as hypothesized. However, the confidence floor (0.51–0.57) persists regardless of framing. The router's confidence output appears to have a floor near 0.50 that decomposed framing does not break through.

---

## Phase A Findings (Decomposed)

### security-reviewer — haiku (Task 1)

[security-reviewer] [TIER: haiku] [TASK: structural-ownership] SEVERITY: CRITICAL — Ownership enforcement requirement absent. The specification lists authentication (session token validation) in dependencies but contains no acceptance criteria requiring the API to verify the authenticated user owns the preference record being read or modified.

### security-reviewer — sonnet (Tasks 2, 3, 4)

[security-reviewer] [TIER: sonnet] [TASK: 2-structural] SEVERITY: HIGH — The spec contains no definition of security properties for the unsubscribe token (User Story 2). No expiry, no single-use enforcement, no cryptographic user/event-type binding. Token validation is delegated to the Comms team via the dependency table but security properties are unspecified; the implementing team has no normative requirement to enforce any of these.

[security-reviewer] [TIER: sonnet] [TASK: 3-reasoning] SEVERITY: CRITICAL — IDOR attack chain: authenticate as any user → call preference API with victim's user identifier → read or overwrite victim's CRITICAL_ALERT preferences. The spec defines no ownership-enforcement requirement — only a valid session is required. Reading preferences leaks behavioral data; writing preferences silently disables CRITICAL_ALERT notifications. The Auth service dependency covers only session validity, not ownership authorization.

[security-reviewer] [TIER: sonnet] [TASK: 4-judgment] SEVERITY: HIGH — Audit logging deferral (OQ-1) is not acceptable risk for CRITICAL_ALERT preferences. A malicious actor disabling another user's CRITICAL_ALERT preferences leaves no forensic trail. Changes propagate within 5 minutes (US2 AC) with no record of who made the change. OQ-1 cites GDPR as the rationale for logging — deferring it specifically for the highest-sensitivity preference channel undercuts the stated justification.

### systems-architect — haiku (Task 6)

[systems-architect] [TIER: haiku] [TASK: structural-priority] SEVERITY: INFO — P1/P2 rationale IS present. User Story 1 (P1) rationale: "unwanted push alerts are a leading driver of app uninstalls" — framed as user retention and highest-friction channel. User Story 2 (P2) rationale: "most users manage email through unsubscribe links rather than through the settings UI" — framed as interface preference. Both assignments have stated rationale; ordering basis is defined in the spec.

### systems-architect — sonnet (Tasks 5, 7, 8)

[systems-architect] [TIER: sonnet] [TASK: 5-enumeration] SEVERITY: LOW — Only one user role defined in the spec: "registered user" (User Stories 1 and 2). No admin, compliance officer, anonymous/unauthenticated user, or operator role is introduced anywhere — including User Stories, Acceptance Criteria, Constraints, Open Questions, or Dependencies. The absence of an admin/support role is not designated a deliberate non-goal.

[systems-architect] [TIER: sonnet] [TASK: 7-structural] SEVERITY: HIGH — Constraints section directly contradicts User Story 2. Constraint: "Existing notification delivery pipelines must not be modified — preference lookup is additive." US2 Acceptance Criteria requires an unsubscribe link embedded in each notification email that "disables all email notifications for that event type." Token generation, embedding in outgoing emails, and validation endpoint exposure are not purely additive operations — they require modifying how the email pipeline composes messages. The Dependencies table even lists "Unsubscribe link token validation" under the email delivery pipeline owner, confirming integration is expected. One of the two must be revised; the spec as written cannot be implemented consistently.

[systems-architect] [TIER: sonnet] [TASK: 8-reasoning] SEVERITY: MEDIUM — Partial rollout creates split-default state. When US1 (push) is live and US2 (email) is not yet deployed: CRITICAL_ALERT email defaults (from Event Types table) are unenforceable; users see a push preferences UI but no email preferences UI from the same profile page (creating an expectation gap); and the preference lookup hook is partially wired for push but not email, requiring a second integration pass when email is added. The spec defines no feature-flag boundary or partial rollout sequencing contract between US1 and US2.

---

## Consolidation Pass (Synthesis) — sonnet

### Compound Risk Findings

**CR-1: IDOR + Audit Gap** — CRITICAL (blocking)
IDOR (Task 3) and audit gap (Task 4) combine: attacker modifies victim's CRITICAL_ALERT preferences with no forensic trace, no authoritative record of prior state, and no ability to determine scope of tampering after the fact. The audit gap eliminates the only compensating control that could partially mitigate IDOR.

**CR-2: Token security properties undefined + pipeline constraint contradiction** — HIGH (blocking)
Unsubscribe token properties unspecified (Task 2) + pipeline must-not-be-modified constraint (Task 7). If constraint is interpreted strictly, the mechanism to deliver signed tokens cannot be built regardless of what security properties are eventually specified. Resolution requires an architecture decision gate with a documented ADR, not a team-level assumption.

**CR-3: IDOR + no admin role — no recovery path** — HIGH (escalated from LOW)
Task 5's admin role absence is LOW in isolation. Combined with CR-1, it means tampering has no detection path, no recovery path, and no escalation path. Absence of admin role should be explicitly designated a non-goal with documented rationale, or an admin read/restore capability should be scoped.

**CR-4: Partial rollout gap extends IDOR exposure window** — MEDIUM
During US1-live/US2-not-deployed window, a victim whose CRITICAL_ALERT email preferences are tampered via IDOR cannot discover the tampered state through normal product interaction — the email preferences UI does not yet exist.

### P1/P2 Rationale Assessment (synthesis)

The consolidation agent independently assessed the P1/P2 priority rationale quality:

> "The P2 rationale understates email's structural importance. The stated rationale is that users prefer to manage email through unsubscribe links rather than through the settings UI — this is a behavioral observation about how users currently interact with email preferences, not a statement about whether email is a more or less important channel. Email is the foundational notification channel for web users: it reaches users regardless of whether they have the mobile app installed, regardless of platform, and it is the delivery mechanism for CRITICAL_ALERT notifications to users who do not use the mobile app. Framing P2 as lower priority because users prefer unsubscribe links conflates the management interface preference with the channel's overall reach and criticality."

> "The prioritization likely reflects mobile-centric product assumptions... For a product with meaningful web traffic or a user base that receives CRITICAL_ALERTs primarily via email, this prioritization could result in the higher-reach channel shipping later and with less-specified security properties."

This is a synthesis-level identification of the PROD-2 concern — surfaced by asking the consolidation agent to assess rationale quality rather than merely confirm rationale presence.

---

## Contamination Check

Pre-scoring scan of ALL Phase A findings for verbatim planted issue IDs:
PROD-1, PROD-2, SEC-1, FALSE-1, ARCH-1, ARCH-2, SEC-2, FALSE-2, DEL-1, DEL-2, ARCH-3, FALSE-3

**Result: CLEAN** — no verbatim IDs found.

---

## Scoring Pass — Spec Gate (PROD-1, PROD-2, SEC-1, FALSE-1)

| Issue | Expected Agent | Phase A Verdict | Caught By | Notes |
|---|---|---|---|---|
| PROD-1 | product-strategist | **Caught** | systems-architect Task 5 | Admin role absence identified; rated LOW vs. expected HIGH severity, but core problem correctly identified |
| PROD-2 | product-strategist | **Missed (Phase A)** | Consolidation (synthesis) | Task 6 (haiku): rationale IS present → INFO. Task 8: partial rollout framing, not priority inversion. Consolidation agent identified priority framing problem independently in synthesis step. |
| SEC-1 | security-reviewer | **Caught** | haiku Task 1 + sonnet Task 3 | CRITICAL from both agents; full IDOR chain in sonnet Task 3 |
| FALSE-1 | not triggered | **Not triggered** ✓ | — | No finding raised OQ-2 master toggle as HIGH/MEDIUM |

**Phase A catch rate**: 2 of 3 scorable issues (PROD-2 Missed Phase A; caught at synthesis)
**SC-C verdict**: **PASS** — ≥ Phase 1 routing-off baseline (2/3)

---

## SC-D: Haiku Structural Quality Comparison

| Structural Task | Haiku Finding | Phase 1 Sonnet Equivalent | Equivalent? |
|---|---|---|---|
| Task 1: Ownership enforcement present? | CRITICAL — absent (same conclusion as Phase 1) | CRITICAL IDOR (security-reviewer Phase 1) | **Yes — equivalent** |
| Task 6: P1/P2 rationale present? | INFO — rationale present (push = uninstall driver; email = UI preference) | HIGH — partial rollout risk from P1/P2 ordering (Phase 1); HIGH — P1/P2 inverted regulatory risk (Phase 2 warm) | **No — not equivalent for catching PROD-2** |

**SC-D verdict**: **PARTIAL**

- Haiku is fully equivalent for structural binary presence checks (ownership enforcement: present/absent). This is the correct use case.
- Haiku is NOT appropriate for structural correctness/quality checks (P1/P2 rationale: is it appropriate?). The structural task was framed as "identify whether rationale exists" — haiku answered correctly (yes, rationale exists). But PROD-2 requires judging the *quality* of the rationale, not its presence. This is a task design finding: a binary structural check cannot catch a priority-correctness issue.
- **Key lesson**: Structural tasks must be designed as correctness checks ("does the stated rationale reflect relative user reach?"), not presence checks ("does a rationale exist?"), to catch quality-level findings. Haiku may be appropriate for well-defined correctness checks, but the check must be designed to expose the defect.

---

## Token Efficiency Analysis

| Pass | Agents | Tiers | Phase A Est. Tokens | Catch Rate | Tokens/Caught |
|---|---|---|---|---|---|
| Phase 1 routing-off (broad) | 2 | sonnet×2 | ~3,950 | 2/3 | ~1,975 |
| Decomposed Phase A (this run) | 4 | haiku×2, sonnet×2 | ~5,800 | 2/3 | ~2,900 |
| Decomposed + consolidation | 5 | haiku×2, sonnet×3 | ~8,175 | 2/3 (3 at synth) | ~4,088 |

*Decomposed Phase A chars: Task 1 ~4,700 + Tasks 2-4 ~7,000 + Task 6 ~4,700 + Tasks 5,7,8 ~6,800 = ~23,200 → ~5,800 est. tokens*
*Consolidation chars: input ~5,500 + output ~4,000 = ~9,500 → ~2,375 est. tokens*

**Token efficiency verdict**: Decomposed framing uses MORE estimated tokens than broad framing (+47% Phase A only; +107% with consolidation) at equal catch rate. The additional cost comes from:
1. 4 agent calls vs. 2 (each agent carries fixture input overhead independently)
2. Required consolidation pass (equivalent to Phase B, but mandatory in decomposed approach — broad-framing agents consolidate within a single output)

**The haiku price savings are real but not captured by the character-count proxy.** Tasks 1 and 6 at haiku cost ~80% less per token than sonnet. The token count is roughly equal (~1,175 tokens each), but at haiku pricing (~$0.0002/k tokens vs. ~$0.003/k for sonnet) the two haiku tasks cost ~1/15th of equivalent sonnet tasks. This is a genuine per-task savings, but offset by the additional sonnet agent calls and consolidation.

**Net economics (estimated)**:
- Haiku Task 1 + Task 6: ~2,350 tokens × haiku rate ≈ $0.00047
- If those had been sonnet: ~2,350 tokens × sonnet rate ≈ $0.007
- Haiku savings: ~$0.007 per run pair
- Additional sonnet overhead (2 extra agent calls + consolidation): ~4,225 extra tokens × sonnet rate ≈ $0.013
- **Net cost: decomposed approach costs more than broad-framing for current 2-agent task count**

---

## Success Criteria Verdicts

| ID | Criterion | Verdict |
|---|---|---|
| SC-A | Router confidence > 0.70 for ≥ 6/8 decomposed tasks | **FAIL** — 0/8 above threshold; range 0.514–0.568 |
| SC-B | ≥ 2 tasks route to haiku | **PASS** — Tasks 1 and 6 route haiku via ADR_008 alternatives |
| SC-C | Catch rate ≥ Phase 1 baseline (2/3) | **PASS** — 2/3 at Phase A; PROD-2 surfaces at synthesis |
| SC-D | Decomposed haiku equivalent to broad sonnet for structural issues | **PARTIAL** — Equivalent for binary presence checks; not equivalent for correctness/quality checks |

---

## Key Findings

### 1. Confidence Floor Persists Regardless of Task Framing

Decomposed tasks produced complexity scores in the expected range (0.24 for structural, 0.43 for reasoning) but all 8 tasks returned confidence 0.514–0.568. SC-A fails. The hypothesis that decomposed framing would push confidence above 0.70 was not supported. The router's confidence output appears to have a systematic floor near 0.50 that is independent of task framing. ADR_008's alternatives ranking continues to be the mechanism that makes haiku routing possible — not confidence-driven recommendation.

### 2. Haiku Correctly Handles Binary Structural Checks

Task 1 (haiku): correctly identified IDOR ownership enforcement as absent — equivalent quality to Phase 1 sonnet. Duration: 8.2 seconds. The structural check was a well-defined binary question (requirement present or absent) and haiku answered it correctly and concisely. This is the correct use case for haiku at the spec gate.

### 3. Task Design Determines Whether Haiku Can Catch a Finding

Task 6 (haiku): correctly identified that P1/P2 rationale IS present — but missed PROD-2 because the task framing ("identify whether rationale is stated") was a presence check, not a correctness check. To catch PROD-2 via a structural task, the framing must be: "Is the stated rationale for P1/P2 consistent with the relative user reach of each channel?" A binary correctness check might be within haiku's capability — this is worth testing.

### 4. Consolidation Catches PROD-2 When Phase A Misses It

The consolidation agent, asked to assess "whether the P1/P2 rationale correctly reflects relative user reach and business impact," independently identified the priority inversion problem (mobile-centric framing understates email's structural importance for web users). This mirrors the warm-run Phase 2 finding. PROD-2 is consistently catchable at the synthesis layer when the synthesizing agent is explicitly tasked with rationale quality assessment, not merely finding consolidation.

### 5. Decomposed Approach Has Higher Token Volume at Equal Quality

The decomposed approach costs ~107% more in estimated tokens (with consolidation) than broad-framing Phase 1 at the same catch rate. The efficiency case for decomposed framing rests on price-per-token savings (haiku vs. sonnet rates) rather than volume reduction. For a 2-agent spec review, the haiku savings (~$0.007) do not offset the additional agent-call overhead (~$0.013). The economics improve as the number of structural tasks scales — if a spec has 6 structural tasks that route to haiku, the savings math changes.

---

## Follow-On Design Recommendations

### Recommendation 1: Redesign Task 6 as Correctness Check
Replace: "Identify whether P1/P2 assignments appear with a stated rationale."
With: "The spec assigns US1 (push notifications) as P1 and US2 (email notifications) as P2. Evaluate whether this priority assignment is consistent with the relative user reach of each channel — specifically, which channel reaches more users across the full user base (web + mobile)."

This frames PROD-2 detection as a binary correctness check haiku may be able to answer, rather than a presence check that systematically misses the inversion.

### Recommendation 2: Measure Price, Not Volume
The character-count proxy (ADR_007) is insufficient for decomposed experiments where tier routing matters. Add a price-per-run estimate using published haiku/sonnet/opus rates to compare experiments correctly. A decomposed run with 4 haiku tasks and 4 sonnet tasks may have equal token volume to 2 sonnet tasks but lower cost.

### Recommendation 3: Consolidation Task Framing for PROD-2
Add an explicit consolidation directive: "For each priority assignment (P1, P2) in the spec, assess whether the stated rationale reflects the channel's user reach across the full user base." This ensures synthesis-level PROD-2 detection is reliable and not dependent on whether a Phase A agent happens to examine the priority from the right angle.

### Recommendation 4: Test Correctness-Check Framing at Haiku
Design a 2-task structural variant for systems-architect:
- Task A: "The spec assigns email preferences as P2 (lower priority) and push as P1. Is email the primary notification channel for web users who do not have the mobile app installed?" (binary yes/no)
- Task B: "If yes, does the P1/P2 assignment reflect that ordering?" (binary yes/no)
Two haiku binary questions may reliably catch PROD-2 where one broad framing question does not.
