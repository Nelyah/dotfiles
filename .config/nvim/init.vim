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
    Plug 'nvim-lua/completion-nvim'                                      " Tool for providing autocompletion interface
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
    Plug 'lewis6991/gitsigns.nvim'                                       " git info on the sign column
    Plug 'ryvnf/readline.vim'                                            " Brings readline mappings to ex command

    """""""""""""""
    "  Interface  "
    """""""""""""""
    Plug 'vim-airline/vim-airline'                                       " line with useful infos
    Plug 'vim-airline/vim-airline-themes'                                " A collection of themes
    Plug 'ap/vim-css-color'                                              " Color highlighter
    Plug 'Nelyah/onedark.vim'                                            " Colour scheme
    Plug 'drewtempelmeyer/palenight.vim'

    """""""""""""""""""""""
    "  Language specific  "
    """""""""""""""""""""""
    Plug 'sheerun/vim-polyglot'                                          " Provide many language syntax highlighting

    Plug 'vim-python/python-syntax', {'for': 'python'}                   " Better Python syntax highlighting
    Plug 'tmhedberg/SimpylFold', {'for': 'python'}                       " Better folding in python for docstrings and such
    Plug 'Vigemus/iron.nvim', {'for': 'python'}                          " Interactive REPL over Neovim
    Plug 'rhysd/vim-clang-format', {'for': 'cpp'}
    Plug 'jackguo380/vim-lsp-cxx-highlight', {'for': ['c', 'cpp']}

    " Plug 'Konfekt/FastFold', {'for': ['markdown', 'pandoc']}
    Plug 'plasticboy/vim-markdown', {'for': ['markdown', 'pandoc', 'vimwiki.markdown']}      " Many conceal and folding features for Markdown
    " Plug 'shime/vim-livedown', {'for': ['markdown', 'pandoc']}
    " Plug 'vim-pandoc/vim-pandoc', {'for': ['pandoc']}                    " Provide a Pandoc interface conversion
    " Plug 'Nelyah/vim-pandoc-syntax', {'for': ['pandoc']}                 " Provide pandoc specific syntax

    " Plug 'arakashic/chromatica.nvim', {'for': ['c', 'cpp']}              " Better syntax highlighting for c and cpp languages

    Plug 'lervag/vimtex', {'for': ['tex', 'latex']}                      " Many LateX features
    Plug 'ymatz/vim-latex-completion', {'for': ['tex', 'latex']}         " Better LateX completion

    """""""""""""""""""""
    "  Integrated apps  "
    """""""""""""""""""""
    Plug 'vimwiki/vimwiki'                                               " Wiki for vim
    " Plug 'lervag/wiki.vim'
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


"""""""""""""""""""""""""""
"        PLUGINS          "
"""""""""""""""""""""""""""

" {{{ Onedark

try
" Put this here as it need to be after QuickScope
colorscheme onedark

catch
  echo 'onedark not installed. It should work after running :PlugInstall'
endtry

" }}}
" {{{ Fugitive
nnoremap <Leader>gs :vertical botright Gstatus<CR>
" }}}
" {{{ Chromatica
" let g:clang_library_path='/usr/lib64/libclang.so'
let g:chromatica#enable_at_startup=1
" }}}
" {{{ NERDtree
map <Leader>n :NERDTreeToggle<return><CR>
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
" }}}
" {{{ Airline
try

let nvim_conf_dir = expand('<sfile>:p:h')
let target_theme_file = nvim_conf_dir . '/plugged/vim-airline-themes/autoload/airline/themes/space.vim'
if !filereadable(target_theme_file)
    call system('cp ' . nvim_conf_dir . '/space.vim ' . target_theme_file)
    " if v:shell_error
    "     echom v:shell_error
    " endif
endif


" Enable CSV integration
let g:airline#extensions#csv#enabled = 1
let g:airline#extensions#csv#column_display = 'Name'

" Enable extensions
let g:airline_extensions = ['branch', 'hunks', 'coc', 'tabline']

