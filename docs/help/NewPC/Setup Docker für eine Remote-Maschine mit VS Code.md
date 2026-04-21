Diese Anleitung erklärt, wie du dein Docker-Setup auf einer Remote-Maschine einrichtest und dich von deinem Laptop aus mit VS Code darauf einloggst.

---

## 1. Voraussetzungen

### **Auf der Remote-Maschine:**

- **Docker und Docker Compose**: Installiere Docker und Docker Compose auf der Remote-Maschine.
- **SSH-Zugang**: Stelle sicher, dass du per SSH auf die Remote-Maschine zugreifen kannst.
- **VS Code Server**: Wird automatisch installiert, wenn du dich über VS Code verbindest.

### **Auf deinem Laptop:**

- **VS Code**: Stelle sicher, dass du die Remote-SSH-Erweiterung installiert hast.
- **SSH-Schlüssel**: Richte SSH-Schlüssel ein, um dich ohne Passwort auf der Remote-Maschine einzuloggen.

---

## 2. VS Code: Remote-SSH einrichten

### **Schritt 1: Remote-SSH installieren**

- Installiere die Extension **Remote - SSH** in VS Code.

### **Schritt 2: SSH-Konfiguration**

Bearbeite oder erstelle die Datei `~/.ssh/config` auf deinem Laptop:

```ssh
Host remote-server
HostName <REMOTE_IP_OR_HOSTNAME>
User <REMOTE_USERNAME>
IdentityFile ~/.ssh/id_rsa
ForwardAgent yes
```

Ersetze `<REMOTE_IP_OR_HOSTNAME>` und `<REMOTE_USERNAME>` entsprechend.

Teste die Verbindung:

```bash
ssh remote-server
```

---

## 3. Docker-Setup anpassen

### **Option A: Lokale Volumes anpassen**

Wenn dein Projektcode auf der Remote-Maschine liegt, musst du in der `docker-compose.yml` sicherstellen, dass die Pfade korrekt sind.

- Ersetze die lokalen Host-Pfade durch Pfade der Remote-Maschine. Zum Beispiel:

```yaml
volumes:
- /home/<REMOTE_USERNAME>/oglocgreenspace:/app/oglocgreenspace
- /home/<REMOTE_USERNAME>/venvs/venv:/app/oglocgreenspace/.venv
```

### **Option B: Docker-Ports weiterleiten**

Stelle sicher, dass alle Ports, die du brauchst (z. B. 3000 oder 5901), in der `docker-compose.yml` definiert sind:

```yaml
ports:
- "3000:3000"
- "5901:5901"
```

So kannst du später auf diese Ports zugreifen, während du mit der Remote-Maschine verbunden bist.

---

## 4. Verbindung mit VS Code

### **Schritt 1: Öffnen des Remote-Containers**

- Öffne VS Code und klicke auf das **Remote-SSH-Icon** in der linken Seitenleiste.
- Wähle die Remote-Maschine aus.

### **Schritt 2: Devcontainer auf der Remote-Maschine starten**

- Sobald du auf der Remote-Maschine bist, öffne dein Projekt.
- Starte den Devcontainer über **Command Palette > Rebuild and Reopen in Container**.

VS Code nutzt jetzt den Docker-Container auf der Remote-Maschine.

---

## 5. Zusätzliche Ansätze

### **Option A: Projekt- und Container-Quellen synchronisieren**

Falls der Code nur lokal liegt, kannst du Tools wie **rsync** verwenden, um Dateien automatisch auf die Remote-Maschine zu synchronisieren:

```bash
rsync -avz ~/Desktop/oglocgreenspace/ remote-server:/home/<REMOTE_USERNAME>/oglocgreenspace/
```

### **Option B: VS Code "Remote - Containers" Extension**

Alternativ kannst du direkt mit der **Remote - Containers**-Extension arbeiten. Dabei wird der Container auf der Remote-Maschine ausgeführt und VS Code verbindet sich direkt mit diesem Container.

- Stelle in der `devcontainer.json` sicher, dass die Verbindung mit Docker auf der Remote-Maschine korrekt eingerichtet ist:

```json
"dockerComposeFile": "/path/to/docker-compose.yml",
"service": "service_oglocgreenspace_dev_container",
"remoteEnv": {
"DISPLAY": "${env:DISPLAY}"
}
```

---

## 6. Sicherheitshinweise

1. **SSH-Sicherheit**:
    - Nutze einen SSH-Schlüssel anstelle von Passwörtern.
    - Beschränke den SSH-Zugang auf deine IP-Adresse.
2. **Firewall**:
    - Öffne nur die benötigten Ports (z. B. 22 für SSH).
3. **Docker-Nutzung**:
    - Überlege, Docker nicht direkt als Root auszuführen. Nutze stattdessen eine Docker-Gruppe.