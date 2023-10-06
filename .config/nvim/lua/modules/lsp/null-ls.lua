local M = {}

local null_ls = require("null-ls")

M.sources = {
    null_ls.builtins.formatting.shfmt,
    null_ls.builtins.formatting.golines,
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.diagnostics.mypy,
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.clang_format,
}

if vim.fn.executable("gersemi") then
    table.insert(M.sources, {
        method = null_ls.methods.FORMATTING,
        name = "cmake-gersemi-format",
        filetypes = { "cmake" },
        generator = {
            fn = function(params)
                local buf_nr = vim.api.nvim_get_current_buf()
                local lines = {}
                require("plenary.job")
                    :new({
                        command = "gersemi",
                        args = { vim.fn.expand("%") },
                        on_stdout = function(_, line)
                            table.insert(lines, line)
                        end,
                        on_exit = function(_, _)
                            vim.schedule(function()
                                vim.api.nvim_buf_set_lines(buf_nr, 0, -1, false, lines)
                            end)
                        end,
                    })
                    :start()
            end,
        },
    })
end

return M
