#!/usr/bin/env bash
#
# install - symlink every skill in this repository into a coding agent's
# skills directory.
#
# Usage:
#   scripts/install.sh <agent>
#   scripts/install.sh help

set -euo pipefail

readonly SCRIPT_NAME="$(basename -- "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# The skills live at the repository root, one level up from this script.
readonly REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
readonly SKILLS_DIR="$REPO_ROOT/skills"

# resolve_agent_dir <agent>
# Print the destination skills directory for the given agent, or return 1 when
# the agent is not supported.
resolve_agent_dir() {
  case "$1" in
    # The global OpenCode skills directory. Note that OpenCode also reads
    # ~/.claude/skills for compatibility, so "claude" works for both agents.
    opencode) printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills" ;;
    claude) printf '%s\n' "$HOME/.claude/skills" ;;
    *) return 1 ;;
  esac
}

# usage
# Print the help text with usage and an example.
usage() {
  cat <<EOF
Symlink every skill in this repository into a coding agent's skills directory.

Usage:
  $SCRIPT_NAME <agent>
  $SCRIPT_NAME help

Agents:
  opencode   ${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills
  claude     $HOME/.claude/skills

The skills live in:
  $SKILLS_DIR

Existing symlinks are refreshed; real files or directories are left untouched.

Examples:
  $SCRIPT_NAME opencode     # link every skill into OpenCode
  $SCRIPT_NAME claude       # link every skill into Claude Code
EOF
}

# link_skills <dest_dir>
# Symlink every entry in SKILLS_DIR into dest_dir, refreshing stale symlinks.
link_skills() {
  local dest_dir="$1"
  local src name target linked=0 skipped=0

  if [ ! -d "$SKILLS_DIR" ]; then
    printf 'error: skills directory not found: %s\n' "$SKILLS_DIR" >&2
    exit 1
  fi

  mkdir -p -- "$dest_dir"

  for src in "$SKILLS_DIR"/*; do
    name="$(basename -- "$src")"
    target="$dest_dir/$name"

    if [ -L "$target" ]; then
      # Already linked here? Keep it. Otherwise replace the stale link.
      if [ "$(readlink -- "$target")" = "$src" ]; then
        printf 'ok       %s\n' "$name"
        linked=$((linked + 1))
        continue
      fi
      rm -- "$target"
    elif [ -e "$target" ]; then
      printf 'skipped  %s (exists and is not a symlink)\n' "$name" >&2
      skipped=$((skipped + 1))
      continue
    fi

    ln -s -- "$src" "$target"
    printf 'linked   %s -> %s\n' "$name" "$target"
    linked=$((linked + 1))
  done

  printf '\n%s: %d linked, %d skipped in %s\n' "$SCRIPT_NAME" "$linked" "$skipped" "$dest_dir"
}

main() {
  local agent="${1:-}"
  local dest_dir

  if [ "$#" -gt 1 ]; then
    printf 'error: too many arguments\n\n' >&2
    usage >&2
    exit 2
  fi

  case "$agent" in
    "")
      usage >&2
      exit 1
      ;;
    help|-h|--help)
      usage
      ;;
    *)
      if ! dest_dir="$(resolve_agent_dir "$agent")"; then
        printf 'error: unknown agent "%s"\n\n' "$agent" >&2
        usage >&2
        exit 2
      fi
      link_skills "$dest_dir"
      ;;
  esac
}

main "$@"
