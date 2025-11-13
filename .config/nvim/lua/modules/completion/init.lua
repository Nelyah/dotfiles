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
	"olimorris/codecompanion.nvim",
	opts = {},
	dependencies = {
		{ "nvim-lua/plenary.nvim", branch = "master" },
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		local spinner = require("modules.completion.codecompanion.spinner")
		spinner:init()

		require("codecompanion").setup({
			send = {
				callback = function(chat)
					vim.cmd("<esc>o")
					vim.cmd("stopinsert")
					chat:submit()
					chat:add_buf_message({ role = "llm", content = "" })
				end,
				index = 1,
				description = "Send",
			},
			strategies = {

				chat = {
					adapter = {
						name = "copilot",
						model = "gpt-5-codex",
					},
					roles = {
						llm = function(adapter)
							local model_name = ''
							if adapter.schema and adapter.schema.model and adapter.schema.model.default then
								local model = adapter.schema.model.default
								if type(model) == 'function' then
									model = model(adapter)
								end
								model_name = ' (' .. model .. ')'
							end
							return '  ' .. adapter.formatted_name .. model_name
						end,
						user = ' User',
					},
				},
				stop = {
					modes = {
						n = '<C-c>',
					},
					index = 4,
					callback = 'keymaps.stop',
					description = 'Stop Request',
				},
				agent = {
					adapter = 'copilot',
					model = "gpt-5-codex",
				},
				inline = {
					adapter = {
						name = "copilot",
						model = "gpt-5-codex",
					},
				},
			},
			memory = {
				opts = {
					chat = {
						enabled = true,
					},
				},
			},
		})
		vim.keymap.set("v", "<leader>cc", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })
		vim.keymap.set("n", "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
	end,
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
	"saghen/blink.cmp",
	dependencies = { "rafamadriz/friendly-snippets" },

	-- use a release tag to download pre-built binaries
	version = "1.*",
	---
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		-- See :h blink-cmp-config-keymap for defining your own keymap
		keymap = {
			preset = "default",
			["<C-s>"] = { "select_and_accept", "fallback" },
		},
		cmdline = {
			keymap = {
				preset = "cmdline",
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
			default = { "lsp", "path", "snippets", "buffer" },
			per_filetype = {
				codecompanion = { "codecompanion" },
			},
		},

		-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
		-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
		-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
		--
		-- See the fuzzy documentation for more information
		fuzzy = { implementation = "prefer_rust" },
	},
	opts_extend = { "sources.default" },
})
-- }}}
