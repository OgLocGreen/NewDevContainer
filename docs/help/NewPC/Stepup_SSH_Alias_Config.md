# SSH Alias einrichten – `ssh spark` statt `ssh user@192.168.1.42`

Diese Anleitung erklärt, wie du einen SSH-Alias einrichtest, damit du einen Server mit einem kurzen Namen ansprechen kannst.  
Sie funktioniert auf **Windows (nativ)**, **WSL (Ubuntu)** und **Linux/macOS**.

---

## Was ist eine SSH Config?

Die Datei `~/.ssh/config` ist eine persönliche Konfigurationsdatei für SSH.  
Sie speichert Verbindungsprofile mit einem selbstgewählten Namen – dem **Alias**.  
OpenSSH liest diese Datei automatisch, wenn du `ssh <Name>` eingibst.

---

## Übersicht: Wo liegt die Config-Datei?

| System | Pfad |
|--------|------|
| Linux / macOS | `~/.ssh/config` |
| WSL (Ubuntu im Windows) | `~/.ssh/config` *(im WSL-Dateisystem)* |
| Windows (nativ, PowerShell/CMD) | `C:\Users\<Benutzername>\.ssh\config` |

> **Wichtig:** Auf Windows und Linux/macOS sind das **getrennte** SSH-Umgebungen.  
> Ein Alias in WSL gilt nicht in PowerShell und umgekehrt.  
> Richte den Alias in der Umgebung ein, in der du SSH auch verwendest.

---

## 1. Config-Datei erstellen oder öffnen

### Linux, macOS und WSL

```bash
# Ordner erstellen, falls nicht vorhanden
mkdir -p ~/.ssh

# Datei öffnen (nano ist einfacher als vim)
nano ~/.ssh/config
```

### Windows (PowerShell)

```powershell
# Ordner erstellen, falls nicht vorhanden
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.ssh"

# Datei öffnen (Notepad)
notepad "$env:USERPROFILE\.ssh\config"
```

> Alternativ in VS Code:
> ```powershell
> code "$env:USERPROFILE\.ssh\config"
> ```

---

## 2. Alias eintragen

Füge folgenden Block in die Datei ein und ersetze die Platzhalter:

```ssh
Host spark
    HostName 192.168.1.42
    User chris
    IdentityFile ~/.ssh/id_ed25519
    Port 22
```

### Was bedeuten die Felder?

| Feld | Bedeutung | Beispiel |
|------|-----------|---------|
| `Host` | Der Alias – was du tippen wirst | `spark` |
| `HostName` | Die echte IP-Adresse oder Domain des Servers | `192.168.1.42` |
| `User` | Dein Benutzername auf dem Server | `chris` |
| `IdentityFile` | Pfad zu deinem privaten SSH-Schlüssel | `~/.ssh/id_ed25519` |
| `Port` | SSH-Port des Servers (Standard: 22) | `22` |

> **Tipp:** `Port 22` kann weggelassen werden, wenn der Server den Standard-Port nutzt.

---

## 3. Datei speichern

### nano (Linux / macOS / WSL)

1. `Ctrl + O` → Datei speichern  
2. `Enter` → Dateiname bestätigen  
3. `Ctrl + X` → nano beenden

### Notepad (Windows)

`Datei → Speichern` oder `Ctrl + S`, dann Fenster schließen.

---

## 4. Berechtigungen setzen

Die SSH-Config-Datei muss korrekte Berechtigungen haben, sonst **ignoriert OpenSSH sie ohne Fehlermeldung**.

### Linux, macOS und WSL

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
```

**Was bedeutet das?**
- `700` auf den Ordner: Nur du selbst darfst ihn lesen, schreiben und öffnen.
- `600` auf die Datei: Nur du selbst darfst sie lesen und schreiben. Andere Benutzer haben keinen Zugriff.

### Windows (nativ, PowerShell)

Auf Windows gibt es kein `chmod`. Die Berechtigungen werden über **NTFS-Zugriffsrechte** gesteuert.  
In den meisten Fällen sind die Berechtigungen bereits korrekt, weil der `.ssh`-Ordner nur dir gehört.

Falls SSH sich beschwert (`Bad permissions`), Berechtigungen manuell korrigieren:

```powershell
# Nur deinen eigenen Benutzer als Eigentümer setzen
$configPath = "$env:USERPROFILE\.ssh\config"

# Alle vererbten Berechtigungen entfernen und nur den aktuellen Benutzer erlauben
icacls $configPath /inheritance:r /grant:r "${env:USERNAME}:(R,W)"
```

---

## 5. Verbindung testen

```bash
ssh spark
```

Das ist jetzt äquivalent zu:

```bash
ssh -i ~/.ssh/id_ed25519 -p 22 chris@192.168.1.42
```

---

## 6. Mehrere Aliase in einer Config

Du kannst beliebig viele Hosts in einer einzigen Config-Datei eintragen:

```ssh
Host spark
    HostName 192.168.1.42
    User chris
    IdentityFile ~/.ssh/id_ed25519

Host gpu-server
    HostName 10.0.0.5
    User chris
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes

Host uni
    HostName ssh.hs-heilbronn.de
    User cheinzmann
    IdentityFile ~/.ssh/id_ed25519
    Port 22
```

---

## 7. Nützliche Zusatzoptionen

```ssh
Host spark
    HostName 192.168.1.42
    User chris
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes            # Lokale SSH-Keys auf dem Server nutzbar (z. B. für git push)
    ServerAliveInterval 60      # Sendet alle 60 Sekunden ein Keep-Alive-Signal
    ServerAliveCountMax 3       # Trennt nach 3 unbeantworteten Signalen
```

**`ForwardAgent yes`** ist besonders praktisch, wenn du auf dem Server GitHub-Repositories klonen oder pushen willst, ohne dort einen eigenen SSH-Key ablegen zu müssen.

---

## 8. Häufige Fehler und Lösungen

### „Permission denied (publickey)"
→ Der Server kennt deinen Public Key noch nicht.  
→ Lösung: Public Key auf den Server kopieren (siehe Anleitung *SSH Key einrichten*).

### SSH ignoriert die Config-Datei kommentarlos
→ Meistens Berechtigungsproblem (Schritt 4 wiederholen).  
→ Auf Linux/WSL: `ls -la ~/.ssh/config` zeigt `-rw-------` wenn korrekt.

### „Bad configuration option" beim Verbinden
→ Tippfehler in der Config. Jede Option muss mit **4 Leerzeichen** eingerückt sein, nicht mit Tab.

### Windows: `ssh spark` nimmt die falsche IdentityFile-Pfadangabe
→ Unter Windows `~` im IdentityFile-Pfad durch den vollständigen Pfad ersetzen:
```ssh
IdentityFile C:\Users\chris\.ssh\id_ed25519
```

---

## Zusammenfassung

| Schritt | Linux / macOS / WSL | Windows |
|---------|--------------------|---------| 
| Config öffnen | `nano ~/.ssh/config` | `notepad $env:USERPROFILE\.ssh\config` |
| Berechtigungen | `chmod 600 ~/.ssh/config` | meistens automatisch korrekt, sonst `icacls` |
| Testen | `ssh spark` | `ssh spark` |
