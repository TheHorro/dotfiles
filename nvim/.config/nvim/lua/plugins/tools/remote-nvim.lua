return {
  "amitds1997/remote-nvim.nvim",
  version = "*", -- pin to stable GitHub releases
  dependencies = {
    "nvim-lua/plenary.nvim",   -- standard utility functions
    "MunifTanjim/nui.nvim",    -- plugin UI components
    "nvim-telescope/telescope.nvim", -- host picker UI
  },
  config = function()
    require("remote-nvim").setup({
      ssh_config_file_paths = { "$HOME/.ssh/config" },
    })
  end,
}
