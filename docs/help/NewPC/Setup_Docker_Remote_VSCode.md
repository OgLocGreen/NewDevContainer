# Docker auf einer Remote-Maschine mit VS Code

Diese Anleitung erklärt, wie du Docker auf einer Remote-Maschine (z. B. Hochschul-GPU-Server, Heimserver) einrichtest und dich von deinem Laptop aus mit **VS Code** darauf einloggst — entweder so, dass der gesamte Workspace remote läuft (Variante A), oder so, dass nur der Container remote läuft und du lokal arbeitest (Variante B).

**Reihenfolge:**

1. Voraussetzungen
2. SSH-Verbindung zur Remote-Maschine
3. Docker auf der Remote-Maschine vorbereiten
4. VS Code mit der Remote-Maschine verbinden (Variante A & B)
5. Devcontainer auf der Remote-Maschine starten
6. Volumes und Port-Forwarding
7. Code-Synchronisation lokal ↔ remote (optional)
8. Sicherheit
9. Troubleshooting

---

## 1. Voraussetzungen

### Auf deinem Laptop

- **VS Code** mit Extension **Remote - SSH** (`ms-vscode-remote.remote-ssh`)
- Optional für Variante A: **Dev Containers** (`ms-vscode-remote.remote-containers`)
- SSH-Schlüssel eingerichtet — siehe begleitende Anleitung *Setup_Git_SSH_MultiRemote.md*

### Auf der Remote-Maschine

- SSH-Server läuft und ist erreichbar
- Docker Engine + Docker Compose installiert (siehe Abschnitt 3)
- Dein Benutzer ist Mitglied der `docker`-Gruppe (siehe Abschnitt 3)
- VS Code Server wird automatisch installiert, sobald du dich erstmals mit Remote-SSH verbindest

---

## 2. SSH-Verbindung zur Remote-Maschine

Falls noch kein SSH-Key existiert oder die `~/.ssh/config` noch leer ist, der ausführlichen Anleitung in *Setup_Git_SSH_MultiRemote.md* folgen.

Kurzfassung — Eintrag in `~/.ssh/config` (lokal):

