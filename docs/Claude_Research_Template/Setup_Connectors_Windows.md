# Setup: Obsidian + Zotero MCP for Claude Desktop (Windows)

> Step-by-step guide for setting up the MCP servers for Obsidian and Zotero on Windows with Claude Desktop (MSIX / Store version).
>
> **Verified:** 2026-05-12
>
> **Obsidian variants:** Filesystem MCP (Variant A, default) vs. Local REST API (Variant B, advanced). See `_DECISIONS.md` for the active choice.
>
> **Zotero package-name note:** the correct PyPI package is `zotero-mcp-server` (by 54yyyu), **not** `zotero-mcp`. Both exist on PyPI and both ship a CLI called `zotero-mcp` — installing the wrong one causes silent failures. The required `env` block (including `ZOTERO_LOCAL=true`) is documented in Sections 3.2 and 4.4.

**Target system:** Windows, PowerShell, Claude Desktop MSIX
**Example paths in this guide:** replace `YOUR_USERNAME` and `YOUR_VAULT_PATH` with your actual values.

For the full workflow guide (sessions, `/push`, Dr. prompts, etc.), see [Setup_Guide](Setup_Guide.md).
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
| Status                       | **Default (recommended)** | Alternative               |
| Local REST API plugin needed | no                        | yes                       |
| Obsidian must be running     | no                        | yes                       |
| Read/write/search files      | yes                       | yes                       |
| Resolve Dataview queries     | no                        | yes                       |
| Resolve backlinks (semantic) | no (full-text only)       | yes                       |
| Use tag indexes              | no                        | yes                       |
| Setup complexity             | low                       | medium                    |

**Recommendation:** Variant A is sufficient for projects following the `_PROJECT.md` / `_DECISIONS.md` / `_PLAN.md` convention. Switch to Variant B if you need Dataview output, plugin state, or resolved backlinks.

Record the active choice in `_DECISIONS.md`.

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

> **Note on Python 3.14+:** if `pip install zotero-mcp-server` fails with build errors (missing wheels for native dependencies), fall back to a venv with Python 3.12.

### 1.3 Enable PowerShell ExecutionPolicy for npm

PowerShell blocks scripts like `npm.ps1` by default. Set once per user (no admin required):

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Confirm with `Y`.

### 1.4 Install Obsidian

```powershell
winget install Obsidian.Obsidian
```

Alternative: installer from https://obsidian.md.

On first start: select **Open folder as vault** and point to your vault directory, e.g.:

```
C:\Users\YOUR_USERNAME\Documents\my-obsidian-vault
```

For Variant A, Obsidian does not need to be running at runtime — but installing it is recommended so you can edit notes interactively.

---

## 2. Set up Zotero (both variants)

### 2.1 Enable local API access in Zotero

```
Edit → Settings → Advanced → Allow other applications on this computer to communicate with Zotero
```

Enable the toggle. Zotero must be running whenever Claude Desktop uses the Zotero MCP server.

### 2.2 Verify the Zotero local API

```powershell
curl.exe http://localhost:23119/api/users/0/items?limit=1
```

Expected: JSON with one item. If this fails, Zotero is not running or the toggle is off.

### 2.3 Install the Zotero MCP server

> **⚠ Package-name trap:** two different projects on PyPI share a similar name:
>
> - `zotero-mcp` — older, unrelated project — **do not install this**
> - `zotero-mcp-server` — by 54yyyu, the correct package — **install this**
>
> Both ship a CLI named `zotero-mcp`. Installing the wrong one causes silent failures: Claude shows the server as connected, but tool calls return errors.
>
> Check what is currently installed:
> ```powershell
> python -m pip show zotero-mcp
> python -m pip show zotero-mcp-server
> ```
> If `zotero-mcp` (the wrong one) is installed, uninstall it first:
> ```powershell
> python -m pip uninstall zotero-mcp -y
> ```

Install the correct package:

```powershell
python -m pip install zotero-mcp-server
```

Optional — if you want semantic search over your library:

```powershell
python -m pip install "zotero-mcp-server[semantic]"
```

Find the executable path:

```powershell
where.exe zotero-mcp
```

Note the full path — you will need it in the config (Sections 3.2 / 4.4).

If `where.exe zotero-mcp` returns nothing, the user-Scripts folder is not in PATH. Add it:

```powershell
$scriptsPath = python -c "import sysconfig; print(sysconfig.get_path('scripts', 'nt_user'))"
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "User") + ";$scriptsPath", "User")
```

