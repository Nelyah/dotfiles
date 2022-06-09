vim.g.mapleader = ' '
vim.opt.number = true                           -- line numbers

-- Remove 'latin1' from the default list because on large files, vim can't figure out
-- it needs to use 'utf-8' and not 'latin1'. This results in multi-byte characters not
-- being rendered correctly
vim.o.fileencodings = 'ucs-bom,utf-8,default'
vim.opt.encoding = 'utf-8'

vim.opt.autoread = true                         -- reload automatically a file if not changed
vim.opt.mouse = 'a'                             -- Use the mouse to slide panes size or scrolling, and copying
vim.opt.hidden = true                           -- Allow background buffers without saving
vim.opt.splitright = true                       -- Split appears on the right
vim.opt.splitbelow = true                       -- Split appears below
vim.opt.display = 'lastline'                    -- Display as much as possible as last line, instead of just showing @
vim.cmd[[hi CursorLineNr guifg=#dddddd]]

vim.opt.relativenumber = true                   -- show relative numbers in gutter
vim.opt.cursorline = true                       -- highlight current line
vim.opt.autoindent = true                       -- Enable automatic indent

vim.opt.autoread = true                          -- Automatically reload modified files
vim.opt.lazyredraw = true                       -- Don't redraw while executing macros, etc
vim.opt.cmdheight = 2                           -- Better display for messages
vim.opt.synmaxcol = 5000                        -- Only highlight first 1000 chars for better performance
vim.opt.complete = vim.opt.complete + 'kspell'

if (vim.fn.has("termguicolors")) then
    vim.opt.termguicolors = true
end

vim.opt.showmode = false                        -- Hide default mode text (i.e. INSERT below status line)
vim.opt.ruler = true                            -- Show cursor position in bottom right, only useful if not overriden by plugin


-- Default formatoptions in neovim: tcqj
-- t Wrap text using textwidth
-- c Wrap comments using textwidth, inserting comment leader automatically.
-- q Allow formatting of comments with "gq"
-- n Smart auto-indenting inside numbered lists
vim.opt.formatoptions = 'cqn'

-- Adding my own snippets
vim.opt.runtimepath = vim.opt.runtimepath + '~/.config/nvim/my-snippets/'

-- In case nvim doesn't recognise the tex flavour,
-- set this as default rather than falling back to plaintext
vim.g.tex_flavor = 'latex'

if vim.fn.executable('rg') then
    vim.g.grepprg='rg --vimgrep --no-heading --smart-case'
end

vim.opt.pumheight = 20 -- Maximum number of items to show in the popup menu


-- {{{ Temporary files
vim.opt.backupdir = {'$HOME/.config/nvim/backup', '/tmp'}

-- Some servers have issues with backup files, see #649
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- Keep undo history across sessions by storing it in a file
if (vim.fn.has('persistent_undo') == 1) then
  local is_root = vim.env.USER == 'root'
  if (is_root) then
    vim.opt.undofile = false  -- don't create root-owned files
  else
    vim.opt.undofile = true
  end
end
-- }}}
-- {{{ NetRW - VIM file explorer
vim.g.netrw_liststyle = 1   -- Detail View
vim.g.netrw_sizestyle = 'H' -- Human-readable file sizes
vim.g.netrw_banner = 0      -- Turn off banner
-- }}}
-- {{{ Search
vim.opt.incsearch = true      -- search as characters are entered
vim.opt.hlsearch = true       -- highlight matches
vim.opt.magic = true          -- For regex
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- }}}
-- {{{ Tab spec
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.backspace = {'indent', 'eol', 'start' }
-- }}}
-- {{{ Folds
vim.opt.foldenable = true
vim.opt.foldmethod = 'marker'
-- }}}
-- {{{ Wildmode completion in command
vim.opt.wildmode = 'full' -- Reasonable tab completion
vim.opt.wildignore = vim.opt.wildignore + {
    '*.o', '*.obj', '*.pyc',                                          -- Ignore autogenerated files
    '.git',                                                           -- Ignore source control
    'build', 'lib', 'node_modules', 'public', '_site', 'third_party', -- Ignore lib/ dirs since the contain compiled libraries typically
    '*.gif','*.jpg','*.jpeg','*.otf','*.png','*.svg','*.ttf','*.svg', -- Ignore images and fonts
}

vim.opt.wildignorecase = true -- Ignore case when completing
-- }}}

-- this allows to avoid having the blank separation between the characters in the
-- terminal
vim.opt.fillchars = {
  diff = '⣿', -- BOX DRAWINGS
  vert = '┃', -- HEAVY VERTICAL (U+2503, UTF-8: E2 94 83)
  fold = '─',
  msgsep = '‾',
  eob = ' ', -- Hide end of buffer ~
  foldopen = '▾',
  foldsep = '│',
  foldclose = '▸',
}