" Update section z to just have line number
let g:airline_section_z = airline#section#create(['%l/%L ', '%v'])

" Do not draw separators for empty sections (only for the active window) >
let g:airline_skip_empty_sections = 1

" Smartly uniquify buffers names with similar filename, suppressing common parts of paths.
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#enabled = 1

" Custom setup that removes filetype/whitespace from default vim airline bar
let g:airline#extensions#default#layout = [['a', 'b', 'c'], ['x', 'warning', 'error', 'z']]

let airline#extensions#coc#stl_format_err = '%E{[%e(#%fe)]}'

let airline#extensions#coc#stl_format_warn = '%W{[%w(#%fw)]}'

" Configure error/warning section to use coc.nvim
let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'

" Hide the Nerdtree status line to avoid clutter
let g:NERDTreeStatusline = ''

" Disable vim-airline in preview mode
let g:airline_exclude_preview = 1

" Enable powerline fonts
let g:airline_powerline_fonts = 1

" Enable caching of syntax highlighting groups
let g:airline_highlighting_cache = 1

" Define custom airline symbols
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

" Don't show git changes to current file in airline
let g:airline#extensions#hunks#enabled=0

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

" airline symbols
let g:airline_left_sep = ' '
let g:airline_left_alt_sep = ' '
let g:airline_right_sep = ' '
let g:airline_right_alt_sep = ' '
let g:airline_symbols.branch = ' '
let g:airline_symbols.readonly = ' '
let g:airline_symbols.linenr = ' '

" Vim airline theme
let g:airline_theme='palenight'

catch
  echo 'Airline not installed. It should work after running :PlugInstall'
endtry

" }}}
" {{{ Palenight
let g:palenight_terminal_italics=1
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
" {{{ Expand regions
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)
" }}}
" {{{ Python folding
" Be able to read doc
let g:SimpylFold_docstring_preview = 1

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
" {{{ vim-pandoc-syntex
let g:pandoc#syntax#conceal#urls=1
let g:pandoc#syntax#codeblocks#embeds#langs = ['bash=sh', 'css', 'html', 'js=javascript',
      \ 'typescript=javascript', 'python', 'lua']
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
" {{{ wiki.vim
let g:wiki_root = '~/cloud/utils/wiki'
autocmd! BufEnter *.wiki set filetype=pandoc
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
set completeopt=menuone,noinsert,noselect,preview

" Completion Neovim
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']
let g:completion_matching_smart_case = 1
let g:completion_trigger_keyword_length = 1
let g:completion_enable_snippet = 'UltiSnips'

autocmd BufEnter * lua require'completion'.on_attach()
let g:completion_auto_change_source = 1
let g:completion_chain_complete_list = {
    \'default' : [
    \    {'complete_items': ['lsp', 'snippet', 'path']},
    \    {'mode': '<c-p>'},
    \    {'mode': '<c-n>'}
    \],
    \'cpp' : [
    \    {'complete_items': ['ts', 'lsp', 'snippet', 'path']},
    \    {'mode': '<c-p>'},
    \    {'mode': '<c-n>'}
    \],
    \'c' : [
    \    {'complete_items': ['ts', 'lsp', 'snippet', 'path']},
    \    {'mode': '<c-p>'},
    \    {'mode': '<c-n>'}
    \],
    \'python' : [
    \    {'complete_items': ['ts', 'lsp', 'snippet', 'path']},
    \    {'mode': '<c-p>'},
    \    {'mode': '<c-n>'}
    \],
\}

"}}}
" {{{ Neovim LSP

if executable('clangd')
    lua require('lspconfig').clangd.setup{ on_attach=require'completion'.on_attach }
endif
if executable('pyls')
    lua require('lspconfig').pyls.setup{ on_attach=require'completion'.on_attach }
endif
if executable('bash-language-server')
    lua require('lspconfig').bashls.setup{ on_attach=require'completion'.on_attach }
endif
if executable('vim-language-server')
    lua require('lspconfig').vimls.setup{ on_attach=require'completion'.on_attach }
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

set completeopt-=preview
