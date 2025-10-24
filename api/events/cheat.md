# aim\_fire
Description:
Fired when the rage aimbot shoots at a player.

## Example
```lua
local hitgroup_names = {"generic", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear"}

local function aim_fire(e)
    local flags = {
        e.teleported and "T" or "",
        e.interpolated and "I" or "",
        e.extrapolated and "E" or "",
        e.boosted and "B" or "",
        e.high_priority and "H" or ""
    }

    local group = hitgroup_names[e.hitgroup + 1] or "?"
    print(string.format(
        "Fired at %s (%s) for %d dmg (chance=%d%%, bt=%2d, flags=%s)",
        entity.get_player_name(e.target), group, e.damage,
        math.floor(e.hit_chance + 0.5), globals.toticks(e.backtrack),
        table.concat(flags)
    ))
end

client.set_event_callback("aim_fire", aim_fire)
```

## Arguments
| Index | Name | Type |
| :---: | :---: | :---: |
| 0 | Argument \#0 | table |

**\#0 - Properties**
| Name | Description |
| :--- | :--- |
| `id` | Shot ID, this can be used to find the corresponding `aim_hit` / `aim_miss` event |
| `target` | Target player entindex |
| `hit_chance` | Chance the shot will hit, depends on spread |
| `hitgroup` | Targeted hit group, this is not the same thing as a hitbox |
| `damage` | Predicted damage the shot will do |
| `backtrack` | Amount of ticks the player was backtracked |
| `boosted` | True if accuracy boost was used to increase the accuracy of the shot |
| `high_priority` | True if the shot was at a high priority record, like on shot backtrack |
| `interpolated` | Player was interpolated |
| `extrapolated` | Player was extrapolated |
| `teleported` | Target player was teleporting (breaking lag compensation) |
| `tick` | Tick the shot was fired at. This can be used to draw the hitboxes using `client.draw_hitboxes` |
| `x` | X world coordinate of the aim point |
| `y` | Y world coordinate of the aim point |
| `z` | Z world coordinate of the aim point |

# aim\_hit
Description:
Fired when the rage aimbot hit a shot at a player.

## Example
```lua
local hitgroup_names = {"generic", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear"}

local function aim_hit(e)
    local group = hitgroup_names[e.hitgroup + 1] or "?"

    print(string.format(
        "Hit %s in the %s for %d damage (%d health remaining)",
        entity.get_player_name(e.target), group, e.damage,
        entity.get_prop(e.target, "m_iHealth")
    ))
end

client.set_event_callback("aim_hit", aim_hit)
```

## Arguments
| Index | Name | Type |
| :---: | :---: | :---: |
| 0 | Argument \#0 | table |

**\#0 - Properties**
| Name | Description |
| :--- | :--- |
| `id` | Shot ID, the corresponding `aim_fire` event has the same ID |
| `target` | Target player entindex |
| `hit_chance` | Actual hit chance the shot had |
| `hitgroup` | Hit group that was hit. This is not the same thing as a hitbox |
| `damage` | Actual damage the shot did |

# aim\_miss
Description:
Fired when the rage aimbot missed a shot at a player.

## Example
```lua
local hitgroup_names = {"generic", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear"}

local function aim_miss(e)
    local group = hitgroup_names[e.hitgroup + 1] or "?"

    print(string.format(
        "Missed %s (%s) due to %s",
        entity.get_player_name(e.target), group, e.reason
    ))
end

client.set_event_callback("aim_miss", aim_miss)
```

## Arguments
| Index | Name | Type |
| :---: | :---: | :---: |
| 0 | Argument \#0 | table |

**\#0 - Properties**
| Name | Description |
| :--- | :--- |
| `id` | Shot ID, the corresponding `aim_fire` event has the same ID |
| `target` | Target player entindex |
| `hit_chance` | Actual hit chance the shot had |
| `hitgroup` | Hit group that was missed. This is not the same thing as a hitbox |
| `reason` | Reason the shot was missed. This can be 'spread', 'prediction error', 'death' or '?' (unknown / resolver) |

# console\_input
Description:
Fired every time the user types something in the game console and presses enter. Return **true** from the event handler to make the game not process the input.

## Example
```lua
client.set_event_callback("console_input", function(text)
    client.log("entered: '", text, "'")
end)
```

