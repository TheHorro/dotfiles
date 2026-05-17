hl.on("hyprland.start", function()
	hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("swayosd-server")
	hl.exec_cmd("waybar")
	hl.exec_cmd("swaync")
	hl.exec_cmd("xwaylandvideobridge")
	hl.exec_cmd("nextcloud --background")
	hl.exec_cmd("nm-applet")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-- monitor options
hl.monitor({
	output = "*",
	mode = "preferred",
	position = "auto",
	transform = 1,
})

hl.monitor({
	output = "DP-2",
	mode = "3440x1440@165.0",
	position = "0x1440",
	scale = 1,
	bitdepth = 10,
	cm = "srgb",
})

hl.monitor({
	output = "DP-3",
	mode = "2560x1440@165.0",
	position = "440x0",
	scale = 1,
	bitdepth = 10,
	cm = "srgb",
	transform = 2,
})

hl.monitor({
	output = "eDP-1",
	mode = "2560x1600@60.0",
	position = "0x0",
	scale = "1.0",
	bitdepth = 10,
	cm = "srgb",
})

-- workspace assignment
local curMon = hl.get_active_monitor()
if curMon ~= nil then
	if curMon.name == "DP-2" or curMon.name == "DP-3" then
		-- mainPC config
		for i = 1, 10 do
			hl.workspace_rule({ workspace = tostring(i), monitor = "DP-2" })
			hl.workspace_rule({ workspace = tostring(i + 10), monitor = "DP-3" })
		end
	elseif curMon.name == "eDP-1" or curMon.name == "HDMI-A-1" then
		-- laptop config
		for i = 1, 10 do
			hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1" })
			hl.workspace_rule({ workspace = tostring(i + 10), monitor = "HDMI-A-1" })
		end
	end
end

-- Toolkit Backend
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland,x11,windows")
hl.env("CLUTTER_BACKEND", "wayland")

-- XDG Specifications
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Qt
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QUICK_CONTROLS_STYLE", "org.hyprland.style")
hl.env("QT_STYLE_OVERRIDE", "kvantum")

hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")

hl.env("XCOMPOSEFILE", "~/.XCompose")
hl.env("HYPRCURSOR_SIZE", "24")
