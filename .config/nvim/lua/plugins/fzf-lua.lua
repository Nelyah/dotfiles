local M = {}

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
        },
        lsp = {
            git_icons = false,
        },
    }

    vim.cmd('command! FT call v:lua.FuzzyFileTypes()')

    vim.keymap.set('n', '<leader>o', "<cmd>lua require('fzf-lua').files()<CR>")
    vim.keymap.set('n', '<leader>O', "<cmd>lua require('fzf-lua').grep()<CR>")
    vim.keymap.set('n', '<leader>i', "<cmd>lua require('fzf-lua').grep({search = ''})<CR>")
    vim.keymap.set('n', '<leader>I', "<cmd>lua require('fzf-lua').live_grep()<CR>")
    vim.keymap.set('n', '<leader>s', "<cmd>lua require('fzf-lua').blines()<CR>")
    vim.keymap.set('n', '<leader>x', "<cmd>lua require('fzf-lua').commands()<CR>")
    vim.keymap.set('n', '<c-x>h', "<cmd>lua require('fzf-lua').help_tags()<CR>")
    vim.keymap.set('n', '<leader>us', "<cmd>lua require('fzf-lua').git_status()<CR>")
    vim.keymap.set('n', ',', "<cmd>lua require('fzf-lua').buffers()<CR>")
    vim.keymap.set('n', 'z=', "<cmd>lua require('fzf-lua').spell_suggest()<CR>")
end

return M
