return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local treesitter = require 'nvim-treesitter'
    treesitter.setup {}

    local function attach(buf)
      local ft = vim.bo[buf].filetype
      local lang = vim.treesitter.language.get_lang(ft)
      if not lang or not pcall(vim.treesitter.start, buf, lang) then
        return
      end

      if ft == 'ruby' then
        vim.bo[buf].syntax = 'ruby'
      elseif vim.treesitter.query.get(lang, 'indents') then
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end

    -- The main branch uses Neovim's built-in highlighting, enabled per buffer.
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('custom-treesitter', { clear = true }),
      callback = function(event)
        attach(event.buf)
      end,
    })

    -- Parser installation is asynchronous; attach open buffers once it finishes.
    treesitter.install({ 'bash', 'lua', 'luadoc', 'markdown', 'vim', 'python', 'rust', 'zig' }):await(function(err, installed)
      if err or not installed then
        return
      end
      vim.schedule(function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) then
            attach(buf)
          end
        end
      end)
    end)
  end,
}
