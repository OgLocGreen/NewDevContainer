# SMB/CIFS-Netzlaufwerk unter Linux mounten

Diese Anleitung erklärt, wie du Netzlaufwerke (z. B. Hochschul-Fileserver, NAS) per SMB/CIFS unter Linux einbindest — einmalig, mit gespeicherten Zugangsdaten und automatisch beim Systemstart.

**Reihenfolge:**

1. Voraussetzungen
2. Schnelltest: einmalig manuell mounten
3. Zugangsdaten sicher in Credentials-Datei speichern
4. Auto-Mount via `/etc/fstab`
5. Wichtige Mount-Optionen
6. Auto-Mount via systemd (Alternative zu fstab)
7. Troubleshooting

---

## 1. Voraussetzungen

CIFS-Tools installieren (einmalig):

```bash
# Debian / Ubuntu
sudo apt update && sudo apt install cifs-utils

# Fedora / RHEL
sudo dnf install cifs-utils

# Arch
sudo pacman -S cifs-utils
```

Mountpoint anlegen:

```bash
mkdir -p ~/mounts/<sharename>
```

> **Konvention:** Mountpoints unter `~/mounts/` halten — übersichtlicher als irgendwo auf dem Desktop, und im Home-Verzeichnis sind die Berechtigungen klar.

---

## 2. Schnelltest: einmalig manuell mounten

Grund-Syntax:

```bash
sudo mount -t cifs //<server>/<share> <mountpoint> -o username=<user>,vers=3.0
```

Konkretes Beispiel:

```bash
sudo mount -t cifs //fileserver.example.com/projects ~/mounts/projects \
    -o username=<user>,vers=3.0
```

Du wirst nach dem Passwort gefragt. Wird das akzeptiert, ist der Share unter `~/mounts/projects/` erreichbar.

### Passwort mit Sonderzeichen direkt übergeben

Sonderzeichen (`:`, `"`, `$`, `!`) müssen escaped oder das ganze Passwort in **einfache** Anführungszeichen gesetzt werden:

```bash
sudo mount -t cifs //fileserver.example.com/projects ~/mounts/projects \
    -o username=<user>,password='P@ss:word!',vers=3.0
```

> **Sicherheit:** Passwort in der Kommandozeile landet in der Shell-History und ist via `ps` für andere User sichtbar. Für mehr als einen Test → Credentials-Datei (Abschnitt 3).

### Aushängen

```bash
sudo umount ~/mounts/projects
```

Falls „target is busy": prüfen mit `lsof +D ~/mounts/projects`, ob noch Prozesse darauf zugreifen.

---

## 3. Zugangsdaten sicher in Credentials-Datei speichern

Empfohlen — Passwort liegt nicht mehr im Klartext in History oder fstab.

### Datei anlegen

```bash
sudo mkdir -p /etc/samba
sudo nano /etc/samba/credentials
```

Inhalt:

```
username=<user>
password=<passwort>
domain=<domain>      # optional, z. B. bei AD-Authentifizierung
```

### Berechtigungen restriktiv setzen

```bash
sudo chown root:root /etc/samba/credentials
sudo chmod 600 /etc/samba/credentials
```

> **Wichtig:** `600` = nur Root darf lesen/schreiben. Ohne diese Beschränkung kann jeder Benutzer am System dein Passwort sehen.

### Mounten mit Credentials-Datei

```bash
sudo mount -t cifs //fileserver.example.com/projects ~/mounts/projects \
    -o credentials=/etc/samba/credentials,vers=3.0
```

### Mehrere Shares, mehrere Konten

Eine Credentials-Datei pro Konto:

```
/etc/samba/credentials-uni
/etc/samba/credentials-nas
```

Beim Mount jeweils die passende referenzieren.

---

## 4. Auto-Mount via `/etc/fstab`

Damit der Share bei jedem Systemstart automatisch eingehängt wird.

