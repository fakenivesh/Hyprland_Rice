-- auto start
authentication = "systemctl --user start hyprpolkitagent"
bar = "waybar"
wallpaper = "hyprpaper"
lockscreen = "hypridle"
Notification = "dunst"
Clipboard = "wl-paste --type text --watch cliphist store"

hl.on("hyprland.start", function()
	hl.exec_cmd(authentication)
	hl.exec_cmd(bar)
	hl.exec_cmd(wallpaper)
	hl.exec_cmd(lockscreen)
	hl.exec_cmd(Notification)
	hl.exec_cmd(Clipboard)
end)
