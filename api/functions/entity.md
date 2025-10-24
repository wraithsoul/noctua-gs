# entity
Description:
Entity related functions such as iterating them, getting and modifying netvars, etc.

## Functions

### `get_all`
`entity.get_all(classname: string): table`
Returns an array of entity indices matching the `classname`. Pass no arguments for all entities. Dormant entities are not returned.

### `get_bounding_box`
`entity.get_bounding_box(ent: number): number, number, number, number, number`
Returns the 2D bounding box and alpha multiplier (dormant esp). The contents of `x1, y1, x2, y2` must be ignored when `alpha_multiplier` is zero, which indicates that the bounding box is invalid and should not be drawn.

### `get_classname`
`entity.get_classname(ent: number): string`
Returns the name of the entity's class.

### `get_esp_data`
`entity.get_esp_data(player: number): table`
Returns a table containing `alpha`, `health`, `flags`, and `weapon_id`, or **nil** on failure.

### `get_game_rules`
`entity.get_game_rules(): number`
Returns the entity index of the `CCSGameRulesProxy` instance, or **nil** if none exists.

### `get_local_player`
`entity.get_local_player(): number`
Returns the entity index for the local player, or **nil** on failure.

### `get_origin`
`entity.get_origin(ent: number): number, number, number`
Returns **x, y, z** world coordinates of the entity's origin, or **nil** if the entity is dormant and dormant ESP information is not available.

### `get_player_name`
`entity.get_player_name(player: number): string`
Returns the player's name, or the string "unknown" on failure.

### `get_player_resource`
`entity.get_player_resource(): number`
Returns the entity index of the `CCSPlayerResource` instance, or **nil** if none exists.

### `get_player_weapon`
`entity.get_player_weapon(player: number): number`
Returns the entity index of the player's active weapon, or **nil** if the player is not alive, dormant, etc.

### `get_players`
`entity.get_players(enemies_only: boolean): table`
Returns an array of player entity indices. Dormant and dead players will not be added to the list.

### `get_prop`
`entity.get_prop(ent: number, prop: string, array_index: number):`
Returns the value of the property, or **nil** on failure. For vectors or angles, this returns three values.

### `get_steam64`
`entity.get_steam64(player: number): number`
Returns the player's **SteamID3**, or **nil** on failure.

### `hitbox_position`
`entity.hitbox_position(player: number, hitbox: number): number, number, number`
Returns world coordinates of the hitboxes, or **nil** on failure.

### `is_alive`
`entity.is_alive(ent: number): boolean`
Returns **true** if the player is not dead.

### `is_dormant`
`entity.is_dormant(ent: number): boolean`
Returns **true** if the entity is dormant.

### `is_enemy`
`entity.is_enemy(ent: number): boolean`
Returns **true** if the entity is on the opposing team.

### `new_prop`
`entity.new_prop(propname: string, offset: number, type: number, array_type: number, array_element_size: number, array_count: number)`
Creates a new entity prop that can then be read and modified with `entity.get_prop` / `entity.set_prop`.

### `set_prop`
`entity.set_prop(ent: number, prop: string, ..., array_index: number)`
Sets the value of the property. For vectors or angles, pass three values.