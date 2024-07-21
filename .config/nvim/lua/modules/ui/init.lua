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
		require("onedark").setup()
		vim.cmd([[colorscheme onedark]])
		vim.cmd([[highlight IncSearch guibg=#135564 guifg=white]])
		vim.cmd([[highlight Search guibg=#135564 guifg=white]])
		vim.cmd([[highlight Folded guibg=default guifg=grey]])
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
	version = false, -- telescope did only one release, so use HEAD for now
	init = function()
		require("modules.ui.telescope").init()
	end,
	config = function()
		require("modules.ui.telescope").setup()
		local ok, err = pcall(require("telescope").load_extension, "fzf")
		if not ok then
			local lib = plugin.dir .. "/build/libfzf.so"
			if not vim.uv.fs_stat(lib) then
				print("`telescope-fzf-native.nvim` not built. Rebuilding...")
				require("lazy").build({ plugins = { plugin }, show = false }):wait(function()
					print("Rebuilding `telescope-fzf-native.nvim` done.\nPlease restart Neovim.")
				end)
			else
				print("Failed to load `telescope-fzf-native.nvim`:\n" .. err)
			end
		end
	end,
	dependencies = {
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = vim.fn.executable("make") and "make"
				or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
			enabled = vim.fn.executable("make") or vim.fn.executable("cmake"),
		},
	},
})
plugin({
	"nvim-lua/plenary.nvim",
	lazy = true,
})
plugin({
	"kyazdani42/nvim-web-devicons",
	lazy = true,
})
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
