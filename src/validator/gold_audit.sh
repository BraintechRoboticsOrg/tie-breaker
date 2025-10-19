#!/bin/bash
# ─────────────────────────────────────────────────────────────
# 🧠 BrainTech Robotics – Tie-Breaker Gold Audit & Self-Verify
# 💻 Execution Context: Laptop / 🧠 Server Compatible
# 🔒 Compliance: BTR Gold Protocol – Integrity v1.0
# ─────────────────────────────────────────────────────────────

set -euo pipefail
trap 'echo "[ERROR] Line $LINENO – Audit aborted"; exit 1' ERR

# ── Normalize Base Path ──────────────────────────────────────
BASE="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." >/dev/null 2>&1 && pwd -P )"
TARGET="$BASE"
LOG="$BASE/logs/gold_audit_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$BASE/logs"

echo "--------------------------------------------------------------"
echo "[INFO] Running Gold Audit"
echo "Target: $TARGET"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Log: $LOG"
echo "--------------------------------------------------------------" | tee -a "$LOG"

cd "$TARGET"

# ── Core Checks ──────────────────────────────────────────────
ok=true

check_dir() {
  local d="$1"
  if [ ! -d "$d" ]; then
    echo "[❌] Missing directory: $d" | tee -a "$LOG"
    ok=false
  else
    echo "[✅] Found: $d" | tee -a "$LOG"
  fi
}

check_file() {
  local f="$1"
  if [ ! -f "$f" ]; then
    echo "[❌] Missing file: $f" | tee -a "$LOG"
    ok=false
  else
    echo "[✅] File exists: $f" | tee -a "$LOG"
  fi
}

# Expected Directories
for d in docs src tests; do check_dir "$d"; done

# Expected Sub-Directories
for d in src/loader src/validator src/telemetry src/metrics; do check_dir "$d"; done

# Critical Files
for f in src/loader/pour_loader.sh tests/test_local_pour.sh; do check_file "$f"; done

# ── Permission Sanity ─────────────────────────────────────────
echo "--------------------------------------------------------------" | tee -a "$LOG"
find src -type f -name "*.sh" -exec chmod +x {} \;
echo "[🔐] Normalized script permissions" | tee -a "$LOG"

# ── Syntax Validation ─────────────────────────────────────────
for f in $(find src -type f -name "*.sh"); do
  if ! bash -n "$f" 2>/dev/null; then
    echo "[❌] Syntax error in $f" | tee -a "$LOG"
    ok=false
  else
    echo "[✅] Syntax OK → $f" | tee -a "$LOG"
  fi
done

# ── Final Verdict ─────────────────────────────────────────────
echo "--------------------------------------------------------------" | tee -a "$LOG"
if $ok; then
  echo "[OK] Gold Audit PASSED – All checks verified." | tee -a "$LOG"
  exit 0
else
echo "--------------------------------------------------------------" | tee -a "$LOG"; 
echo "[🩹] Triggering Gold Auto-Heal (phase 2)..." | tee -a "$LOG"; 
AUTOHEAL="$BASE/src/validator/gold_autoheal.sh"; 
if [ -x "$AUTOHEAL" ]; then bash "$AUTOHEAL" | tee -a "$LOG"; else echo "[⚠️] Auto-Heal module missing"; fi; 
echo "--------------------------------------------------------------" | tee -a "$LOG";
  echo "[FAIL] Gold Audit FAILED – Review $LOG for details." | tee -a "$LOG"
  exit 1
fi
