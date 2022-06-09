require('options')
require('mappings')
require('autocmd')
require('work.soundhound')

--{{{ Plugins

local fn = vim.fn

local packer_install_dir = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

local packer_bootstrap = false
if not require('utils').file_exists(packer_install_dir .. '/lua/packer.lua') then
    packer_bootstrap = fn.system({'git', 'clone', '--depth', '1',
                                  'https://github.com/wbthomason/packer.nvim', packer_install_dir
                                 })
end

require('packer').startup(function(use)

    use 'wbthomason/packer.nvim'
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

    -- {{{ VimTmuxNavigator
    use {                                                   -- Sane binding to navigate between vim and tmux
        'christoomey/vim-tmux-navigator',
        config = function ()
            vim.g.tmux_navigator_no_mappings = 1

            vim.keymap.set('n', '<m-h>', '<cmd>TmuxNavigateLeft<cr>')
            vim.keymap.set('n', '<m-j>', '<cmd>TmuxNavigateDown<cr>')
            vim.keymap.set('n', '<m-k>', '<cmd>TmuxNavigateUp<cr>')
            vim.keymap.set('n', '<m-l>', '<cmd>TmuxNavigateRight<cr>')
            vim.keymap.set('n', '<m-\\>', '<cmd>TmuxNavigatePrevious<cr>')

            vim.keymap.set('t', '<m-h>', '<C-\\><C-n><cmd>TmuxNavigateLeft<cr>')
            vim.keymap.set('t', '<m-j>', '<C-\\><C-n><cmd>TmuxNavigateDown<cr>')
            vim.keymap.set('t', '<m-k>', '<C-\\><C-n><cmd>TmuxNavigateUp<cr>')
            vim.keymap.set('t', '<m-l>', '<C-\\><C-n><cmd>TmuxNavigateRight<cr>')
            vim.keymap.set('t', '<m-\\>', '<C-\\><C-n><cmd>TmuxNavigatePrevious<cr>')
        end
    }
    -- }}}
    -- {{{ LuaSnip
    use {
        'L3MON4D3/LuaSnip',
        after = {'nvim-cmp'},
        config = function() 
            require("luasnip.loaders.from_vscode").lazy_load()
            vim.keymap.set('i', '<c-c>', function ()
                if require('luasnip').expand_or_jumpable() == true then
                    return '<Plug>luasnip-expand-or-jump'
                else
                    return '<c-c>'
                end
            end)
        end,
        requires = {'rafamadriz/friendly-snippets'}
    }
    -- }}}

    -- {{{ Vim Multiple Cursor
    use 'terryma/vim-multiple-cursors'
    -- }}}
    -- {{{ nvim-autopairs - Autocomplete parenthesis
    use {
        'windwp/nvim-autopairs',
        config = function() require("nvim-autopairs").setup({}) end,
    }
    -- }}}

    --------------------
    ----  Completion  --
    --------------------
    -- {{{ Nvim LSP - Enable the built-in LSP
    use {
        'neovim/nvim-lsp',
        requires = {
            'neovim/nvim-lspconfig', -- Easier configuration interface for Neovim LSP
            'hrsh7th/nvim-cmp',
            'hrsh7th/cmp-nvim-lsp',
        },
        config = function () require('plugins.nvim-lsp').setup() end,
    }
    -- }}}
    -- {{{ LspInstaller
    use {
        'williamboman/nvim-lsp-installer',
        requires = {'neovim/nvim-lspconfig'},
        config = function () require('plugins.nvim-lsp').nvim_lsp_installer_setup() end,
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
            'nvim-treesitter/completion-treesitter',
            'saadparwaiz1/cmp_luasnip',
        },
    }
    -- }}}
    -- {{{ Nvim TreeSitter - Provide Syntax information
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function ()
            require'nvim-treesitter.configs'.setup({
              ensure_installed = "all", -- either "all" or a list of languages
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
            vim.keymap.set('n', '<Leader>gs', '<cmd>vertical botright Gstatus<CR>')
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

    -------------------
    ----  Interface  --
    -------------------
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

    ---------------------------
    ----  Language specific  --
    ---------------------------
    -- {{{ SympylFold - Python language folding
    use {
        'tmhedberg/SimpylFold',
        ft = 'python',
        config = function ()
            vim.g.SimplylFold_docstring_preview = 1 -- Be able to read doc
        end,
    }
    -- }}}
    -- {{{ Vim ClangFormat - Brings command such as ClangFormat
    use {
        'rhysd/vim-clang-format',
        ft = 'cpp',
    }
    -- }}}
    -- {{{ Black nvim format
    use {
        'averms/black-nvim',
        config = function ()
            vim.cmd[[let g:black#settings = { 'line_length': 120 }]]
        end,
    }
    -- }}}
    -- {{{ Salmon vim
    use 'git@git.soundhound.com:terrier/salmon-vim'
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
    -- {{{ Markdown preview
    use({
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    })
    -- }}}

    -------------------------
    ----  Integrated apps  --
    -------------------------

    -- {{{ DiffView
    use {
        'sindrets/diffview.nvim',
    }
    -- }}}
    -- {{{ TagBar -- Show symbols information on side window
    use {
        'majutsushi/tagbar',
        cmd = 'TagbarToggle',
        setup = function ()
            vim.keymap.set('n', '<F8>', '<cmd>TagbarToggle<CR>') -- Opens a tagbar on the right side
        end,
    }
    -- }}}
    -- {{{ Plenary.nvim -- Set of Lua functions used by other plugins
    use 'nvim-lua/plenary.nvim'
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
        setup = function () vim.keymap.set('n', '<leader>n', '<cmd>NvimTreeToggle<CR>') end,
        requires = {'kyazdani42/nvim-web-devicons'},
    }
    -- }}}

    if packer_bootstrap then
        require('packer').sync()
        require('packer').compile()
    end
end)
--}}}
