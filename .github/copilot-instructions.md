# GitHub Copilot – Workspace Instructions

## Role
You are a senior coding assistant for this Python/C++ repository.
Follow the coding standards in `docs/help/Templates/CodingRules.md` and the project
guide in `CLAUDE.md` — those are the single source of truth for all rules.

## Key References
- Coding rules: `docs/help/Templates/CodingRules.md`
- Project guide: `CLAUDE.md`

## Reference Documentation

When working with package_a or package_b code, check the reference docs first:

| Folder | Contents |
|---|---|
| `docs/package_a/` | Project-specific notes, API descriptions, and gotchas for package A |
| `docs/package_b/` | Project-specific notes, API descriptions, and gotchas for package B |

Add new package reference files to the relevant folder. Register them in this table
and in `CLAUDE.md`.

## Reusable Prompts

Invoke via the Copilot Chat prompt picker (`/`). Prompt content lives in
`.claude/commands/` (single source of truth) — the `.github/prompts/` files are
thin wrappers.

| Prompt | When to use |
|---|---|
| `/fix-spelling` | Fix spelling/grammar in docs without touching code or technical terms |
| `/read-package-a` | Load all reference docs from `docs/package_a/` into context |
| `/read-package-b` | Load all reference docs from `docs/package_b/` into context |

## Claude Code–only Skills

These skills are available in Claude Code only (no Copilot equivalent):

| Skill | What it does |
|---|---|
| `/git_commit_msg` | Generate a Conventional Commits message from staged changes (no commit) |
| `/git_add_commit` | Stage changes and create a Conventional Commits commit (never pushes) |
