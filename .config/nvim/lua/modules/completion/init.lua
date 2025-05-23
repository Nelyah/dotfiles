local plugin = require("core.packer").register_plugin

plugin({
	"github/copilot.vim",
	lazy = true,
	cmd = "Copilot",
	config = function()
		vim.keymap.set("i", "<C-a>", 'copilot#Accept("\\<CR>")', {
			expr = true,
			replace_keycodes = false,
		})
		vim.g.copilot_no_tab_map = true
		vim.g.copilot_enabled = false
	end,
})
plugin({
	"CopilotC-Nvim/CopilotChat.nvim",
	branch = "canary",
	cmd = "CopilotChatOpen",
	lazy = true,
	init = function()
		vim.keymap.set("n", "<leader>cc", function()
			if vim.g.copilot_chat_enabled == nil or vim.g.copilot_chat_enabled == false then
				vim.g.copilot_chat_enabled = true
				vim.cmd("CopilotChatOpen")
			else
				vim.g.copilot_chat_enabled = false
				vim.cmd("CopilotChatClose")
			end
		end)
	end,
	dependencies = {
		{ "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
	},
	opts = {
		debug = true, -- Enable debugging
	},
})
-- {{{ nvim-autopairs
plugin({
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = function()
		require("nvim-autopairs").setup({})
	end,
})
-- }}}
-- {{{ Blink.cmp - Provide autocompletion
plugin({
	'saghen/blink.cmp',
	dependencies = { 'rafamadriz/friendly-snippets' },

	-- use a release tag to download pre-built binaries
	version = '1.*',
	---
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		-- See :h blink-cmp-config-keymap for defining your own keymap
		keymap = {
			preset = 'default',
			["<C-s>"] = { "select_and_accept", "fallback" },
		},
		cmdline = {
			keymap = {
				preset = 'cmdline',
				["<C-e>"] = {},
			},
		},


		appearance = {
			use_nvim_cmp_as_default = true,
		},

		signature = { enabled = true },
		completion = { documentation = { auto_show = true } },

		-- Default list of enabled providers defined so that you can extend it
		-- elsewhere in your config, without redefining it, due to `opts_extend`
		sources = {
			default = { 'lsp', 'path', 'snippets', 'buffer' },
		},

		-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
		-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
		-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
		--
		-- See the fuzzy documentation for more information
		fuzzy = { implementation = "prefer_rust" }
	},
	opts_extend = { "sources.default" }
})
-- }}}
