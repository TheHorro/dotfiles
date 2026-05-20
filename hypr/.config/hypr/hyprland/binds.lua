local mainMod = "SUPER + "

-- Application bindings
local terminal = "ghostty"
local browser = "brave --disable-features=WaylandWpColorManagerV1"
local music = "tidal-hifi"
local fileManager = "thunar"
local pwManager = "bitwarden-desktop "

hl.bind(mainMod .. "RETURN", hl.dsp.exec_cmd(terminal), { desc = "Open Terminal" })
hl.bind(mainMod .. "F", hl.dsp.exec_cmd(fileManager), { desc = "File Manager" })
hl.bind(mainMod .. "B", hl.dsp.exec_cmd(browser), { desc = "Browser" })
hl.bind(mainMod .. "SHIFT + B", hl.dsp.exec_cmd(browser .. " --incognito"), { desc = "private Browser" })
hl.bind(mainMod .. "M", hl.dsp.exec_cmd(music), { desc = "Music Player" })
hl.bind(mainMod .. "O", hl.dsp.exec_cmd("obsidian -disable-gpu"), { desc = "Obsidian" })
hl.bind(mainMod .. "SLASH", hl.dsp.exec_cmd(pwManager), { desc = "PasswordManager" })

hl.bind(
	mainMod .. "D",
	hl.dsp.exec_cmd("pkill rofi || true && rofi -show drun -drun-match-fields name -modi drun,filebrowser,run,window"),
	{ desc = "Main Menu (APP Launcher)" }
)
hl.bind("CTRL + ALT + Delete", hl.dsp.exit(), { desc = "exit Hyprland" }) -- hl.dsp.exec_cmd("hyprctl dispatch exit 0")
hl.bind(mainMod .. "Q", hl.dsp.window.close(), { desc = "close focused window" })
hl.bind(mainMod .. "SHIFT + Q", function()
	hl.dispatch(hl.dsp.exec_cmd("kill -9 " .. hl.get_active_window().pid))
end, { desc = "kill focused window" })

hl.bind(mainMod .. "SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"), { desc = "Open swayNc-Notification Panel" })

hl.bind(mainMod .. "CTRL + ALT + M", hl.dsp.exit(), { description = "Exit Hyprland" })

hl.bind(
	mainMod .. "SHIFT + F",
	hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle", desc = "toggle read fullscreen" })
)
hl.bind(
	mainMod .. "CTRL + F",
	hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle", desc = "toggle fake fullscreen" })
)
hl.bind(mainMod .. "SPACE", hl.dsp.window.float({ action = "toggle" })) -- toggle float screen

hl.bind(mainMod .. "SHIFT + S", hl.dsp.exec_cmd("hyprscreen screenshot area"))
hl.bind(mainMod .. "SHIFT + R", function()
	local wallpaper = os.getenv("HOME") .. "/.config/hypr/wallpapers/green-room.jpg"

	os.execute("kill -9 $(pidof waybar rofi hyprpaper swaync swayosd-server)")

	os.execute("matugen image " .. wallpaper)

	os.execute("sleep 1 && waybar &")
	os.execute("swaync > /dev/null 2>&1 &")
	os.execute("swayosd-server &")
	os.execute("hyprpaper &")
end)
hl.bind("CTRL + ALT + P", hl.dsp.exec_cmd("wlogout --protocol layer-shell -b 2"))
hl.bind("CTRL + ALT + L", hl.dsp.exec_cmd("hyprlock"))

hl.bind(mainMod .. "SHIFT + T", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. "CTRL + T", hl.dsp.layout("swapsplit"))

local dirs = { h = "left", j = "down", k = "up", l = "right" }
for key, dir in pairs(dirs) do
	hl.bind(mainMod .. key, hl.dsp.focus({ direction = dir }), { desc = "change focus" })
	hl.bind(mainMod .. "CTRL + " .. key, hl.dsp.window.move({ direction = dir }), { desc = "move window" })
	hl.bind(mainMod .. "ALT + " .. key, hl.dsp.window.swap({ direction = dir }), { desc = "swap window" })
end

