# Benchmark Run: Phase 1 — Routing-Off (Sonnet Baseline)

**Gate**: spec | **Phase**: 1 | **State**: routing-off
**Date**: 2026-04-05
**Panel**: security-reviewer (Sonnet), systems-architect (Sonnet), devils-advocate (Sonnet), synthesis-judge (Sonnet)
**Contamination**: CLEAN
**ADRs**: ADR_003, ADR_004, ADR_007, ADR_008

---

## Routing Recommendations Log (logged only — not acted on in this pass)

| Agent | Raw Recommendation | Confidence | Complexity | Top Alternative | Actual Tier Used |
|---|---|---|---|---|---|
| security-reviewer | opus | 0.563 | 0.505 | sonnet (0.989) | **sonnet** (routing disabled) |
| systems-architect | opus | 0.568 | 0.437 | sonnet (0.875) | **sonnet** (routing disabled) |

Both agents received opus recommendations with confidence < 0.60. Routing-on pass (per ADR_008) would use top non-opus alternative = sonnet for both. The routing-off and routing-on passes will use the same tier (sonnet) for all Phase A agents. Cost difference will be routing overhead only (~2 tool calls × ~0.5ms each).

---

## Phase A Findings

### security-reviewer [TIER: sonnet]

[security-reviewer] [TIER: sonnet] SEVERITY: CRITICAL — No authorization check to verify session token maps to preference record being read or written (User Story 1, Acceptance Criteria). Susceptible to IDOR: any authenticated user can read or overwrite another user's notification preferences.

[security-reviewer] [TIER: sonnet] SEVERITY: CRITICAL — Unsubscribe link token (User Story 2) has no defined expiry, single-use enforcement, or user binding. Token harvested from forwarded email enables preference manipulation for any targeted user. Email proxies pre-fetching links create inadvertent redemption risk.

[security-reviewer] [TIER: sonnet] SEVERITY: HIGH — Spec delegates session validation to Auth service but defines no requirement that unauthenticated requests are rejected before processing.

[security-reviewer] [TIER: sonnet] SEVERITY: HIGH — Unsubscribe link is a state-mutating operation via GET-equivalent click. CSRF framing incorrect (DA challenged); real risk is unauthenticated state mutation, covered by CB-2 in synthesis.

[security-reviewer] [TIER: sonnet] SEVERITY: HIGH — OQ-1 defers audit logging; preference changes (especially CRITICAL_ALERT) leave no forensic record. DA escalated to CRITICAL as part of IDOR compound chain.

[security-reviewer] [TIER: sonnet] SEVERITY: MEDIUM — No requirement to invalidate in-flight notifications when preferences change; race condition window for suppression.

[security-reviewer] [TIER: sonnet] SEVERITY: MEDIUM — Default state enforced server-side unspecified; malformed request could silently reset to permissive default.

[security-reviewer] [TIER: sonnet] SEVERITY: MEDIUM — API versioning has no per-version access control requirement; DA downgraded to LOW.

[security-reviewer] [TIER: sonnet] SEVERITY: MEDIUM — No server-side enumeration validation on event type field; arbitrary identifiers accepted.

[security-reviewer] [TIER: sonnet] SEVERITY: LOW — Analytics events may be client-side; DA recommended removing from security findings.

### systems-architect [TIER: sonnet]

[systems-architect] [TIER: sonnet] SEVERITY: CRITICAL — No persona or acceptance criteria for administrative or support staff who need to view or override user notification preferences (User Stories section). DA challenged CRITICAL rating; reduced to MEDIUM in synthesis.

[systems-architect] [TIER: sonnet] SEVERITY: CRITICAL — Push notification defaults defined in both User Story 1 AC and Event Type table with no single authoritative source. Dual-ownership creates silent inconsistency risk if either source changes.

[systems-architect] [TIER: sonnet] SEVERITY: CRITICAL — Constraint "existing notification delivery pipelines must not be modified" directly contradicts User Story 2 unsubscribe token handling. Architecturally incoherent; blocks User Story 2 implementation.

[systems-architect] [TIER: sonnet] SEVERITY: HIGH — No persona or acceptance criteria for unauthenticated unsubscribe behavior. Email recipients may not have active session.

[systems-architect] [TIER: sonnet] SEVERITY: HIGH — prefs_push_disabled_all success metric definition ambiguous (individual toggles vs. future master toggle).

[systems-architect] [TIER: sonnet] SEVERITY: HIGH — GDPR data retention on account deletion unaddressed despite OQ-1 flagging GDPR awareness.

[systems-architect] [TIER: sonnet] SEVERITY: HIGH — Partial rollout behavior undefined (push live, email preferences not yet deployed).

[systems-architect] [TIER: sonnet] SEVERITY: MEDIUM — No conflict resolution policy for simultaneous multi-device preference changes.

[systems-architect] [TIER: sonnet] SEVERITY: MEDIUM — CRITICAL_ALERT opt-out classification undefined; spec does not distinguish mandatory vs. opt-outable event types.

[systems-architect] [TIER: sonnet] SEVERITY: MEDIUM — 80% unsubscribe metric embeds unvalidated product assumption. DA: remove from technical findings.

[systems-architect] [TIER: sonnet] SEVERITY: MEDIUM — Preference data ownership ambiguous (User Profile service vs. Notifications service).

[systems-architect] [TIER: sonnet] SEVERITY: MEDIUM — Intermediate user states (email-unverified, suspended) unaddressed.

[systems-architect] [TIER: sonnet] SEVERITY: LOW — OQ-2 cross-reference to 022-notification-history appears misplaced. DA: remove.

[systems-architect] [TIER: sonnet] SEVERITY: LOW — Versioning constraint has no implementation guidance or referenced standard.

