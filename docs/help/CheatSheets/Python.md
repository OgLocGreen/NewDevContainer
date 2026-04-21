## Virtuelle Umgebung (venv)
### Erstellen
```bash
python -m venv env
```  
### Aktivieren
- **Windows**
```bash
env\Scripts\activate
```
- **Linux/macOS**
```bash
source env/bin/activate
```
### Deaktivieren
```bash
deactivate
```
---
## pip & Pakete aktualisieren
### pip selbst updaten
```bash
python -m pip install --upgrade pip
```
### setuptools (Beispiel)
```bash
pip install --upgrade setuptools
```
---
## Requirements-Datei
### Liste erstellen
```bash
pip freeze > requirements.txt
```
### Liste installieren
```bash
pip install -r requirements.txt
```
---
## EXE-Datei erstellen mit PyInstaller
### Installation
```bash
pip install pyinstaller
```
### Einfache EXE (einzelne Datei)
```bash
pyinstaller --onefile dein_script.py
```
### Ohne Konsolenfenster (z.B. für GUI-Apps)
```bash
pyinstaller --onefile --noconsole dein_script.py
```
  
> Die `.exe` findest du im `dist/`-Ordner.

## Zwei inkompatible Python Libraries verwenden (z. B. PyTorch 1 & 2)
### 1. Microservice-Trennung mit Docker (empfohlen für Produktivbetrieb)
#### Beispiel: Docker Compose Setup
**Verzeichnisstruktur**
```
project-root/
├── model1/
│ └── Dockerfile
├── model2/
│ └── Dockerfile
└── docker-compose.yml
```  
**docker-compose.yml**
```yaml
services:
model1:
build: ./model1
volumes:
- ./model1:/app
model2:
build: ./model2
volumes:
- ./model2:/app
```
**model1/Dockerfile**
```Dockerfile
FROM python:3.10
WORKDIR /app
COPY . .
RUN pip install torch==1.13
CMD ["python", "run_model1.py"]
```
**model2/Dockerfile**
```Dockerfile
FROM python:3.10
WORKDIR /app
COPY . .
RUN pip install torch==2.1
CMD ["python", "run_model2.py"]
```
---
### 2. Isolation über Subprozess und venv (empfohlen für easy Use)
#### venv vorbereiten
```bash
python -m venv venv_model2
source venv_model2/bin/activate
pip install torch==2.1
```
#### Subprozess in Python starten
```python
import subprocess  
subprocess.run(["venv_model2/bin/python", "run_model2.py"])
```

> So kannst du zwei inkompatible Modelle getrennt laufen lassen, ohne Konflikte.