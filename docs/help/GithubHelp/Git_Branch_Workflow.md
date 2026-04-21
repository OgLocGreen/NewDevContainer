## Vorteile von getrennten Branches
- Erleichtern paralleles Arbeiten
- Vermeiden Merge-Konflikte
- Bessere Nachverfolgbarkeit einzelner Features
## Empfohlener Ablauf


  1. **Commit & Push**
Nach jedem Commit den Branch pushen, damit das Remote-Repository (GitHub) aktuell bleibt. 
2. **Feature-Entwicklung**
Arbeite in einem Feature-Branch und pushe regelmäßig deine Änderungen.
3. **Merge in Main_<Entwicklername>**
Wenn ein Feature-Branch Fortschritte macht, führe einen Merge in deinen persönlichen Main-Branch durch:

```
git checkout Main_<Entwicklername>
git merge feature/<feature-name>
git push
```

4.  **Updates zurückholen**
Umgekehrt regelmäßig `Main_<Entwicklername>` zurück in den Feature-Branch mergen, um auf dem aktuellen Stand zu bleiben:

```
git checkout feature/<feature-name>
git merge Main_<Entwicklername>

```
5. **Abschluss**
Wenn das Feature stabil ist, Merge von `Main_<Entwicklername>` in `main`:

```
git checkout main
git merge Main_<Entwicklername>
git push
``` 
## Tipp

  - Verwende `git log --oneline --graph` zur visuellen Kontrolle deines Branch-Verlaufs.