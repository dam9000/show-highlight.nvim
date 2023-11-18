# Show Highlight for Neovim

Show LSP, Treesitter or regular vim syntax highlight group under cursor
in lualine or cmd line if lualine is not available. Alternatively show
the `:Inspect` output in a separate window.

default keymap to toggle the functionality is:
- `<leader>th` for status line
- `<leader>tH` for Inspect window

to disable the default keymap use the following parameter to setup():
`{ disable_keymap = true, }`

## Installation

Install the plugin with your preferred package manager.

Example for [lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager:

```lua
{ 'dam9000/show-highlight.nvim', },
```

or, with disabled default keymap:

```lua
{ 'dam9000/show-highlight.nvim', opts = { disable_keymap = true, }, },
```

