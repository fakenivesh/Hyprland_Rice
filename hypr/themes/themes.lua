-- Select a theme from themes/themes and link its configs into the locations
-- expected by Waybar, Dunst, hyprpaper, and hypridle.

local home = assert(os.getenv("HOME"), "HOME is not set")
local config = home .. "/.config/hypr"
local themes_dir = config .. "/themes/themes"

local function shell_quote(value)
	return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function run(command)
	local ok, why, code = os.execute(command)
	if ok == true or ok == 0 then
		return true
	end
	return nil, (why or "command failed") .. (code and (" (" .. code .. ")") or "")
end

local list = io.popen("find " .. shell_quote(themes_dir) .. " -mindepth 1 -maxdepth 1 -type d -printf '%f\\n' | sort", "r")
if not list then
	io.stderr:write("Could not list theme folders in " .. themes_dir .. "\n")
	os.exit(1)
end

local themes = {}
for name in list:lines() do
	if not name:find("[\r\n]") then
		themes[#themes + 1] = name
	end
end
list:close()

if #themes == 0 then
	io.stderr:write("No theme folders found in " .. themes_dir .. "\n")
	os.exit(1)
end

-- Reject newline-containing names because hyprlauncher's dmenu input is
-- newline-delimited.
local menu_lines = {}
local available = {}
for _, name in ipairs(themes) do
	if not name:find("[\r\n]") then
		menu_lines[#menu_lines + 1] = name
		available[name] = true
	end
end
if #menu_lines == 0 then
	io.stderr:write("No usable theme folder names found\n")
	os.exit(1)
end

local menu = "printf '%s\\n' "
for _, name in ipairs(menu_lines) do
	menu = menu .. shell_quote(name) .. " "
end
menu = menu .. "| hyprlauncher --dmenu"

local picker = io.popen(menu, "r")
if not picker then
	io.stderr:write("Could not start hyprlauncher\n")
	os.exit(1)
end
local selected = picker:read("*l")
picker:close()

if not selected or not available[selected] then
	-- Closing the launcher without choosing a theme is a normal cancellation.
	os.exit(0)
end

local theme_dir = themes_dir .. "/" .. selected
local links = {
	{ source = theme_dir .. "/waybar", target = home .. "/.config/waybar", kind = "directory" },
	{ source = theme_dir .. "/dunst", target = home .. "/.config/dunst", kind = "directory" },
	{ source = theme_dir .. "/hyprpaper.conf", target = config .. "/hyprpaper.conf", kind = "file" },
	{ source = theme_dir .. "/hypridle.conf", target = config .. "/hypridle.conf", kind = "file" },
}

-- Validate everything before changing any links, so a partial theme is not
-- applied.
for _, link in ipairs(links) do
	local check = link.kind == "directory" and "test -d " or "test -f "
	local ok = run(check .. shell_quote(link.source))
	if not ok then
		io.stderr:write("Theme '" .. selected .. "' is missing required " .. link.kind .. ": " .. link.source .. "\n")
		os.exit(1)
	end
	local target_ok = run("test ! -e " .. shell_quote(link.target) .. " || test -L " .. shell_quote(link.target))
	if not target_ok then
		io.stderr:write("Refusing to replace a non-symlink at " .. link.target .. "\n")
		os.exit(1)
	end
end

for _, link in ipairs(links) do
	local ok, err = run("ln -sfnT " .. shell_quote(link.source) .. " " .. shell_quote(link.target))
	if not ok then
		io.stderr:write("Could not link " .. link.target .. ": " .. err .. "\n")
		os.exit(1)
	end
end

print("Applied theme: " .. selected)
