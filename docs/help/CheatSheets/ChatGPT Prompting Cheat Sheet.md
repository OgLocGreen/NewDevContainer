## ChatGPT Prompting Cheat Sheet – Wissenschaftliche Recherche (Stand 2025)
### Grundlagen für effektive wissenschaftliche Recherche
- **Klarheit & Präzision:** Formuliere spezifische, eindeutige Fragestellungen mit klaren Erwartungen bezüglich Quellen und Output-Formaten.
- **Aktualität:** Gib stets das Erscheinungsjahr relevanter Quellen (Paper, Artikel, Konferenzen) explizit an.
- **Relevanz der Quellen:** Beziehe dich bevorzugt auf stark zitierte, renommierte wissenschaftliche Arbeiten oder Publikationen von anerkannten Konferenzen (z. B. NeurIPS, ICML, ICLR).
### Erweiterte Techniken für Recherche-Prompts
#### 1. Few-Shot & Chain-of-Thought (CoT)
- **Few-Shot Prompting (Brown et al., 2022):**<^
    - Nutze konkrete Recherchebeispiele, um exakte Formate und Quellenstruktur klar vorzugeben.
- **Chain-of-Thought (Wei et al., 2022):**
    - Fordere schrittweise Erläuterungen zur systematischen Analyse von Forschungsfragen und Quellen.
#### 2. Rollenbeschreibung für Recherche
- Klar definierte Rolle als wissenschaftlicher Recherche-Assistent:
    ```markdown
    [System] Du bist ein wissenschaftlicher Rechercheassistent, spezialisiert auf multimodale Transformer (Li et al., 2023). Identifiziere präzise und aktuelle Quellen zu technischen Forschungsfragen.
    ```
#### 3. Strukturierte Ausgabeformate erzwingen
- Fordere strukturierte Antworten mit Quellen und Kurzbeschreibung:
    ```markdown
    Gib deine Antwort strikt in folgendem Format aus:
    {
      "Fragestellung": "...",
      "Ergebnisse": [
        {"Titel": "...", "Autor": "...", "Jahr": "...", "Kurzbeschreibung": "..."}
      ]
    }
    ```
#### 4. Meta-Prompting zur Quellenqualität
- Lass das Modell die Qualität der gelieferten Quellen bewerten:
    ```markdown
    Bewerte die Qualität der vorgeschlagenen Quellen hinsichtlich ihrer Relevanz und Zitierhäufigkeit (1–5). Gib Verbesserungsvorschläge für weitere Recherche.
    ```
### Parametersteuerung für präzise Rechercheergebnisse
- **Temperatur:**
    - Niedrige Temperatur (0.2–0.4) für möglichst präzise und zuverlässige Quellen.
- **Adaptive Prompting:** Iterative Anpassung des Recherche-Prompts bei unbefriedigenden Ergebnissen:
    ```markdown
    Die vorherige Recherche war unvollständig. Erweitere deine Suche auf Paper der letzten drei Jahre, insbesondere stark zitierte Artikel.
    ```
### Iteratives Prompt-Refinement in der Recherche
- Systematische Verbesserung bei ungenauen Ergebnissen:
    ```markdown
    Deine vorige Antwort enthielt keine relevanten Quellen aus renommierten Konferenzen. Wiederhole die Suche mit Fokus auf Konferenzen wie NeurIPS und ICML der Jahre 2023–2025.
    ```
### Troubleshooting & typische Fallstricke
- **Mehrdeutigkeit vermeiden:** Stelle klar definierte, eindeutige Recherchefragen.
- **Bias-Erkennung:** Fordere explizit neutrale Darstellungen wissenschaftlicher Ergebnisse:
    ```markdown
    Recherchiere Quellen neutral und ohne kulturelle oder geschlechtsspezifische Verzerrungen.
    ```
### Ethik & Zuverlässigkeit in der Recherche
- **Safety Instructions:** Weise ausdrücklich darauf hin, ethisch problematische Quellen zu vermeiden:
    ```markdown
    Vermeide fragwürdige oder ethisch kontroverse Quellen. Nutze ausschließlich seriöse, wissenschaftlich anerkannte Literatur.
    ```
### Beispiele für gutes (DO) und schlechtes (DON'T) Prompting bei wissenschaftlicher Recherche – Anomaly Detection & Predictive Maintenance
**Hinweis:** Für hochwertige Ergebnisse sollte stets auf Englisch recherchiert werden. Achte auf Veröffentlichungsjahr, Relevanz (z. B. Zitierungen), Open-Access-Verfügbarkeit (z. B. IEEE Xplore, arXiv) und Herkunft aus renommierten Konferenzen (z. B. NeurIPS, ICML, ICLR, AAAI, IEEE).
**DO:**
```
Finde drei aktuelle, vielzitierte und öffentlich zugängliche Paper (2023–2025) zum Thema "Anomaly Detection for Predictive Maintenance". Achte auf Veröffentlichungen aus renommierten Konferenzen wie NeurIPS, ICML, ICLR, AAAI oder IEEE. Gib Titel, Autoren, Veröffentlichungsjahr, Quelle (z. B. DOI oder arXiv-Link), Zitierhäufigkeit und eine kurze Zusammenfassung der wichtigsten Erkenntnisse an.
```
**DON'T:**
```
Such mal aktuelle Paper über Anomalie-Erkennung und Wartung.
```
#### Warum gut?
- Klare und präzise Angabe des Themas („Anomaly Detection for Predictive Maintenance“).
- Konkrete zeitliche Eingrenzung (aktuelle Arbeiten von 2023–2025).
- Explizite Angabe von renommierten Konferenzen (Qualitätssicherung der Quellen).
- Hinweis auf öffentlich zugängliche Quellen wie IEEE oder arXiv erhöht die Nachvollziehbarkeit.
- Angabe von Zitathäufigkeit, um Relevanz und Einfluss der Arbeiten abzuschätzen.
- Klare Aufforderung zur Zusammenfassung zentraler Ergebnisse.
#### Warum schlecht?
- Ungenaue Beschreibung („aktuell“ unklar definiert).
- Sprache Deutsch – reduziert die Qualität und Breite der wissenschaftlichen Ergebnisse.
- Fehlende Angabe von Jahr, Quelle, Konferenz und Zitation.
- Keine Aufforderung zur Bewertung oder Zusammenfassung.
### Zusammenfassung & Best Practices zur wissenschaftlichen Recherche
- Nutze präzise und klar definierte Recherche-Prompts.
- Iterative Verfeinerung des Recherche-Prompts zur Erhöhung der Relevanz und Qualität der Quellen.
- Parameter gezielt einsetzen, um die Präzision der Ergebnisse zu maximieren.
- Explizite Nennung und kritische Bewertung von Quellen.