--{{{ Plugins

local fn = vim.fn

local function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

local packer_install_dir = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

local packer_bootstrap = false
if not file_exists(packer_install_dir .. '/lua/packer.lua') then
    packer_bootstrap = fn.system({'git', 'clone', '--depth', '1',
                                  'https://github.com/wbthomason/packer.nvim', packer_install_dir
                                 })
end

require('packer').startup(function(use)

    use 'wbthomason/packer.nvim'
    -- {{{ DiffView
    use {
        'sindrets/diffview.nvim',
        config = function ()
            require('utils').create_augroup('diffView', {
                'FileType DiffviewFiles nmap <c-j> j<CR>',
                'FileType DiffviewFiles nmap <c-k> k<CR>',
            })
        end,
    }
    -- }}}
    -- {{{ Fzf.vim
    use {                                                   -- Fuzzy search everything
        'junegunn/fzf.vim',
        config = require('plugins.fzf').setup(),
    }
    -- }}}
    -- {{{ FzfLua
    use {                                                   -- Install Lua interface for FZF
        'ibhagwan/fzf-lua',
        config = function () require('plugins.fzf-lua').setup() end,
        requires = {
            'vijaymarupudi/nvim-fzf',
            'kyazdani42/nvim-web-devicons'
        },
    }
    -- }}}
    -- {{{ Fzf.vim
    use {                                                   -- Install FZF
        'junegunn/fzf',
        run = './install --bin',
    }
    -- }}}

    -- {{{ EasyMotion
    use {                                                   -- Easily search and move around the buffer
    'easymotion/vim-easymotion',
        config = function ()
            require('utils').map('/', '<Plug>(easymotion-sn)')
            require('utils').omap('/', '<Plug>(easymotion-tn)')
        end,
    }
    -- }}}
    -- {{{ VimTmuxNavigator
    use {                                                   -- Sane binding to navigate between vim and tmux
        'christoomey/vim-tmux-navigator',
        config = function () require('plugins.vim-tmux-navigator').setup() end
    }
    -- }}}
    -- {{{ UltiSnips
    use {                                                   -- Interface for Snippets
        'SirVer/ultisnips',
        config = function ()
            vim.g.UltiSnipsExpandTrigger = '<c-c>'
            vim.g.UltiSnipsJumpForwardTrigger = '<c-c>'
            vim.g.UltiSnipsJumpBackwardTrigger = '<c-b>'

            require('utils').create_augroup('ultisnips_no_auto_expansion', {
                'VimEnter * au! UltiSnips_AutoTrigger',
            })
        end
    }
    -- }}}
    -- {{{ Vim-Snippets
    use 'honza/vim-snippets'                                -- Provide with many Snippets to Ultisnips
    -- }}}
    -- {{{ Vim Expand Region - Extend visual selection by increasing text objects
    use {
        'terryma/vim-expand-region',
        config = function ()
            vim.cmd[[ vmap v <Plug>(expand_region_expand) ]]
            vim.cmd[[ vmap <C-v> <Plug>(expand_region_shrink) ]]
        end,
    }
    -- }}}

    -- {{{ Vim Multiple Cursor
    use 'terryma/vim-multiple-cursors'                      -- Adding multiple cursors with <c-n>
    -- }}}
    -- {{{ DelimitMate - parenthesis completion
    use 'Raimondi/delimitMate'                              -- For parenthesis completion
    -- }}}
    -- {{{ Asyncrun - Run commands in the background
    use 'skywind3000/asyncrun.vim'                          -- Allows to run commands in the background
    -- }}}

    ------------------
    --  Completion  --
    ------------------
    -- {{{ Nvim LSP - Enable the built-in LSP
    use 'neovim/nvim-lsp'
    -- }}}
    -- {{{ Nvim LSP config - Set of configuration for the Neovim LSP
    use {
        'neovim/nvim-lspconfig',
        config = function () require('plugins.nvim-lsp').setup() end,
    }
    -- }}}
    -- {{{ Nvim Cmp - Provide autocompletion
    use {
        'hrsh7th/nvim-cmp',
        config = function () require('plugins.nvim-cmp').setup() end,
        requires = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'quangnguyen30192/cmp-nvim-ultisnips',
        },
    }
    -- }}}
    -- {{{ Nvim TreeSitter - Provide Syntax information
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function ()
            require'nvim-treesitter.configs'.setup({
              ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
              ignore_install = {}, -- List of parsers to ignore installing
              highlight = {
                enable = true,              -- false will disable the whole extension
                disable = { "python" },  -- list of language that will be disabled
                -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                -- Using this option may slow down your editor, and you may see some duplicate highlights.
                -- Instead of true it can also be a list of languages
                additional_vim_regex_highlighting = false,
              },
            })
        end
    }
    -- }}}
    -- {{{ Nvim Completion-TreeSitter - Add treesitter as completion source
    use 'nvim-treesitter/completion-treesitter'
    -- }}}
    -- {{{ Quick-Scope - Highlight letters when matching 'f' or 'F'
    use {
        'unblevable/quick-scope',
        config = function ()
            vim.g.qs_highlight_on_keys = { 'f', 'F' } -- Trigger a highlight only when pressing f and F.
            vim.g.qs_max_chars=500 -- Disable plugin on long lines
            require('utils').create_augroup('qs_colors', {
              'ColorScheme * highlight QuickScopePrimary guifg=#afff5f gui=underline ctermfg=155 cterm=underline',
              'ColorScheme * highlight QuickScopeSecondary guifg=#5fffff gui=underline ctermfg=81 cterm=underline',
            })
        end,
    }
    -- }}}
    -- {{{ Tabular - Align text based on pattern
    use {
        'godlygeek/tabular',
        config = function ()
            require('utils').nnoremap('<Leader>T=', ':Tabularize /=<CR>')
            require('utils').vnoremap('<Leader>T=', ':Tabularize /=<CR>')
        end,
    }
    -- }}}

    -- {{{ Vim commentary
    use 'tpope/vim-commentary'   -- comments based on the file type
    -- }}}
    -- {{{ Vim Surround
    use 'tpope/vim-surround'
    -- }}}
    -- {{{ Vim Sensible - Add better default config
    -- @todo: Check if needed
    use 'tpope/vim-sensible'     -- Sensible defaults for [n]vim
    -- }}}
    -- {{{ Vim Repeat - Allow repeating plugin actions and more
    use 'tpope/vim-repeat'
    -- }}}
    -- {{{ Vim Eunuch - Provide basic commands (chmod, mkdir, rename, etc.)
    use 'tpope/vim-eunuch'
    -- }}}
    -- {{{ Vim Fugitive - Git interface
    use {
        'tpope/vim-fugitive',
        config = function ()
            require('utils').nnoremap('<Leader>gs', ':vertical botright Gstatus<CR>')
        end
    }
    -- }}}

    -- {{{ Gitsigns - Git information on the sign column
    use {
        'lewis6991/gitsigns.nvim',
        requires = {
            'nvim-lua/plenary.nvim'
        },
        config = function () require('gitsigns').setup() end,
    }
    -- }}}
    -- {{{ Readline - Brings readline mapping to ex command
    -- @todo: Check if that can't be easily done with a few mappings
    use 'ryvnf/readline.vim'
    -- }}}

    -----------------
    --  Interface  --
    -----------------
    -- {{{ Nvim colorizer - Colour highlighter
    use {
        'norcalli/nvim-colorizer.lua',
        config = function () require('colorizer').setup() end,
    }
    -- }}}
    -- {{{ Onedark - Colour scheme with support for treesitter syntax
    use {
        'navarasu/onedark.nvim',
        config = function () require('plugins.onedark').setup() end,
    }
    -- }}}

    -- {{{ LuaLine - Status line and buffer line
    use {
        'nvim-lualine/lualine.nvim',
        config = function () require('plugins.lualine').setup() end,
        requires = {
            'kdheepak/tabline.nvim',
        },
    }
    -- }}}
    -- {{{ Tabline - Better buffers and tabs. Only used for tabs in lualine
    use {
        'kdheepak/tabline.nvim',
        config = function ()
            require('tabline').setup({
                enable = false, -- Set up by lualine
                options = {
                    component_separators = {"", ""},
                    section_separators = {"", ""},
                }
            })
        end,
        requires = {
            'nvim-lualine/lualine.nvim',
            'kyazdani42/nvim-web-devicons',
        },
    }
    -- }}}

    -- {{{ Todo Comments -- Highlight them and make them searchable
    use {
        'folke/todo-comments.nvim',
        config = function ()
            require("todo-comments").setup()
        end,
        requires = "nvim-lua/plenary.nvim",
    }
    -- }}}


    -------------------------
    --  Language specific  --
    -------------------------
    -- {{{ SympylFold - Python language folding
    use {
        'tmhedberg/SimpylFold',
        ft = 'python',
        config = function ()
            vim.g.SimplylFold_docstring_preview = 1 -- Be able to read doc
        end,
    }
    -- }}}
    -- {{{ Iron.nvim - Interactive REPL
    use {                                                   -- Interactive REPL over Neovim
        'Vigemus/iron.nvim',
        ft = 'python',
    }
    -- }}}
    -- {{{ Vim ClangFormat - Brings command such as ClangFormat
    use {
        'rhysd/vim-clang-format',
        ft = 'cpp',
    }
    -- }}}

    -- {{{ Vim Table Mode - Add Table mode for writing them in Markdown
    use {
        'dhruvasagar/vim-table-mode',
        ft = { 'markdown', 'pandoc', 'vimwiki.markdown' },
    }
    -- }}}
    -- {{{ Vim Markdown - Many conceal and folding features
    use {
        'plasticboy/vim-markdown',
        ft = { 'markdown', 'pandoc', 'vimwiki.markdown' },
        config = function ()
            vim.g.vim_markdown_folding_disabled = 1
        end,
    }
    -- }}}
    -- {{{ Vim Livedown - Preview Markdown on browser
    use {
        'shime/vim-livedown',
        ft = { 'markdown', 'pandoc' },
        config = function ()
            vim.g.livedown_autorun = 0 -- Show preview automatically upon opening markdown buffer
            vim.g.livedown_open = 1 -- Pop-up the browser window upon previewing
            vim.g.livedown_port = 1337 -- Livedown server port
            vim.g.livedown_browser = 'firefox' -- Browser to user
        end
    }
    -- }}}
    -- {{{ VimTex
    use {
        'lervag/vimtex',
        ft = { 'tex', 'latex' },
        config = function ()
            vim.g.vimtex_compiler_method = 'latexmk'
            vim.g.vimtex_compiler_progname = 'nvr'
            vim.cmd[[ autocmd FileType tex nnoremap <Leader>c :VimtexTocToggle<CR> ]]
            vim.cmd[[ autocmd FileType tex nnoremap <F5> :VimtexCompile<CR> ]]
        end
    }
    -- }}}

    -----------------------
    --  Integrated apps  --
    -----------------------
    -- {{{ VimWiki
    use {
        'vimwiki/vimwiki',
        config = function () require('plugins.vimwiki').setup() end,
    }
    -- }}}
    -- {{{ TagBar -- Show symbols information on side window
    use {                                                   -- Opens a tagbar on the right side
        'majutsushi/tagbar',
        cmd = 'TagbarToggle',
        config = function ()
            require('utils').nnoremap('<F8>', ':TagbarToggle<CR>')
        end,
    }
    -- }}}
    -- {{{ Goyo -- Distraction-free writing environment
    use {
        'junegunn/goyo.vim',
        config = function ()
            function GoyoEnter ()
              vim.bo.quitting = false
              vim.bo.quitting_bang = false
              vim.cmd[[ autocmd! QuitPre <buffer> let b:quitting = 1 ]]
              vim.cmd[[ cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q! ]]
            end

            function GoyoLeave ()
              -- Quit Vim if this is the only remaining buffer
              if vim.bo.quitting and vim.cmd[[ len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) ]] == 1 then
                if vim.bo.quitting_bang then
                  vim.cmd[[ qa! ]]
                else
                  vim.cmd[[ qa ]]
                end
              end
            end

            vim.cmd[[ autocmd! User GoyoEnter v:lua.GoyoEnter() ]]
            vim.cmd[[ autocmd! User GoyoLeave v:lua.GoyoLeave() ]]
        end,
    }
    -- }}}
    -- {{{ Plenary.nvim -- Set of Lua functions used by other plugins
    use 'nvim-lua/plenary.nvim'
    -- }}}
    -- {{{ Vim Grammarous -- Send text for grammar analysis
    use {
        'rhysd/vim-grammarous',
        cmd = 'GrammarousCheck',
    }
    -- }}}
    -- {{{ tlib_vim --  Some script library that may be required by other plugins
    use 'tomtom/tlib_vim'
    -- }}}
    -- {{{ NvimTree -- Show files on side window
    use {
        'kyazdani42/nvim-tree.lua',
        cmd = 'NvimTreeToggle',
        config = function ()
            require'nvim-tree'.setup({
                view = {
                    width = 40,
                },
            })
        end,
        setup = function () require('utils').nnoremap('<leader>n', ':NvimTreeToggle<CR>') end,
        requires = {'kyazdani42/nvim-web-devicons'},
    }
    -- }}}

    if packer_bootstrap then
        require('packer').sync()
    end
end)
--}}}

require('options')
require('mappings')
require('autocmd')
require('work.soundhound')
