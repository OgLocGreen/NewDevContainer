# LaTeX-Präsentationen (Beamer)

Zwei Vortragsfolien im HHN-Corporate-Design für PhD-Kolleg:innen und Profs.

| Datei | Inhalt |
| ----- | ------ |
| `devcontainer_template.tex`     | Präsentation 1 — Reproduzierbare Forschungsumgebung (Dev Container) |
| `claude_project_template.tex`   | Präsentation 2 — Disziplinierter KI-Forschungsassistent (Claude Project Template) |
| `hhntheme.sty`                  | Gemeinsames Beamer-Theme (HHN-Farben aus `docs/help/Templates/color_hhn_template.md`) |

## Kompilieren

Beide Dateien sind **`pdflatex`-kompatibel** (nur Standardpakete: `beamer`, `tikz`,
`listings`, `booktabs`, `babel`). Zwei Durchläufe wegen TikZ `remember picture`.

```bash
# Lokal (TeX Live / MiKTeX)
latexmk -pdf devcontainer_template.tex
latexmk -pdf claude_project_template.tex

# oder manuell (zweimal):
pdflatex devcontainer_template.tex && pdflatex devcontainer_template.tex
```

**Overleaf:** Ordner hochladen, Compiler auf *pdfLaTeX* stellen, `*.tex` als
Hauptdokument wählen. `hhntheme.sty` muss im selben Projekt liegen.

## Anpassen

- `\author{...}` und `\institute{...}` im Kopf jeder `.tex` sind **Platzhalter** —
  bitte auf die reale Person/Einrichtung setzen.
- Der Akzent-Kicker auf der Titelseite kommt aus `\renewcommand{\hhnkicker}{...}`.
- Farben/Schrift zentral in `hhntheme.sty`.

> Hinweis: Die Folien wurden statisch reviewt, aber mangels lokaler TeX-Distribution
> nicht hier kompiliert. Beim ersten Build ggf. fehlende TeX-Pakete nachinstallieren.
