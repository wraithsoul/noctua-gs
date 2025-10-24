# Global Functions
Description:
Global Lua standard library functions and miscellaneous extensions to them.

## Functions

### `assert`
`assert(expression, message: string)`
If the the first argument is **false** or **nil**, an error is thrown with the second argument as the message. Otherwise all the arguments are returned.

### `collectgarbage`
`collectgarbage(opt: string, arg)`
This function is a generic interface to the garbage collector. It performs different functions according to its first argument, `opt`:

*   **"collect"**: performs a full garbage-collection cycle. This is the default option.
*   **"stop"**: stops the garbage collector.
*   **"restart"**: restarts the garbage collector.
*   **"count"**: returns the total memory in use by Lua (in Kbytes).
*   **"step"**: performs a garbage-collection step. The step "size" is controlled by `arg` (larger values mean more steps) in a non-specified way. If you want to control the step size you must experimentally tune the value of `arg`. Returns `true` if the step finished a collection cycle.
*   **"setpause"**: sets `arg` as the new value for the pause of the collector (see §2.10). Returns the previous value for pause.
*   **"setstepmul"**: sets `arg` as the new value for the step multiplier of the collector (see §2.10). Returns the previous value for step.

*Modifying garbage collector settings is generally not recommended, unless you know what you are doing.*

### `defer`
`defer(callback)`
Registers a function to be called at lua shutdown/reload, equivalent to `client.set_event_callback("shutdown", callback)`.

### `error`
`error(message: string, level: number)`
Terminates the last protected function called and outputs `message` as an error message. If the function containing the error is not called in a protected function (`pcall`), then the script which called the function will terminate. The `error` function itself never returns and acts like a script error. The `level` argument specifies how to get the error position.
*   With `level 1` (the default), the error position is where the `error` function was called.
*   `Level 2` points the error to where the function that called `error` was called; and so on.
*   Passing a `level 0` avoids the addition of error position information to the message.

### `getfenv`
`getfenv(stack): table`
Returns the environment of the function or stack level passed to it.

### `getmetatable`
`getmetatable(tbl: table): table`
Returns the metatable of the given table if it has one, otherwise returns **nil**. If `t` does have a metatable, and the `__metatable` metamethod is set, it returns that value instead.

### `ipairs`
`ipairs(tbl: table): function, table, number`
Returns three values: an iterator function, the table `tbl` and the number `0`. Each time the iterator function is called, it returns the next numerical index-value pair in the table.

When used in a generic `for-in-loop`, the return values can be used to iterate over each numerical index in the table.

### `load`
`load(chunk: string, chunkname: string, mode: string, env: table): function, string`
Loads a chunk of Lua source code from a string or a "reader" function.

If there are no syntactic errors, returns the compiled chunk as a function; otherwise, returns **nil** plus the error message.

If `chunk` is a function, `load` calls it repeatedly to get the chunk pieces. Each call to `chunk` must return a string that concatenates with previous results. A return of an empty string, **nil**, or no value signals the end of the chunk.

### `next`
`next(t: table, key: any): , value`
Returns the first key/value pair in the `t` table. If a `key` argument was specified then returns the next element in the table based on the key provided.

If the table is empty or the specified key was the last key in the array, it returns **nil**. This means that you can use `next(t)` to check whether a table is empty.

The order in which the indices are enumerated is **not specified**, even for numeric indices. To traverse an array-like table in order, use a numerical `for` loop or `ipairs`.

### `pairs`
`pairs(tbl: table): function, table, number`
Returns three values: an iterator function, the table `tbl` and **nil**. Each time the iterator function is called, it returns the next key-value pair in the table.

When used in a generic `for-in-loop`, the return values can be used to iterate over all key-value pairs in the table. The iteration order is not specified and tables do not keep their insertion order.

### `pcall`
`pcall(func, ...): boolean,`
Calls the function `func` in "protected mode". This means that any error inside `func` is not propagated; instead, `pcall` catches the error and returns back to the caller. If the first return value is **true**, the function call succeeded with no errors and the other return values will be the return values from the function. If the first return value is **false**, the second one will be the error message.

