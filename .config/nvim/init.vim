"{{{ Plugins

" check whether vim-plug is installed and install it if necessary
let g:vimdir = expand('<sfile>:p:h')
let plugpath = g:vimdir . '/autoload/plug.vim'
if !filereadable(plugpath)
    if executable('curl')
        let plugurl = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        call system('curl -fLo ' . shellescape(plugpath) . ' --create-dirs ' . plugurl)
        if v:shell_error
            echom "Error downloading vim-plug. Please install it manually.\n"
            exit
        endif
        echom "Installing plugins"
        autocmd VimEnter * PlugInstall --sync
    else
        echom "vim-plug not installed. Please install it manually or install curl.\n"
        exit
    endif
endif


" Required:
call plug#begin('~/.config/nvim/plugged')

    Plug 'junegunn/fzf.vim'                                              " Fuzzy search everything
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }    " Install FZF
    Plug 'easymotion/vim-easymotion'                                     " Easily search and move around the buffer
    Plug 'christoomey/vim-tmux-navigator'                                " Sane binding to navigate between vim and tmux
    Plug 'SirVer/ultisnips'                                              " Interface for Snippets
    Plug 'honza/vim-snippets'                                            " Provide with many Snippets to Ultisnips
    Plug 'terryma/vim-expand-region'                                     " Extend visual selection by increasing text objects
    Plug 'terryma/vim-multiple-cursors'                                  " Adding multiple cursors with <c-n>
    Plug 'Raimondi/delimitMate'                                          " For parenthesis completion
    Plug 'skywind3000/asyncrun.vim'

    """"""""""""""""
    "  Completion  "
    """"""""""""""""
    Plug 'neovim/nvim-lsp'                                               " Enable the Neovim built-in LSP
    Plug 'neovim/nvim-lspconfig'                                         " Set of configuration for the Neovim LSP
    Plug 'hrsh7th/nvim-compe'                                            " Tool for providing autocompletion interface
    Plug 'nvim-treesitter/nvim-treesitter'                               " Enable TreeSitter
    Plug 'nvim-treesitter/completion-treesitter'                         " Add TreeSitter as an autocompletion source

    Plug 'ludovicchabant/vim-gutentags'                                  " (Re)generate tags automatically
    Plug 'godlygeek/tabular'                                             " Tabuliarise and align based on pattern
    Plug 'unblevable/quick-scope'                                        " Highlight matches when pressing 'f' or 'F'

    Plug 'tpope/vim-commentary'                                          " comments based on the file type
    Plug 'tpope/vim-surround'                                            " Add/change/remove quotes and stuff around objects
    Plug 'tpope/vim-sensible'                                            " Sensible defaults for [n]vim
    Plug 'tpope/vim-repeat'                                              " Allows for more complicated repeat using '.'
    Plug 'tpope/vim-eunuch'                                              " Provide with basic commands (chmod, rename, etc...)
    Plug 'tpope/vim-fugitive'                                            " Git Interface
    Plug 'lewis6991/gitsigns.nvim', {'branch': 'main'}                   " git info on the sign column
    Plug 'ryvnf/readline.vim'                                            " Brings readline mappings to ex command

    """""""""""""""
    "  Interface  "
    """""""""""""""
    Plug 'ap/vim-css-color'                                              " Color highlighter
    Plug 'navarasu/onedark.nvim'                                         " Colour scheme
    Plug 'ryanoasis/vim-devicons'                                        " Collection of devicons required from some plugins to correctly show 
    Plug 'hoob3rt/lualine.nvim'                                          " Lua line to show info at the bottom and organise the top bar as well
    Plug 'kdheepak/tabline.nvim'                                         " Fill the top bar with buffers and tabs

    """""""""""""""""""""""
    "  Language specific  "
    """""""""""""""""""""""
    Plug 'sheerun/vim-polyglot'                                          " Provide many language syntax highlighting

    Plug 'vim-python/python-syntax', {'for': 'python'}                   " Better Python syntax highlighting
    Plug 'tmhedberg/SimpylFold', {'for': 'python'}                       " Better folding in python for docstrings and such
    Plug 'Vigemus/iron.nvim', {'for': 'python'}                          " Interactive REPL over Neovim
    Plug 'rhysd/vim-clang-format', {'for': 'cpp'}
    Plug 'jackguo380/vim-lsp-cxx-highlight', {'for': ['c', 'cpp']}

    Plug 'dhruvasagar/vim-table-mode', {'for': ['markdown', 'pandoc', 'vimwiki.markdown']}      " Add a table mode for writing them in markdown
    Plug 'plasticboy/vim-markdown', {'for': ['markdown', 'pandoc', 'vimwiki.markdown']}      " Many conceal and folding features for Markdown
    Plug 'shime/vim-livedown', {'for': ['markdown', 'pandoc']}

    Plug 'lervag/vimtex', {'for': ['tex', 'latex']}                      " Many LateX features
    Plug 'ymatz/vim-latex-completion', {'for': ['tex', 'latex']}         " Better LateX completion

    """""""""""""""""""""
    "  Integrated apps  "
    """""""""""""""""""""
    Plug 'vimwiki/vimwiki'                                               " Wiki for vim
    Plug 'scrooloose/nerdtree', {'on':  'NERDTreeToggle'}                " NERDtree loaded on toggle
    Plug 'Xuyuanp/nerdtree-git-plugin', {'on':  'NERDTreeToggle'}        " Add git markers for the Nerdtree plugin
    Plug 'majutsushi/tagbar', {'on': 'TagbarToggle'}                     " Opens a tagbar on the right side
    Plug 'junegunn/goyo.vim', {'on': 'Goyo'}                             " Clean interface for writing prose

    Plug 'nvim-lua/plenary.nvim'                                         " Set of Lua functions used by plugins

    Plug 'rhysd/vim-grammarous', {'on': 'GrammarousCheck'}               " Grammar check

    Plug 'tomtom/tlib_vim'                                               " Some script library that may be required by other plugins
    Plug 'Shougo/vimproc.vim', {'build': 'make'}                         " Provide with some async function (and a library of functions)

