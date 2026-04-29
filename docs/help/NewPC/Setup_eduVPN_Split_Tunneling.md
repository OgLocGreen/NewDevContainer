# Split-Tunneling für eduVPN unter Linux

Diese Anleitung zeigt, wie du eine eduVPN-Verbindung unter Linux so konfigurierst, dass **nur der Traffic zu Hochschul-Ressourcen** (z. B. Fileserver, interne Dienste) über das VPN läuft, während dein restlicher Internetverkehr direkt über deine normale Verbindung geht.

**Reihenfolge:**

1. Was ist Split-Tunneling und warum?
2. Voraussetzungen
3. Aktuellen Netzwerk-Zustand prüfen
4. Ziel-IP und VPN-Gateway ermitteln
5. Route setzen — nur Ziel-Netz über VPN
6. Standard-Route korrigieren (falls VPN allen Traffic übernommen hat)
7. Verifizieren
8. Dauerhaft machen (systemd-Service)
9. Troubleshooting

> **Verwandte Anleitung:** Wenn du einen SMB/CIFS-Share hinter dem VPN einbinden willst, siehe *Setup_SMB_CIFS_Mount.md*.

---

## 1. Was ist Split-Tunneling und warum?

Standardmäßig leitet ein VPN **alles** durch den Tunnel — auch Netflix, Web-Browsing und Updates. Das hat drei Nachteile:

- **Bandbreite:** VPN-Endpunkt der Hochschule wird unnötig belastet
- **Latenz:** Pakete machen einen Umweg über den Hochschul-Server
- **Geo-Lokalisierung:** Streaming-Dienste sehen dich plötzlich am Hochschul-Standort

**Split-Tunneling** löst das, indem nur der Traffic zu bestimmten Zielen (Subnetzen oder Hosts) über das VPN geht. Der Rest läuft normal über die Default-Route.

---

## 2. Voraussetzungen

