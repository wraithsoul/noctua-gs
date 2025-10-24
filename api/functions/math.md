# math
Description:
Standard library for common mathematical functions.

## Functions

### `abs`
`math.abs(x: number): number`
Returns the absolute value of `x`, removing the negative sign if present.

### `acos`
`math.acos(x: number): number`
Returns the arccosine of the given number.

### `asin`
`math.asin(x: number): number`
Returns the arcsine of the given number.

### `atan`
`math.atan(x: number): number`
Returns the arc tangent of `x` (in radians).

### `atan2`
`math.atan2(y: number, x: number): number`
Returns the arc tangent of `y/x` (in radians), but uses the signs of both parameters to find the quadrant of the result. It also handles correctly the case of `x` being zero.

### `ceil`
`math.ceil(x: number): number`
Rounds the number up to the nearest integer.

### `cos`
`math.cos(x: number): number`
Returns the cosine of `x` (assumed to be in radians).

### `cosh`
`math.cosh(x: number): number`
Returns the hyperbolic cosine of `x`.

### `deg`
`math.deg(x: number): number`
Converts the angle `x` from radians to degrees.

### `exp`
`math.exp(x: number): number`
Returns the value of $e^x$.

### `floor`
`math.floor(x: number): number`
Rounds the number down to the nearest integer.

### `fmod`
`math.fmod(x: number, y: number): number`
Returns the modulus of the specified values (remainder of `x / y`). While this is similar to the `%` operator, it will return a negative value if the first argument is negative, whereas the `%` operator will return a positive value even if the first operand is negative.

### `frexp`
`math.frexp(x: number): number, number`
Returns `m` and `e` such that $x = m \cdot 2^e$, $e$ is an integer and the absolute value of $m$ is in the range $(0.5, 1)$ (or zero when $x$ is zero). Used to split the number value into a normalized fraction and an exponent. Two values are returned: the first is a multiplier in the range $1/2$ (inclusive) to $1$ (exclusive) and the second is an integer exponent. The result is such that $x = m \cdot 2^e$.

### `ldexp`
`math.ldexp(x: number, e: number): number`
Returns $x \cdot 2^e$ (`e` should be an integer).

### `log`
`math.log(x: number, base: number): number`
Returns the logarithm of `x` using the given `base`, or the mathematical constant $e$ if no base is provided (natural logarithm).

### `log10`
`math.log10(x: number): number`
Returns the base-10 logarithm of `x`.

### `max`
`math.max(...): number`
Returns the largest of its arguments.

### `min`
`math.min(...): number`
Returns the smallest of its arguments.

### `modf`
`math.modf(base: number): number, number`
Returns the integral and fractional component of the modulo operation.

### `pow`
`math.pow(x: number, y: number): number`
Returns $x^y$. In particular, `math.pow(1.0, x)` and `math.pow(x, 0.0)` always return `1.0`, even when `x` is a zero or **NaN**. If both `x` and `y` are finite, `x` is negative, and `y` is not an integer then `math.pow(x, y)` is undefined.

### `rad`
`math.rad(x: number): number`
Converts the angle `x` from degrees to radians.

### `random`
`math.random(min: number, max: number): number`
Returns a random number between the values provided.
*   When called **without arguments**, returns a uniform pseudo-random real number in the range $[0, 1]$.
*   When called with an integer number `m`, `math.random` returns a uniform pseudo-random integer in the range $[1, m]$.
*   When called with two integer numbers `m` and `n`, `math.random` returns a uniform pseudo-random integer in the range $[m, n]$.

LuaJIT uses a Tausworthe PRNG with period $2^{223}$ to implement `math.random` and `math.randomseed`.

When called without arguments it generates 52 pseudo-random bits for every call. The result is uniformly distributed between 0.0 and 1.0. It's correctly scaled up and rounded for `math.random(n [,m])` to preserve uniformity.

**Important:** Neither this nor any other PRNG based on the simplistic `math.random` API is suitable for cryptographic use.

### `randomseed`
`math.randomseed(seed: number)`
Seeds the random number generator. The same seed will guarantee the same sequence of numbers each time with `math.random`. **Incorrect usage of this function will affect all loaded scripts.**

### `sin`
`math.sin(x: number): number`
Returns the sine of `x` (assumed to be in radians).

### `sinh`
`math.sinh(x: number): number`
Returns the hyperbolic sine of `x`.

### `sqrt`
`math.sqrt(x: number): number`
Returns the square root of `x`. (You can also use the expression `x^0.5` to compute this value.)

### `tan`
`math.tan(x: number): number`
Returns the tangent of `x` (assumed to be in radians).

### `tanh`
`math.tanh(x: number): number`
Returns the hyperbolic tangent of `x`.