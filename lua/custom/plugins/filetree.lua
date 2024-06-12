-- Neovim plugin to manage the file system and other tree like structures.

-- Unless you are still migrating, remove the deprecated commands from v1.x
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    "s1n7ax/nvim-window-picker",
    config = function()
      require("window-picker").setup()
    end,
  },
  config = function ()
    require('neo-tree').setup {
      opts = {
        source_selector = {
          sources = {
            { source = "filesystem" },
            { source = "git_status" },
            { source = "document_symbols" },
            { source = "buffers" },
          },
        },
        window = {
          position = "left",
          width = 40,
          mappings = {
            ["e"] = nil, -- disable auto expand; it doesn't work with edgy
            ["<tab>"] = "toggle_node",
          },
        },
        document_symbols = {
          follow_cursor = true,
          renderers = {
            symbol = {
              { "indent", with_expanders = true },
              { "kind_icon", default = "?" },
              { "name", zindex = 10 },
              -- removed the kind text as its redundant with the icon
            },
          },
        },
    },
  }
  end,
}
