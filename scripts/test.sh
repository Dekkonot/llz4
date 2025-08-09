#!/bin/bash
# Very basic tests using lz4's datagen utility. Because Luau is extremely
# limited in what it can do, we pass it test case input using command-line
# arguments. This has a couple of issues --- arguments cannot contain null bytes
# and they have size limits --- but it should be good enough for now. Ideally,
# we would fuzz the library somehow, but that's a project for another time.

set -e

seed="$(date +%s)"
temp_lib_file="llz4-test.lua"


if [ "$1" = "--help" ]; then
	echo "usage: scripts/test.sh"
	exit 0
elif ! [ -x datagen ]; then
	echo >&2 "error: missing or non-executable ./datagen"
	exit 1
fi


# <length> <runner> <test file>
function run_test_with_size {
	for (( compr = 0; compr <= 100; compr += 20 )); do
		if [ "$compr" != 100 ]; then
			data="$(./datagen "-s$seed" "-g$1" "-P$compr" 2> /dev/null)"
		else
			data="$(printf 'a%.0s' $(eval "echo {1..$1}"))"
		fi

		if [ "$2" = "luau" ]; then
			"$2" "$3" -a "$data"
		else
			"$2" "$3" "$data"
		fi
	done
}

# run_tests <runner> <test file> <library file>
function run_tests {
	echo "Testing $3 using $1 with $2"
	ln -sf "$3" "$temp_lib_file"

	for (( len = 0; len <= 1000; len++ )); do
		run_test_with_size "$len" "$1" "$2"
	done

	run_test_with_size 65536 "$1" "$2"
}

function cleanup {
	rm -f "$temp_lib_file"
}
trap cleanup EXIT SIGINT


run_tests lua scripts/test.lua llz4.lua
run_tests luau scripts/test.lua llz4.luau

echo "ALL OK"
