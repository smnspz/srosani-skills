---
name: readme-audit
description: "Audit the project's README.md against recent code changes and decide whether those changes are worth documenting. Inspects the recent diff, compares it against what the README currently describes, and proposes README updates only for changes that affect users of the project (features, CLI/API, configuration, install/build/run steps, dependencies, behavior). When uncertain whether something belongs in the README, always asks the user before editing. Use after committing, before a release, or when the user asks to check that the README is up to date."
version: 0.1.0
---

Audit `README.md` against recent code changes and keep it accurate, without documenting noise.

The goal is a README that reflects how the project is installed, configured, built, run, and used. Not every code change belongs there. Refactors, internal cleanups, test-only changes, and formatting rarely do. Changes to public behavior, commands, configuration, dependencies, or setup steps usually do.

## Process

### 1. Locate the README

Find the `README.md` relevant to the changed code. In a multi-project repo there may be several (a top-level one and per-app/per-lib ones). Pick the README that owns the changed files, for example the one in the nearest parent directory of the diff. If more than one README could apply, ask the user which to audit rather than guessing.

If no README exists near the changed code, tell the user and ask whether one should be created.

### 2. Gather the recent changes

Determine what "recent changes" means, in this order:

1. If the user named a fixed point (a commit SHA, branch, tag, `HEAD~3`, etc.), use it.
2. Otherwise default to the most recent commit: `git show HEAD` and `git diff HEAD~1...HEAD`.
3. If the working tree has uncommitted changes relevant to the audit, include `git diff HEAD` as well.

Capture both the diff and the commit messages (`git log <range> --oneline`), since the messages often state intent that clarifies whether a change is user-facing.

Confirm the range resolves and the diff is non-empty before analyzing. An empty diff means there is nothing to audit; say so and stop.

### 3. Classify each change

For every meaningful change in the diff, decide whether it is user-facing. Treat these as **worth documenting**:

- New, changed, or removed features or capabilities
- Changes to the CLI (flags, subcommands, arguments) or public API
- New or changed configuration (env vars, config files, defaults)
- Changes to install, build, run, or deployment steps
- New, removed, or version-bumped dependencies or runtime requirements
- Changes to supported platforms or minimum language/tool versions
- Behavior changes a user would notice

Treat these as **usually not worth documenting** (unless they change something above):

- Internal refactors, renames of private symbols, code moves
- Test-only changes
- Formatting, comments, whitespace
- Purely internal implementation details

### 4. Audit the README against the classification

For each change classified as worth documenting, check whether the README already covers it accurately:

- Missing: the README says nothing about it.
- Stale: the README describes the old behavior, command, or requirement.
- Correct: the README already reflects it, no action needed.

Also flag the reverse: README content that describes something the diff removed or renamed (now inaccurate).

### 5. Decide, and ask when unsure

- If a change is clearly user-facing and the README is missing or stale, prepare a concrete README edit.
- If a change is clearly internal, leave the README alone.
- If you are **unsure** whether a change belongs in the README (ambiguous audience, unclear intent, borderline user-facing), **ask the user** with a specific question. Describe the change, why it is borderline, and propose the edit you would make. Do not edit the README on a guess.

Never invent documentation for behavior you cannot confirm from the diff or the code. When the diff is insufficient to describe a change accurately, read the relevant source before writing, or ask.

### 6. Apply and report

For confirmed updates, edit the README in place, matching its existing tone, structure, and formatting. Then report:

- What you changed in the README and why (tie each edit to a specific change in the diff).
- What you deliberately did not document, and why (internal/test/formatting).
- Any open questions you raised for the user, if the audit is blocked on their answer.

Keep the edits minimal and focused. Do not restructure or rewrite the whole README unless the user asks.
