local api = vim.api
local preview_buffer = require("core.preview_buffer")
local test_code = require("modules.lsp.test_code")

local M = { max_depth = 12, max_nodes = 500, hide_tests = true }

local ns = api.nvim_create_namespace("CallStack")
api.nvim_set_hl(0, "CallStackSite", { link = "Search", default = true })

local function item_key(item)
	local start = item.selectionRange.start
	return string.format("%s:%d:%d", item.uri, start.line, start.character)
end

local function relpath(uri)
	return vim.fn.fnamemodify(vim.uri_to_fname(uri), ":~:.")
end

local Node = {}
Node.__index = Node

function Node.new(item, range, parent)
	local id = string.format("%s@%d:%d", item_key(item), range.start.line, range.start.character)
	return setmetatable({
		id = parent and parent.id .. ">" .. id or id,
		item = item,
		uri = item.uri,
		range = range,
		parent = parent,
		depth = parent and parent.depth + 1 or 0,
		children = {},
		recursive = false,
		truncated = false,
	}, Node)
end

function Node:calls_itself()
	local key = item_key(self.item)
	local node = self.parent
	while node do
		if item_key(node.item) == key then
			return true
		end
		node = node.parent
	end
	return false
end

function Node:visible(expanded, into)
	into = into or {}
	table.insert(into, self)
	if expanded[self.id] then
		for _, child in ipairs(self.children) do
			child:visible(expanded, into)
		end
	end
	return into
end

local function call_site(call)
	return call.fromRanges[1] or call.from.selectionRange
end

local function by_location(a, b)
	if a.from.uri ~= b.from.uri then
		return a.from.uri < b.from.uri
	end
	return call_site(a).start.line < call_site(b).start.line
end

local Session = {}
Session.__index = Session

function Session.new(client, bufnr, item)
	local classifier = test_code.new(client.root_dir or vim.fn.getcwd(), client.offset_encoding)
	return setmetatable({
		client = client,
		bufnr = bufnr,
		item = item,
		encoding = client.offset_encoding,
		classifier = classifier,
		calls = {},
		show_tests = not M.hide_tests or classifier:is_test(item.uri, item.selectionRange),
	}, Session)
end

function Session:incoming(item, callback)
	local key = item_key(item)
	if self.calls[key] then
		callback(nil, self.calls[key])
		return true
	end
	return self.client:request("callHierarchy/incomingCalls", { item = item }, function(err, result)
		if not err then
			self.calls[key] = result or {}
			table.sort(self.calls[key], by_location)
		end
		callback(err, self.calls[key])
	end, self.bufnr)
end

function Session:resolve(on_done)
	local root = Node.new(self.item, self.item.selectionRange, nil)
	local pending, count, hidden, first_error = 0, 1, 0, nil

	local function finish()
		pending = pending - 1
		if pending == 0 then
			on_done(root, hidden, first_error)
		end
	end

	local function expand(node)
		if node.depth >= M.max_depth then
			node.truncated = true
			return
		end
		pending = pending + 1
		local sent = self:incoming(node.item, function(err, calls)
			first_error = first_error or (err and err.message)
			for _, call in ipairs(calls or {}) do
				local site = call_site(call)
				if not self.show_tests and self.classifier:is_test(call.from.uri, site) then
					hidden = hidden + 1
				elseif count >= M.max_nodes then
					node.truncated = true
					break
				else
					count = count + 1
					local child = Node.new(call.from, site, node)
					table.insert(node.children, child)
					if child:calls_itself() then
						child.recursive = true
					else
						expand(child)
					end
				end
			end
			finish()
		end)
		if not sent then
			finish()
		end
	end

	expand(root)
end

local View = {}
View.__index = View

local function float(buf, enter, config)
	return api.nvim_open_win(buf, enter, vim.tbl_extend("force", {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		title_pos = "center",
		noautocmd = true,
	}, config))
end

local function placeholder_buf(text)
	local buf = api.nvim_create_buf(false, true)
	api.nvim_buf_set_lines(buf, 0, -1, false, { text })
	vim.bo[buf].modifiable = false
	return buf
end

local function line_byte(line, encoding, character)
	return vim.str_byteindex(line, encoding, character, false)
end

function View.open(session, origin_win, root, hidden)
	local self = setmetatable({
		session = session,
		origin_win = origin_win,
		encoding = session.encoding,
		buffers = preview_buffer.new(),
		placeholder = placeholder_buf("File unavailable or too large to preview"),
		list_buf = api.nvim_create_buf(false, true),
		highlighted = nil,
		closed = false,
		expanded = { [root.id] = true },
	}, View)
	local bo = vim.bo[self.list_buf]
	bo.bufhidden = "wipe"
	bo.shiftwidth = 2
	bo.filetype = "callstack"
	self:layout()
	self:attach()
	self:render(root, hidden)
	self:update_preview()
	return self
