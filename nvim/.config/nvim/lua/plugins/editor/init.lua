-- Helper function to require a module with error handling
local function safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    -- require('util.notifications').editor('Failed to load plugin module', require('util.notifications').categories.WARNING, { module = module })
    vim.notify("Failed to load plugin module: " .. module, vim.log.levels.WARN)
    return {}
  end
  return result
end

-- Load modules
-- local formatting_module = safe_require("plugins.editor.formatting")
-- local linting_module = safe_require("plugins.editor.linting")
local telescope_module = safe_require("plugins.editor.telescope")
-- local toggleterm_module = safe_require("plugins.editor.toggleterm")
local treesitter_module = safe_require("plugins.editor.treesitter")
local which_key_module = safe_require("plugins.editor.which-key")

-- Return plugin specs
return {
  which_key_module,
  -- formatting_module,
  -- linting_module,
  telescope_module,
  -- toggleterm_module,
  treesitter_module,
}
