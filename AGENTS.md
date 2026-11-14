# AGENTS.md

Instructions for AI coding agents working on this Neovim configuration.

**Target runtime:** Neovim **0.12.2+** (stable). Do not add compatibility shims for 0.10 or 0.11 unless the user explicitly asks.

## Project intent

This is **a personal Neovim config** at `~/.config/nvim`

The config was bootstrapped from [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) and is being evolved independently. Prefer small, understandable changes over wholesale imports from other dotfiles or distros (LazyVim, AstroNvim, etc.) unless explicitly requested.

## Layout

```
~/.config/nvim/
├── init.lua                 # Core options, keymaps, lazy bootstrap and imports
├── lazy-lock.json           # Plugin lockfile (commit when plugins change)
├── lua/
│   ├── kickstart/
│   │   ├── health.lua       # :checkhealth extension
│   │   └── plugins/         # Optional plugin modules (return lazy specs)
│   └── custom/
│       └── plugins/         # Plugin specs split by feature; auto-imported by lazy
│           ├── lsp.lua      # LSP servers, Mason tools, diagnostics and LSP keymaps
│           ├── conform.lua  # Formatters and format-on-save
│           ├── gitsigns.lua # Git signs and buffer-local keymaps
│           └── *.lua        # Completion, theme, Telescope, Treesitter, etc.
├── doc/                     # Vim help tags (kickstart legacy; low priority)
├── .stylua.toml             # Lua formatter settings
└── README.md
```

### Where to edit

| Goal | Location |
|------|----------|
| New plugin or heavy customization | `lua/custom/plugins/*.lua` (add files; lazy auto-imports the folder) |
| Small tweak to an existing kickstart module | `lua/kickstart/plugins/<name>.lua` |
| Global options, leader, basic keymaps | `init.lua` (top sections) |
| Colorscheme, Treesitter, Telescope, completion | `lua/custom/plugins/colorscheme.lua`, `treesitter.lua`, `telescope.lua`, `blink.lua` |
| LSP servers, diagnostics, Mason tools | `lua/custom/plugins/lsp.lua` |
| Formatters and format-on-save | `lua/custom/plugins/conform.lua` |
| Git signs and keymaps | `lua/custom/plugins/gitsigns.lua` |

**Default rule for agents:** keep plugin specs under `lua/custom/plugins/`, grouped by feature, rather than growing `init.lua`. Keep a plugin's dependencies nested in its spec unless they need independent configuration. There is no `lua/custom/plugins/init.lua`; lazy imports the feature files directly.

## Plugin system

