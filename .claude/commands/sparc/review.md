# SPARC Review — Three-Phase Adversarial Review Protocol

You are running a structured adversarial review. This protocol is designed to prevent groupthink through strict phase separation: agents cannot see each other's work until the designated synthesis step.

## Prerequisites
- Read `constitution.md` to determine the Adversarial Review rigor level:
  - **FULL**: All three phases, Opus for devil's advocate and synthesis judge, 4+ reviewers in Phase A
  - **STANDARD**: All three phases, Sonnet for devil's advocate, 3 reviewers in Phase A
  - **LIGHTWEIGHT**: Phase A + Phase C only (skip devil's advocate), 2 reviewers
- Identify what is being reviewed. Ask if not clear: "What artifact are we reviewing? (spec / plan / tasks / code)"
- Load the artifact being reviewed.

---

## Phase A — Independent Parallel Analysis

Assign reviewers based on what is being reviewed and the rigor level from `constitution.md`.

**For spec review:**
- requirements-analyst: Are user stories complete, testable, and independent? Are requirements implementation-agnostic?
- domain-expert: Do the entities and concepts match the problem domain? Is anything missing or misnamed?
- risk-analyst: Which assumptions are most dangerous? Which edge cases are not covered?
- security-reviewer: (FULL rigor only) Are there any privacy, trust, or abuse vectors in the design?

**For plan review:**
- systems-architect: Is the architecture appropriate for the scale and lifetime? Are there hidden coupling risks?
- security-reviewer: Are security requirements adequately addressed? Are there threat vectors?
- delivery-reviewer: Is the plan achievable? Are dependencies correctly sequenced? Are estimates realistic?
- operations-reviewer: (FULL rigor only) How does this behave in production? What are the operational concerns?

**For task review:**
- delivery-reviewer: Can tasks be executed in the listed order? Are parallel markers correct?
- qa-reviewer: Is the TDD sequence correct? Are tests written before implementation in every task?
- scope-reviewer: Do tasks cover all acceptance scenarios? Is anything in the spec not addressed by any task?

**Rules for Phase A:**
- Each reviewer operates INDEPENDENTLY. Do not share findings between reviewers.
- Each reviewer produces a structured report: [Findings] / [Concerns] / [Recommendations] / [Blockers]
- A BLOCKER is a finding that, if not addressed, should prevent PROCEED.
- Reviewers do not know what other reviewers found.

Collect all Phase A reports. Do NOT show them to the user yet.

---

## Phase B — Devil's Advocate Challenge

(Skip this phase if rigor level is LIGHTWEIGHT)

**Build the consensus summary first:**
From the Phase A reports, identify every finding that appears in 2 or more independent reports. This is the consensus — the things reviewers agreed on without coordinating.

The devil's advocate challenge targets the consensus specifically:

Assign one devil's advocate agent (Opus model, FULL rigor always — do not downgrade this regardless of project rigor level).

Give the devil's advocate:
- The consensus summary ONLY (not the full Phase A reports)
- This instruction: "Your job is to challenge this consensus. What is the consensus getting wrong? What important findings are ABSENT from the consensus because they're uncomfortable, non-obvious, or require disagreeing with the majority? What minority position, if true, would invalidate the consensus?"

The devil's advocate produces: [Challenged findings] / [Missing findings] / [Minority positions worth preserving]

---

## Phase C — Synthesis Judge

One synthesis judge agent receives:
- All Phase A reports (full text)
- The consensus summary
- The devil's advocate challenge (if Phase B ran)

The synthesis judge produces the final review report:

```markdown
# Review Report: [artifact name]
**Review date:** [date]
**Rigor level:** [FULL/STANDARD/LIGHTWEIGHT]
**Artifact reviewed:** [path/name]

## Consensus Findings (agreed by 2+ reviewers)
[List — these are the most reliable findings]

## Minority Findings (strong evidence, not consensus)
[List — preserved explicitly; "minority position with strong evidence outranks majority with weak evidence"]

## Active Disagreements
[Findings where reviewers reached opposite conclusions — flagged for user decision]

## Blind Spots Identified by Devil's Advocate
[Things the panel missed or avoided]

## Blockers (must be resolved before PROCEED)
[List — if empty, no blockers found]

## Recommendations
[Ordered list of improvements, separated into: address-before-proceeding / address-before-implementation / nice-to-have]

## Suggested ADRs
[Decisions surfaced by review that should be formally recorded]

## Suggested LOGs
[Open questions or challenges that should be tracked]

## Gate Decision
**Recommendation:** PROCEED / REVISE / RE-REVIEW
**Reasoning:** [one paragraph]
```

---

## Gate Decision Presentation

Present the synthesis report to the user and ask them to choose:

```
Gate decision required. Reviewer recommendation: [PROCEED/REVISE/RE-REVIEW]

Your options:
  [P] PROCEED — Accept the artifact as reviewed. Minor findings become follow-up tasks.
  [R] REVISE — Address blockers/major findings and resubmit for review.
  [V] RE-REVIEW — Major concerns warrant a full new review after revision.
  [O] OVERRIDE — Proceed despite blockers. Creates a LOG entry documenting accepted risk.
```

**If the user chooses OVERRIDE:**
Create a LOG entry immediately:
```
File: .decisions/LOG_NNN_override-[artifact]-[date].md
Content: Documents the specific blockers overridden, the user's stated rationale, and the risk accepted.
```

**If the user chooses PROCEED:**
- Any "address-before-proceeding" recommendations become tasks in the next planning phase
- Store review summary in AgentDB: `npx @claude-flow/cli@latest memory store --key "review-[artifact]-[date]" --value "[summary]" --namespace reviews`

**If the user chooses REVISE:**
- Produce a revision checklist from the blockers and major findings
- After revision, the user should run `/sparc-review` again on the updated artifact
