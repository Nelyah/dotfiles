local large_file = require("core.large_file")

local M = {}
M.__index = M

local function scratch_buf(path)
	local stat = vim.uv.fs_stat(path)
	if not stat or stat.type ~= "file" or stat.size > large_file.max_bytes then
		return nil
	end
	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok then
		return nil
	end
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	local ft = vim.filetype.match({ filename = path, contents = lines })
	if ft then
		local lang = vim.treesitter.language.get_lang(ft)
		if not (lang and pcall(vim.treesitter.start, buf, lang)) then
			vim.bo[buf].syntax = ft
		end
	end
	return buf
end

function M.new()
	return setmetatable({ scratch = {} }, M)
end

function M:get(bufnr)
	if vim.api.nvim_buf_is_loaded(bufnr) then
		return bufnr
	end
	if not self.scratch[bufnr] then
		self.scratch[bufnr] = scratch_buf(vim.api.nvim_buf_get_name(bufnr))
	end
	return self.scratch[bufnr]
end

function M:reset()
	for _, buf in pairs(self.scratch) do
		if vim.api.nvim_buf_is_valid(buf) then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end
	self.scratch = {}
end

return M
