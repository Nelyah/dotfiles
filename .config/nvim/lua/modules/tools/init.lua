local plugin = require("core.packer").register_plugin

plugin({ -- Easily search and move around the buffer
	"easymotion/vim-easymotion",
	event = "VeryLazy",
	init = function()
		vim.keymap.set("n", "/", "<Plug>(easymotion-sn)", { remap = true })
		vim.keymap.set("o", "/", "<Plug>(easymotion-tn)", { remap = true })
	end,
})

plugin({ -- Sane binding to navigate between vim and tmux
	"christoomey/vim-tmux-navigator",
	event = "VeryLazy",
    init = function ()
        vim.g.tmux_navigator_no_mappings = 1
    end,
	config = function()
		require("modules.tools.vim-tmux-navigator").setup()
	end,
})

plugin({ "terryma/vim-multiple-cursors", event = "VeryLazy" })

plugin({ -- Align text based on pattern
	"godlygeek/tabular",
	event = "VeryLazy",
	config = function()
		vim.keymap.set({ "n", "v" }, "<Leader>T=", "<cmd>Tabularize /=<CR>")
	end,
})
--
-- comments based on the file type
plugin({ "tpope/vim-commentary", event = "VeryLazy" })
plugin({ "tpope/vim-surround", event = "VeryLazy" })
plugin({ "tpope/vim-repeat", event = "VeryLazy" }) -- Allow repeating plugin actions and more
plugin("tpope/vim-eunuch") -- Provide basic commands (chmod, mkdir, rename, etc.)
plugin({ "ryvnf/readline.vim", branch = "main", event = "VeryLazy" })

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
	cmd = "DogeGenerate",
	build = ":call doge#install()",
	config = function()
		vim.g.doge_doc_standard_python = "google"
		vim.g.doge_doc_standard_cpp = "doxygen_javadoc"

		vim.keymap.set({ "n", "i", "x" }, "<TAB>", "<Plug>(doge-comment-jump-forward)")
		vim.keymap.set({ "n", "i", "x" }, "<S-TAB>", "<Plug>(doge-comment-jump-backward)")
	end,
})

plugin({ -- Autoformat
	"stevearc/conform.nvim",
	event = "VeryLazy",
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

		lint.base_linters_by_ft = {
			markdown = { "markdownlint" },
			python = { "ruff", "mypy" },
			json = { "jsonlint" },
			sh = { "shellcheck" },
		}

        -- Only load available linters and provide a utility command
        -- to install them
		local base_linters_by_ft = lint.base_linters_by_ft
        local missing_linters = {}
        lint.linters_by_ft = {}
        for filetype, linters in pairs(base_linters_by_ft) do
            local new_linters = {}
            for _, linter in ipairs(linters) do
                if vim.fn.executable(linter) == 1 then
                    table.insert(new_linters, linter)
                else
                    table.insert(missing_linters, linter)
                end
            end
            lint.linters_by_ft[filetype] = new_linters
        end
        vim.api.nvim_create_user_command("InstallLinters", function ()
            vim.cmd("MasonInstall " .. table.concat(missing_linters, " "))
            lint.linters_by_ft = base_linters_by_ft
        end, {})

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

-- Show symbol information on the side bar, currently powered by LSP only
plugin({
	"hedyhli/outline.nvim",
	lazy = true,
	cmd = { "Outline", "OutlineOpen" },
	opts = {},
})
