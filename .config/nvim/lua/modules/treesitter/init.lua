local plugin = require("core.packer").register_plugin

local ensure_installed = {
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
}

local core_installed = {
	"lua",
	"python",
	"yaml",
	"cpp",
	"vim",
	"toml",
	"json",
	"git_config",
	"git_rebase",
	"gitattributes",
	"gitcommit",
	"gitignore",
}

plugin({
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	branch = "main",
	version = false, -- last release is way too old and doesn't work on Windows
	config = function()
		local treesitter = require("nvim-treesitter")
		treesitter.setup()
		require("modules.work").treesitter_setup()
		require'nvim-treesitter'.install(core_installed)
		vim.wo.foldmethod = 'expr'
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

		local ensure_set = {}
		for _, lang in ipairs(ensure_installed) do
			ensure_set[lang] = true
		end


		local installing = {}

		local function installed_set()
			local installed = treesitter.get_installed("parsers") or {}
			local out = {}
			for _, lang in ipairs(installed) do
				out[lang] = true
			end
			return out
		end

		vim.api.nvim_create_user_command("TSInstallEnsured", function()
			local installed = installed_set()
			local missing = {}
			for _, lang in ipairs(ensure_installed) do
				if not installed[lang] then
					table.insert(missing, lang)
				end
			end

			if #missing == 0 then
				vim.notify("Tree-sitter parsers already installed.")
				return
			end

			treesitter.install(missing, { summary = true })
		end, {})

		vim.schedule(function()
			local installed = installed_set()
			local missing = {}
			for _, lang in ipairs(core_installed) do
				if not installed[lang] then
					table.insert(missing, lang)
				end
			end
			if #missing > 0 then
				treesitter.install(missing, { summary = true })
			end
		end)

		local group = vim.api.nvim_create_augroup("treesitter-auto-install", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			callback = function(args)
				local ft = vim.bo[args.buf].filetype
				if ft == "" then
					return
				end

				local lang = ft
				if vim.treesitter.language and vim.treesitter.language.get_lang then
					lang = vim.treesitter.language.get_lang(ft) or ft
				end

				if ensure_set[lang] and not installing[lang] then
					local installed = installed_set()
					if not installed[lang] then
						installing[lang] = true
						treesitter.install(lang)
					end
				end

				pcall(vim.treesitter.start, args.buf, lang)
			end,
		})
	end,
})
