
* Restores **from the Samba backup** to your **local working copy**
* Keeps your local `.git/` intact by default (so your repo config/history stays safe)
* Creates an automatic **pre-restore snapshot** of your local tree
* Supports **dry-run** and a **“full overwrite”** mode if you intentionally want to replace everything (rare)

---

### 📜 `scripts/restore_from_share.sh`

```bash
#!/usr/bin/env bash
# restore_from_share.sh
# Restore local Lyceum Vault working tree from Samba backup
# Default: preserve .git/ locally; mirror all other files from backup
set -euo pipefail

# --- Config ---
LOCAL_DIR="${LOCAL_DIR:-$HOME/Projects/leo-nakayama.github.io}"
BACKUP_DIR="${BACKUP_DIR:-/mnt/share/Projects/leo-nakayama.github.io_backup}"
PRESERVE_GIT="${PRESERVE_GIT:-1}"   # 1 = keep local .git, 0 = allow overwrite (if backup contains .git)
DRYRUN="${DRYRUN:-0}"               # 1 = simulate
SNAPSHOT_ROOT="${SNAPSHOT_ROOT:-$HOME/Projects/_snapshots}"

# --- Parse flags ---
# -n  dry-run
# -f  full overwrite (do not preserve .git)
while getopts ":nf" opt; do
  case $opt in
    n) DRYRUN=1 ;;
    f) PRESERVE_GIT=0 ;;
    *) ;;
  endac
done

echo "== Lyceum Vault: restore from backup =="
echo "Backup: $BACKUP_DIR"
echo "Local : $LOCAL_DIR"
echo "Preserve .git: $PRESERVE_GIT (1=yes, 0=no)"
echo "Dry run: $DRYRUN (1=yes, 0=no)"
echo

# --- Preflight checks ---
[[ -d "$BACKUP_DIR" ]] || { echo "❌ Backup dir not found: $BACKUP_DIR"; exit 1; }
[[ -d "$LOCAL_DIR" ]] || { echo "❌ Local dir not found:  $LOCAL_DIR"; exit 1; }

# Avoid catastrophes: ensure not root of filesystem
[[ "$LOCAL_DIR" != "/" ]] || { echo "❌ LOCAL_DIR cannot be /"; exit 1; }
[[ "$BACKUP_DIR" != "/" ]] || { echo "❌ BACKUP_DIR cannot be /"; exit 1; }

# Show a quick size & mount summary
echo "Mounts and free space:"
df -h "$BACKUP_DIR" "$LOCAL_DIR" || true
echo

# --- Create pre-restore snapshot of LOCAL_DIR ---
TS=$(date +%F_%H%M%S)
SNAP_DIR="${SNAPSHOT_ROOT}/leo-lyceum-${TS}"
echo "→ Creating pre-restore snapshot at: $SNAP_DIR"
mkdir -p "$SNAP_DIR"

RSYNC_SNAPSHOT_FLAGS="-aH --delete --exclude .git/ --exclude site/"
if [[ $DRYRUN -eq 1 ]]; then
  RSYNC_SNAPSHOT_FLAGS="--dry-run $RSYNC_SNAPSHOT_FLAGS"
fi

# Snapshot local working tree (without .git and site) so we can roll back if needed
rsync $RSYNC_SNAPSHOT_FLAGS "$LOCAL_DIR"/ "$SNAP_DIR"/

echo
echo "Snapshot complete (or simulated)."

# --- Confirm destructive restore ---
echo
read -rp "Proceed to restore LOCAL from BACKUP (this will overwrite local files)? [y/N] " ans
if [[ ! "$ans" =~ ^[yY]$ ]]; then
  echo "Aborted."
  exit 0
fi

# --- Build rsync flags for restore ---
RSYNC_FLAGS="-aH --delete --progress"
# By default, do NOT overwrite .git/ locally
if [[ $PRESERVE_GIT -eq 1 ]]; then
  RSYNC_FLAGS="$RSYNC_FLAGS --exclude .git/"
fi
# site/ is a build artifact; usually don’t restore it
RSYNC_FLAGS="$RSYNC_FLAGS --exclude site/"

if [[ $DRYRUN -eq 1 ]]; then
  RSYNC_FLAGS="--dry-run $RSYNC_FLAGS"
  echo "(dry run)"
fi

echo
echo "→ Restoring from $BACKUP_DIR to $LOCAL_DIR ..."
rsync $RSYNC_FLAGS "$BACKUP_DIR"/ "$LOCAL_DIR"/

echo
echo "✅ Restore complete."
echo "Pre-restore snapshot saved at: $SNAP_DIR"
echo "To inspect changes, you can diff:"
echo "  diff -ru \"$SNAP_DIR\" \"$LOCAL_DIR\" | less"
echo
echo "Tip: If something looks wrong, you can restore from snapshot back to local:"
echo "  rsync -aH --delete \"$SNAP_DIR\"/ \"$LOCAL_DIR\"/"
```

---

### 🔧 How to use

```bash
# Save the script
mkdir -p ~/Projects/leo-nakayama.github.io/scripts
nano ~/Projects/leo-nakayama.github.io/scripts/restore_from_share.sh
# paste the script, then:
chmod +x ~/Projects/leo-nakayama.github.io/scripts/restore_from_share.sh
```

Run it:

* **Standard restore (safe defaults)**

  ```bash
  ~/Projects/leo-nakayama.github.io/scripts/restore_from_share.sh
  ```

  Preserves your local `.git/` directory and mirrors everything else.

* **Dry-run (see what would change)**

  ```bash
  ~/Projects/leo-nakayama.github.io/scripts/restore_from_share.sh -n
  ```

* **Full overwrite (rare)**

  ```bash
  ~/Projects/leo-nakayama.github.io/scripts/restore_from_share.sh -f
  ```

  Allows `.git/` to be replaced *if the backup contains one* (yours doesn’t by default).

---

### 🧠 Why this layout works well

* Your **backup** excludes `.git/` and `site/`, so it’s a clean content mirror.
* Your **restore** keeps local Git history and CI/CD files intact.
* The **snapshot** gives you a quick undo path if you want to revert the restore.


