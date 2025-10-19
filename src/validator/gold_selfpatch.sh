#!/bin/bash
# ─────────────────────────────────────────────────────────────
# 🛰️  BrainTech Robotics – Tie-Breaker GitHub Self-Patch Manifest
# 💻  Execution Context: Laptop / 🧠  Server Compatible
# 🔒  Compliance: BTR Gold Protocol v1.2
# ─────────────────────────────────────────────────────────────
set -euo pipefail
trap 'echo "[ERROR] GitHub Self-Patch failed at line $LINENO"; exit 1' ERR

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." >/dev/null 2>&1 && pwd -P)"
LOG="$BASE/logs/gold_selfpatch_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$BASE/logs"

echo "--------------------------------------------------------------" | tee -a "$LOG"
echo "[INFO] Launching GitHub Self-Patch Manifest" | tee -a "$LOG"
echo "Base: $BASE" | tee -a "$LOG"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG"
echo "--------------------------------------------------------------" | tee -a "$LOG"

# 1️⃣ Prepare commit
git -C "$BASE" add . >/dev/null 2>&1
git -C "$BASE" commit -m "autoheal: self-patch $(date +%Y%m%d_%H%M)" >/dev/null 2>&1 || true

# 2️⃣ Issue manifest
TITLE="Auto-Heal Report – $(date +%Y-%m-%d_%H:%M)"
BODY_FILE="$BASE/logs/_autoheal_manifest.md"
{
  echo "### 🩹 Auto-Heal Event Report"
  echo "- **Timestamp:** $(date)"
  echo "- **Host:** $(hostname)"
  echo "- **Base Path:** $BASE"
  echo "- **Log:** $LOG"
  echo "- **Commit Hash:** $(git -C "$BASE" rev-parse HEAD 2>/dev/null || echo 'n/a')"
  echo "#### Recent Log Excerpt:"
  tail -n 25 "$LOG" 2>/dev/null || echo "[No log details]"
} > "$BODY_FILE"

# 3️⃣ Push & notify via GitHub CLI
if git -C "$BASE" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[🛰️] Pushing self-patch to remote..." | tee -a "$LOG"
  git -C "$BASE" push origin main || echo "[⚠️] Git push skipped (no remote)"
fi

if command -v gh >/dev/null 2>&1; then
  echo "[📬] Creating GitHub issue..." | tee -a "$LOG"
  gh issue create --repo BraintechRoboticsOrg/tie-breaker \
    --title "$TITLE" \
    --body-file "$BODY_FILE" \
    >/dev/null 2>&1 || echo "[⚠️] GitHub issue creation skipped"
else
  echo "[ℹ️] GitHub CLI not available – manifest saved locally at $BODY_FILE" | tee -a "$LOG"
fi

echo "--------------------------------------------------------------" | tee -a "$LOG"
echo "[✅] GitHub Self-Patch Manifest completed." | tee -a "$LOG"
