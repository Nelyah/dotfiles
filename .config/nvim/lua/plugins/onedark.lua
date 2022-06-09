local M = {}

function M.setup ()
    require('onedark').setup()
    vim.cmd[[colorscheme onedark]]
    vim.cmd[[highlight IncSearch guibg=#135564 guifg=white]]
    vim.cmd[[highlight Search guibg=#135564 guifg=white]]
    vim.cmd[[highlight Folded guibg=default guifg=grey]]
    vim.cmd[[hi default LspCxxHlGroupNamespace ctermfg=Yellow guifg=#E5C07B cterm=none gui=none]]
    vim.cmd[[hi default LspCxxHlGroupMemberVariable ctermfg=White guifg=#F16E77]]
end

return M