end

function View:title(hidden)
	local title = " Call stack: " .. self.session.item.name
	if hidden > 0 then
		title = title .. string.format(" · %d test call%s hidden (a)", hidden, hidden == 1 and "" or "s")
	elseif self.session.show_tests then
		title = title .. " · tests shown (a)"
	end
	return title .. " "
end

function View:marker(node)
	if #node.children == 0 then
		return "  "
	end
	return self.expanded[node.id] and "▾ " or "▸ "
end

function View:render(root, hidden)
	self.root = root
	self.hidden = hidden
	self:draw()
end

function View:draw()
	self.nodes = self.root:visible(self.expanded)
	self.line_of = {}
	local lines, marks = {}, {}
	for i, node in ipairs(self.nodes) do
		self.line_of[node.id] = i
		local indent = string.rep("  ", node.depth)
		local marker = self:marker(node)
		local suffix = node.recursive and " ↻" or node.truncated and " …" or ""
		local location = string.format("%s:%d", relpath(node.uri), node.range.start.line + 1)
		lines[i] = indent .. marker .. node.item.name .. suffix .. "  " .. location
		local name_start = #indent + #marker
		local name_end = name_start + #node.item.name
		table.insert(marks, { i - 1, #indent, name_start, "NonText" })
		table.insert(marks, { i - 1, name_start, name_end, "Function" })
		table.insert(marks, { i - 1, name_end, name_end + #suffix, "WarningMsg" })
		table.insert(marks, { i - 1, #lines[i] - #location, #lines[i], "Comment" })
	end
	vim.bo[self.list_buf].modifiable = true
	api.nvim_buf_set_lines(self.list_buf, 0, -1, false, lines)
	vim.bo[self.list_buf].modifiable = false
	api.nvim_buf_clear_namespace(self.list_buf, ns, 0, -1)
	for _, mark in ipairs(marks) do
		api.nvim_buf_set_extmark(self.list_buf, ns, mark[1], mark[2], { end_col = mark[3], hl_group = mark[4] })
	end
	api.nvim_win_set_config(self.list_win, { title = self:title(self.hidden), title_pos = "center" })
end

function View:focus(node)
	while node and not self.line_of[node.id] do
		node = node.parent
	end
	api.nvim_win_set_cursor(self.list_win, { node and self.line_of[node.id] or 1, 0 })
	self:update_preview()
end

function View:expand()
	local node = self:current()
	if #node.children == 0 then
		return
	end
	if self.expanded[node.id] then
		self:focus(node.children[1])
		return
	end
	self.expanded[node.id] = true
	self:draw()
	self:focus(node)
end

function View:collapse()
	local node = self:current()
	if self.expanded[node.id] and #node.children > 0 then
		self.expanded[node.id] = nil
		self:draw()
		self:focus(node)
	elseif node.parent then
		self:focus(node.parent)
	end
end

function View:toggle_tests()
	local current = self:current()
	self.session.show_tests = not self.session.show_tests
	self.session:resolve(function(root, hidden)
		if self.closed then
			return
		end
		self:render(root, hidden)
		self:focus(current)
	end)
end

function View:layout()
	local width = math.max(math.floor(vim.o.columns * 0.9), 20)
	local height = math.max(math.floor((vim.o.lines - vim.o.cmdheight) * 0.8), 5)
	local row = math.floor((vim.o.lines - vim.o.cmdheight - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)
	local list_width = math.floor(width * 0.4)

	self.list_win = float(self.list_buf, true, {
		row = row,
		col = col,
		width = list_width,
		height = height - 2,
		title = " ",
	})
	local wo = vim.wo[self.list_win]
	wo.cursorline = true
	wo.wrap = false
	wo.foldenable = false

	self.preview_win = float(self.placeholder, false, {
		row = row,
		col = col + list_width + 2,
		width = math.max(width - list_width - 4, 1),
		height = height - 2,
		title = " ",
		focusable = false,
	})
end

function View:attach()
	local group = api.nvim_create_augroup("CallStack" .. self.list_buf, { clear = true })
	api.nvim_create_autocmd("CursorMoved", {
		group = group,
		buffer = self.list_buf,
		callback = function()
			self:update_preview()
		end,
	})
	api.nvim_create_autocmd({ "WinLeave", "BufWipeout" }, {
		group = group,
		buffer = self.list_buf,
		callback = function()
			vim.schedule(function()
				self:close()
			end)
		end,
	})
	local opts = { buffer = self.list_buf, nowait = true }
	for _, lhs in ipairs({ "<CR>", "gf" }) do
		vim.keymap.set("n", lhs, function()
			self:jump()
		end, vim.tbl_extend("force", opts, { desc = "Open call site" }))
	end
	vim.keymap.set("n", "l", function()
		self:expand()
	end, vim.tbl_extend("force", opts, { desc = "Expand callers, or go to first caller" }))
	vim.keymap.set("n", "h", function()
		self:collapse()
	end, vim.tbl_extend("force", opts, { desc = "Collapse callers, or go to callee" }))
	vim.keymap.set("n", "a", function()
		self:toggle_tests()
	end, vim.tbl_extend("force", opts, { desc = "Toggle test callers" }))
	for _, lhs in ipairs({ "q", "<Esc>" }) do
		vim.keymap.set("n", lhs, function()
			self:close()
		end, vim.tbl_extend("force", opts, { desc = "Close call stack" }))
	end
end

function View:current()
	return self.nodes[api.nvim_win_get_cursor(self.list_win)[1]]
end

function View:clear_highlight()
	if self.highlighted and api.nvim_buf_is_valid(self.highlighted) then
		api.nvim_buf_clear_namespace(self.highlighted, ns, 0, -1)
	end
	self.highlighted = nil
end

function View:show_buf(buf)
	if api.nvim_win_get_buf(self.preview_win) ~= buf then
		local eventignore = vim.o.eventignore
		vim.o.eventignore = "all"
		pcall(api.nvim_win_set_buf, self.preview_win, buf)
		vim.o.eventignore = eventignore
	end
	local wo = vim.wo[self.preview_win]
	wo.number = true
	wo.cursorline = true
	wo.foldenable = false
	wo.wrap = false
end

function View:update_preview()
	if self.closed or not api.nvim_win_is_valid(self.preview_win) then
		return
	end
	local node = self:current()
	local buf = self.buffers:get(vim.uri_to_bufnr(node.uri)) or self.placeholder
	self:clear_highlight()
	self:show_buf(buf)
	api.nvim_win_set_config(self.preview_win, { title = " " .. relpath(node.uri) .. " ", title_pos = "center" })
	if buf == self.placeholder then
		return
	end

	local start, stop = node.range.start, node.range["end"]
	local lnum = math.min(start.line, api.nvim_buf_line_count(buf) - 1)
	local line = api.nvim_buf_get_lines(buf, lnum, lnum + 1, false)[1] or ""
	local col = line_byte(line, self.encoding, start.character)
	local end_col = stop.line == start.line and line_byte(line, self.encoding, stop.character) or #line
	api.nvim_buf_set_extmark(buf, ns, lnum, col, { end_col = math.max(end_col, col), hl_group = "CallStackSite" })
	self.highlighted = buf

	api.nvim_win_set_cursor(self.preview_win, { lnum + 1, col })
	api.nvim_win_call(self.preview_win, function()
		vim.cmd("normal! zz")
	end)
end

function View:close()
	if self.closed then
		return
	end
	self.closed = true
	self:clear_highlight()
	for _, win in ipairs({ self.preview_win, self.list_win }) do
		if win and api.nvim_win_is_valid(win) then
			api.nvim_win_close(win, true)
		end
	end
	self.buffers:reset()
	if api.nvim_buf_is_valid(self.placeholder) then
		api.nvim_buf_delete(self.placeholder, { force = true })
	end
end

function View:jump()
	local node = self:current()
	self:close()
	if api.nvim_win_is_valid(self.origin_win) then
		api.nvim_set_current_win(self.origin_win)
	end
	vim.lsp.util.show_document({ uri = node.uri, range = node.range }, self.encoding, { focus = true })
end

function M.open()
	local bufnr = api.nvim_get_current_buf()
	local win = api.nvim_get_current_win()
	local client = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/prepareCallHierarchy" })[1]
	if not client then
		vim.notify("No attached LSP client supports call hierarchy", vim.log.levels.WARN)
		return
	end
	local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
	client:request("textDocument/prepareCallHierarchy", params, function(err, result)
		if err then
			vim.notify(err.message, vim.log.levels.WARN)
			return
		end
		local item = result and result[1]
		if not item then
			vim.notify("No call hierarchy item under cursor", vim.log.levels.WARN)
			return
		end
		api.nvim_echo({ { "Resolving call stack of " .. item.name .. "…" } }, false, {})
		local session = Session.new(client, bufnr, item)
		session:resolve(function(root, hidden, message)
			api.nvim_echo({ { "" } }, false, {})
			if message then
				vim.notify("Call stack incomplete: " .. message, vim.log.levels.WARN)
			end
			View.open(session, win, root, hidden)
		end)
	end, bufnr)
end

return M
