local M = {}

M.get_branch_name = function()
	local handle = io.popen("git -C " .. os.getenv("HOME") .. "/dotfiles" .. " branch --show-current 2>/dev/null")
	if handle then
		local branch = handle:read("*l")
		handle:close()
		return branch
	end
	return nil
end

return M
