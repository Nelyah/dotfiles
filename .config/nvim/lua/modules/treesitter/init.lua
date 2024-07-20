local plugin = require("core.packer").register_plugin

plugin({
	"nvim-treesitter/nvim-treesitter",
	event = { "VeryLazy" },
	build = ":TSUpdate",
	version = false, -- last release is way too old and doesn't work on Windows
	lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
	---@type TSConfig
	---@diagnostic disable-next-line: missing-fields
	opts = {
		highlight = { enable = true },
		indent = { enable = true },
		ensure_installed = {
			"arduino",
			"awk",
			"bash",
			"bibtex",
			"c",
			"cmake",
			"comment",
			"cpp",
			"css",
			"csv",
			"diff",
			"dockerfile",
			"doxygen",
			"fortran",
			"git_config",
			"git_rebase",
			"gitattributes",
			"gitcommit",
			"gitignore",
			"gnuplot",
			"go",
			"gomod",
			"gosum",
			"gpg",
			"graphql",
			"groovy",
			"html",
			"java",
			"javascript",
			"jq",
			"jsdoc",
			"json",
			"jsonc",
			"latex",
			"ledger",
			"lua",
			"luadoc",
			"luap",
			"make",
			"markdown",
			"markdown_inline",
			"mermaid",
			"muttrc",
			"ninja",
			"nix",
			"norg",
			"ocaml",
			"org",
			"passwd",
			"pem",
			"php",
			"printf",
			"python",
			"query",
			"r",
			"regex",
			"requirements",
			"ruby",
			"rust",
			"sql",
			"ssh_config",
			"strace",
			"tmux",
			"todotxt",
			"toml",
			"tsv",
			"tsx",
			"typescript",
			"vim",
			"vimdoc",
			"xml",
			"yaml",
		},
		incremental_selection = {
			enable = true,
			keymaps = {
				node_incremental = "v",
				scope_incremental = false,
				node_decremental = "<bs>",
			},
		},
	},
	---@param opts TSConfig
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end,
})
