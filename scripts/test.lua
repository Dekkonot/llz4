local llz4 = require("../llz4-test")
local str = (...)

for acceleration = 1, 10 do
	local compressed = llz4.compress(str, acceleration)
	local decompressed = llz4.decompress(compressed)
	assert(decompressed == str, "decompressed doesn't match original")
end
