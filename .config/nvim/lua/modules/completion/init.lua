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
-- {{{ LuaSnip
plugin({
	"L3MON4D3/LuaSnip",
	lazy = true,
	config = function()
		require("luasnip.loaders.from_vscode").lazy_load()
		vim.keymap.set("i", "<c-c>", function()
			if require("luasnip").expand_or_jumpable() == true then
				require("luasnip").expand_or_jump()
				return
			end
			return "<c-c>"
		end)
	end,
	dependencies = { "rafamadriz/friendly-snippets", "nvim-cmp" },
})
-- }}}
-- {{{ nvim-autopairs
plugin({
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = function()
		require("nvim-autopairs").setup({})
	end,
})
-- }}}
-- {{{ Nvim Cmp - Provide autocompletion
plugin({
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	config = function()
		require("modules.completion.nvim-cmp").setup()
	end,
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"saadparwaiz1/cmp_luasnip",
	},
})
-- }}}
