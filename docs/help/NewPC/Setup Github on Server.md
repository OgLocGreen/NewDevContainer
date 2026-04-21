## 1. Voraussetzungen

- SSH-Zugriff auf den Server
- Git installiert (`git`-Befehl sollte verfügbar sein)
- Zugriff auf ein GitHub-Konto

---

## 2. SSH-Schlüssel erstellen

Falls noch kein SSH-Schlüssel existiert, erstellen Sie einen neuen:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

- Wenn `ed25519` nicht unterstützt wird, verwenden Sie `rsa`:

  ```bash
  ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
  ```

- Folgen Sie den Anweisungen. Speichern Sie den Schlüssel unter `~/.ssh/id_ed25519` (Standard).
- **Passphrase setzen:** Empfohlen für Sicherheit.

---

## 3. SSH-Agent einrichten

Starten und konfigurieren Sie den SSH-Agenten:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

---

## 4. SSH-Schlüssel zu GitHub hinzufügen

1. Öffnen Sie den öffentlichen Schlüssel:

   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

2. Kopieren Sie den gesamten Inhalt.
3. Gehen Sie zu [GitHub SSH Settings](https://github.com/settings/keys).
4. Klicken Sie auf **New SSH Key**:
   - **Title:** z. B. `Server Key`
   - **Key:** Fügen Sie den kopierten Schlüssel ein.
5. Speichern Sie mit **Add SSH Key**.

---

## 5. Git konfigurieren

Richten Sie Ihre Git-Identität ein:

```bash
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"
```

```bash
git config --global user.name "Chris"
git config --global user.email "oglocgreen@protonmail.com"
```

(Optional) Zeilenende-Konvertierung anpassen (für plattformübergreifende Projekte):

```bash
git config --global core.autocrlf input
```

---

## 6. Verbindung testen

Prüfen Sie die SSH-Verbindung zu GitHub:

```bash
ssh -T git@github.com
```

Erwartete Antwort:

```
Hi your_username! You've successfully authenticated, but GitHub does not provide shell access.
```

---

## 7. Repository klonen oder initialisieren

### Klonen eines bestehenden Repositories

```bash
git clone git@github.com:username/repository.git
```

### Neues Repository initialisieren

1. Wechseln Sie in das gewünschte Verzeichnis:

   ```bash
   cd /path/to/your/project
   ```

2. Initialisieren Sie Git:

   ```bash
   git init
   ```

3. Fügen Sie die Remote-URL hinzu:

   ```bash
   git remote add origin git@github.com:username/repository.git
   ```

4. Erstellen Sie eine erste Commit-Nachricht und pushen Sie:

   ```bash
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git push -u origin main
   ```

---

## 8. Zusätzliche Einstellungen

### Globale .gitignore

Erstellen Sie eine globale `.gitignore`:

```bash
echo ".DS_Store
*.log
node_modules/" >> ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
```

### Credential Caching (optional)

Um HTTP-Passwortabfragen zu vermeiden (falls HTTPS verwendet wird):

```bash
git config --global credential.helper cache
```

---

## 9. Fehlerbehebung

### "Permission denied (publickey)"

- Prüfen Sie, ob der richtige Schlüssel geladen ist:

  ```bash
  ssh-add -l
  ```

- Falls leer, fügen Sie den Schlüssel erneut hinzu:

  ```bash
  ssh-add ~/.ssh/id_ed25519
  ```

### SSH-Debugging

```bash
ssh -vT git@github.com
```