```ssh-config
Host remote-server
    HostName <REMOTE_IP_OR_HOSTNAME>
    User <REMOTE_USERNAME>
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

`ForwardAgent yes` ist wichtig, falls du später auf der Remote-Maschine `git push` zu GitHub/GitLab machen willst, ohne dort einen eigenen Key zu hinterlegen.

Verbindung testen:

```bash
ssh remote-server
```

---

## 3. Docker auf der Remote-Maschine vorbereiten

### Docker installieren

Offizielles Convenience-Skript (Linux):

```bash
curl -fsSL https://get.docker.com | sh
```

Oder distributionsspezifisch nach Anleitung auf [docs.docker.com/engine/install](https://docs.docker.com/engine/install/).

### Eigenen Benutzer in die `docker`-Gruppe aufnehmen

So musst du nicht jedes Docker-Kommando mit `sudo` ausführen — wichtig, damit auch VS Code Docker ohne Root-Rechte ansprechen kann.

```bash
sudo usermod -aG docker $USER
# Neu einloggen, damit die Gruppen-Mitgliedschaft greift
exit
ssh remote-server
```

Verifizieren:

```bash
docker run --rm hello-world
```

> **Sicherheitshinweis:** Mitglieder der `docker`-Gruppe haben effektiv Root-Rechte auf dem System. Auf Mehrbenutzer-Servern entsprechend vorsichtig sein.

### Docker Compose

Bei aktuellen Docker-Installationen ist Compose als Plugin enthalten:

```bash
docker compose version
```

Falls nicht: Installation siehe [docs.docker.com/compose/install](https://docs.docker.com/compose/install/).

---

## 4. VS Code mit der Remote-Maschine verbinden

Es gibt zwei sinnvolle Setups. Für die meisten Anwendungsfälle ist **Variante A** die einfachste.

### Variante A — Workspace UND Container auf der Remote-Maschine

Code liegt remote, Container läuft remote, VS Code verbindet sich per SSH und hängt sich anschließend in den Container.

**Schritte:**

1. In VS Code: `F1` → **Remote-SSH: Connect to Host...** → `remote-server`
2. Neues VS-Code-Fenster öffnet sich, ist mit der Remote-Maschine verbunden
3. **File → Open Folder** → Pfad zum Projekt auf der Remote-Maschine
4. Wenn das Projekt eine `.devcontainer/devcontainer.json` enthält:
   `F1` → **Dev Containers: Reopen in Container**

VS Code baut den Container auf der Remote-Maschine, mountet den remote liegenden Code und hängt sich rein. Du arbeitest mit voller IntelliSense, Debugging etc. — alles läuft auf dem Remote-Server.

### Variante B — Workspace lokal, Container auf der Remote-Maschine

Code liegt auf deinem Laptop, der Container läuft remote (z. B. um die GPU des Servers zu nutzen, ohne den Code dort hinzulegen). Funktioniert über **Docker Contexts**.

**Schritte:**

1. Auf deinem Laptop einen Docker-Context anlegen, der auf den Remote-Server zeigt:

   ```bash
   docker context create remote-server \
       --docker "host=ssh://remote-server"
   ```

2. Context aktivieren:

   ```bash
   docker context use remote-server
   ```

   Ab jetzt zeigen alle lokalen `docker`/`docker compose`-Kommandos auf den Remote-Server.

3. In VS Code: `F1` → **Dev Containers: Reopen in Container** auf einem lokal geöffneten Projekt.

   Der Container wird auf dem Remote-Server gebaut. VS Code mountet das Workspace-Verzeichnis automatisch ins Container-Volume.

Zurück zu lokalem Docker:

```bash
docker context use default
```

---

## 5. Devcontainer-Konfiguration

Beispiel `.devcontainer/devcontainer.json`:

```json
{
  "name": "Project Dev Container",
  "dockerComposeFile": "../docker-compose.yml",
  "service": "dev",
  "workspaceFolder": "/workspace",
  "remoteEnv": {
    "DISPLAY": "${localEnv:DISPLAY}"
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-azuretools.vscode-docker"
      ]
    }
  }
}
```

Wichtige Felder:

| Feld | Bedeutung |
|---|---|
| `dockerComposeFile` | Relativer Pfad zur `docker-compose.yml` |
| `service` | Welcher Service aus der Compose-Datei der Dev Container ist |
| `workspaceFolder` | Pfad **im Container**, in dem das Projekt liegt |
| `remoteEnv` | Env-Variablen, die in den Container durchgereicht werden (z. B. `DISPLAY` für GUI-Apps via X11) |
| `customizations.vscode.extensions` | Extensions, die im Container automatisch installiert werden |

---

## 6. Volumes und Port-Forwarding

### Volumes in `docker-compose.yml`

Auf der Remote-Maschine müssen die gemounteten Pfade auch existieren. Beispiel:

```yaml
services:
  dev:
    build: .
    volumes:
      - /home/<REMOTE_USERNAME>/projects/<projektname>:/workspace
      - /home/<REMOTE_USERNAME>/venvs/venv:/workspace/.venv
```

> **Hinweis:** Bei Variante A (Workspace remote) brauchst du dieses explizite Mount oft gar nicht — der Devcontainer-Mechanismus mountet das geöffnete Workspace-Verzeichnis automatisch.

### Ports weiterleiten

In `docker-compose.yml`:

```yaml
services:
  dev:
    ports:
      - "3000:3000"
      - "8888:8888"
```

VS Code Remote-SSH erkennt diese Ports automatisch und tunnelt sie auf deinen Laptop weiter. Du kannst dann lokal im Browser `http://localhost:3000` öffnen, obwohl der Service remote läuft.

Manuelles Forwarding bei Bedarf:

```bash
ssh -L 3000:localhost:3000 remote-server
```

---

## 7. Code-Synchronisation lokal ↔ remote (optional)

Wenn du in Variante A arbeitest, der Code aber zusätzlich lokal liegen soll (z. B. für Backups oder lokale IDE-Suche), funktioniert `rsync` zuverlässig:

```bash
# Lokal → Remote
rsync -avz --delete ./projects/<projektname>/ remote-server:/home/<REMOTE_USERNAME>/projects/<projektname>/

# Remote → Lokal
rsync -avz --delete remote-server:/home/<REMOTE_USERNAME>/projects/<projektname>/ ./projects/<projektname>/
```

Wichtige Flags:

| Flag | Bedeutung |
|---|---|
| `-a` | Archive-Modus (rekursiv, behält Metadaten) |
| `-v` | Verbose |
| `-z` | Komprimiert während Übertragung |
| `--delete` | Löscht im Ziel, was in der Quelle fehlt — **vorsichtig nutzen** |
| `--exclude='.venv/'` | Bestimmte Pfade ausschließen |

