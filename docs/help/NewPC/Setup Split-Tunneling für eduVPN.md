# Split-Tunneling für eduVPN: Nur Uni-Server über VPN, Internet Normal

Diese Anleitung beschreibt, wie du nur den Uni-Server über die VPN leitest, während dein restliches Internet über dein normales Netzwerk läuft.

---

## Schritt-für-Schritt-Anleitung

### 1. Prüfen, ob das VPN aktiv ist

Führe aus:

```bash
nmcli connection show --active
```

Falls `eduVPN` aktiv ist, fahre fort.

Alternativ:

```bash
ip a | grep eduVPN
```

Falls keine Ausgabe kommt, ist das VPN nicht verbunden.

---

### 2. Herausfinden, welches Netzwerk nur über die VPN erreichbar ist

1. Uni-Server IP ermitteln:

```bash
nslookup hhncl-smb02.hhn.hs-heilbronn.de
```

Falls eine private IP (`10.x.x.x`, `172.16.x.x`, `192.168.x.x`) zurückkommt, gehört sie zum Uni-Netz.

Beispiel:

```
Name: hhncl-smb02.hhn.hs-heilbronn.de
Address: 10.1.20.25
```

2. Prüfen, ob der gesamte Traffic über VPN läuft:

```bash
ip route | grep default
```

Falls nur `default via 192.168.x.x dev wlp0s20f3` erscheint, ist alles gut. Falls `default via 10.x.x.x dev eduVPN` erscheint, geht alles über VPN → weiter zu Schritt 4.

---

### 3. Route setzen, damit nur der Uni-Server über VPN läuft

```bash
sudo ip route add 10.1.20.25 via 10.30.224.4 dev eduVPN
```

Falls die Route bereits existiert:

```bash
ip route show | grep 10.1.20.25
sudo ip route del 10.1.20.25
```

Dann die Route erneut setzen.

---

### 4. Falls alles über VPN läuft: Standardroute korrigieren

Falls dein gesamtes Internet über die VPN läuft, entferne die Standardroute:

```bash
sudo ip route del default dev eduVPN
```

Falls das nicht geht, prüfe die VPN-Gateway-IP mit:

```bash
ip route | grep default
```

Falls dort `default via 10.30.224.1 dev eduVPN` steht, entferne sie mit:

```bash
sudo ip route del default via 10.30.224.1 dev eduVPN
```

---

### 5. Prüfen, ob der Uni-Server nur über die VPN läuft

```bash
ip route get 10.1.20.25
```

Falls die Ausgabe `via 10.30.224.4 dev eduVPN` enthält, funktioniert das Split-Tunneling.

Teste den Uni-Server:

```bash
ping -I eduVPN 10.1.20.25
```

Falls Pakete zurückkommen, ist die Verbindung über VPN aktiv.

---

### 6. Dauerhafte Route setzen (nach jedem Neustart automatisch)

**Option 1: `/etc/rc.local` (falls unterstützt)**

```bash
sudo nano /etc/rc.local
```

Füge vor `exit 0` hinzu:

```bash
ip route add 10.1.20.25 via 10.30.224.4 dev eduVPN
```

Speichern mit `CTRL+X`, `Y`, `Enter` und dann:

```bash
sudo chmod +x /etc/rc.local
```

**Option 2: `systemd`-Service (moderner Ansatz)**

```bash
sudo nano /etc/systemd/system/eduVPN-route.service
```

Füge ein:

```
[Unit]
Description=Set eduVPN route for Uni SMB Server
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/sbin/ip route add 10.1.20.25 via 10.30.224.4 dev eduVPN
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Dann:

```bash
sudo systemctl daemon-reload
sudo systemctl enable eduVPN-route.service
sudo systemctl restart eduVPN-route.service
```

---

## FAQ: Häufige Probleme & Lösungen

### Warum ging das VPN erst nach dem Start der eduVPN-GUI?

Das Interface `eduVPN` existiert erst, wenn die GUI läuft. Ohne GUI gibt es keine Verbindung, daher kann `systemd` die Route nicht setzen.

### Warum lief mein gesamtes Internet über die VPN?

Weil dein VPN eine Standardroute gesetzt hat. Die Lösung ist, die `default via eduVPN`-Route zu löschen:

```bash
sudo ip route del default dev eduVPN
```

### Wie überprüfe ich, ob mein Internet normal läuft?

```bash
curl ifconfig.me
```

Falls eine Uni-IP zurückkommt, läuft dein gesamtes Internet noch über die VPN. Falls deine normale Provider-IP erscheint, ist alles korrekt.

### Warum wird die Route nicht automatisch gesetzt?

`systemd` startet den Service zu früh. Lösung: Nutze ein Skript, das wartet, bis `eduVPN` existiert:

```bash
#!/bin/bash
sleep 15
if ip link show eduVPN &> /dev/null; then
    ip route add 10.1.20.25 via 10.30.224.4 dev eduVPN
fi
```

Speichern als `/usr/local/bin/set_vpn_route.sh`, ausführbar machen mit:

```bash
sudo chmod +x /usr/local/bin/set_vpn_route.sh
```

### Warum bekomme ich nach Neustart wieder die falsche Route?

Falls `eduVPN` eine neue IP bekommt, könnte sich die Route ändern. Prüfe mit:

```bash
ip route show | grep eduVPN
```

Falls nötig, passe `10.30.224.4` in der Route an.

---

Jetzt läuft nur dein Uni-Server über die VPN, der Rest des Internets bleibt normal.