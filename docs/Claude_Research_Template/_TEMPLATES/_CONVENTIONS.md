# Conventions: Claude + Obsidian Workflow

> This document defines how Claude works with the Obsidian vault.
> Applies to all projects. Referenced by each project's System Prompt.
> Last updated: 2026-05-04

## Principles

1. **Obsidian = single source of truth** for everything that is not code.
2. **Git repo = single source of truth** for code.
3. **Claude Project = context loader.** No uploaded files that go stale. The System Prompt points to vault paths.
4. **No duplicates.** Claude reads/writes directly in the vault, never copies content into the chat as a replacement.
5. **Asymmetric sync.** Pulls happen automatically when needed, or explicitly via `/pull*` commands. Writes happen only on explicit `/push`.

## Multi-level project structure

Projects can be flat (single working area) or hierarchical (parent + subprojects). The convention supports both.

### Flat project

```
Projects/[ProjectName]/
├── _PROJECT.md
├── _PLAN.md
├── _DECISIONS.md
├── Scratch/
└── notes/
```

### Hierarchical project (parent + subprojects)

```
Projects/[ParentProject]/
├── _PROJECT.md         ← Parent status, cross-cutting TODOs
├── _PLAN.md            ← High-level roadmap, phase overview
├── _DECISIONS.md       ← ALL decisions (default location, tag with [Subproject])
├── Scratch/            ← Idea bin for ALL subprojects (parent-level only)
│
├── [Subproject_A]/
│   ├── _PLAN.md        ← Subproject-specific detailed plan (REQUIRED if active)
│   ├── _DECISIONS.md   ← Optional, only if decision volume is large
│   └── [content files]
│
└── [Subproject_B]/
    └── ...
```

**Rules for hierarchical projects:**
- Parent always has `_PROJECT.md`, `_PLAN.md`, `_DECISIONS.md`, `Scratch/`
- Active subproject has its own `_PLAN.md`
- Subproject `_DECISIONS.md` is optional — default: write decisions to parent's `_DECISIONS.md` and tag with `[Subproject_A]`
- `Scratch/` lives only at parent level
- No subproject-of-subproject by default. If depth needed, use plain folders without meta files.

## File conventions

Per-project meta files (with underscore prefix):
- `_PROJECT.md` — status + TODO list. Claude updates only via `/push`.
- `_DECISIONS.md` — append-only log. New entries on top. Never modify existing entries.
- `_PLAN.md` — roadmap. Modify only with explicit OK.
- `Scratch/` — folder for project-relevant ideas and side notes that don't fit elsewhere.

Free notes, research, drafts go in subfolders (e.g. `notes/`, `research/`, `Bibliography/`).

Outdated documents move to `archive/`, never deleted.

## Per-session Claude behavior

The behavior is fully specified in each project's System Prompt (see `_CLAUDE_PROJECT_SYSTEM_PROMPT.md`). In summary:

| Phase | Behavior |
|-------|----------|
| Session start | Auto-pull `_PROJECT.md` (and others as needed) when a substantive question is asked |
| During work | Discuss, brainstorm, iterate freely. No automatic writes |
| Explicit pulls | `/pull`, `/pull_path`, `/pull_keyword`, `/pull_subproject` for targeted reads |
| Drift check | Every 3-4 substantive exchanges: compact cross-check between chat reality and vault state |
| On `/push` | 5-step ritual: recap → diff plan → clarifications → write → closer |
| Session end | Suggest a next-chat starter |

## Command summary

**Read commands** (risk-free, never block):
- `/where` — status synthesis
- `/pull` — full project refresh
- `/pull_path <path>` — targeted file/folder
- `/pull_keyword <term>` — full-text search
- `/pull_subproject <name>` — subproject focus

**Write command** (ritual, with confirmation):
- `/push` — 5-step consolidation

**Sync command** (special case):
- `/sync` — Zotero ↔ Obsidian reconciliation

## TODO conventions

- Simple Markdown checkboxes in `_PROJECT.md`
- Priority = order (top = next)
- Done items: date prefix, keep max 10, delete older
- Deferred items in their own section

## Scratch conventions

- One `Scratch/` folder per parent project (not per subproject)
- Append freely, no format requirements
- Promote mature ideas to a structured document via `/push`
- Discard when no longer relevant (this is the only vault content where deletion is OK)

## What Claude does NOT do

- Never delete files (only move to `archive/`, except in `Scratch/`)
- Never modify `_PLAN.md` without explicit OK
- Never duplicate vault content into Claude Projects
- Never make assumptions about Git state (always ask, or use Claude Code)
- Never fabricate citations, dates, or statistics
- Never write to vault files outside the `/push` ritual

## Multi-project setup

Each project lives in `Projects/[ProjectName]/`. The `_CLAUDE_PROJECT_SYSTEM_PROMPT.md` is copied into the corresponding Claude Project, with placeholders filled in for that project.

Projects are independent. There is no global `_DECISIONS.md` across projects — keep concerns separated.
