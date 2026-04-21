# Coding Rules

## 1. General Rules
- **Readability over complexity:** Write code that is easy to understand and maintain.
- **DRY principle:** Avoid code duplication ("Don't Repeat Yourself").
- **Version control:** Every merge into `main` must contain working, tested, and documented changes.

---

## 2. Naming Conventions
- **File names:** Use `snake_case` for both languages.
  Examples: `my_module.cpp`, `my_class.h`, `my_script.py`
- **Classes:** Use `PascalCase` for both languages.
  Example: `MyClass`
- **Functions and methods:** Use `snake_case` for both languages.
  Example: `do_something()`
- **Variables:** Use `snake_case` for both languages.
  Example: `my_variable`
- **Constants:** Use `UPPER_SNAKE_CASE` for both languages.
  Example: `MAX_COUNT`
- **Namespaces (C++) and modules (Python):** Use `snake_case`.
  Examples: `namespace my_namespace` (C++), `import my_module` (Python)

---

### Python: Class Naming and Documentation
- **Class names:** Use `PascalCase`.
- **Class docstring:** Every class gets a short descriptive docstring directly after the definition,
  explaining its purpose and important attributes.

  ```python
  class MyClass:
      """
      Short description of what this class represents or does.

      Attributes:
          attribute1 (int): Description of attribute1.
          attribute2 (str): Description of attribute2.
      """
      def __init__(self, attribute1: int, attribute2: str):
          self.attribute1 = attribute1
          self.attribute2 = attribute2
  ```

- **Protected / private attributes:**
  - protected: `_attribute`
  - private: `__attribute`
  > Note: Python does not enforce true access control like C++.

---

## 3. File Structure

### C++
1. **Header files (`.h`):**
   - Contain class, function, and constant declarations.
   - Use include guards or `#pragma once`.

   ```cpp
   #ifndef MY_CLASS_H
   #define MY_CLASS_H

   class MyClass {
   public:
       void do_something();
   private:
       int my_variable;
   };

   #endif
   ```

2. **Implementation files (`.cpp`):**
   - Contain the definitions from the header files.
   - Keep functions and methods short and modular.

### Python
- Import order: standard library → third-party → internal modules.

  ```python
  import os
  import sys

  import numpy as np

  from my_module import my_function
  ```

---

## 4. Comments and Documentation

### Required
- **Doxygen style:** Use Doxygen-compatible comments for both languages.
- **Function comments:**

  C++ example:
  ```cpp
  /**
   * Calculates the sum of two numbers.
   * @param a The first number.
   * @param b The second number.
   * @return The sum of a and b.
   */
  int add(int a, int b);
  ```

  Python example:
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

- **Inline comments:** Use sparingly — always short and precise.
  ```cpp
  int count = 0; // Counter for the loop
  ```

### Additional Tags
- **`@note`:** Use to explain non-obvious assumptions, constraints, or known compatibility issues.
  Examples:
  - Assumptions about parameter ranges or types.
  - Performance impact of specific configurations.
  - Known limitations or compatibility problems.

- **`# TODO:`:** Use for planned improvements, known bugs, or workarounds — describe them directly.
  Examples:
  - `# TODO: Make possible for all datasets, only works for Dataset A at the moment`
  - `# TODO: Only works with Python 3.11`

---

## 5. Code Style
- **Indentation:** 4 spaces (no tabs).
- **Line length:** Maximum 100 characters.
- **Blank lines:** Use blank lines to separate logical blocks.
- **Braces and blocks:**
  - C++: Opening `{` on the same line as the statement.
    ```cpp
    if (condition) {
        do_something();
    }
    ```
  - Python: Follow PEP 8 indentation rules.

---

## 6. Best Practices
- **Error handling:** Use exceptions (`try/catch` in C++, `try/except` in Python) instead of error return codes.
- **Unit tests:** Every piece of functionality must have unit tests.
- **Code reviews:** All code must be reviewed before merging.

---

## 7. Tooling
- **Code formatter:** `clang-format` (C++), `black` (Python).
- **Linting:** `cpplint` (C++), `pylint` (Python).

---

## 8. Git and Documentation
- See [Git_Branch_Workflow.md](GithubHelp/Git_Branch_Workflow.md) for branching strategy.
- Open-source contributions must include updated documentation.

### Adding a new AI tool

1. Read `docs/help/Templates/CodingRules.md` for the rule set.
2. Read `.github/copilot-instructions.md` for the pre-prompt pattern.
3. Create a new file under `docs/help/CustomGPT/<ToolName>/System Prompt.md`
   combining both.