call plug#end()
" }}}

" {{{ Basic VIM modifications
au TermOpen * setlocal nonumber norelativenumber
au TermOpen * normal i
" set t_Co=256
set number              " line numbers
set encoding=utf-8

set autoindent
set autoread            " reload automatically a file if not changed


" Keep undo history across sessions by storing it in a file
if has('persistent_undo')
  if exists('$SUDO_USER')
    set noundofile                    " don't create root-owned files
  else
    set undodir=~/.config/nvim/tmp/undo       " keep undo files out of the way
    set undodir+=.
    set undofile                      " actually use undo files
  endif
endif

" Adding my own snippets
set runtimepath+=~/.config/nvim/my-snippets/

" vim tmp files
set directory=$HOME/.config/nvim/swap,/tmp
set backupdir=$HOME/.config/nvim/backup,/tmp
set undodir=$HOME/.config/nvim/undo,/tmp
" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup
if exists('$SUDO_USER')
  set noswapfile                      " don't create root-owned files
else
  set directory=~/.config/nvim/tmp/swap/     " keep swap files out of the way
  set directory+=.
endif
set noswapfile                      " don't create root-owned files

" mapping the 'super' button on space
let mapleader = "\<Space>"

" To fix spelling mistakes
nnoremap z- z=1<enter><enter>

""" NetRW - VIM file explorer
let g:netrw_liststyle = 1 " Detail View
let g:netrw_sizestyle = 'H' " Human-readable file sizes
" let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+' " hide dotfiles
" let g:netrw_hide = 1 " hide dotfiles by default
let g:netrw_banner = 0 " Turn off banner

""" Explore in vertical split
" nnoremap <Leader>e :Explore! <enter>

nnoremap <Leader>fi :e ~/.config/nvim/init.vim<CR>
nnoremap <Leader>fd :lcd %:h<CR>

nnoremap <down> :cnext<CR>
nnoremap <up> :cprevious<CR>

