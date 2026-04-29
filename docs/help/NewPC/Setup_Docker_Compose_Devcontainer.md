# Dev Container Setup mit Dockerfile, docker-compose.yml und devcontainer.json

Diese Anleitung erklärt das Zusammenspiel der drei zentralen Dateien für eine reproduzierbare VS-Code-Entwicklungsumgebung im Container. Sie ist als Referenz gedacht — sowohl für den ersten Aufbau als auch zum Nachschlagen, wenn du nach Wochen das eigene Setup wieder verstehen willst.

**Reihenfolge:**

1. Übersicht: welche Datei macht was
2. `Dockerfile`
3. `docker-compose.yml`
4. `.devcontainer/devcontainer.json`
5. Setup-Skripte (`postCreate`, `postStart`)
6. Python-Pakete im Container (`requirements.txt`)
7. GUI-Anwendungen (X11-Forwarding)
8. Datei-Berechtigungen (Root-Problem)
9. Workflow
10. Troubleshooting

> **Hinweis:** Wenn der Container auf einer Remote-Maschine laufen soll, siehe begleitende Anleitung *Setup_Docker_Remote_VSCode.md*.

---

## 1. Übersicht: welche Datei macht was

| Datei | Aufgabe | Wann anpassen |
|---|---|---|
| `Dockerfile` | Definiert das Image: Basis-OS, Systempakete, Python-Version, Tools | Wenn neue Systemabhängigkeiten oder eine andere Python/CUDA-Version benötigt werden |
| `docker-compose.yml` | Definiert den/die Container: Volumes, Ports, Environment, GPU, Netzwerk | Wenn Mounts, Ports, GPU-Zugriff oder Env-Variablen geändert werden |
| `.devcontainer/devcontainer.json` | Bindeglied zu VS Code: welcher Service, welche Extensions, welche Lifecycle-Befehle | Wenn VS-Code-Extensions, Interpreter-Pfad oder Startup-Verhalten angepasst werden |

Typische Verzeichnisstruktur:

```
my-project/
├── .devcontainer/
│   ├── devcontainer.json
│   └── setup_startup.sh
├── docker-compose.yml
├── Dockerfile
├── requirements.txt
├── .dockerignore
└── src/
```

---

## 2. Dockerfile

Das Dockerfile beschreibt das **Image** — also den Bauplan für den Container. Beispiel für ein ML-Projekt mit CUDA:

```dockerfile
# Base image with CUDA + cuDNN, matched to your installed driver
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

# Avoid interactive prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3.11 \
        python3.11-venv \
        python3-pip \
        git \
        curl \
        build-essential \
        # X11 client libs for GUI forwarding
        libx11-6 libxext6 libxrender1 libxtst6 \
    && rm -rf /var/lib/apt/lists/*

# Symlink so 'python' points to python3.11
RUN ln -s /usr/bin/python3.11 /usr/bin/python

# Create non-root user matching typical host UID/GID (avoids file-permission issues)
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid $USER_GID dev \
    && useradd --uid $USER_UID --gid $USER_GID -m dev

USER dev
WORKDIR /workspace
```

**Best Practices:**

- Pakete in einem einzigen `RUN` mit `&& rm -rf /var/lib/apt/lists/*` zusammenfassen — spart Image-Größe
- `--no-install-recommends` verhindert ungewollte Mit-Installationen
- Layer-Reihenfolge: was sich selten ändert (System-Pakete) zuerst, was sich oft ändert (Code) zuletzt — nutzt Docker-Layer-Caching
- `.dockerignore` anlegen, damit `.git`, `node_modules`, `.venv` etc. nicht ins Build-Context wandern

Beispiel `.dockerignore`:

```
.git
.venv
node_modules
__pycache__
*.pyc
.vscode
.idea
```

---

## 3. docker-compose.yml

Compose orchestriert den/die Container und kapselt alle Laufzeit-Details (Mounts, Ports, GPU). Komplettes Beispiel:

