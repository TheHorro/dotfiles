-- hl.exec_once("hyprpm reload -n")

hl.config({
	plugin = {
		["split-monitor-workspace"] = {
			count = 10,
			keep_focused = true,
			enable_notification = true,
			link_monitors = true,
		},
	},
})
