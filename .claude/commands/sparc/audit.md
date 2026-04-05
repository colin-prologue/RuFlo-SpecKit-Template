# SPARC Audit — Bidirectional Doc-Code Consistency Audit

You are performing a three-pass bidirectional audit of documentation vs. code consistency. This surfaces drift, undocumented decisions, and tribal knowledge before it becomes technical debt.

## Prerequisites
- Read `constitution.md` for rigor level. FULL = all three passes + health score report. STANDARD = all three passes. LIGHTWEIGHT = Pass 1 only.
- Ask the user which feature or scope to audit if not specified. Default: the entire project.

---

## Pass 1 — Docs → Code

Verify that everything documented is reflected in code.

### 1a. ADR Compliance
For each `ADR_NNN_*.md` in `.decisions/`:
- Find the code that implements or is constrained by this decision
- Does the code match what the ADR says was decided?
- If the ADR says "we chose Prisma", is Prisma actually used (not some other ORM)?
- Flag: **ADR_DRIFT** if code contradicts a finalized ADR

### 1b. Spec Coverage
For each user story in `specs/*-spec.md`:
- Is there a corresponding test that exercises this acceptance scenario?
- Does the implementation satisfy the functional requirements (FR-NNN)?
- Flag: **SPEC_GAP** if a requirement has no test coverage
- Flag: **SPEC_DRIFT** if implementation behavior differs from spec

### 1c. Plan Structure Compliance
For each architectural decision in `specs/*-plan.md`:
- Is the component structure as planned?
- Are the API contracts as specified?
- Is the data model consistent with what was planned?
- Flag: **PLAN_DRIFT** if significant divergence exists

### 1d. Task Completion Verification
For each task in `specs/*-tasks.md` marked `[x]`:
- Can we confirm the task is actually done? (test exists and passes / code change exists)
- Flag: **TASK_UNVERIFIED** if a completed task has no observable evidence of completion

### 1e. Contract Compliance
For any API contracts defined in the plan:
- Does the actual implementation match the defined schemas?
- Flag: **CONTRACT_DRIFT** if inputs, outputs, or error cases diverge

---

## Pass 2 — Code → Docs

Verify that significant code decisions have corresponding documentation.

### 2a. Undocumented Dependencies
Scan `package.json`, imports, or dependency files:
- Are there dependencies not mentioned in any ADR or plan?
- For each undocumented dependency: recommend an ADR or note it as a LOW/MEDIUM/HIGH decision gap

### 2b. Architectural Patterns in Code
Scan the codebase for:
- Design patterns (factory, strategy, observer, etc.) not mentioned in the plan
- Significant abstractions or modules not described in any spec or plan
- For each finding: flag as **UNDOCUMENTED_ARCHITECTURE** and recommend a new ADR

### 2c. API Endpoints
Scan for route definitions, exported functions, or public interfaces:
- Are all public APIs documented in the plan or spec?
- Flag: **UNDOCUMENTED_API** for any public surface not covered

### 2d. CLAUDE.md Freshness
Check if `CLAUDE.md` accurately describes:
- Current build commands (does `npm run build` actually work?)
- Current test commands
- Current directory structure
- Flag: **CLAUDEMD_STALE** for any inaccuracies

### 2e. Dead Code
Identify:
- Exported functions/classes with no callers
- Feature flags or config values no longer referenced
- TODOs or FIXMEs older than the current feature
- Flag: **DEAD_CODE** for cleanup candidates

### 2f. Config-as-Decision Detection
Scan for hardcoded values that represent implicit decisions:
- Magic numbers or strings that should be constants with documented rationale
- Configuration values that differ between environments without explanation
- Flag: **IMPLICIT_DECISION** — recommend creating an ADR or LOG

---

## Pass 3 — Consistency Crosscheck

(FULL rigor only)

### 3a. Naming Drift
Compare entity names across all artifacts:
- Spec → Plan → Tasks → Code → Tests → Docs
- Flag: **NAMING_DRIFT** if the same concept has different names across artifacts

### 3b. Error Handling Divergence
Check that error handling strategy is consistent:
- Is the same error bubbled up differently in different modules?
- Are HTTP status codes consistent with the API contract?
- Flag: **ERROR_HANDLING_DIVERGENCE**

### 3c. Duplicate Implementations
Identify:
- Multiple implementations of the same logic
- Helper functions with overlapping functionality
- Flag: **DUPLICATE_IMPL**

---

## Health Score

Compute a five-dimension health score:

| Dimension | Weight | Score (A–F) | Basis |
|---|---|---|---|
| ADR Compliance | 25% | [A-F] | Count of ADR_DRIFT flags |
| Spec Coverage | 25% | [A-F] | % of acceptance scenarios with passing tests |
| Documentation Freshness | 20% | [A-F] | Count of PLAN_DRIFT + CLAUDEMD_STALE flags |
| Code Consistency | 15% | [A-F] | Count of NAMING_DRIFT + DUPLICATE_IMPL flags |
| Decision Tracking | 15% | [A-F] | Count of IMPLICIT_DECISION + UNDOCUMENTED_ARCHITECTURE flags |

**Overall grade** = weighted average. Display as a letter grade with a one-sentence summary.

Grading: A = 0 flags, B = 1–2 minor, C = 3–5 or 1 major, D = 6+ or 2+ major, F = critical ADR_DRIFT or security issues

---

## Output: Audit Report

Produce `docs/audit-[date].md`:

```markdown
# Audit Report
**Date:** [date]
**Scope:** [feature or "full project"]
**Rigor:** [FULL/STANDARD/LIGHTWEIGHT]
**Overall Grade:** [letter]

## Health Score
| Dimension | Grade | Flags |
|---|---|---|
| ADR Compliance | [A-F] | [N] |
| Spec Coverage | [A-F] | [N] |
| Documentation Freshness | [A-F] | [N] |
| Code Consistency | [A-F] | [N] |
| Decision Tracking | [A-F] | [N] |

## Findings by Flag Type

### ADR_DRIFT (critical)
[list]

### SPEC_GAP / SPEC_DRIFT (high)
[list]

### UNDOCUMENTED_ARCHITECTURE / IMPLICIT_DECISION (medium)
[list]

### NAMING_DRIFT / DEAD_CODE (low)
[list]

## Recommended New ADRs
[list decisions found in code that should be documented]

## Recommended New LOGs
[list questions or challenges surfaced by the audit]

## Cleanup Candidates
[list dead code, duplicates]
```

Store the audit result in AgentDB:
```bash
npx @claude-flow/cli@latest memory store \
  --key "audit-[date]-grade" \
  --value "[overall grade and top findings]" \
  --namespace audits
```

Tell the user the overall grade, the most critical findings, and what to fix before the next feature begins.
