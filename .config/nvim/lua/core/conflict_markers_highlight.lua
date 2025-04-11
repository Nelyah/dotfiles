-- I don't want to execute this on files that are bigger than this
-- Because we still read all lines and it could make start up WAY
-- too slow (eg. file is multiple GB)
local max_file_lines = 1000000

local function setup()
	local highlight_conflict_current_hi = "ConflictMarkerCurrentHi"
	local highlight_conflict_current = "ConflictMarkerCurrent"
	local highlight_conflict_parent_hi = "ConflictMarkerParentHi"
	local highlight_conflict_parent = "ConflictMarkerParent"
	local highlight_conflict_incoming_hi = "ConflictMarkerIncomingHi"
	local highlight_conflict_incoming = "ConflictMarkerIncoming"

	-- Define highlight groups for conflict markers
	local white = "#dddddd"
	local current_changes_bg = "#522d2d"
	local parent_changes_bg = "#272727"
	local incoming_changes_bg = "#353e32"

	vim.api.nvim_set_hl(0, highlight_conflict_current_hi, { fg = white, bg = current_changes_bg, bold = true })
	vim.api.nvim_set_hl(0, highlight_conflict_current, { bg = current_changes_bg })
	vim.api.nvim_set_hl(0, highlight_conflict_parent_hi, { fg = white, bg = parent_changes_bg, bold = true })
	vim.api.nvim_set_hl(0, highlight_conflict_parent, { bg = parent_changes_bg })
	vim.api.nvim_set_hl(0, highlight_conflict_incoming_hi, { fg = white, bg = incoming_changes_bg, bold = true })
	vim.api.nvim_set_hl(0, highlight_conflict_incoming, { bg = incoming_changes_bg })

	-- Define markers as local variables so they can be reused
	local current_change_marker        = "<<<<<<<"
	local parent_change_marker         = "|||||||"
	local start_incoming_change_marker = "======="
	local end_incoming_change_marker   = ">>>>>>>"

	-- Function to scan the buffer and add extmark highlights for conflict markers
	local function highlight_conflict_markers(bufnr)
		bufnr = bufnr or vim.api.nvim_get_current_buf()

		-- Namespace for conflict marker highlights
		-- Namespaces allow to erase all colouring applied to one specific namespace. This means
		-- I can colour things and then at the end erase all it the end marker isn't there (without
		-- affecting other conflicts)
		local conflict_count = 1
		local conflict_ns = vim.api.nvim_create_namespace("conflict_markers_" .. conflict_count)

		-- Clear previous extmarks in the namespace
		vim.api.nvim_buf_clear_namespace(bufnr, 0, 0, -1)
		local lines                     = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		local first_line                = vim.fn.line("w0")
		local last_line                 = vim.fn.line("w$")
		local conflict_hl_name          = nil
		local has_started, has_ended    = false, false

		local current_change_regex      = "^" .. current_change_marker
		local marker_parent_regex       = "^" .. parent_change_marker
		local marker_incoming_regex     = "^" .. start_incoming_change_marker
		local marker_end_incoming_regex = "^" .. end_incoming_change_marker

		for i, line in ipairs(lines) do
			if i < first_line - 500 or i > last_line + 500 then
				goto continue
			end

			if line:match(current_change_regex) then
				if not has_ended then
					-- If the previous conflict did not close properly, clear extmarks and use a new namespace.
					vim.api.nvim_buf_clear_namespace(bufnr, conflict_ns, 0, -1)
					conflict_count = conflict_count + 1
					conflict_ns = vim.api.nvim_create_namespace("conflict_markers_" .. conflict_count)
				end
				conflict_hl_name = highlight_conflict_current_hi
				has_started = true
			elseif has_started and line:match(marker_parent_regex) then
				conflict_hl_name = highlight_conflict_parent_hi
			elseif has_started and line:match(marker_incoming_regex) then
				conflict_hl_name = highlight_conflict_incoming_hi
			elseif has_started and line:match(marker_end_incoming_regex) then
				conflict_hl_name = highlight_conflict_incoming_hi
				has_ended = true
			end

			-- This is a line that should be highlighted because it's inside conflict markers
			if conflict_hl_name then
				-- Use extmarks with 'hl_eol' true so the highlight extends across the entire line.
				vim.api.nvim_buf_set_extmark(bufnr, conflict_ns, i - 1, 0, {
					end_line = i,
					hl_group = conflict_hl_name,
					hl_eol = true,
				})

				if conflict_hl_name == highlight_conflict_parent_hi then
					conflict_hl_name = highlight_conflict_parent
				elseif conflict_hl_name == highlight_conflict_current_hi then
					conflict_hl_name = highlight_conflict_current
				elseif conflict_hl_name == highlight_conflict_incoming_hi then
					conflict_hl_name = highlight_conflict_incoming
				end

				--
				-- If this is ending a conflict, increment the namespace count
				if line:match("^" .. end_incoming_change_marker) then
					conflict_hl_name = nil
					has_started, has_ended = false, false
					conflict_count = conflict_count + 1
					conflict_ns = vim.api.nvim_create_namespace("conflict_markers_" .. conflict_count)
				end
			end

			::continue::
		end

		-- If the last conflict is not closed properly, clear its extmarks.
		if not has_ended then
			vim.api.nvim_buf_clear_namespace(bufnr, conflict_ns, 0, -1)
		end
	end
	-- Automatically update conflict marker highlights on buffer read and text changes.
	vim.api.nvim_create_augroup("NelyahGitConflictMarkers", { clear = true })
	vim.api.nvim_create_autocmd({ "BufReadPost", "TextChanged", "InsertLeave" }, {
		group = "NelyahGitConflictMarkers",
		callback = function(args)
			if vim.api.nvim_buf_line_count(args.buf) > max_file_lines then
				return
			end
			highlight_conflict_markers(args.buf)
		end,
	})
end

-- Required because loading the colorscheme overrides a lot of this
-- So this is to load it (again) once the ColorScheme event is sent.
vim.api.nvim_create_augroup("CustomHighlights", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
	group = "CustomHighlights",
	callback = function()
		if vim.api.nvim_buf_line_count(0) > max_file_lines then
			return
		end
		setup()
	end,
})

-- Load this module anyway
if vim.api.nvim_buf_line_count(0) < max_file_lines then
	setup()
end
