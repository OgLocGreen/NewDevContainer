# Konventionen: Claude + Obsidian Workflow

> Dieses Dokument definiert wie Claude mit dem Obsidian Vault arbeitet.
> Gilt fuer alle Projekte. Wird im System Prompt jedes Claude Projects referenziert.

## Prinzipien

1. **Obsidian = Single Source of Truth** fuer alles was kein Code ist.
2. **Git-Repo = Single Source of Truth** fuer Code.
3. **Claude Project = Kontext-Loader.** Keine hochgeladenen Dateien die veralten. System Prompt zeigt auf Obsidian-Pfade.
4. **Keine Duplikate.** Claude liest/schreibt direkt im Vault, kopiert nie Inhalte in den Chat als Ersatz.

## Dateikonventionen

- Projektordner enthalten Meta-Dateien mit Underscore-Prefix: `[[Projects/Prompt_Engineering/_PROJECT|_PROJECT]].md`, `[[Projects/PhD/_DECISIONS|_DECISIONS]].md`, `[[Projects/PhD/_PLAN|_PLAN]].md`
- `[[Projects/Prompt_Engineering/_PROJECT|_PROJECT]].md`: Status + TODO-Liste. Claude aktualisiert das proaktiv.
- `[[Projects/PhD/_DECISIONS|_DECISIONS]].md`: Append-only. Neue Eintraege oben. Bestehende nie aendern.
- `[[Projects/PhD/_PLAN|_PLAN]].md`: Nur nach expliziter Absprache aendern.
- Freie Notizen, Research etc. liegen in Unterordnern (z.B. `[[Notes]]/`, `research/`).
- Veraltete Dokumente werden nach `archive/` verschoben, nie geloescht.

## Claude-Verhalten pro Session

1. **Session-Start:** `[[Projects/Prompt_Engineering/_PROJECT|_PROJECT]].md` lesen fuer aktuellen Stand.
2. **Waehrend Arbeit:** Bei substanziellen Entscheidungen `[[Projects/PhD/_DECISIONS|_DECISIONS]].md` appenden.
3. **Session-Ende / auf Anfrage:** `[[Projects/Prompt_Engineering/_PROJECT|_PROJECT]].md` updaten (Status, TODOs).
4. **Notizen:** Wenn Chris sagt "halt das fest" oder "notier das", in passende Datei schreiben.

## TODO-Konventionen

- Einfache Markdown-Checkboxen in `[[Projects/Prompt_Engineering/_PROJECT|_PROJECT]].md`
- Prioritaet = Reihenfolge (oben = naechstes)
- Erledigte Tasks: Datum prefix, max. 10 behalten, aeltere loeschen
- Zurueckgestellte Tasks in eigener Sektion

## Was Claude NICHT tut

- Keine Dateien loeschen (nur nach `archive/` verschieben)
- Keine `[[Projects/PhD/_PLAN|_PLAN]].md` aendern ohne explizites OK
- Keine Inhalte aus dem Vault in Claude Projects hochladen
- Keine Annahmen ueber Git-Stand machen (immer fragen oder Claude Code nutzen)