- **Manager:** [lazy.nvim](https://github.com/folke/lazy.nvim) — bootstrapped at the bottom of `init.lua`.
- **Spec style:** files under `lua/**/plugins/` return a plugin spec or a list of specs; `require('lazy').setup({ ... })` in `init.lua` imports them.
- **Custom plugins:** enabled via `{ import = 'custom.plugins' }` in `init.lua`.
- **Kickstart modules:** `require 'kickstart.plugins.*'` entries in `init.lua` load optional features (debug, lint, neo-tree, etc.).

After changing plugin specs:

1. Run `nvim` (lazy may sync on start).
2. Use `:Lazy` to verify install/state; `:Lazy sync` or `:Lazy update` when needed.
3. Commit `lazy-lock.json` when dependencies changed.

## Conventions

- **Leader:** `<Space>` (`vim.g.mapleader = ' '`).
- **Local leader:** `<Space>` as well.
- **Nerd Font:** `vim.g.have_nerd_font = true` — icons in UI/diagnostics assume a Nerd Font terminal.
- **Formatting:** [stylua](https://github.com/JohnnyMorganz/StyLua) per `.stylua.toml` (160 col width, 2 spaces, single quotes preferred).
- **Neovim APIs (0.12):** use `vim.hl.on_yank()` (not `vim.highlight`), `vim.uv` (not `vim.loop`), and `client:supports_method(method, bufnr)` for LSP capability checks.
- **Augroup names:** still prefixed with `kickstart-` in places — rename to `nvim-` or `custom-` only when editing that code; no mass rename required.
- **Keymap descriptions:** use `desc = '...'` for which-key integration.

## Language tooling

- **LSP** (`lua/custom/plugins/lsp.lua`, via mason-lspconfig): `clangd`, `ruff`, `pyright`, `zls`, `lua_ls`
- **Formatters** (`lua/custom/plugins/conform.lua`): `stylua` (lua), `sqlfluff` (sql); format-on-save with per-filetype LSP fallback rules
- **Mason tools** (`lsp.lua`): derived from LSP list + `stylua`, `sqlfluff`
- **Treesitter** (`lua/custom/plugins/treesitter.lua`): `bash`, `lua`, `luadoc`, `markdown`, `markdown_inline`, `vim`, `python`, `rust`, `zig`; parsers installed via `treesitter.install(...)`

When adding a language: update `servers` in `lsp.lua` and, as needed, Mason tools, `formatters_by_ft` in `conform.lua`, and the parser list in `treesitter.lua`.

## Notable plugins (quick reference)

| Area | Plugin |
|------|--------|
| File tree | neo-tree (`kickstart.plugins.neo-tree`) |
| Fuzzy find | telescope + fzf-native |
| Completion | blink.cmp v2 + `blink.lib` + LuaSnip (`lua/custom/plugins/blink.lua`); LSP capabilities in `lua/custom/plugins/lsp.lua` |
| Git | gitsigns (`lua/custom/plugins/gitsigns.lua`); signs and keymaps consolidated here |
| Test | neotest-dotnet |
| Theme | kanagawa-wave |
| Markdown preview | markdown-preview.nvim |
| Markdown rendering | render-markdown.nvim (`lua/custom/plugins/render-markdown.lua`) |
| Debug | kickstart.plugins.debug |

## Agent workflow

1. **Read before write** — open the relevant spec file and nearby keymaps in `init.lua`.
2. **Minimize scope** — one concern per change; avoid drive-by refactors.
3. **Match existing patterns** — lazy `opts`, `config = function()`, `event`/`ft`/`cmd` keys as used elsewhere.
4. **Do not** add new dependencies on LazyVim, kickstart upstream sync, or copy entire foreign configs.
5. **Do not** commit secrets, API keys, or machine-specific absolute paths unless the user asks.
6. **Do not** remove `lazy-lock.json` from git; `.gitignore` intentionally tracks it (upstream kickstart ignored it; this repo does not).

### Verification checklist

- [ ] `nvim --headless +qa` or open `nvim` without Lua errors on startup
- [ ] `:checkhealth` — especially `lazy`, `mason`, LSP attach
- [ ] `:Lazy` — new/changed plugins show correct state
- [ ] If LSP changed: open a sample file for that filetype and `:LspInfo`
- [ ] If keymaps changed: `:WhichKey` or trigger the map

### Useful commands

```
:Lazy          " plugin manager
:Mason         " LSP/tool installer
:Telescope     " pickers
:checkhealth   " diagnostics
:help <topic>  " built-in docs; <leader>sh searches help
```

## Common tasks (recipes)

**Add a plugin**

```lua
-- lua/custom/plugins/example.lua
return {
  'author/plugin.nvim',
  event = 'VeryLazy',
  opts = {},
}
```

**Add an LSP server** — extend `servers` in `lua/custom/plugins/lsp.lua`. Mason's install list and `automatic_enable` are derived from its keys; the existing loop configures servers via `vim.lsp.config`.

**Add a keymap** — prefer buffer-local maps inside LSP `LspAttach` or plugin `config`; global maps go near other keymaps in `init.lua` or the plugin's config block.

**Change colorscheme** — edit `lua/custom/plugins/colorscheme.lua`.

## Documentation debt (optional human follow-ups)

- Large kickstart banner and comments at top of `init.lua` can be trimmed over time.
- `doc/kickstart.txt` and README upstream sections are legacy; safe to delete when no longer useful.
- Consider renaming `lua/kickstart/` → `lua/nvim/` when doing a dedicated refactor (not required for routine plugin work).

## Git

- Only commit when the user asks.
- Include `lazy-lock.json` in commits that change plugins.
- Do not change git config or force-push unless explicitly requested.
