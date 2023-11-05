-- Show regular vim syntax highlight group under cursor in lualine status line
-- default keymap to enable the functionality is: <leader>th
-- to disable the default keymap add to lazy plugin spec:
-- opts = { disable_keymap = true, }
-- Treesitter highlight will be disabled when show highlight is enabled
-- (with: :TSDisable highlight all)

--[[
-- more details:
function SynStack2()
  for _, i1 in ipairs(vim.fn.synstack(vim.fn.line('.'), vim.fn.col('.'))) do
    local i2 = vim.fn.synIDtrans(i1)
    local n1 = vim.fn.synIDattr(i1, 'name')
    local n2 = vim.fn.synIDattr(i2, 'name')
    print(n1, '->', n2)
  end
end
--]]

vim.g.highlight_line_active = false
vim.g.highlight_lualine_enabled = false

local M = {}

function M.SynStackStr()
  local s = ""
  for _, i1 in ipairs(vim.fn.synstack(vim.fn.line('.'), vim.fn.col('.'))) do
    local n1 = vim.fn.synIDattr(i1, 'name')
    if s == "" then
      s = n1
    else
      s = s .. " " .. n1
    end
  end
  s = "[" .. s .. "]"
  return s
end

function M.SynStackLine()
  if vim.g.highlight_line_active then
    return M.SynStackStr()
  else
    return ""
  end
end

function M.SynStackToggle()
  if not vim.g.highlight_lualine_enabled then
    if pcall(require, 'lualine') then
      local ll_x = require('lualine').get_config().sections.lualine_x
      table.insert(ll_x, 1, M.SynStackLine)
      require('lualine').setup({
        sections = {
          lualine_x = ll_x,
        }
      })
    end
    vim.g.highlight_lualine_enabled = true
    -- disable treesitter highlight if treesitter present
    if pcall(require, 'nvim-treesitter') then
      vim.cmd(':TSDisable highlight all')
    end
  end
  vim.g.highlight_line_active = not vim.g.highlight_line_active
end

function M.setup(opts)
  vim.g.loaded_show_highlight = 1
  local disable_keymap = opts and opts.disable_keymap
  if not disable_keymap then
    vim.keymap.set('n', '<leader>th', M.SynStackToggle,
      {
        noremap = true,
        silent = true,
        desc = '[T]oggle [H]ighlight under cursor'
      })
  end
end

return M

-- vim: ts=2 sts=2 sw=2 et
