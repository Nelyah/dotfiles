local plugin = require("core.packer").register_plugin

-- {{{ DiffView
plugin({
    "sindrets/diffview.nvim",
})
-- }}}

-- {{{ Fzf.vim
plugin({ -- Fuzzy search everything
    "junegunn/fzf.vim",
    config = require("modules.ui.fzf").setup(),
})
-- }}}

-- {{{ FzfLua
plugin({ -- Install Lua interface for FZF
    "ibhagwan/fzf-lua",
    config = function()
        require("modules.ui.fzf-lua").setup()
    end,
    requires = {
        "vijaymarupudi/nvim-fzf",
        "kyazdani42/nvim-web-devicons",
    },
})
-- }}}
-- {{{ Fzf.vim
plugin({ -- Install FZF
    "junegunn/fzf",
    run = "./install --bin",
})
-- }}}

-- {{{ Vim Fugitive - Git interface
plugin({
    "tpope/vim-fugitive",
    config = function()
        vim.keymap.set("n", "<Leader>gs", "<cmd>vertical botright Git status<CR>")
    end,
})
-- }}}

-- {{{ Gitsigns - Git information on the sign column
plugin({
    "lewis6991/gitsigns.nvim",
    requires = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        require("gitsigns").setup()
    end,
})
-- }}}

-- {{{ Nvim colorizer - Colour highlighter
plugin({
    "norcalli/nvim-colorizer.lua",
    config = function()
        require("colorizer").setup()
    end,
})
-- }}}
-- {{{ Onedark - Colour scheme with support for treesitter syntax
plugin({
    "navarasu/onedark.nvim",
    config = function()
        require("modules.treesitter") -- needed for this theme
        require("modules.ui.onedark").setup()
    end,
})
-- }}}

-- {{{ LuaLine - Status line and buffer line
plugin({
    "nvim-lualine/lualine.nvim",
    config = function()
        require("modules.ui.lualine").setup()
    end,
    requires = {
        "kdheepak/tabline.nvim",
    },
})
-- }}}
-- {{{ Tabline - Better buffers and tabs. Only used for tabs in lualine
plugin({
    "kdheepak/tabline.nvim",
    config = function()
        require("tabline").setup({
            enable = false, -- Set up by lualine
            options = {
                component_separators = { "", "" },
                section_separators = { "", "" },
            },
        })
    end,
    requires = {
        "nvim-lualine/lualine.nvim",
        "kyazdani42/nvim-web-devicons",
    },
})
-- }}}

-- {{{ Todo Comments -- Highlight them and make them searchable
plugin({
    "folke/todo-comments.nvim",
    config = function()
        require("todo-comments").setup()
    end,
    requires = "nvim-lua/plenary.nvim",
})
-- }}}

-- {{{ TagBar -- Show symbols information on side window
plugin({ -- Opens a tagbar on the right side
    "majutsushi/tagbar",
    cmd = "TagbarToggle",
    config = function()
        vim.keymap.set("n", "<F8>", "<cmd>TagbarToggle<CR>")
    end,
})
-- }}}

-- {{{ NvimTree -- Show files on side window
plugin({
    "kyazdani42/nvim-tree.lua",
    cmd = "NvimTreeToggle",
    config = function()
        require("nvim-tree").setup({
            view = {
                width = 40,
            },
        })
    end,
    setup = function()
        vim.keymap.set("n", "<leader>n", "<cmd>NvimTreeToggle<CR>")
    end,
    requires = { "kyazdani42/nvim-web-devicons" },
})
-- }}}