## Arguments
| Index | Name | Type |
| :---: | :---: | :---: |
| 0 | console input text | string |

# finish\_command
Description:
Unknown

## Arguments
| Index | Name | Type |
| :---: | :---: | :---: |
| 0 | Argument \#0 | table |

**\#0 - Properties**
| Name | Description |
| :--- | :--- |
| `command_number` | Current command number. |
| `chokedcommands` | Amount of commands that the client has choked |

# indicator
Description:
This event lets you lets you override how indicators are drawn. There can only be one callback for this event. This event callback is invoked from `renderer.indicator` and indicators like "DT".

## Arguments
| Index | Name | Type |
| :---: | :---: | :---: |
| 0 | Argument \#0 | table |

**\#0 - Properties**
| Name | Description |
| :--- | :--- |
| `text` | Drawn text |
| `r` | Drawn color: Red 0-255 |
| `g` | Drawn color: Green 0-255 |
| `b` | Drawn color: Blue 0-255 |
| `a` | Alpha 0-255 |

# net\_update\_end
Description:
Fired after an entity update packet is received from the server. (`FrameStageNotify FRAME_NET_UPDATE_END`)

# net\_update\_start
Description:
Fired before the game processes entity updates from the server. (`FrameStageNotify FRAME_NET_UPDATE_START`) Be careful when using this event to modify entity data, some things have to be restored manually as not even a full update will update them

# output
Description:
This event lets you override the text drawn in the top left. There can only be one callback for this event. This event callback is invoked from `print`, `client.log`, `client.color_log`, "Missed due to spread" message, etc.

## Arguments
| Index | Name | Type |
| :---: | :---: | :---: |
| 0 | Argument \#0 | table |

**\#0 - Properties**
| Name | Description |
| :--- | :--- |
| `text` | Drawn text |
| `r` | Drawn color: Red 0-255 |
| `g` | Drawn color: Green 0-255 |
| `b` | Drawn color: Blue 0-255 |
| `a` | Alpha 0-255 |

# override\_view
Description:
Lets you override the camera position and angles.

## Arguments
| Index | Name | Type |
| :---: | :---: | :---: |
| 0 | Argument \#0 | table |

**\#0 - Properties**
| Name | Description |
| :--- | :--- |
| `x` | Camera X position |
| `y` | Camera Y position |
| `z` | Camera Z position |
| `pitch` | Pitch view angle |
| `yaw` | Yaw view angle |
| `fov` | Field of view |

# paint
Description:
Fired every time the game renders a frame while being connected to a server. Can be used to draw to the screen using the `renderer.*` functions.

## Example
```lua
client.set_event_callback("paint", function()
    renderer.text(15, 15, 255, 255, 255, 255, nil, 0, "hello world")
end)
```

# paint\_ui
Description:
Fired every time the game renders a frame, even if you're in the menu. Can be used to draw to the screen using the `renderer.*` functions.

# player\_chat
Description:
Fired when a player sends a message to chat.

## Arguments
| Index | Name | Type |
| :---: | :---: | :---: |
| 0 | Argument \#0 | table |

**\#0 - Properties**
| Name | Description |
| :--- | :--- |
| `teamonly` | true if the message was sent to team chat |
| `entity` | Entity index of the player sending the message |
| `name` | Name of the player sending the message |
| `text` | Chat message text |

# post\_config\_load
Description:
Fired after a config has been loaded.

# post\_config\_save
Description:
Fired after a config has been saved.

# post\_render
Description:
Fired after a frame is rendered.

# pre\_config\_load
Description:
Fired before a config will be loaded.

# pre\_config\_save
Description:
Fired before a config will be saved.

# pre\_predict\_command
Description:
This event doesn't have any known information about it yet (awaiting staff clarification).

# pre\_render
Description:
Fired before a frame is rendered.

# pre\_render\_3d
Description:
This event doesn't have any known information about it yet (awaiting staff clarification).

# predict\_command
Description:
Fired when the game prediction is ran.

## Arguments
| Index | Name | Type |
| :---: | :---: | :---: |
| 0 | Argument \#0 | table |

**\#0 - Properties**
| Name | Description |
| :--- | :--- |
| `command_number` | Command number of the predicted command |

# run\_command
Description:
Fired every time the game runs a command (usually 64 times a second, equal to tickrate) while you're alive. This is the best event for processing data that only changes when the game receives an update from the server, like information about other players.

