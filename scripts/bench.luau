local base64 = require("../Base64")

local llz4 = require("../llz4-luau")
local llzw = require("../llzw-luau")

local data = require("../luau-data")[1]


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

bench("iter", justIter, justIter, data)
bench("llz4", llz4.compress, llz4.decompress, data)
bench("llz4 + base64", function(str)
	local buf = buffer.fromstring(str)
	local out, outLen = llz4.compressBuffer(buf, 0, #str)
	local toSize = buffer.create(outLen)
	buffer.copy(toSize, 0, out, 0, outLen)
	return buffer.tostring(base64.encode(toSize))
end, function(str)
	local buf = base64.decode(buffer.fromstring(str))
	local out, outLen = llz4.decompressBuffer(buf, 0, buffer.len(buf))
	return buffer.readstring(out, 0, outLen)
end, data)
bench("llzw", llzw.compress, llzw.decompress, data)
