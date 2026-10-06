local api = vim.api
local markers = require("core.conflict_markers")
local namespace = api.nvim_create_namespace("nelyah_conflict_markers")
local buffers = {}
local large_file = require("core.large_file")
local max_line_bytes = 4096
local batch_lines = 1024

local function define_highlights()
	for name, background in pairs({ Current = "#522d2d", Parent = "#272727", Incoming = "#353e32" }) do
		api.nvim_set_hl(0, "ConflictMarker" .. name, { bg = background })
		api.nvim_set_hl(0, "ConflictMarker" .. name .. "Hi", { fg = "#dddddd", bg = background, bold = true })
	end
end

local function scan_line(bufnr, row, length)
	if length == 0 or length > max_line_bytes then
		return nil
	end
	local prefix = api.nvim_buf_get_text(bufnr, row, 0, row, 1, {})[1]
	if not markers.is_candidate(prefix) then
		return nil
	end
	return markers.lex(api.nvim_buf_get_text(bufnr, row, 0, row, length, {})[1], row)
end

local function remove_highlights(bufnr, conflict)
	for _, id in ipairs(conflict.marks) do
		api.nvim_buf_del_extmark(bufnr, namespace, id)
	end
end

local function draw_conflict(bufnr, conflict)
	local ids = {}
	local function highlight(first, last, group)
		if first < last then
			ids[#ids + 1] = api.nvim_buf_set_extmark(bufnr, namespace, first, 0, {
				end_row = last,
				end_col = 0,
				hl_group = "ConflictMarker" .. group,
				hl_eol = true,
				right_gravity = true,
				end_right_gravity = false,
			})
		end
	end
	local first, separator, last = conflict.first.row, conflict.separator.row, conflict.last.row
	highlight(first, first + 1, "CurrentHi")
	highlight(first + 1, conflict.base and conflict.base.row or separator, "Current")
	if conflict.base then
		highlight(conflict.base.row, conflict.base.row + 1, "ParentHi")
		highlight(conflict.base.row + 1, separator, "Parent")
	end
	highlight(separator, separator + 1, "IncomingHi")
	highlight(separator + 1, last, "Incoming")
	highlight(last, last + 1, "IncomingHi")
	conflict.marks = ids
end

local function render(state)
	local tokens = {}
	for _, token in pairs(state.tokens) do
		tokens[#tokens + 1] = token
	end
	table.sort(tokens, function(a, b) return a.row < b.row end)
	tokens[#tokens + 1] = { kind = markers.Kind.Eof, row = api.nvim_buf_line_count(state.bufnr), width = 0 }
	local rendered = {}
	for _, conflict in ipairs(markers.parse(tokens)) do
		local previous = state.rendered[conflict.first]
		if previous and not previous.dirty and previous.base == conflict.base
			and previous.separator == conflict.separator and previous.last == conflict.last then
			conflict.marks = previous.marks
		else
			if previous then
				remove_highlights(state.bufnr, previous)
			end
			draw_conflict(state.bufnr, conflict)
		end
		rendered[conflict.first] = conflict
		state.rendered[conflict.first] = nil
	end
	for _, conflict in pairs(state.rendered) do
		remove_highlights(state.bufnr, conflict)
	end
	state.rendered = rendered
end

local function queue_scan(state)
	if state.scheduled then
		return
	end
	state.scheduled = true
	vim.schedule(function()
		state.scheduled = false
		local bufnr = state.bufnr
		if buffers[bufnr] ~= state or not api.nvim_buf_is_loaded(bufnr) then
			return
		end
		if large_file.is_large(bufnr) or vim.bo[bufnr].buftype ~= "" then
			api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
			state.tokens, state.rendered, state.ranges = {}, {}, {}
			state.disabled = true
			return
		end
		state.disabled = false
		local range = state.ranges[1]
		if range then
			local last = math.min(range.last, range.first + batch_lines)
			local offset = api.nvim_buf_get_offset(bufnr, range.first)
			for row = range.first, last - 1 do
				local next_offset = api.nvim_buf_get_offset(bufnr, row + 1)
				state.tokens[row] = scan_line(bufnr, row, next_offset - offset - 1)
				offset = next_offset
			end
			range.first = last
			if last == range.last then
				table.remove(state.ranges, 1)
			end
		end
		if #state.ranges > 0 then
			queue_scan(state)
		else
			render(state)
		end
	end)
end

local function reset(state)
	state.tokens = {}
	state.ranges = { { first = 0, last = api.nvim_buf_line_count(state.bufnr) } }
	queue_scan(state)
end

local function changed(state, first, last, new_last)
	if state.disabled then
		reset(state)
		return
	end
	for _, conflict in pairs(state.rendered) do
		if first <= conflict.last.row + 1 and last >= conflict.first.row then
			conflict.dirty = true
		end
	end
	local delta = new_last - last
	local tokens = {}
	for row, token in pairs(state.tokens) do
		if row < first then
			tokens[row] = token
		elseif row >= last then
			token.row = row + delta
			tokens[token.row] = token
		end
	end
	state.tokens = tokens
	local function shift(row)
		if row >= last then
			return row + delta
		end
		return math.min(row, first)
	end
	for _, range in ipairs(state.ranges) do
		range.first, range.last = shift(range.first), shift(range.last)
	end
	state.ranges[#state.ranges + 1] = { first = first, last = new_last }
	table.sort(state.ranges, function(a, b) return a.first < b.first end)
	local ranges = {}
	for _, range in ipairs(state.ranges) do
		local previous = ranges[#ranges]
		if previous and range.first <= previous.last then
			previous.last = math.max(previous.last, range.last)
		elseif range.first < range.last then
			ranges[#ranges + 1] = range
		end
	end
	state.ranges = ranges
	queue_scan(state)
end

local function attach(bufnr)
	if buffers[bufnr] or not api.nvim_buf_is_loaded(bufnr) or vim.bo[bufnr].buftype ~= "" then
		return
	end
	local state = { bufnr = bufnr, tokens = {}, rendered = {} }
	buffers[bufnr] = state
	api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
	local attached = api.nvim_buf_attach(bufnr, false, {
		on_lines = function(_, _, _, first, last, new_last)
			changed(state, first, last, new_last)
		end,
		on_reload = function()
			reset(state)
		end,
		on_detach = function()
			buffers[bufnr] = nil
		end,
	})
	if attached then
		reset(state)
	else
		buffers[bufnr] = nil
	end
end

local group = api.nvim_create_augroup("NelyahGitConflictMarkers", { clear = true })
api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWinEnter" }, {
	group = group,
	callback = function(args) attach(args.buf) end,
})
api.nvim_create_autocmd("ColorScheme", { group = group, callback = define_highlights })
define_highlights()
for _, bufnr in ipairs(api.nvim_list_bufs()) do
	attach(bufnr)
end