Eintrag in `/etc/fstab` ergänzen:

```fstab
//fileserver.example.com/projects  /home/<user>/mounts/projects  cifs  credentials=/etc/samba/credentials,uid=1000,gid=1000,vers=3.0,_netdev,nofail,x-systemd.automount  0  0
```

Felder (durch Whitespace getrennt):

| Spalte | Wert | Bedeutung |
|---|---|---|
| 1 | `//server/share` | Quelle |
| 2 | `/home/<user>/mounts/projects` | Mountpoint (absoluter Pfad nötig) |
| 3 | `cifs` | Dateisystem-Typ |
| 4 | Optionen (siehe unten) | Mount-Optionen, kommagetrennt |
| 5 | `0` | Dump (nicht relevant für Netzlaufwerke) |
| 6 | `0` | fsck-Reihenfolge (immer `0` für Netzlaufwerke) |

### Empfohlene Optionen für fstab

| Option | Zweck |
|---|---|
| `credentials=/etc/samba/credentials` | Zugangsdaten aus Datei |
| `uid=1000,gid=1000` | Welcher lokale User die Dateien „besitzt" — eigene UID via `id -u` ermitteln |
| `vers=3.0` | SMB-Protokollversion erzwingen (3.0+ ist Pflicht für Sicherheit) |
| `_netdev` | Mount erst nach Netzwerk-Verfügbarkeit |
| `nofail` | Boot bricht nicht ab, falls Share unerreichbar |
| `x-systemd.automount` | Lazy Mount — wird erst bei Zugriff eingehängt, beschleunigt Boot |

### fstab testen ohne Reboot

```bash
sudo mount -a
```

Keine Ausgabe = okay. Bei Fehlern → Eintrag prüfen, Tippfehler in Pfad oder Optionen sind häufig.

---

## 5. Wichtige Mount-Optionen

| Option | Beispiel | Zweck |
|---|---|---|
| `vers=` | `vers=3.0` oder `vers=3.1.1` | SMB-Version. Niemals `vers=1.0` (unsicher, deprecated) |
| `uid=`, `gid=` | `uid=1000,gid=1000` | Lokaler Owner der Dateien. Sonst gehören alle Files Root |
| `file_mode=` | `file_mode=0664` | Default-Berechtigungen für Dateien |
| `dir_mode=` | `dir_mode=0775` | Default-Berechtigungen für Ordner |
| `iocharset=` | `iocharset=utf8` | Zeichenkodierung — wichtig für Umlaute in Dateinamen |
| `domain=` | `domain=AD` | Active Directory Domäne |
| `sec=` | `sec=ntlmssp` | Auth-Mechanismus, bei Verbindungsproblemen probieren |
| `ro` / `rw` | `ro` | Nur-lesen / lesen+schreiben (Default) |
| `noperm` | — | Lokale Permission-Checks aushebeln (nur wenn nötig) |

Vollständiger Parameter-Überblick: `man mount.cifs`.

---

## 6. Auto-Mount via systemd (Alternative zu fstab)

Modernere Variante, sauberer logging-bar als fstab. Sinnvoll bei Laptops, die nicht immer im richtigen Netzwerk hängen.

Zwei Unit-Dateien sind nötig — der Mountpoint-Pfad bestimmt den Dateinamen (Slashes durch Bindestriche ersetzen, ohne führenden Slash).

Beispiel für Mountpoint `/home/<user>/mounts/projects` → Dateiname `home-<user>-mounts-projects`.

### `/etc/systemd/system/home-<user>-mounts-projects.mount`

```ini
[Unit]
Description=Mount projects share
Requires=network-online.target
After=network-online.target

[Mount]
What=//fileserver.example.com/projects
Where=/home/<user>/mounts/projects
Type=cifs
Options=credentials=/etc/samba/credentials,uid=1000,gid=1000,vers=3.0,_netdev

[Install]
WantedBy=multi-user.target
```

