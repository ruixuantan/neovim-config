# nvim

## Quick start

**Requirements:** [Neovim 0.12.2](https://github.com/neovim/neovim/releases) or newer, `git`, a C compiler, [ripgrep](https://github.com/BurntSushi/ripgrep), and a [Nerd Font](https://www.nerdfonts.com/) in the terminal.

```sh
# macOS (example)
brew install neovim ripgrep fd
nvim --version   # should show 0.12.2+

# Clone into ~/.config/nvim (back up any existing config first)
git clone <this_repo> ~/.config/nvim

# first launch — lazy.nvim installs plugins
nvim
```

Inside Neovim:

- `:Lazy` — manage plugins
- `:Mason` — install LSP servers and CLI tools
- `:checkhealth` — troubleshoot setup (custom check reports 0.12+ under **nvim config**)

**Completion:** [blink.cmp](https://github.com/saghen/blink.cmp) v2 (`lua/custom/plugins/blink.lua`). Optional: install [Rust](https://rustup.rs/) and run `gb` on `blink.cmp` in `:Lazy` for the faster fuzzy matcher.

## Configuration layout

Personal configuration originally bootstrapped from [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).

- `init.lua` — core options, basic keymaps, lazy.nvim bootstrap, and plugin imports.
- `lua/custom/plugins/*.lua` — plugin specs grouped by feature, automatically loaded through `{ import = 'custom.plugins' }`. No `init.lua` is needed in this folder.
- `lua/kickstart/plugins/` — enabled modules for debugging, indentation guides, linting, autopairs, and neo-tree.
- `lazy-lock.json` — tracked plugin versions; include changes when committing plugin updates.
- `AGENTS.md` — conventions and guidance for editing this config.

### Where to customize

Paths below are relative to `lua/custom/plugins/`:

| Feature | File |
|---------|------|
| LSP servers, Mason tools, diagnostics, LSP keymaps | `lsp.lua` |
| Formatters and format-on-save | `conform.lua` |
| Completion and snippets | `blink.lua` |
| Git signs and buffer-local keymaps | `gitsigns.lua` |
| Fuzzy finding and search keymaps | `telescope.lua` |
| Theme (kanagawa-wave) | `colorscheme.lua` |
| Treesitter parsers, highlighting, indentation | `treesitter.lua` |
| Keybinding hints | `which-key.lua` |
| Textobjects, surroundings, statusline | `mini.lua` |
| Lua development support | `lazydev.lua` |
| Markdown rendering / browser preview | `render-markdown.lua` / `markdown-preview.lua` |
| .NET test adapter | `neotest-dotnet.lua` |
| TODO comments / whitespace detection | `todo-comments.lua` / `sleuth.lua` |

Add plugins in new feature files here. Keep plugin dependencies nested in their parent spec unless they need independent configuration. Gitsigns signs and keymaps live together in `gitsigns.lua`, not in a separate Kickstart module.

## Language tooling

- **LSP:** `clangd`, `ruff`, `pyright`, `zls`, `lua_ls`. Mason installation and automatic enablement are derived from the `servers` table in `lsp.lua`.
- **Formatters:** StyLua for Lua, sqlfluff for SQL. Format-on-save uses LSP fallback except for C, C++, and Python; `<leader>f` manually formats the buffer.
- **Treesitter parsers:** Bash, Lua, LuaDoc, Markdown (including inline), Vim, Python, Rust, Zig. Installed asynchronously by `treesitter.lua`.

When adding a language, update `lsp.lua` and, as needed, the formatters in `conform.lua` and parser list in `treesitter.lua`.

## Verification

```sh
nvim --headless +qa
```

After changing plugin configuration, open `nvim`, inspect `:Lazy`, and run `:checkhealth`. For LSP changes, open a sample file and check `:LspInfo`. Only run `:Lazy sync` or `:Lazy update` when plugin installation or updates are needed.