---

## Phase B Summary (Devils-Advocate)

Key escalations and challenges — see full output in session. Net outcomes:
- 3 security-reviewer findings challenged (session delegation false positive, CSRF framing incorrect, API versioning speculation)
- Admin persona downgraded from CRITICAL to MEDIUM
- Audit logging escalated from HIGH to CRITICAL (compound IDOR chain)
- 2 NEW CRITICAL findings raised by DA: schema evolution default, dual authentication models
- 2 NEW HIGH findings: Notifications service unavailability, push channel granularity

---

## Synthesis Summary

Gate decision: **REVISE** — 5 critical blockers, must resolve before proceeding to planning.

Critical blockers: pipeline constraint conflict (CB-1), dual auth models (CB-2), compound IDOR+audit gap (CB-3), schema evolution default (CB-4), CRITICAL_ALERT opt-out classification (CB-5).

---

## Overlap Clusters

| Finding Topic | Agents | Verdict |
|---|---|---|
| Unsubscribe token properties + IDOR user binding | security-reviewer, DA | Different angles — keep both; H-1 resolving is precondition for CB-3 |
| CRITICAL_ALERT classification + opt-out ambiguity | security-reviewer, systems-architect, DA | Redundant framing — consolidated into CB-5 |
| IDOR attack vector + audit logging gap | security-reviewer ×2, DA | Different angles — merged into CB-3 compound chain |
| Schema evolution default + CRITICAL_ALERT classification | DA ×2 | Different angles — CB-5 must resolve before CB-4 |
| Pipeline constraint + dual auth models | systems-architect, DA | Different angles — different problems despite shared feature surface |
| GDPR retention + schema evolution | systems-architect, DA | Different angles — opposite ends of data lifecycle |
| Admin persona + audit logging | Phase A reviewer, CB-3 | Partially redundant — admin writes absorbed into CB-3 audit requirement |

---

## Contamination Check

Pre-scoring scan of ALL Phase A findings for verbatim planted issue IDs:
PROD-1, PROD-2, SEC-1, FALSE-1, ARCH-1, ARCH-2, SEC-2, FALSE-2, DEL-1, DEL-2, ARCH-3, FALSE-3

**Result: CLEAN** — no verbatim IDs found in Phase A output.

---

## Miss Rate (Spec Gate — PROD-1, PROD-2, SEC-1, FALSE-1)

| Planted Issue | Severity | Expected Agent | Caught By | Result | Notes |
|---|---|---|---|---|---|
| PROD-1 | HIGH | product-strategist | systems-architect | **Caught** | systems-architect raised admin persona gap at CRITICAL (overcorrected severity, but core problem correctly identified) |
| PROD-2 | MEDIUM | product-strategist | — | **Missed** | No agent raised email=foundational-web-channel vs. push=mobile-only priority reversal framing; systems-architect raised partial rollout risk from priority ordering (different angle, not core PROD-2 problem) |
| SEC-1 | HIGH | security-reviewer | security-reviewer | **Caught** | Raised as CRITICAL (more severe than benchmark key); IDOR ownership enforcement gap correctly identified |
| FALSE-1 | — (FP trap) | none | — | **Not triggered** ✓ | systems-architect raised OQ-2 cross-reference at LOW (not HIGH/MEDIUM); DA challenged and recommended removing it entirely |

**Catch rate**: 2 of 3 scorable issues (PROD-2 Missed; FALSE-1 not triggered)

**Comparison to Claude-Root STANDARD**:
| Issue | Claude-Root STANDARD | RuFlo STANDARD (this run) | Delta |
|---|---|---|---|
| PROD-1 | Caught (product-strategist) | Caught (systems-architect) | Same result, different agent |
| PROD-2 | Caught (partial) | Missed | Regression — no product-strategist in RuFlo STANDARD panel |
| SEC-1 | Missed | Caught | **Improvement** — security-reviewer added to RuFlo STANDARD |
| FALSE-1 | False positive (DA as MEDIUM) | Not triggered | **Improvement** — DA did not escalate; challenged the LOW finding instead |

---

## Unique Contribution by Agent (Phase A only)

| Agent | Unique Findings | Shared Findings | Unique Rate |
|---|---|---|---|
| security-reviewer | 7 | 3 | 70% |
| systems-architect | 10 | 4 | 71% |

*Shared topics: default state authority (both agents raised from different angles), unsubscribe authentication gap (both raised), CRITICAL_ALERT classification (both touched)*

---

## Character Count Table (Phase A — ADR_007)

| Agent | Input Chars | Output Chars | Total Chars | Estimated Tokens |
|---|---|---|---|---|
| security-reviewer | ~4,800 | ~2,800 | ~7,600 | ~1,900 |
| systems-architect | ~4,800 | ~3,400 | ~8,200 | ~2,050 |
| **Phase A Total** | **~9,600** | **~6,200** | **~15,800** | **~3,950** |

*Input chars = fixture spec (~4,200) + system prompt (~600) per agent*
*Estimated tokens = total chars ÷ 4 (ADR_007 character-count proxy)*

---

## Tokens-per-Caught-Issue (Routing-Off Baseline)

| Metric | Value |
|---|---|
| Total Phase A estimated tokens | ~3,950 |
| Issues Caught (full) | 2 (PROD-1, SEC-1) |
| Issues Caught (partial) | 0 |
| **Tokens-per-caught-issue** | **~1,975 estimated tokens** |

*This is the baseline for Phase 1 routing-on comparison (ADR_004)*
*Note: routing-on will also use Sonnet for both agents per ADR_008 adjusted routing logic (confidence < 0.60 → use top non-opus alternative = sonnet). Cost delta will be routing call overhead only (~4 hooks_model-route calls × negligible latency).*
