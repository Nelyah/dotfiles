local M = {}
local utils = require('utils')

function M.setup ()
    require('onedark').setup()
    vim.cmd[[colorscheme onedark]]
    vim.cmd[[highlight IncSearch guibg=#135564 guifg=white]]
    vim.cmd[[highlight Search guibg=#135564 guifg=white]]
    vim.cmd[[highlight Folded guibg=default guifg=grey]]
end

return M
