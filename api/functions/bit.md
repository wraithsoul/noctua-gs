# bit
Description:
LuaJIT library for bitwise operations

## Functions

### `arshift`
`bit.arshift(x: number, n: number): number`
Returns the bitwise arithmetic right-shift of its first argument by the number of bits given by the second argument. Arithmetic right-shift treats the most-significant bit as a sign bit and replicates it. Only the lower 5 bits of the shift count are used (reduces to the range [0..31]).

### `band`
`bit.band(x1: number, ...): number`
Returns the bitwise and of all of its arguments. Note that more than two arguments are allowed.

### `bnot`
`bit.bnot(x: number): number`
Returns the bitwise not of its argument (all bits flipped).

### `bor`
`bit.bor(x1: number, ...): number`
Returns the bitwise or of all of its arguments. Note that more than two arguments are allowed.

### `bswap`
`bit.bswap(x: number): number`
Swaps the bytes of its argument and returns it. This can be used to convert little-endian 32 bit numbers to big-endian 32 bit numbers or vice versa.

### `bxor`
`bit.bxor(x1: number, ...): number`
Returns the bitwise xor of all of its arguments. Note that more than two arguments are allowed.

### `lshift`
`bit.lshift(x: number, n: number): number`
Returns the bitwise logical left-shift of its first argument by the number of bits given by the second argument. Logical shifts treat the first argument as an unsigned number and shift in 0-bits. Only the lower 5 bits of the shift count are used (reduces to the range [0..31]).

### `rol`
`bit.rol(x: number, n: number): number`
Returns the bitwise left rotation of its first argument by the number of bits given by the second argument. Bits shifted out on one side are shifted back in on the other side. Only the lower 5 bits of the rotate count are used (reduces to the range [0..31]).

### `ror`
`bit.ror(x: number, n: number): number`
Returns the bitwise right rotation of its first argument by the number of bits given by the second argument. Bits shifted out on one side are shifted back in on the other side. Only the lower 5 bits of the rotate count are used (reduces to the range [0..31]).

### `rshift`
`bit.rshift(x: number, n: number): number`
Returns the bitwise logical right-shift of its first argument by the number of bits given by the second argument. Logical shifts treat the first argument as an unsigned number and shift in 0-bits. Only the lower 5 bits of the shift count are used (reduces to the range [0..31]).

### `tobit`
`bit.tobit(x: number): number`
Normalizes a number to the numeric range for bit operations and returns it. This function is usually not needed since all bit operations already normalize all of their input arguments.

### `tohex`
`bit.tohex(x: number, n: number): string`
Converts its first argument to a hex string. The number of hex digits is given by the absolute value of the optional second argument. Positive numbers between 1 and 8 generate lowercase hex digits. Negative numbers generate uppercase hex digits. Only the least-significant 4*|n| bits are used. The default is to generate 8 lowercase hex digits.