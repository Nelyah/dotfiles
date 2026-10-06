local M = { max_bytes = 1000000, max_lines = 20000 }

function M.is_large(buf)
	if not vim.api.nvim_buf_is_loaded(buf) then
		return false
	end
	local lines = vim.api.nvim_buf_line_count(buf)
	return lines > M.max_lines or vim.api.nvim_buf_get_offset(buf, lines) > M.max_bytes
end

function M.setup()
	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufEnter", "TextChanged", "TextChangedI", "TextChangedP" }, {
		group = vim.api.nvim_create_augroup("LargeFilePolicy", { clear = true }),
		callback = function(args)
			local large = M.is_large(args.buf)
			if vim.b[args.buf].large_file == large then
				return
			end
			vim.b[args.buf].large_file = large
			vim.api.nvim_exec_autocmds("User", {
				pattern = "LargeFileChanged",
				data = { buf = args.buf, large = large },
			})
		end,
	})
end

return M
