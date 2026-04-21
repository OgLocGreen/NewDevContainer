
## 1. Problemstellung

Beim Versuch, ein Netzwerklaufwerk unter Linux zu mounten, kann es vorkommen, dass der Mount-Befehl aufgrund von Sonderzeichen im Passwort oder anderen Syntaxfehlern nicht richtig funktioniert.

## 2. Lösung: Korrekte Syntax verwenden

### Option 1: Passwort korrekt escapen

Falls das Passwort Sonderzeichen enthält (wie `:` oder `"`), muss es in einfache Anführungszeichen gesetzt oder mit Backslashes (`\`) escapt werden.

```bash
sudo mount -t cifs //hhncl-smb02.hhn.hs-heilbronn.de/fak_t1/ASE-InfoSys-1 /home/chris/Desktop/InfoSys1 -o username=cheinzmann,password='xxx',vers=3.0
```

Falls das nicht funktioniert:

```bash
sudo mount -t cifs //hhncl-smb02.hhn.hs-heilbronn.de/fak_t1/ASE-InfoSys-1 /home/chris/Desktop/InfoSys1 -o username=cheinzmann,password=xxx,vers=3.0
```

---

### Option 2: Sicheres Speichern der Zugangsdaten (empfohlen!)

1. Erstelle eine Datei für die Zugangsdaten:
    
    ```bash
    sudo nano /etc/samba/credentials
    ```
    
2. Füge folgende Zeilen hinzu:
    
    ```
    username=cheinzmann
    password=xxx
    ```
    
3. Speichere die Datei mit `CTRL + X`, dann `Y` und `ENTER`.
    
4. Setze sichere Berechtigungen:
    
    ```bash
    sudo chmod 600 /etc/samba/credentials
    ```
    
5. Mounten mit:
    
    ```bash
    sudo mount -t cifs //hhncl-smb02.hhn.hs-heilbronn.de/fak_t1/ASE-InfoSys-1 /home/chris/Desktop/InfoSys1 -o credentials=/etc/samba/credentials,vers=3.0
    ```
    
6. Falls das Laufwerk beim Systemstart automatisch gemountet werden soll, füge folgende Zeile in `/etc/fstab` hinzu:
    
    ```
    //hhncl-smb02.hhn.hs-heilbronn.de/fak_t1/ASE-InfoSys-1 /home/chris/Desktop/InfoSys1 cifs credentials=/etc/samba/credentials,vers=3.0 0 0
    ```
    
7. Teste die `fstab`-Konfiguration mit:
    
    ```bash
    sudo mount -a
    ```
    

---

## 3. Debugging

Falls der Zugriff nicht funktioniert, kann man folgende Befehle zur Fehleranalyse verwenden:

```bash
dmesg | tail -n 20
journalctl -xe | tail -n 20
```

Falls immer noch Probleme auftreten, kann der Mount-Befehl erst ohne Passwort getestet werden:

```bash
sudo mount -t cifs //hhncl-smb02.hhn.hs-heilbronn.de/fak_t1/ASE-InfoSys-1 /home/chris/Desktop/InfoSys1 -o username=cheinzmann,vers=3.0
```

Dann wird nach dem Passwort gefragt, sodass man es manuell eingeben kann.

---

### Fazit

Durch die Verwendung einer `credentials`-Datei oder korrektes Escaping von Sonderzeichen kann das Netzlaufwerk problemlos unter Linux eingebunden werden. Falls es weiterhin Probleme gibt, können die Systemlogs helfen, die genaue Ursache zu finden.