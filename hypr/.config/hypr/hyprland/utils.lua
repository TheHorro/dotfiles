local M = {}

M.wallpaper = os.getenv("HOME") .. "/.config/hypr/wallpapers/cabin.jpg"

M.get_branch_name = function()
	local handle = io.popen("git -C " .. os.getenv("HOME") .. "/dotfiles" .. " branch --show-current 2>/dev/null")
	if handle then
		local branch = handle:read("*l")
		handle:close()
		return branch
	end
	return nil
end

M.uname = function()
	local utsname = require("posix.sys.utsname")

	local info, err, errno = utsname.uname()
	if not info then
		error(err .. " (" .. tostring(errno) .. ")")
	end

	local hostname = info.nodename
	return hostname
end

local restart_app = function(app)
	-- hl.exec_cmd("kill -9 $(pidof " .. app .. "); " .. app .. " &")
	hl.exec_cmd("pkill " .. app .. "; " .. app .. " &")
end

M.reload_config = function()
	-- hl.exec_cmd("killall -SIGUSR2 waybar")
	restart_app("waybar")
	restart_app("swayosd-server")
	restart_app("hypridle")
	restart_app("swaync")
	hl.exec_cmd("kill -9 $(pidof swaybg); swaybg -i " .. M.wallpaper .. " -m fill &")
end

M.workspace_keys = { "code:10", "code:11", "code:12", "code:13" }
M.setupMonitor = function(monitor)
	for i = 1, #M.workspace_keys do
		hl.workspace_rule({
			workspace = tostring(10 * monitor.id + i),
			persistent = true,
			monitor = monitor.name,
			default = i == 1,
		})
	end
end

M.setupMonitors = function(monitors)
	for _, monitor in ipairs(monitors) do
		M.setupMonitor(monitor)
	end
end

return M
