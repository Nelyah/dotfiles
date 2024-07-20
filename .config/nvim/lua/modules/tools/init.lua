local plugin = require("core.packer").register_plugin

plugin({ -- Easily search and move around the buffer
	"easymotion/vim-easymotion",
	config = function()
		vim.keymap.set("n", "/", "<Plug>(easymotion-sn)", { remap = true })
		vim.keymap.set("o", "/", "<Plug>(easymotion-tn)", { remap = true })
	end,
})

plugin({ -- Sane binding to navigate between vim and tmux
	"christoomey/vim-tmux-navigator",
	config = function()
		require("modules.tools.vim-tmux-navigator").setup()
	end,
})

plugin("terryma/vim-multiple-cursors")

plugin({ -- Align text based on pattern
	"godlygeek/tabular",
	config = function()
		vim.keymap.set({ "n", "v" }, "<Leader>T=", "<cmd>Tabularize /=<CR>")
	end,
})

plugin("tpope/vim-commentary") -- comments based on the file type
plugin("tpope/vim-surround")
plugin("tpope/vim-repeat") -- Allow repeating plugin actions and more
plugin("tpope/vim-eunuch") -- Provide basic commands (chmod, mkdir, rename, etc.)
plugin({ "ryvnf/readline.vim", branch = "main" })

plugin({ -- Add Table mode for writing them in Markdown
	"dhruvasagar/vim-table-mode",
	ft = { "markdown", "pandoc", "vimwiki.markdown" },
})

plugin({ -- Many conceal and folding features
	"plasticboy/vim-markdown",
	ft = { "markdown", "pandoc", "vimwiki.markdown" },
	config = function()
		vim.g.vim_markdown_folding_disabled = 1
	end,
})

plugin({
	"rhysd/vim-grammarous",
	cmd = "GrammarousCheck",
})

-- Docstring automatic generation
vim.g.doge_enable_mappings = 0 -- disable the default mappings
plugin({
	"kkoomen/vim-doge",
	build = ":call doge#install()",
	config = function()
		vim.g.doge_doc_standard_python = "google"
		vim.g.doge_doc_standard_cpp = "doxygen_javadoc"

		vim.keymap.set({ "n", "i", "x" }, "<TAB>", "<Plug>(doge-comment-jump-forward)")
		vim.keymap.set({ "n", "i", "x" }, "<S-TAB>", "<Plug>(doge-comment-jump-backward)")
	end,
})

-- To be efficient in caching other plugins, impatient needs to be loaded
-- before them. It also needs to add some configuration options to the main
-- scope.
-- If impatient is installed, this piece of code will execute before any plugin is loaded
local has_impatient, _ = pcall(require, "impatient")
if has_impatient then
	_G.__luacache_config = {
		chunks = {
			enable = true,
			path = vim.fn.stdpath("cache") .. "/luacache_chunks",
		},
		modpaths = {
			enable = true,
			path = vim.fn.stdpath("cache") .. "/luacache_modpaths",
		},
	}
	require("impatient").enable_profile()
end
plugin({
	"lewis6991/impatient.nvim",
})

plugin({ -- Autoformat
	"stevearc/conform.nvim",
	lazy = false,
	keys = {
		{
			"gF",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			mode = "",
			desc = "[F]ormat buffer",
		},
	},
	opts = {
		notify_on_error = false,
		formatters_by_ft = {
			lua = { "stylua" },
			-- Conform can also run multiple formatters sequentially
			python = function(bufnr)
				if require("conform").get_formatter_info("ruff_format", bufnr).available then
					return { "ruff_format" }
				else
					return { "isort", "black" }
				end
			end,

			shell = { "shfmt" },
			--
			-- You can use a sub-list to tell conform to run *until* a formatter
			-- is found.
			javascript = { { "prettierd", "prettier" } },
			cpp = { "clang-format" },
			go = { "golines" },
			json = { "jq" },
			cmake = { "gersemi" },
		},
	},
})

plugin({ -- Linting
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		lint.linters_by_ft = {
			markdown = { "markdownlint" },
			python = { "ruff", "mypy" },
			json = { "jsonlint" },
			sh = { "shellcheck" },
		}

		if os.getenv("VIRTUAL_ENV") then
			vim.list_extend(
				lint.linters.mypy.args,
				{ "--python-executable", os.getenv("VIRTUAL_ENV") .. "/bin/python3" }
			)
		end

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				require("lint").try_lint()
			end,
		})
	end,
})
