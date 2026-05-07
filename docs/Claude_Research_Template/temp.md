Ah, jetzt ist die Asymmetrie klar: Wiki *darf* aus Strategie lernen, aber nur durch ein **explizites, beidseitig vorschlagbares Ritual** — nicht durch Auto-Sync und nicht durch ständiges Mounten. Strategiewechsel im OgVault → ggf. neue Reading-List, neue Concept-Stubs, neue Paper-Ordner-Struktur im Wiki.

Wichtig daran: Es ist *kein zweiter Datenfluss in Echtzeit*. Es ist ein bewusster Trigger, den entweder du auslöst ("Strategiewechsel, Wiki anpassen") oder ich vorschlage ("In den letzten drei `/push` ist X dreimal als neue Richtung aufgetaucht — willst du das im Wiki spiegeln?").

## Diagramm 1 — Drei Schienen mit dem zusätzlichen Strategie→Wiki-Pfad

```mermaid
flowchart LR
    subgraph LANE1["🧭 STRATEGIE-Schiene (Langzeit)"]
        direction TB
        OG[("📘 OgVault<br/>System-Design, Richtungen<br/>_PROJECT _PLAN _DECISIONS")]
        CD["Claude Desktop<br/>+ Filesystem MCP<br/>+ Zotero MCP"]
        OBS1["Obsidian"]
        CD <-->|"/push /pull*"| OG
        OBS1 <-->|edit| OG
    end

    subgraph LANE2["📚 REFERENZ-Schiene (mittlere Frequenz)"]
        direction TB
        WR["📦 og-wiki Repo<br/>(privat)"]
        WV[("📗 Wiki-Vault<br/>concepts/, papers/<br/>projects/, reading-lists/<br/>index.md, .manifest.json")]
        OBS2["Obsidian<br/>(zweiter Vault)"]
        WR --- WV
        OBS2 -.lesen / browsen.-> WV
    end

    subgraph LANE3["⚙️ AUSFÜHRUNGS-Schiene (austauschbar)"]
        direction TB
        R1["📦 Repo A<br/>DevContainer + Claude Code"]
        R2["📦 Repo B"]
        R3["📦 Repo C ..."]
    end

    OG -. "TODO migriert<br/>bei Repo-Start" .-> R1
    OG -. " " .-> R2
    OG -. " " .-> R3

    R1 ==>|"wiki-update<br/>(git push)"| WR
    R2 ==>|"wiki-update"| WR
    R3 ==>|"wiki-update"| WR

    WV -. "selten: Erkenntnis<br/>elevaten zu Strategie<br/>(Wiki → OG)" .-> OG

    OG ===>|"/wiki-realign<br/>(Strategie → Wiki)<br/>nur auf Trigger"| WR

    classDef strat fill:#e8f1ff,stroke:#3b6fb6
    classDef ref fill:#eaf7ea,stroke:#4a8a4a
    classDef exec fill:#fff4e0,stroke:#b07a2a
    class OG,CD,OBS1 strat
    class WR,WV,OBS2 ref
    class R1,R2,R3 exec
```

Das `===>` zwischen OG und Wiki ist der neue, explizite Pfad — mit dem Hinweis "nur auf Trigger". Eine fette Linie, weil sie *strukturelle* Auswirkung hat (Reading-Lists, Concept-Stubs, ggf. Ordner-Reorgs), keine kontinuierliche.

## Diagramm 2 — Wann der Strategie→Wiki-Trigger feuert

