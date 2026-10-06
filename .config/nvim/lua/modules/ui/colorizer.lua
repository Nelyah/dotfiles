local M = {
	filetypes = { "css", "scss", "sass", "less", "html", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte", "lua", "json", "yaml", "toml" },
}

function M.setup()
	local colorizer = require("colorizer")
	local large_file = require("core.large_file")
	local filetypes = {}
	for _, ft in ipairs(M.filetypes) do
		filetypes[ft] = true
	end
	colorizer.setup({ filetypes = {}, buftypes = {} })
	local function update(buf)
		if not vim.api.nvim_buf_is_loaded(buf) then
			return
		end
		if large_file.is_large(buf) or vim.bo[buf].buftype ~= "" or not filetypes[vim.bo[buf].filetype] then
			colorizer.detach_from_buffer(buf)
		elseif not colorizer.is_buffer_attached(buf) then
			colorizer.attach_to_buffer(buf)
		end
	end
	local group = vim.api.nvim_create_augroup("ColorizerPolicy", { clear = true })
	vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
		group = group,
		callback = function(args) update(args.buf) end,
	})
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "LargeFileChanged",
		callback = function(args) update(args.data.buf) end,
	})
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		update(buf)
	end
end

return M
