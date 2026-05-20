# nvim

## Quick start

**Requirements:** [Neovim 0.12.2](https://github.com/neovim/neovim/releases) or newer, `git`, a C compiler, [ripgrep](https://github.com/BurntSushi/ripgrep), and a [Nerd Font](https://www.nerdfonts.com/) in the terminal.

```sh
# macOS (example) — pin to 0.12.x
brew install neovim ripgrep fd
nvim --version   # should show 0.12.2+

# cloning this repo
cd .config/nvim
git clone <this_repo>

# first launch — lazy.nvim installs plugins
nvim
```

Inside Neovim:

- `:Lazy` — manage plugins
- `:Mason` — install LSP servers and CLI tools
- `:checkhealth` — troubleshoot setup (custom check reports 0.12+ under **nvim config**)

**Completion:** [blink.cmp](https://github.com/saghen/blink.cmp) v2 (`lua/custom/plugins/blink.lua`). Optional: install [Rust](https://rustup.rs/) and run `gb` on `blink.cmp` in `:Lazy` for the faster fuzzy matcher.

