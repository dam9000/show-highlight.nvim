# Show Highlight for Neovim

Show regular vim syntax highlight group under cursor in lualine status line

default keymap to enable the functionality is: `<leader>th`

to disable the default keymap use the following parameter to setup():
`{ disable_keymap = true, }`

Treesitter highlight will be disabled when show highlight is enabled

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

