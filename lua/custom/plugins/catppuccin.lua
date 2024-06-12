-- Catppuccin is a community-driven pastel theme that aims to be the middle ground between low and high contrast themes. It consists of 4 soothing warm flavors with 26 eye-candy colors each.

return {
    {
      "catppuccin/nvim",
      lazy = false,
      name = "catppuccin",
      priority = 1000,
      config = function()
        vim.cmd.colorscheme "catppuccin-mocha"
      end
    }
  }
