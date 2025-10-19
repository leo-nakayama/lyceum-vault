#!/usr/bin/env bash
# publish_and_backup.sh
# 1) Validates build (mkdocs --strict)
# 2) Commits & pushes current branch to GitHub
# 3) Rsync-mirrors repo to /mnt/share (excluding .git and site/)
set -euo pipefail

# --- Config ---
SRC_DIR="${SRC_DIR:-$HOME/Projects/leo-nakayama.github.io}"
DEST_DIR="${DEST_DIR:-/mnt/share/Projects/leo-nakayama.github.io_backup}"
BRANCH="${BRANCH:-$(git -C "$SRC_DIR" rev-parse --abbrev-ref HEAD)}"
COMMIT_MSG="${1:-Vault update: $(date +'%Y-%m-%d %H:%M:%S')}"
DRYRUN="${DRYRUN:-0}"   # set to 1 or pass -n to simulate rsync

# --- Flags ---
if [[ "${1:-}" == "-n" || "${2:-}" == "-n" ]]; then
  DRYRUN=1
fi

echo "== Lyceum Vault: publish & backup =="
echo "SRC:   $SRC_DIR"
echo "DEST:  $DEST_DIR"
echo "BRANCH: $BRANCH"
echo

# --- Preflight checks ---
[[ -d "$SRC_DIR" ]] || { echo "❌ SRC_DIR not found: $SRC_DIR"; exit 1; }
[[ -d "$DEST_DIR" ]] || mkdir -p "$DEST_DIR"

# Ensure we’re inside the repo for git/mkdocs
cd "$SRC_DIR"

# --- 1) Validate build ---
echo "→ Building with mkdocs (strict)…"
mkdocs build --strict

# --- 2) Commit & push ---
echo "→ Checking for changes to commit…"
if ! git diff --quiet || ! git diff --cached --quiet; then
  git add -A
  git commit -m "$COMMIT_MSG"
else
  echo "No working tree changes to commit."
fi

echo "→ Pushing to origin/$BRANCH…"
git push origin "$BRANCH"

# --- 3) Rsync backup to Samba share ---
echo "→ Backing up to $DEST_DIR (rsync)…"
LOG="/tmp/rsync_lyceumvault_$(date +%F_%H%M%S).log"
RSYNC_FLAGS="-avh --delete --progress --exclude .git/ --exclude site/"
if [[ "$DRYRUN" -eq 1 ]]; then
  RSYNC_FLAGS="--dry-run $RSYNC_FLAGS"
  echo "(dry run)"
fi

rsync $RSYNC_FLAGS "$SRC_DIR"/ "$DEST_DIR"/ | tee "$LOG"

echo
echo "✅ Done. Log: $LOG"

