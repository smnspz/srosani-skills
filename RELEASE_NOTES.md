# Release Notes

All notable changes to this repository are documented in this file. The format
is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Every skill change is described here. The repository version follows the most
significant change in a release: adding a skill or a skill feature is MINOR, a
skill breaking change or a skill removal is MAJOR, fixes are PATCH.

## [Unreleased]

## [1.1.1] - 2026-10-17

### Changed

- `c-cpp-best-practices`: the nested-namespace rule now prescribes the C++17
  `namespace A::B` form instead of `namespace A { namespace B`, which cannot
  survive Allman brace reformatting.

## [1.1.0] - 2026-10-16

### Added

- `scripts/download-vendor-skills.sh`: initialises and updates the vendored
  skill submodules.

### Changed

- Moved the `install` script to `scripts/install.sh`; it now resolves the
  repository root from its own location.

## [1.0.1] - 2026-10-16

### Changed

- `README.md`: simplified the project introduction.

## [1.0.0] - 2026-10-16

### Added

- `install` script: symlinks every skill in the repository into a coding
  agent's skills directory (OpenCode or Claude).

## [0.7.2] - 2026-10-16

### Changed

- Renamed the project to `srosani-skills`.

## [0.7.1] - 2026-10-16

### Changed

- Moved all skills into a `skills/` directory and re-pointed the vendored skill
  symlinks to match.

## [0.7.0] - 2026-10-16

### Added

- `c-cpp-best-practices` skill: C/C++ conventions (naming, `nullptr`, const
  correctness, Doxygen comments, namespace and class layout, memory management,
  warnings-as-errors policy).
- `js-ts-best-practices` skill: TypeScript/JavaScript conventions (Node version
  via nvm, JSDoc/TSDoc).
- `python-best-practices` skill: Python conventions (pyproject.toml packaging,
  project-local virtual environments, `.gitignore` baseline, Google-style
  docstrings).

## [0.6.1] - 2026-10-16

### Changed

- `coding-standards`: removed project-specific naming so the skill applies to
  any codebase.

## [0.6.0] - 2026-10-16

### Added

- `coding-standards` skill: language-agnostic coding standards for readability,
  naming, documentation, control flow, and safe editing.

## [0.5.0] - 2026-10-16

### Added

- `grill-me`, `wait-what` and `writing-for-agents` skills, also vendored from
  `mattpocock/skills` and exposed at the top level via symlinks.

## [0.4.0] - 2026-10-16

### Added

- `grilling` skill, vendored from `mattpocock/skills` (MIT) as a git submodule
  at `vendor/mattpocock-skills` and exposed at the top level via `grilling`.

## [0.3.0] - 2026-10-16

### Changed

- `versioning`: the standard now versions the repository as a single unit with
  one root changelog; skills are no longer versioned individually.

### Removed

- Per-skill `version:` frontmatter fields and per-skill `CHANGELOG.md` files.

## [0.2.0] - 2026-10-16

### Added

- `readme-audit` skill: audits `README.md` against recent code changes and
  proposes updates only for changes that affect users.

## [0.1.0] - 2026-10-16

### Added

- `versioning` skill: a repository-agnostic standard for version numbers and
  release notes, based on Semantic Versioning and Keep a Changelog.