-- resize window
hl.bind(mainMod .. "SHIFT + H", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. "SHIFT + J", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. "SHIFT + K", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })
hl.bind(mainMod .. "SHIFT + L", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. "mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. "mouse:273", hl.dsp.window.resize(), { mouse = true })

-- select workspace

for i = 1, 10 do
	local key = i % 10 -- i = 10 -> key = 0
	hl.bind(mainMod .. tostring(key), function()
		local curMon = hl.get_active_monitor()
		if curMon ~= nil then
			if curMon.name == "DP-3" then
				hl.dispatch(hl.dsp.focus({ workspace = i + 10 }))
			else
				hl.dispatch(hl.dsp.focus({ workspace = i }))
			end
		end
	end)

	hl.bind(mainMod .. " SHIFT + " .. tostring(key), function()
		local curMon = hl.get_active_monitor()
		if curMon ~= nil then
			if curMon.name == "DP-3" then
				hl.dispatch(hl.dsp.window.move({ workspace = i + 10, follow = false }))
			else
				hl.dispatch(hl.dsp.window.move({ workspace = i, follow = false }))
			end
		end
	end)
end

-- local swayosdcmd = "swayosd-client --monitor " .. hl.get_active_monitor().name
local maxvolume = "150"

-- media control
hl.bind("XF86AudioPause", function()
	hl.dispatch(
		hl.dsp.exec_cmd("swayosd-client --monitor " .. hl.get_active_monitor().name .. " --playerctl play-pause")
	)
end, { locked = true, desc = "toggle PlayPause" })

hl.bind("XF86AudioPlay", function()
	hl.dispatch(
		hl.dsp.exec_cmd("swayosd-client --monitor " .. hl.get_active_monitor().name .. " --playerctl play-pause")
	)
end, { locked = true, desc = "toggle PlayPause" })
hl.bind("XF86AudioNext", function()
	hl.dispatch(hl.dsp.exec_cmd("swayosd-client --monitor " .. hl.get_active_monitor().name .. " --playerctl next"))
end, { locked = true, desc = "Next Track" })
hl.bind("XF86AudioPrev", function()
	hl.dispatch(hl.dsp.exec_cmd("swayosd-client --monitor " .. hl.get_active_monitor().name .. " --playerctl previous"))
end, { locked = true, desc = "Previous Track" })
hl.bind("XF86Audiostop", function()
	hl.dispatch(hl.dsp.exec_cmd("swayosd-client --monitor " .. hl.get_active_monitor().name .. " --playerctl stop"))
end, { locked = true, desc = "Stop Media" })

-- brightness
hl.bind("XF86monbrightnessup", function()
	hl.dispatch(hl.dsp.exec_cmd("swayosd-client --monitor " .. hl.get_active_monitor().name .. " --brightness +5"))
end, { repeating = true, locked = true, desc = "Brightness up" })
hl.bind("XF86monbrightnessdown", function()
	hl.dispatch(hl.dsp.exec_cmd("swayosd-client --monitor " .. hl.get_active_monitor().name .. " --brightness -5"))
end, { repeating = true, locked = true, desc = "Brightness down" })

-- volume
hl.bind("XF86AudioRaiseVolume", function()
	hl.dispatch(
		hl.dsp.exec_cmd(
			"swayosd-client --monitor "
				.. hl.get_active_monitor().name
				.. " --output-volume +5 --max-volume "
				.. maxvolume
		)
	)
end, { repeating = true, locked = true, desc = "Volume up" })
hl.bind("XF86AudioLowerVolume", function()
	hl.dispatch(
		hl.dsp.exec_cmd(
			"swayosd-client --monitor "
				.. hl.get_active_monitor().name
				.. " --output-volume -5 --max-volume "
				.. maxvolume
		)
	)
end, { repeating = true, locked = true, desc = "Volume down" })
hl.bind("XF86AudioMicMute", function()
	hl.dispatch(
		hl.dsp.exec_cmd("swayosd-client --monitor " .. hl.get_active_monitor().name .. " --input-volume mute-toggle")
	)
end, { locked = true, desc = "Toggle Mic" })
hl.bind("XF86AudioMute", function()
	hl.dispatch(
		hl.dsp.exec_cmd("swayosd-client --monitor " .. hl.get_active_monitor().name .. " --output-volume mute-toggle")
	)
end, { locked = true, desc = "Toggle Audio" })
