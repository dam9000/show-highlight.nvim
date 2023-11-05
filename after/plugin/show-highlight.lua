-- if setup() was not called by the plugin manager then call it now

if vim.g.loaded_show_highlight == 1 then
  return
end
vim.g.loaded_show_highlight = 1

require('show-highlight').setup()

-- vim: ts=2 sts=2 sw=2 et
