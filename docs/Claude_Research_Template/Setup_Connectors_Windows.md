# Setup: Obsidian + Zotero MCP for Claude Desktop (Windows)

> Step-by-step guide for setting up the MCP servers for Obsidian and Zotero on Windows with Claude Desktop (MSIX / Store version).
> **Verified:** 2026-05-04. **Restructured:** 2026-05-07 — Filesystem MCP is now Variant A (default, currently active), Local REST API is Variant B (alternative for advanced Obsidian features). See `_DECISIONS.md`.

**Target system:** Windows, PowerShell, Claude Desktop MSIX
**Example vault path used in this guide:** `C:\Users\ogloc\Desktop\OgLocGreenSpace\docs\oglocgreen_obsidian` — replace with your own.

This guide is platform-specific. For the conceptual overview that applies to all platforms, see [[Setup_Guide#Step 2: Install MCP connectors]].

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

Note: Python 3.14 is very recent. If `pip install zotero-mcp` fails with build errors (e.g. missing wheels for native dependencies), fall back to a venv with Python 3.12. Not verified whether `zotero-mcp` builds cleanly with 3.14.

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

Enable.

### 2.2 Verify the Zotero API

```powershell
curl.exe http://localhost:23119/api/users/0/items?limit=1
```

Should return JSON with one item (Zotero must be running).

### 2.3 Install Zotero MCP server

```powershell
python -m pip install zotero-mcp
```

Resolve path to the executable:

```powershell
where.exe zotero-mcp
```

Note the path — needed in the config.

Important: **do not use `zotero-mcp setup`** — it has been observed to write to the wrong path on MSIX installations.

---

## 3. Variant A — Filesystem MCP (default, currently active)

This variant uses the official Anthropic filesystem MCP server pointed directly at the vault directory. It does **not** need Obsidian to be running and does **not** require any Obsidian plugin. The trade-off: the server sees plain Markdown files only — no Dataview output, no resolved backlinks, no tag index. Full-text search across files still works.

### 3.1 Install the filesystem MCP server

The server is shipped as `@modelcontextprotocol/server-filesystem` (not verified for your concrete install — check the existing entry in `claude_desktop_config.json` if uncertain). It runs via `npx` on demand, but a global install avoids first-run delay:

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
      "args": ["serve"]
    }
  }
}
```

Adjustments:

- Replace the vault path with your own (double the backslashes in JSON)
- Replace `C:\\path\\to\\zotero-mcp.exe` with the result of `where.exe zotero-mcp`

Note: `args: ["serve"]` is the typical invocation. The exact subcommand depends on the `zotero-mcp` version — on error, check `zotero-mcp --help`. Not verified for the currently installed version.

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
      "args": ["serve"]
    }
  }
}
```

Adjustments:

- Replace `YOUR_API_KEY` with the Local REST API key from Obsidian
- Replace `C:\\path\\to\\zotero-mcp.exe` with the result of `where.exe zotero-mcp` (double the backslashes)
- Replace the vault path with your own

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

After successful setup, log it as a decision in your project's `_DECISIONS.md` (which variant, which versions, date) — see Conventions in `_TEMPLATES/_CONVENTIONS.md`.

---

## 7. Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `npm` blocked with `UnauthorizedAccess` | Restrictive ExecutionPolicy | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |
| `pip` not found | Scripts folder not in PATH | Use `python -m pip install ...` instead of `pip` |
| MCP server shows red in Claude | Wrong config path or broken JSON | Re-locate path with `Get-ChildItem`, validate JSON |
| Variant A: tool calls fail with "path not allowed" | Vault path missing from `args` of filesystem server | Add vault directory to `args`; restart Claude Desktop |
| Variant B: API returns nothing | Plugin not active or Obsidian closed | Keep Obsidian open, check plugin status |
| Zotero API returns nothing | Zotero not open or API toggle off | Start Zotero, check Settings |
| `pip install zotero-mcp` fails to build | Python 3.14 too new for native wheels | Create venv with Python 3.12 |
