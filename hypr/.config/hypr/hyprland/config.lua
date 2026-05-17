local colors = loadfile("/home/Horro/.config/hypr/colors.lua") or {}

hl.config({ xwayland = { force_zero_scaling = true } })
hl.config({ ecosystem = { no_update_news = true, no_donation_nag = true } })

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "altgr-intl",
		kb_model = "",
		kb_options = "nodeadkeys",
		kb_rules = "",
		repeat_rate = 50,
		repeat_delay = 300,

		sensitivity = 0,
		accel_profile = "flat",
		numlock_by_default = true,
		left_handed = false,
		follow_mouse = true,
		float_switch_override_focus = false,

		touchpad = {
			natural_scroll = false,
		},
	},
	general = {
		gaps_in = 1,
		gaps_out = 4,
		border_size = 2,
		col = {
			active_border = { colors = { colors().primary_hex } },
			inactive_border = { colors = { colors().background_hex } },
		},
		resize_on_border = false,
		allow_tearing = true,
		layout = "dwindle",
	},

	-- Decoration
	decoration = {
		rounding = 0,

		shadow = {
			enabled = true,
			range = 2,
			render_power = 3,
			color = colors().shadow_hex,
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
		new_status = "master",
	},

	-- Misc
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		focus_on_activate = true,
	},

	-- Cursor
	cursor = {
		hide_on_key_press = true,
		no_hardware_cursors = 1,
	},
})
