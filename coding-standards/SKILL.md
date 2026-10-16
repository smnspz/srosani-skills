---
name: coding-standards
description: Coding standards — language-agnostic principles for readability, naming, documentation, control flow, and safe editing across every language in a codebase.
---

# Coding Standards

Language-agnostic conventions that apply to codebases in any language (C/C++, TypeScript/JavaScript, Python, and others). Language-specific detail belongs in dedicated per-language conventions; this file captures the principles that hold everywhere.

## General Principles

- Write readable code before clever code.
- Follow the idiomatic conventions of the language in use. Do not force patterns from one language onto another.
- Prefer immutability: use `const`, `val`, `final`, or the language's equivalent wherever a value is not reassigned.
- Make types explicit when the language is statically typed. Avoid escape-hatch types (`any`, `Object`, `dynamic`) unless justified.
- One file = one main responsibility. If a file grows too large, split it.
- Keep functions small and focused. If a function grows past roughly 30 lines, consider extraction.
- Always handle errors: no empty catches, no silenced return codes.

## Explicit Over Implicit

Prefer explicit comparisons over implicit truthiness. This makes intent clear and avoids ambiguity about what a value means.

- Compare return codes explicitly (e.g. `if (foo() != 0)` rather than `if (foo())`), especially where `0` means success.
- Check for null/none explicitly (e.g. `if (ptr == NULL)` / `if (value is None)`), not by relying on falsiness.
- Compare counts and sizes explicitly (e.g. `if (count == 0)` rather than `if (!count)`).

Apply this to new code and to lines being changed. When editing existing code that follows a different local style, keep the surrounding style consistent.

## Control Flow Clarity

- Prefer early return over deep nesting.
- When a preceding block may exit the function early (via `return`, `exit`, or `throw`), make the implicit "otherwise" explicit. In languages that support it, a single lowercase `//else` comment on its own line after the early-return block signals that the code below runs only when the early return did not happen.
- Avoid hidden side effects: functions should be predictable from their signature.

## Naming Conventions

Follow the native convention of each language rather than importing one language's style into another. Use meaningful names; no cryptic abbreviations.

- Types/classes: the language's type-name convention (commonly PascalCase).
- Functions/variables: the language's convention (camelCase, snake_case, etc.).
- Constants: the language's convention (commonly UPPER_SNAKE_CASE).
- No magic numbers or strings: introduce named constants with meaningful names.

### Reserved identifiers

Never use identifier patterns reserved by the language or its standard library. In C/C++ this includes names starting with two underscores (`__anything`) or an underscore followed by an uppercase letter (`_Reserved`). Prefer, more generally, to avoid leading-underscore naming schemes to sidestep reserved-identifier hazards.

## Documentation Comments

- Every function, method, class, and public symbol must have a documentation comment describing what it does, its parameters (with types where the language is typed), and its return value. If a function returns nothing, state that explicitly.
- Use the language's idiomatic documentation style (Google-style docstrings for Python, `///` doc comments for C/C++, JSDoc/TSDoc for TypeScript, etc.).
- Comment the **why**, not the **what**. The code itself should make the "what" clear.

## No Banner Separators

Never use large decorative separator comments to divide code into sections, for example:

```
# ============================================================================
# Some Section
# ============================================================================
```

If a logical grouping needs a heading, a single concise comment line is enough (e.g. `// --- Registration ---`). Prefer relying on the doc comment of the first item in a group to mark the boundary.

## Inline Comments

Mark each logical step of a function body with a short comment (in the language's line-comment syntax) placed directly above it, at the same indentation level as the code it describes. Separate each comment+code block from the next with a blank line, so the function reads as a sequence of clearly labeled steps.

Rules:

- One line only. Do not wrap a comment onto a second line; shorten it instead.
- Capitalize the first word. No trailing period.
- Keep it short and concise, typically 3 to 8 words.
- Reserve comments for grouping multi-line steps. Do not add a comment above a single, self-explanatory line.
- Reuse the same recurring phrasing patterns:
  - `Initializations` above the first block that sets up local variables.
  - `Check <condition>` above a validation or guard block.
  - `Calculate <value>` / `Compute <value>` above a computation.
  - `Return <what>` above the final return statement.
  - `<Verb> the <noun>` as the general pattern for an action block, e.g. `Encode the remaining bytes`, `Advance`, `Sort the values`.

This pairs with the early-return marker from **Control Flow Clarity**: after an early-return block, a lone "else" comment on its own line (followed by a blank line) signals that the rest of the function runs only when the early return did not happen.

```ts
function loadCalibration(path) {
  if (!exists(path)) {
    return {};
  }

  // else

  // Initializations
  const result = {};

  // Read and parse the file line by line
  const contents = read(path);
  for (const line of contents.split('\n')) {
    // ...
  }

  // Return the parsed values
  return result;
}
```

## Project Setup Hygiene

When creating a new project or subproject, regardless of language:

- Target the current, supported version of the language/toolchain rather than hardcoding an older one out of habit. Only lower the baseline for a stated compatibility requirement.
- Prefer the language's modern, declarative packaging/metadata format (for example `pyproject.toml` over `requirements.txt` for Python) with sensibly pinned dependency lower bounds.
- Keep environment and build artifacts out of version control. Create environments project-locally (not in a shared/global location) and provide a `.gitignore` that excludes caches, build output, dependency directories, and environment folders. Extend the baseline with project-specific generated files.

## Editing Existing Code (Migration Policy)

The codebase may contain older conventions. Do **not** automatically refactor legacy style to a new convention while doing unrelated work. Migration happens gradually and only when consciously decided.

Apply new conventions to:
- Brand-new files, classes, and modules.
- Code explicitly requested to be migrated.

Otherwise, preserve the surrounding style as-is.

## Build Policy

Do not automatically run build or configure commands (for example `cmake` configure/build, or any compile step). If you believe compilation is needed to verify a change, ask the user first before executing any build-related command.

## Formatting

- Use the language's standard formatter (`prettier`, `black`, `gofmt`, `rustfmt`, `clang-format`, etc.).
- Follow the project's existing indentation and line-length conventions. If none is established, use the language's idiomatic defaults.
