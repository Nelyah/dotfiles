local fn = vim.fn

vim.cmd([[au TermOpen * setlocal nonumber norelativenumber]])
vim.cmd([[au TermOpen * normal i]])

vim.cmd([[ au BufNewFile,BufRead CMakeLists.txt set filetype=cmake ]])

vim.cmd([[ command! ThumbsDown :norm i👎 <esc> ]])
vim.cmd([[ command! ThumbsUp :norm i👍 <esc> ]])

-- Auto-source the nvim config when written
-- vim.cmd[[ autocmd! BufWritePost $MYVIMRC :source $MYVIMRC ]]

vim.cmd([[ autocmd! BufEnter,BufWinEnter,WinEnter term://* startinsert ]])

-- Used for filetype specific editing
vim.cmd([[ autocmd! FileType tex,mail set spell ]])
vim.cmd([[ autocmd! FileType vimwiki,tex,mail set spelllang=en_gb,fr,es ]])
vim.cmd([[ autocmd! FileType tex set iskeyword+=:,- ]])

-- Open the help buffer as a right split
-- @todo: Fix unwanted behaviour when opening twice the helper
--        with FzfLua.
vim.cmd([[ autocmd! FileType help wincmd L ]])

vim.cmd([[ command! -nargs=1 Ssh :r scp://<args>/ ]])

-- {{{ Git
-- Git rebase bindings
vim.api.nvim_create_autocmd("Filetype", {
    group = vim.api.nvim_create_augroup("git_rebase_mappings", { clear = true }),
    pattern = { "gitrebase" },
    callback = function()
        vim.keymap.set("n", "<Leader>p", "ciwpick<esc>0")
        vim.keymap.set("n", "<Leader>r", "ciwreword<esc>0")
        vim.keymap.set("n", "<Leader>e", "ciwedit<esc>0")
        vim.keymap.set("n", "<Leader>s", "ciwsquash<esc>0")
        vim.keymap.set("n", "<Leader>f", "ciwfixup<esc>0")
        vim.keymap.set("n", "<Leader>x", "ciwexec<esc>0")
        vim.keymap.set("n", "<Leader>b", "ciwbreak<esc>0")
        vim.keymap.set("n", "<Leader>d", "ciwdrop<esc>0")
        vim.keymap.set("n", "<Leader>l", "ciwlabel<esc>0")
        vim.keymap.set("n", "<Leader>t", "ciwreset<esc>0")
        vim.keymap.set("n", "<Leader>m", "ciwmerge<esc>0")
        vim.cmd([[%s/^pick \\([a-z0-9]\\+\\) drop! /drop \1 /e]])
    end,
})
-- }}}
-- {{{ Mail
-- Go to the pattern if exists, else adds it on the first line
local mailJumpToField = function(field)
    local line_pattern = fn.search("^" .. field .. ":")

    vim.api.nvim_win_set_cursor(0, { 0, 1 })

    if line_pattern == 0 then
        fn.append(0, field .. ":")
        vim.api.nvim_win_set_cursor(0, { 0, string.len(vim.api.nvim_get_current_line()) - 1 })
    else
        vim.api.nvim_win_set_cursor(0, { line_pattern, 0 })
    end
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("mail_autocmd", { clear = true }),
    pattern = "mail",
    callback = function()
        vim.bo.textwidth = 0
        vim.keymap.set("n", "<Leader>gt", function()
            mailJumpToField("To")
        end)
        vim.keymap.set("n", "<Leader>gb", function()
            mailJumpToField("Bcc:")
        end)
        vim.keymap.set("n", "<Leader>gc", function()
            mailJumpToField("Cc:")
        end)
        vim.keymap.set("n", "<Leader>gs", function()
            mailJumpToField("Subject:")
        end)
    end,
})

-- }}}
