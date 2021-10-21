local utils = require('utils')
local fn = vim.fn

-- To fix spelling mistakes
utils.nnoremap('z-', 'z=1<enter><enter>')

utils.nnoremap('<Leader>fi', ':e $MYVIMRC<CR>')
utils.nnoremap('<Leader>fd', ':lcd %:h<CR>')

utils.nnoremap('<down>', ':cnext<CR>')
utils.nnoremap('<up>', ':cprevious<CR>')

-- Filetype, requires FT command defined for FzfLua
utils.nnoremap('<Leader>m', ':FT<CR>')

utils.nnoremap('<Leader>k', ':q<CR>')
utils.nnoremap('<Leader>1', ':only<CR>')
utils.nnoremap('<Leader>2', ':split<CR>')
utils.nnoremap('<Leader>3', ':vsplit<CR>')

-- Select whole buffer
utils.nnoremap('gV', '`[V`]')
-- Copy whole buffer to system clipboard
utils.nnoremap('<leader>gV', '`[V`]"+y <c-o>')

utils.nnoremap(';', ':')

-- Performs a regular search
utils.nnoremap('<leader>d', '/\\v', {silent = false})
utils.inoremap('kj', '<esc>')
utils.tnoremap('<Esc>', '<C-\\><C-n>')

-- Switching panes using the meta key
utils.nnoremap('<M-h>', '<C-w>h')
utils.nnoremap('<M-j>', '<C-w>j')
utils.nnoremap('<M-k>', '<C-w>k')
utils.nnoremap('<M-l>', '<C-w>l')

-- Navigate display lines
utils.nnoremap('j', 'gj')
utils.nnoremap('k', 'gk')
utils.vnoremap('j', 'gj')
utils.vnoremap('k', 'gk')

-- If using a count to move up or down, ignore display lines
utils.vnoremap('k', 'v:count == 0 ? "gk" : "\\<Esc>".v:count."k"', {expr = true})
utils.vnoremap('j', 'v:count == 0 ? "gj" : "\\<Esc>".v:count."j"', {expr = true})
utils.nnoremap('k', 'v:count == 0 ? "gk" : "\\<Esc>".v:count."k"', {expr = true})
utils.nnoremap('j', 'v:count == 0 ? "gj" : "\\<Esc>".v:count."j"', {expr = true})

utils.noremap('H', '5h')
utils.noremap('J', '5j')
utils.noremap('K', '5k')
utils.noremap('L', '5l')
utils.nnoremap('<c-j>', 'J')
utils.nnoremap('<c-h>', 'H')
utils.nnoremap('<c-l>', 'L')
utils.nnoremap('<c-m>', 'M')

utils.nnoremap('<c-e>', '7<c-e>')
utils.nnoremap('<c-y>', '7<c-y>')
utils.vnoremap('<c-e>', '7<c-e>')
utils.vnoremap('<c-y>', '7<c-y>')

utils.nnoremap('Y', 'y$')

-- Saving
utils.nnoremap('<Leader>w', ':w<CR>')

-- Copy to clipboard
utils.vnoremap('<leader>y', '"+y')
utils.nnoremap('<leader>y', '"+y')
utils.nnoremap('<leader>p', 'o<esc>"+gp')

-- Align blocks of texte and keep them selected
utils.vnoremap('<', '<gv')
utils.vnoremap('>', '>gv')

utils.nnoremap('<Leader>l', ':bn<CR>')
utils.nnoremap('<Leader>h', ':bp<CR>')

-- Close the current buffer and move to the previous one
utils.nnoremap('<Leader>q', ':bp <BAR> bd #<CR>')

-- Turn off highlight after search
utils.nnoremap('<Leader>a', ':noh<CR>')

-- Resize window
utils.nnoremap('<c-up>', '<c-w>3+')
utils.nnoremap('<c-down>', '<c-w>3-')
utils.nnoremap('<c-left>', '<c-w>3<')
utils.nnoremap('<c-right>', '<c-w>3>')

-- {{{ Pasting without replacing register

local restore_reg = nil
_G.restore_register = function()
    fn.setreg('"', restore_reg)
    return ''
end
_G.replace_value_with_register = function()
    restore_reg = fn.getreg('"')
    return "p@=v:lua.restore_register()\"
end

utils.vnoremap('p', 'v:lua.replace_value_with_register()', {expr = true})
-- }}}

utils.inoremap('<s-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<S-Tab>"', {expr = true})
utils.inoremap('<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true})
