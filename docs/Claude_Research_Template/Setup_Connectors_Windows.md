# Setup: Obsidian + Zotero MCP for Claude Desktop (Windows)

> Step-by-step guide for setting up the MCP servers for Obsidian and Zotero on Windows with Claude Desktop (MSIX / Store version).
> **Verified:** 2026-05-04. Procedures may change with future MCP server releases — see linked upstream repos in `Setup_Guide.md` if commands fail.

**Target system:** Windows, PowerShell, Claude Desktop MSIX
**Example vault path used in this guide:** `C:\Users\ogloc\Desktop\OgLocGreenSpace\docs\oglocgreen_obsidian` — replace with your own.

This guide is platform-specific. For the conceptual overview that applies to all platforms, see [[Setup_Guide#Step 2: Install MCP connectors]].

---

## 1. Prerequisites

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

---

## 2. Set up Obsidian

### 2.1 Install Obsidian

```powershell
winget install Obsidian.Obsidian
```

Alternative: installer from https://obsidian.md.

### 2.2 Open vault

On first start: select **Open folder as vault** and point to your existing vault, e.g.:

```
C:\Users\ogloc\Desktop\OgLocGreenSpace\docs\oglocgreen_obsidian
```

### 2.3 Enable Local REST API plugin

This plugin is the bridge that the MCP server needs to talk to.

1. `Settings → Community plugins → Turn on community plugins` (one-time opt-in)
2. `Browse → "Local REST API"` → **Install** → **Enable**
3. `Settings → Local REST API`:
   - **Copy the API key** (long string, needed in Step 5)
   - Note the ports: `27124` (HTTPS), `27123` (HTTP)

### 2.4 Verify the API connection

```powershell
curl.exe -k https://127.0.0.1:27124/ -H "Authorization: Bearer YOUR_API_KEY"
```

Expected response: JSON with `{"status":"OK",...}`.

---

## 3. Set up Zotero

### 3.1 Start Zotero and enable API access

In Zotero:

```
Edit → Settings → Advanced → Allow other applications on this computer to communicate with Zotero
```

Enable.

### 3.2 Verify the Zotero API

```powershell
curl.exe http://localhost:23119/api/users/0/items?limit=1
```

Should return JSON with one item (Zotero must be running).

---

## 4. Install MCP servers

### 4.1 Obsidian MCP server

```powershell
npm install -g obsidian-mcp-server
```

Note install path (can be retrieved with `npm root -g`).

Note: there are several Obsidian MCP implementations (`obsidian-mcp-server` by cyanheads, `mcp-obsidian` by MarkusPfundstein). Both use the Local REST API. Which server was used previously: not verified — if uncertain, check `_DECISIONS.md` in your vault.

### 4.2 Zotero MCP server

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

## 5. Configure Claude Desktop

### 5.1 Find the config file (MSIX path)

```powershell
Get-ChildItem "$env:APPDATA","$env:LOCALAPPDATA" -Filter "claude_desktop_config.json" -Recurse -ErrorAction SilentlyContinue
```

Expected path on the MSIX version:

```
$env:LOCALAPPDATA\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\claude_desktop_config.json
```

If the file doesn't exist: create it.

### 5.2 Config content

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

Note: `args: ["serve"]` is the typical invocation. The exact subcommand depends on the `zotero-mcp` version — on error, check `zotero-mcp --help`. Not verified for the currently installed version.

### 5.3 Restart Claude Desktop

Close completely — including from the system tray. Then restart.

In Settings under `Developer → MCP Servers`, both servers should appear as **connected**.

---

## 6. Verification

In a new Claude chat:

- Test Obsidian: "List the top-level folders of my vault"
- Test Zotero: "Show me the last 5 items in my Zotero library"

Both should run without errors.

After successful setup, log it as a decision in your project's `_DECISIONS.md` (which Obsidian MCP server, which versions, date) — see Conventions in `_TEMPLATES/_CONVENTIONS.md`.

---

## 7. Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `npm` blocked with `UnauthorizedAccess` | Restrictive ExecutionPolicy | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |
| `pip` not found | Scripts folder not in PATH | Use `python -m pip install ...` instead of `pip` |
| MCP server shows red in Claude | Wrong config path or broken JSON | Re-locate path with `Get-ChildItem`, validate JSON |
| Obsidian API returns nothing | Plugin not active or Obsidian closed | Keep Obsidian open, check plugin status |
| Zotero API returns nothing | Zotero not open or API toggle off | Start Zotero, check Settings |
| `pip install zotero-mcp` fails to build | Python 3.14 too new for native wheels | Create venv with Python 3.12 |
