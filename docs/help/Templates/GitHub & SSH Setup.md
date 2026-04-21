# GitHub & SSH Setup (Template für Studierende)

Dieses Dokument beschreibt die grundlegenden Schritte, um GitHub mit dem lokalen Rechner sowie mit einem Server (z. B. `gpu-zollner`) zu verbinden.  
Die Anleitung ist so aufgebaut, dass ihr sie **einmal von oben nach unten** durchgehen könnt.  

---

## 1. SSH-Key lokal erstellen

1. **Key erzeugen**  
   ```bash
   ssh-keygen -t ed25519 -C "dein_github_mail" -f ~/.ssh/id_ed25519
   ```
   - Bei der Abfrage nach einer *Passphrase*:  
     - **Enter drücken** → kein Passwort, immer direkt nutzbar (**einfach, aber weniger sicher**)  
     - **Passphrase vergeben** → sicherer, aber ihr müsst sie beim ersten Mal eingeben (**empfohlen**)  

---

## 2. SSH-Agent einrichten (empfohlen, wenn Passphrase vergeben)

1. **SSH-Agent starten und Key hinzufügen:**  
   ```bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ```
   → Passphrase wird **einmal pro Session** abgefragt.

2. **Automatisch laden bei Login (optional, aber praktisch):**  
   In `~/.bashrc` oder `~/.zshrc` einfügen:  
   ```bash
	eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519
   ```
3. **Public Key auf den Server kopieren:** (optional, empfohlen keine erneute Passwort abfrage)
   ```bash
 ssh-copy-id -i ~/.ssh/id_ed25519.pub user@server.example.com
   ```

---
## 3. SSH-Key bei GitHub hinterlegen

1. **Public Key anzeigen:**  
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
   → Inhalt kopieren  

2. **Bei GitHub hinzufügen:**  
   GitHub → **Settings → SSH and GPG keys → New SSH key**  

3. **Verbindung testen:**  
   ```bash
   ssh -T git@github.com
   ```
   Erwartete Ausgabe:  
   ```
   Hi <username>! You've successfully authenticated...
   ```

---

## 4. Git konfigurieren

1. **Globalen Benutzer setzen (nur einmal nötig):**  
   ```bash
   git config --global user.name  "Dein Name"
   git config --global user.email "dein_github_mail"
   ```

2. **Repo-URL auf SSH umstellen (falls noch https):**  
   ```bash
   git remote set-url origin git@github.com:<ORG>/<REPO>.git
   ```

---

## 5. SSH-Config für Serverzugang

Damit ihr nicht jedes Mal User/IP eintippen müsst, erstellt ihr eine lokale Konfig.  

1. **Datei öffnen:**  
   ```bash
   nano ~/.ssh/config
   ```

2. **Eintrag hinzufügen:**  
   ```ssh
   Host gpu-zollner
       HostName <SERVER_IP_ODER_DOMAIN>   # notwendig: IP oder Domain des Servers
       User <BENUTZERNAME>                # notwendig: euer Benutzername
       ForwardAgent yes                   # notwendig: GitHub-Keys weiterleiten

       # Optional: nur diesen Key nutzen (falls mehrere Keys existieren)
       IdentityFile ~/.ssh/id_ed25519
       IdentitiesOnly yes
   ```

3. **Testen:**  
   ```bash
   ssh gpu-zollner
   ```

---

## 6. GitHub auf dem Server nutzen

Jetzt könnt ihr direkt auf dem Server arbeiten, ohne weitere Keys ablegen zu müssen:  

```bash
ssh gpu-zollner
cd <REPO>
git pull
git push
```

Alles läuft über euren lokalen Key.  

---

## 7. Zusammenfassung

- **Ohne Passphrase:** Key sofort nutzbar, kein Passwort nötig.  
- **Mit Passphrase:** sicherer → in Kombination mit `ssh-agent` nur einmal pro Session eingeben.  
- **SSH-Config:** erspart wiederholtes Tippen von User/IP, leitet automatisch euren Key an den Server weiter.  

---