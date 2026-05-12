local mainMod = "SUPER + "

local scripts = "$HOME/.config/hypr/scripts"

-- Application bindings
local terminal = "ghostty"
local browser = "brave --disable-features=WaylandWpColorManagerV1"
local music = "tidal-hifi"
local fileManager = "thunar"
local pwManager = "bitwarden-desktop "

-- local curMonitor = "$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')"
local swayosdcmd = "swayosd-client --monitor \"$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')\""

-- .. hl.get_active_monitor()
local maxvolume = "150"

hl.bind(mainMod .. "RETURN", hl.dsp.exec_cmd(terminal), { description = "Open Terminal" })
hl.bind(mainMod .. "F", hl.dsp.exec_cmd(fileManager), { description = "File Manager" })
hl.bind(mainMod .. "B", hl.dsp.exec_cmd(browser), { desc = "Browser" })
hl.bind(mainMod .. "SHIFT + B", hl.dsp.exec_cmd(browser .. " --incognito"), { desc = "private Browser" })
hl.bind(mainMod .. "M", hl.dsp.exec_cmd(music), { description = "Music Player" })
hl.bind(mainMod .. "O", hl.dsp.exec_cmd("obsidian -disable-gpu"))
hl.bind(mainMod .. "SLASH", hl.dsp.exec_cmd(pwManager), { description = "PasswordManager" })

hl.bind(
	mainMod .. "D",
	hl.dsp.exec_cmd(
		"pkill rofi || true && rofi -show drun -drun-match-fields name -modi drun,filebrowser,run,window # Main Menu (APP Launcher)"
	)
)
-- exit Hyprland
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("hyprctl dispatch exit 0"))
-- close active (not kill)
hl.bind(mainMod .. "Q", hl.dsp.window.close())
--  Kill active process
hl.bind(
	mainMod .. "SHIFT + Q",
	hl.dsp.exec_cmd("kill \"$(hyprctl activewindow | grep -o 'pid: [0-9]*' | cut -d' ' -f2)\"")
)

-- swayNC notification panel
hl.bind(mainMod .. "SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"))

hl.bind(mainMod .. "CTRL + ALT + M", hl.dsp.exit(), { description = "Exit Hyprland" })

hl.bind(mainMod .. "SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" })) -- whole full screen
hl.bind(mainMod .. "CTRL + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })) -- fake full screen
hl.bind(mainMod .. "SPACE", hl.dsp.window.float({ action = "toggle" })) -- toggle float screen

hl.bind(mainMod .. "SHIFT + S", hl.dsp.exec_cmd(scripts .. "/ScreenShot.sh --swappy"))
hl.bind(mainMod .. "SHIFT + R", hl.dsp.exec_cmd(scripts .. "/Refresh.sh"))
hl.bind("CTRL + ALT + P", hl.dsp.exec_cmd("wlogout --protocol layer-shell -b 2"))
hl.bind("CTRL + ALT + L", hl.dsp.exec_cmd("hyprlock"))

-- Dwindle Layout
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

-- Scroll through existing workspaces with mainMod + scroll
-- hl.bind(mainMod .. "mouse_down", hl.dsp.focus({ workspace = "e+1" }))
-- hl.bind(mainMod .. "mouse_up", hl.dsp.focus({ workspace = "e-1" }))
-- hl.bind(mainMod .. "period", hl.dsp.focus({ workspace = "e+1" }))
-- hl.bind(mainMod .. "comma", hl.dsp.focus({ workspace = "e-1" }))

-- media control
-- hl.bind("XF86AudioPlayPause", hl.dsp.exec_cmd(swayosdcmd .. " --playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(swayosdcmd .. " --playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(swayosdcmd .. " --playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(swayosdcmd .. " --playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(swayosdcmd .. " --playerctl previous"), { locked = true })
hl.bind("XF86Audiostop", hl.dsp.exec_cmd(swayosdcmd .. " --playerctl stop"), { locked = true })
-- brightness
hl.bind("XF86monbrightnessup", hl.dsp.exec_cmd(swayosdcmd .. "--brightness raise"), { repeating = true, locked = true })
hl.bind(
	"XF86monbrightnessdown",
	hl.dsp.exec_cmd(swayosdcmd .. "--brightness lower"),
	{ repeating = true, locked = true }
)

-- volume
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(swayosdcmd .. " --output-volume raise --max-volume " .. maxvolume),
	{ repeating = true, locked = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd(swayosdcmd .. " --output-volume lower --max-volume " .. maxvolume),
	{ repeating = true, locked = true }
)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(swayosdcmd .. " --input-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(swayosdcmd .. " --output-volume mute-toggle"), { locked = true })
