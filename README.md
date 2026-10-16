# Skills

A collection of my personal agent skills. The repository has its own version,
and every skill is also versioned on its own, both with
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Layout

```
VERSION                  repository version (source of truth for the collection)
<skill-name>/
  SKILL.md               skill definition; frontmatter holds its version
  CHANGELOG.md           that skill's release history (Keep a Changelog)
README.md
RELEASE_NOTES.md         repository changelog (Keep a Changelog)
```

## Anatomy of a skill

A skill lives in `<skill-name>/SKILL.md` at the repository root and is defined
by YAML frontmatter:

```markdown
---
name: skill-name
description: What the skill does and when to use it.
version: 0.1.0
---

# Skill name

Instructions for the agent...
```

- `name` — kebab-case, identical to the folder name.
- `description` — what the skill does and when it should trigger.
- `version` — the skill's own semantic version and single source of truth.

## Versioning

There are two levels:

- **Repository** — `VERSION` holds the collection's version. It is bumped by the
  most significant change in a release: adding a skill or a skill feature is
  MINOR, a skill breaking change or removing a skill is MAJOR, fixes are PATCH.
- **Skill** — the `version` field in each `SKILL.md` is that skill's own version.

Both use Semantic Versioning, and both histories use Keep a Changelog: the
repository's in `RELEASE_NOTES.md`, each skill's in its own `CHANGELOG.md`. This
repository follows the `versioning` skill
([`versioning/SKILL.md`](versioning/SKILL.md)).

## Adding a skill

1. Create `<skill-name>/SKILL.md` and `<skill-name>/CHANGELOG.md`.
2. In `SKILL.md`, add the frontmatter above: set `name` to the folder name,
   write the `description`, and start at `version: 0.1.0`.
3. In `CHANGELOG.md`, add the header, an `## [Unreleased]` section, and a
   `## [0.1.0] - YYYY-MM-DD` entry.
4. Bump `VERSION` (MINOR) and add an entry to `RELEASE_NOTES.md`.
5. Commit.

## Releasing a change

1. Choose the bumps with the `versioning` skill.
2. Update `version` in the skill's `SKILL.md` and `VERSION` at the root.
3. In the skill's `CHANGELOG.md`, rename `## [Unreleased]` to
   `## [<version>] - YYYY-MM-DD` and open a fresh `## [Unreleased]` above it.
4. Do the same in `RELEASE_NOTES.md` with the repository version.
5. Commit, then tag:
   `git tag -a <skill-name>@v<version> -m "<skill-name> <version>"` and
   `git tag -a v<version> -m "Release <version>"`.

## Installing a skill

Link a skill into your agent's skills directory, for example:

```bash
ln -s "$PWD/<skill-name>" ~/.agents/skills/<skill-name>
```
