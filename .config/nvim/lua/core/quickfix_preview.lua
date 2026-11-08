local buffers = require("core.preview_buffer").new()

local M = { enabled = true, max_height = 20 }

local preview = { win = nil }

local function close_win()
	if preview.win and vim.api.nvim_win_is_valid(preview.win) then
		vim.api.nvim_win_close(preview.win, true)
	end
	preview.win = nil
end

local function reset()
	close_win()
	buffers:reset()
end

local function current_item(qf_win)
	local idx = vim.api.nvim_win_get_cursor(qf_win)[1]
	local what = { idx = idx, items = 0 }
	local list = vim.fn.getwininfo(qf_win)[1].loclist == 1 and vim.fn.getloclist(qf_win, what) or vim.fn.getqflist(what)
	local item = list.items[1]
	if item and item.valid == 1 and item.bufnr ~= 0 then
		return item
	end
end

local function float_config(qf_win, title)
	local height = math.min(M.max_height, vim.fn.win_screenpos(qf_win)[1] - 4)
	if height < 3 then
		return nil
	end
	return {
		relative = "win",
		win = qf_win,
		anchor = "SW",
		row = 0,
		col = 0,
		width = vim.api.nvim_win_get_width(qf_win) - 2,
		height = height,
		style = "minimal",
		border = "rounded",
		title = " " .. title .. " ",
		title_pos = "center",
		focusable = false,
		noautocmd = true,
	}
end

local function show(qf_win)
	close_win()
	if not M.enabled then
		return
	end
	local item = current_item(qf_win)
	local buf = item and buffers:get(item.bufnr)
	if not buf then
		return
	end
	local config = float_config(qf_win, vim.fn.fnamemodify(vim.api.nvim_buf_get_name(item.bufnr), ":~:."))
	if not config then
		return
	end
	preview.win = vim.api.nvim_open_win(buf, false, config)
	local wo = vim.wo[preview.win]
	wo.number = true
	wo.cursorline = true
	wo.foldenable = false
	local lnum = math.min(math.max(item.lnum, 1), vim.api.nvim_buf_line_count(buf))
	vim.api.nvim_win_set_cursor(preview.win, { lnum, math.max(item.col - 1, 0) })
	vim.api.nvim_win_call(preview.win, function()
		vim.cmd("normal! zz")
	end)
end

local function attach(qf_buf)
	local group = vim.api.nvim_create_augroup("QuickfixPreview" .. qf_buf, { clear = true })
	vim.api.nvim_create_autocmd({ "CursorMoved", "WinEnter" }, {
		group = group,
		buffer = qf_buf,
		callback = function()
			show(vim.api.nvim_get_current_win())
		end,
	})
	vim.api.nvim_create_autocmd({ "WinLeave", "BufWinLeave" }, {
		group = group,
		buffer = qf_buf,
		callback = function()
			vim.schedule(reset)
		end,
	})
	vim.keymap.set("n", "P", function()
		M.enabled = not M.enabled
		show(vim.api.nvim_get_current_win())
	end, { buffer = qf_buf, desc = "Toggle quickfix preview" })
end

function M.setup()
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("QuickfixPreview", { clear = true }),
		pattern = "qf",
		callback = function(args)
			attach(args.buf)
			vim.schedule(function()
				if vim.api.nvim_get_current_buf() == args.buf then
					show(vim.api.nvim_get_current_win())
				end
			end)
		end,
	})
end

return M
