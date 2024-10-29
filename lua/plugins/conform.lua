-- Lightweight formatter for Neovim
return {
  {
    'stevearc/conform.nvim',
    dependencies = { 'mason.nvim' },
    lazy = true,
    cmd = 'ConformInfo',
    keys = {
      '<leader>rf',
      '<leader>rF',
    },
    config = function()
      require('conform').setup {
        notify_on_error = true,
        -- format_on_save = {
        --     timeout_ms = 2000,
        --     lsp_fallback = true,
        -- },
        formatters_by_ft = {
          python = { 'ruff' },
          lua = { 'stylua' },
          bib = { 'bibtex-tidy' },
          tex = { 'latexindent' },
          sh = { 'shfmt' },
        },
      }
      -- Customize the "injected" formatter
      require('conform').formatters.injected = {
        options = {
          ignore_errors = true,
          lang_to_ext = {
            bash = 'sh',
            julia = 'jl',
            latex = 'tex',
            python = 'py',
            rust = 'rs',
          },
        },
      }

      vim.keymap.set({ 'n', 'v' }, '<leader>rF', function()
        require('conform').format { formatters = { 'injected' } }
      end, { desc = 'Format Injected Langs' })
      vim.keymap.set('n', '<leader>rf', require('conform').format, { desc = 'Format File' })
    end,
  },
}
