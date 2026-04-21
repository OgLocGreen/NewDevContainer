
## Dateisystem und Navigation

### Befehle
- `ls` - Listet Dateien und Verzeichnisse im aktuellen Verzeichnis auf.
- `cd [Pfad]` - Ändert das aktuelle Verzeichnis.
- `pwd` - Zeigt den aktuellen Verzeichnispfad an.
- `mkdir [Verzeichnisname]` - Erstellt ein neues Verzeichnis.
- `rmdir [Verzeichnisname]` - Löscht ein leeres Verzeichnis.
- `rm [Datei/Verzeichnis]` - Löscht Dateien oder Verzeichnisse (`-r` für rekursiv).
- `cp [Quelle] [Ziel]` - Kopiert Dateien/Verzeichnisse.
- `mv [Quelle] [Ziel]` - Verschiebt oder benennt Dateien/Verzeichnisse um.
- `find [Pfad] -name [Name]` - Sucht nach Dateien oder Verzeichnissen.
- `locate [Name]` - Findet Dateien über eine Datenbank (schneller als `find`).

## Dateisuche

### Befehle
- `find [Pfad] -name [Dateiname]` - Sucht nach Dateien mit einem bestimmten Namen.
  - Beispiel: `find /home -name "*.txt"`
- `find [Pfad] -type d` - Sucht nur nach Verzeichnissen.
- `grep -r [Text] [Pfad]` - Sucht rekursiv nach einem bestimmten Text in Dateien.
  - Beispiel: `grep -r "Fehler" /var/log/`
- `locate [Dateiname]` - Sucht Dateien basierend auf einer Indexdatenbank (schneller als `find`).
  - Beispiel: `locate Dokument.txt`

## Terminal Shortcuts und Tipps

### Shortcuts
- `ctrl + c` - Beendet den aktuell laufenden Prozess.
- `ctrl + z` - Pausiert den aktuell laufenden Prozess.
- `fg` - Bringt einen pausierten Prozess zurück in den Vordergrund.
- `bg` - Setzt einen pausierten Prozess im Hintergrund fort.
- `ctrl + l` - Löscht den aktuellen Terminal-Bildschirm (entspricht `clear`).
- `ctrl + r` - Sucht interaktiv nach einem vorherigen Befehl in der History.
- `!!` - Führt den letzten Befehl erneut aus.
- `!n` - Führt den Befehl mit der Nummer `n` aus (mit `history` herausfinden).
- `tab` - Autovervollständigung für Befehle, Dateinamen oder Pfade.
- `ctrl + d` - Schließt das Terminal, wenn keine Prozesse laufen.
- `ctrl + shit + T` - Neuer Tab.
- `ctrl + shit + N`  - Neues Winodow. 


### Tipps
- Nutze `alias`, um häufige Befehle zu verkürzen (z. B. `alias ll='ls -la'`).
- Mit `history` kannst du deine zuletzt verwendeten Befehle einsehen.
- Verwende `man [Befehl]`, um die Anleitung zu einem Befehl anzuzeigen (z. B. `man find`).
- Lege `.bashrc` oder `.zshrc` fest, um deine Terminal-Umgebung anzupassen.
- Kombiniere Befehle mit `&&`, um sie nacheinander auszuführen (z. B. `cd /home && ls`).

## Dateibearbeitung

### Befehle
- `cat [Datei]` - Zeigt den Inhalt einer Datei an.
- `less [Datei]` - Zeigt den Inhalt einer Datei seitenweise an.
- `nano [Datei]` - Bearbeitet eine Datei im Terminal (einfacher Editor).
- `vim [Datei]` - Mächtiger Terminal-Editor (erfordert grundlegende Vim-Kenntnisse).
- `touch [Dateiname]` - Erstellt eine leere Datei.

## Systeminformationen

### Befehle
- `uname -a` - Zeigt Systeminformationen an.
- `df -h` - Zeigt den Speicherplatz der Dateisysteme an.
- `du -sh [Pfad]` - Zeigt die Größe eines Verzeichnisses oder einer Datei an.
- `top` - Zeigt eine dynamische Übersicht über Prozesse und Systemressourcen.
- `htop` - Benutzerfreundliche Version von `top` (falls installiert).
- `free -h` - Zeigt Informationen über den Arbeitsspeicher.

## Prozesse und Pakete

### Befehle
- `ps aux` - Listet laufende Prozesse auf.
- `kill [PID]` - Beendet einen Prozess basierend auf der Prozess-ID (PID).
- `killall [Prozessname]` - Beendet alle Prozesse mit dem angegebenen Namen.
- `sudo apt update` - Aktualisiert die Paketlisten (Debian/Ubuntu).
- `sudo apt upgrade` - Aktualisiert alle installierten Pakete (Debian/Ubuntu).
- `sudo pacman -Syu` - Aktualisiert Pakete und Datenbank (Arch Linux).

## Berechtigungen

### Befehle
- `chmod [Modus] [Datei]` - Ändert die Berechtigungen einer Datei.
  - Beispiel: `chmod 755 script.sh`
- `chown [Benutzer:Gruppe] [Datei]` - Ändert den Besitzer einer Datei.
  - Beispiel: `sudo chown user:user file.txt`

## Netzwerk

### Befehle
- `ping [Host/IP]` - Überprüft die Verbindung zu einem Host.
- `ifconfig` - Zeigt Netzwerkschnittstellen und deren Konfiguration (veraltet, durch `ip` ersetzt).
- `ip a` - Zeigt Netzwerkschnittstellen und IP-Adressen an.
- `netstat -tuln` - Listet offene Ports und Verbindungen auf (veraltet, durch `ss` ersetzt).
- `ss -tuln` - Listet offene Ports und Verbindungen auf (moderner).
- `curl [URL]` - Ruft eine URL ab und zeigt den Inhalt an.

## SSH und Remote-Verbindungen

### Befehle
- `ssh user@hostname` - Verbindet sich per SSH zu einem Remote-Host.
- `ssh -i [Key] user@hostname` - Nutzt einen spezifischen SSH-Schlüssel für die Verbindung.
- `scp [Quelle] user@hostname:[Pfad]` - Kopiert Dateien von lokal zu einem Remote-Host.
  - Beispiel: `scp file.txt user@192.168.1.10:/home/user/`
- `scp user@hostname:[Quelle] [Ziel]` - Kopiert Dateien von einem Remote-Host zu lokal.
  - Beispiel: `scp user@192.168.1.10:/home/user/file.txt ./`
- `rsync -avz [Quelle] [Ziel]` - Synchronisiert Dateien zwischen lokalen und Remote-Systemen.
  - Beispiel: `rsync -avz file.txt user@hostname:/remote/path/`
- `ssh-copy-id user@hostname` - Kopiert den lokalen SSH-Schlüssel zu einem Remote-Host, um passwortlose Anmeldung zu ermöglichen.

## Praktische Kurzbefehle

### Befehle
- `alias [Name]='[Befehl]'` - Erstellt einen Alias für einen Befehl.
  - Beispiel: `alias ll='ls -la'`
- `history` - Zeigt die letzten eingegebenen Befehle.
- `!!` - Führt den letzten Befehl erneut aus.
- `!n` - Führt den Befehl mit der Nummer `n` aus (`history` hilft).
- `ctrl + r` - Sucht interaktiv nach einem vorherigen Befehl.


