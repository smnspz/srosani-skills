---
name: js-ts-best-practices
description: TypeScript/JavaScript conventions — selecting the Node version with nvm, and JSDoc/TSDoc comment conventions for TypeScript and JavaScript. Use when creating a JS/TS project or writing, editing, or reviewing .js, .jsx, .ts, or .tsx code.
---

# TypeScript / JavaScript Best Practices

TypeScript/JavaScript-specific conventions. Language-agnostic rules (no banner separators, early-return clarity, documenting every symbol, modern-packaging and version-baseline hygiene, keeping artifacts out of version control) live in the `coding-standards` skill; this skill covers the JS/TS detail on top of that.

TypeScript is the default for new projects; the rules below apply equally to existing JavaScript projects unless a rule is explicitly TypeScript-only.

## Project Creation

### Node version

Every new project targets the latest Node.js version available locally through [nvm](https://github.com/nvm-sh/nvm). Before scaffolding, verify nvm is installed and pick the highest locally-installed version rather than hardcoding one:

```bash
command -v nvm
nvm ls
```

Then activate that version for the project:

```bash
nvm use <latest-installed-version>
```

### Loading nvm in a fresh shell

Some shells do not load nvm automatically, so a fresh shell can fall back to an old Node version. Before running any Node or pnpm command, load nvm and select the required version:

```bash
# Load nvm functions
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Install and use the required version
nvm install <version>
nvm use <version>
```

## JSDoc

Every function, method, and class must have a comprehensive JSDoc block describing what it does, every parameter, and what it returns. If the function returns nothing, state that explicitly.

**TypeScript files** (`.ts`, `.tsx`): omit `@param` and `@returns` type tags — the TypeScript signature already carries the types. Describe each parameter by name.

```ts
/**
 * Resize a frame to the given dimensions.
 *
 * @param frame - The source frame as an HxWxC array.
 * @param width - Target width in pixels.
 * @param height - Target height in pixels.
 * @returns The resized frame with shape (height, width, channels).
 */
export function resizeFrame(frame: Uint8Array, width: number, height: number): Uint8Array {
  // ...
}
```

For a function with no return value, document it as returning nothing:

```ts
/**
 * Write the configuration to a JSON file.
 *
 * @param config - The configuration mapping to serialize.
 * @param path - Destination file path.
 * @returns Nothing. Writes to disk.
 */
export function saveConfig(config: Record<string, unknown>, path: string): void {
  // ...
}
```

When a function throws errors that callers are expected to handle, document them in `@throws`:

```ts
/**
 * Load calibration data from a file.
 *
 * @param path - Path to the calibration file.
 * @returns The parsed calibration parameters.
 * @throws {Error} If the file does not exist or its contents cannot be parsed.
 */
export function loadCalibration(path: string): Record<string, unknown> {
  // ...
}
```

**JavaScript files** (`.js`, `.jsx`): include type tags on every `@param` and `@returns`, since there is no other source of type information.

```js
/**
 * Resize a frame to the given dimensions.
 *
 * @param {Uint8Array} frame - The source frame as an HxWxC array.
 * @param {number} width - Target width in pixels.
 * @param {number} height - Target height in pixels.
 * @returns {Uint8Array} The resized frame with shape (height, width, channels).
 */
export function resizeFrame(frame, width, height) {
  // ...
}
```
