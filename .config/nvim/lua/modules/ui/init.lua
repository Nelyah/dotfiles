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
		end, { desc = "Toggle Git diff view" })
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
	init = function()
		vim.api.nvim_create_user_command("Blame", function()
			require("gitsigns").blame()
		end, { desc = "Show Git blame" })
	end,
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
				end, { desc = "Go to next Git hunk or diff change" })

				map("n", "[c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gitsigns.nav_hunk("prev")
					end
				end, { desc = "Go to previous Git hunk or diff change" })

				local gitsign_key_prefix = "<leader>g"

				-- Actions
				map("n", gitsign_key_prefix .. "s", gitsigns.stage_hunk, { desc = "Stage Git hunk" })
				map("n", gitsign_key_prefix .. "r", gitsigns.reset_hunk, { desc = "Reset Git hunk" })
				map("v", gitsign_key_prefix .. "s", function()
					gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "Stage selected Git lines" })
				map("v", gitsign_key_prefix .. "r", function()
					gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "Reset selected Git lines" })
				map("n", gitsign_key_prefix .. "S", gitsigns.stage_buffer, { desc = "Stage entire buffer" })
				map("n", gitsign_key_prefix .. "u", gitsigns.undo_stage_hunk, { desc = "Undo staging Git hunk" })
				map("n", gitsign_key_prefix .. "R", gitsigns.reset_buffer, { desc = "Reset entire buffer" })
				map("n", gitsign_key_prefix .. "p", gitsigns.preview_hunk, { desc = "Preview Git hunk" })
				map("n", gitsign_key_prefix .. "b", gitsigns.toggle_current_line_blame, { desc = "Toggle current line Git blame" })
				map("n", gitsign_key_prefix .. "d", gitsigns.preview_hunk_inline, { desc = "Preview Git hunk inline" })
				map("n", gitsign_key_prefix .. "D", function()
					gitsigns.diffthis("~")
				end, { desc = "Diff buffer against previous commit" })

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select Git hunk" })
			end,
		})
	end,
})
-- }}}
-- {{{ Nvim colorizer - Colour highlighter
plugin({
	"catgoose/nvim-colorizer.lua",
	ft = require("modules.ui.colorizer").filetypes,
	config = function()
		require("modules.ui.colorizer").setup()
	end,
})
-- }}}
-- {{{ Onedark - Colour scheme with support for treesitter syntax
plugin({
	"navarasu/onedark.nvim",
	priority = 1000,
	config = function()
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
		vim.api.nvim_set_hl(0, "GitSignsDeleteVirtLn", { link = "DiffviewDiffDelete" })
		vim.api.nvim_set_hl(0, "GitSignsDeleteVirtLnInLine", { link = "DiffviewDiffDeleteWord" })
		vim.api.nvim_set_hl(0, "GitSignsDeleteInline", { link = "DiffviewDiffDeleteWord" })
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
	dependencies = { "nvim-tree/nvim-web-devicons" },
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
			on_attach = function(bufnr)
				require("nvim-tree.api").map.on_attach.default(bufnr)
				vim.keymap.del("n", "J", { buffer = bufnr })
				vim.keymap.del("n", "K", { buffer = bufnr })
			end,
			view = {
				width = 40,
			},
		})
	end,
	init = function()
		vim.keymap.set("n", "<leader>n", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
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
	cmd = { "FzfLua", "FT" },
	keys = {
		{ "<leader>i", desc = "Search project text" },
		{ "<leader>o", desc = "Find files" },
		{ "<leader>x", desc = "Find commands" },
		{ "<leader>s", desc = "Search current buffer lines" },
		{ "<c-x>h", desc = "Search help tags" },
		{ ",", desc = "Find buffers" },
	},
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("modules.ui.fzf-lua").setup()
	end,
})
-- }}}
-- {{{ Scrollview (scrollbar with diagnostic icons)
plugin({
	"dstein64/nvim-scrollview",
	event = "VeryLazy",
	dependencies = { "lewis6991/gitsigns.nvim" },
	config = function()
		require("scrollview").setup({
			excluded_filetypes = { "NvimTree" },
			byte_limit = require("core.large_file").max_bytes,
			line_limit = require("core.large_file").max_lines,
			current_only = true,
			base = "right",
			signs_scrollbar_overlap = "over",
			signs_on_startup = { "conflicts", "diagnostics", "search" },
			diagnostics_severities = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN },
		})
		require("scrollview.contrib.gitsigns").setup({
			add_symbol = "▏",
			change_symbol = "▏",
			delete_symbol = "▁",
			add_highlight = "GitSignsAdd",
			change_highlight = "GitSignsChange",
			delete_highlight = "GitSignsDelete",
			add_priority = 35,
			change_priority = 35,
			delete_priority = 35,
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
