local M = {}

function M.setup()
    vim.g.tmux_navigator_no_mappings = 1

    vim.keymap.set("n", "<m-h>", "<cmd>TmuxNavigateLeft<cr>")
    vim.keymap.set("n", "<m-j>", "<cmd>TmuxNavigateDown<cr>")
    vim.keymap.set("n", "<m-k>", "<cmd>TmuxNavigateUp<cr>")
    vim.keymap.set("n", "<m-l>", "<cmd>TmuxNavigateRight<cr>")
    vim.keymap.set("n", "<m-\\>", "<cmd>TmuxNavigatePrevious<cr>")

    vim.keymap.set("t", "<m-h>", "<C-\\><C-n><cmd>TmuxNavigateLeft<cr>")
    vim.keymap.set("t", "<m-j>", "<C-\\><C-n><cmd>TmuxNavigateDown<cr>")
    vim.keymap.set("t", "<m-k>", "<C-\\><C-n><cmd>TmuxNavigateUp<cr>")
    vim.keymap.set("t", "<m-l>", "<C-\\><C-n><cmd>TmuxNavigateRight<cr>")
    vim.keymap.set("t", "<m-\\>", "<C-\\><C-n><cmd>TmuxNavigatePrevious<cr>")
end

return M
