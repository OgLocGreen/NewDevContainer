# Claude Research Template

> Strukturierter Research-Workflow für **Claude Desktop + Obsidian**: Chats sind der Brainstorm-Raum, der **Vault ist die einzige Quelle der Wahrheit** für Pläne, Entscheidungen und Notizen.
>
> **Für wen:** Forschende/Wissensarbeiter, die mit Claude Desktop arbeiten und ihre Pläne, Entscheidungen und Notizen in einem Obsidian-Vault persistent halten wollen. **Voraussetzungen:** Claude Desktop, Obsidian-Vault, lokale Maschine zum Installieren von MCP-Servern. **Nicht nötig**, wenn du nur einzelne Chat-Sessions ohne dauerhaftes Wissensmanagement brauchst — dafür reichen die [Dr.-Prompts](#dr-prompts).
> Last updated: 2026-06-09
> Ausblick auf die geplante Drei-Schienen-Architektur mit zusätzlicher Wiki-Schiene — **Vision, noch nicht implementiert**, nicht zum Nachbauen gedacht: [`ReadMe_Future.md`](ReadMe_Future.md). Diese (`ReadMe.md`) beschreibt den heutigen, real funktionierenden Stand.

---

## TL;DR

Dieses Template gibt dir vier Dinge:

1. **Vault-Struktur** mit klaren Rollen pro Datei (`_PROJECT`, `_PLAN`, `_DECISIONS`, `Scratch/`)
2. **System-Prompt** für ein Claude Project, der die Rituale `/push`, `/pull*`, `/sync` und den Drift-Check fest verankert
3. **Setup-Guides** zum Einrichten von Vault + MCP-Servern (Obsidian, Zotero)
4. **Dr.-Prompts** — vier rollenbasierte System-Prompts für wiederkehrende Aufgaben (Code, Analyse, Mail, Alltag)

Du betreibst es heute auf der **Vault-Maschine** (dein Laptop mit Obsidian + Claude Desktop + MCP-Servern — das *Model Context Protocol*, Claude Desktops Brücke zum Dateisystem). Dieses Template lebt zwar im NewDevContainer-Repo, hat aber nichts mit dem dort enthaltenen Python-DevContainer zu tun — der DevContainer läuft komplett unabhängig in einer eigenen Welt. Siehe [Abschnitt zum realen Ablauf](#realer-ablauf-heute-was-wirklich-passiert).

---

## Mentales Modell

```
Chat (flüchtig)           Vault (persistent)
──────────────            ──────────────────
Brainstorming   ──/push──▶  konsolidierte Zustände
Diskutieren                 _PROJECT.md
Iterieren                   _PLAN.md
Verwerfen                   _DECISIONS.md
```

- **Chat = working directory** — Denken erlaubt, falsche Hypothesen okay, alles verwerfbar.
- **Vault = repository** — nur saubere Zustände, dokumentierte Entscheidungen, aktuelle Pläne.
- **Übergang = `/push`** — 5-Schritt-Ritual mit Preview und Bestätigung pro Datei.

Die Trennung ist Absicht. Ohne sie wird entweder der Chat zu vorsichtig (weil alles in den Vault rutschen könnte) oder der Vault verstopft mit Halbgedanken.

---

## Vault-Struktur: was wo lebt

### Flat-Projekt (eine Arbeitsfläche)

```
Projects/[ProjectName]/
├── _PROJECT.md     Status + TODOs
├── _PLAN.md        Roadmap, Phasen, Arbeitspakete
├── _DECISIONS.md   Append-only Entscheidungslog
└── Scratch/        halbgebackene Ideen
```

### Hierarchisches Projekt (Parent + Subprojekte)

```
Projects/[ParentProject]/
├── _PROJECT.md          Parent-Status, übergreifende TODOs
├── _PLAN.md             High-Level-Roadmap
├── _DECISIONS.md        ALLE Entscheidungen (mit [Subproject]-Tag)
├── Scratch/             eine Idea-Bin für alle Subprojekte
│
├── [Subproject_A]/
│   ├── _PLAN.md         Subprojekt-Plan (Pflicht wenn aktiv)
│   └── _DECISIONS.md    optional, nur bei hohem Volumen
│
└── [Subproject_B]/
    └── ...
```

**Regeln:**
- Parent hat immer `_PROJECT.md`, `_PLAN.md`, `_DECISIONS.md`, `Scratch/`.
- Aktives Subprojekt hat immer eigenes `_PLAN.md`.
- `_DECISIONS.md` im Subprojekt nur bei großem Volumen — sonst Tag im Parent-Log.
- `Scratch/` lebt **nur** auf Parent-Ebene (keine Fragmentierung).
- Kein Subprojekt-im-Subprojekt. Tiefer = einfache Ordner ohne Meta-Files.

### Was jede Datei macht

| Datei            | Zweck                                            | Wer schreibt          | Format                                  |
| ---------------- | ------------------------------------------------ | --------------------- | --------------------------------------- |
| `_PROJECT.md`    | Status, Phase, Next Milestone, TODOs             | Claude nur via `/push` | Status-Tabelle + Flat-TODO-Liste        |
| `_PLAN.md`       | Roadmap, Phasen, Arbeitspakete, Risiken          | Claude nur nach OK   | Phasen mit Definition-of-Done + Risiko-Tabelle |
| `_DECISIONS.md`  | Append-only Entscheidungslog, neueste oben       | Claude nur via `/push` | Pro Eintrag: Context / Options / Decision / Impact |
| `Scratch/`       | Brainstorm, Halbgedanken, datierte Notizen      | User & Claude frei     | Datierte Einträge oben, beliebige Form  |
| `Bibliography/`  | Optional: Paper-Notizen + `_INDEX.md`            | Claude via `/sync`    | Pro Paper eine `[CitationKey].md`       |

Vorlagen liegen unter [`_PROJECT_TEMPLATES/`](_PROJECT_TEMPLATES/) — jede mit Platzhaltern, die du beim Setup ersetzt.

---

## Die Rituale

Vier Rituale halten Chat und Vault synchron, ohne dass etwas heimlich passiert.

### `/push` — Konsolidierung Chat → Vault

Das einzige Ritual, das schreibt. Fünf Schritte, keine Abkürzungen.

| Schritt | Was passiert                                                              | Wer bestätigt |
| ------- | ------------------------------------------------------------------------- | ------------- |
| 1       | **Recap** — Claude fasst Session zusammen: Decisions, Insights, Plan-Änderungen, offene Punkte | User korrigiert ggf. |
| 2       | **Vault-Diff-Plan** — Claude liest Vault-Files, beschreibt Änderungen *in Prosa* (noch kein Write) | User sieht *intent* |
| 3       | **Rückfragen** — Claude klärt: "Decision oder offene Ablation?", "TODO done/in progress/deferred?" | User antwortet |
| 4       | **Schreiben** — pro Datei: finaler Text/Diff zeigen → OK abwarten → schreiben | User OK pro Datei |
| 5       | **Closer** — kurze Zusammenfassung + Next-Chat-Starter zum Reinpasten      | —             |

**Leer-Push:** Wenn nichts konsolidierungswürdig ist, sagt Claude das ehrlich und beendet das Ritual sofort. Kein Pseudo-Push.

### `/pull` — Vault → Chat lesen

Alle Pull-Mechanismen sind **read-only** und blockieren das Gespräch nie.

| Mechanismus              | Was passiert                                                            |
| ------------------------ | ----------------------------------------------------------------------- |
| Auto-Pull (automatisch)  | Bei Statusfragen, Verweisen auf Decisions, Paper-Bezügen — mit transparentem Hinweis "lese kurz X" |
| `/pull`                  | Voller Refresh: Parent + alle aktiven Subprojekt-Meta-Files             |
| `/pull_path <path>`      | Gezielt; bei mehrdeutigem Namen Liste + Rückfrage; bei riesigen Files Whole-or-Section |
| `/pull_keyword <term>`   | Volltextsuche im aktuellen Projekt, Treffer mit Snippets, dann Auswahl  |
| `/pull_subproject <name>` | `[Subproject]/_PLAN.md` + optional `_DECISIONS.md`                     |
| `/where`                 | Meta-Synthese: wo stehen wir, was wurde vereinbart, was fehlt           |

Typische Auto-Pull-Reihenfolge: `_PROJECT.md` → `_PLAN.md` → `_DECISIONS.md` → spezifische Subfiles.

### `/sync` — Zotero ↔ Obsidian

Bibliographie-Abgleich zwischen Zotero (Master für Metadaten) und Obsidian (Master für persönliche Notizen).

1. Aktive Zotero-Collection ziehen
2. `Bibliography/_INDEX.md` + `Bibliography/[CitationKey].md` aus dem Vault lesen
3. Diff anzeigen: **Neu in Zotero** / **Verwaist in Obsidian** / **Metadata-Drift**
4. Pro Kategorie nachfragen, was passieren soll
5. Erst nach Bestätigung anwenden, Closer-Summary

Was `/sync` **nicht** tut: keine Push-Richtung Obsidian → Zotero (Adds via `zotero_add_by_doi`), kein Auto-Löschen verwaister Notizen (nur markieren), keine Modifikation bestehender Notiz-Bodies (nur Metadata-Header).

### Drift-Check (zyklisch)

Alle 3–4 substantielle Wechsel macht Claude einen kompakten Cross-Check:

> "Quick check: wir haben jetzt A, B, C diskutiert. Der Vault hat X, Y. Drift-Beobachtung: [konkreter Punkt]. Weitermachen oder zuerst klären?"

Kein Reflex, keine Korrektur-Schleife — ein **Frühwarnsystem**, damit Chat-Realität und Vault-Stand nicht auseinanderlaufen. Bei laufendem Gedankengang: bis zur nächsten Pause verschieben.

---

## Realer Ablauf heute: was wirklich passiert

Drei Diagramme, jedes für eine eigene Frage: **wo läuft was** auf der Vault-Maschine, **was steckt im DevContainer**, und **wie verläuft das `/push`-Ritual** Schritt für Schritt. Im Gegensatz zur Zukunftsvision in [`ReadMe_Future.md`](ReadMe_Future.md) zeigen alle drei **ausschließlich** Komponenten und Abläufe, die heute existieren. Die zentrale Aussage über die beiden Architekturen hinweg: zwischen Vault-Maschine und Dev-Maschine existiert kein einziger Pfeil — sie sind getrennte Welten, der User ist die einzige Verbindung.

### Vault-Maschine: was heute wirklich da ist

Die Vault-Maschine ist die heutige, real funktionierende Architektur auf dem persönlichen Laptop. Sie verbindet den Menschen über Obsidian und Claude Desktop mit dem lokalen OgVault — zusätzlich greift Claude über MCP-Server auf das Dateisystem und Zotero zu.

```mermaid
flowchart LR
    subgraph VM["Vault-Maschine — persönlicher Laptop"]
        User(("User"))
        Obsidian["Obsidian<br/>(Desktop-Editor)"]
        Claude["Claude Desktop"]
        FSMCP["Filesystem<br/>MCP Server"]
        ZotMCP["Zotero<br/>MCP Server"]
        Zotero["Zotero (App)"]
        OgVault[("OgVault")]
    end

    User <-->|"editiert"| Obsidian
    Obsidian <-->|"liest & schreibt"| OgVault
    User <-->|"Chat"| Claude
    Claude -->|"MCP"| FSMCP
    FSMCP <-->|"liest & schreibt"| OgVault
    Claude -->|"MCP"| ZotMCP
    ZotMCP -->|"Bibliographie"| Zotero

    classDef live fill:#d4edda,stroke:#28a745,stroke-width:2px,color:#155724
    classDef vault fill:#fff3cd,stroke:#856404,stroke-width:2px,color:#856404
    classDef person fill:#e2e3ff,stroke:#3f3d99,stroke-width:2px,color:#1a1a4d

    class Obsidian,Claude,FSMCP,ZotMCP,Zotero live
    class OgVault vault
    class User person
```

Grün markierte Knoten sind aktive Komponenten, die heute laufen. Gelb steht für den lokalen OgVault als zentraler Datenspeicher. Lila kennzeichnet den Menschen als Akteur. Alle Verbindungen existieren real — Obsidian liest und schreibt direkt im Vault, Claude Desktop greift über MCP-Server auf Dateisystem und Zotero zu.

### Dev-Maschine: was im Container heute läuft

Die Dev-Maschine besteht heute aus einem DevContainer mit Python 3.12 und CUDA 12.6, in dem Claude Code direkt mitläuft. Skills und Slash-Befehle arbeiten ausschließlich auf den Doc-Verzeichnissen und dem Projekt-Repo — kein MCP, kein Vault.

```mermaid
flowchart TD
    User["User"]

    subgraph DEV["Dev-Maschine - DevContainer im Repo"]
        DC["DevContainer<br/>(Python 3.12 + CUDA 12.6, Docker)"]
        CC["Claude Code<br/>(im Container, via DevContainer-Feature)"]
        SK["package-docs Skill"]
        CMD["Slash-Befehle:<br/>/spell-check<br/>/read-package-a<br/>/read-package-b"]
        DA["docs/package_a/"]
        DB["docs/package_b/"]
        REPO["Projekt-Repo<br/>NewDevContainer<br/>(Container-Workspace)"]
        NOTE["Hinweis:<br/>keine MCP-Server,<br/>kein Vault-Zugriff"]
    end

    User -->|"startet"| DC
    DC -->|"enthaelt"| CC
    User -->|"ruft Slash-Befehle auf"| CMD
    CMD --> CC
    CC -->|"laedt bei Bedarf"| SK
    SK -.->|"liest"| DA
    SK -.->|"liest"| DB
    CC <-->|"edits und reads"| REPO
    CC -.->|"Kontext"| NOTE

    classDef devSide fill:#e8a87c,stroke:#8b4513,stroke-width:2px,color:#2b1810
    classDef devDocs fill:#d4906a,stroke:#6b3410,stroke-width:1px,color:#2b1810
    classDef devNote fill:#fff3e0,stroke:#a0522d,stroke-width:1px,color:#5c2e0a,font-style:italic
    classDef userNode fill:#f5deb3,stroke:#8b4513,stroke-width:2px,color:#2b1810

    class User userNode
    class DC,CC,SK,CMD,REPO devSide
    class DA,DB devDocs
    class NOTE devNote
```

Warme Orange- und Brauntöne markieren die Dev-Seite: kräftiges Orange für aktive Komponenten (DevContainer, Claude Code, Skill, Slash-Befehle, Repo), gedämpftes Braun für die Doc-Verzeichnisse und ein heller Hinweis-Kasten, der die fehlende Verbindung zur Vault-Maschine sichtbar macht. Gestrichelte Pfeile kennzeichnen reine Lesezugriffe des Skills auf die Doc-Ordner sowie den Kontext-Hinweis.

### `/push` — der Konsolidierungs-Fluss

Das `/push`-Ritual ist der zentrale Schreibfluss vom Chat in den OgVault. Es läuft in fünf klar getrennten Schritten ab, mit expliziter Bestätigung pro Datei — und bricht sauber ab, wenn nichts zu konsolidieren ist.

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Claude
    participant Vault as Vault OgVault

    User->>Claude: /push
    Note over User,Vault: Schritt 1 - Recap
    Claude->>Claude: Session zusammenfassen<br/>Entscheidungen, Insights,<br/>Planaenderungen, offene Punkte
    Claude->>User: Recap zur Bestaetigung
    User->>Claude: Bestaetigung oder Korrektur

    alt Nichts Konsolidierungswuerdiges
        Note over User,Vault: Leer-Push-Abzweig
        Claude->>User: Nichts zu konsolidieren<br/>Ende ohne Pseudo-Push
    else Inhalte vorhanden
        Note over User,Vault: Schritt 2 - Vault-Diff-Plan
        Claude->>Vault: Lese _PROJECT.md
        Claude->>Vault: Lese _PLAN.md
        Claude->>Vault: Lese _DECISIONS.md
        Vault-->>Claude: Aktueller Stand
        Claude->>User: Prosa-Plan der Aenderungen<br/>noch kein Schreiben

        Note over User,Vault: Schritt 3 - Rueckfragen
        Claude->>User: Wo gehoert es hin?<br/>z.B. Decision oder offene Ablation
        User->>Claude: Antwort und Einordnung

        Note over User,Vault: Schritt 4 - Schreiben
        loop Pro Datei
            Claude->>User: Finaler Text bzw. Diff
            User->>Claude: Explizites OK
            Claude->>Vault: Schreibe Datei
            Vault-->>Claude: Bestaetigung
        end

        Note over User,Vault: Schritt 5 - Session-Closer
        Claude->>User: Kurze Zusammenfassung<br/>+ Starter fuer naechsten Chat
    end
```

Die `Note over`-Banner markieren die Schritt-Grenzen. Der `alt`-Zweig zeigt den **Leer-Push**: Claude sagt ehrlich Bescheid und beendet den Flow, statt einen Pseudo-Push zu inszenieren. Geschrieben wird ausschließlich in Schritt 4 — und immer erst nach explizitem OK pro Datei.

### `/pull` — der Lese-Fluss

Spiegelbild zu `/push`: alle Wege, auf denen Vault-Wissen in den Chat kommt. Der äußere `alt`-Block trennt **Auto-Pull** (Claude erkennt selbst, dass Vault-Wissen nötig ist) von **explizitem Pull** (User tippt einen Befehl). Innerhalb des expliziten Zweigs fächern sich die fünf Befehle in `alt`/`else` auf. Alle Pfade sind strikt read-only — kein Pull schreibt zurück, kein Pull blockiert das Gespräch.

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Claude
    participant Vault as Vault OgVault

    User->>Claude: inhaltliche Frage / Anliegen

    alt Auto-Pull: Claude erkennt Vault-Wissen noetig
        Note over User,Vault: Auto-Pull-Pfad (transparent, ohne Befehl)
        Claude->>User: Hinweis "lese kurz _PROJECT.md"
        Claude->>Vault: Lese _PROJECT.md
        Vault-->>Claude: Inhalt
        opt weitere Files noetig
            Claude->>Vault: Lese _PLAN.md / _DECISIONS.md / Subfiles
            Vault-->>Claude: Inhalt
        end
        Claude->>User: Antwort mit Vault-Kontext

    else Expliziter /pull-Befehl
        Note over User,Vault: Explizite Lese-Varianten

        alt /pull — voller Refresh
            User->>Claude: /pull
            Claude->>Vault: Lese parent _PROJECT.md, _PLAN.md, _DECISIONS.md
            Claude->>Vault: Lese alle aktiven Subproject-Meta-Files
            Vault-->>Claude: Alle Inhalte
            Claude->>User: Voller Stand zusammengefasst

        else /pull_path <pfad> — gezielt
            User->>Claude: /pull_path <pfad>
            opt Pfad mehrdeutig
                Claude->>User: Liste der Treffer, welcher?
                User->>Claude: Auswahl
            end
            opt Datei sehr gross
                Claude->>User: Ganz oder bestimmter Abschnitt?
                User->>Claude: Auswahl
            end
            Claude->>Vault: Lese Datei bzw. Abschnitt
            Vault-->>Claude: Inhalt
            Claude->>User: Inhalt im Chat

        else /pull_keyword <term> — Volltextsuche
            User->>Claude: /pull_keyword <term>
            Claude->>Vault: Volltextsuche im aktuellen Projekt
            Vault-->>Claude: Trefferliste mit Snippets
            Claude->>User: Treffer, welche voll lesen?
            User->>Claude: Auswahl
            Claude->>Vault: Lese ausgewaehlte Dateien
            Vault-->>Claude: Volltext
            Claude->>User: Antwort mit Kontext

        else /pull_subproject <name> — Subprojekt-Fokus
            User->>Claude: /pull_subproject <name>
            Claude->>Vault: Lese [Subproject]/_PLAN.md
            opt Subproject _DECISIONS.md existiert
                Claude->>Vault: Lese [Subproject]/_DECISIONS.md
            end
            Vault-->>Claude: Subprojekt-Stand
            Claude->>User: Fokus auf Subprojekt gesetzt

        else /where — Meta-Synthese
            User->>Claude: /where
            Claude->>Vault: Auto-Pull relevanter Meta-Files
            Vault-->>Claude: Inhalte
            Claude->>User: Synthese: wo stehen wir, was fehlt
        end
    end

    Note over User,Vault: Alle Pull-Pfade sind strikt read-only
```

Auto-Pull ist der unsichtbare Default — kein Befehl nötig, nur ein transparenter Hinweis. Die expliziten Varianten unterscheiden sich darin, **was** sie lesen und **wie** sie sich bei Mehrdeutigkeit verhalten: `/pull` liest komplett, `/pull_path` gezielt mit Rückfrage bei mehrdeutigen Namen, `/pull_keyword` zeigt erst Trefferliste, `/pull_subproject` fokussiert auf eine Subprojekt-Mappe, `/where` liefert eine Meta-Synthese statt Rohdaten.

---

## Setup (Quickstart)

Vollständige Anleitungen liegen in den Setup-Guides. Hier nur die Schritt-Übersicht.

### 1. Vault & Ordnerstruktur

Lege in deinem Obsidian-Vault einen `Projects/`-Ordner an und darin pro Projekt eine Mappe wie oben beschrieben. Vorlagen kopieren:

**macOS / Linux / Git Bash:**
```bash
cp _PROJECT_TEMPLATES/_PROJECT_TEMPLATE.md     <vault>/Projects/MyProject/_PROJECT.md
cp _PROJECT_TEMPLATES/_PLAN_TEMPLATE.md        <vault>/Projects/MyProject/_PLAN.md
cp _PROJECT_TEMPLATES/_DECISIONS_TEMPLATE.md   <vault>/Projects/MyProject/_DECISIONS.md
mkdir <vault>/Projects/MyProject/Scratch
```

**Windows PowerShell:**
```powershell
Copy-Item _PROJECT_TEMPLATES\_PROJECT_TEMPLATE.md     <vault>\Projects\MyProject\_PROJECT.md
Copy-Item _PROJECT_TEMPLATES\_PLAN_TEMPLATE.md        <vault>\Projects\MyProject\_PLAN.md
Copy-Item _PROJECT_TEMPLATES\_DECISIONS_TEMPLATE.md   <vault>\Projects\MyProject\_DECISIONS.md
New-Item -ItemType Directory <vault>\Projects\MyProject\Scratch
```

> Aktuell ist das Kopieren manuell. Ein Deployment-Skript gibt es noch nicht — siehe [Was dieses Template heute NICHT macht](#was-dieses-template-heute-nicht-macht).

### 2. MCP-Server installieren

Damit Claude Desktop den Vault lesen/schreiben kann, brauchst du zwei MCP-Server (kleine Node-/Python-Prozesse, die Claude Desktop beim Start mit-startet):

- **Filesystem MCP** (auch als „Obsidian MCP" konfiguriert) — Lese-/Schreibzugriff auf Vault-Dateien. Pflicht.
- **Zotero MCP** — Bibliographie-Sync. Optional.

Konkret bedeutet das: einen Eintrag pro Server in `claude_desktop_config.json` ergänzen und Claude Desktop neu starten. Schritt-für-Schritt mit Pfaden und JSON-Snippets: [`_PROJECT_TEMPLATES/Setup_Connectors_Windows.md`](_PROJECT_TEMPLATES/Setup_Connectors_Windows.md) (Windows). Plattformübergreifender Guide: [`_PROJECT_TEMPLATES/Setup_Guide.md`](_PROJECT_TEMPLATES/Setup_Guide.md).

### 3. Claude Project anlegen

In Claude Desktop ein neues Project erstellen, dann den System-Prompt aus [`_PROJECT_TEMPLATES/_CLAUDE_PROJECT_SYSTEM_PROMPT.md`](_PROJECT_TEMPLATES/_CLAUDE_PROJECT_SYSTEM_PROMPT.md) einfügen und alle `[PLACEHOLDERS]` mit deinen Werten ersetzen:

- `[PROJECT_NAME]`, `[USER_NAME]`, `[DOMAIN]`, `[SHORT_DESCRIPTION]`
- `[VAULT_ROOT_PATH]`, `[PROJECT_FOLDER]`
- `[COLLECTION_KEY]`, `[COLLECTION_NAME]` (nur wenn Zotero genutzt wird)
- `[REPO_URL]` (optional)

Konventionen, die alle Projekte teilen, stehen in [`_PROJECT_TEMPLATES/_CONVENTIONS.md`](_PROJECT_TEMPLATES/_CONVENTIONS.md).

### 4. Erste Session

- Chat öffnen, etwas brainstormen
- Bei einer Statusfrage: Claude macht **Auto-Pull** und liest `_PROJECT.md`
- Wenn etwas konsolidierungswürdig ist: `/push` — das 5-Schritt-Ritual startet
- Am Ende: **Next-Chat-Starter** (kurzer Kontext-Block, den Claude in Schritt 5 ausgibt) kopieren und als erste Nachricht in die nächste Session einfügen

---

## Dr.-Prompts

Vier rollenbasierte System-Prompts unter [`Prompts/`](Prompts/) — der Name kommt daher, dass jeder Prompt eine fiktive Fach-Persona definiert (Dr. EveryDay, Dr. Code, Dr. Analyse, Dr. Mail). Sie sind für Sessions gedacht, die **kein** Projekt-Vault brauchen:

| Prompt                                              | Rolle                                                                  |
| --------------------------------------------------- | ---------------------------------------------------------------------- |
| [`Dr_EveryDay.md`](Prompts/Dr_EveryDay.md)         | Alltagsfragen mit harter Source-Verification-Pflicht und Anti-Halluzinations-Regeln |
| [`Dr_Code.md`](Prompts/Dr_Code.md)                  | Programmier-Assistent: vollständige Dateien, Doxygen-Doku, sauberer Stil |
| [`Dr_Analyse.md`](Prompts/Dr_Analyse.md)            | Text- und Kommunikationsoptimierung mit psychologischer Analyse        |
| [`Dr_Mail.md`](Prompts/Dr_Mail.md)                  | Business- und formelle E-Mails: kurz, präzise, ohne Erfindung           |

Verwendung: Inhalt kopieren, in ein Claude Project oder eine Custom-GPT-Konfiguration einfügen, fertig. Sie funktionieren unabhängig von Vault und MCP.

---

## Folder-Layout

```
docs/Claude_Research_Template/
├── ReadMe.md                          ← du bist hier (echte README, aktueller Stand)
├── ReadMe_Future.md                   ← Zukunftsbild mit Wiki-Schiene
├── temp.md                            ← Arbeitsnotiz (kein Bestandteil)
│
├── _PROJECT_TEMPLATES/                ← Vorlagen für neue Projekte
│   ├── Setup_Guide.md                 ← Setup plattformübergreifend
│   ├── Setup_Connectors_Windows.md    ← MCP-Server auf Windows
│   ├── _CLAUDE_PROJECT_SYSTEM_PROMPT.md ← System-Prompt fürs Claude Project
│   ├── _CONVENTIONS.md                ← Vault-übergreifende Konventionen
│   ├── _PROJECT_TEMPLATE.md           ← Vorlage für _PROJECT.md
│   ├── _PLAN_TEMPLATE.md              ← Vorlage für _PLAN.md
│   ├── _DECISIONS_TEMPLATE.md         ← Vorlage für _DECISIONS.md
│   ├── _SCRATCH_TEMPLATE.md           ← Vorlage für Scratch-Notizen
│   ├── _PROJECT.md                    ← Status dieses Templates selbst
│   └── archive/                       ← ältere Template-Versionen
│
└── Prompts/                           ← Dr.-Prompts (rollenbasierte System-Prompts)
    ├── Dr_EveryDay.md
    ├── Dr_Code.md
    ├── Dr_Analyse.md
    ├── Dr_Mail.md
    └── archive/                       ← frühere Prompt-Varianten
```

---

## Was dieses Template heute NICHT macht

Damit du nicht nach Funktionen suchst, die nicht da sind:

- **Keine Wiki-Schiene.** Kein `og-wiki` Repo, kein `wiki-update` Skill, kein `/wiki-realign`. Die Idee dazu steht in [`ReadMe_Future.md`](ReadMe_Future.md), umgesetzt ist sie nicht.
- **Kein Auto-Deployment der Templates.** Du kopierst die `_*.md`-Vorlagen manuell in deinen Vault. Ein Skript dafür existiert nicht.
- **Keine Integration mit dem DevContainer dieses Repos.** Der DevContainer (Claude Code + `package-docs`) lebt in einer eigenen Welt. Er hat keinen Vault-Zugriff und keine MCP-Server installiert. Siehe Diagramm oben.
- **Kein Push Obsidian → Zotero.** `/sync` zieht nur in eine Richtung — Adds gehen über `zotero_add_by_doi`.
- **Kein Auto-Trigger für `/push`.** Konsolidierung passiert immer nur, wenn der User es explizit anstößt.

---

## Glossar

**OgVault** — Persönlicher Obsidian-Vault, Single Source of Truth für Strategie, Pläne, Entscheidungen, persönliche Notizen.

**Vault-Maschine** — Die Maschine, auf der dein OgVault physisch liegt und Claude Desktop mit MCP-Anbindung läuft.

**Claude Project** — Eine Projekt-Hülle in Claude Desktop, die den System-Prompt + Custom Instructions trägt. Pro Vault-Projekt eines.

**MCP** (Model Context Protocol) — Brücke zwischen Claude Desktop und externen Systemen (Filesystem, Zotero). Macht den Vault für Claude lesbar/schreibbar.

**Auto-Pull** — Automatisches Lesen relevanter Vault-Files bei substantiellen Fragen, immer mit transparentem Hinweis.

**`/push`** — 5-Schritt-Ritual: Recap → Diff-Plan → Rückfragen → Schreiben (pro Datei nach OK) → Closer.

**`/pull*`** — Familie expliziter Read-Befehle: `/pull`, `/pull_path`, `/pull_keyword`, `/pull_subproject`, `/where`.

**`/sync`** — Zotero ↔ Obsidian Bibliographie-Abgleich, Diff-basiert, pro Kategorie bestätigt.

**Drift-Check** — Kompakter Cross-Check alle 3–4 substantielle Wechsel: gleicht Chat-Realität mit Vault-Stand ab.

**Subprojekt** — Eingebettetes Arbeitsthema mit eigenem `_PLAN.md` unter einem Parent-Projekt. Decisions tagsweise im Parent-Log.

---

## Verwandte Dokumente

- [`ReadMe_Future.md`](ReadMe_Future.md) — Zukunftsbild mit Wiki-Schiene und Drei-Schienen-Architektur (Soll, nicht gebaut)
- [`_PROJECT_TEMPLATES/Setup_Guide.md`](_PROJECT_TEMPLATES/Setup_Guide.md) — vollständiger plattformübergreifender Setup
- [`_PROJECT_TEMPLATES/Setup_Connectors_Windows.md`](_PROJECT_TEMPLATES/Setup_Connectors_Windows.md) — MCP-Server auf Windows
- [`_PROJECT_TEMPLATES/_CLAUDE_PROJECT_SYSTEM_PROMPT.md`](_PROJECT_TEMPLATES/_CLAUDE_PROJECT_SYSTEM_PROMPT.md) — der System-Prompt
- [`_PROJECT_TEMPLATES/_CONVENTIONS.md`](_PROJECT_TEMPLATES/_CONVENTIONS.md) — Vault-übergreifende Regeln
- [`../../ReadMe.md`](../../ReadMe.md) — Repo-Root-Onboarding (DevContainer-Doku)
- [`../../CLAUDE.md`](../../CLAUDE.md) — Projekt-Kontext für Claude Code im Container
