local fn = vim.fn

function InsertHeader ()
    local cur_filename = fn.expand('%:t')
    local cur_fileending = fn.expand('%:e')
    local start_lines = {
        '/* file "' .. cur_filename .. '" */',
        '/* Copyright ' .. os.date('%Y') .. ' SoundHound, Incorporated. All rights reserved. */',
        ''
    }
    local end_lines = {}
    if cur_fileending == "h" or cur_fileending == "ti" then
        local upper_filename = string.upper(cur_filename)
        local subs = {'%.', '_'}
        for i, pattern in pairs(subs) do subs[i] = string.gsub(upper_filename, pattern, '') end

        for _, out in pairs({
            '#ifndef ' .. cur_filename,
            '#define ' .. cur_filename,
            '',
        }) do
            table.insert(start_lines, out)
        end

        for _, out in pairs({
            '',
            '#endif /* ' .. cur_filename .. ' */',
        }) do
            table.insert(end_lines, out)
        end
    end
    fn.append(0, start_lines)
    fn.append(fn.line('$'), end_lines)
end

-- Treat .ter/.ti/.cdt files as cpp files
vim.cmd[[ autocmd! BufNewFile,BufRead,BufEnter *.ter set filetype=cpp ]]
vim.cmd[[ autocmd! BufNewFile,BufRead,BufEnter *.ti set filetype=cpp ]]
vim.cmd[[ autocmd! BufNewFile,BufRead,BufEnter *.cdt set filetype=cpp ]]

vim._expand_pat('%')

vim.cmd[[ command! InsertHeader call v:lua.InsertHeader() ]]

vim.g.python3_host_prog = '/mnt/filer-a-7/disk2/terrier/cdequeker/Python-3.7.13/neovim_python/bin/python'