```yaml
services:
  dev:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        USER_UID: 1000
        USER_GID: 1000

    # Keep the container alive for VS Code to attach to
    command: sleep infinity

    volumes:
      # Project code (host -> container)
      - .:/workspace
      # Persistent virtualenv outside the workspace
      - venv-data:/workspace/.venv
      # Docker-out-of-Docker (only if you really need it)
      - /var/run/docker.sock:/var/run/docker.sock
      # X11 socket for GUI applications (Linux host only)
      - /tmp/.X11-unix:/tmp/.X11-unix

    ports:
      - "3000:3000"   # web dev server (e.g. React, Flask)
      - "8888:8888"   # Jupyter
      - "5901:5901"   # VNC (optional)

    environment:
      - DISPLAY=${DISPLAY}
      - VIRTUAL_ENV=/workspace/.venv
      - PATH=/workspace/.venv/bin:/usr/local/bin:/usr/bin:/bin

    # GPU access (requires NVIDIA Container Toolkit on host)
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]

volumes:
  venv-data:
```

### Volumes erklärt

| Mount | Zweck |
|---|---|
| `.:/workspace` | Projektcode aus dem Host wird live in den Container gespiegelt — Edits im Host sind sofort im Container sichtbar |
| `venv-data:/workspace/.venv` | Named Volume für die virtualenv. Bleibt zwischen Container-Rebuilds erhalten und wird **nicht** vom Bind-Mount oben überschrieben |
| `/var/run/docker.sock:/var/run/docker.sock` | Erlaubt `docker`-Befehle **innerhalb** des Containers (Docker-out-of-Docker). Nur einbinden wenn wirklich gebraucht — bedeutet effektiv Root-Zugriff auf den Host |
| `/tmp/.X11-unix:/tmp/.X11-unix` | X11-Socket für GUI-Apps. Nur unter Linux-Host sinnvoll, siehe Abschnitt 7 |

### Ports

`"3000:3000"` heißt: Port `3000` im Container ist als Port `3000` auf dem Host erreichbar. Wenn du nur den ersten Wert änderst (`"3001:3000"`), läuft der Service intern weiterhin auf 3000, ist von außen aber unter 3001 ansprechbar.

### GPU

