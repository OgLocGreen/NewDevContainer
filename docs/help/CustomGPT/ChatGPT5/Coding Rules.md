# Coding Rules (C/C++ & Python)

These rules are authoritative for all code and documents in this repository.

---

## [R1] General Rules

- **Readability over complexity**: Favor clear, maintainable solutions.
- **DRY principle**: Avoid duplication; refactor shared logic.
- **Version control**: Every merge to `main` must contain working, tested, and documented changes.
- **Branch protection**: `main` is protected with required status checks (format, lint, tests, docs). CI must pass before merge.

---

## [R2] Naming Conventions

- **Files**: `snake_case` in all languages  
  Examples: `my_module.c`, `my_module.cpp`, `my_class.h`, `my_script.py`
- **Classes (C++)**: `PascalCase` (e.g., `MyClass`)
- **Functions/Methods**: `snake_case` (e.g., `do_something()`)
- **Variables**: `snake_case` (e.g., `my_variable`)
- **Constants**: `UPPER_SNAKE_CASE` (explicitly not `kCamelCase`) (e.g., `MAX_COUNT`)
- **Namespaces (C++) / Modules (Py)**: `snake_case` (e.g., `namespace my_namespace`, `import my_module`)

### Python: Class Naming & Docstrings
- **Class names**: `PascalCase`.
- **Docstring**: Each class has a concise docstring describing purpose and key attributes.

```python
class MyClass:
    """
    Short description of the responsibility/purpose.

    Attributes:
        attribute1 (int): Explanation.
        attribute2 (str): Explanation.
    """
    def __init__(self, attribute1: int, attribute2: str):
        self.attribute1 = attribute1
        self.attribute2 = attribute2
```

- **Protected/Private**: `_attribute` (convention), `__attribute` (name-mangled). Note that Python has no enforced access control.

---

## [R3] File Structure

### C/C++
1) **Headers (`.h`)**  
   - Declarations only.  
   - Include guards **mandatory** using `<PROJECT>_<PATH>_<FILE>_H_` (uppercase). `#pragma once` optional.

```c
#ifndef MYPROJECT_SRC_UTIL_MY_CLASS_H_
#define MYPROJECT_SRC_UTIL_MY_CLASS_H_

#ifdef __cplusplus
extern "C" {
#endif

void do_something(void);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // MYPROJECT_SRC_UTIL_MY_CLASS_H_
```

2) **Implementations (`.c` / `.cpp`)**  
   - Definitions corresponding to headers.  
   - Keep functions short and modular.

### Python
- Import order: **stdlib → third-party → internal**.

```python
import os
import sys

import numpy as np

from my_module import my_function
```

- Package code under modules with `__init__.py` as needed.

---

## [R4] Comments & Documentation

- **Doxygen compatibility** for C/C++ and Python.
- **Python docstrings**: Google style parsed by **Sphinx + Napoleon** (preferred). If unified docs are built via Doxygen only, either:
  - integrate via **Breathe**, or
  - accept that Python docstrings are Sphinx-native and add a `@note` in relevant modules.

### Function Documentation Examples

**C/C++**
```c
/**
 * Calculates the sum of two integers.
 * @param a First addend.
 * @param b Second addend.
 * @return The sum of a and b.
 */
int add(int a, int b);
```

**Python**
```python
def add(a: int, b: int) -> int:
    """Calculate the sum of two integers.

    Args:
        a: First addend.
        b: Second addend.

    Returns:
        Sum of a and b.
    """
    return a + b
```

- **Inline comments**: Use sparingly, short and precise.
- **@note**: Important assumptions, parameter ranges, performance implications, known limitations.
- **#TODO**: Concrete follow-ups, workarounds, or improvements (e.g., `# TODO: Support Dataset B; only A is supported currently`).

---

## [R5] Code Style

- **Indentation**: 4 spaces; no tabs.
- **Line length**: Python **88** (Black default); C/C++ **100**.
- **Whitespace**: Use blank lines to separate logical blocks.
- **Blocks/Braces**:
  - **C/C++**: Opening `{` on the same line as control statement/function.
  - **Python**: Follow PEP 8 strictly.

---

## [R6] Best Practices

- **Error handling**:  
  - **C++**: Prefer exceptions (`try/catch`) over error return codes.  
  - **C**: Use explicit error codes and/or result structs; document return conventions.
- **Unit tests**: Each nontrivial change must include or update tests proving correctness.
- **Code reviews**: Required before merge.

### Testing Standards
- **Python**: `pytest` under `tests/`, files named `test_*.py`.
- **C++**: GoogleTest under `tests/`, files named `*_test.cpp`.
- **C**: a lightweight C framework such as **Unity** or **CMocka** under `tests/`.
- Each bug fix should include a regression test that fails before the fix and passes after.

---

## [R7] Tooling

- **Formatters**:
  - **Python**: `black` (line-length 88), configured in `pyproject.toml`.
  - **C/C++**: `clang-format` with project `.clang-format`.

- **Linters**:
  - **Python**: `pylint` (configure `.pylintrc` as needed).
  - **C/C++**: `clang-tidy` (recommended checks: `clang-analyzer-*`, `cppcoreguidelines-*`, `modernize-*`); optional `cppcheck` and/or `cpplint`.

- **Assistant expectation**: When generating or touching code, the assistant SHOULD emit or update relevant config files and basic CI steps.

---

## Git & Documentation

- **Conventional Commits**: Use prefixes like `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `ci:`, `build:`, `chore:`. Breaking changes: `feat!:` and a `BREAKING CHANGE:` footer.
- **CI**: Enforce required checks (format, lint, tests, docs). Example CI snippets should accompany new tools/config.
- **Open Source**: Respect licenses. Cite origins for adapted code.

---

## Compliance Checklist (for PRs and Assistant Responses)

- [ ] **R1** Readability > complexity; DRY; working + tested + documented; CI protected.
- [ ] **R2** Naming: files/classes/functions/vars/constants and namespaces/modules follow rules.
- [ ] **R3** Structure: C/C++ headers with guards; `.c/.cpp` definitions; Python import order.
- [ ] **R4** Docs: Doxygen-compatible; Python Google docstrings; `@note` and `#TODO` used appropriately.
- [ ] **R5** Style: 4 spaces; line length Python 88 / C/C++ 100; braces/PEP8.
- [ ] **R6** Tests: pytest / GoogleTest / Unity|CMocka present and meaningful.
- [ ] **R7** Tooling: formatters/linters run; configs updated; CI green.
