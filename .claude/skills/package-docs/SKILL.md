---
name: package-docs
description: Use this skill whenever the user asks about package_a or package_b — their documentation, API usage, code examples, integration details, or error messages from those packages. Load the relevant files from docs/package_a/ or docs/package_b/ before answering so that responses are grounded in the team's curated reference material instead of guesswork.
---

# Package Docs Skill

This skill exposes the team-curated reference material for the internal
packages shipped under `docs/package_a/` and `docs/package_b/` so that Claude
can answer questions about them with accurate, project-specific context.

## When to activate

Trigger on any question or task that mentions:

- `package_a`, `package-a`, or a symbol/API that is documented under
  `docs/package_a/`.
- `package_b`, `package-b`, or a symbol/API that is documented under
  `docs/package_b/`.
- "docs / documentation / reference / example / API" in combination with one
  of the two packages.
- Debugging errors or tracebacks that originate from either package.

If the request is ambiguous (e.g. "show me an example"), ask which package
before loading files.

## How to use the reference material

1. **Start with the index.** Read `docs/package_<x>/README.md` first — it is
   the table of contents and will point at the right sub-documents.
2. **Load targeted files only.** Prefer reading one or two specific documents
   (e.g. `api.md`, `examples/quickstart.md`) over dumping the whole folder
   into context. Use `Glob` / `Grep` to locate the relevant file by topic.
3. **Quote, don't paraphrase, API signatures.** When the docs define a
   function signature, CLI flag, or config key, reproduce it verbatim so that
   the answer stays copy-paste-safe.
4. **Link back.** Mention the source file (`docs/package_a/api.md:42`) so the
   user can open it in VS Code.
5. **Never invent APIs.** If a symbol is not documented and not discoverable
   via `Grep` in `src/`, say so and ask — do not guess.

## Suggested folder layout inside each package doc dir

```
docs/package_<x>/
├── README.md        # index / overview — always read first
├── api.md           # public API reference
├── examples/        # runnable code snippets
│   ├── quickstart.md
│   └── advanced.md
└── changelog.md     # version history (optional)
```

The layout is a suggestion, not a hard rule — adapt it to the package. The
only file this skill relies on is `README.md`.

## Response style

- Answer in the language the user writes in (English or German).
- Be concise; prefer a short explanation plus a code block over prose walls.
- If the user asks for an API call, give a minimal runnable example using the
  project's Python 3.12 / `/app/venv` environment conventions.
