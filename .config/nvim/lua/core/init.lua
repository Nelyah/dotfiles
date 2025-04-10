require("core.options")
require("core.mappings")
require("core.autocmd")
require('core.conflict_markers_highlight')

local pack = require("core.packer")

-- Adding this as core since it's useful for many use cases
pack.register_plugin("nvim-lua/plenary.nvim")

pack:bootstrap()
