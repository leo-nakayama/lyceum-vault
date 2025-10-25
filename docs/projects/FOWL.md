# FOWL - Fully Outsourced Wisdom Linkage

## What is it?

FOWL is my multi-machine lab: g16 (desktop), e14 (laptop), m900 (server), a00(observatory) that is based on my concept of "philosophy of systems". My focus of the architectual design is on Linux automation, backups, observatory (Grafana) as a platform of creative workflows. FOWL is based on my concept of "philosophy of systems".

## What it is not.

FOWL is not for owl, nor isn't a false owl. 

## Areas
- Storage tiers (hot/warm/cold), LVM, rsync/borg
- Samba + ACLs; remote access; CI/CD for home lab
- Music stack (LilyPond, Python Euclidean rhythms)
- DSL module runner (AWS, Python, OpenAI for philosophical modules)
- Observatory layer (Grafana, home LAN)

## Nodes
- 🐦‍🔥  Observatory
- 🐔 Storage & Backup
- 🐧Computation
- 🦆 Development

## Current FOWL Architecture

| **Layer / Aspect**              | **Role / Function**                                                                                                          | **Host(s)**                      | **Status**    | **Notes**                                                                                                    |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | -------------------------------- | ------------- | ------------------------------------------------------------------------------------------------------------ |
| 🐦‍🔥**a00 (Fedora server)**    | _Observatory Node_ — runs Prometheus (collector) and Grafana (visualization). Central metrics brain of the Lyceum ecosystem. | 192.168.1.x                      | ✅ Active      | SELinux adjusted for Grafana↔Prometheus. “Node Exporter Full” and “Prometheus 2.0 Stats” dashboards working. |
| 🐔**m900 ( RHEL server)**       | _Storage & Backup Tier_ — Borg + rsync tier; currently preparing for node_exporter service.                                  | 192.168.1.x                      | ⚠️ Partial    | Metrics exporter not yet responding on 9100; firewall & user setup pending.                                  |
| 🐧**g16 (Ubuntu desktop)**      | _Computation Node_ — GPU / AI inference and DSL experiments.                                                                 | 192.168.1.x                      | ✅ Active      | Node exporter connected and visible on Grafana. Serves as the main AI/ML execution node.                     |
| 🦆**e14 (Fedora laptop)**       | _Development Node_ — code editing, Python + DSL integration; handles local builds and CI staging.                            | 192.168.1.x                      | ✅ Active      | Node exporter connected. Acts as dev and local CI/CD workstation.                                            |
| **iPad Pro**                    | _Control / Visualization Surface_ — remote Grafana access, status viewing.                                                   | Dynamic (client)                 | ✅ Active      | Accesses Grafana dashboard via LAN. No telemetry agent (view-only).                                          |
| **Network Infrastructure**      | _LAN Backbone_ — 192.168.1.0/24 subnet; static IP mapping per node.                                                          | Home LAN                         | ✅ Stable      | Prometheus scrapes via IP:9100; firewall tuned per host; no mTLS yet.                                        |
| **Monitoring Stack**            | _Prometheus + Grafana_ — central observability + visualization framework.                                                    | a00                              | ✅ Operational | 15s scrape interval; dashboards imported (IDs 1860, 3662). SELinux and port labeling complete.               |
| **Philosophical Layer (Vault)** | _Knowledge Layer_ — Observation Reports, Aristotelian DSLs, philosophical reflection data.                                   | Lyceum Vault (GitHub + Obsidian) | ✅ Active      | Not yet annotated into Grafana timelines; forms conceptual input for Reflexivity Stage II.                   |
| **Security Context**            | _Access Control & Policy_ — SELinux, systemd hardening, SSH keys, firewall rules.                                            | All nodes                        | ✅ Tightened   | SELinux boolean for Grafana enabled; Prometheus port relabeled to `http_port_t`.                             |
| **Next Integration Target**     | _Unified Reflexive Loop_ — correlate Observation Reports with system metrics.                                                | Cross-system                     | 🚧 Planned    | Requires annotation layer (Grafana API or Loki) and m900 exporter fix.                                       |

## Notes
See related guides in **Notes**.
