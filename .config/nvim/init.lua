vim.loader.enable()

require("core")

local pack = require("core.packer")

require("modules").load({
	"lsp",
	"completion",
	"tools",
	"treesitter",
	"ui",
	"work",
})

pack:load_plugins()
