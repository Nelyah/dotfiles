local M = {}

local utils = require('utils')

function FuzzyFileTypes ()
    require('fzf-lua').filetypes()
end

function M.setup ()
    local search_cmd = '' -- leaves back to the default (fd > find)
    if (vim.fn.executable('fd') == 0) and (vim.fn.executable('rg') == 1) then
        search_cmd = 'rg --files'
    end

    require('fzf-lua').setup{
        winopts = {
            height  = 0.35,            -- window height
            width   = 1.00,            -- window width
            row     = 0.92,            -- window row position (0=top, 1=bottom)
        },
        files = {
            cmd     = search_cmd,
        }
    }


    vim.cmd('command! FT call v:lua.FuzzyFileTypes()')

    utils.nnoremap('<leader>o', ":lua require('fzf-lua').files()<CR>")
    utils.nnoremap('<leader>O', ":lua require('fzf-lua').grep()<CR>")
    utils.nnoremap('<leader>i', ":lua require('fzf-lua').grep({search = ''})<CR>")
    utils.nnoremap('<leader>I', ":lua require('fzf-lua').live_grep()<CR>")
    utils.nnoremap('<leader>s', ":lua require('fzf-lua').blines()<CR>")
    utils.nnoremap('<leader>x', ":lua require('fzf-lua').commands()<CR>")
    utils.nnoremap('<c-x>h', ":lua require('fzf-lua').help_tags()<CR>")
    utils.nnoremap('<leader>us', ":lua require('fzf-lua').git_status()<CR>")
    utils.nnoremap(',', ":lua require('fzf-lua').buffers()<CR>")
    utils.nnoremap('z=', ":lua require('fzf-lua').spell_suggest()<CR>")
end

return M
