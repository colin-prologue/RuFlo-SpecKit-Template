# LOG-002: Rigor Level Assumed Without Constitution

**Date**: 2026-04-05
**Type**: ASSUMPTION
**Status**: Open
**Raised In**: specs/ruflo-benchmark-spec.md — Explicit Assumptions (A-06)

---

## Description

No `constitution.md` exists in this project. The benchmark spec assumed STANDARD rigor
(single maintainer, research context, no PII, low blast radius) without running
`/sparc-constitution` to calibrate governance formally.

## Impact

- Panel composition in the benchmark uses STANDARD panel: security-reviewer +
  systems-architect + devils-advocate. If constitution sets a different default,
  this changes the Phase A agent set.
- Review gates for the spec itself: STANDARD rigor requires spec review before planning.
  If constitution sets LIGHTWEIGHT, that gate is optional.

## Resolution Path

Run `/sparc-constitution` before implementation begins. If it changes rigor:
- FULL: add product-strategist + delivery-reviewer to Phase A panel; spec must be
  re-reviewed before planning proceeds.
- LIGHTWEIGHT: devils-advocate-only panel; accept lower planted-issue catch rate as
  a design choice for this experiment.

**Resolved By**: TBD
**Resolved Date**: TBD
