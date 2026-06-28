hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize", opacity = "0.97 0.9" })

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

-- Force chromium-based browsers into a tile (workaround for --app)
hl.window_rule({
	match = { class = "^([cC]hrom(e|ium)|[bB]rave-browser|Microsoft-edge|Vivaldi-stable|[fF]irefox|zen|librewolf)$" },
	tile = true,
	opacity = "1.0 override 0.97 override",
})

-- Terminals
hl.window_rule({
	match = { class = "^(Alacritty|kitty|com.mitchellh.ghostty)$" },
	opacity = "1.0 override 1.0 override",
})

-- Steam
hl.window_rule({
	match = { class = "^([sS]team|[vV]esktop|[tT]idal)$", title = "^steam$" },
	tile = true,
	workspace = 11,
	opacity = "1.0 override 1.0 override",
})
hl.window_rule({
	match = { class = "^steam$", title = "^Friends List$" },
	float = true,
	size = { 460, 800 },
	workspace = 11,
})

-- Floating windows
hl.window_rule({
	match = {
		class = "^(xdg-desktop-portal-gtk|"
			.. "sublime_text|DesktopEditors|"
			.. "org.gnome.Nautilus|blueberry.py|"
			.. "Impala|Wiremix|org.gnome.NautilusPreviewer|"
			.. "com.gabm.satty|Omarchy|About|TUI.float)$",
		title = "^(Open.*Files?|Open [Ff]older.*|Save.*Files?|Save.*As|Save|All Files)$",
	},
	float = true,
	center = true,
	size = { 800, 600 },
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
hl.window_rule({
	match = { class = "^(cs2|[eE]lden [rR]ing)" },
	immediate = true,
	fullscreen_state = "2",
	content = "game",
	opacity = "1.0 override 1.0 override",
	focus_on_activate = true,
	no_anim = true,
	no_blur = true,
	no_dim = true,
	render_unfocused = true,
})

-- Layer rule: no animation for hyprshot selection
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })
