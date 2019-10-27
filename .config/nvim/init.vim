set nocompatible               " Be iMproved
filetype off                  " required

"{{{ Plugins
" Required:
call plug#begin('~/.config/nvim/plugged')

    Plug 'Shougo/vimproc.vim', {'build': 'make'}
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'junegunn/fzf.vim'
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'mileszs/ack.vim'                     " Fuzzy search

    Plug 'neoclide/coc.nvim', {'tag': '*', 'branch': 'release'}

    Plug 'Shougo/neco-vim'
    Plug 'jeaye/color_coded', {
                \ 'do': 'rm -f CMakeCache.txt && cmake . -DDOWNLOAD_CLANG=0 && make && make install',
                \ 'for': ['c', 'cpp', 'objc', 'objcpp'],
                \ 'build_commands' : ['cmake', 'make']
                \}

    Plug 'easymotion/vim-easymotion'
    Plug 'rhysd/vim-grammarous'
    Plug 'jreybert/vimagit'

    Plug 'ludovicchabant/vim-gutentags'

    Plug 'vim-airline/vim-airline'               " line with useful infos
    Plug 'vim-airline/vim-airline-themes'
    Plug 'airblade/vim-gitgutter'                " git info on the left
    Plug 'ap/vim-css-color'                      " Color highlighter
    Plug 'joshdick/onedark.vim'                  " Colour scheme
    Plug 'vimwiki/vimwiki'
"     Plugin 'Yggdroot/indentLine'                   " Display indentation
    " Plug 'thaerkh/vim-indentguides'

    Plug 'Raimondi/delimitMate'                  " For parenthesis

    " NERDtree loaded on toggle
    Plug 'scrooloose/nerdtree'
    Plug 'Xuyuanp/nerdtree-git-plugin'

    Plug 'tmhedberg/SimpylFold'
    Plug 'godlygeek/tabular'                        " Tabuliarise and align based on pattern
    Plug 'plasticboy/vim-markdown'
    Plug 'vim-pandoc/vim-pandoc'
    Plug 'vim-pandoc/vim-pandoc-syntax'

    Plug 'junegunn/goyo.vim'

    Plug 'sheerun/vim-polyglot'
    Plug 'vim-python/python-syntax'

    Plug 'Vigemus/iron.nvim' " Interactive REPL over Neovim; might need lua config TODO

    Plug 'tpope/vim-commentary'                  " comments based on the file type
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-sensible'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-eunuch'

    Plug 'def-lkb/vimbufsync'
    Plug 'terryma/vim-expand-region'
    Plug 'xolox/vim-misc'
    Plug 'terryma/vim-multiple-cursors'
    Plug 'marcweber/vim-addon-mw-utils'
    Plug 'tomtom/tlib_vim'
    Plug 'majutsushi/tagbar'

    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'
    Plug 'lervag/vimtex'
    Plug 'ymatz/vim-latex-completion'

call plug#end()
" }}}

" {{{ Basic VIM modifications


set guioptions=M
set mouse=a " Use the mouse to slide panes size or scrolling, and copying

set hidden " Allow background buffers without saving
set splitright

" set t_Co=256
set number              " line numbers
hi CursorLineNr guifg=#dddddd
set cursorline                        " highlight current line
set encoding=utf-8

set autoindent
set autoread            " reload automatically a file if not changed

set formatoptions+=n                  " smart auto-indenting inside numbered lists

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


" Text wrapping
" set nowrap
" set textwidth=79
" set colorcolumn=80

" Adding my own snippets
set runtimepath+=~/.config/nvim/my-snippets/

" Search
set incsearch           " search as characters are entered
set hlsearch            " highlight matches
set magic               " For regex
set ignorecase

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

nnoremap z- z=1<enter><enter>

" Tab spec
set tabstop=4
set shiftwidth=4
set expandtab
set backspace=indent,eol,start

""" NetRW - VIM file explorer
let g:netrw_liststyle = 1 " Detail View
let g:netrw_sizestyle = 'H' " Human-readable file sizes
" let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+' " hide dotfiles
" let g:netrw_hide = 1 " hide dotfiles by default
let g:netrw_banner = 0 " Turn off banner

""" Explore in vertical split
nnoremap <Leader>e :Explore! <enter>

