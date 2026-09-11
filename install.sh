#!/usr/bin/env bash
#
# Symlinks every skill in this repo into Claude Code and/or Codex.
# The repo stays the source of truth; edits in either location are the same file.
#
# Usage:
#   ./install.sh                          Install for Claude Code and Codex
#   ./install.sh --target codex           Install only for Codex
#   ./install.sh --target claude --force  Replace collisions after backing them up

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$REPO_DIR/skills"
FORCE=0
TARGET="all"
SKILL=""

usage() {
  cat <<'EOF'
Usage: ./install.sh [--target claude|codex|all] [--skill NAME] [--force]

Targets:
  all      Install into ~/.claude/skills and ~/.codex/skills (default)
  claude   Install only into ~/.claude/skills
  codex    Install only into ~/.codex/skills

Options:
  -s, --skill NAME  Install only this skill directory (default: all skills)
  --force  Back up and replace real files or directories that collide
  -h, --help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--skill|--skill=*)
      if [[ -n "$SKILL" ]]; then
        echo "error: --skill can only be specified once" >&2
        exit 2
      fi
      if [[ "$1" == --skill=* ]]; then
        SKILL="${1#*=}"
        shift
      else
        if [[ $# -lt 2 ]]; then
          echo "error: --skill requires a skill directory name" >&2
          exit 2
        fi
        SKILL="$2"
        shift 2
      fi
      if [[ ! "$SKILL" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
        echo "error: invalid skill name '$SKILL'; expected a kebab-case directory name" >&2
        exit 2
      fi
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --target)
      if [[ $# -lt 2 ]]; then
        echo "error: --target requires claude, codex, or all" >&2
        exit 2
      fi
      TARGET="$2"
      shift 2
      ;;
    --target=*)
      TARGET="${1#*=}"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$TARGET" in
  all)
    runtimes=("Claude Code" "Codex")
    dest_dirs=("$HOME/.claude/skills" "$HOME/.codex/skills")
    ;;
  claude)
    runtimes=("Claude Code")
    dest_dirs=("$HOME/.claude/skills")
    ;;
  codex)
    runtimes=("Codex")
    dest_dirs=("$HOME/.codex/skills")
    ;;
  *)
    echo "error: invalid target '$TARGET'; expected claude, codex, or all" >&2
    exit 2
    ;;
esac

if [[ ! -d "$SRC_DIR" ]]; then
  echo "error: no skills/ directory at $SRC_DIR" >&2
  exit 1
fi

# Without nullglob an empty skills/ leaves the glob unexpanded and we would link a
# directory literally named "*" into the destination.
if [[ -n "$SKILL" ]]; then
  if [[ ! -f "$SRC_DIR/$SKILL/SKILL.md" ]]; then
    echo "error: unknown or invalid skill '$SKILL'; expected skills/$SKILL/SKILL.md" >&2
    exit 2
  fi
  skill_dirs=("$SRC_DIR/$SKILL/")
else
  shopt -s nullglob
  skill_dirs=("$SRC_DIR"/*/)
  shopt -u nullglob
fi

if [[ ${#skill_dirs[@]} -eq 0 ]]; then
  echo "error: no skills found in $SRC_DIR" >&2
  exit 1
fi

total_linked=0
total_skipped=0
total_replaced=0

install_destination() {
  local runtime="$1"
  local dest_dir="$2"
  local linked=0
  local skipped=0
  local replaced=0
  local dangling
  local src name dest backup

  mkdir -p "$dest_dir"
  echo
  echo "$runtime → $dest_dir"

  for src in "${skill_dirs[@]}"; do
    name="$(basename "$src")"
    dest="$dest_dir/$name"
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

    # A real path holds content this repo may not have. Never delete it silently.
    if [[ -e "$dest" ]]; then
      if [[ $FORCE -eq 1 ]]; then
        backup="$dest.backup.$(date +%Y%m%d%H%M%S)"
        echo "  replace  $name (existing path moved to $(basename "$backup"))"
        mv "$dest" "$backup"
        ln -s "$src" "$dest"
        replaced=$((replaced + 1))
      else
        echo "  SKIP     $name — a real path already exists there. Re-run with --force to replace it." >&2
        skipped=$((skipped + 1))
      fi
      continue
    fi

    echo "  link     $name"
    ln -s "$src" "$dest"
    linked=$((linked + 1))
  done

  echo "  linked: $linked  repointed/replaced: $replaced  skipped: $skipped"

  # Dangling symlinks are usually leftovers from a previous layout.
  dangling=$(find "$dest_dir" -maxdepth 1 -type l ! -exec test -e {} \; -print 2>/dev/null || true)
  if [[ -n "$dangling" ]]; then
    echo
    echo "warning: dangling symlinks found in $dest_dir (targets no longer exist):"
    while IFS= read -r link; do
      printf '  %s\n' "$link"
    done <<< "$dangling"
    echo "remove them with: find \"$dest_dir\" -maxdepth 1 -type l ! -exec test -e {} \\; -delete"
  fi

  total_linked=$((total_linked + linked))
  total_replaced=$((total_replaced + replaced))
  total_skipped=$((total_skipped + skipped))
}

for index in "${!dest_dirs[@]}"; do
  install_destination "${runtimes[$index]}" "${dest_dirs[$index]}"
done

echo
echo "Done. linked: $total_linked  repointed/replaced: $total_replaced  skipped: $total_skipped"
echo "This workflow has no MCP-server or third-party-skill dependencies."

# Skips mean the install is incomplete — don't let a caller chained with && treat that as success.
if [[ $total_skipped -gt 0 ]]; then
  exit 1
fi
