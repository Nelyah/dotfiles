local fn = vim.fn

vim.cmd([[au TermOpen * setlocal nonumber norelativenumber]])

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

vim.keymap.set("i", "<m-b>", function()
    vim.cmd([[normal! b]])
    vim.cmd([[startinsert]])
end)

vim.keymap.set("i", "<m-f>", function()
    vim.cmd([[normal! w]])
    vim.cmd([[startinsert]])
end)

vim.keymap.set("i", "<c-b>", function()
    vim.cmd([[normal! i]])
end)

vim.keymap.set("i", "<c-f>", function()
    vim.cmd([[normal! la]])
end)

vim.keymap.set("i", "<c-e>", function()
    vim.cmd([[normal! A]])
end)

vim.keymap.set("i", "<c-a>", function()
    vim.cmd([[normal! 0i]])
end)

-- {{{ Command-line readline bindings (replaces readline.vim)
vim.keymap.set("c", "<C-a>", "<Home>")
vim.keymap.set("c", "<C-e>", "<End>")
vim.keymap.set("c", "<C-f>", "<Right>")
vim.keymap.set("c", "<C-b>", "<Left>")
vim.keymap.set("c", "<M-f>", "<S-Right>")
vim.keymap.set("c", "<M-b>", "<S-Left>")
vim.keymap.set("c", "<C-d>", "<Del>")

local kill_ring = ""

vim.keymap.set("c", "<C-k>", function()
    local line = vim.fn.getcmdline()
    local pos = vim.fn.getcmdpos()
    kill_ring = line:sub(pos)
    vim.fn.setcmdline(line:sub(1, pos - 1), pos)
end)

vim.keymap.set("c", "<C-u>", function()
    local line = vim.fn.getcmdline()
    local pos = vim.fn.getcmdpos()
    kill_ring = line:sub(1, pos - 1)
    vim.fn.setcmdline(line:sub(pos), 1)
end)

vim.keymap.set("c", "<C-y>", function()
    local line = vim.fn.getcmdline()
    local pos = vim.fn.getcmdpos()
    local new = line:sub(1, pos - 1) .. kill_ring .. line:sub(pos)
    vim.fn.setcmdline(new, pos + #kill_ring)
end)
-- }}}

-- {{{ Align text on pattern (replaces tabular)
local function align_on(pattern)
    local s, e = vim.fn.line("'<"), vim.fn.line("'>")
    local lines = vim.api.nvim_buf_get_lines(0, s - 1, e, false)
    local max = 0
    for _, l in ipairs(lines) do
        local p = l:find(pattern)
        if p and p > max then max = p end
    end
    local out = {}
    for _, l in ipairs(lines) do
        local p = l:find(pattern)
        if p then
            table.insert(out, l:sub(1, p - 1) .. string.rep(" ", max - p) .. l:sub(p))
        else
            table.insert(out, l)
        end
    end
    vim.api.nvim_buf_set_lines(0, s - 1, e, false, out)
end
vim.keymap.set("v", "<Leader>T=", function() align_on("=") end)
-- }}}

-- {{{ File commands (replaces vim-eunuch)
vim.api.nvim_create_autocmd("BufWritePost", {
    callback = function()
        local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""
        if first_line:match("^#!%s*%S") then
            local file = vim.fn.expand("%:p")
            local stat = vim.uv.fs_stat(file)
            if stat and bit.band(stat.mode, 0x49) == 0 then
                vim.fn.system({ "chmod", "+x", file })
            end
        end
    end,
})

vim.api.nvim_create_user_command("Rename", function(opts)
    local old = vim.fn.expand("%:p")
    local dir = vim.fn.expand("%:p:h")
    local new = dir .. "/" .. opts.args
    vim.fn.rename(old, new)
    vim.cmd("edit " .. vim.fn.fnameescape(new))
    vim.cmd("bdelete! #")
end, { nargs = 1, complete = "file" })

vim.api.nvim_create_user_command("Delete", function()
    local path = vim.fn.expand("%:p")
    vim.cmd("bdelete!")
    vim.fn.delete(path)
end, {})

vim.api.nvim_create_user_command("Move", function(opts)
    local old = vim.fn.expand("%:p")
    local new = opts.args
    local dir = vim.fn.fnamemodify(new, ":h")
    vim.fn.mkdir(dir, "p")
    vim.fn.rename(old, new)
    vim.cmd("edit " .. vim.fn.fnameescape(new))
    vim.cmd("bdelete! #")
end, { nargs = 1, complete = "file" })

vim.api.nvim_create_user_command("Mkdir", function(opts)
    vim.fn.mkdir(opts.args, "p")
end, { nargs = 1, complete = "dir" })

vim.api.nvim_create_user_command("Chmod", function(opts)
    vim.fn.system({ "chmod", opts.args, vim.fn.expand("%:p") })
end, { nargs = 1 })
-- }}}

-- {{{ Git commands (replaces vim-fugitive)
vim.api.nvim_create_user_command("Git", function(opts)
    local cmd = "git " .. opts.args
    cmd = cmd:gsub("%%", vim.fn.expand("%%:p"))
    vim.cmd("!" .. cmd)
end, { nargs = "+", complete = "file" })

vim.api.nvim_create_user_command("Blame", function()
    require("gitsigns").blame()
end, {})
-- }}}
