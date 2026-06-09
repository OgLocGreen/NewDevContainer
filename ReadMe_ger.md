# NewDevContainer Development Template

## Übersicht
Diese Vorlage bietet eine standardisierte Entwicklungsumgebung für Python-Projekte mit DevContainers, Docker und Docker Compose. Die Umgebung ist so konfiguriert, dass sie sofort einsatzbereit ist, unabhängig vom Host-Betriebssystem.

## Installation

### Voraussetzungen

- [Git](https://git-scm.com/)
- [Docker](https://www.docker.com/) mit Docker Compose V2
- [Visual Studio Code](https://code.visualstudio.com/) mit der [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) Extension
- NVIDIA GPU + Treiber *(optional — siehe GPU-spezifische Einstellungen)*

### 1. Repository klonen

```bash
git clone git@github.com:dein-benutzername/dein-repo.git
cd dein-repo
git submodule update --init --recursive
```

### 2. Im Dev Container öffnen

Öffne den Ordner in VS Code und wähle **„Reopen in Container"**, wenn die Aufforderung erscheint, oder führe aus:

```
Dev Containers: Rebuild and Reopen in Container
```

Der Container wird automatisch gebaut und alle System-Abhängigkeiten werden installiert.

### 3. Python-Abhängigkeiten installieren

Im Container-Terminal:

```bash
pip install -r .devcontainer/requirements.txt
```

Die virtuelle Umgebung liegt unter `/app/venv` und wird automatisch aktiviert.

---

## DevContainer

Der DevContainer bietet eine vollständig konfigurierte Entwicklungsumgebung, die in VS Code genutzt werden kann. Er enthält:

- Python-Laufzeitumgebung
- Vorkonfigurierte Extensions für Python-Entwicklung
- Einheitliche Umgebungsvariablen
- Konsistente Abhängigkeiten

### Erste Schritte mit DevContainers

1. Installiere [Visual Studio Code](https://code.visualstudio.com/)
2. Installiere die [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) Extension
3. Öffne dieses Verzeichnis in VS Code
4. Wenn die Aufforderung erscheint, wähle "Reopen in Container"
5. Die Umgebung wird automatisch eingerichtet

## Docker & Docker Compose

### Docker-Konfiguration

Die Entwicklungsumgebung basiert auf dem offiziellen NVIDIA-CUDA-Image. Die
`Dockerfile` (maßgeblich ist `.devcontainer/Dockerfile`) ist aufgebaut um:

```dockerfile
FROM nvidia/cuda:12.6.2-cudnn-devel-ubuntu24.04

# System-Pakete: Python 3.12, git, Docker-CLI, X11, ffmpeg, ...
# Node.js 20 (von der Claude-Code-CLI benötigt)

# Isoliertes virtualenv als Default-Interpreter
RUN python3 -m venv /app/venv
ENV VIRTUAL_ENV=/app/venv
ENV PATH="/app/venv/bin:$PATH"

WORKDIR /app/new_dev_container
```

### Docker Compose

Docker Compose orchestriert den Container und (optional) GPU-Ressourcen. Zwei
Profile sind enthalten:

| Datei                                  | Wann verwenden                              |
| -------------------------------------- | ------------------------------------------- |
| `.devcontainer/docker-compose.yml`     | Mit NVIDIA-GPU + Treibern (Standard)        |
| `.devcontainer/docker-compose.cpu.yml` | Reine Laptops, CI-Runner, Apple Silicon, … |

GPU-Profil (Standard – vollständig in `.devcontainer/docker-compose.yml`):

```yaml
services:
  service_new_dev_container:
    build:
      context: .
    volumes:
      - ${localWorkspaceFolder:-..}:/app/new_dev_container
    shm_size: '32gb'
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
```

CPU-Profil – gleiches Image, ohne `deploy.resources`-GPU-Reservierung. Direkt
starten mit:

```bash
docker compose -f .devcontainer/docker-compose.cpu.yml up
```

Oder VS Code darauf zeigen lassen, indem `.devcontainer/devcontainer.json`
angepasst wird:

```jsonc
"dockerComposeFile": "docker-compose.cpu.yml"
```

## Python-Entwicklung

### Projektstruktur

```
NewDevContainer/
├── .claude/                        # Claude Code Team-Defaults (settings, commands, skills)
│   └── skills/
│       └── package-docs/           # Lädt docs/package_a|b bei Bedarf
├── .devcontainer/                  # DevContainer-Konfiguration
│   ├── Dockerfile                  # CUDA 12.6 + Python 3.12 Basis-Image
│   ├── docker-compose.yml          # GPU-Profil (Standard)
│   ├── docker-compose.cpu.yml      # CPU-only-Profil (Laptops / kein NVIDIA)
│   └── requirements.txt            # Dev-Time Python-Abhängigkeiten (Basic AI Stack)
├── .github/                        # GitHub Copilot Instructions und Prompt-Dateien
├── .vscode/                        # Gemeinsame VS Code Settings
├── src/                            # Quellcode
│   └── NewWandB/                   # Git-Submodul
├── data/                           # Beispieldaten (keine großen Binaries)
├── docs/                           # Dokumentation, Cheat Sheets, Templates
│   ├── package_a/                  # Referenz für package_a (vom package-docs-Skill gelesen)
│   └── package_b/                  # Referenz für package_b (vom package-docs-Skill gelesen)
├── CLAUDE.md                       # Kontext für Claude Code
├── ReadMe.md                       # Englische Variante
├── ReadMe_ger.md                   # Diese Datei
└── NewDevContainer.code-workspace  # VS Code Multi-Root Workspace
```

### Neues Python-Programm erstellen

1. Erstelle eine neue Datei unter `src/` mit `.py`-Erweiterung
2. Importiere benötigte Module:
   ```python
   import pandas as pd
   import numpy as np
   ```
3. Schreibe deine Funktionen und Klassen
4. Füge einen Einstiegspunkt hinzu:
   ```python
   if __name__ == "__main__":
       # Code wird nur ausgeführt, wenn die Datei direkt aufgerufen wird
       main()
   ```

### Abhängigkeiten verwalten

`.devcontainer/requirements.txt` enthält den Basic-AI-Stack (numpy, pandas,
matplotlib, jupyterlab, scikit-learn, torch, transformers, streamlit, …) und
zieht standardmäßig CPU-Wheels – funktioniert in beiden Compose-Profilen.

1. Neue Abhängigkeiten in `.devcontainer/requirements.txt` hinzufügen
2. Im Container-Terminal ausführen:
   ```bash
   pip install -r .devcontainer/requirements.txt
   ```

Für CUDA-12.6-Wheels von PyTorch (nur sinnvoll im GPU-Profil) nach der
Basis-Installation überschreiben:

```bash
pip install --upgrade \
    --index-url https://download.pytorch.org/whl/cu126 \
    torch torchvision
```

## AI Assistant Setup

This template pre-configures AI coding assistants (GitHub Copilot and Claude Code)
to use the project's coding rules automatically — no manual copy-paste needed.

### How it works

| Tool                   | Config File                       | What it does                                                         |
| ---------------------- | --------------------------------- | -------------------------------------------------------------------- |
| GitHub Copilot         | `.github/copilot-instructions.md` | Pre-prompt loaded automatically in every chat session                |
| GitHub Copilot         | `.vscode/settings.json`           | Injects `CodingRules.md` and package references into code generation |
| Claude Code            | `CLAUDE.md`                       | Full project context with reference to coding rules                  |
| Custom GPT / Claude.ai | `docs/help/CustomGPT/`            | Standalone system prompts for external chatbots                      |

### Single source of truth

All AI tools point to the same rules file:
```
docs/help/Templates/CodingRules.md
```
Update this file once and every assistant automatically follows the new rules.

### Package Reference Docs

Drop package-specific API notes, gotchas, and usage examples into the reference folders:
```
docs/package_a/   ← C++ package references (e.g. Eigen)
docs/package_b/   ← additional packages
```
Copilot reads these automatically during code generation and review.

### Reusable Skills (Prompt Files)

**GitHub Copilot** — invoke via the `/` prompt picker in Copilot Chat:

| Skill             | File                                       | What it does                                                            |
| ----------------- | ------------------------------------------ | ----------------------------------------------------------------------- |
| `/fix-spelling`   | `.github/prompts/fix-spelling.prompt.md`   | Fixes spelling/grammar in docs without touching code or technical terms |
| `/read-package-a` | `.github/prompts/read-package-a.prompt.md` | Loads all docs from `docs/package_a/` into the session context          |
| `/read-package-b` | `.github/prompts/read-package-b.prompt.md` | Loads all docs from `docs/package_b/` into the session context          |

**Claude Code** — invoke via the `/` command picker in Claude Code chat:

| Command           | File                                 | What it does                                                            |
| ----------------- | ------------------------------------ | ----------------------------------------------------------------------- |
| `/spell-check`    | `.claude/commands/spell-check.md`    | Fixes spelling/grammar in docs without touching code or technical terms |
| `/read-package-a` | `.claude/commands/read-package-a.md` | Loads all docs from `docs/package_a/` into the session context          |
| `/read-package-b` | `.claude/commands/read-package-b.md` | Loads all docs from `docs/package_b/` into the session context          |

### Adding a new package reference

1. Create a new folder `docs/package_c/` and add your reference Markdown files.
2. **Copilot:** Copy `.github/prompts/read-package-a.prompt.md` → `read-package-c.prompt.md` and update the path inside. Add the new file to `github.copilot.chat.codeGeneration.instructions` in `.vscode/settings.json`. Register it in `.github/copilot-instructions.md`.
3. **Claude Code:** Copy `.claude/commands/read-package-a.md` → `read-package-c.md` and update the path inside.

---

## Best Practices

1. **Versionskontrolle**: Nutze Git für die Versionskontrolle deines Codes
2. **Tests**: Schreibe Unit-Tests für deinen Code im `tests/` Verzeichnis
3. **Dokumentation**: Dokumentiere deinen Code mit Docstrings
4. **Umgebungsvariablen**: Sensible Daten über `.env` Dateien (nicht in Git) verwalten

## Ausführen von Python-Programmen

Im DevContainer Terminal:

```bash
# Direkt ausführen
python src/dein_programm.py

# Mit Argumenten
python src/dein_programm.py --argument1 wert1

# Als Modul
python -m src.dein_modul
```

## Fehlerbehebung

- **Container startet nicht**: Prüfe, ob Docker läuft und du ausreichende Berechtigungen hast
- **Module nicht gefunden**: Überprüfe die `requirements.txt` und führe `pip install -r requirements.txt` aus
- **Pfad-Probleme**: Achte auf korrekte relative Imports in Python


## Start DevContainer Schritt-für-Schritt-Anleitung
- **WSL öffnen**
Starte dein WSL-Terminal (z. B. Ubuntu) über deine Kommandozeile.

- **Mit GitHub verbinden**
Stelle sicher, dass du Zugriff auf dein GitHub-Konto hast. Konfiguriere Git:

   `git config --global user.name 'Dein Name'`

   `git config --global user.email 'deine@email.com'`

- **SSH-Key erstellen**
Falls noch nicht vorhanden, erstelle einen SSH-Schlüssel:

   `ssh-keygen -t ed25519 -C 'deine@email.com'`

   Füge den öffentlichen Schlüssel `(.ssh/id_ed25519.pub)` in deinem GitHub-Konto unter
   "Settings → SSH and GPG Keys" hinzu.

- **Repository klonen**
Klone das Repository über SSH:

   `git clone git@github.com:dein-benutzername/dein-repo.git`

- **Visual Studio Code installieren**
Installiere Visual Studio Code von
`https://code.visualstudio.com/`

- **Visual Studio Code im WSL öffnen**
Öffne dein Projektverzeichnis mit VS Code aus dem WSL-Terminal:

       `code .`

- **Benötigte Erweiterungen installieren**
   - Python
   - Remote - Containers
   - Remote - SSH (Wenn der Container auf einem Remote-SSH_Server läuft)
   - Remote - WSL (Wenn der Container Local auf Linux läuft)


- **Projektordner öffnen**
Öffne in Visual Studio Code den Ordner des geklonten Projekts:

   `code dein-path/`

- **Pfad in docker-compose.yml**
Seit Template-Version 2 nutzt `docker-compose.yml` automatisch `${localWorkspaceFolder}` — manuelles Anpassen ist nicht mehr nötig. Wenn du den Container ohne VS Code startest, kannst du den Pfad per Env-Variable überschreiben:

      localWorkspaceFolder=/dein/pfad/zum/projekt docker compose up

- **GPU-spezifische Einstellungen anpassen (optional)**
Falls du keine NVIDIA-GPU hast, benutze das CPU-Profil statt die GPU-Datei
manuell zu patchen: `devcontainer.json` auf `docker-compose.cpu.yml` zeigen
lassen oder den Container direkt starten mit:

      docker compose -f .devcontainer/docker-compose.cpu.yml up

- **Container neu erstellen**
Öffne in Visual Studio Code die Kommando-Palette ("F1" oder "Ctrl+Shift+P") und wähle:

   `Dev Containers: Rebuild and Reopen in Container`
