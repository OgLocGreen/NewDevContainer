# Setup: Obsidian + Zotero MCP for Claude Desktop (Windows)

> Step-by-step guide for setting up the MCP servers for Obsidian and Zotero on Windows with Claude Desktop (MSIX / Store version).
> **Verified:** 2026-05-07. **Restructured:** 2026-05-07 — Filesystem MCP is Variant A (default, currently active), Local REST API is Variant B (alternative for advanced Obsidian features). See `_DECISIONS.md`.
> **2026-05-07 fix:** corrected Zotero PyPI package name (`zotero-mcp-server`, not `zotero-mcp` — there are two different projects on PyPI with similar names) and added the required `env` block with `ZOTERO_LOCAL=true`. Without this fix the server starts but cannot reach the local Zotero API.

**Target system:** Windows, PowerShell, Claude Desktop MSIX
**Example vault path used in this guide:** `C:\Users\ogloc\Desktop\OgLocGreenSpace\docs\oglocgreen_obsidian` — replace with your own.

For the full workflow guide (sessions, `/push`, Dr. prompts, etc.), see [[Setup_Guide]].
For other platforms, see [Section 9](#9-other-platforms-macos--linux).

---

## Contents

- [0. Choose a variant](#0-choose-a-variant)
- [1. Prerequisites](#1-prerequisites-both-variants)
- [2. Set up Zotero](#2-set-up-zotero-both-variants)
- [3. Variant A — Filesystem MCP (default)](#3-variant-a--filesystem-mcp-default-currently-active)
- [4. Variant B — Local REST API (alternative)](#4-variant-b--local-rest-api-alternative)
- [5. Configure Claude Desktop](#5-configure-claude-desktop-both-variants)
- [6. Verification](#6-verification)
- [7. Troubleshooting](#7-troubleshooting)
- [8. Maintenance](#8-maintenance)
- [9. Other platforms (macOS / Linux)](#9-other-platforms-macos--linux)

---

## 0. Choose a variant

|                              | Variant A: Filesystem MCP | Variant B: Local REST API |
| ---------------------------- | ------------------------- | ------------------------- |
| Status                       | **Currently active**      | Alternative               |
| Local REST API plugin needed | no                        | yes                       |
| Obsidian must be running     | no                        | yes                       |
| Read/write/search files      | yes                       | yes                       |
| Resolve Dataview queries     | no                        | yes                       |
| Resolve backlinks (semantic) | no (full-text only)       | yes                       |
| Use tag indexes              | no                        | yes                       |
| Setup complexity             | low                       | medium                    |

**Recommendation:** Variant A is sufficient for projects following the `_PROJECT.md` / `_DECISIONS.md` / `_PLAN.md` convention. Switch to Variant B if you need Dataview output, plugin state, or resolved backlinks.

The decision currently in effect is logged in `_DECISIONS.md`.

---

## 1. Prerequisites (both variants)

### 1.1 Node.js

```powershell
node --version
```

If not present:

```powershell
winget install OpenJS.NodeJS.LTS
```

After install, **close and reopen PowerShell**, then verify:

```powershell
node --version
npm --version
```

### 1.2 Python

```powershell
python --version
```

Expected: 3.10 or newer. If not present:

```powershell
winget install Python.Python.3.12
```

Note: Python 3.14 is very recent. If `pip install zotero-mcp-server` fails with build errors (e.g. missing wheels for native dependencies), fall back to a venv with Python 3.12. Not verified whether `zotero-mcp-server` builds cleanly with 3.14.

### 1.3 Enable PowerShell ExecutionPolicy for npm

PowerShell blocks scripts like `npm.ps1` by default. Set once per user (no admin needed):

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Confirm with `Y`.

### 1.4 Install Obsidian

```powershell
winget install Obsidian.Obsidian
```

Alternative: installer from https://obsidian.md.

On first start: select **Open folder as vault** and point to your existing vault, e.g.:

```
C:\Users\ogloc\Desktop\OgLocGreenSpace\docs\oglocgreen_obsidian
```

For Variant A, Obsidian itself is not strictly required at runtime — but installing it is recommended so you can edit notes interactively.

---

## 2. Set up Zotero (both variants)

### 2.1 Start Zotero and enable API access

In Zotero:

```
Edit → Settings → Advanced → Allow other applications on this computer to communicate with Zotero
```

Enable. Zotero must be running whenever Claude Desktop is using the MCP server.

### 2.2 Verify the Zotero API

```powershell
curl.exe http://localhost:23119/api/users/0/items?limit=1
```

Should return JSON with one item.

### 2.3 Install the Zotero MCP server

> **⚠ Package-name trap:** there are two different projects on PyPI:
>
> - `zotero-mcp` (older, unrelated project, last released April 2025) — **don't install this one**
> - `zotero-mcp-server` (by 54yyyu, the project we want) — **install this one**
>
> Both projects ship a CLI named `zotero-mcp` (yes, confusing). Installing the wrong package leads to subtle failures: the server starts, Claude shows it as connected, but tool calls return errors because the CLI doesn't recognize `serve` or doesn't accept the same env variables.
>
> Check what you have:
> ```powershell
> python -m pip show zotero-mcp
> python -m pip show zotero-mcp-server
> ```
> If `zotero-mcp` is installed: `python -m pip uninstall zotero-mcp -y` first.

Install the correct package:

```powershell
python -m pip install zotero-mcp-server
```

Optional — if you want semantic search over your library:

```powershell
python -m pip install "zotero-mcp-server[semantic]"
```

Resolve path to the executable:

```powershell
where.exe zotero-mcp
```

Note the full path — needed in the config (Section 3.2 / 4.4).

If `where.exe zotero-mcp` returns nothing, the user-Scripts folder is not in PATH. Add it once:

```powershell
$scriptsPath = python -c "import sysconfig; print(sysconfig.get_path('scripts', 'nt_user'))"
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "User") + ";$scriptsPath", "User")
```

Then **reopen PowerShell** and run `where.exe zotero-mcp` again.

> **About `zotero-mcp setup`:** the auto-setup helper does work for the 54yyyu package, but on Claude Desktop **MSIX** (Store version) it writes to the classic config path (`%APPDATA%\Claude\claude_desktop_config.json`) instead of the MSIX path (`%LOCALAPPDATA%\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\claude_desktop_config.json`). The result: a config file in the wrong place that Claude doesn't read. **On MSIX: skip `zotero-mcp setup` and edit the config manually** as described in Section 5.

---

## 3. Variant A — Filesystem MCP (default, currently active)

This variant uses the official Anthropic filesystem MCP server pointed directly at the vault directory. It does **not** need Obsidian to be running and does **not** require any Obsidian plugin. The trade-off: the server sees plain Markdown files only — no Dataview output, no resolved backlinks, no tag index. Full-text search across files still works.

### 3.1 Install the filesystem MCP server

The server is shipped as `@modelcontextprotocol/server-filesystem`. It runs via `npx` on demand, but a global install avoids first-run delay:

```powershell
npm install -g @modelcontextprotocol/server-filesystem
```

### 3.2 Config snippet for Claude Desktop

```json
{
  "mcpServers": {
    "obsidian-vault": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "C:\\Users\\ogloc\\Desktop\\OgLocGreenSpace\\docs\\oglocgreen_obsidian"
      ]
    },
    "zotero": {
      "command": "C:\\path\\to\\zotero-mcp.exe",
      "args": ["serve"],
      "env": {
        "ZOTERO_LOCAL": "true",
        "ZOTERO_EMBEDDING_MODEL": "default"
      }
    }
  }
}
```

Adjustments:

- Replace the vault path with your own (double the backslashes in JSON)
- Replace `C:\\path\\to\\zotero-mcp.exe` with the result of `where.exe zotero-mcp`
- The `env` block is **required**. Without `ZOTERO_LOCAL: "true"` the server tries to talk to the Zotero Web API and fails (there's no API key set).
- `ZOTERO_EMBEDDING_MODEL: "default"` uses the local embedding model (`all-MiniLM-L6-v2`) — no data leaves your machine. Only relevant if you installed the `[semantic]` extra; harmless otherwise.

→ Continue with Section 5 (Configure Claude Desktop) and Section 6 (Verification).

---

## 4. Variant B — Local REST API (alternative)

Use this variant if you need Obsidian-specific features such as resolved Dataview queries, semantic backlinks, or plugin state. Requires Obsidian to be running while Claude Desktop is in use.

### 4.1 Enable Local REST API plugin

This plugin is the bridge that the MCP server needs to talk to.

1. `Settings → Community plugins → Turn on community plugins` (one-time opt-in)
2. `Browse → "Local REST API"` → **Install** → **Enable**
3. `Settings → Local REST API`:
   - **Copy the API key** (long string, needed in the config)
   - Note the ports: `27124` (HTTPS), `27123` (HTTP)

### 4.2 Verify the API connection

```powershell
curl.exe -k https://127.0.0.1:27124/ -H "Authorization: Bearer YOUR_API_KEY"
```

Expected response: JSON with `{"status":"OK",...}`.

### 4.3 Install Obsidian MCP server

```powershell
npm install -g obsidian-mcp-server
```

Note install path (can be retrieved with `npm root -g`).

Note: there are several Obsidian MCP implementations (`obsidian-mcp-server` by cyanheads, `mcp-obsidian` by MarkusPfundstein). Both use the Local REST API. Pick one and record the choice in `_DECISIONS.md`.

### 4.4 Config snippet for Claude Desktop

```json
{
  "mcpServers": {
    "obsidian-vault": {
      "command": "npx",
      "args": ["-y", "obsidian-mcp-server"],
      "env": {
        "OBSIDIAN_API_KEY": "YOUR_API_KEY",
        "OBSIDIAN_VAULT_PATH": "C:\\Users\\ogloc\\Desktop\\OgLocGreenSpace\\docs\\oglocgreen_obsidian"
      }
    },
    "zotero": {
      "command": "C:\\path\\to\\zotero-mcp.exe",
      "args": ["serve"],
      "env": {
        "ZOTERO_LOCAL": "true",
        "ZOTERO_EMBEDDING_MODEL": "default"
      }
    }
  }
}
```

Adjustments:

- Replace `YOUR_API_KEY` with the Local REST API key from Obsidian
- Replace `C:\\path\\to\\zotero-mcp.exe` with the result of `where.exe zotero-mcp` (double the backslashes)
- Replace the vault path with your own
- Same Zotero `env` requirement as Variant A — see Section 3.2 notes

→ Continue with Section 5 (Configure Claude Desktop) and Section 6 (Verification).

---

## 5. Configure Claude Desktop (both variants)

### 5.1 Find the config file (MSIX path)

```powershell
Get-ChildItem "$env:APPDATA","$env:LOCALAPPDATA" -Filter "claude_desktop_config.json" -Recurse -ErrorAction SilentlyContinue
```

Expected path on the MSIX version:

```
$env:LOCALAPPDATA\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\claude_desktop_config.json
```

If the file doesn't exist: create it.

> **PowerShell quoting:** paths with `$env:` variables must always be in **double quotes**, e.g. `"$env:LOCALAPPDATA\Packages\..."`. Without quotes you get a parser error.

### 5.2 Insert the config snippet

Use the JSON from Section 3.2 (Variant A) or Section 4.4 (Variant B). If you already have entries under `mcpServers`, merge — don't overwrite.

### 5.3 Restart Claude Desktop

Close completely — including from the system tray. Then restart.

In Settings under `Developer → MCP Servers`, both servers should appear as **connected**.

---

## 6. Verification

In a new Claude chat:

- Test Obsidian: "List the top-level folders of my vault"
- Test Zotero: "Show me the last 5 items in my Zotero library"

Both should run without errors.

**How to tell which Obsidian variant is actually loaded:**

- **Variant A (Filesystem):** Tools have generic names like `read_text_file`, `list_directory`, `directory_tree`, `move_file`, `edit_file`, `write_file`.
- **Variant B (REST API):** Tools have Obsidian-specific names like `obsidian_search_notes`, `obsidian_get_note`, `obsidian_list_files_in_vault`.

**Zotero tools you should see (zotero-mcp-server):** `zotero_search_items`, `zotero_search_by_tag`, `zotero_get_item_metadata`, `zotero_get_item_fulltext`, `zotero_semantic_search` (with `[semantic]` extra), `zotero_update_search_database`.

After successful setup, log it as a decision in your project's `_DECISIONS.md` (which variants, which versions, date) — see Conventions in `_TEMPLATES/_CONVENTIONS.md`.

---

## 7. Troubleshooting

| Symptom                                            | Cause                                                                                        | Fix                                                                                                         |
| -------------------------------------------------- | -------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `npm` blocked with `UnauthorizedAccess`            | Restrictive ExecutionPolicy                                                                  | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`                                                       |
| `pip` not found                                    | Scripts folder not in PATH                                                                   | Use `python -m pip install ...` instead of `pip`                                                            |
| `where.exe zotero-mcp` returns empty               | User-Scripts folder not in PATH                                                              | Add it via `[Environment]::SetEnvironmentVariable(...)` (see Section 2.3)                                   |
| MCP server shows red in Claude                     | Wrong config path or broken JSON                                                             | Re-locate path with `Get-ChildItem`, validate JSON                                                          |
| Variant A: tool calls fail with "path not allowed" | Vault path missing from `args` of filesystem server                                          | Add vault directory to `args`; restart Claude Desktop                                                       |
| Variant B: API returns nothing                     | Plugin not active or Obsidian closed                                                         | Keep Obsidian open, check plugin status                                                                     |
| Zotero shows connected but tool calls fail         | Wrong package installed (`zotero-mcp` instead of `zotero-mcp-server`) OR missing `env` block | Run `pip show` checks from Section 2.3, reinstall, add `env` block                                          |
| Zotero API returns nothing                         | Zotero not open or API toggle off                                                            | Start Zotero, check Settings                                                                                |
| Zotero: "Missing required environment variables"   | `env` block missing or `ZOTERO_LOCAL` not set                                                | Add `"env": { "ZOTERO_LOCAL": "true", ... }` to the `zotero` server config                                  |
| `pip install zotero-mcp-server` fails to build     | Python 3.14 too new for native wheels                                                        | Create venv with Python 3.12                                                                                |
| Semantic search returns no results                 | Embedding DB not built                                                                       | `zotero-mcp update-db --force-rebuild`                                                                      |
| ChromaDB / stale embedding model errors            | Changed embedding model after first build                                                    | `zotero-mcp update-db --force-rebuild`; if persistent, delete `~/.config/zotero-mcp/chroma_db/` and rebuild |

---

## 8. Maintenance

```powershell
# Check for updates without installing
zotero-mcp update --check-only

# Update to latest version (preserves config)
zotero-mcp update

# Rebuild semantic-search DB
zotero-mcp update-db --force-rebuild

# Rebuild with full-text indexing (slower, more thorough)
zotero-mcp update-db --fulltext --force-rebuild
```

---

## 9. Other platforms (macOS / Linux)

No dedicated guide exists yet. The setup flow is the same as on Windows — install Node.js and Python, install the two MCP servers, register them in the Claude Desktop config — but the details differ:

| Aspect                     | macOS                                                             | Linux                                               |
| -------------------------- | ----------------------------------------------------------------- | --------------------------------------------------- |
| Node.js / Python install   | `brew install node python`                                        | `apt install nodejs python3` (or distro equivalent) |
| Claude Desktop config path | `~/Library/Application Support/Claude/claude_desktop_config.json` | `~/.config/Claude/claude_desktop_config.json`       |
| ExecutionPolicy step       | not needed                                                        | not needed                                          |
| Zotero MCP executable      | `~/.local/bin/zotero-mcp` (typical)                               | `~/.local/bin/zotero-mcp` (typical)                 |

**Upstream documentation:**
- Obsidian Local REST API plugin: https://github.com/coddingtonbear/obsidian-local-rest-api
- obsidian-mcp-server (cyanheads): https://github.com/cyanheads/obsidian-mcp-server
- zotero-mcp-server (54yyyu): https://github.com/54yyyu/zotero-mcp

The config JSON format (Sections 3.2 and 4.4) is identical across platforms — only paths and the config file location differ. The package-name trap (Section 2.3) and the `env` block requirement apply on all platforms.

A contributions welcome — create `Setup_Connectors_macOS.md` or `Setup_Connectors_Linux.md` following the structure of this file.
