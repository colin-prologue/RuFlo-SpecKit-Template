---
name: sparc-constitution
description: Governance calibration wizard — 21-question interview that sets FULL/STANDARD/LIGHTWEIGHT rigor levels for 8 principles, stored in AgentDB and written to constitution.md
---

# SPARC Constitution

## Role
Calibrate project governance before any feature work begins. Interview the user, produce `constitution.md`, store rigor levels in AgentDB.

## Memory
```javascript
// Retrieve existing constitution if re-running
mcp__claude-flow__memory_retrieve { key: "governance-rigor", namespace: "governance" }
```

## Interview (one question at a time, wait for each answer)

**Team & Context:** project name/description · team size (solo/2-5/6+) · expected lifetime (spike/6-12mo/1yr+/indefinite) · developer turnover expected?

**Audience & Scale:** primary users · expected scale · greenfield or existing system?

**Data & Risk:** sensitive/PII data? · compliance requirements (none/GDPR/HIPAA/PCI/SOC2) · blast radius if something goes wrong (low/medium/high)?

**Technical:** primary language & framework · public API or external consumers? · existing CI/CD and tests? · existing codebase?

**Delivery:** fixed deadline? · deployment target · who approves production?

**Priorities:** rank correctness/performance/security/maintainability/speed-of-delivery · most unacceptable failure mode · existing test coverage expectation · any other constraints?

## Rigor Calibration

| Principle | FULL | LIGHTWEIGHT |
|---|---|---|
| Specification Before Implementation | team 6+, 1yr+, compliance | solo, spike |
| Simplicity | long lifetime, turnover | prototype, no turnover |
| Test-Driven Development | compliance, high blast radius, public API | solo prototype, no CI |
| Incremental Delivery | fixed deadline, consumer-facing | spike, no deadline |
| Security by Default | PII/financial/health, compliance, public API | internal, no sensitive data |
| Documentation Currency | turnover, team 6+, 1yr+ | solo, prototype |
| Decision Transparency | compliance, team 6+, external consumers | solo, internal |
| Adversarial Review | high blast radius, security-critical, compliance | solo prototype |

STANDARD = everything between FULL and LIGHTWEIGHT triggers.

## Output

Write `constitution.md` at project root using the structure: project identity · team context · audience & risk profile · quality priorities · 8 governing principles each with `[FULL/STANDARD/LIGHTWEIGHT]` and one-sentence rationale · amendment history table.

Store rigor levels:
```javascript
mcp__claude-flow__memory_store {
  key: "governance-rigor",
  value: { "spec": "FULL", "tdd": "STANDARD", ... },
  namespace: "governance"
}
```

Tell the user: rigor levels set, which workflows are most affected, next step is `/sparc-brainstorm` or `/sparc-specify`.
