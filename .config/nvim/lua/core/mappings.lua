local fn = vim.fn

-- To fix spelling mistakes
vim.keymap.set("n", "z-", "z=1<enter><enter>", { desc = "Correct spelling with the first suggestion" })

vim.keymap.set("n", "<Leader>fi", "<cmd>e $MYVIMRC<CR>", { desc = "Edit Neovim configuration" })
vim.keymap.set("n", "<Leader>fd", "<cmd>lcd %:h<CR>", { desc = "Set window directory to the current file directory" })

vim.keymap.set("n", "<down>", "<cmd>cnext<CR>", { desc = "Go to next quickfix item" })
vim.keymap.set("n", "<up>", "<cmd>cprevious<CR>", { desc = "Go to previous quickfix item" })

-- Filetype, requires FT command defined for FzfLua
vim.keymap.set("n", "<Leader>m", "<cmd>FT<CR>", { desc = "Choose buffer filetype" })

local function close_all_other_windows()
  -- Check if the current window is a floating window
  local current_win = vim.api.nvim_get_current_win()
  local win_config = vim.api.nvim_win_get_config(current_win)
  if not win_config.relative or win_config.relative == "" then
    vim.cmd("only")
    return
  end

  local float_buf = vim.api.nvim_win_get_buf(current_win)
  -- Ensure the buffer is listed. This ensure that the buffer stays
  -- open even if we switch to another buffer. (Not the case by default
  -- if we had switched to a temporary buffer)
  vim.api.nvim_buf_set_option(float_buf, 'buflisted', true)

  local cursor_pos = vim.api.nvim_win_get_cursor(current_win)

  -- Get the parent window (the window that is not floating)
  local parent_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if not config.relative or config.relative == "" then
      parent_win = win
      break
    end
  end

  if not parent_win then
    print("No parent window found. That is a bug.")
    return
  end

  -- Switch the parent window to use the buffer from the floating window
  vim.api.nvim_win_set_buf(parent_win, float_buf)

  -- Restore the cursor position in the parent window
  vim.api.nvim_win_set_cursor(parent_win, cursor_pos)

  -- Close all other windows
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if win ~= parent_win then
      vim.api.nvim_win_close(win, true)
    end
  end
end


vim.keymap.set("n", "<Leader>k", "<cmd>q<CR>", { desc = "Close window" })
vim.keymap.set("n", "<Leader>1", close_all_other_windows, { desc = "Keep current buffer and close other windows" })
vim.keymap.set("n", "<Leader>2", "<cmd>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<Leader>3", "<cmd>vsplit<CR>", { desc = "Split window vertically" })

-- Select whole buffer
vim.keymap.set("n", "gV", "`[V`]", { desc = "Select last changed or yanked lines" })
-- Copy whole buffer to system clipboard
vim.keymap.set("n", "<leader>gV", '`[V`]"+y <c-o>', { desc = "Copy last changed or yanked lines to clipboard" })

vim.keymap.set("n", ";", ":", { desc = "Enter command-line mode" })

-- Performs a regular search
vim.keymap.set("n", "<leader>d", "/\\v", { silent = false, desc = "Search with very magic patterns" })
vim.keymap.set("i", "kj", "<esc>", { desc = "Leave insert mode" })
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Leave terminal mode" })

-- Navigate display lines
vim.keymap.set("n", "j", "gj", { desc = "Move down one display line" })
vim.keymap.set("n", "k", "gk", { desc = "Move up one display line" })
vim.keymap.set("v", "j", "gj", { desc = "Move down one display line" })
vim.keymap.set("v", "k", "gk", { desc = "Move up one display line" })

-- If using a count to move up or down, ignore display lines
vim.keymap.set("n", "k", 'v:count == 0 ? "gk" : "\\<Esc>".v:count."k"', { expr = true, desc = "Move up by display line or counted buffer lines" })
vim.keymap.set("n", "j", 'v:count == 0 ? "gj" : "\\<Esc>".v:count."j"', { expr = true, desc = "Move down by display line or counted buffer lines" })

vim.keymap.set({ "n", "v" }, "H", "5h", { desc = "Move left five characters" })
vim.keymap.set({ "n", "v" }, "J", "5j", { desc = "Move down five lines" })
vim.keymap.set({ "n", "v" }, "K", "5k", { desc = "Move up five lines" })
vim.keymap.set({ "n", "v" }, "L", "5l", { desc = "Move right five characters" })
vim.keymap.set("n", "<c-j>", "J", { desc = "Join lines" })
vim.keymap.set("n", "<c-h>", "H", { desc = "Move to top of screen" })
vim.keymap.set("n", "<c-l>", "L", { desc = "Move to bottom of screen" })
vim.keymap.set("n", "<c-m>", "M", { desc = "Move to middle of screen" })

vim.keymap.set("n", "<c-e>", "7<c-e>", { desc = "Scroll down seven lines" })
vim.keymap.set("n", "<c-y>", "7<c-y>", { desc = "Scroll up seven lines" })
vim.keymap.set("v", "<c-e>", "7<c-e>", { desc = "Scroll down seven lines" })
vim.keymap.set("v", "<c-y>", "7<c-y>", { desc = "Scroll up seven lines" })

vim.keymap.set("n", "Y", "y$", { desc = "Yank to end of line" })

-- Saving
vim.keymap.set("n", "<Leader>w", "<cmd>w<CR>", { desc = "Save buffer" })

-- Copy to clipboard
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Copy selection to clipboard" })
vim.keymap.set("n", "<leader>y", '"+y', { desc = "Copy motion to clipboard" })
vim.keymap.set("n", "<leader>p", 'o<esc>"+gp', { desc = "Paste clipboard on a new line below" })

-- Align blocks of texte and keep them selected
vim.keymap.set("v", "<", "<gv", { desc = "Indent selection left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent selection right and reselect" })

vim.keymap.set("n", "<Leader>l", "<cmd>bn<CR>", { desc = "Go to next buffer" })
vim.keymap.set("n", "<Leader>h", "<cmd>bp<CR>", { desc = "Go to previous buffer" })

-- Close the current buffer and move to the previous one
vim.keymap.set("n", "<Leader>q", "<cmd>bp <BAR> bd #<CR>", { desc = "Close buffer and switch to previous buffer" })

-- Turn off highlight after search
vim.keymap.set("n", "<Leader>a", "<cmd>noh<CR>", { desc = "Clear search highlights" })

-- Resize window
vim.keymap.set("n", "<c-up>", "<c-w>3+", { desc = "Increase window height by three lines" })
vim.keymap.set("n", "<c-down>", "<c-w>3-", { desc = "Decrease window height by three lines" })
vim.keymap.set("n", "<c-left>", "<c-w>3<", { desc = "Decrease window width by three columns" })
vim.keymap.set("n", "<c-right>", "<c-w>3>", { desc = "Increase window width by three columns" })

vim.keymap.set("n", "ge", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({bufnr = 0})) end, { desc = "Toggle LSP inlay hints" })

-- {{{ Pasting without replacing register

local restore_reg = nil
_G.restore_register = function()
    fn.setreg('"', restore_reg)
    return ""
end

vim.keymap.set("v", "p", function()
    restore_reg = fn.getreg('"')
    return "p@=v:lua.restore_register()\
"
end, { expr = true, desc = "Paste over selection and preserve unnamed register" })
-- }}}

vim.keymap.set("i", "<s-Tab>", function()
    return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true, desc = "Select previous completion item or insert Shift-Tab" })

vim.keymap.set("i", "<Tab>", function()
    return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true, desc = "Select next completion item or insert Tab" })
