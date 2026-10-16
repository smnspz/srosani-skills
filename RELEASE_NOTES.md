# Release Notes

All notable changes to this repository are documented in this file. The format
is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The repository version tracks the collection as a whole. Each skill is also
versioned on its own; the authoritative, detailed history for a skill lives in
that skill's own `CHANGELOG.md`.

## [Unreleased]

## [0.2.0] - 2026-10-16

### Added

- `readme-audit` skill (0.1.0): audits `README.md` against recent code changes
  and proposes updates only for changes that affect users.
- Repository versioning: a root `VERSION` and a repository-level changelog,
  bumped by the most significant change across skills.

### Changed

- `versioning` skill (0.2.0): the standard now covers repository (collection)
  versioning alongside per-skill versions.

## [0.1.0] - 2026-10-16

### Added

- `versioning` skill (0.1.0): a repository-agnostic standard for version numbers
  and release notes, based on Semantic Versioning and Keep a Changelog.
