# Hyprland Rice

Personal Hyprland configuration built with the `hyprland-lua` configuration system. It includes Waybar and Dunst themes, hyprpaper and hypridle settings, keybindings, and theme switching.

## Install

The setup script currently installs packages automatically on Arch Linux using `pacman`. It uses `sudo` for package installation and backs up an existing `~/.config/hypr`, `~/.config/waybar`, or `~/.config/dunst` before replacing it.

```bash
git clone https://github.com/fakenivesh/Hyprland_Rice.git
cd Hyprland_Rice
./setup.sh
```

The repository's `hypr` directory is linked to `~/.config/hypr`. The `demo` theme is activated initially. Existing configs are moved to `~/.config-backups/hyprland-rice-<timestamp>/`.

Log out and choose **Hyprland** in your display manager. You can switch themes with **Super+T** or by running:

```bash
lua ~/.config/hypr/themes/themes.lua
```

## Packages

The installer requests Hyprland and its Lua configuration support, Waybar, Dunst, hyprpaper, hypridle, hyprlock, hyprpolkitagent, Kitty, Dolphin, hyprlauncher, wl-clipboard, cliphist, brightnessctl, playerctl, WirePlumber, and Lua.

On other distributions, install the same packages with your package manager, then apply the config and theme links described in `setup.sh`.

## Keybindings

- **Super+Q**: terminal
- **Super+E**: file manager
- **Super+R**: application launcher
- **Super+C**: close focused window
- **Super+T**: choose a theme
- **Super+1–0**: switch workspace
- **Super+Shift+1–0**: move window to workspace
- **Super+Arrow keys**: change focus

Media, volume, brightness, floating, and workspace bindings are also configured in `hypr/core/keybindings.lua`.

## Notes

- Review and edit the monitor settings in `hypr/core/monitors.lua` for your displays.
- The terminal and file manager are set in `hypr/core/con.lua`.
- Add theme folders under `hypr/themes/themes/`. Each theme needs `waybar/`, `dunst/`, `hyprpaper.conf`, and `hypridle.conf`.