> **Achtung:** `--delete` kann Daten löschen. Bei Unsicherheit erst mit `--dry-run` testen.

In den meisten Fällen ist Git der bessere Sync-Mechanismus zwischen lokal und remote. `rsync` ist sinnvoll für große Datensätze, Modell-Checkpoints oder Dateien, die nicht ins Repo gehören.

---

## 8. Sicherheit

| Bereich | Empfehlung |
|---|---|
| SSH-Auth | Ausschließlich Public-Key, kein Passwort. In `/etc/ssh/sshd_config`: `PasswordAuthentication no` |
| SSH-Port | Standard-Port 22 lassen ist okay, kombiniert mit Fail2ban. Port wechseln verhindert nur Logspam, keinen ernsten Angriff |
| Firewall | Nur benötigte Ports nach außen öffnen (mind. 22 für SSH). Anwendungs-Ports nur via SSH-Tunnel zugänglich machen, nicht öffentlich |
| Docker-Gruppe | Mitgliedschaft = Root-Äquivalent. Nur Trusted Users hinzufügen |
| Container-User | Im Dockerfile `USER` setzen statt als Root laufen lassen |
| Secrets | Nicht ins Image bauen, nicht in `docker-compose.yml` committen. Über `.env` (in `.gitignore`) oder Docker Secrets |
| Updates | `sudo apt update && sudo apt upgrade` regelmäßig, Docker-Images per `docker compose pull` aktualisieren |

---

## 9. Troubleshooting

### `Cannot connect to the Docker daemon`

Dein Benutzer ist nicht in der `docker`-Gruppe oder die Gruppen-Mitgliedschaft greift in der aktuellen Session noch nicht.

```bash
groups          # 'docker' muss in der Liste stehen
# Falls nicht
sudo usermod -aG docker $USER
exit && ssh remote-server   # neu einloggen
```

### VS Code: `Failed to connect to the remote extension host server`

Meist ein veralteter VS Code Server auf der Remote-Maschine. Killen und beim nächsten Connect neu installieren lassen:

```bash
# Auf der Remote-Maschine
rm -rf ~/.vscode-server
```

### Dev Container baut, aber Volume ist leer

Pfad in `docker-compose.yml` zeigt auf einen nicht existierenden Ordner auf der Remote-Maschine. Docker erstellt diesen dann als leeres Verzeichnis (mit Root-Rechten — schwer zu löschen).

```bash
# Auf der Remote-Maschine prüfen
ls -la /home/<REMOTE_USERNAME>/projects/
```

### Port-Forwarding aus VS Code funktioniert nicht

In der Status-Bar unten auf den **Ports**-Tab klicken und manuell hinzufügen. Alternative: SSH-Tunnel von Hand (`ssh -L`).

### Docker Context: `error during connect: ... ssh: handshake failed`

Der Context kann den Server per SSH nicht erreichen. Erst klassisch testen:

```bash
ssh remote-server docker version
```

Wenn das funktioniert, aber `docker context use remote-server` scheitert, prüfen, ob der Context korrekt angelegt wurde:

```bash
docker context inspect remote-server
```

### GPU im Container nicht sichtbar

Auf der Remote-Maschine **NVIDIA Container Toolkit** installieren ([docs](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)) und in der Compose-Datei:

```yaml
services:
  dev:
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
```

Im Container testen:

```bash
nvidia-smi
```

---

## Anhang: Cheatsheet

| Aufgabe | Befehl |
|---|---|
| SSH zur Remote-Maschine | `ssh remote-server` |
| Docker-Context anlegen | `docker context create remote-server --docker "host=ssh://remote-server"` |
| Docker-Context wechseln | `docker context use remote-server` / `docker context use default` |
| Aktiven Context anzeigen | `docker context show` |
| Container auf Remote bauen | `docker compose build` (mit aktivem Remote-Context) |
| VS Code: Remote verbinden | `F1` → `Remote-SSH: Connect to Host...` |
| VS Code: in Container öffnen | `F1` → `Dev Containers: Reopen in Container` |
| Lokal → Remote sync | `rsync -avz ./project/ remote-server:/path/to/project/` |
| Port manuell tunneln | `ssh -L 3000:localhost:3000 remote-server` |
| VS Code Server zurücksetzen | `rm -rf ~/.vscode-server` (auf Remote) |
