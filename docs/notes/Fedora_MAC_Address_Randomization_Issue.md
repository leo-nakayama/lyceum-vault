---
title: Fedora MAC Address Randomization Issue
date: 2025-10-21
tags:
  - Fedora
  - NetworkManager
  - MAC
  - SSH
  - LyceumNotes
---

# 🧠 Fedora MAC Address Randomization — Troubleshooting Log

**Context:**  
While connecting from `g16` (Kubuntu) to `e14` (Fedora) via SSH,  
the e14 host became unreachable at its usual IP (`192.168.1.12`).  
Investigation revealed Fedora’s default **MAC randomization** caused a new IP (`192.168.1.15`)  
to be assigned, breaking router DHCP binding and SSH connectivity.

---

## 🧩 1. Symptoms

| Command | Result | Interpretation |
|----------|---------|----------------|
| `ping e14` (from g16) | `Destination Host Unreachable` | No route to previous IP |
| `nslookup e14` | `192.168.1.12` | Name resolution still cached |
| `ssh leo@e14` | `No route to host` | TCP unreachable |
| `ip addr show wlp3s0` (on e14) | `link/ether 0a:8c:57:a9:8b:ad permaddr aa:aa:aa:aa:aa:aaf` | Randomized MAC detected |

**Root Cause:**  
Fedora’s `NetworkManager` uses a randomized Wi-Fi MAC address each connection  
(`wifi.cloned-mac-address=random`), invalidating the router’s static IP binding.

---

## ⚙️ 2. Corrective Actions

### Step 1 — Disable Random MAC for the Wi-Fi Connection

```bash
nmcli connection show
sudo nmcli connection modify "<SSID>" 802-11-wireless.cloned-mac-address permanent
sudo nmcli connection down "<SSID>"
sudo nmcli connection up "<SSID>"
````

Verify:

```bash
ip link show wlp3s0
```

✅ You should now see the **hardware MAC**.

---

### Step 2 — Optional Global Policy (for all Wi-Fi)

Create `/etc/NetworkManager/conf.d/10-disable-wifi-random.conf`:

```ini
[device]
wifi.scan-rand-mac-address=no

[connection]
wifi.cloned-mac-address=permanent
```

Reload:

```bash
sudo systemctl restart NetworkManager
```

---

### Step 3 — Restore Router Binding

On your router, bind:

```
aa:aa:aa:aa:aa:aa → 192.168.1.12
```

This ensures the IP stays fixed across reboots and OS reinstalls.

---

## 🧰 3. Verification Script: `check-mac.sh`

A utility script to verify if Fedora is still using a randomized MAC.

```bash
#!/usr/bin/env bash
iface="${1:-wlp3s0}"

if ! ip link show "$iface" &>/dev/null; then
  echo "❌ Interface '$iface' not found."; exit 1; fi

active_mac=$(ip -o link show "$iface" | awk '{print $17}')
perm_mac=$(ip -o link show "$iface" | grep -o 'permaddr [0-9a-f:]*' | awk '{print $2}')
[ -z "$perm_mac" ] && perm_mac=$(sudo ethtool -P "$iface" 2>/dev/null | awk '{print $3}')

echo "🧠 Interface:  $iface"
echo "🔹 Active MAC: $active_mac"
echo "🔸 Permanent:  $perm_mac"

if [ "$active_mac" != "$perm_mac" ]; then
  echo "🚨 Warning: active MAC differs — randomization is still active!"
  echo "👉 Run: nmcli connection modify \"<SSID>\" 802-11-wireless.cloned-mac-address permanent"
else
  echo "✅ OK: active MAC matches hardware MAC."
fi
```

---

## 🔍 4. Verification Flow

| Step         | Command                                  | Expected Result           |
| ------------ | ---------------------------------------- | ------------------------- |
| Check MACs   | `check-mac.sh wlp3s0`                    | Same active/permanent MAC |
| Router lease | `grep e14 /var/lib/dhcp/dhclient*.lease` | Confirms 192.168.1.12     |
| Ping test    | `ping -c 4 e14`                          | Replies successfully      |
| SSH test     | `ssh leo@e14`                            | Connects without issue    |

---

## 💡 Reflection (Lyceum Notes)

* **Material Cause (M):** Fedora Wi-Fi hardware with MAC randomization feature
* **Formal Cause (F):** NetworkManager configuration rules and router DHCP bindings
* **Efficient Cause (E):** Fedora default privacy setting altering MAC per session
* **Final Cause (T):** Restoring network stability and predictable SSH routing

> **Observation:**
> Modern OS defaults emphasize privacy (randomized MACs) over LAN persistence.
> In controlled lab environments like the **Lyceum Home Lab**, predictability outweighs anonymity —
> thus disabling MAC randomization aligns with system telos: *“stable reflective connectivity.”*

---

✅ **Outcome:**

* e14 now consistently reports its hardware MAC.
* Router rebinds static IP `192.168.1.12`.
* g16 ↔ e14 SSH restored.
* Verified using `check-mac.sh`.

---
