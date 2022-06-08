local M = {}

local utils = require('utils')
local fn = vim.fn

function M.setup ()
    vim.g.vimwiki_map_prefix = '<Leader>e'
    vim.g.vimwiki_main = {
        path = '$HOME/cloud/utils/vimwiki/',
        syntax = 'markdown',
        ext = '.md'
    }
    vim.g.vimwiki_book = {
        path = '$HOME/cloud/utils/book/',
        syntax = 'markdown',
        ext = '.md'
    }
    vim.g.vimwiki_soundhound = {
        path = '$HOME/cloud/utils/soundhound-wiki/',
        syntax = 'markdown',
        ext = '.md'
    }
    vim.g.vimwiki_list = { vim.g.vimwiki_soundhound, vim.g.vimwiki_main, vim.g.vimwiki_book }
    vim.g.vimwiki_folding = 'custom'
    vim.g.vimwiki_global_ext = 0
    vim.g.vimwiki_filetypes = { 'markdown' }
    vim.cmd[[ autocmd FileType vimwiki setlocal fdm=marker ]]


    -- vim.g.pandoc#folding#fastfolds=1

    -- let g:pandoc#filetypes#handled = ["pandoc", "markdown"]
    -- let g:pandoc#filetypes#pandoc_markdown = 0
    -- let g:pandoc#folding#mode = ["syntax"]
    -- let g:pandoc#modules#enabled = ["formatting", "folding"]
    -- let g:pandoc#formatting#mode = "h"

    -- let g:vimwiki_folding='expr'
    -- au FileType vimwiki set filetype=markdown



    vim.cmd[[ command! ShowDiaryLastWeekRecap execute 'edit' . system('ls -t ' . g:vimwiki_soundhound.path . '/diary/week-recap* | head -1') ]]
    vim.cmd[[ command! RecapDiaryWeek call v:lua.RecapDiaryWeek() ]]
    vim.cmd[[ command! FZFwiki execute 'FZF ' . g:vimwiki_soundhound.path ]]
    vim.keymap.set('n', '<leader>eo', '<cmd>FZFwiki<CR>')
end

function RecapDiaryWeek ()
    -- Set variables and dates
    local wday = os.date('*t', os.time())['wday']
    local ago = 0
    if wday == 1 then
        ago = 6
    else
        ago = wday - 2
    end
    local last_week_date = os.date('%Y%m%d', os.time() - 24*60*60*ago)

    local list_files_date = {}
    local list_files = vim.fn.systemlist("ls " .. vim.g.vimwiki_soundhound.path .. '/diary/ -I diary.md -I "week-recap*"')
    for _, f in pairs(list_files) do
        f = string.gsub(f, '%.md', '')
        f = string.gsub(f, '-', '')
        table.insert(list_files_date, f)
    end

    -- Filter old files
    local list_index = 1
    local len_list_files = utils.table_size(list_files)
    local relevant_files = {}
    while list_index < len_list_files do
        if list_files_date[list_index] >= tostring(last_week_date-1) then
            table.insert(relevant_files, list_files[list_index])
        end
        list_index = list_index + 1
    end
    for i, val in pairs(relevant_files) do
        relevant_files[i] = vim.g.vimwiki_soundhound.path .. 'diary/' .. val
    end
    local output_file = fn.expand(vim.g.vimwiki_soundhound.path) .. 'diary/week-recap-' .. last_week_date .. '.md'

    -- Write file
    fn.writefile({ "# My week recap:" }, output_file)
    fn.writefile({ "" }, output_file, 'a')
    fn.writefile({ "- Chloé Dequeker" }, output_file, 'a')

    -- Write every diary file
    for _, diary_file in pairs(relevant_files) do
        local tmp_file = fn.readfile(fn.expand(diary_file))
        local diary_file_date = fn.fnamemodify(diary_file, ":t:r")
        diary_file_date = utils.execute('date -d"' .. diary_file_date .. '" "+%A %b. %d %Y"')
        fn.writefile({'', "## " .. diary_file_date, tmp_file}, output_file, 'a')
    end

    fn.writefile({
            "",
            "",
            "# Week recap:",
            "",
            "# Next week:",
            "",
            "",
        }, output_file, 'a')
    fn.execute('edit ' .. output_file)
end

return M
