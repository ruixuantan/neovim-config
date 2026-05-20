-- autopairs
-- https://github.com/windwp/nvim-autopairs
-- Function-completion brackets are handled by blink.cmp `completion.accept.auto_brackets`.

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  config = function()
    require('nvim-autopairs').setup {}
  end,
}