**Reopen PowerShell**, then run `where.exe zotero-mcp` again.

> **About `zotero-mcp setup`:** the auto-setup helper writes to the classic config path (`%APPDATA%\Claude\claude_desktop_config.json`) instead of the MSIX path. Claude Desktop MSIX will not read that file. **Skip `zotero-mcp setup` and configure manually** as described in Section 5.

---

## 3. Variant A — Filesystem MCP (default, currently active)

This variant uses the official Anthropic filesystem MCP server pointed at the vault directory. It does **not** require Obsidian to be running and does **not** require any Obsidian plugin. Trade-off: the server sees plain Markdown files only — no Dataview output, no resolved backlinks, no tag index. Full-text search still works.

### 3.1 Install the filesystem MCP server

```powershell
npm install -g @modelcontextprotocol/server-filesystem
```

A global install avoids the first-run download delay when using `npx`.

### 3.2 Config snippet for Claude Desktop

```json
{
  "mcpServers": {
    "obsidian-vault": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "C:\\Users\\YOUR_USERNAME\\Documents\\YOUR_VAULT_PATH"
      ]
    },
    "zotero": {
      "command": "C:\\Users\\YOUR_USERNAME\\AppData\\Local\\Packages\\PythonSoftwareFoundation.Python.3.13_qbz5n2kfra8p0\\LocalCache\\local-packages\\Python313\\Scripts\\zotero-mcp.exe",
      "args": [
        "serve"
      ],
      "env": {
        "ZOTERO_LOCAL": "true",
        "ZOTERO_EMBEDDING_MODEL": "default",
        "ZOTERO_API_KEY": "YOUR_ZOTERO_API_KEY",
        "ZOTERO_LIBRARY_ID": "YOUR_ZOTERO_LIBRARY_ID"
      }
    }
  }
}
```

**What to replace:**

| Placeholder              | Where to find the value                                                          |
| ------------------------ | -------------------------------------------------------------------------------- |
| `YOUR_USERNAME`          | Your Windows username                                                            |
| `YOUR_VAULT_PATH`        | Path to your Obsidian vault folder                                               |
| `zotero-mcp.exe` path    | Output of `where.exe zotero-mcp` (path may differ for Python 3.11/3.12 installs) |
| `YOUR_ZOTERO_API_KEY`    | Zotero → Settings → Advanced → API keys                                          |
| `YOUR_ZOTERO_LIBRARY_ID` | Numeric ID visible in the Zotero web interface URL                               |

**Notes:**
- The `env` block is **required**. Without `ZOTERO_LOCAL: "true"` the server attempts to reach the Zotero Cloud API and fails.
- `ZOTERO_EMBEDDING_MODEL: "default"` uses a local model (`all-MiniLM-L6-v2`) — no data leaves your machine. Only relevant if you installed the `[semantic]` extra; harmless otherwise.
- Double all backslashes in JSON paths.

