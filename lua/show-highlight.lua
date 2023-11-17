-- Show regular vim syntax highlight group under cursor in lualine status line
-- default keymap to enable the functionality is: <leader>th
-- to disable the default keymap add to lazy plugin spec:
-- opts = { disable_keymap = true, }


vim.g.highlight_line_active = false
vim.g.highlight_lualine_enabled = false

local M = {}

--[[
--OLD
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
--]]

function M.fmt_hl_group(s, hdr, o)
  if o then
    if o.hl_group == o.hl_group_link then
      s = string.format("%s%s%s ", s, hdr, o.hl_group)
    else
      s = string.format("%s%s%s->%s ", s, hdr, o.hl_group, o.hl_group_link)
    end
  end
  return s
end

function M.has_color(hl)
  local synid = vim.fn.synIDtrans(vim.fn.hlID(hl))
  local bg = vim.fn.synIDattr(synid, 'bg')
  local fg = vim.fn.synIDattr(synid, 'fg')
  if (fg and fg ~= '') or (bg and bg ~= '') then
    return true
  else
    return false
  end
end

function M.last_prio_with_color(syntable)
  local o = nil
  -- get highest priority with a defined fg or bg
  for _, x in ipairs(syntable) do
    local xo = x
    if x.opts then xo = x.opts end
    if not o then
      o = xo
    else
      local prio = true
      if o.priority and xo.priority then prio = xo.priority > o.priority end
      if prio and M.has_color(xo.hl_group_link) then
        o = xo
      end
    end
  end
  return o
end

function M.InspectSynStr()
  local s = "[ "
  local o = nil
  local insp = vim.inspect_pos()
  if insp then
    o = M.last_prio_with_color(insp.syntax)
    s = M.fmt_hl_group(s, "syn:", o)
    o = M.last_prio_with_color(insp.treesitter)
    s = M.fmt_hl_group(s, "ts:", o)
    o = M.last_prio_with_color(insp.semantic_tokens)
    s = M.fmt_hl_group(s, "lsp:", o)
  end
  s = s .. "]"
  return s
end

function M.SynStackLine()
  if vim.g.highlight_line_active then
    return M.InspectSynStr()
  else
    return ""
  end
end

function M.SynStackToggle()
  if not vim.g.highlight_lualine_enabled then
    if pcall(require, 'lualine') then
        -- add an entry in lualine
      local ll_x = require('lualine').get_config().sections.lualine_x
      table.insert(ll_x, 1, M.SynStackLine)
      require('lualine').setup({
        sections = {
          lualine_x = ll_x,
        }
      })
    end
    vim.g.highlight_lualine_enabled = true
  end
  vim.g.highlight_line_active = not vim.g.highlight_line_active
end

function M.setup(opts)
  vim.g.loaded_show_highlight = 1
  local disable_keymap = opts and opts.disable_keymap
  if not disable_keymap then
    vim.keymap.set('n', '<leader>th', M.SynStackToggle,
      {
        desc = '[T]oggle [H]ighlight under cursor'
      })
  end
end

return M

-- vim: ts=2 sts=2 sw=2 et
