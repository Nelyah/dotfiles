local Pack = {}

local packer_plugin = require("packer")

local function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

function Pack:bootstrap()
    local packer_install_dir = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

    self.pack_bootstrapped = false
    if not file_exists(packer_install_dir .. "/lua/packer.lua") then
        self.pack_bootstrapped = vim.fn.system({
            "git",
            "clone",
            "--depth",
            "1",
            "https://github.com/wbthomason/packer.nvim",
            packer_install_dir,
        })
    end
end

function Pack:new()
    self.__index = self
    self.plugins = { "wbthomason/packer.nvim" }
    local new_instance = {}
    setmetatable(new_instance, self)

    return new_instance
end

function Pack:load_plugins()
    packer_plugin.startup(function(use)
        for _, plugin in ipairs(self.plugins) do
            use(plugin)
        end
    end)

    if Pack.pack_bootstrapped then
        packer_plugin.sync()
    end
end

-- @param opts Options for this plugin
-- @return nil
function Pack.register_plugin(opts)
    if type(opts) == "string" then
        table.insert(Pack.plugins, { opts })
        return
    end
    table.insert(Pack.plugins, opts)
end

local p = Pack:new()

return p
