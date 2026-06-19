local colors = require("colors")

hl.config({
	general = {
		gaps_in = 1,
		gaps_out = 4,
		border_size = 2,
		col = {
			active_border = { colors = { colors.primary_hex } },
			inactive_border = { colors = { colors.background_hex } },
		},
		resize_on_border = false,
		allow_tearing = true,
		-- layout = "dwindle",
		layout = "master",
	},

	-- Decoration
	decoration = {
		rounding = 0,

		shadow = {
			enabled = true,
			range = 2,
			render_power = 3,
			color = colors.shadow_hex,
		},

		blur = {
			enabled = true,
			size = 10,
			passes = 1,
			vibrancy = 0.1696,
		},
	},

	-- Animations (global toggle)
	animations = {
		enabled = true,
	},

	-- Dwindle layout
	dwindle = {
		force_split = 0,
		preserve_split = false,
		smart_split = false,
		smart_resizing = true,
		permanent_direction_override = false,
		special_scale_factor = 1,
		split_width_multiplier = 1.0,
		use_active_for_splits = true,
		default_split_ratio = 1.0,
		split_bias = 0,
		precise_mouse_move = false,
	},

	-- Master layout
	master = {
		mfact = 0.50,
		new_status = "inherit",
		orientation = "center",
		slave_count_for_center_master = 2,
		center_master_fallback = "left",
	},

	-- Misc
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		focus_on_activate = true,
		font_family = "CaskaydiaCove Nerd Font",
		mouse_move_enables_dpms = true,
		key_press_enables_dpms = true,
	},
})

-- Bezier curves
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Animations
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = false })
