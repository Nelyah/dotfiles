local M = {}

-- @param module Either a module (string) or an array of of modules
M.load = function(modules)
    if type(modules) == "string" then
        require("modules." .. modules)
        return
    end

    for _, module in ipairs(modules) do
        require("modules." .. module)
    end
end

return M
