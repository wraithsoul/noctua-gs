# json
Description:
A JSON parser and serializer library. Slightly modified version of Lua CJSON.

Useful tools: [JSON Formatter / Validator](https://jsonlint.com/) - [JSON Tree Viewer](http://jsonviewer.stack.hu/)

## Functions

### `decode_invalid_numbers`
`json.decode_invalid_numbers(setting: boolean): boolean`
`json.parse` may generate an error when trying to decode numbers not supported by the JSON specification. Invalid numbers are defined as: **infinity**, **not-a-number (NaN)** and **hexadecimal**.

Available settings:
*   `true` - Accept and decode invalid numbers. This is the default setting.
*   `false` - Throw an error when invalid numbers are encountered.

The current setting is always returned, and is only updated when an argument is provided.

### `decode_max_depth`
`json.decode_max_depth(depth: number): number`
`json.parse` will generate an error when parsing deeply nested JSON once the maximum array/object depth has been exceeded. This check prevents unnecessarily complicated JSON from slowing down the application, or crashing the application due to lack of process stack space.

An error may be generated before the depth limit is hit if Lua is unable to allocate more objects on the Lua stack. By default, `json.parse` will reject JSON with arrays and/or objects nested more than **1000** levels deep.

The current setting is always returned, and is only updated when an argument is provided.

### `encode_invalid_numbers`
`json.encode_invalid_numbers(setting): boolean`
`json.stringify` may generate an error when encoding floating point numbers not supported by the JSON specification such as **Infinity** and **NaN**. This behavior can be changed by calling this function.

Available settings:
*   `true` - Allow invalid numbers to be encoded. This will generate non-standard JSON, but this output is supported by some libraries.
*   `false` - Throw an error when attempting to encode invalid numbers. This is the default setting.
*   `"null"` - Encode invalid numbers as a JSON **null** value. This allows infinity and NaN to be encoded into valid JSON.

The current setting is always returned, and is only updated when an argument is provided.

### `encode_max_depth`
`json.encode_max_depth(depth: number): number`
`json.stringify` will generate an error when encoding deeply nested JSON once the maximum table depth has been exceeded. This check prevents unnecessarily complicated JSON from slowing down the application, or crashing the application due to lack of process stack space.

By default, `json.stringify` will reject JSON with more than **1000** nested tables.

The current setting is always returned, and is only updated when an argument is provided.

### `encode_number_precision`
`json.encode_number_precision(precision: number): number`
The amount of significant digits returned by `json.stringify` when encoding numbers can be changed to balance accuracy versus performance. For data structures containing many numbers, setting `json.encode_number_precision` to a smaller integer, for example **3**, can improve encoding performance by up to 50%. By default, Lua CJSON will output **14** significant digits when converting a number to text.

The current setting is always returned, and is only updated when an argument is provided.

### `encode_sparse_array`
`json.encode_sparse_array()`
`json.stringify` classifies a Lua table into one of three kinds when encoding a JSON array. This is determined by the number of values missing from the Lua array as follows:

*   **Normal**: All values are available.
*   **Sparse**: At least 1 value is missing.
*   **Excessively sparse**: The number of values missing exceeds the configured ratio.

It encodes sparse Lua arrays as JSON arrays using JSON **null** for the missing entries. An array is excessively sparse when all the following conditions are met: `ratio > 0`, `maximum_index > safe`, `maximum_index > item_count * ratio`

JSON will never consider an array to be excessively sparse when `ratio = 0`. The `safe` limit ensures that small Lua arrays are always encoded as sparse arrays. By default, attempting to encode an excessively sparse array will generate an error. If `convert` is set to **true**, excessively sparse arrays will be converted to a JSON object.

The current settings are always returned. A particular setting is only changed when the argument is provided (non-nil).

### `parse`
`json.parse(json_text: string):`
Parses a **UTF-8** JSON string into a Lua object (table, number, string, etc).

**UTF-16** and **UTF-32** JSON strings are not supported. All escape codes will be decoded and other bytes will be passed transparently. JSON **null** will be converted to a `NULL` lightuserdata value. This can be compared with `json.null` for convenience.

By default, numbers incompatible with the JSON specification (infinity, NaN, hexadecimal) can be parsed. This default can be changed with `json.decode_invalid_numbers`.

### `stringify`
`json.stringify(object): string`
Serializes a Lua object into a JSON string.

It supports the following types: `boolean`, `nil`, `number`, `string`, `table`

The remaining Lua types will generate an error: `function`, `lightuserdata`, `thread`, `userdata`

By default, numbers are encoded with **14** significant digits. Refer to `json.encode_number_precision` for details.

!!!warning
This function will successfully encode/decode binary strings, but this is technically not supported by JSON and may not be compatible with other JSON libraries. To ensure the output is valid JSON, applications should ensure all Lua strings passed to `json.stringify` are UTF-8. Base64 is commonly used to encode binary data as the most efficient encoding under UTF-8 can only reduce the encoded size by a further ~8%.
!!!