local plugin = require("core.packer").register_plugin

-- {{{ DiffView
plugin({
    "sindrets/diffview.nvim",
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
        require("todo-comments").setup({
  keywords = {
    FIX = {
      icon = " ", -- icon used for the sign, and in search results
      color = "error", -- can be a hex color, or a named color (see below)
      alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
      -- signs = false, -- configure signs for some keywords individually
    },
    -- @todo: blah
    TODO = { icon = " ", color = "info", alt = {"todo"} },
    HACK = { icon = " ", color = "warning", alt = {"hack"} },
    WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX", "warning", "xxx", "warn" } },
    PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE", "optim", "performance", "optimize", "perf" } },
    NOTE = { icon = " ", color = "hint", alt = { "INFO", "info", "note" } },
    TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED", "testing", "passed", "failed", "test" } },
  },
  highlight = {
      -- @todo
    pattern = {[[.*@\(KEYWORDS\)]], [[.*@(KEYWORDS):]], [[.*<(KEYWORDS)\s*:]]}, -- pattern or table of patterns, used for highlighting (vim regex)
  },
        })
    end,
    requires = "nvim-lua/plenary.nvim",
})
-- }}}
-- {{{ TagBar -- Show symbols information on side window
plugin({
         -- Opens a tagbar on the right side
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
-- {{{ Telescope
plugin({
    "nvim-telescope/telescope.nvim",
    requires = { "nvim-lua/plenary.nvim", "kyazdani42/nvim-web-devicons" },
    config = function()
        require("modules.ui.telescope").setup()
    end,
})
if vim.fn.executable("make") then
    plugin({
        "nvim-telescope/telescope-fzf-native.nvim",
        run = "make",
        config = function()
            require("telescope").load_extension("fzf")
        end,
        requires = { "nvim-telescope/telescope.nvim" },
    })
end
plugin({
    "nvim-telescope/telescope-live-grep-args.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
    config = function()
        require("telescope").load_extension("live_grep_args")
    end,
})
-- }}}
-- {{{ Markdown Preview
plugin({
    "iamcco/markdown-preview.nvim",
    run = function()
        vim.fn["mkdp#util#install"]()
    end,
})
-- }}}
