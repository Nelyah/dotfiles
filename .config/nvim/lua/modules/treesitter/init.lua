local plugin = require("core.packer").register_plugin
local large_file = require("core.large_file")
local indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

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
	if not vim.api.nvim_buf_is_loaded(buf) or large_file.is_large(buf) or vim.bo[buf].buftype ~= "" then
		return false
	end
	if vim.treesitter.language.get_lang(vim.bo[buf].filetype) ~= lang then
		return false
	end
	if not vim.treesitter.language.add(lang) then
		return false
	end

	vim.treesitter.start(buf, lang)

	-- Without an indents query this would fall back to vim's own indentexpr anyway,
	-- but setting it unconditionally hides which languages are actually supported.
	if vim.treesitter.query.get(lang, "indents") then
		if vim.bo[buf].indentexpr ~= indentexpr then
			vim.b[buf].treesitter_previous_indentexpr = vim.bo[buf].indentexpr
		end
		vim.bo[buf].indentexpr = indentexpr
	end
	return true
end

plugin({
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	branch = "main",
	version = false, -- last release is way too old and doesn't work on Windows
	config = function()
		local treesitter = require("nvim-treesitter")
		treesitter.setup({
			install_dir = vim.fn.stdpath("data") .. "/site",
		})
		vim.api.nvim_create_user_command("TSInstallCore", function()
			treesitter.install(core_installed)
		end, {})

		local available
		local function attach(buf)
			if not vim.api.nvim_buf_is_loaded(buf) or vim.bo[buf].buftype ~= "" then
				return
			end
			if large_file.is_large(buf) then
				vim.treesitter.stop(buf)
				if vim.bo[buf].indentexpr == indentexpr then
					vim.bo[buf].indentexpr = vim.b[buf].treesitter_previous_indentexpr or ""
				end
				return
			end
			local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
			if not lang or try_attach(buf, lang) then
				return
			end
			if not available then
				available = {}
				for _, name in ipairs(treesitter.get_available()) do
					available[name] = true
				end
			end
			if available[lang] then
				treesitter.install(lang):await(function()
					try_attach(buf, lang)
				end)
			end
		end
		local group = vim.api.nvim_create_augroup("treesitter-attach", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			callback = function(args) attach(args.buf) end,
		})
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "LargeFileChanged",
			callback = function(args) attach(args.data.buf) end,
		})
	end,
})
