# client
Description:
General game- and cheat-related functions

## Functions

### `camera_angles`
`client.camera_angles(pitch: number, yaw: number): number, number`
Get or set camera angles. Pass no arguments to get the current camera angles.

### `camera_position`
`client.camera_position(): number, number, number`
Returns **x, y, z** world coordinates of the game's camera position.

### `color_log`
`client.color_log(r: number, g: number, b: number, ...)`
Logs a colored message to console. End the string with `\0` to prevent it from adding a newline.

### `create_interface`
`client.create_interface(module_name: string, interface_name: string): userdata`
Returns a pointer to the interface, or **nil** on failure.

### `current_threat`
`client.current_threat(): number`
Returns the **entindex** of the 'current threat', i.e. the enemy that is currently being used for 'At targets' anti-aim.

### `delay_call`
`client.delay_call(delay: number, callback, ...)`
Executes the `callback` after `delay` seconds, passing the arguments to it.

### `draw_debug_text`
`client.draw_debug_text(x: number, y: number, z: number, line_offset: number, duration: number, r: number, g: number, b: number, a: number, ...)`
Draws a DebugOverlay text at the specified 3d position. **Avoid calling this during the paint event.**

### `draw_hitboxes`
`client.draw_hitboxes(entindex: number, duration: number, hitboxes: number, r: number, g: number, b: number, a: number, tick: number)`
Draws hitbox overlays. **Avoid calling this during the paint event.**

### `error_log`
`client.error_log(msg: string)`
Prints an error to the console and plays a sound.

### `exec`
`client.exec(...)`
Executes a console command. Multiple commands can be combined with `;`. Be careful when passing user input (including player names) to it.

### `eye_position`
`client.eye_position(): number, number, number`
Returns **x, y, z** world coordinates of the local player's eye position.

### `find_signature`
`client.find_signature(module_name: string, pattern: string): userdata`
Finds the specified pattern and returns a pointer to it, or **nil** if not found.

### `fire_event`
`client.fire_event(event_name: string, ...)`
Fires a custom event that other scripts can listen to using `client.set_event_callback`.

### `get_cvar`
`client.get_cvar(cvar_name: string): string`
Returns the value of a console variable.

### `get_model_name`
`client.get_model_name(model_index: number): string`
Returns model name, or **nil** on failure.

### `key_state`
`client.key_state(key: number): boolean`
Returns **true** if the key is pressed, or **nil** on failure.

### `latency`
`client.latency(): number`
Returns your latency in seconds.

### `log`
`client.log(...)`
Logs a message to the console.

### `random_float`
`client.random_float(minimum: number, maximum: number): number`
Returns a random float between `minimum` and `maximum`.

### `random_int`
`client.random_int(minimum: number, maximum: number): number`
Returns a random integer between `minimum` and `maximum`.

### `real_latency`
`client.real_latency(): number`
Returns your real latency, regardless of ping spike.

### `register_esp_flag`
`client.register_esp_flag(flag: string, r: number, g: number, b: number, callback)`
Requires "Flags" in Player ESP to be enabled.

### `reload_active_scripts`
`client.reload_active_scripts()`
Reloads all scripts the following frame.

### `request_full_update`
`client.request_full_update()`
Requests a full update from the server, refreshing things like skins, player models and modified netvars.

### `scale_damage`
`client.scale_damage(entindex: number, hitgroup: number, damage: number): number`
Returns adjusted damage for the specified hitgroup.

### `screen_size`
`client.screen_size(): number, number`
Returns the size of the screen in pixels.

### `set_clan_tag`
`client.set_clan_tag(...)`
Sets the player's clan tag. The clan tag is removed if no argument is passed or if it is an empty string. Additional arguments will be concatenated.

### `set_event_callback`
`client.set_event_callback(event_name: string, callback)`
Registers the function as a callback for the specified event. It can be removed later using `client.unset_event_callback`.

### `system_time`
`client.system_time(): number, number, number, number`
Returns the user's windows time.

### `timestamp`
`client.timestamp(): number`
Returns high precision timestamp in milliseconds. This can be used for benchmarking code.

### `trace_bullet`
`client.trace_bullet(from_player: number, from_x: number, from_y: number, from_z: number, to_x: number, to_y: number, to_z: number, skip_players: boolean): number, number`
Returns **entindex, damage**. Entindex is **nil** when no player is hit or if players are skipped.

### `trace_line`
`client.trace_line(skip_entindex: number, from_x: number, from_y: number, from_z: number, to_x: number, to_y: number, to_z: number): number, number`
Returns **fraction, entindex**. `fraction` is a percentage in the range `[0.0, 1.0]` that tells you how far the trace went before hitting something, so `1.0` means nothing was hit. `entindex` is the entity index that hit, or `-1` if no entity was hit.

### `unix_time`
`client.unix_time(): number`
Returns the current system time as unix time.

### `unset_event_callback`
`client.unset_event_callback(event_name: string, callback)`
Removes a callback that was previously set using `client.set_event_callback`.

### `update_player_list`
`client.update_player_list()`
Updates the player list tab without having to open it.

### `userid_to_entindex`
`client.userid_to_entindex(userid: number): number`
Converts a User ID (from game events, for example) to the entity index.

### `visible`
`client.visible(x: number, y: number, z: number): boolean`
Returns **true** if the position is visible from the local player eye position. For more advanced ray tracing use `client.trace_line`.