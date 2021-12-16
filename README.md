# ce - Common Environment for c++

- supports clang, gcc, and msvc
- supports x86 and WebAsm
- 0 dependancies
- header only core ce.h
- non-allocating
- good code generation in non-optimized builds

## Features
### ce.h
#### basic types compatible with `std`
- `uint_t`, `sizE_t`, `ptrdiff_t`
- `uint8_t`, `uint16_t`, `uint32_t`, `uint64_t`
- `int8_t`, `int16_t`, `int32_t`, `int64_t` 
#### critical type traits and templates
-  `types<Ts...>` - list of types
- `items<T, T...Ns>` - list of scalar values
- `sequence_t<T, N>` - the type `items<T, T{ 0 }, T{ 1 }, ..., T{ N - 1 }>` using log N compile time recursion
#### fixed size contaners and span
- `tuple<Ts...>` - basic tuple support, `box<T>`, `pair<T, U>`
- `span<T>` - contiguous range of `T*`
- `bulk<N, T>` - fixed sized container of [0, `N`) `T`'s
#### simd style vectors and math utlities
- `vec<N, T, Ks...>` - small simd style vectors `N` = [0, 4] with optional unit tags `Ks...`
- `sqrx()`, `dotx()`, and `crossx()` - operations on scalars and `vec`s which expand integer types by 2x bits
- `in_polygon_xy()` and `in_polygon()` - generic point in polygon test (winding number) for types with `.x` & `.y` members
- `crc32` - fast header only type safe `constexpr` 32 bit cyclic redundancy check
- `fnv1a` - `constexpr` fnv hashing
- `xoroshiro64ss` - easy, good, compact random number generator http://prng.di.unimi.it/xoroshiro64starstar.c
- `base64` - `constexpr` base64 decode

### Macros
- `CE_STATIC_ASSERT()` - pre c++17 static_assert with optional and better error messges
- `CE_CPU_X86`, `CE_CPU_X86_32`, `CE_CPU_X86_64` - x86 compile time cpu detection
- `CE_CPU_WASM`, `CE_CPU_WASM_32`, `CE_CPU_WASM_64` - WebAssembly compile time cpu detection
- `CE_DEBUG_BREAK()` - break to debugger
- `CE_TIME_STAMP()` - high resolution time stamp counter
- `CE_MEMCPY()` - memcpy intrinsic
- `CE_MEMSET()` - memset intrinsic
- `CE_ROTL32()` - rotate left intrinsic
- `CE_STRLEN()` - strlen intrinsic
- `CE_ERROR()`, `CE_ASSERT()`, `CE_VERIFY()`, and `CE_FAILED()` - runtime error checking
- `CE_COUNTOF()` - compile time array extent
- `CE_FOLD_LEFT_COMMA()` - pre c++17 left comma fold expression
- `CE_LOG()` - structured logging
- `CE_LOG_MSG()` - typesafe logging

### cdt.h
- constrained delaunay triangulation with low memory footprint integer 
### dictionary.h
### io.h
### lziii.h
- `constexpr` lzss style compression
### math.h
- more math...
### pool.h
### sort.h
### zorder.h
- Morton Z ordering https://en.wikipedia.org/wiki/Z-order_curve
