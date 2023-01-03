local M = {}

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
            live_grep_args = {
                mappings = {
                    i = { ["<c-f>"] = require("telescope.actions").to_fuzzy_refine }
                },
            },
        },
    })

    local telescope_builtin = require("telescope.builtin")
    local telescope_extensions = require("telescope").extensions
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
        return telescope_builtin.find_files(opts_ff)
    end)
    vim.keymap.set("n", "<leader>i", function()
        telescope_extensions.live_grep_args.live_grep_args()
    end)
    vim.keymap.set("n", "<leader>x", function()
        telescope_builtin.commands()
    end)
    vim.keymap.set("n", "<leader>s", function()
        telescope_builtin.current_buffer_fuzzy_find()
    end)
    vim.keymap.set("n", "<c-x>h", function()
        telescope_builtin.help_tags()
    end)
    vim.keymap.set("n", ",", function()
        telescope_builtin.buffers()
    end)

    vim.api.nvim_create_user_command("FT", function()
        telescope_builtin.filetypes()
    end, {})
end

return M