" Filetype
nnoremap <silent> <Leader>mv :setfiletype vim<CR>
nnoremap <silent> <Leader>mp :setfiletype python<CR>
nnoremap <silent> <Leader>mcc :setfiletype c<CR>
nnoremap <silent> <Leader>mcpp :setfiletype cpp<CR>
nnoremap <silent> <Leader>mmd :setfiletype markdown<CR>

au BufNewFile,BufRead CMakeLists.txt set filetype=cmake

nnoremap <Leader>k :q<CR>
nnoremap <Leader>1 :only<CR>
nnoremap <Leader>2 :split<CR>
nnoremap <Leader>3 :vsplit<CR>

command! ThumbsDown :norm i👎<esc>
command! ThumbsUp :norm i👍<esc>

syntax on
filetype plugin indent on

" Auto-source the nvim config when written
autocmd! BufWritePost $MYVIMRC :source $MYVIMRC

" Select whole buffer
nnoremap gV `[V`]
" Copy whole buffer to clipboard
nnoremap <leader>gV `[V`]"+y <c-o>

nnoremap ; :

" Performs a regular search
nnoremap <leader>d /\v
inoremap kj <esc>
" vnoremap kj <esc>
tnoremap <Esc> <C-\><C-n>
autocmd! BufEnter,BufWinEnter,WinEnter term://* startinsert

" Switching panes using the meta key
nnoremap <M-h> <C-w>h
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-l> <C-w>l

" Navigate display lines
nnoremap <silent> j gj
nnoremap <silent> k gk
vnoremap <silent> j gj
vnoremap <silent> k gk

" If using a count to move up or down, ignore display lines
nnoremap <expr> j v:count == 0 ? 'gj' : "\<Esc>".v:count.'j'
nnoremap <expr> k v:count == 0 ? 'gk' : "\<Esc>".v:count.'k'
vnoremap <expr> j v:count == 0 ? 'gj' : "\<Esc>".v:count.'j'
vnoremap <expr> k v:count == 0 ? 'gk' : "\<Esc>".v:count.'k'

if exists('+relativenumber')
  set relativenumber                  " show relative numbers in gutter
endif

noremap H 5h
noremap J 5j
noremap K 5k
noremap L 5l
nnoremap <c-j> J
nnoremap Y y$
nnoremap <c-h> H
nnoremap <c-l> L
nnoremap <c-m> M

nnoremap <c-e> 7<c-e>
nnoremap <c-y> 7<c-y>
vnoremap <c-e> 7<c-e>
vnoremap <c-y> 7<c-y>

" Saving
nnoremap <Leader>w :w<CR>

" Save the copy buffer
noremap <Leader>X "+

" Copy to clipboard
vnoremap <leader>y "+y
nnoremap <leader>y "+y
nnoremap <leader>p o<esc>"+gp

" Align blocks of texte and keep them selected
vnoremap < <gv
vnoremap > >gv

" Used for filetype specific editing
autocmd! FileType tex,mail set spell
autocmd! FileType vimwiki,tex,mail set spelllang=en_gb,fr,es
autocmd! FileType tex set iskeyword+=:,-

augroup mail
    autocmd!
    autocmd FileType mail set textwidth=0
    autocmd FileType mail set wrapmargin=0
    autocmd FileType mail nnoremap <Leader>gt :call MailJumpToField('To')<CR>
    autocmd FileType mail nnoremap <Leader>gb :call MailJumpToField('Bcc:')<CR>
    autocmd FileType mail nnoremap <Leader>gc :call MailJumpToField('Cc:')<CR>
    autocmd FileType mail nnoremap <Leader>gs :call MailJumpToField('Subject:')<CR>
augroup END

let g:tex_flavor='latex'


set guioptions=M
set mouse=a " Use the mouse to slide panes size or scrolling, and copying

set hidden " Allow background buffers without saving
set splitright " Split appears on the right
set splitbelow " Split appears below

hi CursorLineNr guifg=#dddddd
set cursorline                        " highlight current line
set formatoptions+=n                  " smart auto-indenting inside numbered lists
" Search
set incsearch           " search as characters are entered
set hlsearch            " highlight matches
set magic               " For regex
set ignorecase
set smartcase

