-- Completion: blink.cmp v2 (replaces nvim-cmp)
return {
  {
    'saghen/blink.cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
      'saghen/blink.lib',
      {
        'L3MON4D3/LuaSnip',
        build = function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end,
      },
      'rafamadriz/friendly-snippets',
    },
    build = function()
      require('blink.cmp').build():wait(60000)
    end,
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'default',
        -- Match previous nvim-cmp snippet navigation
        ['<C-l>'] = { 'snippet_forward', 'fallback' },
        ['<C-h>'] = { 'snippet_backward', 'fallback' },
      },
      completion = {
        documentation = { auto_show = false },
      },
      snippets = { preset = 'luasnip' },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        per_filetype = {
          lua = { inherit_defaults = true, 'lazydev' },
        },
      },
      -- Use Lua if the Rust matcher was not built (`gb` in :Lazy on blink.cmp)
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
  },
}
