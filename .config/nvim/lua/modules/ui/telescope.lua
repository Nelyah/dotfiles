local M = {}

local function find_command()
	if vim.fn.executable("rg") == 1 then
		return { "rg", "--files", "--color", "never", "-g", "!.git" }
	elseif vim.fn.executable("fd") == 1 then
		return { "fd", "--type", "f", "--color", "never", "-E", ".git" }
	elseif vim.fn.executable("fdfind") == 1 then
		return { "fdfind", "--type", "f", "--color", "never", "-E", ".git" }
	elseif vim.fn.executable("find") == 1 then
		return { "find", ".", "-type", "f" }
	elseif vim.fn.executable("where") == 1 then
		return { "where", "/r", ".", "*" }
	end
end

M.setup = function()
	local layout_small_bottom = {
		layout_strategy = "vertical",
		layout_config = {
			vertical = { width = 0.8, height = 0.3 },
			anchor = "S",
		},
	}
	require("telescope").setup({
		defaults = {
			-- Default configuration for telescope goes here:
			-- config_key = value,
			mappings = {
				i = {
					["<C-h>"] = "which_key",
					["<C-k>"] = "move_selection_previous",
					["<C-j>"] = "move_selection_next",
				},
			},
		},
		pickers = {
			commands = layout_small_bottom,
			filetypes = layout_small_bottom,
			find_files = {
				find_command = find_command,
				hidden = true,
			},
		},
		extensions = {
			fzf = {
				fuzzy = true, -- false will only do exact matching
				override_generic_sorter = true, -- override the generic sorter
				override_file_sorter = true, -- override the file sorter
				case_mode = "smart_case", -- or "ignore_case" or "respect_case"
				-- the default case_mode is "smart_case"
			},
		},
	})
    require('telescope').load_extension('fzf')
end

M.init = function()
	vim.keymap.set("n", "<leader>o", function()
		-- Telescope doesn't yet support selecting multiple files
		-- see https://github.com/nvim-telescope/telescope.nvim/issues/1048#issuecomment-1140280174
		local opts_ff = {
			attach_mappings = function(_, _)
				local actions = require("telescope.actions")
				actions.select_default:replace(function(prompt_bufnr)
					local state = require("telescope.actions.state")
					local picker = state.get_current_picker(prompt_bufnr)
					local multi = picker:get_multi_selection()
					local single = picker:get_selection()
					local str = ""
					if #multi > 0 then
						for _, j in pairs(multi) do
							str = str .. "edit " .. j[1] .. " | "
						end
					end
					str = str .. "edit " .. single[1]
					-- To avoid populating qf or doing ":edit! file", close the prompt first
					actions.close(prompt_bufnr)
					vim.api.nvim_command(str)
				end)
				return true
			end,
		}
		return require("telescope.builtin").find_files(opts_ff)
	end)
	vim.keymap.set("n", "<leader>i", function()
		require("telescope").extensions.live_grep_args.live_grep_args()
	end)
	vim.keymap.set("n", "<leader>x", function()
		require("telescope.builtin").commands()
	end)
	vim.keymap.set("n", "<leader>s", function()
		require("telescope.builtin").current_buffer_fuzzy_find()
	end)
	vim.keymap.set("n", "<c-x>h", function()
		require("telescope.builtin").help_tags()
	end)
	vim.keymap.set("n", ",", function()
		require("telescope.builtin").buffers()
	end)

	vim.api.nvim_create_user_command("FT", function()
		require("telescope.builtin").filetypes()
	end, {})
end

return M
