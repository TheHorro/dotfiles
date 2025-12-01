-- Main autolist module with exported functions
local M = {}

-- Export the operations and utils modules
M.operations = require("plugins.tools.autolist.util.list_operations")
M.utils = require("plugins.tools.autolist.util.utils")

return M
