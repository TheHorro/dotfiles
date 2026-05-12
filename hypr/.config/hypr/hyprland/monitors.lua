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
	scale = "1.0",
	bitdepth = 10,
	cm = "srgb",
})

hl.monitor({
	output = "DP-3",
	mode = "2560x1440@165.0",
	position = "440x0",
	scale = "1.0",
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

for i = 1, 10 do
	hl.workspace_rule({ workspace = tostring(i), monitor = "DP-2" })
	hl.workspace_rule({ workspace = tostring(i + 10), monitor = "DP-3" })
end
