local M = {}

local utils = require('utils')
local fn = vim.fn

function CreateCenteredFloatingWindow ()
    local columns = vim.o.columns
    local lines = vim.o.lines
    local width = math.min(columns - 4, math.max(80, fn.float2nr(columns/2)))
    local height = math.min(lines - 4, math.max(20, fn.float2nr((lines * 2)/3)))

    local top = ((lines - height) / 2) - 1
    local left = (columns - width) / 2
    local opts = {
        relative = 'editor',
        row = top,
        col = left,
        width = width,
        height = height,
        style = 'minimal',
    }

    local repeat_pattern = function (patt, count)
        local out = ''
        for _=1,count do
            out = out .. patt
        end
    end

    local top_str = "╭" .. repeat_pattern("─", width - 2) .. "╮"
    local mid_str = "│" .. repeat_pattern(" ", width - 2) .. "│"
    local bot_str = "╰" .. repeat_pattern("─", width - 2) .. "╯"
    local win_lines = {top_str, repeat_pattern(mid_str, height - 2), bot_str}

    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, win_lines)
    vim.api.nvim_open_win(bufnr, true, opts)
    -- vim.o.winhl = Normal:Floating
    opts.row = opts.row + 1
    opts.height = opts.height - 2
    opts.col = opts.col + 2
    opts.width = opts.width - 4
    vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, opts)
    vim.cmd[[ au BufWipeout <buffer> exe 'bw '.s:buf ]]
end

function M.setup ()
    vim.cmd[[ autocmd CompleteDone * pclose ]]
    vim.g.fzf_history_dir = '~/.local/share/fzf-history'
    -- [Buffers] Jump to the existing window if possible
    vim.g.fzf_buffers_jump = 1

    vim.g.fzf_colors = {
      fg =      { 'fg', 'Normal' },
      bg =      { 'bg', 'Normal' },
      hl =      { 'fg', 'Comment' },
      -- fg+ =     { 'fg', 'CursorLine', 'CursorColumn', 'Normal' },
      -- bg+ =     { 'bg', 'CursorLine', 'CursorColumn' },
      info =    { 'fg', 'PreProc' },
      border =  { 'fg', 'Ignore' },
      pointer = { 'fg', 'Exception' },
      spinner = { 'fg', 'Label' },
      header =  { 'fg', 'Comment' },
    }

    utils.nnoremap(',', ':Buffers<CR>')
    utils.nnoremap('<Leader>i', ':Rg<CR>')
    utils.nnoremap('<Leader>o', ':FZF<CR>')
    utils.nnoremap('<Leader>t', ':Tags<CR>')
    utils.nnoremap('<Leader>T', ':BTags<CR>')
    utils.nnoremap('<Leader>fp', ':GFiles<CR>')
    utils.nnoremap('<Leader>s', ':BLines<CR>')

    utils.nnoremap('<c-x>h', ':Helptags<CR>')
    utils.inoremap('<c-x>h', ':Helptags<CR>')
    utils.nnoremap('<Leader>x', ':Commands<CR>')
    utils.inoremap('<M-x>', ':Commands<CR>')
    -- Fuzzy search help <leader>?

    vim.cmd[[
    command! -bang -nargs=* Rg
     \ call fzf#vim#grep(
     \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
     \   <bang>0 ? fzf#vim#with_preview('up:60%')
     \           : fzf#vim#with_preview('right:50%:hidden', '?'),
     \   <bang>0)
    ]]

    vim.g.fzf_layout = { window = 'call CreateCenteredFloatingWindow()' }

    vim.cmd[[ autocmd! FileType fzf ]]
end

return M
