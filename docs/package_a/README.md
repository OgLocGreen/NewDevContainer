# package_a — Documentation Index

> This folder is the team-curated reference for `package_a`.
> The `package-docs` Claude Code skill (`.claude/skills/package-docs/`) reads
> this file first when answering questions about the package.

## Overview

Short paragraph: what is `package_a`, what problem does it solve, who owns it.

## Contents

- `api.md` — public API reference (functions, classes, CLI flags).
- `examples/quickstart.md` — minimal runnable example.
- `examples/advanced.md` — more complex integrations.
- `changelog.md` — notable changes per version.

Add files as the package evolves and keep this index in sync.

## Conventions

- Keep examples runnable inside the Dev Container (`/app/venv`, Python 3.12).
- Prefer small, focused snippets over monolithic dumps.
- Link to the source in `src/` with `src/<module>/<file>.py:<line>` so readers
  can jump straight to the implementation.
