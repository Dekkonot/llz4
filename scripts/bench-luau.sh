#!/bin/sh
set -e

if [ $# = 0 ]; then
	echo "usage: bench-luau.sh <file>"
	exit 1
fi

lua scripts/requireify.lua "$1"   # Convert input file into something that can be `require()`d
ln -sf llz4.luau llz4-luau.luau   # Luau require complains about having both llz4.lua and llz4.luau
luau scripts/bench.luau           # Run
rm llz4-luau.luau luau-data.luau  # Cleanup