" Tab spec
set tabstop=4
set shiftwidth=4
set expandtab
set backspace=indent,eol,start

nnoremap <Leader>l :bn<CR>
nnoremap <Leader>h :bp<CR>
nnoremap gl :ls<CR>
nnoremap gb :ls<CR>:b

nnoremap <Leader>c ggVG:!column -t<CR>

nnoremap <Leader>m :make 

" Close the current buffer and move to the previous one
" This replicates the idea of closing a tab
nnoremap <Leader>q :bp <BAR> bd #<CR>

" Visual mode enhancements
nnoremap <Leader><Leader> V

" Turn off highlight after search
nnoremap <Leader>a :noh<CR>

" Open the help buffer as a right split
augroup vimrc_help
  autocmd!
  autocmd BufEnter *.txt if &buftype == 'help' | wincmd L | endif
augroup END

if executable('rg')
    set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
endif

" }}}
" Interface {{{

" Display as much as possible as last line, instead of just showing @
set display=lastline

" Default formatoptions in neovim: tcqj
" t Wrap text using textwidth
" c Wrap comments using textwidth, inserting comment leader automatically.
" q Allow formatting of comments with "gq"
set formatoptions=cq

" Automatically reload modified files
set autoread

" Don't redraw while executing macros, etc
set lazyredraw

" Better display for messages
set cmdheight=2

" Only highlight first 500 chars for better performance
set synmaxcol=1000
" Color scheme
set background=dark

if (has("termguicolors"))
    set termguicolors
endif


" Resize window
nnoremap <silent> <c-up> <c-w>3+
nnoremap <silent> <c-down> <c-w>3-
nnoremap <silent> <c-left> <c-w>3<
nnoremap <silent> <c-right> <c-w>3>

" Enable folds, using markers by default
set foldenable
set foldmethod=marker

" Hide default mode text (i.e. INSERT below status line)
set noshowmode

" Show cursor position in bottom right
" Only useful if airline is not used
set ruler

" Reasonable tab completion
set wildmode=full

" Ignore autogenerated files
set wildignore+=*.o,*.obj,*.pyc
" Ignore source control
set wildignore+=.git
" Ignore lib/ dirs since the contain compiled libraries typically
set wildignore+=build,lib,node_modules,public,_site,third_party
" Ignore images and fonts
set wildignore+=*.gif,*.jpg,*.jpeg,*.otf,*.png,*.svg,*.ttf,*.svg,
" Ignore case when completing
set wildignorecase

set complete+=kspell
" }}}
" {{{ Useful functions and commands
command! -nargs=1 Ssh :r scp://<args>/

" pasting doesn't replace paste buffer
function! RestoreRegister()
    let @" = s:restore_reg"
    return ''
endfunction
function! s:Repl()
    let s:restore_reg = @"
    return "p@=RestoreRegister()\<cr>"
endfunction
vnoremap <silent> <expr> p <sid>Repl()

" Go to the pattern if exists, else adds it on the first line
function! MailJumpToField(field)
    let s:line_pattern = search('^' . a:field . ':')
    if (s:line_pattern == 0)
        call cursor(1, 1)
        execute "normal! O". a:field . ":$"
    else
        call cursor(s:line_pattern, 1)
    endif
endfunction

" }}}
" Markdown config {{{
" Syntax highlight within fenced code blocks
let g:markdown_fenced_languages = [
    \ 'bash=sh', 'css', 'html', 'js=javascript',
    \ 'typescript=javascript', 'python', 'lua'
\]

" }}}
" {{{ Git