Funktioniert nur, wenn auf dem Host **NVIDIA Container Toolkit** installiert ist:
[docs.nvidia.com/datacenter/cloud-native/container-toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

Verifizieren:

```bash
docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi
```

---

## 4. .devcontainer/devcontainer.json

Diese Datei sagt VS Code, **wie** der Container gestartet und integriert wird. Komplettes Beispiel:

```json
{
  "name": "Project Dev Container",

  "dockerComposeFile": "../docker-compose.yml",
  "service": "dev",
  "workspaceFolder": "/workspace",

  "remoteUser": "dev",

  "remoteEnv": {
    "DISPLAY": "${localEnv:DISPLAY}"
  },

  "customizations": {
    "vscode": {
      "settings": {
        "python.defaultInterpreterPath": "/workspace/.venv/bin/python",
        "terminal.integrated.defaultProfile.linux": "bash"
      },
      "extensions": [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "ms-toolsai.jupyter",
        "ms-azuretools.vscode-docker",
        "eamodio.gitlens"
      ]
    }
  },

  "forwardPorts": [3000, 8888],

  "postCreateCommand": "python -m venv /workspace/.venv && /workspace/.venv/bin/pip install -r requirements.txt",
  "postStartCommand": "bash .devcontainer/setup_startup.sh"
}
```

### Wichtige Felder

| Feld | Bedeutung |
|---|---|
| `dockerComposeFile` | Pfad zur Compose-Datei, **relativ zur `devcontainer.json`** |
| `service` | Name des Services aus `docker-compose.yml`, in den eingehängt wird |
| `workspaceFolder` | Pfad **im Container**, in dem das Projekt gemountet ist |
| `remoteUser` | Mit welchem User VS Code im Container arbeitet — sollte mit dem User aus dem Dockerfile übereinstimmen |
| `remoteEnv` | Env-Variablen, die in die VS-Code-Sessions im Container durchgereicht werden |
| `customizations.vscode.settings` | VS-Code-Einstellungen, die nur im Container gelten |
| `customizations.vscode.extensions` | Extensions, die beim ersten Start automatisch im Container installiert werden |
| `forwardPorts` | Ports, die VS Code automatisch auf den Host weiterreicht |
| `postCreateCommand` | Wird **einmalig nach Container-Erstellung** ausgeführt (Setup, Pip-Install) |
| `postStartCommand` | Wird **bei jedem Start** ausgeführt (Daemons, X11-Berechtigungen) |

### postCreateCommand vs postStartCommand

Häufig verwechselt:

- `postCreateCommand` — läuft genau einmal nach dem Image-Build / Container-Erstellung. Hier gehört zeitintensives Setup hin: `pip install`, `npm install`, Modelle herunterladen.
- `postStartCommand` — läuft jedes Mal beim Container-Start. Hier gehört nur hin, was bei jedem Start neu gemacht werden muss: X11 freigeben, Hintergrund-Services starten.

Pip-Install in `postStartCommand` ist ein häufiger Anti-Pattern, der bei jedem Reattach Sekunden bis Minuten kostet.

---

## 5. Setup-Skripte

Beispiel `.devcontainer/setup_startup.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Allow X11 connections from local Docker (Linux host only)
if [ -n "${DISPLAY:-}" ] && command -v xhost &>/dev/null; then
    xhost +local:docker || true
fi

# Activate the virtualenv for interactive shells
echo 'source /workspace/.venv/bin/activate' >> ~/.bashrc

# Optional: start background services here
# e.g. mlflow ui, jupyter lab, ...
```

Ausführbar machen (auf dem Host **vor** dem ersten Build):

```bash
chmod +x .devcontainer/setup_startup.sh
```

---

## 6. Python-Pakete im Container

`requirements.txt` ins Repo committen, im `postCreateCommand` installieren (siehe Abschnitt 4). Beispiel für ein typisches ML-Projekt:

```
# Core
numpy
pandas
scikit-learn

# Deep Learning
torch
transformers
datasets

# Notebooks & Plotting
jupyter
matplotlib
seaborn

# Dev Tools
ruff
pytest
```

> **Tipp:** Versionen pinnen für Reproduzierbarkeit (`torch==2.4.0`). Für noch strengere Reproduzierbarkeit `pip-tools` oder `uv` verwenden, um `requirements.lock` zu generieren.

Nachträglich Pakete im laufenden Container installieren:

```bash
pip install <package> --no-cache-dir
```

Damit das nicht beim nächsten Rebuild verloren geht, anschließend `requirements.txt` aktualisieren und committen.

---

## 7. GUI-Anwendungen (X11-Forwarding)

Wenn du grafische Anwendungen aus dem Container heraus starten willst (z. B. `matplotlib`-Fenster, GUI-Tools, RViz), brauchst du X11-Forwarding. Das Setup hängt vom Host-OS ab:

### Linux-Host

Funktioniert mit der Compose-Konfiguration aus Abschnitt 3 (X11-Socket-Mount + `DISPLAY`). Ein einmaliger `xhost +local:docker` auf dem Host (siehe `setup_startup.sh`) gibt die Display-Berechtigung frei.

### macOS-Host

Native X11-Socket-Weiterleitung gibt es nicht. Workaround: **XQuartz** installieren, „Allow connections from network clients" aktivieren, Docker mit `DISPLAY=host.docker.internal:0` starten. Aufwendig — für gelegentliche Plots eher in einem Notebook arbeiten.

### Windows-Host

- **WSL2 + WSLg:** WSLg liefert X11/Wayland direkt. Dev Container im WSL2-Filesystem öffnen, dann funktionieren GUI-Apps oft ohne Zusatzkonfiguration.
- **Ohne WSL2:** X-Server wie **VcXsrv** oder **X410** installieren, `DISPLAY=host.docker.internal:0` setzen.

> **Pragmatischer Hinweis:** Wenn GUI-Forwarding nur für Plots gebraucht wird, ist Jupyter im Browser fast immer der einfachere Weg — kein X11-Stress, plattformübergreifend.

---

## 8. Datei-Berechtigungen (Root-Problem)

**Symptom:** Dateien, die der Container erstellt, gehören auf dem Host `root` und lassen sich nicht ohne `sudo` löschen / editieren.

**Ursache:** Der Container läuft per Default als Root. Da das Workspace per Bind-Mount ins Hostsystem gespiegelt ist, landen alle Schreiboperationen mit User-ID `0` auf der Festplatte.

### Lösung 1 (sauber, empfohlen): Non-Root-User mit Host-UID

Im Dockerfile einen User mit der gleichen UID wie der Host-User anlegen — das macht das Beispiel in Abschnitt 2 mit `USER_UID=1000` / `USER_GID=1000` und `USER dev`. In `devcontainer.json` mit `"remoteUser": "dev"` aktivieren.

Die Host-UID ermittelst du mit:

```bash
id -u    # UID
id -g    # GID
```

Falls dein Host-User nicht UID 1000 hat, die Werte in `docker-compose.yml` (`args`) und ggf. im Dockerfile anpassen.

### Lösung 2 (nachträglich): Berechtigungen auf dem Host korrigieren

```bash
sudo chown -R $USER:$USER /pfad/zum/projekt/
```

Funktioniert, ist aber Symptombehandlung — bei jedem Container-Schreibvorgang entstehen wieder Root-Files.

---

## 9. Workflow

1. Repository klonen, in den Projektordner wechseln
2. VS Code öffnen → `F1` → **Dev Containers: Reopen in Container**
3. Erstes Mal: VS Code baut das Image, startet den Container, führt `postCreateCommand` aus (Pip-Install)
4. Container läuft, virtuelle Umgebung ist aktiv, Extensions sind installiert
5. Code editieren — Änderungen sind dank Bind-Mount sofort im Container sichtbar
6. Bei Bedarf: weitere Pakete via `pip install ...` im Container-Terminal, anschließend `requirements.txt` aktualisieren
7. Container beenden: VS-Code-Fenster schließen oder `F1` → **Dev Containers: Reopen Folder Locally**

Container-Image neu bauen (z. B. nach Dockerfile-Änderung):
`F1` → **Dev Containers: Rebuild Container**

Komplett von vorn (auch Caches weg):
`F1` → **Dev Containers: Rebuild Without Cache and Reopen in Container**

---

## 10. Troubleshooting

### `postCreateCommand` schlägt fehl, Container startet trotzdem

VS Code ignoriert Fehler im Lifecycle-Skript. Logs anschauen:
`F1` → **Dev Containers: Show Container Log**

### Pip findet die GPU nicht (`torch.cuda.is_available() == False`)

- Auf dem **Host** prüfen: `docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi`
- Wenn das geht, in der Compose-Datei den `deploy.resources`-Block kontrollieren (siehe Abschnitt 3)
- PyTorch passend zur installierten CUDA-Version installieren — siehe [pytorch.org/get-started](https://pytorch.org/get-started/locally/)

### Dateien im Container sind nach Rebuild plötzlich Root

Du arbeitest noch ohne Non-Root-User. Lösung 1 aus Abschnitt 8 umsetzen.

### Virtualenv ist nach Rebuild leer

Du nutzt einen Bind-Mount für `.venv`, der jedes Mal vom leeren Host-Ordner überschrieben wird. Stattdessen ein **Named Volume** (`venv-data:/workspace/.venv` wie in Abschnitt 3) verwenden.

### Port-Forwarding zeigt Port nicht an

`forwardPorts` in der `devcontainer.json` ergänzen, Container reattachen. Alternativ: VS-Code-Status-Bar → **Ports**-Tab → manuell hinzufügen.

### `xhost: command not found` im Container

`x11-xserver-utils` im Dockerfile mit installieren — oder einfach `xhost +local:docker` **auf dem Host** ausführen, nicht im Container.

### Image-Build dauert ewig / wird ständig neu gebaut

Layer-Reihenfolge prüfen — wenn `COPY . .` vor `pip install` steht, invalidiert jede Code-Änderung den Pip-Cache. Stattdessen erst nur `requirements.txt` kopieren, installieren, dann `COPY . .`.

### Auf Remote-Server: `Cannot connect to the Docker daemon`

Dein User ist nicht in der `docker`-Gruppe. Siehe *Setup_Docker_Remote_VSCode.md*, Abschnitt 3.

---

## Anhang: Cheatsheet

| Aufgabe | Befehl / Aktion |
|---|---|
| Dev Container öffnen | `F1` → `Dev Containers: Reopen in Container` |
| Dev Container neu bauen | `F1` → `Dev Containers: Rebuild Container` |
| Komplett neu bauen (ohne Cache) | `F1` → `Dev Containers: Rebuild Without Cache...` |
| Container-Logs ansehen | `F1` → `Dev Containers: Show Container Log` |
| Lokal weiterarbeiten | `F1` → `Dev Containers: Reopen Folder Locally` |
| Image manuell bauen | `docker compose build` |
| Container manuell starten | `docker compose up -d` |
| In laufenden Container shellen | `docker compose exec dev bash` |
| Container stoppen | `docker compose down` |
| Container + Volumes löschen | `docker compose down -v` |
| GPU-Zugriff testen | `docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi` |
| Host-UID/GID ermitteln | `id -u` / `id -g` |
| Berechtigungen reparieren | `sudo chown -R $USER:$USER ./` |
