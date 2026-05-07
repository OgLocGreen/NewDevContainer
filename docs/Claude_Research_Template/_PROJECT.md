# _PROJECT: Claude_Research_Template

> Last updated: 2026-05-04

## Status

| Field | Value |
|-------|-------|
| Phase | Active — refactoring from Prompt_Engineering to Claude_Research_Template |
| Next milestone | Templates finalized, tested in live session, adopted into PhD project |
| Blockers | none |
| Repo | none |
| Claude Project | — |

## Summary

Template collection for a structured workflow between Claude and Obsidian. Asymmetric pull/push logic: Claude reads automatically when needed (or via explicit `/pull*` commands for targeted reads), writes only via the explicit `/push` ritual with confirmation. Augmented by a cyclical drift check, a Scratch convention, parent-subproject hierarchy support, and cherry-pick from old chats.

Evolved from the former `Prompt_Engineering` project. Dr. prompts remain included as a bonus — orthogonal to the research workflow, intended as templates for students and colleagues.

## Workflow

How Claude_Research_Template operates at runtime:

```
                  ┌──────────────────────────────────┐
                  │   CHAT  =  Working Directory     │
                  │   ephemeral · brainstorm · try   │
                  └─┬──────────────────────────────┬─┘
                    │                              │
               READ │                              │ WRITE
       auto-pull or │                              │ /push only
          /pull*    │                              │ (5-step ritual)
                    ▼                              ▼
                  ┌──────────────────────────────────┐
                  │   VAULT  =  Repository           │
                  │   persistent · single source     │
                  │                                  │
                  │   _PROJECT.md    status, TODOs   │
                  │   _PLAN.md       roadmap         │
                  │   _DECISIONS.md  decisions log   │
                  │   Scratch/       half-thoughts   │
                  └─────────────┬────────────────────┘
                                │  MCP servers
                       ┌────────┴────────┐
                       ▼                 ▼
                 ┌──────────┐      ┌──────────┐
                 │ Obsidian │◄────►│  Zotero  │
                 │  (notes) │ /sync│ (biblio) │
                 └──────────┘      └──────────┘

  Background runtime:
    • Drift check    every 3-4 substantive exchanges (chat ↔ vault)
    • "Lade Dr. X"   loads role-based prompt for current session
    • Old chats      remain searchable; cherry-pick into new /push
```

### Session lifecycle

```
   start
     │
     ▼
   first substantive Q ──► auto-pull of relevant meta-files
     │
     ▼
   discuss · explore · decide  ◄── drift check (periodic)
     │
     │   use /pull, /pull_path, /pull_keyword, /pull_subproject
     │   for targeted reads · /where for status synthesis
     │
     ▼
   /push  ──►  1. recap session
                2. diff plan (which files change, how)
                3. clarify ambiguous points
                4. write   (per-file confirmation)
                5. starter prompt for next chat
     │
     ▼
   end (vault updated · chat archived as history)
```

## TODO

- [ ] Test in this session: behave per new System Prompt, gather feedback
- [ ] Migrate System Prompt into PhD Claude Project, fill PhD-specific values
- [ ] Adapt PhD `_PROJECT.md`/`_PLAN.md`/`_DECISIONS.md` to new conventions if needed
- [ ] Flesh out `/sync` workflow once first Zotero ↔ Obsidian drift occurs
- [ ] Set up `Bibliography/` folder structure for PhD when needed
- [ ] Add macOS / Linux variant of `Setup_Connectors_*.md` (currently Windows-only)

### Deferred

- [ ] Move Dr. prompts to a separate `Personal_Prompts/` folder (not in this refactoring)

### Done (last 10)

- [x] 2026-05-04: Connector setup documented — `Setup_Connectors_Windows.md` added (verified Windows MSIX guide), Setup_Guide.md restructured with new Step 2 (conceptual flow + platform pointers)
- [x] 2026-05-04: Pull commands added (`/pull`, `/pull_path`, `/pull_keyword`, `/pull_subproject`); System Prompt, Conventions, Setup_Guide, Memory updated
- [x] 2026-05-04: Templates pushed to vault (8 files)
- [x] 2026-05-04: Old templates archived to `_TEMPLATES/archive/2026-05-04_pre_refactor/`
- [x] 2026-05-04: Scratch folders created (template demo + PhD)
- [x] 2026-05-04: Memory edits consolidated (3 new + 1 merged + 4 retained)
- [x] 2026-05-04: Workflow model defined (chat=WD, vault=repo, asymmetric pull/push)
- [x] 2026-05-04: Push protocol specified (5 steps)
- [x] 2026-05-04: Subproject convention established
- [x] 2026-05-04: Folder renamed (Prompt_Engineering → Claude_Research_Template)

---