```mermaid
flowchart TB
    Start([Während /push oder /where im OgVault]) --> Check{Eine dieser<br/>Bedingungen erfüllt?}

    Check -->|"_DECISIONS bekommt<br/>strategischen Eintrag<br/>('neue Richtung X')"| Suggest1[Claude schlägt vor:<br/>'Wiki anpassen?']
    Check -->|"_PLAN ändert sich<br/>spürbar (neue Phase,<br/>Pivot, dropped scope)"| Suggest2[Claude schlägt vor]
    Check -->|"Du sagst explizit:<br/>'Wiki muss das wissen'<br/>oder /wiki-realign"| Trigger[Direkter Trigger]
    Check -->|"Drift-Check sieht:<br/>Wiki-projects/* divergiert<br/>von _PLAN"| Suggest3[Claude schlägt vor]
    Check -->|sonst| Skip[kein Trigger,<br/>weitermachen]

    Suggest1 --> Decide{Du bestätigst?}
    Suggest2 --> Decide
    Suggest3 --> Decide
    Trigger --> Ritual

    Decide -->|nein / später| Skip
    Decide -->|ja| Ritual[/wiki-realign Ritual/]

    Ritual --> S1[1 Diff-Plan: was im Wiki<br/>betroffen wäre]
    S1 --> S2[2 Vorschlag pro Bereich:<br/>concepts/, reading-lists/,<br/>projects/repo-x.md, ...]
    S2 --> S3[3 Per-Bereich-Bestätigung]
    S3 --> S4[4 Schreiben + log.md-Eintrag<br/>'realigned from OgVault YYYY-MM-DD']
    S4 --> S5[5 Cross-Reference im OgVault:<br/>_DECISIONS-Eintrag erwähnt<br/>Wiki-Update]

    classDef trigger fill:#ffe8e8,stroke:#b03a3a
    classDef ritual fill:#e8f5ff,stroke:#3b6fb6
    classDef skip fill:#f0f0f0,stroke:#888
    class Suggest1,Suggest2,Suggest3,Trigger trigger
    class Ritual,S1,S2,S3,S4,S5 ritual
    class Skip skip
```

## Was das `wiki-realign`-Ritual *konkret* anfasst

Damit der Pfad nicht nebulös bleibt — vier typische Realign-Effekte:

- **Reading-Lists**: `wiki/reading-lists/<topic>.md` — Liste von Papers die zur neuen Richtung passen. Stub mit Suchanfragen, nicht ausgefüllt. Die Repos füllen sie auf.
- **Concept-Stubs**: leere `wiki/concepts/<concept>.md`-Files für Begriffe die in der neuen Strategie auftauchen aber im Wiki noch nicht existieren. Repos schreiben sie aus, wenn sie über den Concept stolpern.
- **Project-Page-Update**: `wiki/projects/<repo>.md` bekommt einen Hinweis "Strategy shifted YYYY-MM-DD, see OgVault `_DECISIONS`". Damit landet beim nächsten `wiki-query` der Hinweis im Kontext.
- **Archivierung**: alte Reading-Lists oder Concept-Pages, die zur abgelösten Richtung gehörten, wandern nach `wiki/_archive/YYYY-MM-DD_<topic>/`. Nicht löschen — du willst nachverfolgen können, *warum* eine Richtung verlassen wurde.

## Was das Ritual *nicht* tut

- Kein Auto-Trigger ohne deine Bestätigung. Auch wenn die Bedingung "neue Richtung in `_DECISIONS`" klar zutrifft — der Vorschlag kommt, das Schreiben passiert nur nach OK.
- Keine Übersetzung von Strategie-Inhalt 1:1 ins Wiki. Strategie bleibt im OgVault. Das Wiki bekommt nur *strukturelle Konsequenzen*: neue Stubs, neue Listen, Archivierung — keine Volltexte aus `_DECISIONS`.
- Kein Schreiben von Repos ins OgVault über diesen Pfad. Die andere Richtung (Wiki → OgVault) bleibt komplett manuell und seltener.

## Symmetrie-Check

Damit hast du jetzt drei explizite Rituale, eines pro Richtung:

| Richtung       | Ritual                                   | Frequenz             | Wer triggert                 |
| -------------- | ---------------------------------------- | -------------------- | ---------------------------- |
| Chat → OgVault | `/push`                                  | mehrmals pro Woche   | du                           |
| Repo → Wiki    | `wiki-update`                            | pro Coding-Session   | du im DevContainer           |
| OgVault → Wiki | `wiki-realign`                           | pro Strategiewechsel | du, oder ich schlage vor     |
| Wiki → OgVault | (kein eigenes Ritual, manueller `/push`) | sehr selten          | du, beim periodischen Review |

Die letzte Zeile ist absichtlich kein eigenes Ritual — wenn das Wiki etwas Strategisches enthält, gehört der Anlass für einen `/push` direkt in deinen normalen OgVault-Flow. Mehr Mechanik dort wäre Overengineering.

## Eine Sache zum Validieren

Mein Vorschlag enthält die Annahme, dass Wiki-Strukturänderungen (Stubs, Listen, Archivierung) ausreichen — ohne dass das Wiki *Strategie-Text* spiegelt. Sehe ich das richtig, oder willst du dass `wiki-realign` z. B. auch eine kurze "current strategic direction"-Notiz im Wiki hinterlässt, damit Claude Code im DevContainer beim `wiki-query` automatisch mitliest *wohin* das Projekt gerade zielt?
