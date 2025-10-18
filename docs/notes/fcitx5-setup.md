
# Fcitx5 Setup (KDE/Ubuntu Quick Notes)

## Steps
1. Install: `sudo apt install fcitx5 fcitx5-mozc`  
2. Set input method: `im-config -n fcitx5` (logout/login)  
3. Ensure env:
    ```bash
    echo $XMODIFIERS
    echo $GTK_IM_MODULE
    echo $QT_IM_MODULE
    ```
4. Autostart if needed: `~/.config/autostart/fcitx5.desktop`

## Troubleshooting
- If tray icon missing: verify `fcitx5` is installed and running
- Wayland notes: prefer recent KDE Plasma versions