### `/etc/systemd/system/home-<user>-mounts-projects.automount`

```ini
[Unit]
Description=Automount projects share
Requires=network-online.target
After=network-online.target

[Automount]
Where=/home/<user>/mounts/projects
TimeoutIdleSec=600

[Install]
WantedBy=multi-user.target
```

Aktivieren:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now home-<user>-mounts-projects.automount
```

Vorteil gegenüber fstab: Beim Zugriff wird der Share gemountet, nach `TimeoutIdleSec` Inaktivität wieder ausgehängt. Spart Ressourcen und übersteht VPN-Wechsel besser.

---

## 7. Troubleshooting

### `mount error(13): Permission denied`

Falsche Zugangsdaten oder falsche Domain. Prüfen:

```bash
# Letzte Kernel-Meldungen ansehen
sudo dmesg | tail -n 20

# Systemd-Journal
journalctl -xe | tail -n 30
```

Bei AD-Authentifizierung `domain=<DOMAIN>` in Credentials-Datei oder Mount-Optionen ergänzen.

### `mount error(2): No such file or directory`

Share-Pfad falsch geschrieben oder existiert nicht. Auf dem Server verfügbare Shares listen:

```bash
smbclient -L //fileserver.example.com -U <user>
```

### `mount error(112): Host is down` oder `Connection timed out`

Netzwerk-Problem. Prüfen:

```bash
ping fileserver.example.com
# Port 445 (SMB) erreichbar?
nc -zv fileserver.example.com 445
```

Häufig: Hochschul-Server nur via VPN erreichbar.

### `mount error(95): Operation not supported`

SMB-Versions-Mismatch. Andere Version probieren:

```bash
# Stattdessen 2.1, 3.1.1 testen
-o vers=2.1
-o vers=3.1.1
```

### Umlaute in Dateinamen werden falsch dargestellt

`iocharset=utf8` zu den Mount-Optionen hinzufügen.

### Dateien gehören Root, lokaler User kann nicht schreiben

`uid=` und `gid=` mit der eigenen Host-UID/GID ergänzen:

```bash
id -u    # UID anzeigen
id -g    # GID anzeigen
```

Dann `uid=<wert>,gid=<wert>,file_mode=0664,dir_mode=0775` zu den Mount-Optionen.

### Passwort ohne Eingabe testen

Beim manuellen Mount Passwort weglassen — wird interaktiv abgefragt:

```bash
sudo mount -t cifs //fileserver.example.com/projects ~/mounts/projects \
    -o username=<user>,vers=3.0
```

So lässt sich isolieren, ob das Problem am Passwort, an der Syntax oder am Server liegt.

### Boot hängt wegen unerreichbarem Share

`nofail` und `x-systemd.automount` zu den fstab-Optionen ergänzen — verhindert, dass der Boot-Vorgang auf einen Share wartet, der nicht erreichbar ist.

---

## Anhang: Cheatsheet

| Aufgabe | Befehl |
|---|---|
| CIFS-Tools installieren | `sudo apt install cifs-utils` |
| Verfügbare Shares listen | `smbclient -L //<server> -U <user>` |
| Manuell mounten | `sudo mount -t cifs //<server>/<share> <mountpoint> -o username=<user>,vers=3.0` |
| Mit Credentials-Datei mounten | `sudo mount -t cifs //<server>/<share> <mountpoint> -o credentials=/etc/samba/credentials,vers=3.0` |
| Aushängen | `sudo umount <mountpoint>` |
| fstab-Einträge testen | `sudo mount -a` |
| Aktive Mounts anzeigen | `mount \| grep cifs` |
| Eigene UID/GID | `id -u` / `id -g` |
| SMB-Logs ansehen | `sudo dmesg \| tail` und `journalctl -xe` |
| systemd-Mount aktivieren | `sudo systemctl enable --now <name>.automount` |
