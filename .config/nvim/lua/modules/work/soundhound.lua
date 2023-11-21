local plugin = require("core.packer").register_plugin

local insertHeader = function()
    local fn = vim.fn
    local cur_filename = fn.expand("%:t")
    local cur_fileending = fn.expand("%:e")
    local start_lines = {
        '/* file "' .. cur_filename .. '" */',
        "/* Copyright " .. os.date("%Y") .. " SoundHound, Incorporated. All rights reserved. */",
        "",
    }
    local end_lines = {}
    if cur_fileending == "h" or cur_fileending == "ti" then
        local upper_filename = string.upper(cur_filename)
        local subs = { "%.", "_" }
        for i, pattern in pairs(subs) do
            subs[i] = string.gsub(upper_filename, pattern, "")
        end

        for _, out in pairs({
            "#ifndef " .. upper_filename,
            "#define " .. upper_filename,
            "",
        }) do
            table.insert(start_lines, out)
        end

        for _, out in pairs({
            "",
            "#endif /* " .. upper_filename .. " */",
        }) do
            table.insert(end_lines, out)
        end
    end
    fn.append(0, start_lines)
    fn.append(fn.line("$"), end_lines)
end

local register_treesitter_parser = function()
    local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    parser_config.ter = {
        install_info = {
            url = "/home/nelyah/soundhound/tree-sitter-ter", -- local path or git repo
            files = { "src/parser.c", "src/scanner.cc" },
            -- optional entries:
            branch = "master", -- default branch in case of git repo if different from master
            generate_requires_npm = false, -- if stand-alone parser without npm dependencies
            requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
        },
        filetype = "ter", -- if filetype does not match the parser name
    }
    vim.treesitter.language.register("ter", "ter")
end

local setup = function()
    local has_treesitter, _ = pcall(require, 'nvim-treesitter')
    if not has_treesitter then
        return
    end
    register_treesitter_parser()

    plugin("/home/nelyah/soundhound/tree-sitter-ter-queries")
    plugin('git@git.soundhound.com:terrier/salmon-vim')

    vim.filetype.add({
        extension = { ter = "ter" },
    })
    vim.api.nvim_create_user_command("InsertHeader", insertHeader, {})
end

setup()
