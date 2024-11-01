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
		-- vim.keymap.set("n", "<Leader>gs", "<cmd>vertical botright Git status<CR>")
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
		require("gitsigns").setup({
			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Navigation
				map("n", "]c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gitsigns.nav_hunk("next")
					end
				end)

				map("n", "[c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gitsigns.nav_hunk("prev")
					end
				end)

				local gitsign_key_prefix = "<leader>g"

				-- Actions
				map("n", gitsign_key_prefix .. "s", gitsigns.stage_hunk)
				map("n", gitsign_key_prefix .. "r", gitsigns.reset_hunk)
				map("v", gitsign_key_prefix .. "s", function()
					gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end)
				map("v", gitsign_key_prefix .. "r", function()
					gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end)
				map("n", gitsign_key_prefix .. "S", gitsigns.stage_buffer)
				map("n", gitsign_key_prefix .. "u", gitsigns.undo_stage_hunk)
				map("n", gitsign_key_prefix .. "R", gitsigns.reset_buffer)
				map("n", gitsign_key_prefix .. "p", gitsigns.preview_hunk)
				map("n", gitsign_key_prefix .. "b", function()
					gitsigns.blame_line({ full = true })
				end)
				map("n", gitsign_key_prefix .. "b", gitsigns.toggle_current_line_blame)
				map("n", gitsign_key_prefix .. "d", gitsigns.diffthis)
				map("n", gitsign_key_prefix .. "D", function()
					gitsigns.diffthis("~")
				end)
				map("n", gitsign_key_prefix .. "d", gitsigns.toggle_deleted)

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
			end,
		})
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
		require("onedark").setup({
			style = "warmer",
			colors = {
				bg0 = "#222222",
			},
			lualine = {
				transparent = true, -- lualine center bar transparency
			},
			diagnostics = {
				darker = true, -- darker colors for diagnostic
				undercurl = false, -- use undercurl instead of underline for diagnostics
				background = true, -- use background color for virtual text
			},
		})
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
	end,
	dependencies = {
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = vim.fn.executable("cmake")
					and "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build"
				or "make",
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
-- {{{ Fzf-Lua
plugin({
	"ibhagwan/fzf-lua",
	-- optional for icon support
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		-- calling `setup` is optional for customization
		require("fzf-lua").setup({})

		vim.keymap.set("n", "<leader>o", function()
			require("fzf-lua").files({
				["header"] = false,
				["cwd_prompt"] = false,
				fzf_opts = {
					["--layout"] = "default",
				},
			})
		end)
	end,
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
-- {{{ Scrollview (scrollbar with diagnostic icons)
plugin({
	"dstein64/nvim-scrollview",
	config = function()
		require("scrollview").setup({
			excluded_filetypes = { "nerdtree" },
			current_only = true,
			base = "right",
			signs_on_startup = { "conflicts", "diagnostics", "search" },
			diagnostics_severities = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN },
		})
	end,
})
-- }}}
