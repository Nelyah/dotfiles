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
        require("mason").setup({
            -- Add installed binaries at the end of the PATH
            -- This is important for binaries that are otherwise available locally
            -- and which versions would be preferred
            PATH = "append",
        })
        require("mason-lspconfig").setup()
        require("modules.lsp.nvim-lsp").mason_lspconfig()
    end,
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
    },
})

-- Plugin showing the LSP loading status at the bottom right
plugin({ "j-hui/fidget.nvim", opts = {} })
