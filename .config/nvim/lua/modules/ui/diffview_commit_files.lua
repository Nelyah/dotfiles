local api = vim.api

local M = {}

---@type table<FileHistoryView, CommitFilesPanel>
local panels = {}

local CommitFilesPanel

---@return CommitFilesPanel
local function panel_class()
	if CommitFilesPanel then
		return CommitFilesPanel
	end

	local oop = require("diffview.oop")
	local utils = require("diffview.utils")
	local config = require("diffview.config")
	local FileDict = require("diffview.vcs.file_dict").FileDict
	local FilePanel = require("diffview.scene.views.diff.file_panel").FilePanel

	---@class CommitFilesPanel : FilePanel
	---@field view FileHistoryView
	---@field dicts table<LogEntry, FileDict>
	CommitFilesPanel = oop.create_class("CommitFilesPanel", FilePanel)

	---@param view FileHistoryView
	function CommitFilesPanel:init(view)
		self:super(view.adapter, FileDict(), nil, nil)
		self.view = view
		self.dicts = setmetatable({}, { __mode = "k" })
		self.config_producer = function()
			return self:split_config()
		end
	end

	---@return integer?
	function CommitFilesPanel:anchor_win()
		local layout = self.view.cur_layout
		local first = layout and layout.windows[1]
		if first and first.id and api.nvim_win_is_valid(first.id) then
			return first.id
		end
		return nil
	end

	function CommitFilesPanel:split_config()
		local win_config = config.get_config().file_panel.win_config
		if vim.is_callable(win_config) then
			win_config = win_config()
		end
		return {
			type = "split",
			position = "left",
			relative = "win",
			win = self:anchor_win() or 0,
			width = win_config.width,
			win_opts = win_config.win_opts or {},
		}
	end

	---@return boolean
	function CommitFilesPanel:is_placed()
		local anchor = self:anchor_win()
		if not (anchor and self:is_open(self.view.tabpage)) then
			return false
		end
		return api.nvim_win_get_position(self.winid)[2] < api.nvim_win_get_position(anchor)[2]
	end

	function CommitFilesPanel:ensure_open()
		if self:is_placed() or not self:anchor_win() then
			return
		end
		self:close()
		self:open()
	end

	---@param entry LogEntry
	---@return FileDict
	function CommitFilesPanel:dict_for(entry)
		local dict = self.dicts[entry]
		if not dict then
			dict = FileDict()
			dict:set_working(entry.files)
			dict:update_file_trees()
			self.dicts[entry] = dict
		end
		return dict
	end

	---@param entry LogEntry
	---@param file FileEntry?
	function CommitFilesPanel:show(entry, file)
		self.files = self:dict_for(entry)
		self.rev_pretty_name = entry.commit and entry.commit.hash and entry.commit.hash:sub(1, 8) or nil
		self.cur_file = file
		self:sync()
		if file then
			self:highlight_file(file)
		end
	end

	function CommitFilesPanel:select_at_cursor()
		local item = self:get_item_at_cursor()
		if not item then
			return
		end
		if type(item.collapsed) == "boolean" then
			self:toggle_item_fold(item)
		else
			self.view:set_file(item, false)
		end
	end

	function CommitFilesPanel:close_fold_at_cursor()
		local dir, comp = self:get_dir_at_cursor()
		if not (dir and comp) then
			return
		end
		if not dir.collapsed then
			self:set_item_fold(dir, false)
			return
		end
		local dir_parent = utils.tbl_access(comp, "parent.parent")
		if dir_parent and dir_parent.name == "directory" then
			self:set_item_fold(dir_parent.context, false)
		end
	end

	---@param open boolean
	function CommitFilesPanel:set_all_folds(open)
		if self.listing_style ~= "tree" then
			return
		end
		self.components.working.files.comp:deep_some(function(comp)
			if comp.name == "directory" then
				comp.context.collapsed = not open
			end
		end)
		self:render()
		self:redraw()
	end

	function CommitFilesPanel:toggle_listing_style()
		self.listing_style = self.listing_style == "tree" and "list" or "tree"
		self:sync()
		if self.cur_file then
			self:highlight_file(self.cur_file)
		end
	end

	function CommitFilesPanel:setup_buffer()
		local default_opt = { silent = true, nowait = true, buffer = self.bufid }

		for _, mapping in ipairs(config.get_config().keymaps.file_panel) do
			if type(mapping[3]) == "string" then
				local opt = vim.tbl_extend("force", default_opt, mapping[4] or {}, { buffer = self.bufid })
				vim.keymap.set(mapping[1], mapping[2], mapping[3], opt)
			end
		end

		local function map(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, vim.tbl_extend("force", default_opt, { desc = desc }))
		end
		local function select()
			self:select_at_cursor()
		end
		local function next_file()
			self:highlight_next_file()
		end
		local function prev_file()
			self:highlight_prev_file()
		end
		local function close_fold()
			self:close_fold_at_cursor()
		end

		map("<cr>", select, "Open the diff for the selected entry")
		map("o", select, "Open the diff for the selected entry")
		map("l", select, "Open the diff for the selected entry")
		map("<2-LeftMouse>", select, "Open the diff for the selected entry")
		map("j", next_file, "Bring the cursor to the next file entry")
		map("<down>", next_file, "Bring the cursor to the next file entry")
		map("k", prev_file, "Bring the cursor to the previous file entry")
		map("<up>", prev_file, "Bring the cursor to the previous file entry")
		map("h", close_fold, "Collapse directory")
		map("zc", close_fold, "Collapse directory")
		map("zo", function()
			local dir = self:get_dir_at_cursor()
			if dir then
				self:set_item_fold(dir, true)
			end
		end, "Expand directory")
		map("za", function()
			local dir = self:get_dir_at_cursor()
			if dir then
				self:toggle_item_fold(dir)
			end
		end, "Toggle directory")
		map("zR", function()
			self:set_all_folds(true)
		end, "Expand all directories")
		map("zM", function()
			self:set_all_folds(false)
		end, "Collapse all directories")
		map("i", function()
			self:toggle_listing_style()
		end, "Toggle between 'list' and 'tree' views")
		map("<tab>", function()
			self.view:next_item()
		end, "Open the diff for the next file")
		map("<s-tab>", function()
			self.view:prev_item()
		end, "Open the diff for the previous file")
		map("<leader>e", function()
			self.view.panel:focus()
		end, "Bring focus to the commit log")
	end

	return CommitFilesPanel
