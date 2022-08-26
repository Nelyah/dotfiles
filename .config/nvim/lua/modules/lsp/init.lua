local plugin = require("core.packer").register_plugin

plugin({
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
        local null_ls = require("null-ls")

        null_ls.setup({
            sources = require('modules.lsp.null-ls').sources,
        })
    end,
})
plugin({
    "neovim/nvim-lspconfig",
    config = function()
        require("modules.lsp.nvim-lsp").setup()
    end,
})
plugin({
    "williamboman/mason.nvim",
    config = function()
        require("mason").setup()
    end,
})
plugin({
    "williamboman/mason-lspconfig.nvim",
    config = function()
        require("mason-lspconfig").setup()
        require("modules.lsp.nvim-lsp").mason_lspconfig()
    end,
})