nnoremap <Leader>fi :e ~/.config/nvim/init.vim<CR>
nnoremap <Leader>fd :lcd %:h<CR>

" Filetype
nnoremap <Leader>mv :setfiletype vim<CR>
nnoremap <Leader>mp :setfiletype python<CR>
nnoremap <Leader>mcc :setfiletype c<CR>
nnoremap <Leader>mcpp :setfiletype cpp<CR>

nnoremap <Leader>1 :only<CR>
nnoremap <Leader>2 :split<CR>
nnoremap <Leader>3 :vsplit<CR>

syntax on
filetype plugin indent on


autocmd! BufWritePost $MYVIMRC :source $MYVIMRC



nnoremap gV `[V`]
nnoremap ; :

" Performs a regular search
nnoremap <leader>d /
inoremap kj <esc>
vnoremap kj <esc>
tnoremap <Esc> <C-\><C-n>
tnoremap kjjk <C-\><C-n>

" Switching panes using the ctrl key
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

" Saving
nnoremap <Leader>w :w<CR>

" Save the copy buffer
noremap <Leader>x "+
" Copy to clipboard
vnoremap <leader>y "+y 
vnoremap <leader>p "+p

" Stupid window...
map q: :q

" Align blocks of texte and keep them selected
vnoremap < <gv
vnoremap > >gv

" Used for filetype specific editing
autocmd FileType tex,mail set spell
autocmd FileType vimwiki,tex,mail set spelllang=en_gb,fr
autocmd FileType mail set textwidth=0
autocmd FileType mail set wrapmargin=0
autocmd FileType tex set iskeyword+=:,-

autocmd FileType mail nnoremap <Leader>gt :call MailJumpToField('To')<CR>
autocmd FileType mail nnoremap <Leader>gb :call MailJumpToField('Bcc:')<CR>
autocmd FileType mail nnoremap <Leader>gc :call MailJumpToField('Cc:')<CR>
autocmd FileType mail nnoremap <Leader>gs :call MailJumpToField('Subject:')<CR>

let g:tex_flavor='latex'

" }}}

" {{{ Buffer
nnoremap <Leader>l :bn<CR><return>
nnoremap <Leader>h :bp<CR>
nnoremap gl :ls<CR>
nnoremap gb :ls<CR>:b
" }}}

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


" Display as much as possible as last line, instead of just showing @
set display=lastline

" Default formatoptions in neovim: tcqj
" t Wrap text using textwidth
" c Wrap comments using textwidth, inserting comment leader automatically.
" q Allow formatting of comments with "gq"
set formatoptions=tcq

" Automatically reload modified files
set autoread

" Don't redraw while executing macros, etc
set lazyredraw

" Better display for messages
set cmdheight=2

" Colors & Syntax Highlighting {{{

" Only highlight first 500 chars for better performance
set synmaxcol=500
" Color scheme
set background=dark
"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif
colorscheme onedark

if (has('nvim'))
    colorscheme onedark
    set termguicolors
else
    colorscheme ir_black
endif
" }}}

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
" }}}


set complete+=kspell

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

"
" Markdown config {{{
" Syntax highlight within fenced code blocks
let g:markdown_fenced_languages = ['bash=sh', 'css', 'html', 'js=javascript',
      \ 'typescript=javascript', 'python']
" }}}<Paste>

"""""""""""""""""""""""""""
"        PLUGINS          "
"""""""""""""""""""""""""""

" {{{ Clang-complete
let g:clang_library_path='/usr/lib64/libclang.so'
" }}}

" {{{ ALE
" Prevents from continuously checking for errors
" and eating up battery
let g:ale_lint_on_text_changed = 'never'
let g:ale_sign_column_always = 1
let g:ale_linters = {'python': ['flake8']}
let g:ale_fixers = {'python': ['remove_trailing_lines', 'trim_whitespace', 'yapf'], 'javascript': ['eslint']}
" }}}

" {{{ NERDtree
map <Leader>n :NERDTreeToggle<return><CR>
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
" }}}

" {{{ Airline
let g:airline_theme = 'onedark'
let g:airline#extensions#tabline#enabled = 1
set laststatus=2

" if you want to disable auto detect, comment out those two lines
"let g:airline#extensions#disable_rtp_load = 1
"let g:airline_extensions = ['branch', 'hunks', 'coc']

