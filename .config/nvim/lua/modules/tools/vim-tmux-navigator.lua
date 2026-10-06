local M = {}

function M.setup()
    vim.g.tmux_navigator_no_mappings = 1

    vim.keymap.set("n", "<m-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Focus left Vim or tmux pane" })
    vim.keymap.set("n", "<m-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Focus lower Vim or tmux pane" })
    vim.keymap.set("n", "<m-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Focus upper Vim or tmux pane" })
    vim.keymap.set("n", "<m-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Focus right Vim or tmux pane" })
    vim.keymap.set("n", "<m-\\>", "<cmd>TmuxNavigatePrevious<cr>", { desc = "Focus previous Vim or tmux pane" })

    vim.keymap.set("t", "<m-h>", "<C-\\><C-n><cmd>TmuxNavigateLeft<cr>", { desc = "Focus left Vim or tmux pane" })
    vim.keymap.set("t", "<m-j>", "<C-\\><C-n><cmd>TmuxNavigateDown<cr>", { desc = "Focus lower Vim or tmux pane" })
    vim.keymap.set("t", "<m-k>", "<C-\\><C-n><cmd>TmuxNavigateUp<cr>", { desc = "Focus upper Vim or tmux pane" })
    vim.keymap.set("t", "<m-l>", "<C-\\><C-n><cmd>TmuxNavigateRight<cr>", { desc = "Focus right Vim or tmux pane" })
    vim.keymap.set("t", "<m-\\>", "<C-\\><C-n><cmd>TmuxNavigatePrevious<cr>", { desc = "Focus previous Vim or tmux pane" })
end

return M