" Git rebase bindings
augroup git_rebase
    autocmd!
    autocmd FileType gitrebase nnoremap <Leader>p ciwpick<esc>0
    autocmd FileType gitrebase nnoremap <Leader>r ciwreword<esc>0
    autocmd FileType gitrebase nnoremap <Leader>e ciwedit<esc>0
    autocmd FileType gitrebase nnoremap <Leader>s ciwsquash<esc>0
    autocmd FileType gitrebase nnoremap <Leader>f ciwfixup<esc>0
    autocmd FileType gitrebase nnoremap <Leader>x ciwexec<esc>0
    autocmd FileType gitrebase nnoremap <Leader>b ciwbreak<esc>0
    autocmd FileType gitrebase nnoremap <Leader>d ciwdrop<esc>0
    autocmd FileType gitrebase nnoremap <Leader>l ciwlabel<esc>0
    autocmd FileType gitrebase nnoremap <Leader>t ciwreset<esc>0
    autocmd FileType gitrebase nnoremap <Leader>m ciwmerge<esc>0
    autocmd FileType gitrebase %s/^pick \([a-z0-9]\+\) drop! /drop \1 /e
augroup END

"}}}
" {{{ Expand regions
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)
" }}}


"""""""""""""""""""""""""""
"        PLUGINS          "
"""""""""""""""""""""""""""

" {{{ Onedark

try
    colorscheme onedark
lua << EOF
    vim.cmd[[highlight IncSearch guibg=#135564 guifg=white]]
    vim.cmd[[highlight Search guibg=#135564 guifg=white]]
    vim.cmd[[highlight Folded guibg=default guifg=grey]]
EOF
catch
  echo 'onedark not installed. It should work after running :PlugInstall'
endtry

" }}}
" {{{ Tabline
lua << EOF
require('tabline').setup({
options = {
    component_separators = {"|" , ""},
    section_separators = {"" , ""}
    }
})
EOF
" }}}
" {{{ LuaLine
lua << EOF
require('lualine').setup({
    options = {
        theme = 'onedark'
    },
    tabline = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { require'tabline'.tabline_buffers },
        lualine_x = { require'tabline'.tabline_tabs },
        lualine_y = {},
        lualine_z = {},
    },

})
EOF
" }}}
" {{{ Fugitive
nnoremap <Leader>gs :vertical botright Gstatus<CR>
" }}}
" {{{ NERDtree
map <Leader>n :NERDTreeToggle<return><CR>
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
" }}}
" {{{ VimTex
let g:vimtex_compiler_method = 'latexmk'
autocmd FileType tex nnoremap <Leader>c :VimtexTocToggle<CR>
autocmd FileType tex nnoremap <F5> :VimtexCompile<CR>
" }}}
" {{{ FzF
autocmd CompleteDone * pclose
let g:fzf_history_dir = '~/.local/share/fzf-history'
" [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1
" [Tags] Command to generate tags file
let g:fzf_tags_command = 'ctags -R'

let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

nnoremap , :Buffers<CR>
nnoremap <Leader>i :Rg<CR>
nnoremap <Leader>o :FZF<CR>
nnoremap <Leader>t :Tags<CR>
nnoremap <Leader>T :BTags<CR>
nnoremap <Leader>fp :GFiles<CR>
nnoremap <Leader>s :BLines<CR>

nnoremap <c-x>h :Helptags<CR>
inoremap <c-x>h :Helptags<CR>
nnoremap <Leader>x :Commands<CR>
inoremap <M-x> :Commands<CR>
" Fuzzy search help <leader>?

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

function! CreateCenteredFloatingWindow()
    let width = min([&columns - 4, max([80, float2nr(&columns/2)])])
    let height = min([&lines - 4, max([20, float2nr((&lines * 2)/3)])])
    let top = ((&lines - height) / 2) - 1
    let left = (&columns - width) / 2
    let opts = {'relative': 'editor', 'row': top, 'col': left, 'width': width, 'height': height, 'style': 'minimal'}

    let top = "╭" . repeat("─", width - 2) . "╮"
    let mid = "│" . repeat(" ", width - 2) . "│"
    let bot = "╰" . repeat("─", width - 2) . "╯"
    let lines = [top] + repeat([mid], height - 2) + [bot]
    let s:buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(s:buf, 0, -1, v:true, lines)
    call nvim_open_win(s:buf, v:true, opts)
    set winhl=Normal:Floating
    let opts.row += 1
    let opts.height -= 2
    let opts.col += 2
    let opts.width -= 4
    call nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
    au BufWipeout <buffer> exe 'bw '.s:buf
endfunction


let g:fzf_layout = { 'window': 'call CreateCenteredFloatingWindow()' }

autocmd! FileType fzf
" }}}
" {{{ Tagbar
nnoremap <F8> :TagbarToggle<CR>

" }}}
" {{{ Python folding
" Be able to read doc
let g:SimplylFold_docstring_preview = 1

" }}}
" {{{ Tabular
nnoremap <Leader>T= :Tabularize /=<CR>
vnoremap <Leader>T= :Tabularize /=<CR>

" For it to be working with vimtex
let g:vimtex_compiler_progname = 'nvr'
augroup my_cm_setup
  autocmd!
  autocmd User CmSetup call cm#register_source({
        \ 'name' : 'vimtex',
        \ 'priority': 8,
        \ 'scoping': 1,
        \ 'scopes': ['tex'],
        \ 'abbreviation': 'tex',
        \ 'cm_refresh_patterns': g:vimtex#re#ncm,
        \ 'cm_refresh': {'omnifunc': 'vimtex#complete#omnifunc'},
        \ })
augroup END

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" }}}
" {{{ Ultisnips
let g:UltiSnipsExpandTrigger="<c-c>"
let g:UltiSnipsJumpForwardTrigger="<c-c>"
let g:UltiSnipsJumpBackwardTrigger="<c-b>"
" }}}
" {{{ VIM polyglot
let g:polyglot_disabled = ['python', 'latex', 'markdown']
" }}}
" {{{ python-syntax
let g:python_highlight_all = 1
" }}}
" {{{ Easymotion
" nnoremap  <Leader>s <Plug>(easymotion-bd-w)
" nnoremap <Leader>s <Plug>(easymotion-overwin-w)
" Gif config
map  / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)
" }}}
" {{{ Goyo
function! s:goyo_enter()
  let b:quitting = 0
  let b:quitting_bang = 0
  autocmd QuitPre <buffer> let b:quitting = 1
  cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!
