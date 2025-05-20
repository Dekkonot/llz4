# llz4 - Pure-Lua LZ4 Block De/Compression

`llz4` is a small, simple pure-Lua library for compressing/decompressing data using the [LZ4 block format](https://github.com/lz4/lz4/blob/836decd8a898475dcd21ed46768157f4420c9dd2/doc/lz4_Block_format.md). It was created primarily as an alternative to [`llzw`](https://github.com/RiskoZoSlovenska/llzw), though, unlike `llzw`, it doesn't do base64 encoding/decoding.

This repository contains both a standard Lua version (Lua 5.2+ or LuaJIT) and a [Luau](https://luau.org/) version, which are maintained in parallel.

`llz4` draws a great deal of inspiration from [Lz4.js](https://github.com/Benzinga/lz4js) and from [pierrec/lz4](https://github.com/pierrec/lz4).


## Usage

`llz4` can be installed from [LuaRocks](https://luarocks.org):
```
luarocks install llz4
```

Then:
```lua
local llz4 = require("llz4")

local compressed = llz4.compress(str, acceleration or 1) -- Should never fail
local ok, decompressed = pcall(llz4.decompress, compressed) -- Use pcall if passing untrusted input

assert(str == decompressed)
```

The Luau version also provides a `compressBuffer(data, dataStart, dataLen, acceleration)` and `decompressBuffer(data, dataStart, dataLen, decompressedLen)` functions which operate on [buffer objects](https://luau.org/library#buffer-library) directly.

Proper API documentation is a work in progress; see the source code doc comments for now.


## Performance

I've benchmarked `llz4` against [`llzw`](https://github.com/RiskoZoSlovenska/llzw) and [lua-lz4](https://github.com/witchu/lua-lz4) (the Lua binding to the C library). To get base64 encode/decode, I used [lbase64](https://github.com/iskolbin/lbase64) for Lua and [Base64](https://github.com/Reselim/Base64) for Luau. This is not a strictly rigorous benchmark, but it is probably sufficient to get a rough idea of how `llz4` performs. It was performed on an i7-11800H. Times are in seconds.

Note that `llz4` may produce slightly different compressed strings depending on the exact behaviour of the bit library being used. However, compression ratios should not vary significantly and all compressed strings should be capable of being decompressed by any LZ4 block decompressor.

`iter` simply iterates over the input string and extracts each character using `string.byte()`.

<!-- MARK: JSON -->
<details>
	<summary>Lua 5.2 - A 2.5 MiB minified JSON file with lots of repetition</summary>

|            | Compression Time | Decompression Time | Compression Ratio |
|------------|------------------|--------------------|-------------------|
| iter       |  0.07            |  0.07              |  1.00             |
| **llz4**   |  **0.36**        |  **0.19**          |  **3.83**         |
| llz4 + b64 |  0.43            |  0.28              |  2.87             |
| lz4        |  0.00            |  0.00              |  4.09             |
| lz4 + b64  |  0.08            |  0.08              |  3.06             |
| llzw       |  0.33            |  0.26              |  5.06             |
</details>

<details>
	<summary>Luau - A 2.5 MiB minified JSON file with lots of repetition</summary>

|            | Compression Time | Decompression Time | Compression Ratio |
|------------|------------------|--------------------|-------------------|
| iter       |  0.02            |  0.02              |  1.00             |
| **llz4**   |  **0.07**        |  **0.02**          |  **3.82**         |
| llz4 + b64 |  0.09            |  0.04              |  2.87             |
| llzw       |  0.18            |  0.13              |  5.06             |
</details>

<!-- MARK: canterbury -->
<details>
	<summary>Lua 5.2 - <a href="https://corpus.canterbury.ac.nz/descriptions/#cantrbry">cantrbry.tar</a></summary>

|            | Compression Time | Decompression Time | Compression Ratio |
|------------|------------------|--------------------|-------------------|
| iter       |  0.07            |  0.07              |  1.00             |
| **llz4**   |  **0.46**        |  **0.22**          |  **2.35**         |
| llz4 + b64 |  0.60            |  0.38              |  1.76             |
| lz4        |  0.00            |  0.00              |  2.29             |
| lz4 + b64  |  0.14            |  0.15              |  1.72             |
| llzw       |  0.47            |  0.36              |  2.16             |
</details>

<details>
	<summary>Luau - <a href="https://corpus.canterbury.ac.nz/descriptions/#cantrbry">cantrbry.tar</a></summary>

|            | Compression Time | Decompression Time | Compression Ratio |
|------------|------------------|--------------------|-------------------|
| iter       |  0.02            |  0.02              |  1.00             |
| **llz4**   |  **0.09**        |  **0.03**          |  **2.35**         |
| llz4 + b64 |  0.12            |  0.15              |  1.76             |
| llzw       |  0.26            |  0.18              |  2.16             |
</details>

<!-- MARK: large -->
<details>
	<summary>Lua 5.2 - <a href="https://corpus.canterbury.ac.nz/descriptions/#large">large.tar</a> (as retrieved on 2025-05-05)</summary>

|            | Compression Time | Decompression Time | Compression Ratio |
|------------|------------------|--------------------|-------------------|
| iter       |  0.29            |  0.29              |  1.00             |
| **llz4**   |  **1.93**        |  **0.99**          |  **1.77**         |
| llz4 + b64 |  2.72            |  1.89              |  1.32             |
| lz4        |  0.02            |  0.01              |  1.92             |
| lz4 + b64  |  0.75            |  0.81              |  1.44             |
| llzw       |  2.28            |  1.50              |  2.39             |
</details>

<details>
	<summary>Luau - <a href="https://corpus.canterbury.ac.nz/descriptions/#large">large.tar</a> (as retrieved on 2025-05-05)</summary>

|            | Compression Time | Decompression Time | Compression Ratio |
|------------|------------------|--------------------|-------------------|
| iter       |  0.07            |  0.07              |  1.00             |
| **llz4**   |  **0.37**        |  **0.20**          |  **1.77**         |
| llz4 + b64 |  0.57            |  0.38              |  1.32             |
| llzw       |  1.45            |  0.70              |  2.39             |
</details>

<!-- MARK: random -->
<details>
	<summary>Lua 5.2 - 10 MiB of <code>/dev/random</code></summary>

|            | Compression Time | Decompression Time | Compression Ratio |
|------------|------------------|--------------------|-------------------|
| iter       |  0.28            |  0.28              |  1.00             |
| **llz4**   |  **0.02**        |  **0.81**          |  **1.00**         |
| llz4 + b64 |  2.22            |  4.84              |  0.75             |
| lz4        |  0.34            |  0.00              |  1.00             |
| lz4 + b64  |  2.05            |  3.80              |  0.75             |
| llzw       |  6.05            |  3.35              |  0.60             |
</details>

<details>
	<summary>Luau - 10 MiB of <code>/dev/random</code></summary>

|            | Compression Time | Decompression Time | Compression Ratio |
|------------|------------------|--------------------|-------------------|
| iter       |  0.07            |  0.07              |  1.00             |
| **llz4**   |  **0.01**        |  **0.01**          |  **1.00**         |
| llz4 + b64 |  0.30            |  0.33              |  0.75             |
| llzw       |  3.48            |  1.60              |  0.60             |
</details>

<!-- MARK: enwik8 -->
<details>
	<summary>Lua 5.2 - <a href="https://mattmahoney.net/dc/textdata.html">enwik8</a></summary>

|            | Compression Time | Decompression Time | Compression Ratio |
|------------|------------------|--------------------|-------------------|
| iter       |  2.68            |  2.68              |  1.00             |
| **llz4**   |  **18.35**       |  **8.44**          |  **1.84**         |
| llz4 + b64 |  29.26           |  28.15             |  1.38             |
| lz4        |  0.53            |  0.13              |  1.75             |
| lz4 + b64  |  9.66            |  14.36             |  1.31             |
| llzw       |  30.54           |  17.29             |  2.18             |
</details>

<details>
	<summary>Luau - <a href="https://mattmahoney.net/dc/textdata.html">enwik8</a></summary>

|            | Compression Time | Decompression Time | Compression Ratio |
|------------|------------------|--------------------|-------------------|
| iter       |  0.63            |  0.63              |  1.00             |
| **llz4**   |  **3.26**        |  **1.49**          |  **1.84**         |
| llz4 + b64 |  4.76            |  3.15              |  1.38             |
| llzw       |  *N/A\**         |  *N/A\**           |  *N/A\**          |

\* table overflow
</details>
