
Wenn eine Datei zu groß ist, um sie auf GitHub hochzuladen, oder wenn du eine große Datei versehentlich committet hast, kannst du sie gezielt aus der Git-Historie entfernen. Hier sind zwei Methoden:

## Inhaltsverzeichnis 
- [Herausfinden, welche Dateien zu groß sind](#herausfinden-welche-dateien-zu-groß-sind) 
- [Maximale Dateigröße für GitHub](#maximale-dateigröße-für-github) - [Methode 1: Datei aus der gesamten Git-Historie entfernen (empfohlen)](#methode-1-datei-aus-der-gesamten-git-historie-entfernen-empfohlen) 
- [Methode 2: Einen gesamten Ordner aus der Git-Historie entfernen](#methode-2-einen-gesamten-ordner-aus-der-git-historie-entfernen) 
- [Methode 3: Datei nur aus den letzten Commits entfernen (Rebase)](#methode-3-datei-nur-aus-den-letzten-commits-entfernen-rebase) 
- [Entfernen eines falschen Remote-Branches](#entfernen-eines-falschen-remote-branches) 
- [Lokalen Branch umbenennen, um Änderungen zu sichern](#lokalen-branch-umbenennen-um-änderungen-zu-sichern) 
- [Wichtige Hinweise](#wichtige-hinweise)
## Herausfinden, welche Dateien zu groß sind
Bevor du eine Datei entfernst, kannst du die größten Dateien in deinem Repository auflisten:
```bash
git rev-list --objects --all | sort -k 2 -r | head -n 10
```
Dieser Befehl zeigt die 10 größten Dateien im Repository.

Falls du Dateien über einer bestimmten Größe finden willst, nutze:
```bash
git ls-files -s | awk '$2 > 100000000 { print $2, $4 }'
```
Dieser Befehl listet Dateien über 100 MB auf.

## Maximale Dateigröße für GitHub
- **100 MB** pro Datei beim Pushen (wird von GitHub blockiert).
- **50 MB** empfohlene Grenze für einzelne Dateien zur Performance-Optimierung.
- **1 GB** für das gesamte Repository, größere Repos können Probleme beim Klonen verursachen.
- Falls du größere Dateien speichern musst, verwende **Git LFS (Large File Storage)**.

## Methode 1: Datei aus der gesamten Git-Historie entfernen (empfohlen)
Diese Methode entfernt die Datei vollständig aus der Historie und reduziert die Repository-Größe.

### 1. `git-filter-repo` installieren (falls nicht vorhanden)
```bash
pip install git-filter-repo
```

### 2. Datei aus der gesamten Historie entfernen
```bash
git filter-repo --path PATH/TO/BIG_FILE --invert-paths
```
Ersetze `PATH/TO/BIG_FILE` mit dem tatsächlichen Dateipfad.

### 3. Bereinigen und Änderungen pushen
```bash
git reflog expire --expire=now --all
git gc --prune=now
git push origin --force --all
```
**Achtung:** `--force` ist notwendig, da die Historie verändert wurde.

## Methode 2: Einen gesamten Ordner aus der Git-Historie entfernen
Falls ein gesamter Ordner aus der Historie gelöscht werden soll, kannst du denselben Befehl wie bei Dateien verwenden:
```bash
git filter-repo --path PATH/TO/FOLDER --invert-paths
```
Anschließend wieder die Bereinigung und das Pushen durchführen:
```bash
git reflog expire --expire=now --all
git gc --prune=now
git push origin --force --all
```

---

## Methode 3: Datei nur aus den letzten Commits entfernen (Rebase)
Falls die Datei erst vor kurzem hinzugefügt wurde, kannst du sie gezielt aus bestimmten Commits entfernen.

### 1. Finde den Commit, in dem die Datei hinzugefügt wurde
```bash
git log --diff-filter=A -- PATH/TO/BIG_FILE
```

### 2. Interaktives Rebase starten (z. B. letzte 5 Commits)
```bash
git rebase -i HEAD~5
```
Falls der Commit weiter zurückliegt, erhöhe `HEAD~5` entsprechend.

### 3. Commit zur Bearbeitung markieren
- Ändere `pick` zu `edit` für den Commit, der die Datei enthält.
- Speichere die Datei und schließe den Editor.

### 4. Datei aus dem Commit entfernen
```bash
git rm --cached PATH/TO/BIG_FILE
git commit --amend --no-edit
```

### 5. Rebase fortsetzen
```bash
git rebase --continue
```

### 6. Änderungen pushen
```bash
git push origin --force
```

---

## Entfernen eines falschen Remote-Branches
Falls dein lokaler Branch mit einem falschen Remote-Branch verbunden ist oder du einen nicht benötigten Remote entfernen möchtest:

### 1. Liste alle Remotes auf
```bash
git remote -v
```

### 2. Entferne den unerwünschten Remote
Falls du zum Beispiel `dev_ogloc` entfernen willst, gib ein:
```bash
git remote remove dev_ogloc
```
Falls du `origin` entfernen möchtest:
```bash
git remote remove origin
```

### 3. Falls notwendig, den Remote erneut hinzufügen
Falls du den Remote versehentlich entfernt hast, kannst du ihn wieder hinzufügen:
```bash
git remote add origin git@github.com:OgLocGreen/OgLocGreenSpace.git
```

### 4. Upstream-Branch neu setzen
Falls dein lokaler Branch nicht mehr mit dem Remote-Branch verknüpft ist:
```bash
git branch --set-upstream-to=origin/main main
```
Falls dein Remote-Branch anders heißt, kannst du ihn mit folgendem Befehl herausfinden:
```bash
git branch -r
```
Dann passe den Upstream entsprechend an:
```bash
git branch --set-upstream-to=origin/DEIN_BRANCH_NAME main
```

---

## Lokalen Branch umbenennen, um Änderungen zu sichern
Falls du Änderungen lokal hast, aber `origin/main` holen möchtest, ohne sie zu verlieren:

### 1. Benenne den lokalen `main` um
```bash
git branch -m main main_backup
```

### 2. Hole die neueste Version von `origin/main`
```bash
git fetch origin
git checkout -b main origin/main
```
Falls `main` bereits existiert, kannst du ihn direkt zurücksetzen:
```bash
git reset --hard origin/main
```

### 3. Mergen der Änderungen aus `main_backup`
```bash
git merge main_backup
```
Falls es Merge-Konflikte gibt, löse sie manuell und committe die Änderungen:
```bash
git add .
git commit -m "Merged local changes from main_backup"
```

### 4. Änderungen pushen
```bash
git push origin main
```
Falls nötig, mit `--force`:
```bash
git push origin main --force
```

### 5. (Optional) `main_backup` löschen
Falls nach dem Merge alles passt und du keine Sicherung mehr brauchst:
```bash
git branch -D main_backup
```

---

## Wichtige Hinweise
- Falls du große Dateien in `.gitignore` hinzufügst, löscht das nicht automatisch deren Historie. Nutze `git filter-repo`, um sie wirklich zu entfernen.
- Falls das Repository bereits auf GitHub gepusht wurde, müssen alle Contributor ihr lokales Repository mit `git fetch --all` und `git reset --hard origin/main` synchronisieren.

Durch diese Schritte kannst du große Dateien aus deiner Git-Historie entfernen, Remote-Probleme lösen und dein Repository sauber halten.