endfunction

function! s:goyo_leave()
  " Quit Vim if this is the only remaining buffer
  if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    if b:quitting_bang
      qa!
    else
      qa
    endif
  endif
endfunction

autocmd! User GoyoEnter call <SID>goyo_enter()
autocmd! User GoyoLeave call <SID>goyo_leave()
" }}}
" {{{ vim-tmux-navigator
let g:tmux_navigator_no_mappings = 1

nnoremap <silent> <m-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <m-j> :TmuxNavigateDown<cr>
nnoremap <silent> <m-k> :TmuxNavigateUp<cr>
nnoremap <silent> <m-l> :TmuxNavigateRight<cr>
nnoremap <silent> <m-\> :TmuxNavigatePrevious<cr>

tnoremap <silent> <m-h> <C-\><C-n>:TmuxNavigateLeft<cr>
tnoremap <silent> <m-j> <C-\><C-n>:TmuxNavigateDown<cr>
tnoremap <silent> <m-k> <C-\><C-n>:TmuxNavigateUp<cr>
tnoremap <silent> <m-l> <C-\><C-n>:TmuxNavigateRight<cr>
tnoremap <silent> <m-\> <C-\><C-n>:TmuxNavigatePrevious<cr>
" }}}
" {{{ Gutentags
let g:gutentags_cache_dir = '~/.config/nvim/gutentags'
" }}}
" {{{ Tmux-Complete
let g:tmuxcomplete#trigger = ''
" }}}
" {{{ Vimwiki
let g:vimwiki_map_prefix = '<Leader>e'
let g:vimwiki_main = {'path': '$HOME/cloud/utils/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}
let g:vimwiki_book = {'path': '$HOME/cloud/utils/book/', 'syntax': 'markdown', 'ext': '.md'}
let g:vimwiki_soundhound = {'path': '$HOME/cloud/utils/soundhound-wiki/', 'syntax': 'markdown', 'ext': '.md'}
let g:vimwiki_list = [vimwiki_soundhound, vimwiki_main, vimwiki_book]
let g:vimwiki_folding = 'custom'
let g:vimwiki_global_ext = 0
let g:vimwiki_filetypes = ['markdown']
autocmd FileType vimwiki setlocal fdm=marker


let g:pandoc#folding#fastfolds=1

" let g:pandoc#filetypes#handled = ["pandoc", "markdown"]
" let g:pandoc#filetypes#pandoc_markdown = 0
" let g:pandoc#folding#mode = ["syntax"]
" let g:pandoc#modules#enabled = ["formatting", "folding"]
" let g:pandoc#formatting#mode = "h"

" let g:vimwiki_folding='expr'
" au FileType vimwiki set filetype=markdown

function! RecapDiaryWeek()
    " Set variables and dates
    let s:date_today = system("date \+\%Y\%m\%d")
    let s:last_week_date = system("date -d 'last Monday' \+\%Y\%m\%d")
    let s:last_week_date = substitute(s:last_week_date, '\n\+$', '', '')
    let s:list_files = systemlist("ls " . g:vimwiki_soundhound.path . '/diary/ -I diary.md -I "week-recap*"')
    let s:list_files_date = map(copy(s:list_files), {_, val -> substitute(val, '\v(-|\.md)', '', 'g')})

    " Filter old files
    let s:list_index = 0
    let s:len_list_files = len(s:list_files)
    let s:relevant_files = []
    while s:list_index < s:len_list_files
        if s:list_files_date[s:list_index] >= s:last_week_date-1
            call add(s:relevant_files, s:list_files[s:list_index])
        endif
        let s:list_index += 1
    endwhile
    let s:relevant_files = map(s:relevant_files, 'g:vimwiki_soundhound.path . "diary/". v:val')
    let s:output_file = expand(g:vimwiki_soundhound.path) . 'diary/week-recap-' . s:last_week_date . '.md'

    " Write file
    call writefile(["# My week recap:"], s:output_file)
    call writefile([""], s:output_file, 'a')
    call writefile(["- Chloé Dequeker"], s:output_file, 'a')

    " Write every diary file
    for diary_file in s:relevant_files
        call writefile(split("", "\n", 1), s:output_file, 'a')
        let tmp_file = readfile(expand(diary_file))
        let s:diary_file_date = fnamemodify(diary_file, ":t:r")
        let s:diary_file_date = system('date -d"' . s:diary_file_date . '" "+%A %b. %d %Y"')
        call writefile(split("## " . s:diary_file_date, "\n", 1), s:output_file, 'a')
        call writefile(tmp_file, s:output_file, 'a')
    endfor

    call writefile([""], s:output_file, 'a')
    call writefile([""], s:output_file, 'a')
    call writefile(["# Week recap:"], s:output_file, 'a')
    call writefile([""], s:output_file, 'a')
    call writefile(["# Next week:"], s:output_file, 'a')
    call writefile([""], s:output_file, 'a')
    call writefile([""], s:output_file, 'a')
    execute 'edit' . s:output_file
endfunction


command! ShowDiaryLastWeekRecap execute 'edit' . system('ls -t ' . g:vimwiki_soundhound.path . '/diary/week-recap* | head -1')
command! RecapDiaryWeek call RecapDiaryWeek()
command! FZFwiki execute 'FZF ' . g:vimwiki_soundhound.path
nnoremap <leader>eo :FZFwiki<CR>

" }}}
" {{{ vim-markdown
let vim_markdown_folding_disabled = 1
" }}}
" {{{ livedown
" should markdown preview get shown automatically upon opening markdown buffer
let g:livedown_autorun = 0

" should the browser window pop-up upon previewing
let g:livedown_open = 1

" the port on which Livedown server will run
let g:livedown_port = 1337

" the browser to use, can also be firefox, chrome or other, depending on your executable
let g:livedown_browser = "firefox"
"}}}
" {{{ Taskwiki
let g:taskwiki_markup_syntax = "markdown"
" }}}
" {{{ Quick Scope

" Trigger a highlight only when pressing f and F.
let g:qs_highlight_on_keys = ['f', 'F']

augroup qs_colors
  autocmd!
  autocmd ColorScheme * highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline
  autocmd ColorScheme * highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline
augroup END

" Disable plugin on long lines
let g:qs_max_chars=500

" }}}
"{{{ UltiSnips
" Workaround slowdown in neovim
if has('nvim')
    augroup ultisnips_no_auto_expansion
        au!
        au VimEnter * au! UltiSnips_AutoTrigger
    augroup END
endif
"}}}
" {{{ SoundHound

" Treat .ter/.ti/.cdt files as cpp files
autocmd! BufNewFile,BufRead,BufEnter *.ter set filetype=cpp
autocmd! BufNewFile,BufRead,BufEnter *.ti set filetype=cpp
autocmd! BufNewFile,BufRead,BufEnter *.cdt set filetype=cpp

"" Auto insert the headers for a file
function! InsertHeader()
    let s:curr_filename=expand('%:t')
    let s:curr_fileending=expand('%:e')
    let s:start_lines = ["/* file \"" . s:curr_filename . "\" */", "", "\/* Copyright " . strftime("%Y") . " SoundHound, Incorporated.  All rights reserved. */", ""]
    let s:end_lines = []
    if s:curr_fileending == "h" || s:curr_fileending == "ti"
        let s:curr_filename=toupper(s:curr_filename)
        let s:curr_filename=substitute(s:curr_filename, "\\.", "_", "")
        call add(s:start_lines, "#ifndef " . s:curr_filename)
        call add(s:start_lines, "#define " . s:curr_filename)
        call add(s:start_lines, "")
        call add(s:end_lines, "#endif /* " . s:curr_filename . " */")
    endif
    call append(0, s:start_lines)
    call append(line('$'), s:end_lines)
endfunction
command! InsertHeader call InsertHeader()

"}}}
" {{{ Neovim completion
let g:cpp_simple_highlight = 1

hi default LspCxxHlGroupNamespace ctermfg=Yellow guifg=#E5C07B cterm=none gui=none
hi default LspCxxHlGroupMemberVariable ctermfg=White guifg=#F16E77

" Completion menu
set completeopt=menuone,noselect

lua << EOF
require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = true;

  source = {
    path = true;
    buffer = false;
    calc = true;
    emoji = true;
    nvim_lsp = true;
    nvim_lua = true;
    vsnip = true;
    ultisnips = true;
  };
}
EOF

