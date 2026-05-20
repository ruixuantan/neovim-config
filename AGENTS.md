# AGENTS.md

Instructions for AI coding agents working on this Neovim configuration.

**Target runtime:** Neovim **0.12.2+** (stable). Do not add compatibility shims for 0.10 or 0.11 unless the user explicitly asks.

## Project intent

This is **a personal Neovim config** at `~/.config/nvim`

The config was bootstrapped from [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) and is being evolved independently. Prefer small, understandable changes over wholesale imports from other dotfiles or distros (LazyVim, AstroNvim, etc.) unless explicitly requested.

## Layout

```
~/.config/nvim/
├── init.lua                 # Core options, keymaps, and most plugin specs
├── lazy-lock.json           # Plugin lockfile (commit when plugins change)
├── lua/
│   ├── kickstart/
│   │   ├── health.lua       # :checkhealth extension
│   │   └── plugins/         # Optional plugin modules (return lazy specs)
│   └── custom/
│       └── plugins/         # **Preferred place for new plugins**
│           └── init.lua     # Your overrides (LSP, opencode, conform, …)
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
| Colorscheme, treesitter, telescope, cmp | `init.lua` (plugin table) — consider moving to `custom/` when touching a large block |
| LSP servers, formatters, Mason tools | `lua/custom/plugins/init.lua` |
| AI in editor (opencode) | `lua/custom/plugins/init.lua` |

**Default rule for agents:** add new behavior under `lua/custom/plugins/` rather than growing `init.lua` further. Split into new files (e.g. `lua/custom/plugins/telescope.lua`) when a spec exceeds ~80 lines.

## Plugin system

- **Manager:** [lazy.nvim](https://github.com/folke/lazy.nvim) — bootstrapped at the bottom of `init.lua`.
- **Spec style:** Lua tables returned from `require('lazy').setup({ ... })` and from files under `lua/**/plugins/`.
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

Configured in `lua/custom/plugins/init.lua`:

- **LSP (via mason-lspconfig):** `clangd`, `gopls`, `ruff`, `pyright`, `rust_analyzer`, `zls`, `lua_ls`
- **Formatters (conform):** `stylua` (lua), `sqlfluff` (sql); format-on-save with per-filetype LSP fallback rules
- **Mason tools:** derived from LSP list + `stylua`, `sqlfluff`
- **Treesitter** (`init.lua`): `bash`, `c_sharp`, `lua`, `luadoc`, `markdown`, `vim`, `python`, `rust`, `zig`

When adding a language: update `servers` and usually `ensure_installed` / `formatters_by_ft` / treesitter `ensure_installed` together.

## Notable plugins (quick reference)

| Area | Plugin |
|------|--------|
| File tree | neo-tree (`kickstart.plugins.neo-tree`) |
| Fuzzy find | telescope + fzf-native |
| Completion | blink.cmp v2 + `blink.lib` + LuaSnip (`lua/custom/plugins/blink.lua`); LSP capabilities in `custom/plugins/init.lua` |
| Git | gitsigns (duplicate spec: init + kickstart module — prefer one place when refactoring) |
| Test | neotest-dotnet |
| Theme | kanagawa-wave |
| CSV | rainbow_csv |
| Markdown preview | markdown-preview.nvim |
| AI | opencode.nvim (+ snacks.nvim) |
| Debug | kickstart.plugins.debug |

## Agent workflow

1. **Read before write** — open the relevant spec file and nearby keymaps in `init.lua`.
2. **Minimize scope** — one concern per change; avoid drive-by refactors.
3. **Match existing patterns** — lazy `opts`, `config = function()`, `event`/`ft`/`cmd` keys as used elsewhere.
4. **Do not** add new dependencies on LazyVim, kickstart upstream sync, or copy entire foreign configs.
5. **Do not** commit secrets, API keys, or machine-specific absolute paths unless the user asks.
6. **Do not** remove `lazy-lock.json` from git; `.gitignore` intentionally tracks it (upstream kickstart ignored it; this repo does not).

### Verification checklist

- [ ] `nvim --headless "+lua require('lazy').setup({})" +qa"` or open `nvim` without Lua errors on startup
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

**Add an LSP server** — extend `servers` and `ensure_installed` in `lua/custom/plugins/init.lua`, follow existing `mason-lspconfig` handler pattern.

**Add a keymap** — prefer buffer-local maps inside LSP `LspAttach` or plugin `config`; global maps go near other keymaps in `init.lua` or the plugin's config block.

**Change colorscheme** — edit the `kanagawa.nvim` block in `init.lua` or move it to `custom/plugins/`.

## Documentation debt (optional human follow-ups)

- Large kickstart banner and comments at top of `init.lua` can be trimmed over time.
- `doc/kickstart.txt` and README upstream sections are legacy; safe to delete when no longer useful.
- Consider renaming `lua/kickstart/` → `lua/nvim/` when doing a dedicated refactor (not required for routine plugin work).

## Git

- Only commit when the user asks.
- Include `lazy-lock.json` in commits that change plugins.
- Do not change git config or force-push unless explicitly requested.
