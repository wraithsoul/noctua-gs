# globals
Description:
Global variables used by the source engine.

## Functions

### `absoluteframetime`
`globals.absoluteframetime(): number`
The absolute time the last frame took to render.

### `chokedcommands`
`globals.chokedcommands(): number`
The number of choked commands (commands that haven't yet been sent to the server, for example due to fake lag).

### `commandack`
`globals.commandack(): number`
The command number of the most recent server-acknowledged command.

### `curtime`
`globals.curtime(): number`
The elapsed game time in seconds. This number is synchronized with the server.

### `framecount`
`globals.framecount(): number`
The number of frames rendered since the game started.

### `frametime`
`globals.frametime(): number`
The time the last frame took to render.

### `lastoutgoingcommand`
`globals.lastoutgoingcommand(): number`
The command number of the most recent sent command.

### `mapname`
`globals.mapname(): string`
The name of the loaded map, or **nil** if you are not in game.

### `maxplayers`
`globals.maxplayers(): number`
The maximum number of players in a game (usually 64).

### `oldcommandack`
`globals.oldcommandack(): number`
The command number of the previous server-acknowledged command.

### `realtime`
`globals.realtime(): number`
The time in seconds since the game was started.

### `servertickcount`
`globals.servertickcount(): number`
Returns the most recently received tick from the server.

### `tickcount`
`globals.tickcount(): number`
The number of ticks elapsed on the server.

### `tickinterval`
`globals.tickinterval(): number`
The time between ticks in seconds, 1/64 for 64 tick.