→ Continue with [Section 5 (Configure Claude Desktop)](#5-configure-claude-desktop-both-variants) and [Section 6 (Verification)](#6-verification).

---

## 4. Variant B — Local REST API (alternative)

Use this variant if you need Obsidian-specific features: resolved Dataview queries, semantic backlinks, or plugin state. Requires Obsidian to be running while Claude Desktop is active.

### 4.1 Enable the Local REST API plugin

1. `Settings → Community plugins → Turn on community plugins` (one-time opt-in)
2. `Browse → "Local REST API"` → **Install** → **Enable**
3. `Settings → Local REST API`:
   - **Copy the API key** (long string, needed in the config)
   - Note the ports: `27124` (HTTPS), `27123` (HTTP)

### 4.2 Verify the API connection

```powershell
curl.exe -k https://127.0.0.1:27124/ -H "Authorization: Bearer YOUR_OBSIDIAN_API_KEY"
```

Expected response: `{"status":"OK",...}`.

### 4.3 Install the Obsidian MCP server

```powershell
npm install -g obsidian-mcp-server
```

> **Note:** several Obsidian MCP implementations exist (`obsidian-mcp-server` by cyanheads, `mcp-obsidian` by MarkusPfundstein). Both use the Local REST API. Pick one and record the choice in `_DECISIONS.md`.

### 4.4 Config snippet for Claude Desktop

```json
{
  "mcpServers": {
    "obsidian-vault": {
      "command": "npx",
      "args": ["-y", "obsidian-mcp-server"],
      "env": {
        "OBSIDIAN_API_KEY": "YOUR_OBSIDIAN_API_KEY",
        "OBSIDIAN_VAULT_PATH": "C:\\Users\\YOUR_USERNAME\\Documents\\YOUR_VAULT_PATH"
      }
    },
    "zotero": {
      "command": "C:\\Users\\YOUR_USERNAME\\AppData\\Local\\Packages\\PythonSoftwareFoundation.Python.3.13_qbz5n2kfra8p0\\LocalCache\\local-packages\\Python313\\Scripts\\zotero-mcp.exe",
      "args": [
        "serve"
      ],
      "env": {
        "ZOTERO_LOCAL": "true",
        "ZOTERO_EMBEDDING_MODEL": "default",
        "ZOTERO_API_KEY": "YOUR_ZOTERO_API_KEY",
        "ZOTERO_LIBRARY_ID": "YOUR_ZOTERO_LIBRARY_ID"
      }
    }
  }
}
```

**What to replace:** same placeholders as Section 3.2, plus `YOUR_OBSIDIAN_API_KEY` from the Local REST API plugin settings.

→ Continue with [Section 5 (Configure Claude Desktop)](#5-configure-claude-desktop-both-variants) and [Section 6 (Verification)](#6-verification).

---

## 5. Configure Claude Desktop (both variants)

### 5.1 Find the config file

Claude Desktop stores its config in different locations depending on how it was installed.

#### Step 1 — Search automatically (recommended)

```powershell
Get-ChildItem "$env:APPDATA","$env:LOCALAPPDATA" -Filter "claude_desktop_config.json" -Recurse -ErrorAction SilentlyContinue
```

This prints the full path. To reuse it in Steps 3 and 4, capture it in the same PowerShell session:

```powershell
$claudeConfig = (Get-ChildItem "$env:APPDATA","$env:LOCALAPPDATA" -Filter "claude_desktop_config.json" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
```

#### Step 2 — Known paths by install type

| Install type                  | Config path                                                                                           |
| ----------------------------- | ----------------------------------------------------------------------------------------------------- |
| **MSIX / Microsoft Store**    | `$env:LOCALAPPDATA\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\claude_desktop_config.json`  |
| **Classic installer (.exe)**  | `$env:APPDATA\Claude\claude_desktop_config.json`                                                         |

> **Which version do you have?** Open Claude Desktop → `Help → About`. If the version string ends with `(Store)` or you installed via the Microsoft Store, you have the MSIX version.

#### Step 3 — Open the config file

Using the `$claudeConfig` variable from Step 1:

```powershell
notepad $claudeConfig
```

Or open the containing folder in Windows Explorer to edit with any editor:

```powershell
explorer (Split-Path $claudeConfig)
```

#### Step 4 — Create the file if it does not exist

If `$claudeConfig` is empty (Step 1 found nothing), create the file first:

```powershell
# MSIX version — create directory and file (BOM-free UTF-8)
$claudeDir = "$env:LOCALAPPDATA\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude"
New-Item -ItemType Directory -Force $claudeDir | Out-Null
[System.IO.File]::WriteAllText("$claudeDir\claude_desktop_config.json", '{}', [System.Text.UTF8Encoding]::new($false))
```

Then open it and replace `{}` with the full JSON from Section 3.2 or 4.4.

> **PowerShell quoting:** paths containing `$env:` must be in **double quotes**, e.g. `"$env:LOCALAPPDATA\Packages\..."`. Single quotes will not expand the variable.

### 5.2 Insert the config snippet

Use the JSON from Section 3.2 (Variant A) or Section 4.4 (Variant B). If `mcpServers` already has entries, **merge** — do not overwrite the entire file.

### 5.3 Restart Claude Desktop

Close fully — including from the system tray. Then restart.

Go to `Settings → Developer → MCP Servers`. Both servers should show as **connected** (green).

---

## 6. Verification

Open a new Claude chat and run these quick checks:

- **Obsidian:** "List the top-level folders of my vault"
- **Zotero:** "Show me the last 5 items in my Zotero library"

Both should return results without errors.

**How to identify the active Obsidian variant:**

| Variant        | Tool names visible in Claude                                                                 |
| -------------- | -------------------------------------------------------------------------------------------- |
| A (Filesystem) | `read_text_file`, `list_directory`, `directory_tree`, `move_file`, `edit_file`, `write_file` |
| B (REST API)   | `obsidian_search_notes`, `obsidian_get_note`, `obsidian_list_files_in_vault`                 |

**Zotero tools (zotero-mcp-server):** `zotero_search_items`, `zotero_search_by_tag`, `zotero_get_item_metadata`, `zotero_get_item_fulltext`, `zotero_semantic_search` (requires `[semantic]` extra), `zotero_update_search_database`.

After successful setup, record the active variants and package versions in your project's `_DECISIONS.md`.

---

## 7. Troubleshooting

| Symptom                                          | Cause                                                                       | Fix                                                                                                              |
| ------------------------------------------------ | --------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `npm` blocked with `UnauthorizedAccess`          | Restrictive ExecutionPolicy                                                 | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`                                                            |
| `pip` not found                                  | Scripts folder not in PATH                                                  | Use `python -m pip install ...` instead of `pip`                                                                 |
| `where.exe zotero-mcp` returns empty             | User-Scripts folder not in PATH                                             | Add it via `[Environment]::SetEnvironmentVariable(...)` (see Section 2.3)                                        |
| MCP server shows red in Claude                   | Wrong config path or invalid JSON                                           | Re-locate path with `Get-ChildItem`; validate JSON syntax                                                        |
| Variant A: "path not allowed" error              | Vault path missing from `args`                                              | Add vault directory to the filesystem server's `args`; restart Claude Desktop                                    |
| Variant B: API returns nothing                   | Plugin not enabled or Obsidian closed                                       | Keep Obsidian open; check plugin status                                                                          |
| Zotero connected but tool calls fail             | Wrong package (`zotero-mcp` not `zotero-mcp-server`) or missing `env` block | Run `pip show` checks from Section 2.3; reinstall; add `env` block                                               |
| Zotero API returns nothing                       | Zotero not running or local API toggle off                                  | Start Zotero; check Settings → Advanced                                                                          |
| Zotero: "Missing required environment variables" | `env` block absent or `ZOTERO_LOCAL` not set                                | Add `"env": { "ZOTERO_LOCAL": "true", ... }` to the zotero config entry                                          |
| `pip install zotero-mcp-server` fails to build   | Python version too new — no pre-built wheels                                | Create a venv with Python 3.12                                                                                   |
| Semantic search returns no results               | Embedding DB not built yet                                                  | Run `zotero-mcp update-db --force-rebuild`                                                                       |
| ChromaDB / stale embedding model errors          | Embedding model changed after initial build                                 | Run `zotero-mcp update-db --force-rebuild`; if it persists, delete `~/.config/zotero-mcp/chroma_db/` and rebuild |

---

## 8. Maintenance

```powershell
# Check for updates without installing
zotero-mcp update --check-only

# Update to latest version (config is preserved)
zotero-mcp update

# Rebuild the semantic-search database
zotero-mcp update-db --force-rebuild

# Rebuild with full-text indexing (slower, more thorough)
zotero-mcp update-db --fulltext --force-rebuild
```

---

## 9. Other platforms (macOS / Linux)

No dedicated guide exists yet. The setup flow is the same — install Node.js and Python, install both MCP servers, register them in the Claude Desktop config — but the details differ:

| Aspect                     | macOS                                                             | Linux                                               |
| -------------------------- | ----------------------------------------------------------------- | --------------------------------------------------- |
| Node.js / Python install   | `brew install node python`                                        | `apt install nodejs python3` (or distro equivalent) |
| Claude Desktop config path | `~/Library/Application Support/Claude/claude_desktop_config.json` | `~/.config/Claude/claude_desktop_config.json`       |
| ExecutionPolicy step       | not needed                                                        | not needed                                          |
| Zotero MCP executable      | `~/.local/bin/zotero-mcp` (typical)                               | `~/.local/bin/zotero-mcp` (typical)                 |

The JSON config format (Sections 3.2 and 4.4) is identical across platforms — only the paths and the config file location differ. The package-name trap (Section 2.3) and the `env` block requirement apply on all platforms.

**Upstream documentation:**
- Obsidian Local REST API plugin: https://github.com/coddingtonbear/obsidian-local-rest-api
- obsidian-mcp-server (cyanheads): https://github.com/cyanheads/obsidian-mcp-server
- zotero-mcp-server (54yyyu): https://github.com/54yyyu/zotero-mcp

Contributions welcome — create `Setup_Connectors_macOS.md` or `Setup_Connectors_Linux.md` following the structure of this file.
