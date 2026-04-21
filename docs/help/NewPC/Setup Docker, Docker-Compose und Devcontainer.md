#  Zusammenfassung
 

Diese Dokumentation erklärt, wie dein **Docker-Setup**, einschließlich **Dockerfile**, **docker-compose.yml** und **devcontainer.json**, zusammenarbeitet, um eine Entwicklungsumgebung in VS Code zu erstellen. Sie dient als Leitfaden, falls du nach längerer Zeit die Struktur wieder verstehen möchtest.

  

---

  

## 1. Übersicht der Dateien

1. **Dockerfile**
- Definiert, wie das Basis-Image gebaut wird.
- Hier werden Abhängigkeiten und Systemkonfigurationen für die Entwicklungsumgebung festgelegt.

2. **docker-compose.yml**
- Organisiert die Container und deren Interaktionen.
- Erleichtert die Verwaltung von Volumes, Ports, GPU-Ressourcen und Umgebungsvariablen.

3. **devcontainer.json**
- Bindeglied zwischen Docker und VS Code.
- Gibt VS Code Anweisungen, welchen Service zu starten, welche Erweiterungen zu laden und welche Ports weitergeleitet werden sollen.

  

---

  

## 2. Datei-spezifische Erklärungen

  

### Dockerfile

- Der Dockerfile war in deiner Konfiguration nicht direkt spezifiziert, wird aber benötigt, falls du spezifische Software oder Libraries für dein Projekt installieren möchtest.

- Falls später Änderungen nötig sind, kannst du z. B. CUDA-Versionen oder Python-Pakete hier definieren.

  

### docker-compose.yml

Wichtigste Punkte aus der Datei:

  

```yaml

volumes:

- /home/chris/Desktop/oglocgreenspace/:/app/oglocgreenspace

- /home/chris/Desktop/venvs/venv/:/app/oglocgreenspace/.venv/

- /var/run/docker.sock:/var/run/docker.sock

- /tmp/.X11-unix:/tmp/.X11-unix

```

- **Mounten von Volumes**:

- **Code-Ordner**: `/home/chris/Desktop/oglocgreenspace/` → `/app/oglocgreenspace` stellt sicher, dass der Projektcode im Container verfügbar ist.

- **Virtuelle Umgebung**: `/home/chris/Desktop/venvs/venv/` → `/app/oglocgreenspace/.venv/` erlaubt die Nutzung der Python-venv auf dem Hostsystem.

- **Docker-Socket**: `/var/run/docker.sock` ermöglicht die Verwendung von Docker-Befehlen innerhalb des Containers.

- **X11-Socket**: `/tmp/.X11-unix` wird verwendet, um GUI-Anwendungen im Container anzuzeigen.

  

```yaml

ports:

- "3000:3000"

- "5901:5901"

```

- **Ports**:

- **3000:3000**: Für eine Entwicklungsserver-Anwendung wie React oder Flask.

- **5901:5901**: Für VNC- oder GUI-Verbindungen.

  

```yaml

environment:

- DISPLAY=${DISPLAY}

- VIRTUAL_ENV=/app/oglocgreenspace/.venv

- PATH=/app/oglocgreenspace/.venv/bin:$PATH

```

- **Umgebungsvariablen**:

- **DISPLAY**: Leitet die Anzeige für GUI-Anwendungen auf den Hostrechner weiter.

- **VIRTUAL_ENV und PATH**: Stellen sicher, dass die virtuelle Python-Umgebung verwendet wird.

  

### devcontainer.json

- **Docker Compose-Integration**:

Der Container wird durch die `docker-compose.yml` definiert.

```json

"dockerComposeFile": "docker-compose.yml",

"service": "service_oglocgreenspace_dev_container",

```

  

- **Python-Konfiguration**:

```json

"python.defaultInterpreterPath": "/app/oglocgreenspace/.venv/bin/python"

```

Weist VS Code an, die virtuelle Umgebung als Standard-Python-Interpreter zu verwenden.

  

- **Erweiterungen**:

Die angegebenen Extensions (z. B. `ms-python.python`, `ms-toolsai.jupyter`) stellen sicher, dass Python, Jupyter und andere Tools direkt im Container verfügbar sind.

  

- **Post-Start-Kommandos**:

```json

"postStartCommand": "xhost +local:docker && /app/oglocgreenspace/.devcontainer/setup_startup.sh && source $VIRTUAL_ENV/bin/activate"

```

- `xhost +local:docker`: Erlaubt X11-Anwendungen, sich mit dem Host-Display zu verbinden.

- `setup_startup.sh`: Startet deine benutzerdefinierten Skripte im Container.

- `source $VIRTUAL_ENV/bin/activate`: Aktiviert die verlinkte virtuelle Umgebung automatisch.

  

### setup_startup.sh

Das Skript (`setup_startup.sh`) wird direkt nach dem Start des Containers ausgeführt. Es kann Befehle zur Vorbereitung der Entwicklungsumgebung enthalten, z. B. das Installieren fehlender Abhängigkeiten oder das Laden spezifischer Konfigurationen.

  

### requirements.txt

Deine Anforderungen aus `requirements.txt` beinhalten zahlreiche Python-Pakete, darunter:

- **Machine Learning**: `torch`, `transformers`, `scikit-learn`, `numpy`.

- **NVIDIA-Kompatibilität**: CUDA-Bibliotheken (`nvidia-cudnn-cu12`, `nvidia-cublas-cu12`).

- **Datenverarbeitung**: `pandas`, `datasets`.

  

---

  

## 3. Warum diese Konfiguration?

1. **Flexibilität**: Das Host-System wird nicht verändert, da die Entwicklungsumgebung isoliert im Container läuft.

2. **GPU-Unterstützung**: NVIDIA GPUs können für ML/AI-Aufgaben genutzt werden.

3. **Portabilität**: Dein gesamtes Projekt ist durch Docker leicht auf andere Maschinen übertragbar.

4. **Performance**: Durch Volumes wird sichergestellt, dass große Datenmengen oder Abhängigkeiten nicht bei jedem Start kopiert werden.

5. **GUI-Unterstützung**: X11-Weiterleitung ermöglicht das Starten von grafischen Anwendungen direkt im Container.

  

---

  

## 4. Workflow

1. Starte den Devcontainer in VS Code.

2. Deine virtuelle Umgebung wird automatisch gemountet und aktiviert.

3. Nutze die GUI, falls nötig, oder entwickle in der Terminal-Shell.

4. Bei Bedarf installierst du neue Abhängigkeiten mit:

```bash

python -m pip install <package> --no-cache-dir

```

# 5. Base System
1. Dateien und Ordner welche innerhalb des Containers erstellt werden sind nun vom Root besitzer

2. Zum Bearbeiten auf dem localem System muss davor die Rechte übertragen werden:

```bash
chown -R [Benutzer]:[Gruppe] [Datei/Verzeichnis]

chown -R chris:users /oglocgreenspace/

```

