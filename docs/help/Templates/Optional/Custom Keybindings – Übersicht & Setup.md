# Custom Keybindings – Übersicht & Setup

Diese Datei fasst meine **Custom Shortcuts** zusammen und erklärt kurz, wie sie in den jeweiligen Programmen eingerichtet werden. Ziel: **Tab-Wechsel im „zuletzt benutzt“-Stil** (wie Alt+Tab, aber für Tabs) mit einem einheitlichen Shortcut.

---

## 1) Schnellmatrix (geht es nativ?)

| Programm              | „Zuletzt benutzter Tab“ | Custom Key möglich | Empfehlung |
|----------------------|--------------------------|--------------------|------------|
| Firefox              | **Ja** (per Option)      | **Ja**             | Aktivieren + Key remappen |
| VS Code              | **Ja** (Standard)        | **Ja**             | Direkt Key remappen |
| GNOME Terminal       | **Nein** (nur Nachbar)   | **Ja**             | Emulation/Workaround |
| Terminator / Tilix   | **Ja** (konfigurierbar)  | **Ja**             | Direkt Key remappen |
| Nautilus (Explorer)  | **Nein**                 | **Ja** (Emulation) | AutoKey-Workaround |

**Kurzfazit:** Einheitlicher Shortcut ist überall möglich. „Zuletzt benutzter Tab“ ist nativ in Firefox/VS Code da, im Terminal/Explorer via Workaround/Emulation.

---

## 2) Meine Keykombis

- **Ctrl + ^** → *Switch to last used tab* (bzw. Emulation auf „Ctrl+Tab“)  
- **Ctrl + Shift + ^** → *Switch to previous in MRU* (bzw. Emulation auf „Ctrl+Shift+Tab“)  
- Optional:
  - **Alt + 1..9** → *Direkt zu Tab 1..9* (Terminal/Browser/VS Code dort, wo sinnvoll)
  - **Ctrl + K, Z** → *Zen Mode in VS Code* (fokussiertes Arbeiten)

> Hinweis: `^` ist Taste „Zirkumflex“ (links neben „1“ auf DE-Layout).

---

## 3) Einrichtung pro Programm

### 3.1 Firefox
1. `about:config` öffnen
2. `browser.ctrlTab.recentlyUsedOrder` auf **true** setzen (MRU-Reihenfolge aktivieren)
3. **Shortcut remappen** (z. B. via Add-on wie *Shortkeys* / *Saka Key* / *Custom Hotkeys*):
   - `Ctrl + ^` → Aktion „Next tab (MRU)“ bzw. Senden von `Ctrl+Tab`
   - `Ctrl + Shift + ^` → Senden von `Ctrl+Shift+Tab`

**Alternative ohne Add-on (systemweit via AutoKey):** Siehe Abschnitt 4.

---

### 3.2 VS Code
1. **Keyboard Shortcuts** öffnen: `Ctrl + K, Ctrl + S`
2. Suchen: **„View: Open Next Recently Used Editor“** → Key: `Ctrl + ^`
3. Suchen: **„View: Open Previous Recently Used Editor“** → Key: `Ctrl + Shift + ^`

Optional für Tab-Direktsprünge:
- **„View: Show Editor in Group 1..9“** auf `Alt+1..9`

---

### 3.3 GNOME Terminal (Standard)
- Nativ gibt es **nur Nachbar-Tabs** (`Ctrl+PgUp` / `Ctrl+PgDn`).  
- Zwei Wege:
  1) **AutoKey-Emulation** (empfohlen, siehe Abschnitt 4) → mappe `Ctrl+^` auf `Ctrl+Tab` (wenn Tabs vorhanden) bzw. `Ctrl+PgDn`/`Ctrl+PgUp`.
  2) **Wechsel zu Terminator/Tilix**: Beide erlauben „last used“ bzw. frei konfigurierbare Tab-Switcher.

**Terminator/Tilix Einrichtung (Beispiel):**
- Einstellungen → Shortcuts → „Last Used Terminal/Tab“ auf `Ctrl+^`
- „Previous in MRU“ auf `Ctrl+Shift+^`

---

### 3.4 Nautilus (Explorer)
- Kein „last used“-Modus. Tabs gibt es, aber nur Nachbarwechsel.
- **Workaround:** AutoKey-Emulation:
  - `Ctrl+^` → sende `Ctrl+Tab` oder `Ctrl+PgDn`
  - `Ctrl+Shift+^` → sende `Ctrl+Shift+Tab` oder `Ctrl+PgUp`

---

## 4) Systemweiter Ansatz (Linux): AutoKey

Mit **AutoKey** kannst du `Ctrl+^` überall auf „Next Tab“ (oder MRU-Emulation) mappen – unabhängig von der App.

### 4.1 Installation
```bash
sudo apt update
sudo apt install autokey-gtk  # für GNOME/Ubuntu
```

### 4.2 Beispiel: AutoKey-Skript für „Next/Prev Tab“
- AutoKey starten → „New Script“ → folgenden Code einfügen → Hotkey setzen (`Ctrl+^` bzw. `Ctrl+Shift+^`).

**Next Tab (MRU-Emu) – `Ctrl+^`:**
```python
# AutoKey (Python 3) script
# Ziel: Ctrl+^ sendet Ctrl+Tab (generischer Next Tab)
keyboard.send_keys("<ctrl>+<tab>")
```

**Previous Tab (MRU-Emu) – `Ctrl+Shift+^`:**
```python
# AutoKey (Python 3) script
# Ziel: Ctrl+Shift+^ sendet Ctrl+Shift+Tab (generischer Previous Tab)
keyboard.send_keys("<ctrl>+<shift>+<tab>")
```

> Tipp: Für Apps, die `Ctrl+Tab` nicht kennen, kann man pro-Window-Class bedingt `Ctrl+PgDn/PgUp` senden. Beispiel (Nautilus):
```python
win = window.get_active_class()  # e.g., 'Org.gnome.Nautilus'
if "Nautilus" in win:
    keyboard.send_keys("<ctrl>+<pgdn>")
else:
    keyboard.send_keys("<ctrl>+<tab>")
```

### 4.3 Konflikte vermeiden
- Prüfe, ob `Ctrl+^` schon systemweit belegt ist (GNOME Keyboard Shortcuts).
- In Apps mit eigenem Mapping (Firefox Add-on, VS Code) entweder **direkt dort** mappen **oder** per AutoKey global – vermeide Doppelbelegungen.

---

## 5) Pflege dieser Datei
- Neue Shortcuts hier oben in **Abschnitt 2** ergänzen.
- Pro App unter **Abschnitt 3** kurz notieren, wie das Mapping umgesetzt ist (nativ / Add-on / AutoKey).

---

**Stand:** 2025-08-19