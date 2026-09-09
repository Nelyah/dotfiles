local plugin = require("core.packer").register_plugin

-- Installed eagerly at startup. Everything else is installed on demand the
-- first time a buffer of that filetype is opened.
local core_installed = {
	"bash",
	"c",
	"cpp",
	"diff",
	"git_config",
	"git_rebase",
	"gitattributes",
	"gitcommit",
	"gitignore",
	"json",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"python",
	"query",
	"toml",
	"vim",
	"vimdoc",
	"yaml",
}

---@param buf integer
---@param lang string
local function try_attach(buf, lang)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	if not vim.treesitter.language.add(lang) then
		return
	end

	vim.treesitter.start(buf, lang)

	-- Without an indents query this would fall back to vim's own indentexpr anyway,
	-- but setting it unconditionally hides which languages are actually supported.
	if vim.treesitter.query.get(lang, "indents") then
		vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end
end

plugin({
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	branch = "main",
	version = false, -- last release is way too old and doesn't work on Windows
	config = function()
		local treesitter = require("nvim-treesitter")
		treesitter.setup()
		treesitter.install(core_installed)

		local available = treesitter.get_available()

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter-attach", { clear = true }),
			callback = function(args)
				local lang = vim.treesitter.language.get_lang(args.match)
				if not lang then
					return
				end

				if vim.tbl_contains(treesitter.get_installed("parsers"), lang) then
					try_attach(args.buf, lang)
				elseif vim.tbl_contains(available, lang) then
					treesitter.install(lang):await(function()
						try_attach(args.buf, lang)
					end)
				else
					-- Parser may still exist from another source on the runtimepath.
					try_attach(args.buf, lang)
				end
			end,
		})
	end,
})