- eduVPN-Client installiert und konfiguriert (z. B. via [eduvpn.org](https://www.eduvpn.org/))
- VPN-Verbindung kann grundsätzlich aufgebaut werden
- Root-Rechte für `ip route`-Kommandos
- Tools `ip`, `nslookup` (oder `dig`), `nmcli` — auf den meisten Distributionen vorinstalliert

> **Hinweis:** eduVPN nutzt unter der Haube WireGuard oder OpenVPN. Das Interface heißt typischerweise `eduVPN` oder ähnlich — bei dir kann der Name abweichen. Prüfe mit `ip link`.

---

## 3. Aktuellen Netzwerk-Zustand prüfen

### Ist das VPN aktiv?

```bash
nmcli connection show --active
```

Oder direkt nach dem Interface suchen:

```bash
ip a | grep -A2 eduVPN
```

Kommt keine Ausgabe → VPN ist nicht verbunden. Erst eduVPN-GUI starten und Verbindung aufbauen.

### Läuft mein gesamter Traffic über VPN?

```bash
ip route | grep default
```

Mögliche Ergebnisse:

| Ausgabe | Bedeutung |
|---|---|
| `default via 192.168.x.x dev wlp0s20f3` (oder ähnlich) | Normaler Traffic geht direkt — Standardfall, gut |
| `default via 10.x.x.x dev eduVPN` | **Alles** geht durch das VPN — siehe Abschnitt 6 zum Korrigieren |
| Beide Zeilen | Mehrere Default-Routen mit unterschiedlicher Metrik — Details checken mit `ip route` |

Externe IP zur Bestätigung:

```bash
curl ifconfig.me
```

Erscheint deine normale Provider-IP → alles in Ordnung. Erscheint eine Hochschul-IP → der Traffic läuft komplett übers VPN.

---

## 4. Ziel-IP und VPN-Gateway ermitteln

### Ziel-IP (Server, der hinter dem VPN liegt)

Beispiel: Hochschul-Fileserver

```bash
nslookup <fileserver.hochschule.de>
```

Antwort enthält die IP. Wenn sie aus einem privaten Bereich (`10.x.x.x`, `172.16-31.x.x`, `192.168.x.x`) kommt, ist sie typischerweise nur über VPN erreichbar.

Beispiel-Ausgabe:

```
Name:    <fileserver.hochschule.de>
Address: 10.1.20.25
```

> **Tipp:** Frag nach dem **Subnetz**, nicht nur der einzelnen IP. Hochschulen haben oft mehrere interne Server (`10.1.0.0/16`) — es lohnt sich, das ganze Subnetz zu routen statt für jeden Host eine Einzel-Route. IT-Service der Hochschule fragen oder per `traceroute` nachvollziehen.

### VPN-Gateway-IP (Adresse des VPN-Interfaces auf VPN-Seite)

```bash
ip route | grep eduVPN
```

Beispiel-Ausgabe:

```
10.30.224.0/24 dev eduVPN proto kernel scope link src 10.30.224.7
```

Hier ist `10.30.224.7` deine eigene VPN-IP. Das Gateway zum Hochschul-Netz ist meist `.1` oder `.4` im selben Subnetz — also z. B. `10.30.224.1`. Prüfen mit:

```bash
ip route | grep "via.*eduVPN"
```

Im Folgenden verwenden wir Platzhalter: `<ZIEL_IP>` (z. B. `10.1.20.25`), `<ZIEL_NETZ>` (z. B. `10.1.0.0/16`), `<VPN_GW>` (z. B. `10.30.224.1`).

---

## 5. Route setzen — nur Ziel-Netz über VPN

### Variante A — einzelner Host

```bash
sudo ip route add <ZIEL_IP> via <VPN_GW> dev eduVPN
```

### Variante B — ganzes Subnetz (empfohlen)

```bash
sudo ip route add <ZIEL_NETZ> via <VPN_GW> dev eduVPN
```

Beispiel:

```bash
sudo ip route add 10.1.0.0/16 via 10.30.224.1 dev eduVPN
```

### Wenn die Route bereits existiert

```bash
ip route show | grep <ZIEL_IP>

# Vorhandene Route entfernen
sudo ip route del <ZIEL_IP>

# Neu setzen
sudo ip route add <ZIEL_IP> via <VPN_GW> dev eduVPN
```

---

## 6. Standard-Route korrigieren (falls VPN alles übernommen hat)

Wenn dein gesamtes Internet durchs VPN läuft, hat der eduVPN-Client eine Default-Route gesetzt. Diese musst du entfernen, damit nur noch die spezifischen Routen aus Abschnitt 5 durchs VPN gehen.

```bash
# Aktuelle Default-Routen anzeigen
ip route | grep default

# VPN-Default-Route entfernen
sudo ip route del default dev eduVPN
```

Falls das mit `RTNETLINK answers: No such process` fehlschlägt, ist die Route mit einem spezifischen Gateway eingetragen — dann mit Gateway entfernen:

```bash
sudo ip route del default via <VPN_GW> dev eduVPN
```

Verifizieren:

```bash
ip route | grep default
# Sollte nur noch die normale Default-Route über dein WLAN/LAN zeigen
```

> **Achtung:** Diese Änderung gilt nur bis zum nächsten VPN-Reconnect oder Neustart. Der eduVPN-Client setzt die Default-Route bei jeder Verbindung neu. Für eine dauerhafte Lösung Abschnitt 8.

---

## 7. Verifizieren

### Geht der Ziel-Traffic übers VPN?

```bash
ip route get <ZIEL_IP>
```

Erwartete Ausgabe:

```
<ZIEL_IP> via <VPN_GW> dev eduVPN src 10.30.224.7
```

### Geht der Rest direkt?

```bash
ip route get 1.1.1.1
```

Erwartet: `via <DEIN_LOKALES_GATEWAY> dev <DEINE_NETZWERKKARTE>` — also **nicht** über `eduVPN`.

### Ping-Test über das VPN

```bash
ping -I eduVPN <ZIEL_IP>
```

`-I` zwingt den Ping auf das VPN-Interface. Antworten = Tunnel funktioniert.

### Externe IP-Prüfung

```bash
curl ifconfig.me
```

Sollte deine normale Provider-IP zeigen (nicht die der Hochschule).

---

## 8. Dauerhaft machen (systemd-Service)

`ip route`-Befehle leben nur in der aktuellen Session. Für persistente Konfiguration ein systemd-Skript anlegen, das nach VPN-Verbindung läuft.

### 8.1 Hilfsskript anlegen

```bash
sudo nano /usr/local/bin/eduvpn-split-route.sh
```

Inhalt:

```bash
#!/usr/bin/env bash
set -euo pipefail

INTERFACE="eduVPN"
TARGET="<ZIEL_NETZ>"      # z. B. 10.1.0.0/16
GATEWAY="<VPN_GW>"        # z. B. 10.30.224.1

# Wait for the VPN interface to appear (max 30s)
for _ in {1..30}; do
    if ip link show "$INTERFACE" &>/dev/null; then
        break
    fi
    sleep 1
done

if ! ip link show "$INTERFACE" &>/dev/null; then
    echo "[eduvpn-split-route] $INTERFACE not available — aborting." >&2
    exit 1
fi

# Remove default route through VPN, if present
ip route del default dev "$INTERFACE" 2>/dev/null || true

# Set targeted route (idempotent)
ip route replace "$TARGET" via "$GATEWAY" dev "$INTERFACE"

echo "[eduvpn-split-route] Route to $TARGET via $GATEWAY on $INTERFACE set."
```

Ausführbar machen:

```bash
sudo chmod +x /usr/local/bin/eduvpn-split-route.sh
```

> **Warum `ip route replace` statt `ip route add`?** `replace` ist idempotent — wirft keinen Fehler, wenn die Route schon existiert.

### 8.2 systemd-Service anlegen

```bash
sudo nano /etc/systemd/system/eduvpn-split-route.service
```

Inhalt:

```ini
[Unit]
Description=Configure split-tunneling for eduVPN
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/eduvpn-split-route.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Aktivieren:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now eduvpn-split-route.service
```

Logs prüfen:

```bash
sudo systemctl status eduvpn-split-route.service
journalctl -u eduvpn-split-route.service -n 20
```

### 8.3 Manuell auslösen nach VPN-Reconnect

Wenn du das VPN trennst und wieder verbindest, die Route neu setzen:

```bash
sudo systemctl restart eduvpn-split-route.service
```

Alternative: Per `dispatcher`-Skript automatisch beim VPN-Up triggern (NetworkManager: `/etc/NetworkManager/dispatcher.d/`) — fortgeschrittener und distributionsabhängig, daher hier nicht ausgeführt.

---

## 9. Troubleshooting

### Service läuft, Route ist aber nicht gesetzt

Häufigste Ursache: VPN-Interface existiert beim Service-Start noch nicht. Das Skript aus 8.1 wartet bis zu 30 Sekunden — bei langsam aufbauenden Verbindungen den Timeout-Loop verlängern.

Manuell prüfen:

```bash
ip link show eduVPN
```

Wenn das Interface erst nach Login durch die GUI erscheint, kann ein systemd-Service beim Boot nicht greifen. Workaround: Service durch User-Session triggern oder NetworkManager-Dispatcher-Skript verwenden.

### `RTNETLINK answers: Network is unreachable`

Das angegebene VPN-Gateway ist von deinem System aus nicht erreichbar. Prüfen:

```bash
ip route | grep eduVPN
```

Existiert eine Route ins VPN-Subnetz? Falls nicht, ist der Tunnel halb-konfiguriert. eduVPN-GUI neu verbinden.

### `RTNETLINK answers: File exists`

Route ist schon gesetzt. Erst löschen, dann neu setzen — oder `ip route replace` statt `ip route add` verwenden.

### Internet weiterhin komplett über VPN

Default-Route durch VPN noch aktiv. Prüfen:

```bash
ip route | grep default
```

Falls dort `default ... dev eduVPN` steht: siehe Abschnitt 6.

### Externe IP zeigt Hochschul-Adresse, obwohl Route korrekt aussieht

Manche Anwendungen cachen DNS oder Verbindungen. Browser neu starten, `curl ifconfig.me` direkt im Terminal testen.

### Nach Neustart oder Reconnect ist alles weg

Das ist erwartet — `ip route`-Änderungen sind nicht persistent. Service aus Abschnitt 8 verwenden, oder Service nach jedem VPN-Connect manuell mit `systemctl restart` neu auslösen.

### VPN-Gateway-IP ändert sich

Manche eduVPN-Setups vergeben dynamische IPs. Wenn `<VPN_GW>` sich ändert, schlägt das Skript fehl. Robustere Variante: Gateway zur Laufzeit aus der Routing-Tabelle ableiten.

```bash
# Im Skript statt fester GATEWAY-Variable:
GATEWAY=$(ip route | awk '/dev eduVPN.*proto kernel/ {print $1}' | cut -d/ -f1 | awk -F. '{print $1"."$2"."$3".1"}')
```

(Beispielhaft — die exakte Logik hängt vom konkreten VPN-Setup ab.)

---

## Anhang: Cheatsheet

| Aufgabe | Befehl |
|---|---|
| Aktive VPN-Verbindungen anzeigen | `nmcli connection show --active` |
| VPN-Interface prüfen | `ip a \| grep eduVPN` |
| Default-Route prüfen | `ip route \| grep default` |
| Externe IP testen | `curl ifconfig.me` |
| Route für Host setzen | `sudo ip route add <ZIEL_IP> via <VPN_GW> dev eduVPN` |
| Route für Subnetz setzen | `sudo ip route add <ZIEL_NETZ> via <VPN_GW> dev eduVPN` |
| Route löschen | `sudo ip route del <ZIEL>` |
| VPN-Default-Route löschen | `sudo ip route del default dev eduVPN` |
| Routing-Pfad zu Ziel prüfen | `ip route get <ZIEL_IP>` |
| Ping über VPN-Interface | `ping -I eduVPN <ZIEL_IP>` |
| Service neu auslösen | `sudo systemctl restart eduvpn-split-route.service` |
| Service-Logs ansehen | `journalctl -u eduvpn-split-route.service -n 20` |
