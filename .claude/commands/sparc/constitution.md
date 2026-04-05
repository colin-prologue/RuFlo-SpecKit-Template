# SPARC Constitution — Governance Calibration Wizard

You are running the project governance calibration wizard. Your job is to ask the user 21 targeted questions about their project context, then produce a `constitution.md` that sets rigor levels for 8 governing principles. These levels drive all downstream workflow behavior (review panel size, PR limits, documentation requirements, testing ceremony).

## Rules
- Ask questions ONE AT A TIME. Wait for each answer before continuing.
- Do not ask for information they've already provided.
- Keep questions concise. Accept short answers.
- After all questions are answered, produce the full `constitution.md` in one shot.

---

## The 21 Questions

Ask in this order:

**Team & Context**
1. What is the project name and a one-sentence description of what it does?
2. How many developers will work on this? (solo / small team 2–5 / larger team 6+)
3. What is the expected lifetime of this project? (prototype/spike / 6–12 months / 1+ years / indefinite)
4. Will there be developer turnover or handoffs? (no / unlikely / yes, expected)

**Audience & Scale**
5. Who are the primary users? (internal tools / consumer-facing / enterprise clients / mixed)
6. What is the expected user scale? (< 100 / hundreds / thousands / 100k+)
7. Is this a greenfield project or an addition to an existing system?

**Data & Risk**
8. Will this handle sensitive user data or PII? (no / yes, but not financial/health / yes, financial or health data)
9. Are there compliance or regulatory requirements? (none / GDPR/CCPA / HIPAA / PCI / SOC2 / other)
10. What is the blast radius if something goes wrong? (low: inconvenience / medium: data loss or downtime / high: security breach or financial loss)

**Technical Context**
11. What is the primary language and framework? (be specific)
12. Will this have a public API or be consumed by external systems?
13. Does this have CI/CD and automated testing infrastructure already?
14. Is there an existing codebase, or starting from scratch?

**Delivery**
15. Is there a fixed deadline or launch date?
16. What is the deployment target? (local only / cloud / on-prem / mobile / multiple)
17. Who approves production deployments? (developer self-serves / team lead review / formal change management)

**Quality Priorities**
18. Rank these from most to least important for this project: correctness, performance, security, maintainability, speed-of-delivery
19. What failure mode is most unacceptable? (incorrect results / downtime / data loss / security breach / slow performance)
20. Is there an existing test suite? What is the coverage expectation?
21. Any additional context, constraints, or strong preferences I should know about?

---

## Rigor Calibration Matrix

After collecting answers, apply this matrix to set each principle to FULL, STANDARD, or LIGHTWEIGHT:

| Principle | FULL triggers | STANDARD triggers | LIGHTWEIGHT triggers |
|---|---|---|---|
| Specification Before Implementation | Team 6+, 1+ year lifetime, compliance reqs | Team 2–5, 6–12 months | Solo, prototype/spike |
| Simplicity | Long lifetime, turnover expected | Mixed | Prototype, no turnover |
| Test-Driven Development | Compliance, high blast radius, public API | Medium risk, existing CI | Solo prototype, no CI |
| Incremental Delivery | Fixed deadline, consumer-facing | Most cases | Spike, no deadline |
| Security by Default | PII/financial/health data, compliance, public API | Any user data, external API | Internal tool, no sensitive data |
| Documentation Currency | Turnover expected, team 6+, 1+ years | Team 2–5 | Solo, prototype |
| Decision Transparency | Compliance, team 6+, external consumers | Team 2–5, public API | Solo, internal |
| Adversarial Review | High blast radius, security-critical, compliance | Medium risk, team work | Solo prototype |

---

## Output: constitution.md

Produce this file at the project root. Save it, don't just display it.

```markdown
# Project Constitution
**Version:** 1.0
**Project:** [name]
**Created:** [date]
**Last Amended:** [date]

## Project Identity
[2–3 sentence summary from answers]

## Team Context
- Size: [answer]
- Lifetime: [answer]
- Turnover: [answer]
- Deployment: [answer]

## Audience & Risk Profile
- Users: [answer]
- Scale: [answer]
- Sensitive Data: [answer]
- Compliance: [answer]
- Blast Radius: [answer]

## Quality Priorities (ranked)
1. [highest]
2. ...
5. [lowest]

## Most Unacceptable Failure Mode
[answer]

## Governing Principles

### 1. Specification Before Implementation — [FULL/STANDARD/LIGHTWEIGHT]
[one-sentence rationale based on their context]

### 2. Simplicity — [FULL/STANDARD/LIGHTWEIGHT]
[rationale]

### 3. Test-Driven Development — [FULL/STANDARD/LIGHTWEIGHT]
[rationale]

### 4. Incremental Delivery — [FULL/STANDARD/LIGHTWEIGHT]
[rationale]

### 5. Security by Default — [FULL/STANDARD/LIGHTWEIGHT]
[rationale]

### 6. Documentation Currency — [FULL/STANDARD/LIGHTWEIGHT]
[rationale]

### 7. Decision Transparency — [FULL/STANDARD/LIGHTWEIGHT]
[rationale]

### 8. Adversarial Review — [FULL/STANDARD/LIGHTWEIGHT]
[rationale]

## Amendment History
| Version | Date | Change | Trigger |
|---|---|---|---|
| 1.0 | [date] | Initial constitution | Project start |
```

---

## After Saving constitution.md

Store the rigor levels in AgentDB so all agents can read them:

```bash
npx @claude-flow/cli@latest memory store \
  --key "governance-rigor" \
  --value "[JSON of principle:level pairs]" \
  --namespace governance
```

Then tell the user:
- What rigor levels were set and why
- Which workflows will be most affected
- That they can update the constitution at any time by running `/sparc-constitution` again
- To run `/sparc-brainstorm` or `/sparc-specify` to start feature work