## Arguments
| Index | Name | Type |
| :---: | :---: | :---: |
| 0 | Argument \#0 | table |

**\#0 - Properties**
| Name | Description |
| :--- | :--- |
| `chokedcommands` | Amount of commands that the client has choked |
| `command_number` | Current command number |

# setup\_command
Description:
Fired every time the game prepares a move command that's sent to the server. This is ran before cheat features like antiaim and can be used to modify user input (view angles, pressed keys, movement) how it's seen by the cheat. For example, setting `in_use = 1` will disable antiaim the same way pressing use key ingame does. This is the preferred method of setting user input and should be used instead of `client.exec` whenever possible.

## Arguments
| Index | Name | Type |
| :---: | :---: | :---: |
| 0 | Argument \#0 | table |

**\#0 - Properties**
| Name | Description |
| :--- | :--- |
| `chokedcommands` | Amount of commands that the client has choked |
| `command_number` | Current command number |
| `discharge_pending` | Set to true to discharge double tap. Does not work with other exploit features |
| `pitch` | Pitch view angle |
| `yaw` | Yaw view angle |
| `forwardmove` | Forward / backward speed (-450 to 450) |
| `sidemove` | Left / right speed (-450 to 450) |
| `move_yaw` | Yaw angle that's used for movement. If not set, view yaw is used |
| `allow_send_packet` | Set to false to make the cheat choke the current command (when possible) |
| `no_choke` | Set to true to avoid unnecessary choking like fake lag. Some features (like anti-aimbot) don't respect this field |
| `quick_stop` | Whether or not quick stop is being triggered |
| `force_defensive` | Set to true to forcibly activate defensive |
| `in_attack` | IN\_ATTACK Button |
| `in_jump` | IN\_JUMP Button |
| `in_duck` | IN\_DUCK Button |
| `in_forward` | IN\_FORWARD Button |
| `in_back` | IN\_BACK Button |
| `in_use` | IN\_USE Button |
| `in_cancel` | IN\_CANCEL Button |
| `in_left` | IN\_LEFT Button |
| `in_right` | IN\_RIGHT Button |
| `in_moveleft` | IN\_MOVELEFT Button |
| `in_moveright` | IN\_MOVERIGHT Button |
| `in_attack2` | IN\_ATTACK2 Button |
| `in_run` | IN\_RUN Button |
| `in_reload` | IN\_RELOAD Button |
| `in_alt1` | IN\_ALT1 Button |
| `in_alt2` | IN\_ALT2 Button |
| `in_score` | IN\_SCORE Button |
| `in_speed` | IN\_SPEED Button |
| `in_walk` | IN\_WALK Button |
| `in_zoom` | IN\_ZOOM Button |
| `in_weapon1` | IN\_WEAPON1 Button |
| `in_weapon2` | IN\_WEAPON2 Button |
| `in_bullrush` | IN\_BULLRUSH Button |
| `in_grenade1` | IN\_GRENADE1 Button |
| `in_grenade2` | IN\_GRENADE2 Button |
| `in_attack3` | IN\_ATTACK3 Button |
| `weaponselect` | (No description provided) |
| `weaponsubtype` | (No description provided) |

# shutdown
Description:
Fired when one of the two following conditions are met:

1.  When the game is being closed
2.  When Lua scripts are being unloaded/reloaded

# string\_cmd
Description:
Fired before a string command (chat messages, weapon inspecting, buy commands) is sent to the server.

## Arguments
| Index | Name | Type |
| :---: | :---: | :---: |
| 0 | string command | string |

# voice
Description:
Fired every time that voice data has been received.

## Example
Credits to FlowerHvH1337 for this example:

```lua
local voice_data_t = ffi.typeof[[
    struct {
        char     pad_0000;
        int32_t  client;
        int32_t  audible_mask;
        uint64_t xuid;
        void*    voice_data;
        bool     proximity;
        bool     caster;
        char     pad_001E;
        int32_t  format;
        int32_t  sequence_bytes;
        uint32_t section_number;
        uint32_t uncompressed_sample_offset;
        char     pad_0030;
        uint32_t has_bits;
    } *
]]

client.set_event_callback("voice", function(e)
    local data = e.data
    local voice_data = ffi.cast(voice_data_t, data)
end)
```