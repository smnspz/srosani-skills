---
name: python-best-practices
description: Python conventions — pyproject.toml packaging, project-local virtual environments, a .gitignore baseline, and Google-style docstrings. Use when creating a Python project or writing, editing, or reviewing .py code.
---

# Python Best Practices

Python-specific conventions. Language-agnostic rules (no banner separators, documenting every symbol, modern-packaging and version-baseline hygiene, keeping artifacts out of version control) live in the `coding-standards` skill; this skill covers the Python detail on top of that.

## Project Creation

### Python version

Every new project targets the latest Python version installed on the system. Before scaffolding, detect it rather than assuming:

```bash
python3 --version
```

Use the detected version as the project's baseline (for example, set `requires-python` accordingly). Only lower the baseline if there is a stated compatibility requirement.

### Packaging: pyproject.toml over requirements.txt

Every new project running on Python 3.9 or newer uses `pyproject.toml` for dependencies and project metadata instead of `requirements.txt`.

A minimal `pyproject.toml` looks like:

```toml
[project]
name = "my-project"
version = "0.1.0"
description = "Short description of the project"
requires-python = ">=3.13"
dependencies = [
    "requests>=2.32",
]

[build-system]
requires = ["setuptools>=68"]
build-backend = "setuptools.build_meta"
```

Pin dependencies with sensible lower bounds. Do not add a `requirements.txt` alongside `pyproject.toml` for a new project.

### Virtual environments

Always create the virtual environment inside the project's own directory (not in a shared or global location), and make sure version control ignores it. Use `.venv` as the environment directory name.

```bash
python3 -m venv .venv
```

The `.gitignore` baseline below must exclude it so it is never committed.

### .gitignore

Every new project is initialized with a `.gitignore` that excludes the artifacts and caches Python tooling generates. Start from this baseline and extend it with project-specific artifacts:

```gitignore
# Byte-compiled / optimized / cache
__pycache__/
*.py[cod]
*$py.class

# Distribution / packaging
build/
dist/
*.egg-info/
.eggs/

# Virtual environments (project-local)
.venv/
venv/
env/

# Test / type-check / coverage caches
.pytest_cache/
.mypy_cache/
.ruff_cache/
.tox/
.coverage
.coverage.*
htmlcov/

# Tooling / editor
.python-version
```

Add project-specific generated files (data outputs, media, logs) below the baseline.

## Docstrings (Google style)

Every function and method, however small, must have a comprehensive Google-style docstring. The docstring must describe what the function does, every parameter with its type, and what it returns with its type. If the function returns `None`, state that explicitly.

```python
def resize_frame(frame: np.ndarray, width: int, height: int) -> np.ndarray:
    """Resize a frame to the given dimensions.

    Args:
        frame (np.ndarray): The source frame as an HxWxC array.
        width (int): Target width in pixels.
        height (int): Target height in pixels.

    Returns:
        np.ndarray: The resized frame with shape (height, width, C).
    """
    ...
```

For a function with no return value, document it as returning `None`:

```python
def save_config(config: dict, path: str) -> None:
    """Write the configuration to a JSON file.

    Args:
        config (dict): The configuration mapping to serialize.
        path (str): Destination file path.

    Returns:
        None: This function writes to disk and returns nothing.
    """
    ...
```

When a function raises exceptions that callers are expected to handle, document them in a `Raises:` section:

```python
def load_calibration(path: str) -> dict:
    """Load calibration data from a file.

    Args:
        path (str): Path to the calibration file.

    Returns:
        dict: The parsed calibration parameters.

    Raises:
        FileNotFoundError: If the file does not exist.
        ValueError: If the file contents cannot be parsed.
    """
    ...
```
