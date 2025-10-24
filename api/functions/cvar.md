# cvar
Description:
A table letting you get and set the value of cvars and invoke the callbacks of concommands.

```lua
-- localize the cvar object
local cl_fullupdate = cvar.cl_fullupdate

-- invoke a callback to the command as if you entered the command in the console
cl_fullupdate:invoke_callback()

--localize the cvar object
local cl_downloadfilter = cvar.cl_downloadfilter

-- print the current value of the cvar
client.log(cl_downloadfilter:get_string())

-- set the cvars value
cl_downloadfilter:set_string("none")

-- print it again
client.log(cl_downloadfilter:get_string()) -- "none"
```

## Info
The documentation for the `cvar` type is unfinished as it relies on types that aren't in the docs yet.

## Functions

### `__index`
`cvar.__index(name: string): cvar`
Finds a cvar by name and returns a `cvar` object for it, or **nil** if it doesn't exist or is blocked for security reasons.