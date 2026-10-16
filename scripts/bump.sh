#!/usr/bin/env bash
#
# Release a single skill: bump its semantic version, record the change in
# RELEASE_NOTES.md, and optionally tag the release.
#
# The version lives in the skill's own SKILL.md frontmatter, so every skill is
# versioned independently.
#
# Usage:
#   scripts/bump.sh <skill> major|minor|patch [options]
#   scripts/bump.sh <skill> --set <x.y.z>    [options]
#   scripts/bump.sh <skill> --current
#
# Options:
#   --set <x.y.z>   set an explicit version instead of bumping
#   --current       print the skill's current version and exit
#   --tag           create the git tag <skill>@v<version>
#   --yes, -y       skip the confirmation prompt
#   --dry-run       show what would change without writing anything
#   --help, -h      show this help
#
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_dir="$repo_root/skills"
notes_file="$repo_root/RELEASE_NOTES.md"

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }
note() { printf '  %s\n' "$*"; }
warn() { printf '\033[33m!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[31m✗\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Release a single skill: bump its semantic version, record the change in
RELEASE_NOTES.md, and optionally tag the release.

Usage:
  scripts/bump.sh <skill> major|minor|patch [options]
  scripts/bump.sh <skill> --set <x.y.z>    [options]
  scripts/bump.sh <skill> --current

Options:
  --set <x.y.z>   set an explicit version instead of bumping
  --current       print the skill's current version and exit
  --tag           create the git tag <skill>@v<version>
  --yes, -y       skip the confirmation prompt
  --dry-run       show what would change without writing anything
  --help, -h      show this help

Examples:
  scripts/bump.sh code-review patch
  scripts/bump.sh code-review minor --tag
  scripts/bump.sh code-review --set 1.0.0 --tag --yes
EOF
  exit 0
}

# ── read the `version:` field from a SKILL.md frontmatter ─────────────────────
read_version() {
  awk '
    /^---[[:space:]]*$/ { fm++; next }
    fm == 1 && /^version:[[:space:]]*/ {
      sub(/^version:[[:space:]]*/, "")
      gsub(/[[:space:]]+$/, "")
      print
      exit
    }
    fm == 2 { exit }
  ' "$1"
}

# ── replace the `version:` field in a SKILL.md frontmatter ────────────────────
write_version() {
  local file="$1" version="$2" tmp
  tmp="$(mktemp)"
  awk -v version="$version" '
    /^---[[:space:]]*$/ { fm++ }
    fm == 1 && !done && /^version:[[:space:]]*/ {
      print "version: " version
      done = 1
      next
    }
    { print }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

# ── insert a dated release heading into RELEASE_NOTES.md (newest first) ───────
add_release_note() {
  local file="$1" heading="$2" tmp
  [[ -f "$file" ]] || die "Missing $(basename "$file")"
  tmp="$(mktemp)"
  awk -v heading="$heading" '
    function emit() {
      if (last != "") print ""
      print heading
      print ""
      print "<!-- Describe the notable changes in this release. -->"
      print ""
      last = ""
    }
    { line[NR] = $0 }
    END {
      target = NR + 1
      for (i = 1; i <= NR; i++)
        if (line[i] ~ /^## \[Unreleased\]/) { unrel = i; break }
      if (unrel)
        for (i = unrel + 1; i <= NR; i++)
          if (line[i] ~ /^## \[/) { target = i; break }

      for (i = 1; i <= NR; i++) {
        if (i == target) emit()
        print line[i]
        last = line[i]
      }
      if (target == NR + 1) emit()
    }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

# ── parse arguments ───────────────────────────────────────────────────────────
skill=""
action=""
explicit=""
do_tag=false
assume_yes=false
dry_run=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    major|minor|patch) action="$1"; shift ;;
    --set)     explicit="${2:-}"; shift 2 ;;
    --current) action="current"; shift ;;
    --tag)     do_tag=true; shift ;;
    --yes|-y)  assume_yes=true; shift ;;
    --dry-run) dry_run=true; shift ;;
    --help|-h) usage ;;
    -*)        die "Unknown option: $1 (try --help)" ;;
    *)
      [[ -z "$skill" ]] || die "Unexpected argument: $1"
      skill="$1"; shift ;;
  esac
done

[[ -n "$skill" ]] || die "Missing skill name (try --help)"

skill_file="$skills_dir/$skill/SKILL.md"
[[ -f "$skill_file" ]] || die "No such skill: $skill (expected $skill_file)"

# ── work out the new version ──────────────────────────────────────────────────
current="$(read_version "$skill_file")"
[[ -n "$current" ]] || die "No 'version:' field in skills/$skill/SKILL.md"
[[ "$current" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "Invalid version: $current"

if [[ "$action" == "current" ]]; then
  printf '%s\n' "$current"
  exit 0
fi

if [[ -n "$explicit" ]]; then
  [[ "$explicit" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "--set expects x.y.z (got: $explicit)"
  new="$explicit"
elif [[ -n "$action" ]]; then
  IFS='.' read -r major minor patch <<< "$current"
  case "$action" in
    major) major=$((major + 1)); minor=0; patch=0 ;;
    minor) minor=$((minor + 1)); patch=0 ;;
    patch) patch=$((patch + 1)) ;;
  esac
  new="$major.$minor.$patch"
else
  die "Nothing to do: give major|minor|patch or --set x.y.z (try --help)"
fi

[[ "$new" != "$current" ]] || die "New version equals current version ($current)"

tag="$skill@v$new"
heading="## [$skill $new] - $(date +%F)"

# ── guard: refuse to reuse an existing tag ────────────────────────────────────
if [[ "$do_tag" == true ]] && git -C "$repo_root" rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
  die "Tag already exists: $tag"
fi

bold "Release $skill: $current -> $new"
[[ "$do_tag" == true ]] && note "tag: $tag"

if [[ "$dry_run" == true ]]; then
  warn "Dry run: nothing was written"
  exit 0
fi

# ── apply the bump ────────────────────────────────────────────────────────────
write_version "$skill_file" "$new"
ok "skills/$skill/SKILL.md -> version $new"

add_release_note "$notes_file" "$heading"
ok "RELEASE_NOTES.md -> $heading"

# ── optionally tag the release ────────────────────────────────────────────────
if [[ "$do_tag" == true ]]; then
  if [[ "$assume_yes" != true ]]; then
    read -r -p "Create tag $tag? [y/N] " reply
    case "$reply" in
      [yY]|[yY][eE][sS]) ;;
      *) warn "Tag skipped. Create it later with: git tag -a '$tag' -m '$skill $new'"
         exit 0 ;;
    esac
  fi
  if ! git -C "$repo_root" rev-parse -q --verify HEAD >/dev/null; then
    warn "Cannot tag yet: the repository has no commits."
    note "Commit first, then run: git tag -a '$tag' -m '$skill $new'"
    exit 0
  fi
  git -C "$repo_root" tag -a "$tag" -m "$skill $new"
  ok "Tagged $tag"
fi

printf '\n'
note "Next: describe the changes under the new heading in RELEASE_NOTES.md, then commit."
