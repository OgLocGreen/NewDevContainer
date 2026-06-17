# Claude + Obsidian Workflow — Setup Guide

> Personal reference for setting up a structured workflow between Claude (claude.ai or Claude Desktop) and an Obsidian vault.
> Designed for single-user use; can be adapted for collaborators if shared.
> Last updated: 2026-05-04

---

## Contents

- [What this setup gives you](#what-this-setup-gives-you)
- [Mental model](#mental-model)
- [Prerequisites](#prerequisites)
- [Step 1: Vault structure](#step-1-vault-structure)
- [Step 2: Install MCP connectors](#step-2-install-mcp-connectors-obsidian--zotero)
- [Step 3: Set up a new flat project](#step-3-set-up-a-new-flat-project)
- [Step 4: Set up a hierarchical project](#step-4-set-up-a-hierarchical-project-parent--subprojects)
- [Step 5: How Claude behaves in a session](#step-5-how-claude-behaves-in-a-session)
- [Step 6: Cherry-picking from old chats](#step-6-cherry-picking-from-old-chats)
- [Step 7: Dr. prompts (optional)](#step-7-dr-prompts-optional)
- [Step 8: Memory edits](#step-8-memory-edits)
- [Command quick reference](#command-quick-reference)
- [FAQ](#faq)

---

## What this setup gives you

- Claude has direct read/write access to your Obsidian vault and your Zotero library via MCP servers.
- Each project has a uniform structure: status, TODOs, decision log, roadmap.
- Claude pulls vault context automatically when needed, plus explicit `/pull*` commands for targeted reads.
- Writes happen only via an explicit `/push` ritual with preview and confirmation.
- A drift check runs every few exchanges to keep chat and vault in sync.
- Hierarchical projects (parent + subprojects) are supported.
- Reusable role-based prompts ("Dr. prompts") can be activated per session.
- Old chats remain useful as cherry-pick sources, even after a fresh session is started.

---

## Mental model

**Chat = working directory.** Brainstorming, exploring, discarding hypotheses — all happens here. Ephemeral.

**Vault = repository.** Only clean, consolidated states live here. Persistent.

**The bridge between them is `/push`.** A five-step ritual that turns chat content into vault commits, with preview and confirmation at each step.

This separation is deliberate. Without it, the chat becomes either too cautious (because everything you say might be silently logged) or the vault becomes polluted with half-thoughts.

---

## Prerequisites

1. **Obsidian** installed with a vault folder on your machine.
2. **Claude Pro/Team account** at claude.ai (or Claude Desktop with at least Pro).
3. **Two MCP servers** giving Claude access to vault and bibliography:
   - Obsidian MCP server (with the Local REST API plugin in Obsidian)
   - Zotero MCP server (with API access enabled in Zotero)
4. **Zotero** installed (only if you'll use the bibliography sync feature).

The next step walks through MCP server installation in detail.

---

## Step 1: Vault structure

Create a `Projects/` folder and a templates folder inside it:

```
VaultRoot/
├── Projects/
│   ├── Claude_Research_Template/
│   │   ├── _TEMPLATES/
│   │   │   ├── _CLAUDE_PROJECT_SYSTEM_PROMPT.md
│   │   │   ├── _CONVENTIONS.md
│   │   │   ├── _PROJECT_TEMPLATE.md
│   │   │   ├── _DECISIONS_TEMPLATE.md
│   │   │   ├── _PLAN_TEMPLATE.md
│   │   │   └── _SCRATCH_TEMPLATE.md
│   │   ├── Prompts/
│   │   │   ├── Dr_Analyse.md
│   │   │   ├── Dr_Code.md
│   │   │   ├── Dr_EveryDay.md
│   │   │   └── Dr_Mail.md
│   │   ├── Setup_Guide.md   (this file)
│   │   ├── Setup_Connectors_Windows.md
│   │   └── _PROJECT.md
│   ├── YourProject1/
│   │   ├── _PROJECT.md
│   │   ├── _DECISIONS.md
│   │   ├── _PLAN.md
│   │   ├── Scratch/
│   │   └── notes/
│   └── YourProject2/
│       └── ...
```

---

## Step 2: Install MCP connectors (Obsidian + Zotero)

Claude needs two MCP servers to read and write your vault and bibliography. Installation is platform-specific — follow the guide for your system, then return here.

| Platform                                  | Guide                                                                                                                 |
| ----------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| Windows (PowerShell, Claude Desktop MSIX) | [[Setup_Connectors_Windows]] — verified 2026-05-07                                                                    |
| macOS / Linux                             | No dedicated guide yet — see [[Setup_Connectors_Windows#9-other-platforms-macos--linux]] for hints and upstream links |

> **Note:** MCP server installation procedures change with each major release. If commands fail, check the upstream repos linked in the platform guide.

When done: both servers should appear as **connected** in Claude Desktop `Settings → Developer → MCP Servers`.

---

## Step 3: Set up a new flat project

For a project without subprojects:

1. Create folder `Projects/YourProjectName/`
2. Copy `_PROJECT.md`, `_DECISIONS.md`, `_PLAN.md` from `_TEMPLATES/` and fill in
3. Create `Scratch/` folder for side notes (optional but recommended)
4. Create a Claude Project at claude.ai
5. Copy the content of `_CLAUDE_PROJECT_SYSTEM_PROMPT.md` into the Claude Project's System Prompt
6. Replace all `[PLACEHOLDERS]` (paths, project name, Zotero keys, etc.) with project-specific values
7. Optionally: add the `[PROJECT-SPECIFIC CONTEXT]` block at the bottom of the System Prompt

---

## Step 4: Set up a hierarchical project (parent + subprojects)

For projects with multiple work areas (e.g. PhD with multiple papers):

```
Projects/YourPhD/
├── _PROJECT.md         ← Overall PhD status
├── _PLAN.md            ← High-level roadmap
├── _DECISIONS.md       ← All decisions, tag by subproject
├── Scratch/            ← Idea bin (parent-level only)
├── Paper_1/
│   └── _PLAN.md        ← Paper 1 detailed plan
├── Paper_2/
│   └── _PLAN.md        ← Paper 2 detailed plan
└── Paper_3/
    └── _PLAN.md
```

**Conventions for hierarchical projects:**
- Parent always has `_PROJECT.md`, `_PLAN.md`, `_DECISIONS.md`, `Scratch/`
- Active subproject has its own `_PLAN.md`
- Decisions go to parent `_DECISIONS.md` with `[Subproject]` tag (default)
- Subproject can get its own `_DECISIONS.md` later if volume justifies it
- Scratch lives only at parent level

---

## Step 5: How Claude behaves in a session

### Auto-pull (automatic)

When you ask a substantive question that needs vault knowledge, Claude reads relevant files automatically — and tells you it's doing so ("let me read `_PROJECT.md` quickly"). No command needed.

If the vault has no answer, Claude asks whether to search the web. If yes, it always provides sources.

### Brainstorming and discussion (no command)

Talk freely. Claude does not write to the vault during normal conversation. Hypotheses, false starts, and exploratory thinking are encouraged.

### Explicit pull commands (read-only, risk-free)

When auto-pull isn't enough — for example if you want to load specific material or search across files:

| Command                   | What it does                                                                                                     |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `/pull`                   | Complete refresh: parent meta-files plus all active subproject meta-files                                        |
| `/pull_path <path>`       | Targeted file or folder. Path absolute or relative to project. Ambiguous filenames trigger a "which one?" prompt |
| `/pull_keyword <term>`    | Full-text search in current project, returns ranked snippets, then asks which files to read fully                |
| `/pull_subproject <name>` | All meta-files of a subproject. For flat projects: error message + suggestion to use `/where`                    |

These commands are non-blocking — you can ask follow-up questions immediately.

### Drift check (every 3-4 substantive exchanges)

Claude runs a compact cross-check: what have we discussed vs. what does the vault say? If something is starting to diverge from documented state, Claude flags it. You decide whether to continue or to clarify first.

This is not nagging — it's a periodic sanity check.

### `/push` (when you want to consolidate)

When the session has reached a clean state worth saving:

1. Type `/push`
2. Claude recaps what happened in the session
3. Claude proposes which vault files would change and how
4. Claude asks clarifying questions if anything is ambiguous
5. You confirm per file
6. Claude writes
7. Claude proposes a starter prompt for your next chat

If nothing meaningful happened, Claude says so and ends the ritual.

### `/where` (when you want a status synthesis)

Quick "where do we stand" overview. Claude pulls the relevant files, synthesizes, points out gaps.

### `/sync` (when bibliography needs reconciling)

Zotero ↔ Obsidian bibliography reconciliation:
- Zotero is master for paper metadata
- Obsidian is master for personal notes
- Diff is shown per category (new in Zotero, orphaned in Obsidian, metadata drift)
- Apply only after explicit confirmation

If your project doesn't have a `Bibliography/` folder yet, `/sync` will ask whether to create one.

---

## Step 6: Cherry-picking from old chats

Old chats are not lost when you start a new one. To bring something forward:

1. Open the old chat in claude.ai
2. Find the relevant decision / draft / discussion
3. In your new chat, reference it explicitly ("from chat dated YYYY-MM-DD: we decided X")
4. Include it in the next `/push`

This keeps the vault as the long-term source of truth, while old chats remain searchable history.

---

## Step 7: Dr. prompts (optional)

Specialized role-based prompts in the `Prompts/` folder:

| Trigger in chat                           | File           | Purpose                                      |
| ----------------------------------------- | -------------- | -------------------------------------------- |
| `Lade Dr. Analyse` / `Load Dr. Analyse`   | Dr_Analyse.md  | Psychological text and email analysis        |
| `Lade Dr. Mail` / `Load Dr. Mail`         | Dr_Mail.md     | Formal email optimization                    |
| `Lade Dr. EveryDay` / `Load Dr. EveryDay` | Dr_EveryDay.md | Everyday questions, technology, organization |
| `Lade Dr. Code` / `Load Dr. Code`         | Dr_Code.md     | Programming, debugging, architecture         |

**Usage:** type `Lade Dr. Code` (or `Load Dr. Code`) in chat — Claude reads the prompt from the vault and adopts its rules for the session.

**Adding new ones:** create `Prompts/Dr_[Name].md` and add a memory edit so Claude recognizes the trigger.

---

## Step 8: Memory edits

For Claude to remember the workflow across sessions, set these via Claude's memory feature:

**Memory 1 — workflow:**
> Vault = single source of truth. Pulls automatic when needed; explicit commands `/pull`, `/pull_path`, `/pull_keyword`, `/pull_subproject` for targeted reads. Writes only via `/push` (5-step ritual: recap → diff plan → clarify → write → closer). Drift check every 3-4 substantive exchanges. Never delete vault files — move to `archive/` (exception: `Scratch/`). `Scratch/` folder per parent project for half-formed ideas.

**Memory 2 — vault path:**
> Obsidian vault root: `[YOUR_VAULT_PATH]` — connected via obsidian-vault MCP server with full read/write access.

**Memory 3 — Dr. prompt trigger:**
> When the user says "Lade Dr. X" or "Load Dr. X" (e.g. "Lade Dr. Code"), read `Projects/Claude_Research_Template/Prompts/Dr_[Name].md` and adopt its rules for the session. Available: Dr_Analyse, Dr_Code, Dr_EveryDay, Dr_Mail.

Plus per-project memories with topic, Zotero collection keys, and any persistent context.

---

## Command quick reference

```
Read (no risk):
  /where                       Status synthesis with auto-pull of relevant meta-files
  /pull                        Complete project refresh (parent + active subprojects)
  /pull_path <path>            Targeted file/folder pull
  /pull_keyword <term>         Full-text search in current project
  /pull_subproject <name>      All meta-files of one subproject

Write (ritual):
  /push                        5-step consolidation: recap → diff → clarify → write → closer

Sync (special case):
  /sync                        Zotero ↔ Obsidian bibliography reconciliation
```

---

## FAQ

**Do I need Claude Pro?**
Yes — MCP server access requires at least a Pro account.

**Does this work on mobile?**
MCP servers are currently desktop/web only. On mobile, you can fall back to plain Claude Projects with the System Prompt pasted in (no live vault access).

**Can I load multiple Dr. prompts at once?**
No — one per session. A new "Lade Dr. X" replaces the previous one.

**What if I edit a vault file manually?**
Claude picks up changes the next time it reads the file. Manual edits are always allowed and expected. Use `/pull` to force a refresh after manual edits.

**Can Claude delete files?**
No — only moves to `archive/`. The only exception is `Scratch/`, where deletion is fine. Manual deletion of other files is your call.

**What happens if `/push` fails or I forget it?**
The session content stays in the chat. Open it later, cherry-pick what you need into a new `/push`. Nothing is lost.

**How do I share this template with collaborators?**
Send them the entire `Claude_Research_Template/` folder. They follow the steps in this guide. Their vault and Claude Project will be independent of yours.

**MCP servers stop working mid-session — what now?**
Restart Claude Desktop completely (including from system tray). Keep Obsidian and Zotero running. If problems persist, see the troubleshooting table in [[Setup_Connectors_Windows#7 Troubleshooting]].
