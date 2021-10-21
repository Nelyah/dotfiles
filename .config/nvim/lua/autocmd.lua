local utils = require('utils')
local fn = vim.fn

vim.cmd[[au TermOpen * setlocal nonumber norelativenumber]]
vim.cmd[[au TermOpen * normal i]]


vim.cmd[[ au BufNewFile,BufRead CMakeLists.txt set filetype=cmake ]]


vim.cmd[[ command! ThumbsDown :norm i👎<esc> ]]
vim.cmd[[ command! ThumbsUp :norm i👍<esc> ]]

-- Auto-source the nvim config when written
-- vim.cmd[[ autocmd! BufWritePost $MYVIMRC :source $MYVIMRC ]]

vim.cmd[[ autocmd! BufEnter,BufWinEnter,WinEnter term://* startinsert ]]


-- Used for filetype specific editing
vim.cmd [[ autocmd! FileType tex,mail set spell ]]
vim.cmd [[ autocmd! FileType vimwiki,tex,mail set spelllang=en_gb,fr,es ]]
vim.cmd [[ autocmd! FileType tex set iskeyword+=:,- ]]



-- Open the help buffer as a right split
-- @todo: Fix unwanted behaviour when opening twice the helper
--        with FzfLua.
vim.cmd[[ autocmd! FileType help wincmd L ]]

vim.cmd[[ command! -nargs=1 Ssh :r scp://<args>/ ]]

-- {{{ Git
-- Git rebase bindings
utils.create_augroup('git_rebase', {
    'FileType gitrebase nnoremap <Leader>p ciwpick<esc>0',
    'FileType gitrebase nnoremap <Leader>r ciwreword<esc>0',
    'FileType gitrebase nnoremap <Leader>e ciwedit<esc>0',
    'FileType gitrebase nnoremap <Leader>s ciwsquash<esc>0',
    'FileType gitrebase nnoremap <Leader>f ciwfixup<esc>0',
    'FileType gitrebase nnoremap <Leader>x ciwexec<esc>0',
    'FileType gitrebase nnoremap <Leader>b ciwbreak<esc>0',
    'FileType gitrebase nnoremap <Leader>d ciwdrop<esc>0',
    'FileType gitrebase nnoremap <Leader>l ciwlabel<esc>0',
    'FileType gitrebase nnoremap <Leader>t ciwreset<esc>0',
    'FileType gitrebase nnoremap <Leader>m ciwmerge<esc>0',
    'FileType gitrebase %s/^pick \\([a-z0-9]\\+\\) drop! /drop \1 /e',
})
-- }}}
-- {{{ Mail
-- Go to the pattern if exists, else adds it on the first line
_G.MailJumpToField = function (field)
    local line_pattern = fn.search('^' .. field .. ':')

    vim.api.nvim_win_set_cursor(0, {0, 1})

    if line_pattern == 0 then
        fn.append(0, field .. ':')
        vim.api.nvim_win_set_cursor(0, {0, utils.get_current_line_length()-1})
    else
        vim.api.nvim_win_set_cursor(0, {line_pattern, 0})
    end
end

utils.create_augroup('mail', {
    'FileType mail set textwidth=0',
    'FileType mail set wrapmargin=0',
    'FileType mail nnoremap <Leader>gt :call MailJumpToField("To")<CR>',
    'FileType mail nnoremap <Leader>gb :call MailJumpToField("Bcc:")<CR>',
    'FileType mail nnoremap <Leader>gc :call MailJumpToField("Cc:")<CR>',
    'FileType mail nnoremap <Leader>gs :call MailJumpToField("Subject:")<CR>',
})
-- }}}
