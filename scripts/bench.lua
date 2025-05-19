local base64 = require("base64")

local llz4 = require("llz4")
local lz4 = require("lz4")
local llzw = require("llzw")

local data do
	local file = assert(io.open(assert(arg[1], "missing file name"), "r"))
	data = file:read("*a")
	file:close()
end

local function bench(which, compress, decompress, data)
	collectgarbage()
	collectgarbage()

	local compressStart = os.clock()
	local compressed, a, b, c, d = compress(data)
	local compressEnd = os.clock()

	collectgarbage()
	collectgarbage()

	local decompressStart = os.clock()
	local decompressed = decompress(compressed, a, b, c, d)
	local decompressEnd = os.clock()

	assert(decompressed == data, "decompressed doesn't match original")

	print(string.format(
		"%s:\n  Compress: %.2f s\n  Decompress: %.2f s\n  Ratio: %.2f (%d KiB -> %d KiB)",
		which,
		compressEnd - compressStart,
		decompressEnd - decompressStart,
		#data / #compressed, math.floor(#data / 1024), math.floor(#compressed / 1024)
	))
end

local string_byte = string.byte
local function justIter(s)
	for i = 1, #s do
		local c = string_byte(s, i)
	end
	return s
end

local function compose2(f, g)
	return function(...)
		return f(g(...))
	end
end

bench("iter", justIter, justIter, data)
bench("llz4", llz4.compress, llz4.decompress, data)
bench("llz4 + base64", compose2(base64.encode, llz4.compress), compose2(llz4.decompress, base64.decode), data)
bench("lz4" , lz4.compress, lz4.decompress, data)
bench("lz4 + base64" , compose2(base64.encode, lz4.compress), compose2(lz4.decompress, base64.decode), data)
bench("llzw", llzw.compress, llzw.decompress, data)
