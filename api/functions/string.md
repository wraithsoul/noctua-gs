# string
Description:
Standard library for generic string manipulation, such as finding and extracting substrings or pattern matching.

## Functions

### `byte`
`string.byte(string: string, start: number, end: number): number`
Returns the given string's characters in their numeric ASCII representation.

### `char`
`string.char(...): string`
Creates a string from one or more numeric ASCII codes.

### `find`
`string.find(str: string, pattern: string, start: number, no_patterns: boolean): number, number`
Looks for the first match of the `pattern` in the string `str`. If it finds a match, then it returns the indices of `str` where the occurrence starts and ends; otherwise, it returns **nil**.

Passing **true** as the fourth argument turns off pattern matching facilities, so the function does a plain “find substring” operation, with no characters in the pattern being considered “magic”. Note that if `no_patterns` is given, then `start` must be given as well.

### `format`
`string.format(format: string, ...)`
Returns a formatted version of its variable number of arguments following the description given in its first argument (which must be a string).

---
**Format string options**

Available numeric format specifiers:

*   `%d` - Decimal integer, rounded down.
*   `%o` - Octal integer, rounded down.
*   `%x` - Hexadecimal integer, rounded down. Use `%X` for uppercase.
*   `%f` - Floating-point number, rounded based on the specified precision.
*   `%e` - Scientific notation (mantissa/exponent). Use `%E` for uppercase.
*   `%g` - Shortest float representation, either `%f` or `%e`. Use `%G` for uppercase.
*   `%a` - Hexadecimal float. Use `%A` for uppercase.

Numeric specifiers can be combined with one or more of the following sub-specifiers:

*   **Padding**: Use `%5d` to pad a number to at least 5 characters. By default, it will be padded with spaces, use `%05d` to use zeroes instead. Use `%-5d` to left-justify instead of right-justify the output.
*   **Sign**: Use `%+d` to preceed positive numbers with a plus sign or `% d` to preceed them with a space.
*   **#**: When used with `%o`, `%x` or `%X` it prefixes the output with `0`, `0x` or `0X` respectively for values different than zero. Used with `e`, `E`, `f`, `F`, `g` or `G` it forces the written output to contain a decimal point even if no more digits follow.
*   **Precision**: Number of digits to be printed after the decimal point, for example `%011.5f` to print 5 digits after the decimal point and pad the output to at least 11 characters (including the decimal point).

Other format specifiers:

*   `%c` - Single character as ascii code.
*   `%s` - String
*   `%q` - String between double quotes, with all special characters escaped
*   `%%` - A single `%` character.

String specifiers can also be combined with the width and right-justify sub-specifiers. Use `%16s` to make sure the output string is at least 16 characters long.

---

### `gmatch`
`string.gmatch(str: string, pattern: string): function`
Using lua patterns, returns an iterator which will return either one value if no capture groups are defined, or any capture group matches.

### `gsub`
`string.gsub(str: string, pattern: string, replacement: string, max: number): string, number`
Using lua patterns, returns a copy of `str` with all matches of the `pattern` replaced by the given `replacement` string.

The replacement may be a **string**, a **table** or a **function**.

*   If it is a **string**, then it can contain captures.
*   If it is a **table**, the match is looked up in the table as a key, and the value (string) is used to replace it, if it exists.
*   If it is a **function**, then the function is called for each match, with the value of the match as the first argument, the value of the $n$ argument as the second argument, and the position of the match as the third argument. The function must then return the replacement string to be used for the match.

### `len`
`string.len(str: string): number`
Returns the length of the string `str` in bytes.

### `lower`
`string.lower(str: string): string`
Returns a copy of `str` with all uppercase letters replaced by their lowercase counterparts.

### `match`
`string.match(str: string, pattern: string, start): table`
Using lua patterns, returns the first match of the `pattern` in the string `str`. If no match is found, it returns **nil**.

### `rep`
`string.rep(str: string, n: number, sep: string): string`
Repeats the string `n` times and concatenates them using the separator `sep`.

### `reverse`
`string.reverse(str: string): string`
Reverses the string `str`.

### `sub`
`string.sub(str: string, s: number, e: number): string`
Returns a substring of `str` starting at `s` and ending at `e`. Use negative numbers to start from the end of the string.

### `upper`
`string.upper(str: string): string`
Returns a copy of `str` with all lowercase letters replaced by their uppercase counterparts.