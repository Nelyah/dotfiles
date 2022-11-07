require("core")

local pack = require("core.packer")

require("modules").load({
    "completion",
    "lsp",
    "tools",
    "treesitter",
    "ui",
    "work",
})

pack:load_plugins()
