local plugin = require("core.packer").register_plugin

-- {{{ DiffView
plugin({
	cmd = {
		"DiffviewFileHistory",
		"DiffviewToggleFiles",
		"DiffviewFocusFiles",
		"DiffviewRefresh",
		"DiffviewClose",
		"DiffviewOpen",
		"DiffviewLog",
	},
	"sindrets/diffview.nvim",
})
-- }}}
-- {{{ Vim Fugitive - Git interface
plugin({
	"tpope/vim-fugitive",
	cmd = "Git",
	config = function()
		vim.keymap.set("n", "<Leader>gs", "<cmd>vertical botright Git status<CR>")
	end,
})
-- }}}
-- {{{ Gitsigns - Git information on the sign column
plugin({
	"lewis6991/gitsigns.nvim",
	event = "VeryLazy",
	dependencies = {
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
	event = "VeryLazy",
	config = function()
		require("modules.ui.lualine").setup()
	end,
	dependencies = {
		"kdheepak/tabline.nvim",
	},
})
plugin({
	"kdheepak/tabline.nvim",
	lazy = true,
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
	dependencies = {
		"nvim-lualine/lualine.nvim",
		"kyazdani42/nvim-web-devicons",
	},
})
-- }}}
-- {{{ Todo Comments -- Highlight them and make them searchable
plugin({
	"folke/todo-comments.nvim",
	event = "VeryLazy",
	config = function()
		require("todo-comments").setup()
	end,
	dependencies = "nvim-lua/plenary.nvim",
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
	init = function()
		vim.keymap.set("n", "<leader>n", "<cmd>NvimTreeToggle<CR>")
	end,
	dependencies = { "kyazdani42/nvim-web-devicons" },
})
-- }}}
-- {{{ Telescope
plugin({
	"nvim-telescope/telescope.nvim",
	lazy = true,
	init = function()
		require("modules.ui.telescope").init()
	end,
	config = function()
		require("modules.ui.telescope").setup()
	end,
})
plugin({
	"nvim-lua/plenary.nvim",
	lazy = true,
})
plugin({
	"kyazdani42/nvim-web-devicons",
	lazy = true,
})
if vim.fn.executable("make") then
	plugin({
		"nvim-telescope/telescope-fzf-native.nvim",
		lazy = true,
		build = "make",
		config = function()
			require("telescope").load_extension("fzf")
		end,
	})
end
plugin({
	"nvim-telescope/telescope-live-grep-args.nvim",
	lazy = true,
	config = function()
		require("telescope").load_extension("live_grep_args")
	end,
})

-- Plugin to provide a nicer interface to some things (like some code-action)
plugin({
	"stevearc/dressing.nvim",
	event = "VeryLazy",
	opts = {},
})
-- }}}
-- {{{ Markdown Preview
plugin({
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
	build = function()
		vim.fn["mkdp#util#install"]()
	end,
})
-- }}}
