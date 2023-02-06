local M = {}

local path_sep = vim.loop.os_uname().sysname == "Windows" and "\\" or "/"

function M.path_join(...)
    return table.concat(vim.tbl_flatten({ ... }), path_sep)
end

local function mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

local function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function M.get_package()
    local x = vim.fn.fnamemodify(vim.fn.expand("%"), ":p:h")
    local pathTable = mysplit(x, "/")

    local cutof = indexOf(pathTable, "kotlin")
    local size1 = 0
    for _ in pairs(pathTable) do
        size1 = size1 + 1
    end
    for i = cutof, 1, -1 do
        table.remove(pathTable, 1)
    end

    return table.concat(pathTable, ".")
end
return M
