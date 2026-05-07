# Claude + Obsidian Workflow -- Setup Guide

> Anleitung zum Einrichten eines strukturierten Workflows zwischen Claude (claude.ai) und einem Obsidian Vault.
> Ziel: Obsidian als Single Source of Truth, Claude als intelligenter Assistent der direkt im Vault liest und schreibt.

---

## Was dieses Setup leistet

- Claude hat ueber einen MCP-Server direkten Lese-/Schreibzugriff auf euer Obsidian Vault.
- Jedes Projekt hat eine einheitliche Struktur mit Status, TODOs, Entscheidungslog und Roadmap.
- Claude liest zu Beginn jeder Session den aktuellen Stand und haelt ihn danach aktuell.
- Keine veralteten Kopien in Claude Projects -- alles lebt im Vault.
- Wiederverwendbare System Prompts ("Dr. Prompts") koennen per Trigger im Chat aktiviert werden.

---

## Voraussetzungen

1. **Obsidian** installiert mit einem Vault-Ordner auf eurem Rechner.
2. **Claude Pro/Team Account** auf claude.ai.
3. **Obsidian MCP Server** -- ein MCP-Server der Claude Zugriff auf euer Vault gibt.
   - Empfohlen: [file-context-server](https://github.com/nicholasgriffintn/obsidian-cloudflare-ai) oder ein lokaler Filesystem-MCP-Server.
   - Der Server muss in Claude unter Settings > MCP Servers verbunden sein.
   - Erlaubter Pfad: euer Obsidian Vault Root-Verzeichnis.

---

## Schritt 1: Vault-Struktur anlegen

Erstellt im Root eures Vaults einen Ordner fuer Projekte und einen fuer Templates:

```
VaultRoot/
├── Projects/
│   └── Prompt_Engineering/
│       ├── _TEMPLATES/
│       │   ├── _PROJECT_TEMPLATE.md
│       │   ├── _DECISIONS_TEMPLATE.md
│       │   ├── _PLAN_TEMPLATE.md
│       │   ├── _CONVENTIONS.md
│       │   └── _CLAUDE_PROJECT_SYSTEM_PROMPT.md
│       └── Prompts/
│           ├── Dr_Analyse.md
│           ├── Dr_Code.md
│           ├── Dr_EveryDay.md
│           └── Dr_Mail.md
├── EuerProjekt1/
│   ├── _PROJECT.md
│   ├── _DECISIONS.md
│   ├── _PLAN.md
│   └── notes/
└── EuerProjekt2/
    └── ...
```

---

## Schritt 2: Projekt-Templates verwenden

Jedes Projekt bekommt drei Meta-Dateien. Kopiert die Templates und passt sie an.

### _PROJECT.md -- Status und TODOs

```markdown
# _PROJECT: [Projektname]

> Letzte Aktualisierung: YYYY-MM-DD

## Status

| Feld | Wert |
|------|------|
| Phase | [Planung / Aktiv / Pause / Abgeschlossen] |
| Naechster Meilenstein | ... |
| Blocker | keine / ... |
| Repo | [URL oder Pfad] |

## Zusammenfassung

[2-3 Saetze: Was ist das Projekt, wo stehen wir.]

## TODO

- [ ] ...
- [ ] ...

### Zurueckgestellt

- [ ] ...

### Erledigt (letzte 10)

- [x] YYYY-MM-DD: ...
```

### _DECISIONS.md -- Entscheidungslog

Append-only. Neue Eintraege immer oben. Bestehende nie aendern.

```markdown
## YYYY-MM-DD: [Kurztitel]

**Kontext:** Warum stand die Entscheidung an?
**Optionen:** 1) ... 2) ...
**Entscheidung:** Option X, weil ...
**Auswirkung:** Was aendert sich?
```

### _PLAN.md -- Roadmap

Nur nach expliziter Absprache aendern. Enthaelt Phasen, Arbeitspakete und Risiken.

---

## Schritt 3: Konventionen einhalten

Diese Regeln gelten fuer alle Projekte:

**Prinzipien:**
- Obsidian = Single Source of Truth fuer alles was kein Code ist.
- Git-Repo = Single Source of Truth fuer Code.
- Claude Projects = nur Kontext-Loader (System Prompt zeigt auf Vault-Pfade, keine hochgeladenen Dateien).

**Claude-Verhalten pro Session:**
1. Session-Start: `_PROJECT.md` lesen.
2. Waehrend der Arbeit: Bei Entscheidungen `_DECISIONS.md` appenden.
3. Session-Ende oder auf Anfrage: `_PROJECT.md` updaten.

**Was Claude nicht tut:**
- Keine Dateien loeschen -- veraltetes nach `archive/` verschieben.
- `_PLAN.md` nur nach explizitem OK aendern.
- Keine Vault-Inhalte in Claude Projects duplizieren.

---

## Schritt 4: Memory-Regeln in Claude einrichten

Damit Claude in jeder Session weiss wie es arbeiten soll, muessen folgende Memory Edits gesetzt werden. Geht dazu in claude.ai in die Einstellungen unter Memory, oder sagt Claude direkt: "Bitte merke dir folgendes:"

**Memory 1 -- Workflow-Konventionen:**
```
Obsidian Vault = single source of truth for non-code project data. Each project
has _PROJECT.md (status+TODOs), _DECISIONS.md (append-only), _PLAN.md (change
only with OK). Session start: read _PROJECT.md. After decisions: append
_DECISIONS.md. After work: update _PROJECT.md. Never delete -- move to archive/.
Never duplicate vault content into Claude Projects.
```

**Memory 2 -- Vault-Pfad:**
```
Obsidian Vault path: [EUER_VAULT_PFAD]. Connected via obsidian-vault MCP server
with full read/write access.
```

**Memory 3 -- Dr. Prompt Trigger (optional):**
```
Dr. Prompt Trigger: When I say "Lade Dr. X" or "Dr. X Modus" (e.g. "Lade Dr.
Code"), read the matching prompt from Obsidian at
Projects/Prompt_Engineering/Prompts/Dr_[Name].md and adopt its rules for the
rest of the session. Available: Dr_Analyse, Dr_Mail, Dr_EveryDay, Dr_Code.
```

Ersetzt `[EUER_VAULT_PFAD]` mit dem tatsaechlichen Pfad zu eurem Vault.

---

## Schritt 5: Dr. Prompts nutzen

Im Ordner `Projects/Prompt_Engineering/Prompts/` liegen spezialisierte System Prompts:

| Trigger im Chat | Datei | Zweck |
|-----------------|-------|-------|
| `Lade Dr. Analyse` | Dr_Analyse.md | Psychologische Text- und Mail-Analyse |
| `Lade Dr. Mail` | Dr_Mail.md | Formelle E-Mail-Optimierung |
| `Lade Dr. EveryDay` | Dr_EveryDay.md | Alltagsfragen, Technik, Organisation |
| `Lade Dr. Code` | Dr_Code.md | Programmierung, Debugging, Architektur |

**Benutzung:** Einfach im Chat schreiben: `Lade Dr. Code` -- Claude liest den Prompt aus dem Vault und arbeitet ab da nach diesen Regeln.

**Eigene Prompts hinzufuegen:** Neue `.md`-Datei im Prompts-Ordner anlegen (Format: `Dr_[Name].md`) und den Memory-Eintrag um den neuen Namen erweitern.

---

## Schritt 6: Neues Projekt starten (Checkliste)

1. Ordner im Vault anlegen (z.B. `Projects/MeinNeuesProjekt/`).
2. `_PROJECT.md`, `_DECISIONS.md`, `_PLAN.md` aus den Templates kopieren und befuellen.
3. Optional: Claude Project in claude.ai anlegen und System Prompt aus `_CLAUDE_PROJECT_SYSTEM_PROMPT.md` einfuegen (Platzhalter ersetzen).
4. Loslegen -- Claude liest beim Start automatisch `_PROJECT.md`.

---

## Schritt 7: Claude Project System Prompt (optional)

Wenn ihr fuer ein Projekt ein eigenes Claude Project anlegen wollt, kopiert dieses Template in das System Prompt und ersetzt die Platzhalter:

```
## Projekt: [PROJEKTNAME]

Du arbeitest mit [NAME] an [KURZBESCHREIBUNG].

### Obsidian Vault

Alle Projektdaten liegen im Obsidian Vault unter:
[VAULT_BASEPATH]\[PROJEKTORDNER]\

Wichtige Dateien:
- _PROJECT.md -- Status, Zusammenfassung, TODO-Liste
- _DECISIONS.md -- Entscheidungslog (append-only, neue Eintraege oben)
- _PLAN.md -- Roadmap (nur nach Absprache aendern)

### Workflow-Regeln

1. Lies _PROJECT.md zu Beginn jeder Session.
2. Nach Entscheidungen: _DECISIONS.md appenden.
3. Nach Arbeitsbloecken: _PROJECT.md updaten.
4. _PLAN.md nur nach explizitem OK aendern.
5. Keine Dateien loeschen -- veraltetes nach archive/.
6. Keine Vault-Inhalte duplizieren.

### Kontext

[PROJEKTSPEZIFISCH: Tech Stack, Phase, Constraints, Personen]
```

---

## FAQ

**Brauche ich Claude Pro?**
Ja, fuer MCP-Server-Zugriff ist mindestens ein Pro-Account noetig.

**Funktioniert das auf Mobile?**
Nein, MCP-Server sind aktuell nur im Desktop-Client und Web verfuegbar. Auf Mobile koennt ihr alternativ Claude Projects mit reinkopiertem System Prompt nutzen.

**Kann ich mehrere Dr. Prompts gleichzeitig laden?**
Nein, immer nur einen pro Session. Ein neuer "Lade Dr. X" Befehl ersetzt den vorherigen.

**Was passiert wenn ich eine Datei im Vault manuell aendere?**
Claude liest bei der naechsten Session oder auf Anfrage den aktuellen Stand. Manuelle Aenderungen sind jederzeit moeglich und erwuenscht.

**Kann Claude auch Dateien loeschen?**
Nein -- per Konvention verschiebt Claude nur nach `archive/`. Loeschen muesst ihr manuell machen.
