# Git & SSH Setup — komplette Anleitung

Diese Anleitung führt von einem leeren System bis zu einem voll funktionsfähigen Git-Workflow mit SSH-Authentifizierung und parallelem Push zu **GitHub und GitLab**. Funktioniert auf **Linux**, **macOS**, **WSL (Ubuntu)** und **Windows (nativ, PowerShell)**.

**Reihenfolge:**

1. SSH-Schlüssel erstellen
2. Public Key auf Server / GitHub / GitLab eintragen
3. SSH-Config mit Aliasen einrichten
4. Git installieren und konfigurieren
5. Repository klonen oder initialisieren
6. Multi-Remote: parallel zu GitHub und GitLab pushen
7. Troubleshooting

---

## 1. SSH-Schlüssel erstellen

Ein SSH-Schlüsselpaar besteht aus einem **privaten Schlüssel** (bleibt auf deinem Rechner) und einem **öffentlichen Schlüssel** (kommt auf den Server / zu GitHub / zu GitLab).

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Falls `ed25519` nicht unterstützt wird (sehr alte Systeme), RSA verwenden:

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

Beim Ausführen wirst du gefragt:

| Frage | Empfehlung |
|---|---|
| Speicherort | Enter (Default: `~/.ssh/id_ed25519`) |
| Passphrase | Setzen — schützt den Key, falls jemand deinen Rechner kompromittiert |

Ergebnis:

- `~/.ssh/id_ed25519` — privater Schlüssel (**niemals teilen**)
- `~/.ssh/id_ed25519.pub` — öffentlicher Schlüssel

### SSH-Agent starten

Damit du die Passphrase nicht bei jedem Verbindungsaufbau eingeben musst:

**Linux / macOS / WSL:**

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

**Windows (PowerShell, als Admin):**

```powershell
# SSH-Agent-Dienst aktivieren (einmalig)
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent

# Key hinzufügen
ssh-add $env:USERPROFILE\.ssh\id_ed25519
```

---

## 2. Public Key auf Server / GitHub / GitLab eintragen

### 2.1 Eigener Server (z. B. Uni-Server, Heimserver)

**Option A — automatisch mit `ssh-copy-id`** (Linux / macOS / WSL):

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub username@hostname
```

**Option B — manuell** (auch unter Windows):

```bash
# Public Key anzeigen und kopieren
cat ~/.ssh/id_ed25519.pub
```

Auf dem Server einloggen und einfügen:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/authorized_keys
# Public Key hineinkopieren, speichern
chmod 600 ~/.ssh/authorized_keys
```

### 2.2 GitHub

