local Pack = {}

function Pack:bootstrap()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable", -- latest stable release
            lazypath,
        })
    end
    vim.opt.rtp:prepend(lazypath)
end

function Pack:new()
    self.__index = self
    self.plugins = {}
    local new_instance = {}
    setmetatable(new_instance, self)

    return new_instance
end

function Pack:load_plugins()
    local has_lazy, lazy_plugin = pcall(require, "lazy")
    if not has_lazy then
        print("Restart nvim before installing plugins.")
        return
    end
    lazy_plugin.setup(self.plugins)
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

Pack:bootstrap()

return Pack:new()
