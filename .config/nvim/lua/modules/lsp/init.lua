local plugin = require("core.packer").register_plugin

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
        require("mason-lspconfig").setup()
        require("modules.lsp.nvim-lsp").mason_lspconfig()
    end,
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
    },
})

-- Plugin showing the LSP loading status at the bottom right
plugin({ "j-hui/fidget.nvim", opts = {} })

plugin({
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
        local null_ls = require("null-ls")

        null_ls.setup({
            sources = require("modules.lsp.null-ls").sources,
        })
    end,
})
