package = "llz4"
version = "0.1.0-1"
source = {
	url = "git://github.com/RiskoZoSlovenska/llz4",
	tag = "v0.1.0",
}
description = {
	summary = "Pure-Lua LZ4 Block De/Compression",
	detailed = "llz4 is a small, simple pure-Lua library for compressing/decompressing data using the LZ4 block format.",
	homepage = "https://github.com/RiskoZoSlovenska/llz4",
	license = "MIT",
}
dependencies = {
	"lua >= 5.1",
}
build = {
	type = "builtin",
	modules = {
		llz4 = "llz4.lua",
	},
}
