# Skills

A collection of my personal agent skills, versioned as a single repository with
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Layout

```
VERSION                    repository version (single source of truth)
<skill-name>/
  SKILL.md                 skill definition
README.md
RELEASE_NOTES.md           changelog for every skill change (Keep a Changelog)
vendor/
  mattpocock-skills/       git submodule: github.com/mattpocock/skills (MIT)
grilling                   symlink -> vendor/mattpocock-skills/skills/productivity/grilling
```

## Anatomy of a skill

A skill lives in `<skill-name>/SKILL.md` at the repository root and is defined
by YAML frontmatter:

```markdown
---
name: skill-name
description: What the skill does and when to use it.
---

# Skill name

Instructions for the agent...
```

- `name` — kebab-case, identical to the folder name.
- `description` — what the skill does and when it should trigger.

## Third-party skills

Skills not authored here are vendored as git submodules under `vendor/` and
exposed at the top level with a symlink, so they look like any other
`<skill-name>/SKILL.md`.

| Skill | Source | License |
| --- | --- | --- |
| `grilling` | [mattpocock/skills](https://github.com/mattpocock/skills) | MIT |

After cloning, initialise the submodules:

```bash
git submodule update --init --recursive
```

Update a vendored skill to the latest upstream commit:

```bash
git submodule update --remote vendor/mattpocock-skills
```

## Versioning

The repository has a single version in `VERSION`. Skills are not versioned
individually; every skill change is described in `RELEASE_NOTES.md` and rolled
into the repository version by the most significant change in the release:

- adding a skill, or a skill's backward-compatible feature → MINOR
- removing a skill, or a skill's breaking change → MAJOR
- fixes only → PATCH

Both the version and the changelog follow the `versioning` skill
([`versioning/SKILL.md`](versioning/SKILL.md)): Semantic Versioning and Keep a
Changelog.

## Adding a skill

1. Create `<skill-name>/SKILL.md` with the frontmatter above.
2. Write the instructions.
3. Bump `VERSION` (MINOR) and add an entry to `RELEASE_NOTES.md`.
4. Commit.

## Releasing a change

1. Choose the bump with the `versioning` skill.
2. Update `VERSION`.
3. In `RELEASE_NOTES.md`, rename `## [Unreleased]` to
   `## [<version>] - YYYY-MM-DD` and open a fresh `## [Unreleased]` above it.
4. Commit, then tag: `git tag -a v<version> -m "Release <version>"`.

## Installing a skill

Link a skill into your agent's skills directory, for example:

```bash
ln -s "$PWD/<skill-name>" ~/.agents/skills/<skill-name>
```