"}}}
" {{{ Neovim LSP

if executable('clangd')
    lua require('lspconfig').clangd.setup{ on_attach=require'compe'.on_attach }
endif
if executable('pyls')
    lua require('lspconfig').pyls.setup{ on_attach=require'compe'.on_attach }
endif
if executable('bash-language-server')
    lua require('lspconfig').bashls.setup{ on_attach=require'compe'.on_attach }
endif
if executable('vim-language-server')
    lua require('lspconfig').vimls.setup{ on_attach=require'compe'.on_attach }
endif

nnoremap <silent> 2gD <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gh     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gi    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> gs <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>

lua << EOF
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    -- This will disable virtual text, like doing:
    -- let g:diagnostic_enable_virtual_text = 0
    virtual_text = false,

    -- This is similar to:
    -- let g:diagnostic_show_sign = 1
    -- To configure sign display,
    --  see: ":help vim.lsp.diagnostic.set_signs()"
    signs = true,

    -- This is similar to:
    -- "let g:diagnostic_insert_delay = 1"
    update_in_insert = false,
  }
)
EOF

" Check for event after that much ms
set updatetime=700

" Event listener for when we're holding the cursor. This event is called
" for every 700ms (value of updatetime). If it's true, then show the
" diagnostics in a popup window
autocmd! CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()

let g:diagnostic_auto_popup_while_jump = 1
let g:diagnostic_enable_virtual_text = 0

"}}}
" {{{ gitsigns
lua require('gitsigns').setup()
"}}}