1. Public Key kopieren:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
2. [GitHub SSH Settings](https://github.com/settings/keys) öffnen
3. **New SSH Key** → Title z. B. `Mein Laptop`, Key einfügen → **Add SSH Key**

Verbindung testen:

```bash
ssh -T git@github.com
```

Erwartete Antwort:

```
Hi <username>! You've successfully authenticated, but GitHub does not provide shell access.
```

### 2.3 GitLab

1. Public Key kopieren (siehe oben)
2. GitLab → **Preferences → SSH Keys** öffnen
   (z. B. `https://<gitlab-host>/-/user_settings/ssh_keys`)
3. Title vergeben, Key einfügen, **Add key**

Verbindung testen:

```bash
ssh -T git@<gitlab-host>
```

---

## 3. SSH-Config: Aliase einrichten

Mit der Datei `~/.ssh/config` kannst du Verbindungsprofile mit kurzen Namen anlegen — statt `ssh -i ~/.ssh/id_ed25519 -p 22 username@192.168.1.42` reicht dann `ssh spark`.

### Pfad zur Config-Datei

| System | Pfad |
|---|---|
| Linux / macOS / WSL | `~/.ssh/config` |
| Windows (nativ) | `C:\Users\<Benutzername>\.ssh\config` |

> **Wichtig:** Windows und WSL haben **getrennte** SSH-Umgebungen. Aliase in WSL gelten nicht in PowerShell und umgekehrt.

### Datei erstellen / öffnen

**Linux / macOS / WSL:**

```bash
mkdir -p ~/.ssh
nano ~/.ssh/config
```

**Windows (PowerShell):**

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.ssh"
notepad "$env:USERPROFILE\.ssh\config"
```

### Beispiel-Config

```ssh-config
# Eigener Server
Host spark
    HostName 192.168.1.42
    User username
    IdentityFile ~/.ssh/id_ed25519
    Port 22

# GPU-Server mit Agent-Forwarding für Git-Operationen
Host gpu-server
    HostName 10.0.0.5
    User username
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes
    ServerAliveInterval 60
    ServerAliveCountMax 3

# Hochschul-Server
Host uni
    HostName ssh.hochschule.example.de
    User student
    IdentityFile ~/.ssh/id_ed25519
```

### Bedeutung der Felder

| Feld | Bedeutung |
|---|---|
| `Host` | Alias — was du tippst |
| `HostName` | Echte IP oder Domain |
| `User` | Benutzername auf dem Zielsystem |
| `IdentityFile` | Pfad zum privaten Key |
| `Port` | SSH-Port (Default 22, kann weggelassen werden) |
| `ForwardAgent yes` | Lokale SSH-Keys auf dem Server nutzbar (z. B. für `git push` von dort) |
| `ServerAliveInterval` | Keep-Alive in Sekunden — verhindert Verbindungsabbrüche |

### Berechtigungen setzen

OpenSSH ignoriert die Config-Datei kommentarlos, wenn die Berechtigungen zu offen sind.

**Linux / macOS / WSL:**

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

**Windows (nur falls SSH `Bad permissions` meldet):**

```powershell
$configPath = "$env:USERPROFILE\.ssh\config"
icacls $configPath /inheritance:r /grant:r "${env:USERNAME}:(R,W)"
```

### Testen

```bash
ssh spark
```

> **Windows-Hinweis:** Falls `~` im `IdentityFile`-Pfad nicht aufgelöst wird, vollständigen Pfad eintragen: `IdentityFile C:\Users\<benutzername>\.ssh\id_ed25519`

---

## 4. Git installieren und konfigurieren

Globale Identität setzen:

```bash
git config --global user.name "Vorname Nachname"
git config --global user.email "your.name@example.com"
```

Optional — Zeilenende-Konvertierung für plattformübergreifende Projekte:

```bash
# Linux / macOS / WSL
git config --global core.autocrlf input

# Windows
git config --global core.autocrlf true
```

Globale `.gitignore` (greift in allen Repos):

```bash
# Datei anlegen
cat > ~/.gitignore_global <<EOF
.DS_Store
*.log
node_modules/
.vscode/
.idea/
EOF

# In Git registrieren
git config --global core.excludesfile ~/.gitignore_global
```

---

## 5. Repository klonen oder initialisieren

### Bestehendes Repo klonen

```bash
git clone git@github.com:username/repository.git
```

### Neues Repo initialisieren

```bash
cd /pfad/zum/projekt
git init
git remote add origin git@github.com:username/repository.git

git add .
git commit -m "Initial commit"
git branch -M main
git push -u origin main
```

---

## 6. Multi-Remote: parallel zu GitHub und GitLab pushen

**Anwendungsfall:** Code soll gleichzeitig auf GitHub (öffentlich/privat) und auf einem zweiten GitLab (z. B. Hochschul-GitLab) liegen. GitHub bleibt **Source of Truth** (von dort wird gepullt), GitLab ist **Mirror**.

### 6.1 Bestehende Remotes prüfen

```bash
git remote -v
```

### 6.2 Zweiten Remote (GitLab) hinzufügen

```bash
git remote add gitlab https://<gitlab-host>/<gruppe>/<projekt>.git
```

Damit hast du jetzt:

- `origin` → GitHub (fetch + push)
- `gitlab` → GitLab (fetch + push)

Manuelle zwei Pushes wären jetzt:

```bash
git push origin main
git push gitlab main
```

### 6.3 Komfort: ein einziger Push zu beiden

Dafür legst du einen virtuellen Remote namens `all` an. Er hat **eine Fetch-URL** (technisch von Git vorgegeben — egal welche, da wir nicht von ihm fetchen) und **mehrere Push-URLs**.

```bash
# Remote 'all' anlegen mit GitHub als Basis-URL
git remote add all git@github.com:<dein-github-user>/<repo>.git

# Push-URLs hinzufügen — für JEDES Ziel einzeln
git remote set-url --add --push all git@github.com:<dein-github-user>/<repo>.git
git remote set-url --add --push all https://<gitlab-host>/<gruppe>/<projekt>.git
```

> **Wichtig:** Sobald du `--add --push` benutzt, **ersetzt** das die Default-Push-URL. Deshalb muss GitHub als Push-URL **explizit nochmal** eingetragen werden, sonst wird nur zu GitLab gepusht.

### 6.4 Verhindern, dass `all` doppelt fetcht

`git fetch --all` würde sonst auch von `all` fetchen (und damit GitHub doppelt holen). Abschalten mit:

```bash
git config remote.all.skipFetchAll true
```

### 6.5 Verifizieren

```bash
git remote -v
```

Erwartetes Ergebnis:

```
all     git@github.com:<dein-github-user>/<repo>.git (fetch)
all     git@github.com:<dein-github-user>/<repo>.git (push)
all     https://<gitlab-host>/<gruppe>/<projekt>.git (push)
gitlab  https://<gitlab-host>/<gruppe>/<projekt>.git (fetch)
gitlab  https://<gitlab-host>/<gruppe>/<projekt>.git (push)
origin  git@github.com:<dein-github-user>/<repo>.git (fetch)
origin  git@github.com:<dein-github-user>/<repo>.git (push)
```

### 6.6 Täglicher Workflow

```bash
# Aktuellen Stand von GitHub holen (Source of Truth)
git pull origin main

# ... arbeiten, committen ...

# In einem Schwung zu GitHub UND GitLab pushen
git push all main
```

Falls du explizit beide Remotes fetchen willst:

```bash
git fetch --all   # holt von 'origin' und 'gitlab' (nicht von 'all', da skipFetchAll)
```

### 6.7 Mischung SSH + HTTPS

GitHub via SSH, GitLab via HTTPS funktioniert problemlos. Bei HTTPS jedoch:

- Personal Access Token (PAT) bei GitLab erstellen
- In Windows Credential Manager hinterlegen — sonst Passwort-Prompt bei jedem Push
- Alternative: GitLab ebenfalls auf SSH umstellen (Key bei GitLab eintragen, dann `git remote set-url gitlab git@<gitlab-host>:<gruppe>/<projekt>.git`)

---

## 7. Troubleshooting

### `Permission denied (publickey)`

Public Key ist nicht beim Ziel registriert oder falscher Key wird angeboten.

```bash
# Geladene Keys anzeigen
ssh-add -l

# Falls leer
ssh-add ~/.ssh/id_ed25519

# Verbose Output für Detail-Diagnose
ssh -vT git@github.com
```

### SSH ignoriert die Config-Datei kommentarlos

Berechtigungsproblem. Auf Linux / macOS / WSL prüfen:

```bash
ls -la ~/.ssh/config
# Erwartet: -rw------- (= 600)
```

### `Bad configuration option` beim Verbinden

Tippfehler oder Tabs statt Leerzeichen in der Config. Jede Option mit **Leerzeichen** einrücken, nicht mit Tab.

### `'github' does not appear to be a git repository`

Du versuchst zu einem Remote-Namen zu pushen, der nicht existiert. Prüfen:

```bash
git remote
```

Eventuell heißt der Remote `origin` statt `github`. Umbenennen mit:

```bash
git remote rename origin github
```

### Multi-Remote: `'gitlab' does not appear to be a git repository` beim `git push all`

Du hast in `all` versehentlich Remote-**Namen** statt URLs eingetragen. Lösung: `all` komplett neu aufbauen (siehe Abschnitt 6.3).

### Direkter Eingriff in `.git/config`

Wenn die Remote-Konfig vermurkst ist, ist der schnellste Weg, die Datei direkt zu editieren:

```bash
# Aktuelle Konfig anzeigen
cat .git/config

# Editieren
nano .git/config        # Linux/macOS/WSL
notepad .git/config     # Windows
```

Korrekte Struktur für `all`:

```ini
[remote "all"]
    url = git@github.com:<dein-github-user>/<repo>.git
    fetch = +refs/heads/*:refs/remotes/all/*
    pushurl = git@github.com:<dein-github-user>/<repo>.git
    pushurl = https://<gitlab-host>/<gruppe>/<projekt>.git
```

### Windows: `~` wird im `IdentityFile`-Pfad nicht aufgelöst

Vollständigen Pfad eintragen:

```ssh-config
IdentityFile C:\Users\<benutzername>\.ssh\id_ed25519
```

---

## Anhang: Cheatsheet

| Aufgabe | Befehl |
|---|---|
| Key erstellen | `ssh-keygen -t ed25519 -C "mail@example.com"` |
| Public Key anzeigen | `cat ~/.ssh/id_ed25519.pub` |
| Key auf Server kopieren | `ssh-copy-id -i ~/.ssh/id_ed25519.pub user@host` |
| GitHub-Verbindung testen | `ssh -T git@github.com` |
| Remotes anzeigen | `git remote -v` |
| Remote hinzufügen | `git remote add <name> <url>` |
| Push-URL hinzufügen | `git remote set-url --add --push <name> <url>` |
| Push-URL entfernen | `git remote set-url --delete --push <name> <url>` |
| Doppel-Fetch unterdrücken | `git config remote.<name>.skipFetchAll true` |
| Alle Remotes fetchen | `git fetch --all` |
| Zu beiden pushen | `git push all main` |
