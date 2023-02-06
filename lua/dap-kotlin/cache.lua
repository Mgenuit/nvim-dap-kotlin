local util = require("dap-kotlin.util")

local M = {}

M.settings = {
    logfile = util.path_join(vim.fn.stdpath("cache"), "kotlin-dap-cache.txt"),
}
M._cache = {}

-- Read cache file
function M.cache_read()
    local logfile = io.open(M.settings.logfile, "r")

    if logfile then
        local lines = logfile:lines()

        for line in lines do
            local chunks = line:gmatch("[^=]+")

            local tb = {}
            for hunk in chunks do
                table.insert(tb, hunk)
            end
            M._cache[tb[1]] = tb[2]
        end
        logfile:flush()
    else
        local newFile = assert(io.open(M.settings.logfile, "w"))
        newFile:close()
        M.cache_read()
    end
end

function M.cache_save()
    local logfile = assert(io.open(M.settings.logfile, "w"))
    for key, value in pairs(M._cache) do
        logfile:write(key .. "=" .. value, "\n")
    end
    logfile:flush()
end

function M.cache_add(filename)
    M._cache[vim.fn.getcwd()] = filename
    M.cache_save()
end

return M
