local plugin = require("core.packer").register_plugin

plugin({ -- Easily search and move around the buffer
    "easymotion/vim-easymotion",
    config = function()
        vim.keymap.set("n", "/", "<Plug>(easymotion-sn)", { remap = true })
        vim.keymap.set("o", "/", "<Plug>(easymotion-tn)", { remap = true })
    end,
})

plugin({ -- Sane binding to navigate between vim and tmux
    "christoomey/vim-tmux-navigator",
    config = function()
        require("modules.tools.vim-tmux-navigator").setup()
    end,
})

plugin("terryma/vim-multiple-cursors")

-- {{{ Neorg
plugin({
    "nvim-neorg/neorg",
    after = "nvim-treesitter",
    config = function()
        require("neorg").setup({
            load = {
                ["core.defaults"] = {},
                ["core.norg.concealer"] = {},
                ["core.norg.qol.toc"] = {},
                ["core.norg.completion"] = {
                    config = {
                        engine = "nvim-cmp",
                    },
                },
            },
        })
    end,
    requires = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
})
-- }}}

plugin({ -- Align text based on pattern
    "godlygeek/tabular",
    config = function()
        vim.keymap.set({ "n", "v" }, "<Leader>T=", "<cmd>Tabularize /=<CR>")
    end,
})

plugin("tpope/vim-commentary") -- comments based on the file type
plugin("tpope/vim-surround")
plugin("tpope/vim-repeat") -- Allow repeating plugin actions and more
plugin("tpope/vim-eunuch") -- Provide basic commands (chmod, mkdir, rename, etc.)
plugin("ryvnf/readline.vim")

plugin({ -- Add Table mode for writing them in Markdown
    "dhruvasagar/vim-table-mode",
    ft = { "markdown", "pandoc", "vimwiki.markdown" },
})

plugin({ -- Many conceal and folding features
    "plasticboy/vim-markdown",
    ft = { "markdown", "pandoc", "vimwiki.markdown" },
    config = function()
        vim.g.vim_markdown_folding_disabled = 1
    end,
})

plugin({
    "vimwiki/vimwiki",
    config = function()
        require("modules.tools.vimwiki").setup()
    end,
})

plugin({
    "rhysd/vim-grammarous",
    cmd = "GrammarousCheck",
})
