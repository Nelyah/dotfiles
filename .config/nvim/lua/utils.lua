local cmd = vim.cmd
local M = {}

function M.create_augroup(name, autocmds)
    cmd('augroup ' .. name)
    cmd('autocmd!')
    for _, autocmd in ipairs(autocmds) do
        cmd('autocmd ' .. table.concat({autocmd}, ' '))
    end
    cmd('augroup END')
end

function M.get_current_line_length()
    return string.len(vim.api.nvim_get_current_line())
end

function M.table_size(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

function M.execute(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

function M.file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

return M
