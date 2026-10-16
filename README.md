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
scripts/
  bump.sh                bump a skill's version and log the release
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

Every skill is versioned on its own. Skills are instructions rather than code,
so apply SemVer like this:

| Bump    | When to use it                                                                                              |
| ------- | ----------------------------------------------------------------------------------------------------------- |
| `major` | The skill behaves incompatibly with how it used to (different output, removed behavior, changed interface). |
| `minor` | New capabilities, guidance or options are added without breaking existing use.                              |
| `patch` | Fixes, clarifications, typos and other changes that don't alter intent.                                     |

New skills start at `0.1.0`; promote to `1.0.0` when you consider the skill
stable. A release is complete when the version is bumped, the change is
described in `RELEASE_NOTES.md`, and the release is tagged
`<skill-name>@v<version>`.

## Adding a skill

1. Copy `templates/SKILL.md` to `skills/<skill-name>/SKILL.md`.
2. Set `name` to the folder name and write the `description` and instructions.
3. Leave `version` at `0.1.0`.
4. Commit.

## Releasing a skill

```bash
scripts/bump.sh <skill-name> patch            # 0.1.0 -> 0.1.1
scripts/bump.sh <skill-name> minor --tag      # 0.1.1 -> 0.2.0, tag it
scripts/bump.sh <skill-name> --set 1.0.0 --tag --yes
scripts/bump.sh <skill-name> --current        # print the current version
```

`bump.sh` updates `version` in the skill's `SKILL.md`, adds a dated section to
`RELEASE_NOTES.md`, and, with `--tag`, creates the `<skill-name>@v<version>`
git tag. Use `--dry-run` to preview.

After bumping, describe the changes under the new heading in `RELEASE_NOTES.md`
and commit.

## Installing a skill

Link a skill into your agent's skills directory, for example:

```bash
ln -s "$PWD/skills/<skill-name>" ~/.agents/skills/<skill-name>
```
