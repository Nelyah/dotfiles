local M = {}

local function lualine_file_location()
    local location_buf = vim.api.nvim_win_get_cursor(0)
    return table.concat({
        location_buf[1] .. "/" .. vim.api.nvim_buf_line_count(0) .. " " .. location_buf[2] + 1,
    }, " ")
end

local function lualine_file_readonly()
    -- if buffer is a terminal
    if vim.bo.buftype == "terminal" then
        return "%#InfoMsg#" .. "[TERMINAL]"
    end

    if vim.fn.filereadable(vim.fn.expand("%")) == 0 and #vim.fn.expand("%") > 0 then
        return "%#ErrorMsg#" .. "[NOT READABLE]"
    elseif vim.bo.readonly then
        return "%#WarningMsg#" .. "[READ ONLY]"
    else
        return ""
    end
end

function M.setup()

    -- stylua: ignore
    local colors = {
        blue             = '#80a0ff',
        cyan             = '#79dac8',
        black            = '#080808',
        white            = '#c6c6c6',
        red              = '#ff5189',
        violet           = '#d183e8',
        grey             = '#3D4451',
        pink             = '#ED9DDB',
        teal             = '#7389AE',
        navy             = '#345283',
        yellow           = '#E8DB7D',
        defaul_bg        = '#282c34',
        bright_bg        = '#474E5C',
        darker_bright_bg = '#2C313A'
    }

    local bubbles_theme = {
        normal = {
            a = { fg = colors.black, bg = colors.pink },
            b = { fg = colors.white, bg = colors.grey },
            c = { fg = colors.white, bg = colors.darker_bright_bg },
        },

        insert = { a = { fg = colors.black, bg = colors.teal } },
        visual = { a = { fg = colors.black, bg = colors.yellow } },
        replace = { a = { fg = colors.black, bg = colors.red } },

        inactive = {
            a = { fg = colors.white, bg = colors.bright_bg },
            b = { fg = colors.white, bg = colors.bright_bg },
            c = { fg = colors.black, bg = colors.bright_bg },
        },
    }

    require("lualine").setup({
        options = {
            theme = bubbles_theme,
            component_separators = "|",
            section_separators = { left = "", right = "" },
        },
        sections = {
            lualine_a = {
                { "mode", separator = { left = "", right = "" }, right_padding = 3, left_padding = 3 },
            },
            lualine_b = {
                {
                    "branch",
                    separator = { left = "", right = "" },
                },
                {
                    "diff",
                    color_added = "#77b300",
                    color_modified = "#e67300",
                    color_removed = "#ff1a1a",
                    separator = { left = "", right = "" },
                },
            },
            lualine_c = {
                {
                    "filename",
                    file_status = false,
                    left_padding = 2,
                    right_padding = 2,
                    separator = {  right = "" },
                },
                lualine_file_readonly,
            },
            lualine_x = {
                "diagnostics",
                "searchcount",
                "encoding",
                {
                    "filetype",
                    separator = { left = "" },
                },
            },
            lualine_y = {
                {
                    "progress",
                    separator = { left = "" },
                },
            },
            lualine_z = {
                {
                    right_padding = 2,
                    lualine_file_location,
                    separator = { left = "", right = "" },
                },
            },
        },
        inactive_sections = {
            lualine_a = { "filename" },
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = { "location" },
        },
        tabline = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {
                {
                    "buffers",
                    buffers_color = {
                        active = { fg = colors.pink, bg = "#383c44" }, -- color for active buffer
                        inactive = { fg = colors.white }, -- color for inactive buffer
                    },
                    separator = "",
                },
            },
            lualine_x = { require("tabline").tabline_tabs },
            lualine_y = {},
            lualine_z = {},
        },
        extensions = {},
    })
end

return M