let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'
let airline#extensions#coc#error_symbol = 'E:'
let airline#extensions#coc#warning_symbol = 'W:'
let airline#extensions#coc#stl_format_err = '%E{[%e(#%fe)]}'
let airline#extensions#coc#stl_format_warn = '%W{[%w(#%fw)]}'
" }}}

" {{{ VimTex
let g:vimtex_compiler_method = 'latexmk'
autocmd FileType tex nnoremap <Leader>c :VimtexTocToggle<CR>
autocmd FileType tex nnoremap <F5> :VimtexCompile<CR>
" }}}

" {{{ fzf plugin
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
nnoremap <Leader>i :Rg<CR>

nnoremap , :Buffers<CR>
nnoremap <Leader>o :FZF<CR>
nnoremap <Leader>t :Tags<CR>
nnoremap <Leader>T :BTags<CR>

nnoremap <c-x>h :Helptags<CR>
inoremap <c-x>h :Helptags<CR>
nnoremap <M-x> :Commands<CR>
inoremap <M-x> :Commands<CR>
" Fuzzy search help <leader>?


autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
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

" {{{ Git plugin
set diffopt+=vertical
" }}}

" {{{ Tabular
nnoremap <Leader>a= :Tabularize /=<CR>
vnoremap <Leader>a= :Tabularize /=<CR>

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
let g:polyglot_disabled = ['python']
let g:polyglot_disabled = ['latex']
" }}}

" {{{ python-syntax
let g:python_highlight_all = 1
" }}}

" {{{ git-gutter
nnoremap <Leader>gp <Plug>GitGutterPreviewHunk
nnoremap <Leader>gs <Plug>GitGutterStageHunk
nnoremap <Leader>gu <Plug>GitGutterUndoHunk
" }}}

" {{{ easymotion
nnoremap  <Leader>s <Plug>(easymotion-bd-w)
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

map <silent> <m-h> :TmuxNavigateLeft<cr>
map <silent> <m-j> :TmuxNavigateDown<cr>
map <silent> <m-k> :TmuxNavigateUp<cr>
map <silent> <m-l> :TmuxNavigateRight<cr>
map <silent> <m-\> :TmuxNavigatePrevious<cr>
" }}}

" {{{ Gutentags
let g:gutentags_cache_dir = '~/.config/nvim/gutentags'
" }}}

" {{{ CoC nvim

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call CocAction('fold', <f-args>)

" Using CocList
" Show all diagnostics
nnoremap <silent> <space><space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space><space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space><space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space><space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space><space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space><space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space><space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space><space>p  :<C-u>CocListResume<CR>


function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" nnoremap <Plug>(coc-definition) :<C-u>call CocActionAsync('jumpDefinition')

" Remap keys for gotos
" Use `[c` and `]c` to navigate diagnostics
nnoremap <silent> [c <Plug>(coc-diagnostic-prev)
nnoremap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nnoremap <silent> gd :<C-u>call CocActionAsync('jumpDefinition')<CR>
nnoremap <silent> gy <Plug>(coc-type-definition)
nnoremap <silent> gi <Plug>(coc-implementation)
nnoremap <silent> gr <Plug>(coc-references)


" Use K to show documentation in preview window
nnoremap <silent> gD :call <SID>show_documentation()<CR><CR>

let g:coc_global_extensions = [
    \ 'coc-python', 'coc-snippets',
    \ 'coc-vimlsp', 'https://github.com/Nelyah/coc-notmuch', 'coc-css',
    \ 'coc-json', 'coc-yaml', 'coc-html',
    \ 'coc-git', 'coc-vimtex'
\]

autocmd FileType mail call coc#config('suggest', {
    \ 'autoTrigger': 'trigger',
    \})


" }}}

" {{{ Tmux-Complete
let g:tmuxcomplete#trigger = ''
" }}}

" {{{ Vimwiki
let g:vimwiki_map_prefix = '<Leader>e'
let g:vimwiki_list = [{'path': '~/cloud/utils/vimwiki/', 'syntax': 'markdown', 'ext': '.vw'}]
let g:vimwiki_folding = 'custom'
autocmd FileType vimwiki setlocal fdm=marker
" }}}

