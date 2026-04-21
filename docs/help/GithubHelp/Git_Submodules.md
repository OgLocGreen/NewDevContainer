# Git Submodules - Anleitung

## Übersicht
Git Submodules ermöglichen es, ein Git-Repository als Unterverzeichnis in einem anderen Git-Repository einzubinden. Dies ist besonders nützlich für die Verwaltung von Abhängigkeiten oder gemeinsam genutzten Bibliotheken.

## Repository mit Submodules klonen

### Vollständiges Klonen mit allen Submodules

```bash
# Repository mit allen Submodules klonen
git clone --recursive <repository-url>
```

### Repository klonen und Submodules nachträglich initialisieren

```bash
# Repository normal klonen
git clone <repository-url>
cd <repository-name>

# Submodules initialisieren und herunterladen
git submodule update --init --recursive
```

## Submodule zu einem bestehenden Repository hinzufügen

### Ein externes Repository als Submodule hinzufügen

```bash
# Submodule hinzufügen
git submodule add <submodule-repository-url> <pfad/zum/submodule>

# Beispiel:
git submodule add https://github.com/user/library.git libs/external-library
```

### Änderungen committen

```bash
# Die .gitmodules Datei und das neue Submodule-Verzeichnis hinzufügen
git add .gitmodules <pfad/zum/submodule>
git commit -m "Add submodule: <submodule-name>"
```

## Arbeiten mit Submodules

### Submodules aktualisieren

```bash
# Alle Submodules auf den neuesten Stand bringen
git submodule update --remote

# Spezifisches Submodule aktualisieren
git submodule update --remote <pfad/zum/submodule>
```

### In ein Submodule wechseln und Änderungen vornehmen

```bash
# In das Submodule-Verzeichnis wechseln
cd <pfad/zum/submodule>

# Hier arbeitet man wie in einem normalen Git-Repository
git checkout main
git pull origin main

# Änderungen vornehmen...
git add .
git commit -m "Update submodule"
git push origin main

# Zurück zum Hauptrepository
cd ..

# Submodule-Update im Hauptrepository committen
git add <pfad/zum/submodule>
git commit -m "Update submodule to latest version"
```

### Submodule-Status überprüfen

```bash
# Status aller Submodules anzeigen
git submodule status

# Detaillierte Informationen über Submodules
git submodule foreach git status
```

## Wichtige Befehle im Überblick

| Befehl                                    | Beschreibung                                          |
| ----------------------------------------- | ----------------------------------------------------- |
| `git clone --recursive <url>`             | Repository mit allen Submodules klonen                |
| `git submodule init`                      | Submodules initialisieren                             |
| `git submodule update`                    | Submodules auf den registrierten Commit aktualisieren |
| `git submodule update --init --recursive` | Alle Submodules initialisieren und herunterladen      |
| `git submodule add <url> <path>`          | Neues Submodule hinzufügen                            |
| `git submodule update --remote`           | Submodules auf neueste Commits aktualisieren          |
| `git submodule foreach <command>`         | Befehl in allen Submodules ausführen                  |

## Häufige Probleme und Lösungen

### Problem: Leere Submodule-Verzeichnisse

**Lösung:**
```bash
git submodule update --init --recursive
```

### Problem: Submodule zeigt auf falschen Commit

**Lösung:**
```bash
cd <pfad/zum/submodule>
git checkout <gewünschter-branch-oder-commit>
cd ..
git add <pfad/zum/submodule>
git commit -m "Update submodule reference"
```

### Problem: Submodule entfernen

**Lösung:**
```bash
# Submodule aus .gitmodules entfernen
git submodule deinit <pfad/zum/submodule>

# Submodule-Verzeichnis entfernen
git rm <pfad/zum/submodule>

# Änderungen committen
git commit -m "Remove submodule: <submodule-name>"
```

## Best Practices

### 1. Immer mit --recursive klonen
```bash
git clone --recursive <repository-url>
```

### 2. Regelmäßige Updates
```bash
# Wöchentlich alle Submodules aktualisieren
git submodule update --remote --merge
```

### 3. Submodule-Tracking konfigurieren
```bash
# Submodule so konfigurieren, dass es einem bestimmten Branch folgt
git config -f .gitmodules submodule.<pfad/zum/submodule>.branch <branch-name>
```

### 4. Automatische Updates bei Pull
```bash
# Git-Alias für Pull mit Submodule-Update
git config alias.spull 'pull --recurse-submodules'
```

## .gitmodules Datei

Die `.gitmodules` Datei enthält die Konfiguration aller Submodules:

```ini
[submodule "libs/external-library"]
    path = libs/external-library
    url = https://github.com/user/library.git
    branch = main
```

## Workflow-Beispiel

```bash
# 1. Repository mit Submodules klonen
git clone --recursive https://github.com/myproject/main-repo.git
cd main-repo

# 2. Neues Submodule hinzufügen
git submodule add https://github.com/external/useful-lib.git libs/useful-lib

# 3. Submodule-Änderungen committen
git add .gitmodules libs/useful-lib
git commit -m "Add useful-lib as submodule"

# 4. Submodule aktualisieren
git submodule update --remote

# 5. Alle Änderungen pushen
git push origin main
```

## Weitere Ressourcen

- [Offizielle Git Submodules Dokumentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Pro Git Buch - Submodules](https://git-scm.com/book/de/v2/Git-Tools-Submodule)
- [GitHub Submodules Guide](https://github.blog/2016-02-01-working-with-submodules/)

---

*Diese Anleitung ist Teil des NewDevContainer Development Templates.*
