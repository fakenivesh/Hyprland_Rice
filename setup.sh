#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$REPO_DIR/hypr"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_ROOT="$HOME/.config-backups/hyprland-rice-$(date +%Y%m%d-%H%M%S)"

if [[ ! -d "$SOURCE_DIR" ]]; then
	echo "Could not find the hypr config directory at: $SOURCE_DIR" >&2
	exit 1
fi

if [[ $EUID -eq 0 ]]; then
	echo "Run this script as your normal user; it will request sudo only for package installation." >&2
	exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
	echo "sudo is required to install packages. Install dependencies manually and rerun." >&2
	exit 1
fi

install_packages() {
	local packages=(hyprland hyprland-lua waybar dunst hyprpaper hypridle hyprlock hyprpolkitagent kitty dolphin hyprlauncher wl-clipboard cliphist brightnessctl playerctl wireplumber lua)
	if command -v pacman >/dev/null 2>&1; then
		sudo pacman -S --needed -- "${packages[@]}"
	else
		cat >&2 <<'EOF'
Automatic package installation currently supports Arch Linux (pacman).
Install these packages with your distribution's package manager, then rerun:
  hyprland hyprland-lua waybar dunst hyprpaper hypridle hyprlock
  hyprpolkitagent kitty dolphin hyprlauncher wl-clipboard cliphist
  brightnessctl playerctl wireplumber lua
EOF
		exit 1
	fi
}

backup_path() {
	local target="$1"
	if [[ -e "$target" || -L "$target" ]]; then
		local relative="${target#"$HOME"/}"
		mkdir -p "$BACKUP_ROOT/$(dirname -- "$relative")"
		mv -- "$target" "$BACKUP_ROOT/$relative"
	fi
}

install_packages

# Preserve the existing Hyprland tree, including files unknown to this installer.
if [[ -e "$CONFIG_HOME/hypr" || -L "$CONFIG_HOME/hypr" ]]; then
	backup_path "$CONFIG_HOME/hypr"
fi

mkdir -p "$CONFIG_HOME"
ln -s "$SOURCE_DIR" "$CONFIG_HOME/hypr"

# The selected theme supplies these four runtime configs. Back up any
# standalone Waybar/Dunst configs before creating links into the default theme.
DEFAULT_THEME="$CONFIG_HOME/hypr/themes/themes/demo"
for pair in \
	"$DEFAULT_THEME/waybar:$CONFIG_HOME/waybar" \
	"$DEFAULT_THEME/dunst:$CONFIG_HOME/dunst" \
	"$DEFAULT_THEME/hyprpaper.conf:$CONFIG_HOME/hypr/hyprpaper.conf" \
	"$DEFAULT_THEME/hypridle.conf:$CONFIG_HOME/hypr/hypridle.conf"; do
	source="${pair%%:*}"
	target="${pair#*:}"
	if [[ ! -e "$source" ]]; then
		echo "Missing config source: $source" >&2
		exit 1
	fi
	if [[ -e "$target" || -L "$target" ]]; then
		backup_path "$target"
	fi
	ln -s "$source" "$target"
done

echo "Setup complete. Config installed at $CONFIG_HOME/hypr."
if [[ -d "$BACKUP_ROOT" ]]; then
	echo "Previous configs backed up to $BACKUP_ROOT"
fi
echo "Log out and select Hyprland from your display manager to start the session."
