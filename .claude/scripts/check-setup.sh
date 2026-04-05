#!/bin/bash
# .claude/scripts/check-setup.sh
#
# Runs on SessionStart to verify the RuFlo + Claude-Root environment is ready.
# Uses a flag file (.claude/.setup-complete) so the full check only runs once.
# Subsequent sessions do a lightweight daemon check only.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
FLAG_FILE="$PROJECT_DIR/.claude/.setup-complete"

# ── Lightweight path (already initialized) ───────────────────────────────────
if [ -f "$FLAG_FILE" ]; then
  # Only check if daemon needs restarting
  if ! npx @claude-flow/cli@latest daemon status 2>/dev/null | grep -q "running"; then
    npx @claude-flow/cli@latest daemon start --background 2>/dev/null
    echo "[SETUP] Daemon restarted"
  fi

  # Warn if constitution is missing (may have been deleted or this is a new clone)
  if [ ! -f "$PROJECT_DIR/constitution.md" ]; then
    echo "[SETUP] ⚠ constitution.md missing — run /sparc-constitution before feature work"
  fi

  echo "[SETUP] Environment ready"
  exit 0
fi

# ── Full first-run check ──────────────────────────────────────────────────────
echo "[SETUP] First-run environment check..."

ERRORS=0
WARNINGS=0

# 1. claude-flow CLI
if npx @claude-flow/cli@latest --version &>/dev/null; then
  CLI_VERSION=$(npx @claude-flow/cli@latest --version 2>/dev/null | head -1)
  echo "[SETUP] ✓ claude-flow CLI: $CLI_VERSION"
else
  echo "[SETUP] ✗ claude-flow CLI unavailable — run: npx @claude-flow/cli@latest doctor --fix"
  ERRORS=$((ERRORS + 1))
fi

# 2. Daemon
if npx @claude-flow/cli@latest daemon status 2>/dev/null | grep -q "running"; then
  echo "[SETUP] ✓ Daemon running"
else
  echo "[SETUP] Starting claude-flow daemon..."
  if npx @claude-flow/cli@latest daemon start --background 2>/dev/null; then
    echo "[SETUP] ✓ Daemon started"
  else
    echo "[SETUP] ⚠ Daemon failed to start — some memory/hook features may be unavailable"
    WARNINGS=$((WARNINGS + 1))
  fi
fi

# 3. Constitution (project governance calibration)
if [ -f "$PROJECT_DIR/constitution.md" ]; then
  echo "[SETUP] ✓ constitution.md found"
else
  echo "[SETUP] ⚠ No constitution.md — run /sparc-constitution before starting any feature work"
  WARNINGS=$((WARNINGS + 1))
fi

# 4. .decisions/ directory (ADR/LOG tracking — Claude-Root convention)
if [ -d "$PROJECT_DIR/.decisions" ]; then
  ADR_COUNT=$(find "$PROJECT_DIR/.decisions" -name "ADR_*.md" 2>/dev/null | wc -l | tr -d ' ')
  echo "[SETUP] ✓ .decisions/ exists ($ADR_COUNT ADR(s) recorded)"
else
  mkdir -p "$PROJECT_DIR/.decisions"
  echo "[SETUP] ✓ Created .decisions/ for ADR/LOG tracking"
fi

# 5. docs/adr/ directory (RuFlo auto-generated ADR convention)
if [ ! -d "$PROJECT_DIR/docs/adr" ]; then
  mkdir -p "$PROJECT_DIR/docs/adr"
  echo "[SETUP] ✓ Created docs/adr/ for auto-generated architecture records"
fi

# 6. specs/ directory
if [ ! -d "$PROJECT_DIR/specs" ]; then
  mkdir -p "$PROJECT_DIR/specs"
  echo "[SETUP] ✓ Created specs/ for feature specifications"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
if [ "$ERRORS" -eq 0 ]; then
  touch "$FLAG_FILE"
  if [ "$WARNINGS" -gt 0 ]; then
    echo "[SETUP] Environment established with $WARNINGS warning(s)"
    echo "[SETUP] Next step: run /sparc-constitution to calibrate project governance"
  else
    echo "[SETUP] Environment fully established"
  fi
else
  echo "[SETUP] $ERRORS error(s) must be resolved before work begins"
  echo "[SETUP] Run: npx @claude-flow/cli@latest doctor --fix"
  exit 1
fi
