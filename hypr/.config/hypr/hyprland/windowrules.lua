-- Suppress maximize everywhere
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Default opacity
hl.window_rule({ match = { class = ".*" }, opacity = "0.97 0.9" })

-- Privacy & Media: force full opacity
hl.window_rule({
	match = {
		class = "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$",
	},
	opacity = "1.0 override 1.0 override",
})
hl.window_rule({
	match = { class = "^(org.remmina.Remmina)$" },
	opacity = "1.0 override 1.0 override",
})

-- Video sites (title-based)
hl.window_rule({
	match = { title = ".*(YouTube|Zoom|Twitch).*" },
	opacity = "1.0 override 1.0 override",
})

-- Browser tags
hl.window_rule({
	match = { class = "^([cC]hrom(e|ium)|[bB]rave-browser|Microsoft-edge|Vivaldi-stable)$" },
	tag = "+chromium-browser",
})
hl.window_rule({
	match = { class = "^([fF]irefox|zen|librewolf)$" },
	tag = "+firefox-browser",
})

-- Force chromium-based browsers into a tile (workaround for --app)
hl.window_rule({ match = { tag = "chromium-browser" }, tile = true })

-- Subtle opacity for browsers
hl.window_rule({ match = { tag = "chromium-browser" }, opacity = "1.0 override 0.97 override" })
hl.window_rule({ match = { tag = "firefox-browser" }, opacity = "1.0 override 0.97 override" })

-- Video pages should never be translucent
hl.window_rule({
	match = { initial_title = "(?i)(youtube|zoom)" },
	opacity = "1.0 override 1.0 override",
})

-- Terminals
hl.window_rule({
	match = { class = "^(Alacritty|kitty|com.mitchellh.ghostty)$" },
	tag = "+terminal",
})
hl.window_rule({ match = { tag = "terminal" }, opacity = "1.0 override 1.0 override" })

-- Steam
hl.window_rule({ match = { class = "^steam$", title = "^steam$" }, tile = true })
hl.window_rule({ match = { class = "^steam$", title = "^Friends List$" }, size = { 460, 800 } })
hl.window_rule({ match = { class = "^steam$" }, opacity = "1.0 override 1.0 override" })

-- Floating windows: apply behavior by tag
hl.window_rule({ match = { tag = "floating-window" }, float = true })
hl.window_rule({ match = { tag = "floating-window" }, center = true })
hl.window_rule({ match = { tag = "floating-window" }, size = { 800, 600 } })

-- Tag floating windows
hl.window_rule({
	match = {
		class = "^(blueberry.py|Impala|Wiremix|org.gnome.NautilusPreviewer|com.gabm.satty|Omarchy|About|TUI.float)$",
	},
	tag = "+floating-window",
})
hl.window_rule({
	match = {
		class = "^(xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.gnome.Nautilus)$",
		title = "^(Open.*Files?|Open [Ff]older.*|Save.*Files?|Save.*As|Save|All Files)$",
	},
	tag = "+floating-window",
})

-- Fullscreen screensaver
hl.window_rule({ match = { class = "^Screensaver$" }, fullscreen = true })

-- xwaylandvideobridge: hide completely
hl.window_rule({
	match = { class = "^xwaylandvideobridge$" },
	no_initial_focus = true,
	no_focus = true,
	no_anim = true,
	no_blur = true,
	opacity = "0.0 override 0.0 override",
	max_size = { 1, 1 },
	min_size = { 1, 1 },
	move = { 99999, 99999 },
})

-- CS2: immediate (tearing allowed)
hl.window_rule({ match = { class = "cs2" }, immediate = true })

-- Layer rule: no animation for hyprshot selection
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })
