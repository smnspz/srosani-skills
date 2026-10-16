---
name: versioning
description: >-
  Standard for versioning and releasing any repository. Use when choosing a
  version number, cutting a release, writing or maintaining a changelog or
  release notes, tagging releases, or introducing versioning to a new project.
  Standardizes on Semantic Versioning (SemVer) for version numbers and Keep a
  Changelog for release notes.
version: 0.2.0
---

# Versioning

Apply this standard whenever a repository needs version numbers or release
notes. Two specifications define it:

- **Versions** follow [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html) — `MAJOR.MINOR.PATCH`.
- **Release notes** follow [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/), kept in `CHANGELOG.md` (or `RELEASE_NOTES.md`).

Do not invent a different scheme. If a project already uses one, migrate it to
this standard instead of layering a second convention on top.

## 1. Choose a single source of truth per versioned unit

A *versioned unit* is anything released on its own. Every unit has exactly one
place that records its current version. Pick the one that fits the unit, and
only that one:

| Unit | Source of truth |
| --- | --- |
| Library or application | the version field of the package manifest (`package.json`, `pyproject.toml`, `Cargo.toml`, `pom.xml`, `go.mod`, …) |
| Project without a manifest | a `VERSION` file at the repository root |
| Repository released as a collection | a `VERSION` file at the repository root, tracking the collection as a whole |
| Artifact released independently inside a repository (monorepo, plugin or skill collection) | one version per artifact, stored next to that artifact |

Rules:

- Never duplicate a unit's version in several places. If other files must show it, generate or sync them from the source.
- A repository can be a unit *and* contain units. A collection may have its own repository version (root `VERSION`) while each artifact keeps its own version. The repository version tracks the collection; the artifact versions track the artifacts. That is two levels, not duplication.
- If artifacts are released independently, each gets its own version and its own changelog (see section 3). Do not force a single repository-wide number on them.
- A new project or artifact starts at `0.1.0`. Reach `1.0.0` only once the public surface is stable.

## 2. Decide the next version

Given a unit's current version `MAJOR.MINOR.PATCH`, increment:

| Bump | Result | When |
| --- | --- | --- |
| **MAJOR** | `X+1.0.0` | Incompatible change to the public surface: removed or renamed API, changed output format, changed behavior consumers rely on, removed configuration. |
| **MINOR** | `X.Y+1.0` | Backward-compatible addition: new feature, option, endpoint, or artifact. |
| **PATCH** | `X.Y.Z+1` | Backward-compatible fix: bug fix, performance, documentation, internal refactor, dependency bump. |

Guidance:

- A change is breaking if existing users must change how they use the unit. When unsure, ask what a user has to do differently; if the answer is "nothing", it is not MAJOR.
- **Before `1.0.0`** (`0.y.z`) the public surface is not stable. Increment MINOR for breaking changes and PATCH for everything else. Treat `0.1.0 → 0.2.0` as the breaking signal, not `1.0.0 → 2.0.0`.
- Bump exactly once per release, right before releasing. Never reuse, skip, or move a released version.
- Pre-releases use SemVer pre-release identifiers: `1.0.0-alpha.1`, `1.0.0-rc.2`. Build metadata (`+build.5`) never affects precedence.

### Versioning a collection

When a repository is released as a collection, its version follows the most
significant change in the release, across all of its artifacts:

- Removing an artifact, or any artifact's breaking change → **MAJOR**
- Adding an artifact, or any artifact's backward-compatible feature → **MINOR**
- Only fixes and non-behavioral changes → **PATCH**

Each artifact still bumps its own version independently; the repository version
is the collection's summary of the release.

## 3. Maintain a changelog per versioned unit

Every versioned unit keeps its own changelog as `CHANGELOG.md`, keyed by that
unit's version and kept next to the unit:

- Repository as a single unit → one root `CHANGELOG.md`.
- Repository released as a collection → a root changelog keyed by the repository version, plus a `CHANGELOG.md` inside each artifact keyed by the artifact version.

A root changelog may be named `RELEASE_NOTES.md` instead; pick one name and keep
it consistent. Changelogs for different units are expected, not duplication —
never keep two changelogs for the same unit.

Shape:

```markdown
# Changelog

All notable changes to <unit> are documented in this file.

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
- The latest version goes first; order is reverse chronological.
- Date each release as ISO 8601 (`YYYY-MM-DD`).
- Call out breaking changes, deprecations, and removals explicitly — those are the entries consumers must see.
- Keep it curated. Exclude internal noise (comment typos, merge commits, CI churn) unless it matters to users.
- Keep yanked releases listed and marked, e.g. `## [1.2.3] - 2026-10-16 [YANKED]`.
- In a collection's root changelog, name the artifact and its version in the entry, e.g. ``Added the `foo` skill (0.1.0).``
- If a single changelog must cover several artifacts that have no repository version, prefix each heading with the artifact name: `## [<artifact> <version>] - <date>`.
- Optionally link each version to its tag or compare URL at the bottom of the file.

## 4. Release checklist

Run these steps in order for every release:

1. Confirm the working tree is clean and you are on the release branch.
2. Decide the bump for every changed unit (section 2) from the changes since its last release. For a collection, also bump the repository version by the most significant change.
3. Apply each new version to its source of truth (section 1) and sync any generated copies.
4. In each changed unit's changelog, rename `## [Unreleased]` to `## [<version>] - <today>`, then open a fresh empty `## [Unreleased]` above it. Do the same in the root changelog with the repository version.
5. Commit with a conventional release message, e.g. `chore(release): <version>`.
6. Tag the commit (section 5).
7. Push the commit and the tag.
8. If the project publishes artifacts, publish them from the tagged commit.

## 5. Tag releases

Tags are the immutable record of a release and must point at the released
commit.

- Repository release: `v<version>`, e.g. `v1.4.0`.
- Independently released artifact in a shared repository: `<artifact>@v<version>` or `<artifact>/v<version>`, used consistently.

A collection may use both: `v1.4.0` for the repository and `foo@v0.3.0` for each
artifact released in it.

```bash
git tag -a v1.4.0 -m "Release 1.4.0"
git push origin v1.4.0
```

- Use annotated tags (`-a`) so the tag carries a message and date.
- Tag only after the version bump and changelog update are committed.
- Never move, overwrite, or reuse a tag. To correct a bad release, publish a new patch version and mark the old one `[YANKED]`.

## 6. Rules that prevent pain

- One source of truth per versioned unit, one changelog per versioned unit, one tagging scheme.
- A collection's repository version tracks the collection; each artifact's version tracks that artifact.
- Update the changelog in the change that introduces the work, or at the latest before the release — never reconstruct it later from `git log`.
- Do not let `git log` be the changelog.
- A version number means the same thing to every consumer: incompatible → MAJOR, additive → MINOR, fix → PATCH.
