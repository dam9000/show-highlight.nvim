-- Show syntax highlight group under cursor in lualine or cmd line
-- default keymap to enable the functionality is: <leader>th
-- to disable the default keymap add to lazy plugin spec:
-- opts = { disable_keymap = true, }

local M = {}

M.highlight_line_active = false

M.highlight_lualine_enabled = false

M.show_inspect_enabled = false

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
  if M.highlight_line_active then
    return M.InspectSynStr()
  else
    return ""
  end
end

function M.SynStackToggle()

  M.highlight_line_active = not M.highlight_line_active

  if M.highlight_line_active then
    -- enable show highlight
    if not M.highlight_lualine_enabled then
      if pcall(require, 'lualine') then
        -- add an entry in lualine
        local ll_x = require('lualine').get_config().sections.lualine_x
        table.insert(ll_x, 1, M.SynStackLine)
        require('lualine').setup({
          sections = {
            lualine_x = ll_x,
          }
        })
        M.highlight_lualine_enabled = true
      else
        -- lualine not available, use autocmd echo instead
        local augroup_id = vim.api.nvim_create_augroup("ShowHighlightGroup", {})
        vim.api.nvim_create_autocmd({"CursorMoved"}, {
          group = augroup_id,
          --pattern = {"*"},
          callback = function(_) -- (ev)
            local s = M.InspectSynStr()
            vim.cmd.echo('"'..s..'"')
          end
        })
        M.highlight_autocmd_enabled = true
      end
    end
  else
    -- disable show highlight
    if M.highlight_autocmd_enabled then
      -- clear augroup
      vim.api.nvim_create_augroup("ShowHighlightGroup", {})
      M.highlight_autocmd_enabled = false
    end
  end

end

M.winid = nil
M.bufid = nil

function M.update_inspect_window()
  if not M.winid then return end
  if not M.bufid then return end
  local cur_win = vim.api.nvim_get_current_win()
  if cur_win == M.winid then return end
  local output = vim.fn.split(vim.fn.execute('Inspect'), '\n')
  vim.api.nvim_buf_set_lines(M.bufid, 0, -1, false, output)
end

function M.open_inspect_window()
  if M.winid then return end
  local cur_win = vim.api.nvim_get_current_win()
  vim.cmd.new()
  vim.cmd.file('Inspect')
  M.winid = vim.api.nvim_get_current_win()
  M.bufid = vim.api.nvim_get_current_buf()
  vim.bo.filetype = 'Inspect'
  vim.bo.swapfile = false
  vim.bo.buftype = 'nofile'
  vim.bo.modified = false
  vim.wo.number = false
  vim.api.nvim_buf_set_lines(M.bufid, 0, -1, false, { "Inspect" })
  vim.api.nvim_set_current_win(cur_win)
  M.update_inspect_window()
end

function M.close_inspect_window()
  if M.winid then
    --local ret, err = pcall(func, args...)
    pcall(vim.api.nvim_win_close, M.winid, true)
    M.winid = nil
  end
  if M.bufid then
    pcall(vim.api.nvim_buf_delete, M.bufid, { force = true })
    M.bufid = nil
  end
end

function M.InspectToggle()
  M.show_inspect = not M.show_inspect

  if M.show_inspect then
    -- enable show Inspect
    M.open_inspect_window()
    local augroup_id = vim.api.nvim_create_augroup("augroup_ShowInspect", {})
    vim.api.nvim_create_autocmd({"CursorMoved"}, {
      group = augroup_id,
      --pattern = {"*"},
      callback = function(_) -- (ev)
        M.update_inspect_window()
      end
    })
  else
    -- disable show Inspect
    vim.api.nvim_create_augroup("augroup_ShowInspect", {})
    M.close_inspect_window()
  end
end


function M.setup(opts)
  vim.g.loaded_show_highlight = 1
  local disable_keymap = opts and opts.disable_keymap
  if not disable_keymap then
    vim.keymap.set('n', '<leader>th', M.SynStackToggle,
      {
        desc = '[T]oggle [h]ighlight under cursor'
      })
    vim.keymap.set('n', '<leader>tH', M.InspectToggle,
      {
        desc = '[T]oggle [H]ighlight Inspect window'
      })
  end
end

return M

-- vim: ts=2 sts=2 sw=2 et
