local M = {}

local wincmd_keys = { left = "h", down = "j", up = "k", right = "l" }
local tmux_cmds = { left = "TmuxNavigateLeft", down = "TmuxNavigateDown", up = "TmuxNavigateUp", right = "TmuxNavigateRight" }

-- Pick the innermost multiplexer. herdr strips $TMUX from its panes, so if
-- $TMUX is set, tmux is innermost (plain tmux, or tmux running inside herdr).
--   tmux  -> vim-tmux-navigator (also handles the no-neighbour case)
--   herdr -> move between Neovim splits, at the edge focus the herdr pane
--   none  -> vim-tmux-navigator, which degrades to plain wincmd
local function navigate(direction)
    local herdr_pane = vim.env.HERDR_PANE_ID
    if vim.env.TMUX ~= nil or herdr_pane == nil then
        vim.cmd(tmux_cmds[direction])
        return
    end
    local before = vim.api.nvim_get_current_win()
    vim.cmd("wincmd " .. wincmd_keys[direction])
    if vim.api.nvim_get_current_win() == before then
        vim.system({ vim.env.HERDR_BIN_PATH or "herdr", "pane", "focus", "--pane", herdr_pane, "--direction", direction })
    end
end

function M.setup()
    vim.g.tmux_navigator_no_mappings = 1

    local maps = {
        { "<m-h>", "left", "Focus left Vim or herdr/tmux pane" },
        { "<m-j>", "down", "Focus lower Vim or herdr/tmux pane" },
        { "<m-k>", "up", "Focus upper Vim or herdr/tmux pane" },
        { "<m-l>", "right", "Focus right Vim or herdr/tmux pane" },
    }
    for _, map in ipairs(maps) do
        local lhs, direction, desc = map[1], map[2], map[3]
        vim.keymap.set("n", lhs, function() navigate(direction) end, { desc = desc })
        vim.keymap.set("t", lhs, function()
            vim.cmd("stopinsert")
            navigate(direction)
        end, { desc = desc })
    end

    vim.keymap.set("n", "<m-\\>", "<cmd>TmuxNavigatePrevious<cr>", { desc = "Focus previous Vim or tmux pane" })
    vim.keymap.set("t", "<m-\\>", "<C-\\><C-n><cmd>TmuxNavigatePrevious<cr>", { desc = "Focus previous Vim or tmux pane" })
end

return M
