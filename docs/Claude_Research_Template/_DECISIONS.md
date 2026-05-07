# _DECISIONS: Claude_Research_Template

> Append-only log. New entries always on top. Never modify existing entries.

---

## 2026-05-07: Obsidian MCP via Filesystem (Variante A) statt Local REST API (Variante B)

**Context:** `Setup_Connectors_Windows.md` beschrieb ursprünglich nur die Local-REST-API-Variante (`obsidian-mcp-server` von cyanheads). Die tatsächlich aktive Konfiguration ist jedoch der Filesystem-MCP-Server, der direkt auf den Vault-Pfad zeigt — ohne Plugin-Abhängigkeit. Diskrepanz fiel im Chat auf, als das REST-API-Plugin in Obsidian unverifiziert disabled war, die MCP-Tools aber trotzdem funktionierten.

**Options:**
1. Filesystem-MCP — kein Plugin nötig, Obsidian muss nicht laufen, generische Tools (`read_text_file`, `list_directory`, `edit_file`, `write_file`, ...). Keine Dataview-/Backlink-Auflösung, nur Volltextsuche.
2. Local REST API + `obsidian-mcp-server` — voller Obsidian-Funktionsumfang inkl. Dataview, semantische Backlinks, Tag-Indizes. Plugin + laufender Obsidian-Prozess + API-Key nötig.

**Decision:** Variante A (Filesystem-MCP), weil der aktuelle Workflow (`_PROJECT.md` / `_DECISIONS.md` / `_PLAN.md`) reine Markdown-Bearbeitung ist und keine Obsidian-spezifischen Features benötigt. Geringere Setup-Komplexität, keine Abhängigkeit von einem laufenden Obsidian-Prozess.

**Impact:**
- `Setup_Connectors_Windows.md` umstrukturiert: Filesystem als Variante A (default), REST API als Variante B (alternative). Section 0 enthält Vergleichstabelle.
- Bei zukünftigem Bedarf an Dataview-Output oder semantischen Backlinks: Wechsel auf Variante B dokumentiert (Sections 4.1–4.4).
- Genauer Paketname des aktuell installierten Filesystem-Servers (`@modelcontextprotocol/server-filesystem` angenommen) **nicht verifiziert** — bei Bedarf in `claude_desktop_config.json` prüfen mit:
  ```powershell
  Get-Content "$env:LOCALAPPDATA\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\claude_desktop_config.json"
  ```

---
