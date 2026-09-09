local M = {}

local insertHeader = function()
	local fn = vim.fn
	local cur_filename = fn.expand("%:t")
	local cur_fileending = fn.expand("%:e")
	local start_lines = {
		'/* file "' .. cur_filename .. '" */',
		"/* Copyright " .. os.date("%Y") .. " SoundHound, Incorporated. All rights reserved. */",
		"",
	}
	local end_lines = {}
	if cur_fileending == "h" or cur_fileending == "ti" then
		local upper_filename = string.upper(cur_filename)
		local subs = { "%.", "_" }
		for i, pattern in pairs(subs) do
			subs[i] = string.gsub(upper_filename, pattern, "")
		end

		for _, out in pairs({
			"#ifndef " .. upper_filename,
			"#define " .. upper_filename,
			"",
		}) do
			table.insert(start_lines, out)
		end

		for _, out in pairs({
			"",
			"#endif /* " .. upper_filename .. " */",
		}) do
			table.insert(end_lines, out)
		end
	end
	fn.append(0, start_lines)
	fn.append(fn.line("$"), end_lines)
end

local ter_parser_path = vim.fn.expand("~/dev/tree-sitter-ter")

local register_treesitter_parser = function()
	vim.api.nvim_create_autocmd("User", {
		pattern = "TSUpdate",
		group = vim.api.nvim_create_augroup("soundhound-ts-parsers", { clear = true }),
		callback = function()
			require("nvim-treesitter.parsers").ter = {
				install_info = {
					path = ter_parser_path,
					queries = "queries",
				},
			}
		end,
	})

	vim.treesitter.language.register("ter", "ter")
end

M.setup = function()
	vim.filetype.add({
		extension = { ter = "ter" },
	})
	vim.api.nvim_create_user_command("InsertHeader", insertHeader, {})

	if vim.fn.isdirectory(ter_parser_path) == 1 then
		register_treesitter_parser()
	end
end

return M
