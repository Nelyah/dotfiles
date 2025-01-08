local fn = vim.fn

-- To fix spelling mistakes
vim.keymap.set("n", "z-", "z=1<enter><enter>")

vim.keymap.set("n", "<Leader>fi", "<cmd>e $MYVIMRC<CR>")
vim.keymap.set("n", "<Leader>fd", "<cmd>lcd %:h<CR>")

vim.keymap.set("n", "<down>", "<cmd>cnext<CR>")
vim.keymap.set("n", "<up>", "<cmd>cprevious<CR>")

-- Filetype, requires FT command defined for FzfLua
vim.keymap.set("n", "<Leader>m", "<cmd>FT<CR>")

local function close_all_other_windows()
  -- Check if the current window is a floating window
  local current_win = vim.api.nvim_get_current_win()
  local win_config = vim.api.nvim_win_get_config(current_win)
  if not win_config.relative or win_config.relative == "" then
    vim.cmd("only")
    return
  end

  -- Get the buffer number of the current floating window
  local float_buf = vim.api.nvim_win_get_buf(current_win)
  -- Ensure the buffer is listed
  vim.api.nvim_buf_set_option(float_buf, 'buflisted', true)

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

  -- Close all other windows
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if win ~= parent_win then
      vim.api.nvim_win_close(win, true)
    end
  end
end


vim.keymap.set("n", "<Leader>k", "<cmd>q<CR>")
vim.keymap.set("n", "<Leader>1", close_all_other_windows)
vim.keymap.set("n", "<Leader>2", "<cmd>split<CR>")
vim.keymap.set("n", "<Leader>3", "<cmd>vsplit<CR>")

-- Select whole buffer
vim.keymap.set("n", "gV", "`[V`]")
-- Copy whole buffer to system clipboard
vim.keymap.set("n", "<leader>gV", '`[V`]"+y <c-o>')

vim.keymap.set("n", ";", ":")

-- Performs a regular search
vim.keymap.set("n", "<leader>d", "/\\v", { silent = false })
vim.keymap.set("i", "kj", "<esc>")
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

-- Switching panes using the meta key
vim.keymap.set("n", "<M-h>", "<C-w>h")
vim.keymap.set("n", "<M-j>", "<C-w>j")
vim.keymap.set("n", "<M-k>", "<C-w>k")
vim.keymap.set("n", "<M-l>", "<C-w>l")

-- Navigate display lines
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
vim.keymap.set("v", "j", "gj")
vim.keymap.set("v", "k", "gk")

-- If using a count to move up or down, ignore display lines
vim.keymap.set("n", "k", 'v:count == 0 ? "gk" : "\\<Esc>".v:count."k"', { expr = true })
vim.keymap.set("n", "j", 'v:count == 0 ? "gj" : "\\<Esc>".v:count."j"', { expr = true })

vim.keymap.set({ "n", "v" }, "H", "5h")
vim.keymap.set({ "n", "v" }, "J", "5j")
vim.keymap.set({ "n", "v" }, "K", "5k")
vim.keymap.set({ "n", "v" }, "L", "5l")
vim.keymap.set("n", "<c-j>", "J")
vim.keymap.set("n", "<c-h>", "H")
vim.keymap.set("n", "<c-l>", "L")
vim.keymap.set("n", "<c-m>", "M")

vim.keymap.set("n", "<c-e>", "7<c-e>")
vim.keymap.set("n", "<c-y>", "7<c-y>")
vim.keymap.set("v", "<c-e>", "7<c-e>")
vim.keymap.set("v", "<c-y>", "7<c-y>")

vim.keymap.set("n", "Y", "y$")

-- Saving
vim.keymap.set("n", "<Leader>w", "<cmd>w<CR>")

-- Copy to clipboard
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>p", 'o<esc>"+gp')

-- Align blocks of texte and keep them selected
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

vim.keymap.set("n", "<Leader>l", "<cmd>bn<CR>")
vim.keymap.set("n", "<Leader>h", "<cmd>bp<CR>")

-- Close the current buffer and move to the previous one
vim.keymap.set("n", "<Leader>q", "<cmd>bp <BAR> bd #<CR>")

-- Turn off highlight after search
vim.keymap.set("n", "<Leader>a", "<cmd>noh<CR>")

-- Resize window
vim.keymap.set("n", "<c-up>", "<c-w>3+")
vim.keymap.set("n", "<c-down>", "<c-w>3-")
vim.keymap.set("n", "<c-left>", "<c-w>3<")
vim.keymap.set("n", "<c-right>", "<c-w>3>")

vim.keymap.set("n", "ge", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({bufnr = 0})) end)

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
end, { expr = true })
-- }}}

vim.keymap.set("i", "<s-Tab>", function()
    return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })

vim.keymap.set("i", "<Tab>", function()
    return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })
vim.keymap.set("i", "<Tab>", function()
    return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })
