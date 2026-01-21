return {
  "brenoprata10/nvim-highlight-colors",
  config = function()
    require("nvim-highlight-colors").setup({
      ---Render style: 'background', 'foreground' or 'virtual'
      render = "virtual",
      virtual_symbol = "■", -- The icon that shows the color
      enable_hex = true,    -- #ffffff
      enable_rgb = true,    -- rgb(255, 255, 255)
      enable_hsl = true,    -- hsl(0, 0%, 100%)
      enable_var_usage = true, -- CSS variables support
      enable_tailwind = true,  -- Tailwind CSS support
    })
  end,
}
