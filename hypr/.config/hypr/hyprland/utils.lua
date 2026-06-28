local M = {}

M.wallpaper = os.getenv("HOME") .. "/.config/hypr/wallpapers/green-room.jpg"

M.get_branch_name = function()
	local handle = io.popen("git -C " .. os.getenv("HOME") .. "/dotfiles" .. " branch --show-current 2>/dev/null")
	if handle then
		local branch = handle:read("*l")
		handle:close()
		return branch
	end
	return nil
end

local restart_app = function(app)
	-- hl.exec_cmd("kill -9 $(pidof " .. app .. "); " .. app .. " &")
	hl.exec_cmd("pkill " .. app .. "; " .. app .. " &")
end

M.reload_config = function()
	hl.exec_cmd("killall -SIGUSR2 waybar")
	restart_app("swayosd-server")
	restart_app("hypridle")
	restart_app("swaync")
	hl.exec_cmd("kill -9 $(pidof swaybg); swaybg -i " .. M.wallpaper .. " -m fill &")
end

return M
