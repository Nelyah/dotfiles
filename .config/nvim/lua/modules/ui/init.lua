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
	init = function()
		vim.keymap.set("n", "<leader>gt", function()
			if next(require("diffview.lib").views) == nil then
				print("open")
				vim.cmd("DiffviewOpen")
			else
				print("close")
				vim.cmd("DiffviewClose")
			end
		end)
	end,
	config = function()
		require("diffview").setup({
			enhanced_diff_hl = true,
			file_panel = {
				win_config = {
					width = 50,
				},
			},
			file_history_panel = {
				win_config = {
					height = 16,
				},
			},
			keymaps = {
				file_panel = {
					{ "n", "<leader>w", "<Cmd>vertical resize 80<CR>", { desc = "Widen the file panel" } },
					{ "n", "<leader>W", "<Cmd>vertical resize 50<CR>", { desc = "Reset the file panel width" } },
				},
			},
			hooks = {
				diff_buf_win_enter = function(_, winid, ctx)
					if not ctx or not tostring(ctx.layout_name or ""):find("^diff2") then
						return
					end
					local winhl
					if ctx.symbol == "a" then
						winhl = table.concat({
							"DiffAdd:DiffviewDiffAddAsDelete",
							"DiffDelete:DiffviewDiffDeleteDim",
							"DiffChange:DiffviewDiffAddAsDelete",
							"DiffText:DiffviewDiffDeleteWord",
						}, ",")
					else
						winhl = table.concat({
							"DiffDelete:DiffviewDiffDeleteDim",
							"DiffAdd:DiffviewDiffAdd",
							"DiffChange:DiffviewDiffAdd",
							"DiffText:DiffviewDiffAddWord",
						}, ",")
					end
					vim.api.nvim_set_option_value("winhl", winhl, { win = winid })
				end,
			},
		})
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
			highlights = {
				["@nospell"] = { fg = "none" },
				["@spell"] = { fg = "none" },
				DiffAdd = { bg = "#1e2820" },
				DiffDelete = { bg = "#422928" },
				DiffChange = { bg = "#1e2820" },
				DiffText = { bg = "#2a3e30" },
				DiffviewDiffAdd = { bg = "#1e2820" },
				DiffviewDiffAddAsDelete = { bg = "#422928" },
				DiffviewDiffDelete = { bg = "#422928" },
				DiffviewDiffAddWord = { bg = "#2a3e30" },
				DiffviewDiffDeleteWord = { bg = "#783532" },
			},
		})
		vim.cmd([[colorscheme onedark]])
		vim.cmd([[highlight IncSearch guibg=#135564 guifg=white]])
		vim.cmd([[highlight Search guibg=#135564 guifg=white]])
		vim.cmd([[highlight Folded guibg=default guifg=grey]])
		vim.cmd([[highlight DiagnosticVirtualTextError guibg=#2C2525 guifg=#9e4747]])
		vim.cmd([[highlight DiagnosticVirtualTextWarn guibg=#2b2822 guifg=#a2782a]])
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
plugin({
	"kyazdani42/nvim-web-devicons",
	lazy = true,
})

-- Plugin to provide a nicer interface to some things (like some code-action)
plugin({
	"stevearc/dressing.nvim",
	event = "VeryLazy",
	opts = {},
})
-- {{{ Fzf-Lua
plugin({
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("modules.ui.fzf-lua").setup()
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
-- {{{ Markdown
plugin({
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown" },
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
	-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
	-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
	opts = {},
})
-- }}}