### `print`
`print(...)`
Logs a message to the console. Equivalent to `client.log`.

### `printf`
`printf(fmt: string, ...)`
Logs a formatted message to the console. It accepts the same parameters as `string.format`.

### `rawequal`
`rawequal(v1: any, v2: any): boolean`
Checks whether `v1` is equal to `v2`, **without invoking any metamethod**.

### `rawget`
`rawget(tbl: table, key):`
Gets the raw value of a table field, **without invoking any `__index` metamethod**.

### `rawlen`
`rawlen(tbl: table): number`
Gets the raw length of a table, **without invoking the `__len` metamethod**.

### `rawset`
`rawset(tbl: table, key, value)`
Sets the raw value of a table field, **without invoking any `__newindex` metamethod**.

### `readfile`
`readfile(filename: string): string`
Returns the contents of the file, or **nil** if the file doesn't exist.

### `require`
`require(modname: string):`
Loads a Lua module. The `package.path` is searched for the module, and the first file found is loaded. If the module returns a value, that value is returned by `require`, otherwise **true** is returned. Workshop libraries can be loaded using `require "gamesense/<id>"`, if you are subscribed to them.

### `select`
`select(index: number, ...)`
Returns all the arguments passed to it after the index. Alternatively, if the string **"#"** is passed as the first argument, it returns the total number of arguments passed to it (including **nils**).

### `setfenv`
`setfenv(stack, env: table): function`
Sets the environment of the given function to the given table.

### `setmetatable`
`setmetatable(tbl: table, metatable: table)`
Sets the metatable of the given table `tbl` to `metatable`. If `metatable` is **nil**, the metatable of `t` is removed. Finally, this function returns the table `tbl` which was passed to it. If `tbl` already has a metatable whose `__metatable` metamethod is set, calling this on `tbl` raises an error.

### `tonumber`
`tonumber(value, base: number)`
Tries to convert its argument to a number. If the argument is a number, a string or a number `cdata` object convertible to a number, then `tonumber` returns this number; otherwise, it returns **nil**.

### `tostring`
`tostring(value): string`
Receives an argument of any type and converts it to a string in a reasonable format. For complete control of how numbers are converted, use `string.format`. If the metatable of `value` has a `__tostring` metamethod, then it will be called with `value` as the only argument and will return the result.

### `toticks`
`toticks(time: number): number`
Converts time (seconds) to ticks.

### `totime`
`totime(ticks: number): number`
Converts ticks to time. Return value is in seconds.

### `type`
`type(value): string`
Returns the type of its only argument, coded as a string. The possible results of this function are **"nil"** (a string, not the value `nil`), **"number"**, **"string"**, **"boolean"**, **"table"**, **"function"**, **"thread"**, and **"userdata"**.

### `unpack`
`unpack(tbl: table, i: number, j: number):`
Returns the items with numeric keys from the given table `tbl`, from `i` to `j`.

### `vtable_bind`
`vtable_bind(module_name: string, interface_name: string, index: number, typestring: string, ...): function`
Utility for calling virtual functions on FFI objects. This variant works with **Interfaces** and doesn't require passing the `this-pointer` as the first argument every time.

### `vtable_thunk`
`vtable_thunk(index: number, typestring: string, ...): function`
Utility for calling virtual functions on FFI objects. This variant takes the `this-pointer` as the first argument and grabs the virtual function from it when called.

### `writefile`
`writefile(filename: string, text: string)`
Overwrites the file with the passed text. The file is created if it doesn't exist.

### `xpcall`
`xpcall(func, handler, ...): boolean,`
Calls the function `func` in "protected mode". This means that any error inside `func` is not propagated; instead, `xpcall` catches the error, calls the "error handler" function passed to it, then returns back to the caller. If the first return value is **true**, the function call succeeded with no errors and the other return values will be the return values from the function. If the first return value is **false**, the second one will be the error message.