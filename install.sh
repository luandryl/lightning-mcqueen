#!/usr/bin/env bash
#
# Symlinks every skill in this repo into ~/.claude/skills/.
# The repo stays the source of truth; edits in either location are the same file.
#
# Usage:
#   ./install.sh          Install, skipping anything already present that isn't ours
#   ./install.sh --force  Also replace real directories that collide (they are backed up)

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$REPO_DIR/skills"
DEST_DIR="$HOME/.claude/skills"
FORCE=0

if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
fi

if [[ ! -d "$SRC_DIR" ]]; then
  echo "error: no skills/ directory at $SRC_DIR" >&2
  exit 1
fi

# Without nullglob an empty skills/ leaves the glob unexpanded and we would link a
# directory literally named "*" into the destination.
shopt -s nullglob
skill_dirs=("$SRC_DIR"/*/)
shopt -u nullglob

if [[ ${#skill_dirs[@]} -eq 0 ]]; then
  echo "error: no skills found in $SRC_DIR" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"

linked=0
skipped=0
replaced=0

for src in "${skill_dirs[@]}"; do
  name="$(basename "$src")"
  dest="$DEST_DIR/$name"
  src="${src%/}"

  # Every skill needs a SKILL.md; linking anything else creates a broken skill.
  if [[ ! -f "$src/SKILL.md" ]]; then
    echo "  SKIP     $name — no SKILL.md, not a skill" >&2
    skipped=$((skipped + 1))
    continue
  fi

  # Already pointing at this repo — nothing to do. -ef compares resolved identity,
  # so a relative symlink to the same target is recognised too.
  if [[ -L "$dest" && "$dest" -ef "$src" ]]; then
    echo "  ok       $name (already linked)"
    continue
  fi

  # A symlink somewhere else (e.g. the old ~/.agents store) is safe to repoint.
  if [[ -L "$dest" ]]; then
    echo "  repoint  $name (was -> $(readlink "$dest"))"
    rm "$dest"
    ln -s "$src" "$dest"
    replaced=$((replaced + 1))
    continue
  fi

  # A real directory holds content this repo may not have. Never delete it silently.
  if [[ -e "$dest" ]]; then
    if [[ $FORCE -eq 1 ]]; then
      backup="$dest.backup.$(date +%Y%m%d%H%M%S)"
      echo "  replace  $name (existing directory moved to $(basename "$backup"))"
      mv "$dest" "$backup"
      ln -s "$src" "$dest"
      replaced=$((replaced + 1))
    else
      echo "  SKIP     $name — a real directory already exists there. Re-run with --force to replace it." >&2
      skipped=$((skipped + 1))
    fi
    continue
  fi

  echo "  link     $name"
  ln -s "$src" "$dest"
  linked=$((linked + 1))
done

echo
echo "linked: $linked  repointed/replaced: $replaced  skipped: $skipped"

# Dangling symlinks in the destination are usually leftovers from a previous layout.
dangling=$(find "$DEST_DIR" -maxdepth 1 -type l ! -exec test -e {} \; -print 2>/dev/null || true)
if [[ -n "$dangling" ]]; then
  echo
  echo "warning: dangling symlinks found in $DEST_DIR (targets no longer exist):"
  while IFS= read -r link; do
    printf '  %s\n' "$link"
  done <<< "$dangling"
  echo "remove them with: find \"$DEST_DIR\" -maxdepth 1 -type l ! -exec test -e {} \\; -delete"
fi

echo
echo "Done. This workflow has no MCP-server or third-party-skill dependencies."

# Skips mean the install is incomplete — don't let a caller chained with && treat that as success.
if [[ $skipped -gt 0 ]]; then
  exit 1
fi
