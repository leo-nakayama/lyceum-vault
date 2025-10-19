#!/usr/bin/env bash
# simple_backup.sh
# 1) Rsync-mirrors repo to /mnt/share (excluding .git and site/)
set -euo pipefail

# --- Config ---
SRC_DIR="${SRC_DIR:-$HOME/Projects/leo-nakayama.github.io}"
DEST_DIR="${DEST_DIR:-/mnt/share/Projects/leo-nakayama.github.io_backup}"

echo "== Lyceum Vault: publish & backup =="
echo "SRC:   $SRC_DIR"
echo "DEST:  $DEST_DIR"

# --- Preflight checks ---
[[ -d "$SRC_DIR" ]] || { echo "❌ SRC_DIR not found: $SRC_DIR"; exit 1; }
[[ -d "$DEST_DIR" ]] || mkdir -p "$DEST_DIR"

# Ensure we’re inside the repo for git/mkdocs
cd "$SRC_DIR"

# --- 1) Rsync backup to Samba share ---
echo "→ Backing up to $DEST_DIR (rsync)…"
LOG="/tmp/rsync_lyceumvault_$(date +%F_%H%M%S).log"
RSYNC_FLAGS="-avh --delete --progress --exclude .git/ --exclude site/"

rsync $RSYNC_FLAGS "$SRC_DIR"/ "$DEST_DIR"/ | tee "$LOG"

echo
echo "✅ Done. Log: $LOG"

