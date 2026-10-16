---
name: versioning
description: >-
  Standard for versioning and releasing any repository. Use when choosing a
  version number, cutting a release, writing or maintaining a changelog or
  release notes, tagging releases, or introducing versioning to a new project.
  Standardizes on Semantic Versioning (SemVer) for version numbers and Keep a
  Changelog for release notes.
---

# Versioning

Apply this standard whenever a repository needs version numbers or release
notes. Two specifications define it:

- **Versions** follow [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html) — `MAJOR.MINOR.PATCH`.
- **Release notes** follow [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/), kept in `CHANGELOG.md` (or `RELEASE_NOTES.md`).

Do not invent a different scheme. If a project already uses one, migrate it to
this standard instead of layering a second convention on top.

## 1. One version, one source of truth

A repository has a single version, recorded in exactly one place:

| Project type | Source of truth |
| --- | --- |
| Library or application | the version field of the package manifest (`package.json`, `pyproject.toml`, `Cargo.toml`, `pom.xml`, `go.mod`, …) |
| Project without a manifest | a `VERSION` file at the repository root |

Rules:

- Never duplicate the version in several places. If other files must show it, generate or sync them from the source.
- Components inside the repository — packages in a monorepo, plugins, skills, templates — are not versioned separately. The repository version covers all of them, and every change to them is described in the changelog.
- A new project starts at `0.1.0`. Reach `1.0.0` only once the public surface is stable.

## 2. Decide the next version

Given the current version `MAJOR.MINOR.PATCH`, increment by the most significant
change in the release:

| Bump | Result | When |
| --- | --- | --- |
| **MAJOR** | `X+1.0.0` | Incompatible change to the public surface: removed or renamed API, changed output format, changed behavior consumers rely on, removed configuration. Also: removing a component, or a component's breaking change. |
| **MINOR** | `X.Y+1.0` | Backward-compatible addition: new feature, option, endpoint, or component. Also: adding a component, or a component's backward-compatible feature. |
| **PATCH** | `X.Y.Z+1` | Backward-compatible fix: bug fix, performance, documentation, internal refactor, dependency bump. |

Guidance:

- A change is breaking if existing users must change how they use the project. When unsure, ask what a user has to do differently; if the answer is "nothing", it is not MAJOR.
- The version is the summary of the release: take the highest bump among all the changes it contains. A component addition and a component fix in the same release is a MINOR.
- **Before `1.0.0`** (`0.y.z`) the public surface is not stable. Increment MINOR for breaking changes and PATCH for everything else. Treat `0.1.0 → 0.2.0` as the breaking signal, not `1.0.0 → 2.0.0`.
- Bump exactly once per release, right before releasing. Never reuse, skip, or move a released version.
- Pre-releases use SemVer pre-release identifiers: `1.0.0-alpha.1`, `1.0.0-rc.2`. Build metadata (`+build.5`) never affects precedence.

## 3. Maintain one changelog

Keep one changelog at the repository root, keyed by the project version. Choose
`CHANGELOG.md` or `RELEASE_NOTES.md`, then use that name everywhere. Its shape:

```markdown
# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- ...

## [1.4.0] - 2026-10-16

### Added

- ...
```

Rules:

- Always keep an `## [Unreleased]` section at the top, and add changes to it as work lands.
- Group entries under `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`. Use only the sections that have content; never leave an empty section.
- Write for humans: one bullet per notable change, describing the effect, not the commit hash or raw diff.
- Name the component a change touches, e.g. ``Added the `foo` skill.``, ``Fixed `bar`: …``.
- The latest version goes first; order is reverse chronological.
- Date each release as ISO 8601 (`YYYY-MM-DD`).
- Call out breaking changes, deprecations, and removals explicitly — those are the entries consumers must see.
- Keep it curated. Exclude internal noise (comment typos, merge commits, CI churn) unless it matters to users.
- Keep yanked releases listed and marked, e.g. `## [1.2.3] - 2026-10-16 [YANKED]`.
- Optionally link each version to its tag or compare URL at the bottom of the file.

## 4. Release checklist

Run these steps in order for every release:

1. Confirm the working tree is clean and you are on the release branch.
2. Decide the bump (section 2) from the changes since the last release.
3. Apply the new version to the source of truth (section 1) and sync any generated copies.
4. In the changelog, rename `## [Unreleased]` to `## [<version>] - <today>`, then open a fresh empty `## [Unreleased]` above it.
5. Commit with a conventional release message, e.g. `chore(release): <version>`.
6. Tag the commit (section 5).
7. Push the commit and the tag.
8. If the project publishes artifacts, publish them from the tagged commit.

## 5. Tag releases

Tags are the immutable record of a release and must point at the released
commit. Use `v<version>`, e.g. `v1.4.0`.

```bash
git tag -a v1.4.0 -m "Release 1.4.0"
git push origin v1.4.0
```

- Use annotated tags (`-a`) so the tag carries a message and date.
- Tag only after the version bump and changelog update are committed.
- Never move, overwrite, or reuse a tag. To correct a bad release, publish a new patch version and mark the old one `[YANKED]`.

## 6. Rules that prevent pain

- One version, one source of truth, one changelog, one tagging scheme.
- Update the changelog in the change that introduces the work, or at the latest before the release — never reconstruct it later from `git log`.
- Do not let `git log` be the changelog.
- A version number means the same thing to every consumer: incompatible → MAJOR, additive → MINOR, fix → PATCH.
