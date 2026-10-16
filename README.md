# Skills

A collection of my personal agent skills. Each skill is a self-contained folder
and is versioned independently with
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Layout

```
skills/                  one folder per skill
  <skill-name>/
    SKILL.md             skill definition; frontmatter holds its version
templates/
  SKILL.md               starting point for a new skill
RELEASE_NOTES.md         release history (Keep a Changelog format)
```

## Anatomy of a skill

A skill lives in `skills/<skill-name>/` and is defined by a `SKILL.md` with YAML
frontmatter:

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
- `version` — the skill's own semantic version. This is the single source of
  truth for that skill; nothing else tracks it.

## Versioning

Every skill is versioned on its own. This repository follows the `versioning`
skill ([`skills/versioning/SKILL.md`](skills/versioning/SKILL.md)), which makes
[Semantic Versioning](https://semver.org/spec/v2.0.0.html) and
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) the standard.

In short:

- The `version` field in a skill's `SKILL.md` frontmatter is the single source of truth.
- New skills start at `0.1.0`.
- Bump MAJOR for incompatible behavior, MINOR for additive changes, PATCH for fixes.
- Record the change under a dated heading in `RELEASE_NOTES.md`.
- Tag the release `<skill-name>@v<version>`.

## Adding a skill

1. Copy `templates/SKILL.md` to `skills/<skill-name>/SKILL.md`.
2. Set `name` to the folder name and write the `description` and instructions.
3. Leave `version` at `0.1.0`.
4. Commit.

## Releasing a skill

1. Choose the bump with the `versioning` skill.
2. Update `version` in the skill's `SKILL.md`.
3. Add a `## [<skill-name> <version>] - YYYY-MM-DD` section to `RELEASE_NOTES.md`
   describing the change.
4. Commit, then tag: `git tag -a <skill-name>@v<version> -m "<skill-name> <version>"`.

## Installing a skill

Link a skill into your agent's skills directory, for example:

```bash
ln -s "$PWD/skills/<skill-name>" ~/.agents/skills/<skill-name>
```