end

---@param view FileHistoryView
local function refresh(view)
	local panel = panels[view]
	if not panel then
		return
	end
	if view.panel.single_file then
		panel:close()
		return
	end
	local entry, file = unpack(view.panel.cur_item)
	if not entry then
		return
	end
	view.panel:set_entry_fold(entry, false)
	panel:ensure_open()
	panel:show(entry, file)
end

---@param view View
function M.attach(view)
	local FileHistoryView = require("diffview.scene.views.file_history.file_history_view").FileHistoryView
	if not view:instanceof(FileHistoryView) or panels[view] then
		return
	end
	local panel = panel_class()(view)
	panels[view] = panel
	view.emitter:on("file_open_post", function()
		vim.schedule(function()
			if panels[view] == panel then
				refresh(view)
			end
		end)
	end)
end

---@param view View
function M.detach(view)
	local panel = panels[view]
	if panel then
		panels[view] = nil
		panel:destroy()
	end
end

function M.select_commit()
	local view = require("diffview.lib").get_current_view()
	if not (view and view.panel and view.panel:is_focused()) then
		return
	end
	local item = view.panel:get_item_at_cursor()
	if not item then
		return
	end
	local file = item
	if item.files then
		file = item.files[1]
	end
	if file then
		view:set_file(file, false)
	end
end

return M
