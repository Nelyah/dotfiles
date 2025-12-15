local plugin = require("core.packer").register_plugin

plugin({
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lsp = require("modules.lsp.nvim-lsp")
		lsp.setup()
		lsp.lspconfig()
		lsp.enable()
	end,
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
	},
})

plugin({
	"williamboman/mason.nvim",
	config = function()
		require("mason").setup({
			-- Add installed binaries at the end of the PATH
			-- This is important for binaries that are otherwise available locally
			-- and which versions would be preferred
			PATH = "append",
		})

		require("mason-lspconfig").setup({
			-- Install these automatically if missing.
			ensure_installed = {
				"clang-format",
				"clangd",
				"jq",
				"jsonlint",
				"lua_ls",
				"pyright",
				"rust_analyzer",
			},
			-- We enable LSP after our `vim.lsp.config(...)` overrides are applied.
			automatic_enable = false,
		})
	end,
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
	},
})
plugin({
	"williamboman/mason-lspconfig.nvim",
	lazy = true,
})

-- Plugin showing the LSP loading status at the bottom right
plugin({ "j-hui/fidget.nvim", opts = {}, event = "VeryLazy" })

-- {{{ Goto-preview, allow floating window preview of LSP things
plugin({
	"rmagatti/goto-preview",
	dependencies = {
		"rmagatti/logger.nvim" ,
	},
	event = "BufEnter",
	init = function()
		vim.keymap.set("n", "gs", require("goto-preview").goto_preview_declaration)
		vim.keymap.set("n", "gS", require("goto-preview").goto_preview_definition)
		vim.keymap.set("n", "gx", require("goto-preview").close_all_win)
	end,
	opts = {
		height = 30,
	},
	config = true, -- necessary as per https://github.com/rmagatti/goto-preview/issues/88
})
-- }}}
