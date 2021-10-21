local M = {}

local utils = require('utils')

function M.setup ()
    vim.g.tmux_navigator_no_mappings = 1

    utils.nnoremap('<m-h>', ':TmuxNavigateLeft<cr>')
    utils.nnoremap('<m-j>', ':TmuxNavigateDown<cr>')
    utils.nnoremap('<m-k>', ':TmuxNavigateUp<cr>')
    utils.nnoremap('<m-l>', ':TmuxNavigateRight<cr>')
    utils.nnoremap('<m-\\>', ':TmuxNavigatePrevious<cr>')

    utils.tnoremap('<m-h>', '<C-\\><C-n>:TmuxNavigateLeft<cr>')
    utils.tnoremap('<m-j>', '<C-\\><C-n>:TmuxNavigateDown<cr>')
    utils.tnoremap('<m-k>', '<C-\\><C-n>:TmuxNavigateUp<cr>')
    utils.tnoremap('<m-l>', '<C-\\><C-n>:TmuxNavigateRight<cr>')
    utils.tnoremap('<m-\\>', '<C-\\><C-n>:TmuxNavigatePrevious<cr>')
end

return M
