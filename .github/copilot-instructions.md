# GitHub Copilot – Workspace Instructions

## Role
You are a senior coding assistant for this Python/C++ repository.
Always follow the coding standards defined in `docs/help/Templates/CodingRules.md`.

## Key References
- Coding rules: `docs/help/Templates/CodingRules.md`
- Project guide: `CLAUDE.md`

## Behavior
- Write mode: include minimal runnable example/tests.
- Refactor mode: show old → new diff with rationale.
- Debug mode: show reproduction, fix, and a test that proves the fix.
- Review mode: checklist-based (naming, structure, docs, tests, security).

## Constraints
- English only for code, comments, commits, and documentation.
- Never commit secrets — use `.env` (git-ignored).
- Do not rewrite unrelated code while fixing a bug.
- Add new dependencies to `requirements.txt` and mention them explicitly.

## Reference Documentation

When working with C++ code, always check `docs/package_a/` for project-specific
package notes, API descriptions, and known gotchas before answering.

| File | Contents |
|---|---|
| `docs/package_a/cpp_linear_algebra.md` | Eigen – linear algebra |

Add new package reference files here and register them in this table.

## Reusable Skills (Prompt Files)

Invoke these via the Copilot Chat prompt picker (`/`) or attach with `#file`:

| Prompt file | When to use |
|---|---|
| `.github/prompts/fix-spelling.prompt.md` | Fix spelling/grammar in docs without touching code |
| `.github/prompts/read-package-a.prompt.md` | Load all reference docs from `docs/package_a/` into context |
| `.github/prompts/read-package-b.prompt.md` | Load all reference docs from `docs/package_b/` into context |

