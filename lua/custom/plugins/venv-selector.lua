-- A simple neovim plugin to let you choose what virtual environment to activate in neovim.

return {
  'linux-cultist/venv-selector.nvim',
  dependencies = { 'neovim/nvim-lspconfig', 'nvim-telescope/telescope.nvim', 'mfussenegger/nvim-dap', 'mfussenegger/nvim-dap-python', 'microsoft/debugpy' },
  opts = {
    -- Your options go here
    name = { 'venv', '.venv'},
    auto_refresh = true,
    dap_enabled = true,
  },
  event = 'VeryLazy', -- Optional: needed only if you want to type `:VenvSelect` without a keymapping
  keys = {
    -- Keymap to open VenvSelector to pick a venv.
    { '<leader>vs', '<cmd>VenvSelect<cr>' },
    -- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
    { '<leader>vc', '<cmd>VenvSelectCached<cr>' },
  },
  config = function()
    require('venv-selector').setup {
      anaconda_base_path = '/opt/homebrew/Caskroom/miniconda/base',
      anaconda_envs_path = '/opt/homebrew/Caskroom/miniconda/base/envs',
    }
    require('venv-selector').retrieve_from_cache()
  end,
}
