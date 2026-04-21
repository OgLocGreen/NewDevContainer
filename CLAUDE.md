# NewDevContainer – Project Guide for Claude Code

This file gives Claude Code (and any AI pair programmer) the context it needs to
be useful in this repository. Keep it short and factual.

## Project Summary

NewDevContainer is a **development template** for Python projects. It ships a
preconfigured Dev Container (CUDA 12.6 + Python 3.12) so a new contributor can
clone the repo and start coding without local setup.

## Repository Layout

```
NewDevContainer/
├── .claude/             # Claude Code team defaults (settings, commands, skills)
│   └── skills/
│       └── package-docs/  # Loads docs/package_a|b on demand
├── .devcontainer/       # Dev Container (Dockerfile, compose, startup script)
├── .vscode/             # Shared VS Code settings
├── src/                 # Application source code
│   └── NewWandB/        # Git submodule
├── data/                # Sample datasets (not for large binaries)
├── docs/                # Documentation, cheat sheets, templates
│   ├── package_a/       # Reference for package_a (read by package-docs skill)
│   └── package_b/       # Reference for package_b (read by package-docs skill)
├── ReadMe.md            # Onboarding guide
└── CLAUDE.md            # This file
```

Tests live next to the code they cover (`src/<module>/tests/`) or in a top-level
`tests/` folder when introduced.

## Environment

- **Runtime:** Python 3.12 inside the Dev Container; virtualenv at `/app/venv`.
- **GPU:** NVIDIA CUDA is expected – the compose file reserves all GPUs.
- **Python deps:** `.devcontainer/requirements.txt` is the source of truth for
  dev-time packages. Runtime deps for individual apps live with the app.

## Conventions

- **Language for code, comments, commits, docs:** English.
- **Formatting:** follow PEP 8; 4-space indents; type hints on new code.
- **Imports:** standard lib → third-party → local, separated by blank lines.
- **Entry points:** guard with `if __name__ == "__main__":`.
- **Secrets:** never commit. Use `.env` (already git-ignored).

## Coding Standards

### General
- Readability over cleverness — write code that is easy to understand and maintain.
- DRY: avoid code duplication.
- Every merge to `main` must contain working, tested, and documented changes.

### Naming Conventions
| Construct            | Convention         | Example                      |
| -------------------- | ------------------ | ---------------------------- |
| Files                | `snake_case`       | `my_module.py`, `my_class.h` |
| Classes              | `PascalCase`       | `MyClass`                    |
| Functions / methods  | `snake_case`       | `do_something()`             |
| Variables            | `snake_case`       | `my_variable`                |
| Constants            | `UPPER_SNAKE_CASE` | `MAX_COUNT`                  |
| Modules / namespaces | `snake_case`       | `import my_module`           |
| Protected attributes | `_attribute`       | `self._value`                |
| Private attributes   | `__attribute`      | `self.__value`               |

### Documentation
- Every public function and class **must** have a docstring (Google / Doxygen style).
- Python example:
  ```python
  def add(a: int, b: int) -> int:
      """
      Calculates the sum of two numbers.

      Args:
          a (int): The first number.
          b (int): The second number.

      Returns:
          int: The sum of a and b.
      """
      return a + b
  ```
- C++ example (Doxygen):
  ```cpp
  /**
   * Calculates the sum of two numbers.
   * @param a The first number.
   * @param b The second number.
   * @return The sum of a and b.
   */
  int add(int a, int b);
  ```
- Class docstrings must describe purpose and list important attributes.
- Inline comments: use sparingly; always short and precise.
- Use `@note` for non-obvious assumptions, constraints, or compatibility issues.
- Use `# TODO:` for known limitations or planned improvements — describe them directly.
  Example: `# TODO: Only works with Dataset A at the moment`

### Code Style
- Indentation: 4 spaces (no tabs).
- Line length: max 100 characters.
- Use blank lines to separate logical blocks.
- C++: opening `{` on the same line as the statement.
- Python: follow PEP 8 strictly.

### Best Practices
- Error handling: use exceptions (`try/except` in Python, `try/catch` in C++) — not error return codes.
- Unit tests are required for every piece of functionality.
- Every code change must be reviewed before merging to `main`.
- Formatters: `black` (Python), `clang-format` (C++).
- Linters: `pylint` (Python), `cpplint` (C++).

## Running Things

```bash
# Inside the Dev Container:
python src/<your_program>.py
python -m src.<your_module>
```

## Git Workflow

- `main` is protected; work on feature branches.
- Branch names: `feature/<short-topic>`, `fix/<short-topic>`.
- Commit messages: imperative mood, short subject (<70 chars), detail in body.
- The `src/NewWandB` submodule needs `git submodule update --init --recursive`
  after cloning.

## Custom Commands

These slash commands are available in this project (`.claude/commands/`):

| Command           | What it does                                                           |
| ----------------- | ---------------------------------------------------------------------- |
| `/spell-check`    | Fixes spelling/grammar in docs — never touches code or technical terms |
| `/read-package-a` | Loads all reference docs from `docs/package_a/` into context           |
| `/read-package-b` | Loads all reference docs from `docs/package_b/` into context           |

Suggest the relevant command proactively when it fits the task (e.g. suggest `/spell-check` after editing Markdown, suggest `/read-package-a` before working with that package).

## Notes for AI Assistants

- Prefer editing existing files over creating new ones.
- Do **not** add dependencies without updating `requirements.txt` and mentioning
  it in the PR description.
- Do **not** rewrite unrelated code while fixing a bug – keep diffs small.
- When unsure about business intent, ask instead of guessing.

> Coding rules reference: @docs/help/Templates/CodingRules.md
