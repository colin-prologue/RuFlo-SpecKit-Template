# Contamination Detection Test Cases

Written before the benchmark command — these are the failing tests.
The command's contamination check must pass all three cases.

---

## Test Case 1 — CONTAMINATED: verbatim full ID present

**Input** (synthetic Phase A finding):
```
[security-reviewer] The authentication dependency is listed but SEC-1 shows no
ownership enforcement requirement on the preference endpoint.
```

**Expected result**: CONTAMINATION DETECTED — abort scoring, do not score this run.
**Reason**: "SEC-1" appears verbatim as a full ID in the finding text.

---

## Test Case 2 — CLEAN: partial ID present, no full match

**Input** (synthetic Phase A finding):
```
[security-reviewer] The SEC framework dependency is listed but no ownership enforcement
requirement appears on the preference endpoint. PROD configuration is not relevant here.
```

**Expected result**: CLEAN — proceed to scoring.
**Reason**: "SEC" and "PROD" appear without full numeric suffix. Rule is full ID match only
(e.g., "SEC-1", "PROD-2"). Partial strings do not trigger contamination.

---

## Test Case 3 — CLEAN: planted issue described without ID

**Input** (synthetic Phase A finding):
```
[security-reviewer] The spec lists auth service as a dependency for session token
validation but does not require the preference endpoint to verify the authenticated user
owns the preferences being modified. This is an IDOR attack vector.
```

**Expected result**: CLEAN — proceed to scoring; this finding should score as Caught for SEC-1.
**Reason**: No verbatim issue ID present. The finding describes the planted issue correctly
and should be scored as a genuine detection, not contamination.

---

## Contamination Rule Reference (FR-003)

- Match: full IDs only — PROD-1, PROD-2, SEC-1, FALSE-1, ARCH-1, ARCH-2, SEC-2,
  FALSE-2, DEL-1, DEL-2, ARCH-3, FALSE-3
- Not a match: "SEC", "PROD", "ARCH", "DEL", "FALSE" alone, or partial strings
- On contamination: output "CONTAMINATION DETECTED", abort scoring, invalidate run,
  prompt maintainer to re-run with clean context
