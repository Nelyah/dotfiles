local plugin = require("core.packer").register_plugin

-- {{{ Snacks
plugin({
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		input = { enabled = true },
	},
	keys = {
		{
			"<leader>r",
			function()
				Snacks.rename.rename_file()
			end,
			desc = "Rename File",
		},
	},
	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "OilActionsPost",
			callback = function(event)
				for _, action in ipairs(event.data.actions or {}) do
					if action.type == "move" then
						Snacks.rename.on_rename_file(action.src_url, action.dest_url)
					end
				end
			end,
		})

		local prev = { new_name = "", old_name = "" }
		vim.api.nvim_create_autocmd("User", {
			pattern = "NvimTreeSetup",
			callback = function()
				local events = require("nvim-tree.api").events
				events.subscribe(events.Event.NodeRenamed, function(data)
					if prev.new_name ~= data.new_name or prev.old_name ~= data.old_name then
						prev = data
						Snacks.rename.on_rename_file(data.old_name, data.new_name)
					end
				end)
			end,
		})
	end,
})
-- }}}
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
		vim.keymap.set('n', '<leader>gt', function()
			if next(require('diffview.lib').views) == nil then
				print("open")
				vim.cmd('DiffviewOpen')
			else
				print("close")
				vim.cmd('DiffviewClose')
			end
		end)
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
	"NvChad/nvim-colorizer.lua",
	config = function()
		require("colorizer").setup()
	end,
})
-- }}}
-- {{{ Onedark - Colour scheme with support for treesitter syntax
plugin({
	"navarasu/onedark.nvim",
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
	"nvim-tree/nvim-tree.lua",
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
	dependencies = { "nvim-tree/nvim-web-devicons" },
})
-- }}}
-- {{{ Dependencies
plugin({
	"nvim-lua/plenary.nvim",
	lazy = true,
})
plugin({
	"nvim-tree/nvim-web-devicons",
	lazy = true,
})
-- }}}
-- {{{ Fzf-Lua
plugin({
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local fzf = require("fzf-lua")
		fzf.setup({})
		fzf.register_ui_select()

		local fzf_opts = {
			["cwd_prompt"] = false,
			fzf_opts = {
				["--layout"] = "default",
			},
		}

		vim.keymap.set("n", "<leader>i", function()
			fzf.live_grep_native(fzf_opts)
		end)
		vim.keymap.set("n", "<leader>o", function()
			fzf.files(vim.tbl_extend("force", fzf_opts, { ["header"] = false }))
		end, { nowait = true })
		vim.keymap.set("n", ",", function()
			fzf.buffers()
		end)
		vim.keymap.set("n", "<leader>x", function()
			fzf.commands()
		end)
		vim.keymap.set("n", "<leader>s", function()
			fzf.lgrep_curbuf()
		end)
		vim.keymap.set("n", "<c-x>h", function()
			fzf.help_tags()
		end)
		vim.api.nvim_create_user_command("FT", function()
			fzf.filetypes()
		end, {})
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
	'MeanderingProgrammer/render-markdown.nvim',
	ft = { "markdown" },
	dependencies = { 'nvim-tree/nvim-web-devicons' },
	opts = {},
})
-- }}}
