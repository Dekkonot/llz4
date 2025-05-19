-- Turn an arbitrary file into a Lua file that returns a table with a string
-- holding the contents of said file, so that it can be loaded by Luau.
-- usage: lua requireify.lua <file>

local filename = assert(arg[1], "missing filename")

local file = assert(io.open(filename, "rb"))
local data = file:read("*a")
file:close()

file = assert(io.open("luau-data.luau", "wb"))
file:write(string.format([[
return {%q}
]], data))
file:close()
