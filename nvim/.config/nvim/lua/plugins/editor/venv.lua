-- plugins/venv.lua
return {
  "linux-cultist/venv-selector.nvim",
  branch = "regexp",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("venv-selector").setup({
      settings = {
        search = {
          -- .venv im Projektverzeichnis
          file_dir_venv = {
            command = "fd bin/python$ {file_dir} --full-path --color never",
          },
          -- Mamba/Conda-Umgebungen
          conda = {
            command = "fd bin/python$ ~/miniforge3/envs --full-path --color never",
          },
          -- System-Python
          system = {
            command = "fd bin/python3$ /usr --full-path --color never",
          },
        },
      },
    })
  end,
  keys = {
    { "<leader>vs", "<cmd>VenvSelect<cr>",       desc = "Python Env wählen" },
    { "<leader>vc", "<cmd>VenvSelectCached<cr>", desc = "Letzte Env wiederverwenden" },
  },
}
