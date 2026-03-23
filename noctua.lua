--[[

    noctua.sbs (side by side)
    author: t.me/ovhbypass
    note: бонус за безумный код

--]]

--@region: information
information = {} do
    _G.noctua_runtime = _G.noctua_runtime or {}
    _G.noctua_runtime.stats = _G.noctua_runtime.stats or { hits = 0, misses = 0 }
    _G._name = 'noctua'
    _G._version = '1.4'
    _G._nickname = nil

    information.update_nickname = function()
        local local_player = entity.get_local_player()
        if local_player then
            local name = entity.get_player_name(local_player)
            if name and name ~= "" then
                _G._nickname = name
            end
        end
    end

    information.setup = function()
        information.update_nickname()

        client.set_event_callback('player_spawn', function(e)
            local me = entity.get_local_player()
            if me and client.userid_to_entindex(e.userid) == me then
                information.update_nickname()
            end
        end)
    end

    information.setup()
end
--@endregion

--@region: news
news = {} do
    local container = panorama.loadstring([[
        var panel = null;
        var js_news = null;
        var original_transform = null;
        var original_visibility = null;

        var _Create = function(layout) {
            js_news = $.GetContextPanel().FindChildTraverse("JsNewsContainer");
            if (!js_news) {
                return;
            }

            original_transform = js_news.style.transform || 'none';
            original_visibility = js_news.style.visibility || 'visible';

            js_news.style.transform = 'translate3d(-9999px, -9999px, 0)';
            js_news.style.visibility = 'collapse';

            var parent = js_news.GetParent();
            if (!parent) {
                return;
            }

            panel = $.CreatePanel("Panel", parent, "CustomPanel");
            if(!panel) {
                return;
            }

            if(!panel.BLoadLayoutFromString(layout, false, false)) {
                panel.DeleteAsync(0);
                panel = null;
                return;
            }

            parent.MoveChildBefore(panel, js_news);
        };

        var _Destroy = function() {
            if (js_news) {
                if (panel) {
                    panel.DeleteAsync(0.0);
                    panel = null;
                }

                js_news.style.transform = original_transform;
                js_news.style.visibility = original_visibility;
            }
        };

        return {
            create: _Create,
            destroy: _Destroy,
        };
    ]], "CSGOMainMenu")()

    local layout = [[
    <root>
        <Panel style="width: 100%; height: 100%; flow-children: down;">
        </Panel>
    </root>
    ]]

    news.setup = function()
        container.create(layout)

        client.set_event_callback('shutdown', function()
            container.destroy()
        end)
    end

    news.setup()
end
--@endregion

--@region: luraph
if not LPH_OBFUSCATED then
    LPH_ENCNUM = function(toEncrypt, ...)
        assert(
            type(toEncrypt) == "number" and #{...} == 0,
            "LPH_ENCNUM only accepts a single constant double or integer as an argument."
        )
        return toEncrypt
    end
    LPH_NUMENC = LPH_ENCNUM

    LPH_ENCSTR = function(toEncrypt, ...)
        assert(
            type(toEncrypt) == "string" and #{...} == 0,
            "LPH_ENCSTR only accepts a single constant string as an argument."
        )
        return toEncrypt
    end
    LPH_STRENC = LPH_ENCSTR


    LPH_ENCFUNC = function(toEncrypt, encKey, decKey, ...)
        assert(
            type(toEncrypt) == "function" and type(encKey) == "string" and #{...} == 0,
            "LPH_ENCFUNC accepts a constant function, constant string, and string variable as arguments."
        )
        return toEncrypt
    end
    LPH_FUNCENC = LPH_ENCFUNC

    LPH_JIT = function(f, ...)
        assert(
            type(f) == "function" and #{...} == 0,
            "LPH_JIT only accepts a single constant function as an argument."
        )
        return f
    end
    LPH_JIT_MAX = LPH_JIT

    LPH_NO_VIRTUALIZE = function(f, ...)
        assert(
            type(f) == "function" and #{...} == 0,
            "LPH_NO_VIRTUALIZE only accepts a single constant function as an argument."
        )
        return f
    end

    LPH_NO_UPVALUES = function(f, ...)
        assert(
            type(setfenv) == "function",
            "LPH_NO_UPVALUES can only be used on Lua versions with getfenv & setfenv"
        )
        assert(
            type(f) == "function" and #{...} == 0,
            "LPH_NO_UPVALUES only accepts a single constant function as an argument."
        )
        return f
    end

    LPH_CRASH = function(...)
        assert(#{...} == 0, "LPH_CRASH does not accept any arguments.")
    end
end
--@endregion

--@region: dependencies
dependencies = {} do
    local function try_require(module_name, err_msg)
        local ok, mod = pcall(require, module_name)
        if not ok then
            error(err_msg, 2)
        end
        return mod
    end

    dependencies.setup = function()
        local dependency_list = {
            { name = "pui",           path = "gamesense/pui",            msg = "Failed to require pui" },
            { name = "ffi",           path = "ffi",                      msg = "Failed to require ffi" },
            { name = "bit",           path = "bit",                      msg = "Failed to require bit" },
            { name = "vector",        path = "vector",                   msg = "Failed to require vector" },
            { name = "color",         path = "gamesense/color",          msg = "Failed to require color" },
            { name = "http",          path = "gamesense/http",           msg = "Failed to require http" },
            { name = "antiaim_funcs", path = "gamesense/antiaim_funcs",  msg = "Failed to require antiaim_funcs" },
            { name = "clipboard",     path = "gamesense/clipboard",      msg = "Failed to require clipboard" },
            { name = "images",        path = "gamesense/images",         msg = "Failed to require images" },
            { name = "csgo_weapons",  path = "gamesense/csgo_weapons",   msg = "Failed to require csgo_weapons" },
            { name = "base64",        path = "gamesense/base64",         msg = "Failed to require base64" },
            { name = "chat",          path = "gamesense/chat",           msg = "Failed to require chat" },
            { name = "localize",      path = "gamesense/localize",       msg = "Failed to require localize" },
        }

        for _, dep in ipairs(dependency_list) do
            _G[dep.name] = try_require(dep.path, dep.msg)
        end
    end

    dependencies.setup()
end
--@endregion

--@region: mathematic
mathematic = {} do
    mathematic.clamp = function(v, min, max)
        return math.max(min, math.min(v, max))
    end

    mathematic.sign = function(number)
        if number > 0 then
            return 1
        elseif number < 0 then
            return -1
        else
            return 0
        end
    end

    mathematic.angle_diff = function(dest, src)
        local delta = math.fmod(dest - src + 180, 360) - 180
        return delta
    end

    mathematic.angle_normalize = function(angle)
        return math.fmod(angle, 360)
    end
    
    mathematic.anglemod = function(a)
        local num = (360 / 65536) * bit.band(math.floor(a * (65536 / 360.0)), 65535)
        return num
    end

    mathematic.lerp = function(a, b, t)
        return a + (b - a) * t
    end

    mathematic.normalize_yaw = function(yaw)
        while yaw > 180 do
            yaw = yaw - 360
        end
        while yaw < -180 do
            yaw = yaw + 360
        end
        return yaw
    end

    mathematic.approach_angle = function(target, value, speed)
        target = mathematic.anglemod(target)
        value = mathematic.anglemod(value)
        local delta = target - value
        if speed < 0 then speed = -speed end
        if delta < -180 then
            delta = delta + 360
        elseif delta > 180 then
            delta = delta - 360
        end
        if delta > speed then
            value = value + speed
        elseif delta < -speed then
            value = value - speed
        else
            value = target
        end
        return value
    end
end
--@endregion

--@region: colors
colors = {} do
    colors.hex_rgba = function(r, g, b, a)
        local rInt = math.floor(r + 0.5)
        local gInt = math.floor(g + 0.5)
        local bInt = math.floor(b + 0.5)
        local aInt = math.floor(a + 0.5)
        local hexValue = (rInt * 16777216) + (gInt * 65536) + (bInt * 256) + aInt
        return bit.tohex(hexValue)
    end
    
    colors.shimmer = function(time, text, r, g, b, a, r2, g2, b2, a2)
        local animated = {}
        local index = 1
        local numChars = #text
        local rAdd = r2 - r
        local gAdd = g2 - g
        local bAdd = b2 - b
        local aAdd = a2 - a
        local slowFactor = 0.5
    
        for i = 1, numChars do
            local phase = ((i - 1) / (numChars - 1)) + time * slowFactor
            local animationFactor = math.abs(math.cos(phase))
            local curR = r + rAdd * animationFactor
            local curG = g + gAdd * animationFactor
            local curB = b + bAdd * animationFactor
            local curA = a + aAdd * animationFactor
    
            animated[index] = "\a" .. colors.hex_rgba(curR, curG, curB, curA)
            animated[index + 1] = text:sub(i, i)
            index = index + 2
        end
    
        return animated
    end
end
--@endregion

--@region: aspect ratio
aspect_ratio = {} do
    aspect_ratio.screen_width, aspect_ratio.screen_height = nil, nil
    aspect_ratio.multiplier = 0.01
    aspect_ratio.steps = 200
    aspect_ratio.ratio_table = {}
    aspect_ratio.current_ratio = 1

    aspect_ratio.gcd = function(m, n)
        while m ~= 0 do
            m, n = math.fmod(n, m), m
        end
        return n
    end

    aspect_ratio.generate_ratio_table = function()
        local screen_width, screen_height = client.screen_size()
        if screen_width == aspect_ratio.screen_width and screen_height == aspect_ratio.screen_height then
            return aspect_ratio.ratio_table
        end

        aspect_ratio.screen_width, aspect_ratio.screen_height = screen_width, screen_height
        aspect_ratio.ratio_table = {}

        for i = 1, aspect_ratio.steps do
            local i2 = (aspect_ratio.steps - i) * aspect_ratio.multiplier
            local divisor = aspect_ratio.gcd(screen_width * i2, screen_height)
            if screen_width * i2 / divisor < 100 or i2 == 1 then
                aspect_ratio.ratio_table[i] = string.format("%d:%d", screen_width * i2 / divisor, screen_height / divisor)
            end
        end

        return aspect_ratio.ratio_table
    end
    
    aspect_ratio.set_ratio = function(multiplier)
        local screen_width, screen_height = client.screen_size()
        local aspectratio_value = (screen_width * multiplier) / screen_height

        if multiplier == 1 then
            aspectratio_value = 0
        end
        client.set_cvar("r_aspectratio", tonumber(aspectratio_value))
    end

    aspect_ratio.setup = function()
        -- if not (interface.visuals.enabled_visuals:get() and interface.visuals.aspect_ratio:get()) then
        --     aspect_ratio.current_ratio = mathematic.lerp(aspect_ratio.current_ratio, 1, globals.frametime() * 8)
        --     aspect_ratio.set_ratio(aspect_ratio.current_ratio)
        --     return
        -- end
        
        local target_ratio = 2 - (interface.visuals.aspect_ratio_slider:get() * 0.01)
        aspect_ratio.current_ratio = mathematic.lerp(aspect_ratio.current_ratio, target_ratio, globals.frametime() * 8)
        aspect_ratio.set_ratio(aspect_ratio.current_ratio)
    end

    aspect_ratio.init = function()
        aspect_ratio.generate_ratio_table()
    end
end

aspect_ratio.init()
--@endregion

--@region: thirdperson
thirdperson = {} do
    thirdperson.setup = function() end
end
--@endregion

--@region: viewmodel
viewmodel = {} do
    viewmodel.current_fov = cvar.viewmodel_fov:get_float()
    viewmodel.current_x = cvar.viewmodel_offset_x:get_float()
    viewmodel.current_y = cvar.viewmodel_offset_y:get_float()
    viewmodel.current_z = cvar.viewmodel_offset_z:get_float()
    viewmodel.hand_override_active = false
    viewmodel.saved_righthand = cvar.cl_righthand:get_int()

    local function restore_knife_hand()
        if viewmodel.hand_override_active then
            cvar.cl_righthand:set_int(viewmodel.saved_righthand)
            viewmodel.hand_override_active = false
        end
    end

    viewmodel.setup = function()
        if not (interface.visuals.enabled_visuals:get() and interface.visuals.viewmodel:get()) then
            restore_knife_hand()
            return
        end

        local target_fov = interface.visuals.viewmodel_fov:get()
        local target_x = interface.visuals.viewmodel_x:get() * 0.01
        local target_y = interface.visuals.viewmodel_y:get() * 0.01
        local target_z = interface.visuals.viewmodel_z:get() * 0.01

        viewmodel.current_fov = mathematic.lerp(viewmodel.current_fov, target_fov, globals.frametime() * 8)
        viewmodel.current_x = mathematic.lerp(viewmodel.current_x, target_x, globals.frametime() * 8)
        viewmodel.current_y = mathematic.lerp(viewmodel.current_y, target_y, globals.frametime() * 8)
        viewmodel.current_z = mathematic.lerp(viewmodel.current_z, target_z, globals.frametime() * 8)

        cvar.viewmodel_fov:set_raw_float(viewmodel.current_fov)
        cvar.viewmodel_offset_x:set_raw_float(viewmodel.current_x)
        cvar.viewmodel_offset_y:set_raw_float(viewmodel.current_y)
        cvar.viewmodel_offset_z:set_raw_float(viewmodel.current_z)

        if not interface.visuals.opposite_knife_hand:get() then
            restore_knife_hand()
            return
        end

        local me = entity.get_local_player()
        if not me or not entity.is_alive(me) then
            restore_knife_hand()
            return
        end

        local weapon = entity.get_player_weapon(me)
        local weapon_info = weapon and csgo_weapons(weapon) or nil
        local is_knife = weapon_info ~= nil and weapon_info.type == 'knife'

        if not is_knife then
            restore_knife_hand()
            return
        end

        local current_hand = cvar.cl_righthand:get_int()
        if not viewmodel.hand_override_active then
            viewmodel.saved_righthand = current_hand
            viewmodel.hand_override_active = true
        end

        cvar.cl_righthand:set_int(viewmodel.saved_righthand == 1 and 0 or 1)
    end
end

--@region: sunlight
sunlight = {} do
    sunlight.saved_override = cvar.cl_csm_rot_override:get_int()
    sunlight.saved_x = cvar.cl_csm_rot_x:get_float()
    sunlight.saved_y = cvar.cl_csm_rot_y:get_float()
    sunlight.saved_z = cvar.cl_csm_rot_z:get_float()
    sunlight.active = false

    sunlight.restore = function()
        if not sunlight.active then
            return
        end

        cvar.cl_csm_rot_override:set_int(sunlight.saved_override)
        cvar.cl_csm_rot_x:set_raw_float(sunlight.saved_x)
        cvar.cl_csm_rot_y:set_raw_float(sunlight.saved_y)
        cvar.cl_csm_rot_z:set_raw_float(sunlight.saved_z)
        sunlight.active = false
    end

    sunlight.setup = function()
        if not (interface.visuals.enabled_visuals:get() and interface.visuals.sunlight:get()) then
            sunlight.restore()
            return
        end

        cvar.cl_csm_rot_override:set_int(1)
        cvar.cl_csm_rot_x:set_raw_float(interface.visuals.sunlight_x:get())
        cvar.cl_csm_rot_y:set_raw_float(interface.visuals.sunlight_y:get())
        cvar.cl_csm_rot_z:set_raw_float(interface.visuals.sunlight_z:get())
        sunlight.active = true
    end
end

--@region: fog
fog = {} do
    fog.saved = {
        override = client.get_cvar("fog_override") or "0",
        enable = client.get_cvar("fog_enable") or "0",
        skybox = client.get_cvar("fog_enableskybox") or "0",
        color = client.get_cvar("fog_color") or "255 255 255",
        start = client.get_cvar("fog_start") or "0",
        ["end"] = client.get_cvar("fog_end") or "0",
        density = client.get_cvar("fog_maxdensity") or "1"
    }
    fog.active = false

    fog.restore = function()
        if not fog.active then
            return
        end

        reference.visuals.effects.remove_fog:override()
        client.set_cvar("fog_override", fog.saved.override)
        client.set_cvar("fog_enable", fog.saved.enable)
        client.set_cvar("fog_enableskybox", fog.saved.skybox)
        client.set_cvar("fog_color", fog.saved.color)
        client.set_cvar("fog_start", fog.saved.start)
        client.set_cvar("fog_end", fog.saved["end"])
        client.set_cvar("fog_maxdensity", fog.saved.density)
        fog.active = false
    end

    fog.setup = function()
        if not (interface.visuals.enabled_visuals:get() and interface.visuals.fog:get()) then
            fog.restore()
            return
        end

        local color_value = interface.visuals.fog_color.color.value
        local density = interface.visuals.fog_density:get() * 0.01

        reference.visuals.effects.remove_fog:override(false)
        client.set_cvar("fog_override", 1)
        client.set_cvar("fog_enable", 1)
        client.set_cvar("fog_enableskybox", 1)
        client.set_cvar("fog_color", string.format("%d %d %d", color_value[1], color_value[2], color_value[3]))
        client.set_cvar("fog_start", interface.visuals.fog_start:get())
        client.set_cvar("fog_end", interface.visuals.fog_end:get())
        client.set_cvar("fog_maxdensity", density)
        fog.active = true
    end
end

--@region: zoom animation
zoom_animation = {} do
    zoom_animation.lerp_storage = {}
    
    zoom_animation.lerp = function(name, target, speed, tolerance, easing)
        if zoom_animation.lerp_storage[name] == nil then
            zoom_animation.lerp_storage[name] = target
        end
        
        speed = speed or 8
        tolerance = tolerance or 0.001
        easing = easing or 'ease_out'
        
        local current = zoom_animation.lerp_storage[name]
        local delta = globals.frametime() * speed
        local new_value
        
        if easing == 'linear' then
            new_value = current + (target - current) * delta
        elseif easing == 'ease_out' then
            local progress = 1 - (1 - delta) * (1 - delta)
            new_value = current + (target - current) * progress
        else
            new_value = current + (target - current) * delta
        end
        
        if math.abs(target - new_value) <= tolerance then
            zoom_animation.lerp_storage[name] = target
        else
            zoom_animation.lerp_storage[name] = new_value
        end
        
        return zoom_animation.lerp_storage[name]
    end
    
    zoom_animation.setup = function(ctx)
        if not (interface.visuals.enabled_visuals:get() and interface.visuals.zoom_animation:get()) then
            pui.reference('misc', 'miscellaneous', 'override zoom fov'):override()
            return
        end
        
        pui.reference('misc', 'miscellaneous', 'override zoom fov'):override(0)
        
        local me = entity.get_local_player()
        if not me or not entity.is_alive(me) then
            return
        end
        
        local fov = interface.visuals.zoom_animation_value:get()
        local speed = interface.visuals.zoom_animation_speed:get()
        local is_scoped = entity.get_prop(me, 'm_bIsScoped') == 1
        
        local animate = zoom_animation.lerp('zoom', is_scoped and fov or 0, speed / 10, 0.001, 'ease_out')
        ctx.fov = ctx.fov - animate
    end
end
--@endregion

--@region: spawn zoom
spawn_zoom = {} do
    spawn_zoom.active = false

    spawn_zoom.on_player_spawn = function(e)
        local me = entity.get_local_player()
        if not me then return end
        if client.userid_to_entindex(e.userid) ~= me then return end
        if not (interface.visuals.enabled_visuals:get() and interface.visuals.spawn_zoom:get()) then return end
        spawn_zoom.active = true
        zoom_animation.lerp_storage['spawn_zoom'] = 100
    end

    spawn_zoom.setup = function(ctx)
        if not spawn_zoom.active then return end
        if not (interface.visuals.enabled_visuals:get() and interface.visuals.spawn_zoom:get()) then
            spawn_zoom.active = false
            return
        end
        pui.reference('misc', 'miscellaneous', 'override zoom fov'):override(0)
        local animate = zoom_animation.lerp('spawn_zoom', 0, 80 / 10, 0.01, 'ease_out')
        ctx.fov = ctx.fov - animate
        if math.abs(animate - 0) <= 0.01 then
            spawn_zoom.active = false
        end
    end
end

client.set_event_callback('player_spawn', spawn_zoom.on_player_spawn)
--@endregion

client.set_event_callback('paint', function()
    aspect_ratio.setup()
    thirdperson.setup()
    viewmodel.setup()
    sunlight.setup()
    fog.setup()
end)

client.set_event_callback('shutdown', function()
    if viewmodel.hand_override_active then
        cvar.cl_righthand:set_int(viewmodel.saved_righthand)
    end

    sunlight.restore()
    fog.restore()
end)

client.set_event_callback('override_view', function(ctx)
    spawn_zoom.setup(ctx)
    zoom_animation.setup(ctx)
end)
--@endregion

--@region: interface
local antiaim_state_options = {
    'default',
    'idle',
    'run',
    'slow',
    'air',
    'airc',
    'duck',
    'duck move',
    'use',
    'manual',
    'freestand',
}

interface = {} do
    pui.macros.title = _name

    interface.header = {
        general = pui.group('AA', 'Anti-Aimbot angles'),
        fake_lag = pui.group('AA', 'Fake lag'),
        other = pui.group('AA', 'Other')
    }

    interface.additional = {
        empty = '⠀'
    }
 
    interface.search = interface.header.general:combobox(pui.macros.title .. ' - '.. _version, 'home', 'players', 'aimbot', 'antiaim', 'visuals', 'world', 'utility', 'config', 'other')

    interface.home = {
        title = interface.header.fake_lag:label('your stats:'),
        kills = interface.header.fake_lag:label(' · kills: 0'),
        deaths = interface.header.fake_lag:label(' · deaths: 0'),
        kd = interface.header.fake_lag:label(' · kd ratio: 0'),
        title_script = interface.header.fake_lag:label('cheat:'),
        hits = interface.header.fake_lag:label(' · hits: 0'),
        misses = interface.header.fake_lag:label(' · misses: 0'),
        evaded = interface.header.fake_lag:label(' · evaded shots: 0'),
        ratio = interface.header.fake_lag:label(' · ratio: 0'),
        reset = interface.header.fake_lag:button('reset'),
        confetti = interface.header.general:button('confetti'),
        winter_label = interface.header.other:label('\a89cff0ff❄ winter'),
        menu_snow = interface.header.other:checkbox('menu snow'),
        compatibility_mode = interface.header.other:checkbox('noctua · compatibility mode')
    }

    interface.kas = {
        enabled = interface.header.general:checkbox('enable kas'),
        player_list = interface.header.general:listbox('player list', 220),
        status = interface.header.general:label(' · selected: none'),
        database_status = interface.header.general:label(' · in database: no'),
        add_button = interface.header.general:button('add'),
        edit_button = interface.header.general:button('edit'),
        remove_button = interface.header.general:button('remove'),
        view_source = interface.header.other:label(' · source: -'),
        view_alias = interface.header.other:label(' · alias: -'),
        view_alternative = interface.header.other:label(' · alternative: -'),
        view_group = interface.header.other:label(' · group: -'),
        view_note = interface.header.other:label(' · note: -'),
        options = interface.header.other:multiselect('options\nkas.options', 'alias', 'alternative', 'source', 'group', 'note'),
        source = interface.header.other:combobox('source', {'manual', 'public', 'community', 'league', 'report'}),
        alias_label = interface.header.other:label('alias'),
        alias = (interface.header.other.textbox and interface.header.other:textbox('alias')) or interface.header.other:combobox('alias', ''),
        alternative_label = interface.header.other:label('alternative aliases'),
        alternative = (interface.header.other.textbox and interface.header.other:textbox('alternative aliases')) or interface.header.other:combobox('alternative aliases', ''),
        group_label = interface.header.other:label('group'),
        group = (interface.header.other.textbox and interface.header.other:textbox('group')) or interface.header.other:combobox('group', ''),
        note_label = interface.header.other:label('note'),
        note = (interface.header.other.textbox and interface.header.other:textbox('note')) or interface.header.other:combobox('note', ''),
        add_submit = interface.header.other:button('add'),
        save_submit = interface.header.other:button('save')
    }

    interface.kas_runtime = {
        mode = 'idle',
        has_record = false,
        selected_supported = false,
        show_source = false,
        show_alias = false,
        show_alternative = false,
        show_group = false,
        show_note = false
    }

    interface.home.menu_snow:override(true)
    interface.kas.enabled:override(true)

    local function create_hitchance_profile(profile_key, has_scope)
        local options = { 'in air', 'hotkey', 'crouch', 'peek assist' }
        if has_scope then
            table.insert(options, 2, 'no scope')
        end

        local profile = {
            options = interface.header.fake_lag:multiselect('conditions\nhitchance_override.' .. profile_key .. '.options', unpack(options)),
            in_air = interface.header.fake_lag:slider('in air hitchance\nhitchance_override.' .. profile_key .. '.in_air', 0, 100, 0, true, '%', 1),
            hotkey = interface.header.fake_lag:slider('hotkey hitchance\nhitchance_override.' .. profile_key .. '.hotkey', 0, 100, 0, true, '%', 1),
            crouch = interface.header.fake_lag:slider('crouch hitchance\nhitchance_override.' .. profile_key .. '.crouch', 0, 100, 0, true, '%', 1),
            peek_assist = interface.header.fake_lag:slider('peek assist hitchance\nhitchance_override.' .. profile_key .. '.peek_assist', 0, 100, 0, true, '%', 1)
        }

        if has_scope then
            profile.no_scope = interface.header.fake_lag:slider('no scope hitchance\nhitchance_override.' .. profile_key .. '.no_scope', 0, 100, 0, true, '%', 1)
            profile.no_scope_distance = interface.header.fake_lag:slider('no scope distance\nhitchance_override.' .. profile_key .. '.no_scope_distance', 5, 3000, 450, true, 'u', 1)
        end

        return profile
    end

    interface.aimbot = {
        enabled_aimbot = interface.header.general:checkbox('enable aimbot'),
        enabled_resolver_tweaks = interface.header.general:checkbox('\aa5ab55ffyaw correction'),
        resolver_mode = interface.header.general:combobox('mode', 'autopilot', 'experimental'),
        silent_shot = interface.header.general:checkbox('silent shot'),
        force_recharge = interface.header.general:checkbox('allow force recharge'),
        quick_stop = interface.header.general:checkbox('air stop', 0x00),
        noscope_distance = interface.header.fake_lag:checkbox('noscope distance'),
        noscope_weapons = interface.header.fake_lag:multiselect('weapons', 'autosnipers', 'scout', 'awp'),
        noscope_distance_autosnipers = interface.header.fake_lag:slider('autosnipers distance', 1, 800, 450, true, ''),
        noscope_distance_scout = interface.header.fake_lag:slider('scout distance', 1, 800, 450, true, ''),
        noscope_distance_awp = interface.header.fake_lag:slider('awp distance', 1, 800, 450, true, ''),
        hitchance_override = interface.header.fake_lag:checkbox('hitchance override'),
        hitchance_override_hotkey = interface.header.fake_lag:checkbox('override hotkey', 0x00),
        hitchance_override_weapon = interface.header.fake_lag:combobox('weapon', 'autosnipers', 'deagle', 'revolver', 'pistols', 'scout', 'awp'),
        hitchance_override_profiles = {
            autosnipers = create_hitchance_profile('autosnipers', true),
            deagle = create_hitchance_profile('deagle', false),
            revolver = create_hitchance_profile('revolver', false),
            pistols = create_hitchance_profile('pistols', false),
            scout = create_hitchance_profile('scout', true),
            awp = create_hitchance_profile('awp', true)
        },
        dormant_enabled = interface.header.general:checkbox('dormant aimbot', 0x00),
        dormant_hitchance = interface.header.general:slider('hit chance', 50, 100, 50, true, '%', 1, {[50] = 'auto'}),
        dormant_damage = interface.header.general:slider('minimum damage', 1, 100, 7, true, ''),
        predictive_shot = interface.header.other:checkbox('\aa5ab55ffpredictive shot (awp only, experimental)')
    }

    local function create_antiaim_builder_profile(state_key)
        local state_id = state_key:gsub('[^%w]+', '_')
        local key_prefix = 'antiaim.builder.' .. state_id
        local profile = {}

        if state_key ~= 'default' then
            profile.enabled = interface.header.general:checkbox('override ' .. state_key .. '\n' .. key_prefix .. '.enabled')
        end

        profile.yaw_left = interface.header.general:slider('yaw left\n' .. key_prefix .. '.yaw_left', -180, 180, 0, true, '°')
        profile.yaw_right = interface.header.general:slider('yaw right\n' .. key_prefix .. '.yaw_right', -180, 180, 0, true, '°')
        profile.yaw_random = interface.header.general:slider('random\n' .. key_prefix .. '.yaw_random', 0, 30, 0, true, '%')
        profile.yaw_jitter = interface.header.general:combobox('yaw jitter\n' .. key_prefix .. '.yaw_jitter', 'off', 'offset', 'center', 'random', 'skitter')
        profile.jitter_offset = interface.header.general:slider('jitter offset\n' .. key_prefix .. '.jitter_offset', -180, 180, 0, true, '°')
        profile.jitter_random = interface.header.general:slider('randomization\n' .. key_prefix .. '.jitter_random', 0, 30, 0, true, '%')
        profile.body_yaw = interface.header.general:combobox('body yaw\n' .. key_prefix .. '.body_yaw', 'off', 'opposite', 'static', 'jitter')
        profile.body_yaw_offset = interface.header.general:slider('\n' .. key_prefix .. '.body_yaw_offset', -180, 180, 0, true, '°')
        profile.freestanding_body_yaw = interface.header.general:checkbox('freestanding body yaw\n' .. key_prefix .. '.freestanding_body_yaw')
        profile.delay_from = interface.header.general:slider('delay from\n' .. key_prefix .. '.delay_from', 1, 8, 1, true, 't', 1, {[1] = 'off'})
        profile.delay_to = interface.header.general:slider('delay to\n' .. key_prefix .. '.delay_to', 1, 8, 1, true, 't', 1, {[1] = 'off'})
        profile.invert_chance = interface.header.general:slider('invert chance\n' .. key_prefix .. '.invert_chance', 0, 100, 100, true, '%')
        profile.force_break_lc = interface.header.general:checkbox('\aa5ab55ffforce break lc\n' .. key_prefix .. '.force_break_lc')

        return profile
    end

    interface.antiaim = {
        enabled_antiaim = interface.header.general:checkbox('enable antiaim'),
        builder = {
            state = interface.header.general:combobox('state', unpack(antiaim_state_options)),
            profiles = {}
        },
        fake_lag = {
            extensions = interface.header.fake_lag:multiselect('extensions\nantiaim.fake_lag.extensions', 'avoid backstab', 'force break lc', 'safe head', 'bombsite e fix', 'break self backtrack', 'vigilant lagcomp breaking', 'correct lag on exploit', 'fast fall', 'fast ladder'),
            triggers = interface.header.fake_lag:multiselect('break lc triggers\nantiaim.fake_lag.force_break_lc_triggers', 'flashed', 'damage received', 'reloading', 'weapon switch', 'osaa'),
            safe_head_triggers = interface.header.fake_lag:multiselect('safe head triggers\nantiaim.fake_lag.safe_head_triggers', 'high distance', 'idle', 'duck', 'airc', 'airc+knife', 'airc+zeus'),
            break_self_backtrack_mode = interface.header.fake_lag:combobox('break type based on\nantiaim.fake_lag.break_self_backtrack_mode', 'threat', 'auto'),
            vigilant_controls = interface.header.fake_lag:multiselect('decisive controls\nantiaim.fake_lag.vigilant_controls', 'idle', 'run', 'duck', 'slow', 'air', 'airc'),
            correct_lag_exploit_type = interface.header.fake_lag:multiselect('exploit type\nantiaim.fake_lag.correct_lag_exploit_type', 'double tap', 'osaa')
        },
        hotkeys = {
            freestanding = interface.header.other:checkbox('freestanding', 0x00),
            freestanding_disablers = interface.header.other:multiselect('disablers', 'standing', 'moving', 'slow walk', 'air', 'crouched'),
            manual_yaw = interface.header.other:checkbox('manual yaw'),
            manual_modifier = interface.header.other:multiselect('modifier', 'disable yaw modifiers', 'freestanding body'),
            manual_left = ui.new_hotkey('AA', 'Other', 'left\nantiaim.hotkeys.manual_left'),
            manual_right = ui.new_hotkey('AA', 'Other', 'right\nantiaim.hotkeys.manual_right'),
            manual_forward = ui.new_hotkey('AA', 'Other', 'forward\nantiaim.hotkeys.manual_forward'),
            manual_backward = ui.new_hotkey('AA', 'Other', 'backward\nantiaim.hotkeys.manual_backward')
        }
    }

    for i = 1, #antiaim_state_options do
        local state_key = antiaim_state_options[i]
        interface.antiaim.builder.profiles[state_key] = create_antiaim_builder_profile(state_key)
    end

    ui.set(interface.antiaim.hotkeys.manual_left, 'Toggle')
    ui.set(interface.antiaim.hotkeys.manual_right, 'Toggle')
    ui.set(interface.antiaim.hotkeys.manual_forward, 'Toggle')
    ui.set(interface.antiaim.hotkeys.manual_backward, 'Toggle')

    interface.visuals = {
        enabled_visuals = interface.header.general:checkbox('enable visuals'),
        accent = interface.header.general:label('accent color', {157, 230, 254}),
        secondary = interface.header.general:label('secondary color', {215, 240, 255}),
        vgui = interface.header.general:label('vgui color', {255, 255, 255}), -- 140, 140, 140
        crosshair_indicators = interface.header.general:checkbox('crosshair indicator'),
        crosshair_style = interface.header.general:combobox('style', {'default', 'center', 'emoji'}),
        crosshair_animate_scope = interface.header.general:checkbox('animate on-scope'),
        damage_indicator = interface.header.general:checkbox('damage indicator'),
        lc_status = interface.header.general:checkbox('lc status'),
        window = interface.header.general:checkbox('debug window'),
        window_flag = interface.header.general:checkbox('render user flag'),
        watermark = interface.header.general:checkbox('watermark'),
        watermark_show = interface.header.general:multiselect('show', 'script', 'player', 'time', 'ping'),
        -- shared = interface.header.general:checkbox('shared identity (wip)'),
        bomb_timer = interface.header.general:checkbox('bomb timer'),
        logging = interface.header.general:checkbox('logging'),
        logging_style = interface.header.general:multiselect('style\nvisuals.logging_style', 'console', 'screen'),
        logging_events = interface.header.general:multiselect('events\nvisuals.logging_events', 'damage dealt', 'damage received', 'shots fired', 'shots missed', 'purchases'),
        logging_slider = interface.header.general:slider('slider', 40, 450, 240),
        aspect_ratio = interface.header.fake_lag:checkbox('override aspect ratio'),
        aspect_ratio_slider = interface.header.fake_lag:slider('value', 0, aspect_ratio.steps, aspect_ratio.steps/2, true, '', 1, aspect_ratio.ratio_table),
        thirdperson = interface.header.fake_lag:checkbox('override thirdperson distance'),
        thirdperson_slider = interface.header.fake_lag:slider('distance', 30, 150, 50, true, ''),
        sunlight = interface.header.fake_lag:checkbox('override sunlight'),
        sunlight_x = interface.header.fake_lag:slider('sun x', -180, 180, cvar.cl_csm_rot_x:get_float(), true, '', 0.1),
        sunlight_y = interface.header.fake_lag:slider('sun y', -180, 180, cvar.cl_csm_rot_y:get_float(), true, '', 0.1),
        sunlight_z = interface.header.fake_lag:slider('sun z', -180, 180, cvar.cl_csm_rot_z:get_float(), true, '', 0.1),
        fog = interface.header.general:checkbox('override fog'),
        fog_color = interface.header.general:label('fog color', {180, 200, 255, 255}),
        fog_start = interface.header.general:slider('fog start', 0, 2500, 0, true, ''),
        fog_end = interface.header.general:slider('fog end', 0, 2500, 1200, true, ''),
        fog_density = interface.header.general:slider('fog density', 0, 100, 35, true, '%'),
        viewmodel = interface.header.fake_lag:checkbox('override viewmodel'),
        viewmodel_fov = interface.header.fake_lag:slider('fov', -90, 90, cvar.viewmodel_fov:get_float()),
        viewmodel_x = interface.header.fake_lag:slider('x', -1000, 1000, cvar.viewmodel_offset_x:get_float(), true, '', 0.01),
        viewmodel_y = interface.header.fake_lag:slider('y', -1000, 1000, cvar.viewmodel_offset_y:get_float(), true, '', 0.01),
        viewmodel_z = interface.header.fake_lag:slider('z', -1000, 1000, cvar.viewmodel_offset_z:get_float(), true, '', 0.01),
        opposite_knife_hand = interface.header.fake_lag:checkbox('opposite knife hand'),
        stickman = interface.header.other:checkbox('stickman', {255, 255, 255, 140}),
        zoom_animation = interface.header.other:checkbox('zoom animation'),
        zoom_animation_speed = interface.header.other:slider('speed', 10, 100, 50, true, '%'),
        zoom_animation_value = interface.header.other:slider('strength', 1, 100, 2, true, '%'),
        spawn_zoom = interface.header.other:checkbox('spawn animation'),
        world_damage = interface.header.other:checkbox('world damage'),
        world_damage_type = interface.header.other:combobox('type', {'static', 'dynamic'}),
        enemy_ping_warn = interface.header.other:checkbox('enemy ping warning'),
        enemy_ping_minimum = interface.header.other:slider('minimum latency to show', 10, 100, 80, true, 'ms'),
        grenade_radius = interface.header.other:multiselect('grenade radius', 'smoke', 'molotov'),
        grenade_radius_smoke_color = interface.header.other:label('smoke color', {173, 216, 230, 255}),
        grenade_radius_molotov_color = interface.header.other:label('molotov color', {255, 204, 203, 255}),
        predict_box = interface.header.other:checkbox('predict box'),
        predict_box_show_box = interface.header.other:checkbox('prediction box'),
        predict_box_show_tickbase = interface.header.other:checkbox('tickbase indicator'),
        predict_box_always_show = interface.header.other:checkbox('always show box'),
        predict_box_debug_line = interface.header.other:checkbox('debug line'),
        predict_box_text_color = interface.header.other:label('text color', {255, 45, 45, 255}),
        predict_box_box_color = interface.header.other:label('box color', {47, 117, 221, 255}),
        predict_box_strength = interface.header.other:slider('prediction strength', 1, 16, 8, true, '', 1)
    }

    interface.world = {
        sunlight = interface.visuals.sunlight,
        sunlight_x = interface.visuals.sunlight_x,
        sunlight_y = interface.visuals.sunlight_y,
        sunlight_z = interface.visuals.sunlight_z,
        fog = interface.visuals.fog,
        fog_color = interface.visuals.fog_color,
        fog_start = interface.visuals.fog_start,
        fog_end = interface.visuals.fog_end,
        fog_density = interface.visuals.fog_density
    }

    interface.config = {
        list = interface.header.general:listbox('configs', 300),
        name = (interface.header.general.textbox and interface.header.general:textbox('config name')) or interface.header.general:combobox('config name', ''),
        create_button = interface.header.general:button('create'),
        load_on_startup = interface.header.general:checkbox('load on startup'),
        load_button = interface.header.general:button('load'),
        save_button = interface.header.general:button('save'),
        import_button = interface.header.other:button('import'),
        export_button = interface.header.other:button('export'),
        delete_button = interface.header.other:button('\aff4444ffdelete'),
    }
    
    interface.utility = {
        -- item_anti_crash = interface.header.general:checkbox('\aa5ab55ffchat filter (crash & noise)'),
        clantag = interface.header.general:checkbox('clantag'),
        killsay = interface.header.general:checkbox('balabolka'),
        killsay_modes = interface.header.general:multiselect('modes', 'on kill', 'on death'),
        hitsound = interface.header.general:checkbox('hitsound'),
        buybot = interface.header.general:checkbox('buybot'),
        buybot_primary = interface.header.general:combobox('primary weapon', '-', 'autosnipers', 'scout', 'awp'),
        buybot_primary_fallback = interface.header.general:combobox('primary fallback', '-', 'autosnipers', 'scout', 'awp'),
        buybot_secondary = interface.header.general:combobox('secondary weapon', '-', 'r8 / deagle', 'tec-9 / five-s / cz-75', 'duals', 'p-250'),
        buybot_utility = interface.header.general:multiselect('utility', 'kevlar', 'helmet', 'defuser', 'taser', 'he', 'molotov', 'smoke'),
        auto_r8 = interface.header.general:checkbox('automatic !r8'),
        sync_aimbot_hotkeys = interface.header.general:checkbox('sync aimbot hotkeys'),
        party_mode = interface.header.other:checkbox('party mode'),
        reveal_enemy_team_chat = interface.header.other:checkbox('reveal enemy chat'),
        unlock_fd_speed = interface.header.other:checkbox('unlock fd speed'),
        animation_breakers = interface.header.other:multiselect('animation breakers', 'zero on land', 'earthquake', 'sliding slow motion', 'sliding crouch', 'on ground', 'on air', 'quick peek legs', 'keus scale', 'body lean'),
        on_ground_options = interface.header.other:combobox('on ground', {'frozen', 'walking', 'jitter', 'sliding', 'star'}),
        on_air_options = interface.header.other:combobox('on air', {'frozen', 'walking', 'kinguru'}),
        body_lean_amount = interface.header.other:slider('body lean amount', 0, 100, 50, true, '%'),
        streamer_mode = interface.header.fake_lag:checkbox('streamer mode'),
        streamer_mode_select = interface.header.fake_lag:listbox('images', 200),
        streamer_mode_add = interface.header.fake_lag:button('add'),
        streamer_mode_delete = interface.header.fake_lag:button('\aff4444ffdelete')
    }

    -- interface.utility.item_anti_crash:override(true) -- uncomment later
    interface.visuals.predict_box_show_box:set(true)
    interface.visuals.predict_box_show_tickbase:set(true)
    interface.visuals.predict_box_always_show:set(true)

    interface.hide_references = {
        pui.reference("AA", "Anti-Aimbot angles", "Enabled"),
        { pui.reference("AA", "Anti-Aimbot angles", "Pitch") },
        { pui.reference("AA", "Anti-Aimbot angles", "Yaw") },
        pui.reference("AA", "Anti-Aimbot angles", "Yaw base"),
        { pui.reference("AA", "Anti-Aimbot angles", "Yaw jitter") },
        { pui.reference("AA", "Anti-Aimbot angles", "Body yaw") },
        pui.reference("AA", "Anti-Aimbot angles", "Edge yaw"),
        pui.reference("AA", "Anti-Aimbot angles", "Freestanding body yaw"),
        pui.reference("AA", "Anti-Aimbot angles", "Freestanding"),
        pui.reference("AA", "Anti-Aimbot angles", "Roll"),
        pui.reference("AA", "Fake lag", "Enabled"),
        pui.reference("AA", "Fake lag", "Amount"),
        pui.reference("AA", "Fake lag", "Variance"),
        pui.reference("AA", "Fake lag", "Limit"),
        pui.reference("AA", "Other", "Slow motion"),
        pui.reference("AA", "Other", "Leg movement"),
        { pui.reference("AA", "Other", "Slow motion") },
        pui.reference("AA", "Other", "On shot anti-aim"),
        pui.reference("AA", "Other", "Fake peek")
    }

    interface.hide = function()
        pui.traverse(interface.hide_references, function(element, path)
            if element then
                element:set_visible(false)
            end
        end)
    end

    interface.show = function()
        pui.traverse(interface.hide_references, function(element, path)
            if element then
                element:set_visible(true)
            end
        end)
    end

    interface.update_visibility = function()
        if interface.search:get() == 'other' then
            interface.show()
        else
            interface.hide()
        end
    end

    local naac = function(page)
        -- replaced later
    end

    local function set_element_visible(element, visible)
        if element == nil then
            return
        end

        if type(element) == 'number' then
            ui.set_visible(element, visible)
            return
        end

        element:set_visible(visible)
    end

    interface.setup = function()
        local selection = interface.search:get()
        local groups = {
            home = interface.home,
            kas = interface.kas,
            aimbot = interface.aimbot,
            antiaim = interface.antiaim,
            visuals = interface.visuals,
            utility = interface.utility,
            config = interface.config
        }

        local world_keys = {
            sunlight = true,
            sunlight_x = true,
            sunlight_y = true,
            sunlight_z = true,
            fog = true,
            fog_color = true,
            fog_start = true,
            fog_end = true,
            fog_density = true,
            world_damage = true,
            world_damage_type = true,
            grenade_radius = true,
            grenade_radius_smoke_color = true,
            grenade_radius_molotov_color = true
        }

        local function apply_kas_visibility(element, path)
            local key = path[#path]
            local runtime = interface.kas_runtime or {}
            local enabled = interface.kas.enabled:get()
            local is_idle = runtime.mode == 'idle'
            local is_add = runtime.mode == 'add'
            local is_edit = runtime.mode == 'edit'
            local has_record = runtime.has_record == true
            local supported = runtime.selected_supported == true

            if key == 'enabled' then
                element:set_visible(true)
                return
            end

            if not enabled then
                element:set_visible(false)
                return
            end

            if key == 'player_list' or key == 'status' or key == 'database_status' then
                element:set_visible(true)
                return
            end

            if key == 'add_button' then
                element:set_visible(supported and is_idle and not has_record)
                return
            end

            if key == 'edit_button' or key == 'remove_button' then
                element:set_visible(supported and is_idle and has_record)
                return
            end

            if key == 'view_source' then
                element:set_visible(supported and is_idle and has_record and runtime.show_source == true)
                return
            end

            if key == 'view_alias' then
                element:set_visible(supported and is_idle and has_record and runtime.show_alias == true)
                return
            end

            if key == 'view_alternative' then
                element:set_visible(supported and is_idle and has_record and runtime.show_alternative == true)
                return
            end

            if key == 'view_group' then
                element:set_visible(supported and is_idle and has_record and runtime.show_group == true)
                return
            end

            if key == 'view_note' then
                element:set_visible(supported and is_idle and has_record and runtime.show_note == true)
                return
            end

            if key == 'options' then
                element:set_visible(supported and (is_add or is_edit))
                return
            end

            if key == 'source' then
                element:set_visible(supported and (is_add or is_edit) and runtime.show_source == true)
                return
            end

            if key == 'alias' or key == 'alias_label' then
                element:set_visible(supported and (is_add or is_edit) and runtime.show_alias == true)
                return
            end

            if key == 'alternative' or key == 'alternative_label' then
                element:set_visible(supported and (is_add or is_edit) and runtime.show_alternative == true)
                return
            end

            if key == 'group' or key == 'group_label' then
                element:set_visible(supported and (is_add or is_edit) and runtime.show_group == true)
                return
            end

            if key == 'note' or key == 'note_label' then
                element:set_visible(supported and (is_add or is_edit) and runtime.show_note == true)
                return
            end

            if key == 'add_submit' then
                element:set_visible(supported and is_add)
                return
            end

            if key == 'save_submit' then
                element:set_visible(supported and is_edit)
                return
            end

            element:set_visible(false)
        end

        if interface.home.compatibility_mode:get() then
            interface.search:set_visible(false)

            for _, group in pairs(groups) do
                pui.traverse(group, function(element)
                    set_element_visible(element, false)
                end)
            end

            interface.home.compatibility_mode:set_visible(true)
            return
        else
            interface.search:set_visible(true)
        end

        local visibility_config = {
            home = {
                groups_to_show = { groups.home },
                groups_to_hide = { groups.kas, groups.aimbot, groups.antiaim, groups.visuals, groups.models, groups.utility, groups.config },
                element_visibility_logic = function(element, path)
                    element:set_visible(true)
                end
            },
            players = {
                groups_to_show = { groups.kas },
                groups_to_hide = { groups.home, groups.aimbot, groups.antiaim, groups.visuals, groups.models, groups.utility, groups.config },
                element_visibility_logic = apply_kas_visibility
            },
            kas = {
                groups_to_show = { groups.kas },
                groups_to_hide = { groups.home, groups.aimbot, groups.antiaim, groups.visuals, groups.models, groups.utility, groups.config },
                element_visibility_logic = apply_kas_visibility
            },
            aimbot = {
                groups_to_show = { groups.aimbot },
                groups_to_hide = { groups.home, groups.kas, groups.antiaim, groups.visuals, groups.models, groups.utility, groups.config },
                element_visibility_logic = function(element, path)
                    local key = path[#path]
                    local root = path[1]
                    local enabled = (interface.aimbot.enabled_aimbot:get() == true)
                    local hitchance_enabled = enabled and interface.aimbot.hitchance_override:get()
                    local selected_hitchance_weapon = interface.aimbot.hitchance_override_weapon:get()

                    if root == 'hitchance_override_profiles' then
                        local profile_key = path[2]
                        local profile_field = path[3]
                        local profile = interface.aimbot.hitchance_override_profiles[profile_key]
                        local options = profile and profile.options:get() or {}
                        local is_selected_weapon = (profile_key == selected_hitchance_weapon)

                        if not (hitchance_enabled and is_selected_weapon and profile) then
                            element:set_visible(false)
                            return
                        end

                        if profile_field == 'options' then
                            element:set_visible(true)
                            return
                        end

                        if profile_field == 'in_air' then
                            element:set_visible(type(options) == 'table' and utils.contains(options, 'in air'))
                            return
                        end

                        if profile_field == 'hotkey' then
                            element:set_visible(type(options) == 'table' and utils.contains(options, 'hotkey'))
                            return
                        end

                        if profile_field == 'crouch' then
                            element:set_visible(type(options) == 'table' and utils.contains(options, 'crouch'))
                            return
                        end

                        if profile_field == 'peek_assist' then
                            element:set_visible(type(options) == 'table' and utils.contains(options, 'peek assist'))
                            return
                        end

                        if profile_field == 'no_scope' then
                            element:set_visible(type(options) == 'table' and utils.contains(options, 'no scope'))
                            return
                        end

                        if profile_field == 'no_scope_distance' then
                            element:set_visible(type(options) == 'table' and utils.contains(options, 'no scope'))
                            return
                        end
                    end

                    if key == 'enabled_aimbot' then
                        element:set_visible(true)
                    elseif key == 'resolver_mode' then
                        element:set_visible(enabled and interface.aimbot.enabled_resolver_tweaks:get())
                    elseif key == 'noscope_distance' then
                        element:set_visible(enabled)
                    elseif key == 'noscope_weapons' then
                        element:set_visible(enabled and interface.aimbot.noscope_distance:get())
                    elseif key == 'hitchance_override' then
                        element:set_visible(enabled)
                    elseif key == 'hitchance_override_hotkey' or key == 'hitchance_override_weapon' then
                        element:set_visible(hitchance_enabled)
                    elseif key == 'noscope_distance_autosnipers' then
                        local v = (interface.aimbot.noscope_weapons:get() or {})
                        local has_auto = (type(v) == 'table') and utils.contains(v, 'autosnipers')
                        element:set_visible(enabled and interface.aimbot.noscope_distance:get() and has_auto)
                    elseif key == 'noscope_distance_scout' then
                        local v = (interface.aimbot.noscope_weapons:get() or {})
                        local has_scout = (type(v) == 'table') and utils.contains(v, 'scout')
                        element:set_visible(enabled and interface.aimbot.noscope_distance:get() and has_scout)
                    elseif key == 'noscope_distance_awp' then
                        local v = (interface.aimbot.noscope_weapons:get() or {})
                        local has_awp = (type(v) == 'table') and utils.contains(v, 'awp')
                        element:set_visible(enabled and interface.aimbot.noscope_distance:get() and has_awp)
                    elseif key == 'dormant_hitchance' or key == 'dormant_damage' then
                        element:set_visible(enabled and interface.aimbot.dormant_enabled:get())
                    else
                        element:set_visible(enabled)
                    end
                end
            },
            antiaim = {
                groups_to_show = { groups.antiaim },
                groups_to_hide = { groups.home, groups.kas, groups.aimbot, groups.visuals, groups.models, groups.utility, groups.config },
                element_visibility_logic = function(element, path)
                    local key = path[#path]
                    local root = path[1]
                    local enabled = interface.antiaim.enabled_antiaim:get()
                    local selected_state = interface.antiaim.builder.state:get()

                    if key == 'enabled_antiaim' then
                        element:set_visible(true)
                        return
                    end

                    if not enabled then
                        element:set_visible(false)
                        return
                    end

                    if root == 'builder' and key == 'state' then
                        element:set_visible(true)
                        return
                    end

                    if root == 'builder' and path[2] == 'profiles' then
                        local state_key = path[3]
                        local field = path[4]
                        local profile = interface.antiaim.builder.profiles[state_key]
                        local profile_enabled = state_key == 'default' or (profile ~= nil and profile.enabled ~= nil and profile.enabled:get())

                        if state_key ~= selected_state or profile == nil then
                            element:set_visible(false)
                            return
                        end

                        if field == 'enabled' then
                            element:set_visible(state_key ~= 'default')
                            return
                        end

                        if not profile_enabled then
                            element:set_visible(false)
                            return
                        end

                        if field == 'jitter_offset' or field == 'jitter_random' then
                            element:set_visible(profile.yaw_jitter:get() ~= 'off')
                            return
                        end

                        if field == 'body_yaw_offset' then
                            local body_yaw = profile.body_yaw:get()
                            element:set_visible(body_yaw == 'static' or body_yaw == 'jitter')
                            return
                        end

                        if field == 'freestanding_body_yaw' then
                            local body_yaw = profile.body_yaw:get()
                            element:set_visible(body_yaw ~= 'off' and body_yaw ~= 'jitter')
                            return
                        end

                        if field == 'delay_from' or field == 'delay_to' or field == 'invert_chance' then
                            element:set_visible(profile.body_yaw:get() == 'jitter')
                            return
                        end

                        element:set_visible(true)
                        return
                    end

                    if root == 'fake_lag' then
                        if key == 'triggers' then
                            element:set_visible(utils.multiselect_has(interface.antiaim.fake_lag.extensions:get(), 'force break lc'))
                            return
                        end

                        if key == 'safe_head_triggers' then
                            element:set_visible(utils.multiselect_has(interface.antiaim.fake_lag.extensions:get(), 'safe head'))
                            return
                        end

                        if key == 'break_self_backtrack_mode' then
                            element:set_visible(utils.multiselect_has(interface.antiaim.fake_lag.extensions:get(), 'break self backtrack'))
                            return
                        end

                        if key == 'vigilant_controls' then
                            element:set_visible(utils.multiselect_has(interface.antiaim.fake_lag.extensions:get(), 'vigilant lagcomp breaking'))
                            return
                        end

                        if key == 'correct_lag_exploit_type' then
                            element:set_visible(utils.multiselect_has(interface.antiaim.fake_lag.extensions:get(), 'correct lag on exploit'))
                            return
                        end

                        element:set_visible(true)
                        return
                    end

                    if root == 'hotkeys' then
                        if key == 'freestanding' or key == 'manual_yaw' then
                            element:set_visible(true)
                            return
                        end

                        if key == 'freestanding_disablers' then
                            element:set_visible(interface.antiaim.hotkeys.freestanding:get())
                            return
                        end

                        if key == 'manual_modifier' or key == 'manual_left' or key == 'manual_right' or key == 'manual_forward' or key == 'manual_backward' then
                            element:set_visible(interface.antiaim.hotkeys.manual_yaw:get())
                            return
                        end
                    end

                    element:set_visible(true)
                end
            },
            visuals = {
                groups_to_show = { groups.visuals },
                groups_to_hide = { groups.home, groups.kas, groups.aimbot, groups.antiaim, groups.models, groups.utility, groups.config },
                element_visibility_logic = function(element, path)
                    local key = path[#path]
                    local visuals_enabled = interface.visuals.enabled_visuals:get()

                    if key == 'enabled_visuals' then
                        element:set_visible(true)
                        return
                    end

                    if not visuals_enabled then
                        element:set_visible(false)
                        return
                    end

                    if world_keys[key] then
                        element:set_visible(false)
                        return
                    end

                    if key == 'crosshair_style' then
                        element:set_visible(interface.visuals.crosshair_indicators:get())
                        return
                    end

                    if key == 'watermark_show' then
                        element:set_visible(interface.visuals.watermark:get())
                        return
                    end

                    if key == 'window_flag' then
                        element:set_visible(interface.visuals.window:get())
                        return
                    end

                    if key == 'crosshair_animate_scope' then
                        local style = interface.visuals.crosshair_style:get()
                        local show_anim = interface.visuals.crosshair_indicators:get()
                            and (style == 'center' or style == 'emoji')
                        element:set_visible(show_anim)
                        return
                    end

                    if key == 'enemy_ping_minimum' then
                        element:set_visible(interface.visuals.enemy_ping_warn:get())
                        return
                    end

                    if key == 'aspect_ratio_slider' then
                        element:set_visible(interface.visuals.aspect_ratio:get())
                        return
                    end

                    if key == 'thirdperson_slider' then
                        element:set_visible(interface.visuals.thirdperson:get())
                        return
                    end

                    if key == 'viewmodel_fov' or key == 'viewmodel_x' or key == 'viewmodel_y' or key == 'viewmodel_z' or key == 'opposite_knife_hand' then
                        element:set_visible(interface.visuals.viewmodel:get())
                        return
                    end

                    if key == 'zoom_animation_speed' or key == 'zoom_animation_value' then
                        element:set_visible(interface.visuals.zoom_animation:get())
                        return
                    end

                    if key == 'predict_box_show_box' or key == 'predict_box_show_tickbase' or key == 'predict_box_always_show' or key == 'predict_box_debug_line' or key == 'predict_box_text_color' or key == 'predict_box_box_color' or key == 'predict_box_strength' then
                        element:set_visible(interface.visuals.predict_box:get())
                        return
                    end

                    if key == 'logging_style' or key == 'logging_events' then
                        element:set_visible(interface.visuals.logging:get())
                        return
                    end

                    element:set_visible(true)
                end,
                post_visibility_logic = function()
                    local visuals_enabled = interface.visuals.enabled_visuals:get()
                    
                    local logging_enabled = visuals_enabled and interface.visuals.logging:get() == true
                    interface.visuals.logging_style:set_visible(logging_enabled)
                    interface.visuals.logging_events:set_visible(logging_enabled)
                    interface.visuals.logging_slider:set_visible(false)
                end
            },
            world = {
                groups_to_show = { groups.visuals },
                groups_to_hide = { groups.home, groups.kas, groups.aimbot, groups.antiaim, groups.models, groups.utility, groups.config },
                element_visibility_logic = function(element, path)
                    local key = path[#path]
                    local visuals_enabled = interface.visuals.enabled_visuals:get()

                    if not world_keys[key] then
                        element:set_visible(false)
                        return
                    end

                    if not visuals_enabled then
                        element:set_visible(false)
                        return
                    end

                    if key == 'sunlight_x' or key == 'sunlight_y' or key == 'sunlight_z' then
                        element:set_visible(interface.visuals.sunlight:get())
                        return
                    end

                    if key == 'fog_color' or key == 'fog_start' or key == 'fog_end' or key == 'fog_density' then
                        element:set_visible(interface.visuals.fog:get())
                        return
                    end

                    if key == 'world_damage_type' then
                        element:set_visible(interface.visuals.world_damage:get())
                        return
                    end

                    if key == 'grenade_radius_molotov_color' then
                        local grenades = interface.visuals.grenade_radius:get() or {}
                        element:set_visible(utils.contains(grenades, 'molotov'))
                        return
                    end

                    if key == 'grenade_radius_smoke_color' then
                        local grenades = interface.visuals.grenade_radius:get() or {}
                        element:set_visible(utils.contains(grenades, 'smoke'))
                        return
                    end

                    element:set_visible(true)
                end
            },
            utility = {
                groups_to_show = { groups.utility },
                groups_to_hide = { groups.home, groups.kas, groups.aimbot, groups.antiaim, groups.visuals, groups.models, groups.config },
                element_visibility_logic = function(element, path)
                    local key = path[#path]

                        if key == "buybot_primary" or key == "buybot_primary_fallback" or key == "buybot_secondary" or key == "buybot_utility" then
                            element:set_visible(interface.utility.buybot:get())
                            return
                        end

                        if key == "killsay_modes" then
                            element:set_visible(interface.utility.killsay:get())
                            return
                        end

                        if key == "body_lean_amount" then
                            local breakers_enabled = interface.utility.animation_breakers:get() or {}
                            element:set_visible(utils.contains(breakers_enabled, "body lean"))
                            return
                        end

                        if key == "on_ground_options" then
                            local breakers_enabled = interface.utility.animation_breakers:get() or {}
                            element:set_visible(utils.contains(breakers_enabled, "on ground"))
                            return
                        end

                        if key == "on_air_options" then
                            local breakers_enabled = interface.utility.animation_breakers:get() or {}
                            element:set_visible(utils.contains(breakers_enabled, "on air"))
                            return
                        end

                        if key == "streamer_mode_select" or key == "streamer_mode_add" then
                            local enabled = interface.utility.streamer_mode:get()
                            element:set_visible(enabled)
                            return
                        end

                        if key == "streamer_mode_delete" then
                            local enabled = interface.utility.streamer_mode:get()
                            local sel = streamer_images and streamer_images.get_selected_name and streamer_images.get_selected_name() or nil
                            local is_custom = sel ~= nil and (not streamer_images.is_builtin or not streamer_images.is_builtin(sel))
                            element:set_visible(enabled and is_custom)
                            return
                        end

                        element:set_visible(true)
                end
            },
            config = {
                groups_to_show = { groups.config },
                groups_to_hide = { groups.home, groups.kas, groups.aimbot, groups.antiaim, groups.visuals, groups.models, groups.utility },
                element_visibility_logic = function(element, path)
                    element:set_visible(true)
                end,
                post_visibility_logic = function()
                    -- we'll handle this later
                end
            },
            other = {
                groups_to_show = {},
                groups_to_hide = { groups.home, groups.kas, groups.aimbot, groups.antiaim, groups.visuals, groups.models, groups.utility, groups.config }
            },
            default = {
                groups_to_show = {},
                groups_to_hide = { groups.home, groups.kas, groups.aimbot, groups.antiaim, groups.visuals, groups.models, groups.utility, groups.config }
            }
        }

        local config = visibility_config[selection] or visibility_config.default

        for _, group in pairs(config.groups_to_show or {}) do
            if group then
                pui.traverse(group, function(element, path)
                    local proxy = element
                    if type(element) == 'number' then
                        proxy = {
                            set_visible = function(_, visible)
                                ui.set_visible(element, visible)
                            end
                        }
                    end

                    if config.element_visibility_logic then
                        config.element_visibility_logic(proxy, path)
                    else
                        set_element_visible(element, true)
                    end
                end)
            end
        end

        for _, group in pairs(config.groups_to_hide or {}) do
            if group then
                pui.traverse(group, function(element, path)
                    set_element_visible(element, false)
                end)
            end
        end

        if config.post_visibility_logic then
            config.post_visibility_logic()
        end
    end
end

interface.update_visibility()
interface.setup()

client.set_event_callback('paint_ui', function()
     interface.update_visibility()
     interface.setup()
end)

client.set_event_callback('shutdown', interface.show)

interface.visuals.thirdperson_slider:set_callback(function()
    client.exec("cam_idealdist " .. interface.visuals.thirdperson_slider:get())
end)
--@endregion

--@region: vgui
vgui = {} do
    local engine_client = ffi.cast(ffi.typeof('void***'), client.create_interface('engine.dll', 'VEngineClient014'))
    local console_is_visible = ffi.cast(ffi.typeof('bool(__thiscall*)(void*)'), engine_client[0][11])

    local materials = {
        'vgui_white',
        'vgui/hud/800corner1',
        'vgui/hud/800corner2', 
        'vgui/hud/800corner3',
        'vgui/hud/800corner4',
        'vgui/servers/browser_header',
        'vgui/servers/browser_background',
        'vgui/servers/serverbrowser_listpanel',
        'vgui/servers/tab_active',
        'vgui/servers/tab_inactive'
    }
    
    local material_cache = {}
    for _, mat_name in ipairs(materials) do
        local material = materialsystem.find_material(mat_name)
        if material then
            material_cache[mat_name] = material
        end
    end
    
    local last_r, last_g, last_b, last_a = 0, 0, 0, 0
    
    client.set_event_callback('paint', function()
        local r, g, b, a = unpack(interface.visuals.vgui.color.value)

        if r ~= last_r or g ~= last_g or b ~= last_b or a ~= last_a then
            for _, material in pairs(material_cache) do
                material:alpha_modulate(a)
                material:color_modulate(r, g, b)
            end
            
            last_r, last_g, last_b, last_a = r, g, b, a
        end
    end)

    client.set_event_callback('shutdown', function()
        for _, material in pairs(material_cache) do
            material:alpha_modulate(255)
            material:color_modulate(255, 255, 255)
        end
    end)
end
--@endregion

--@region: custom print
local ConsolePrint = function(label)
    local r, g, b = unpack(interface.visuals.accent.color.value)
    client.color_log(r, g, b, label .. "\0")
end

local log = {}

local drawlog = function(prefix, text)
    local r, g, b = unpack(interface.visuals.accent.color.value)
    log[#log + 1] = {
        text,
        255,
        math.floor(globals.curtime())
    }
    client.color_log(r, g, b, prefix .. "\n\0")
end

local function logMessage(prefix, extra, message)
    message = message or extra
    local r, g, b = unpack(interface.visuals.accent.color.value)
    local fullMessage = prefix .. " " .. message .. "\n\0"
    client.color_log(r, g, b, prefix .. " \0")
    client.color_log(255, 255, 255, message .. "\n\0")
end

local function logPlain(message)
    local r, g, b = unpack(interface.visuals.accent.color.value)
    client.color_log(255, 255, 255, message .. "\n\0")
end
--@endregion

--@region: logging with arguments
local function argLogWithPrefix(prefix, fmt, ...)
    local white = {255, 255, 255}
    local gray  = {212, 212, 212}
    local args  = { ... }
    local segments = {}
    local pos = 1
    local arg_index = 1

    local r, g, b = unpack(interface.visuals.accent.color.value)
    
    client.color_log(r, g, b, prefix .. " \0")

    while true do
        local s, e, conv = string.find(fmt, "(%%[%-%+%.%d]*[sdf])", pos)
        if not s then
            table.insert(segments, { text = fmt:sub(pos), white = false })
            break
        end
        if s > pos then
            table.insert(segments, { text = fmt:sub(pos, s - 1), white = false })
        end
        local argVal = args[arg_index]
        arg_index = arg_index + 1
        local formattedArg = string.format(conv, argVal)
        table.insert(segments, { text = formattedArg, white = true })
        pos = e + 1
    end

    for i, seg in ipairs(segments) do
        local ending = (i == #segments) and "\n\0" or "\0"
        if seg.white then
            client.color_log(white[1], white[2], white[3], seg.text .. ending)
        else
            client.color_log(gray[1], gray[2], gray[3], seg.text .. ending)
        end
    end
end

local function argLog(fmt, ...)
    argLogWithPrefix("noctua ·", fmt, ...)
end
--@endregion

--@region: reference
reference = {} do
    reference.rage = {
        binds = {
            weapon_type = pui.reference('rage', 'weapon type', 'weapon type'),
            enabled = { pui.reference('rage', 'aimbot', 'enabled') },
            stop = { pui.reference('rage', 'aimbot', 'quick stop') },
            minimum_damage = pui.reference('rage', 'aimbot', 'minimum damage'),
            minimum_damage_override = { pui.reference('rage', 'aimbot', 'minimum damage override') },
            minimum_hitchance = pui.reference('rage', 'aimbot', 'minimum hit chance'),
            double_tap = { pui.reference('rage', 'aimbot', 'double tap') },
            body_aim = pui.reference('rage', 'aimbot', 'force body aim'),
            safe_point = pui.reference('rage', 'aimbot', 'force safe point'),
            double_tap_fl = pui.reference('rage', 'aimbot', 'double tap fake lag limit'),
            ps = { pui.reference('misc', 'miscellaneous', 'ping spike') },
            quickpeek = { pui.reference('rage', 'other', 'quick peek assist') },
            quickpeekm = { pui.reference('rage', 'other', 'quick peek assist mode') },
            fakeduck = { pui.reference('rage', 'other', 'duck peek assist') },
            on_shot_anti_aim = { pui.reference('aa', 'other', 'on shot anti-aim') },
            usercmd = pui.reference('misc', 'settings', 'sv_maxusrcmdprocessticks2')
        }
    }
    reference.antiaim = {
        angles = {
            enabled = pui.reference('aa', 'anti-aimbot angles', 'enabled'),
            pitch = { pui.reference('aa', 'anti-aimbot angles', 'pitch') },
            roll = pui.reference('aa', 'anti-aimbot angles', 'roll'),
            yaw_base = pui.reference('aa', 'anti-aimbot angles', 'yaw base'),
            yaw = { pui.reference('aa', 'anti-aimbot angles', 'yaw') },
            freestanding_body_yaw = pui.reference('aa', 'anti-aimbot angles', 'freestanding body yaw'),
            edge_yaw = pui.reference('aa', 'anti-aimbot angles', 'edge yaw'),
            yaw_jitter = { pui.reference('aa', 'anti-aimbot angles', 'yaw jitter') },
            body_yaw = { pui.reference('aa', 'anti-aimbot angles', 'body yaw') },
            freestanding = pui.reference('aa', 'anti-aimbot angles', 'freestanding')
        },
        fakelag = {
            on = { pui.reference('aa', 'fake lag', 'enabled') },
            amount = pui.reference('aa', 'fake lag', 'amount'),
            variance = pui.reference('aa', 'fake lag', 'variance'),
            limit = pui.reference('aa', 'fake lag', 'limit')
        },
        other = {
            slide = { pui.reference('aa', 'other', 'slow motion') },
            slow_motion = { pui.reference('aa', 'other', 'slow motion') },
            fake_peek = { pui.reference('aa', 'other', 'fake peek') },
            leg_movement = pui.reference('aa', 'other', 'leg movement')
        }
    }
    reference.visuals = {
        effects = {
            thirdperson = { pui.reference('visuals', 'effects', 'force third person (alive)') },
            scope = pui.reference('visuals', 'effects', 'remove scope overlay'),
            remove_fog = pui.reference('visuals', 'effects', 'remove fog'),
            dpi = pui.reference('misc', 'settings', 'dpi scale'),
            clrmenu = pui.reference('misc', 'settings', 'menu color'),
            output = pui.reference('misc', 'miscellaneous', 'draw console output'),
            name = { pui.reference('visuals', 'player esp', 'name') },
            ping = { pui.reference('misc', 'miscellaneous', 'ping spike') },
            fov = pui.reference('misc', 'miscellaneous', 'override fov'),
            clantag = pui.reference('misc', 'miscellaneous', 'clan tag spammer'),
            dormantesp = pui.reference('visuals', 'player esp', 'dormant'),
            zfov = pui.reference('misc', 'miscellaneous', 'override zoom fov'),
            edge_jump = { pui.reference('misc', 'movement', 'jump at edge') },
        }
    }
end
--@endregion

--@region: player_list
player_list = {} do
    local SAFE_POINT_OVERRIDE_DEFAULT = "-"
    local PREFER_BODY_AIM_OVERRIDE_DEFAULT = "-"

    local function get_checkbox(field, default)
        return function(self, ent)
            if not ent then
                return default
            end

            local value = plist.get(ent, field)
            if value == nil then
                return default
            end

            return value
        end
    end

    local function set_checkbox(self, ent, cache_key, field, val)
        if not ent or self.values[cache_key][ent] == val then
            return
        end

        plist.set(ent, field, val)
        self.values[cache_key][ent] = val
    end

    local function update_override(self, ent, cache_key, field, val)
        if not ent or self.values[cache_key][ent] == val then
            return
        end

        plist.set(ent, field, val)
        self.values[cache_key][ent] = val
        client.update_player_list()
    end

    player_list.reset = {
        Whitelist = {},
        SharedESPUpdates = {},
        DisableVisuals = {},
        HighPriority = {},
        ForceBodyYaw = {},
        ForceBodyYawCheckbox = {},
        CorrectionActive = {},
        ForcePitch = {},
        ForcePitchCheckbox = {},
        SafePointOverride = {},
        PreferBodyAimOverride = {}
    }
    
    player_list.values = {
        Whitelist = {},
        SharedESPUpdates = {},
        DisableVisuals = {},
        HighPriority = {},
        ForceBodyYaw = {},
        ForceBodyYawCheckbox = {},
        CorrectionActive = {},
        ForcePitch = {},
        ForcePitchCheckbox = {},
        SafePointOverride = {},
        PreferBodyAimOverride = {}
    }
    
    player_list.ref = {
        selected_player = ui.reference('PLAYERS', 'Players', 'Player list', false)
    }
    
    player_list.GetPlayer = function(self)
        return ui.get(self.ref.selected_player)
    end

    player_list.GetWhitelist = get_checkbox('Add to whitelist', false)

    player_list.SetWhitelist = function(self, ent, val)
        set_checkbox(self, ent, 'Whitelist', 'Add to whitelist', val)
    end

    player_list.GetSharedESPUpdates = get_checkbox('Allow shared ESP updates', false)

    player_list.SetSharedESPUpdates = function(self, ent, val)
        set_checkbox(self, ent, 'SharedESPUpdates', 'Allow shared ESP updates', val)
    end

    player_list.GetDisableVisuals = get_checkbox('Disable visuals', false)

    player_list.SetDisableVisuals = function(self, ent, val)
        set_checkbox(self, ent, 'DisableVisuals', 'Disable visuals', val)
    end

    player_list.GetHighPriority = get_checkbox('High priority', false)

    player_list.SetHighPriority = function(self, ent, val)
        set_checkbox(self, ent, 'HighPriority', 'High priority', val)
    end
    
    player_list.GetCorrection = get_checkbox('Correction active', false)
    
    player_list.SetCorrection = function(self, ent, val)
        set_checkbox(self, ent, 'CorrectionActive', 'Correction active', val)
    end
    
    player_list.SetForceBodyYawCheckbox = function(self, ent, val)
        if not ent or self.values.ForceBodyYawCheckbox[ent] == val then
            return
        end
        plist.set(ent, 'Force body yaw', val)
        self.values.ForceBodyYawCheckbox[ent] = val
    end
    
    player_list.SetBodyYaw = function(self, ent, val)
        if not ent or self.values.ForceBodyYaw[ent] == val then
            return
        end
        plist.set(ent, 'Force body yaw value', val)
        self.values.ForceBodyYaw[ent] = val
    end
    
    player_list.GetForcePitch = function(self, ent)
        return plist.get(ent, 'Force pitch value')
    end
    
    player_list.SetForcePitch = function(self, ent, val)
        if not ent or self.values.ForcePitch[ent] == val then
            return
        end
        plist.set(ent, 'Force pitch value', val)
        self.values.ForcePitch[ent] = val
    end
    
    player_list.GetForcePitchCheckbox = function(self, ent)
        return plist.get(ent, 'Force pitch')
    end
    
    player_list.SetForcePitchCheckbox = function(self, ent, val)
        if not ent or self.values.ForcePitchCheckbox[ent] == val then
            return
        end
        plist.set(ent, 'Force pitch', val)
        self.values.ForcePitchCheckbox[ent] = val
    end
    
    player_list.GetSafePointOverride = function(self, ent)
        if not ent then
            return SAFE_POINT_OVERRIDE_DEFAULT
        end

        return plist.get(ent, 'Override safe point')
    end
    
    player_list.SetSafePointOverride = function(self, ent, val)
        update_override(self, ent, 'SafePointOverride', 'Override safe point', val)
    end
    
    player_list.GetPreferBodyAimOverride = function(self, ent)
        if not ent then
            return PREFER_BODY_AIM_OVERRIDE_DEFAULT
        end

        return plist.get(ent, 'Override prefer body aim')
    end

    player_list.SetPreferBodyAimOverride = function(self, ent, val)
        update_override(self, ent, 'PreferBodyAimOverride', 'Override prefer body aim', val)
    end
end
-- @endregion

-- @region: ffi
ffi.cdef([[
    typedef struct {
        float x;
        float y;
        float z;
    } vector_t;

    typedef struct {
        char pad0[0x60]; // 0x00
        void* pEntity; // 0x60
        void* pActiveWeapon; // 0x64
        void* pLastActiveWeapon; // 0x68
        float flLastUpdateTime; // 0x6C
        int iLastUpdateFrame; // 0x70
        float flLastUpdateIncrement; // 0x74
        float flEyeYaw; // 0x78
        float flEyePitch; // 0x7C
        float flGoalFeetYaw; // 0x80
        float flLastFeetYaw; // 0x84
        float flMoveYaw; // 0x88
        float flLastMoveYaw; // 0x8C // changes when moving/jumping/hitting ground
        float flLeanAmount; // 0x90
        char pad1[0x4]; // 0x94
        float flFeetCycle; // 0x98 0 to 1
        float flMoveWeight; // 0x9C 0 to 1
        float flMoveWeightSmoothed; // 0xA0
        float flDuckAmount; // 0xA4
        float flHitGroundCycle; // 0xA8
        float flRecrouchWeight; // 0xAC
        vector_t vecOrigin; // 0xB0
        vector_t vecLastOrigin; // 0xBC
        vector_t vecVelocity; // 0xC8
        vector_t vecVelocityNormalized; // 0xD4
        vector_t vecVelocityNormalizedNonZero; // 0xE0
        vector_t flVelocityLenght2D; // 0xEC
        float flJumpFallVelocity; // 0xF0
        float flSpeedNormalized; // 0xF4 // clamped velocity from 0 to 1
        float m_flFeetSpeedForwardsOrSideWays; // 0xF8
        float m_flFeetSpeedUnknownForwardOrSideways; // 0xFC
        float flRunningSpeed; // 0xF8
        float flDuckingSpeed; // 0xFC
        float flDurationMoving; // 0x100
        float flDurationStill; // 0x104
        bool bOnGround; // 0x108
        bool bHitGroundAnimation; // 0x109
        char pad2[0x2]; // 0x10A
        float flNextLowerBodyYawUpdateTime; // 0x10C
        float flDurationInAir; // 0x110
        float flLeftGroundHeight; // 0x114
        float m_flStopToFullRunningFraction; // 0x116
        float flHitGroundWeight; // 0x118 // from 0 to 1, is 1 when standing
        float flWalkToRunTransition; // 0x11C // from 0 to 1, doesnt change when walking or crouching, only running
        char pad3[0x4]; // 0x120
        float flAffectedFraction; // 0x124 // affected while jumping and running, or when just jumping, 0 to 1
        char pad4[0x208]; // 0x128
        float flMinBodyYaw; // 0x330
        float flMaxBodyYaw; // 0x334
        float flMinPitch; // 0x338
        float flMaxPitch; // 0x33C
        int iAnimsetVersion; // 0x340
    } CPlayer_Animation_State;

    typedef void* (__thiscall* get_client_entity_t)(void*, int);

    typedef struct {
        float m_anim_time;
        float m_fade_out_time;
        int m_flags;
        int m_activity;
        int m_priority;
        int m_order;
        int m_sequence;
        float m_prev_cycle;
        float m_weight;
        float m_weight_delta_rate;
        float m_playback_rate;
        float m_cycle;
        void* m_owner;
        int m_bits;
    } C_AnimationLayer;

    typedef uintptr_t (__thiscall* GetClientEntityHandle_4242425_t)(void*, uintptr_t);

    typedef struct {
        uint64_t version;
        uint64_t __xuid;
        char __name[128];
        int userid;
        char __guid[33];
        unsigned int friendsID;
        char __friendsName[128];
        bool __fakeplayer;
        bool __ishltv;
        unsigned int __custom_files[4];
        unsigned char files_downloaded;
    } PlayerInfo_t;
]])

ffi_utils = {} do
    local PlayerInfo_t = ffi.typeof("PlayerInfo_t")

    local fallback = {
        xuid = function(self) return string.match(tostring(self.__xuid), "%d+") end,
        name = function(self) return ffi.string(self.__name, 128) end,
        guid = function(self) return ffi.string(self.__guid, 33) end,
        friends_name = function(self) return ffi.string(self.__friendsName, 128) end,
        is_fake_client = function(self) return self.__fakeplayer end,
        is_hltv = function(self) return self.__ishltv end,

        custom_files = function(self)
            local custom_files = self.__custom_files
            return { custom_files[0], custom_files[1], custom_files[2], custom_files[3] }
        end
    }

    local PlayerInfo_t_mt = {
        __index = function(self, key)
            local fallback_fn = fallback[key]
            if fallback_fn then
                return fallback_fn(self)
            end
            return nil
        end
    }

    ffi.metatype(PlayerInfo_t, PlayerInfo_t_mt)

    ffi_utils.native_GetPlayerInfo = vtable_bind("engine.dll", "VEngineClient014", 8, "bool(__thiscall*)(void*, int, PlayerInfo_t*)")
end
--@endregion

--@region : FFI Helpers
ffi_helpers = {
    entity_list_ptr = ffi.cast("void***", client.create_interface("client.dll", "VClientEntityList003")),
    rawientitylist = client.create_interface("client.dll", "VClientEntityList003") or error("VClientEntityList003 wasnt found", 2),
    ientitylist = nil,
    get_client_entity_fn = nil,
    get_client_entity_by_handle_fn = nil,
    get_client_entity = nil,

    init = function(self)
        self.ientitylist = ffi.cast(ffi.typeof("void***"), self.rawientitylist) or error("rawientitylist is nil", 2)
        self.get_client_entity_fn = ffi.cast("GetClientEntityHandle_4242425_t", self.entity_list_ptr[0][3]) or error("get_client_entity_fn is nil", 2)
        self.get_client_entity_by_handle_fn = ffi.cast("GetClientEntityHandle_4242425_t", self.entity_list_ptr[0][4]) or error("get_client_entity_by_handle_fn is nil", 2)
        self.get_client_entity = ffi.cast("get_client_entity_t", self.ientitylist[0][3]) or error("get_client_entity is nil", 2)
    end
}

ffi_helpers:init()
--@endregion

--@region: player
player = {} do
    player.get_address = function(idx)
        return ffi_helpers.get_client_entity(ffi_helpers.ientitylist, idx)
    end

    player.get_animstate = function(idx)
        local addr = ffi_helpers.get_client_entity(ffi_helpers.ientitylist, idx)
        if not addr then return end
        return ffi.cast("CPlayer_Animation_State**", ffi.cast('uintptr_t', addr) + 0x9960)[0]
    end

    player.get_animlayer = function(idx)
        local addr = ffi_helpers.get_client_entity(ffi_helpers.ientitylist, idx)
        if not addr then return end
        return ffi.cast("C_AnimationLayer**", ffi.cast('uintptr_t', addr) + 0x2990)[0]
    end

    player.get_velocity = function(idx)
        local vel_x = entity.get_prop(idx, "m_vecVelocity[0]") or 0
        local vel_y = entity.get_prop(idx, "m_vecVelocity[1]") or 0
        local vel_z = entity.get_prop(idx, "m_vecVelocity[2]") or 0
        local vel_2d = math.sqrt(vel_x ^ 2 + vel_y ^ 2)
        return vel_x, vel_y, vel_z, vel_2d
    end

    player.get_origin_vec = function(idx)
        local origin_x, origin_y, origin_z = entity.get_origin(idx)
        if not origin_x then
            return nil
        end

        return {
            x = origin_x,
            y = origin_y,
            z = origin_z
        }
    end

    player.get_velocity_vec = function(idx)
        local vel_x, vel_y, vel_z, vel_2d = player.get_velocity(idx)
        return {
            x = vel_x,
            y = vel_y,
            z = vel_z
        }, vel_2d
    end

    player.get_weapon_max_speed = function(idx)
        local weapon = entity.get_player_weapon(idx)
        local weapon_info = weapon and csgo_weapons(weapon)
        if not weapon_info then
            return 250
        end

        local scoped = entity.get_prop(idx, "m_bIsScoped") == 1
        return (scoped and weapon_info.max_player_speed_alt or weapon_info.max_player_speed) or 250
    end

    player.resolve_effective_speed = function(raw_speed, measured_speed, previous_speed)
        if measured_speed and measured_speed > 0 and measured_speed < 600 then
            return measured_speed
        end

        if raw_speed > 1000 and previous_speed and previous_speed < 600 then
            return previous_speed
        end

        if raw_speed > 0 and raw_speed < 600 then
            return raw_speed
        end

        return previous_speed or raw_speed
    end

    player.apply_friction = function(velocity, stop_speed, friction, surface_friction, tick_interval)
        local speed = math.sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
        if speed < 0.1 then
            velocity.x = 0
            velocity.y = 0
            return
        end

        local control = speed < stop_speed and stop_speed or speed
        local drop = control * friction * surface_friction * tick_interval
        local new_speed = speed - drop

        if new_speed < 0 then
            new_speed = 0
        end

        if new_speed ~= speed then
            local scale = new_speed / speed
            velocity.x = velocity.x * scale
            velocity.y = velocity.y * scale
        end
    end

    player.accelerate = function(velocity, wishdir_x, wishdir_y, wishspeed, accel, surface_friction, tick_interval)
        local current_speed = (velocity.x * wishdir_x) + (velocity.y * wishdir_y)
        local add_speed = wishspeed - current_speed
        if add_speed <= 0 then
            return
        end

        local accel_speed = accel * tick_interval * wishspeed * surface_friction
        if accel_speed > add_speed then
            accel_speed = add_speed
        end

        velocity.x = velocity.x + (accel_speed * wishdir_x)
        velocity.y = velocity.y + (accel_speed * wishdir_y)
    end

    player.extrapolate_position = function(idx, origin, flags, ticks)
        local tick_interval = globals.tickinterval()
        local gravity_step = cvar.sv_gravity:get_float() * tick_interval
        local jump_step = cvar.sv_jump_impulse:get_float() * tick_interval
        local accelerate_cvar = cvar.sv_accelerate:get_float()
        local airaccelerate_cvar = cvar.sv_airaccelerate:get_float()
        local friction_cvar = cvar.sv_friction:get_float()
        local stop_speed = cvar.sv_stopspeed:get_float()
        local velocity = player.get_velocity_vec(idx)
        local surface_friction = entity.get_prop(idx, "m_surfaceFriction") or 1
        local on_ground = bit.band(flags or 0, 1) == 1
        local gravity = 0
        local position = {
            x = origin.x,
            y = origin.y,
            z = origin.z
        }
        local max_speed = player.get_weapon_max_speed(idx)

        if not on_ground then
            gravity = -gravity_step
        elseif velocity.z > 1 then
            gravity = jump_step
        end

        for _ = 1, ticks do
            local previous = {
                x = position.x,
                y = position.y,
                z = position.z
            }
            local horizontal_speed = math.sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))

            if horizontal_speed > 0.1 then
                local wishdir_x = velocity.x / horizontal_speed
                local wishdir_y = velocity.y / horizontal_speed
                local wishspeed = math.max(horizontal_speed, max_speed)

                if on_ground then
                    player.apply_friction(velocity, stop_speed, friction_cvar, surface_friction, tick_interval)
                    player.accelerate(velocity, wishdir_x, wishdir_y, wishspeed, accelerate_cvar, surface_friction, tick_interval)
                else
                    player.accelerate(velocity, wishdir_x, wishdir_y, wishspeed, airaccelerate_cvar, surface_friction, tick_interval)
                end
            end

            position = {
                x = position.x + (velocity.x * tick_interval),
                y = position.y + (velocity.y * tick_interval),
                z = position.z + ((velocity.z + gravity) * tick_interval)
            }

            if not on_ground then
                velocity.z = velocity.z + gravity
            end

            local fraction = client.trace_line(
                idx,
                previous.x, previous.y, previous.z,
                position.x, position.y, position.z
            )

            if fraction < 1 then
                if fraction > 0 then
                    return {
                        x = previous.x + ((position.x - previous.x) * fraction),
                        y = previous.y + ((position.y - previous.y) * fraction),
                        z = previous.z + ((position.z - previous.z) * fraction)
                    }
                end

                return previous
            end
        end

        return position
    end

    player.get_prediction_aim_origin = function(idx, data)
        if not data then
            return nil, 0
        end

        local origin = player.get_origin_vec(idx)
        if not origin then
            return nil, 0
        end

        local flags = entity.get_prop(idx, "m_fFlags") or 0
        local latency = math.max(client.latency(), 0)
        local interp = tonumber(client.get_cvar("cl_interp")) or 0.031
        local latency_time = math.min(0.2, latency + interp)
        local latency_ticks = math.max(1, math.floor(0.5 + (latency_time / globals.tickinterval())))
        local aim_ticks = math.max(data.aim_tick or data.tick or 0, latency_ticks)

        if data.force_predict or data.defensive_peek or data.tickbase then
            aim_ticks = aim_ticks + 1
        end

        return player.extrapolate_position(idx, origin, flags, aim_ticks), aim_ticks, data.speed or 0
    end

    player.distance3d = function(x1, y1, z1, x2, y2, z2)
        return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
    end

    player.get_kd = function(player)
        if player == nil then
            return nil
        end

        local player_resource = entity.get_player_resource()

        if player_resource == nil then
            return nil
        end

        local kills = entity.get_prop(player_resource, 'm_iKills', player)
        local deaths = entity.get_prop(player_resource, 'm_iDeaths', player)

        if deaths > 0 then
            return kills / deaths
        end

        return kills
    end
end
--@endregion

--@region: utils
local ui_references = {
    weapon_type = ui.reference('rage', 'weapon type', 'weapon type'),
    enabled = { ui.reference('rage', 'aimbot', 'enabled') },
    multipoint = { ui.reference('rage', 'aimbot', 'multi-point') },
    stop = { ui.reference('rage', 'aimbot', 'quick stop') },
    minimum_damage = ui.reference('rage', 'aimbot', 'minimum damage'),
    minimum_damage_override = { ui.reference('rage', 'aimbot', 'minimum damage override') },
    minimum_hitchance = ui.reference('rage', 'aimbot', 'minimum hit chance'),
    double_tap = { ui.reference('rage', 'aimbot', 'double tap') },
    body_aim = ui.reference('rage', 'aimbot', 'force body aim'),
    safe_point = ui.reference('rage', 'aimbot', 'force safe point'),
    double_tap_fl = ui.reference('rage', 'aimbot', 'double tap fake lag limit'),
    ps = { ui.reference('misc', 'miscellaneous', 'ping spike') },
    quickpeek = { ui.reference('rage', 'other', 'quick peek assist') },
    quickpeekm = { ui.reference('rage', 'other', 'quick peek assist mode') },
    fakeduck = ui.reference('rage', 'other', 'duck peek assist'),
    on_shot_anti_aim = { ui.reference('aa', 'other', 'on shot anti-aim') },
    usercmd = ui.reference('misc', 'settings', 'sv_maxusrcmdprocessticks2'),
    slow_motion = { ui.reference("aa", "other", "Slow motion") },
    freestanding = { ui.reference('aa', 'anti-aimbot angles', 'freestanding') },
    thirdperson = { ui.reference("visuals", "effects", "force third person (alive)") },
    fakelag_limit = ui.reference("aa", "fake lag", "limit"),
    leg_movement = ui.reference('aa', 'other', 'leg movement')
}

utils = {} do
    utils.contains = function(tbl, val)
        for _, item in ipairs(tbl) do
            if item == val then
                return true
            end
        end
        return false
    end

    utils.index_of = function(tbl, val)
        for index = 1, #tbl do
            if tbl[index] == val then
                return index
            end
        end
    end

    do
        local ui_callback_lookup = { }
        utils.ui_callback_set = function(item, callback, force_call)
            local list = ui_callback_lookup[item]

            if list == nil then
                list = { }
                ui_callback_lookup[item] = list

                ui.set_callback(item, function()
                    for i = 1, #list do
                        list[i](item)
                    end
                end)
            end

            if utils.index_of(list, callback) == nil then
                table.insert(list, callback)
            end

            if force_call then
                callback(item)
            end

            return item
        end

        utils.ui_callback_unset = function(item, callback)
            local list = ui_callback_lookup[item]
            if list == nil then
                return item
            end

            local index = utils.index_of(list, callback)
            if index ~= nil then
                table.remove(list, index)
            end

            return item
        end
    end

    utils.toggle_ui_callback = function(item, callback, enabled, force_call)
        if enabled then
            return utils.ui_callback_set(item, callback, force_call)
        end

        return utils.ui_callback_unset(item, callback)
    end

    utils.multiselect_has = function(value, option)
        if value == nil then
            return false
        end

        if type(value) == 'string' then
            return value == option
        end

        return utils.contains(value, option)
    end

    utils.ragebot_weapon_types = {
        'Global',
        'G3SG1 / SCAR-20',
        'SSG 08',
        'AWP',
        'R8 Revolver',
        'Desert Eagle',
        'Pistol',
        'Zeus',
        'Rifle',
        'Shotgun',
        'SMG',
        'Machine gun'
    }

    utils.sync_hotkey_to_weapon_types = function(item, weapon_type_reference, weapon_types)
        local _, mode, key = ui.get(item)
        local current_weapon_type = ui.get(weapon_type_reference)
        local list = weapon_types or utils.ragebot_weapon_types

        for i = 1, #list do
            ui.set(weapon_type_reference, list[i])
            ui.set(item, mode, key or 0)
        end

        ui.set(weapon_type_reference, current_weapon_type)
    end

    utils.new_vec = function(x, y, z)
        return {
            x = x or 0,
            y = y or 0,
            z = z or 0
        }
    end

    utils.vec_add = function(a, b)
        return utils.new_vec(a.x + b.x, a.y + b.y, a.z + b.z)
    end

    utils.vec_sub = function(a, b)
        return utils.new_vec(a.x - b.x, a.y - b.y, a.z - b.z)
    end

    utils.vec_length_2d = function(v)
        return math.sqrt((v.x * v.x) + (v.y * v.y))
    end

    utils.vec_distance = function(a, b)
        return player.distance3d(a.x, a.y, a.z, b.x, b.y, b.z)
    end

    utils.calc_angle = function(src_x, src_y, src_z, dst_x, dst_y, dst_z)
        local dx = dst_x - src_x
        local dy = dst_y - src_y
        local dz = dst_z - src_z
        local hyp = math.sqrt(dx * dx + dy * dy)
        local pitch = math.deg(math.atan2(-dz, hyp))
        local yaw = math.deg(math.atan2(dy, dx))
        return pitch, yaw
    end

    utils.blend_vec = function(current, target, factor)
        return {
            x = current.x + ((target.x - current.x) * factor),
            y = current.y + ((target.y - current.y) * factor),
            z = current.z + ((target.z - current.z) * factor)
        }
    end

    utils.get_active_min_damage = function()
        local override_enabled = ui.get(ui_references.minimum_damage_override[1]) and ui.get(ui_references.minimum_damage_override[2])
        return override_enabled and ui.get(ui_references.minimum_damage_override[3]) or ui.get(ui_references.minimum_damage)
    end

    utils.antiaim_states = antiaim_state_options

    utils.normalize_antiaim_state = function(state)
        if type(state) ~= 'string' or state == '' then
            return 'default'
        end

        if utils.contains(utils.antiaim_states, state) then
            return state
        end

        return 'default'
    end

    utils.get_antiaim_state = function()
        if _G.noctua_runtime.use_active then
            return 'use'
        end

        if _G.noctua_runtime.manual_active then
            return 'manual'
        end

        if _G.noctua_runtime.freestanding_active then
            return 'freestand'
        end

        local state = utils.get_state()

        if state == 'freestand' then
            return 'freestand'
        end

        return utils.normalize_antiaim_state(state)
    end

    utils.get_player_info = function(idx)
        if type(idx) ~= "number" then
            return nil
        end

        local out = ffi.new("PlayerInfo_t")
        if ffi_utils.native_GetPlayerInfo(idx, out) then
            return out
        end
        return nil
    end

    utils.weapon_ready = function()
        local local_player = entity.get_local_player()
        if not local_player then
            return false
        end

        local weapon = entity.get_player_weapon(local_player)
        if not weapon then
            return false
        end

        local get_curtime = function(nOffset)
            return globals.curtime() - (nOffset * globals.tickinterval())
        end

        if get_curtime(16) < entity.get_prop(local_player, "m_flNextAttack") then
            return false
        end

        if get_curtime(0) < entity.get_prop(weapon, "m_flNextPrimaryAttack") then
            return false
        end

        return true
    end

    utils.get_state = (function()
        local tick_start = 0
        local freeze_start = nil
        return function()
            local local_player = entity.get_local_player()
            if not local_player then
                return "none"
            end

            local vx = entity.get_prop(local_player, "m_vecVelocity[0]") or 0
            local vy = entity.get_prop(local_player, "m_vecVelocity[1]") or 0
            local speed = math.floor(math.sqrt(vx^2 + vy^2))

            if entity.get_prop(local_player, "m_hGroundEntity") == 0 then
                tick_start = tick_start + 1
            else
                tick_start = 0
            end

            local onground = (tick_start >= 32)

            local gameRules = entity.get_all("CCSGameRulesProxy")
            if gameRules and #gameRules > 0 then
                local freezePeriod = entity.get_prop(gameRules[1], "m_bFreezePeriod")
                if freezePeriod == 1 then
                    if not freeze_start then
                        freeze_start = globals.realtime()
                    end
                    local freeze_total = tonumber(client.get_cvar("mp_freezetime")) or 0
                    local elapsed = globals.realtime() - freeze_start
                    local remaining = freeze_total - elapsed
                    if remaining < 0 then remaining = 0 end
                    return string.format("freeze: %d", remaining)
                else
                    freeze_start = nil
                end
            end

            if ui.get(ui_references.fakeduck) then
                return "fakeduck"
            end

            if ui.get(ui_references.slow_motion[1]) and ui.get(ui_references.slow_motion[2]) then
                if entity.get_prop(local_player, "m_flDuckAmount") == 0 then
                    return "slow"
                end
            end

            if not onground then
                if entity.get_prop(local_player, "m_flDuckAmount") == 1 then
                    return "airc"
                end
                return "air"
            end

            if entity.get_prop(local_player, "m_flDuckAmount") == 1 then
                if speed > 8 then
                    return "duck move"
                end
                return "duck"
            end

            if ui.get(ui_references.freestanding[1]) and ui.get(ui_references.freestanding[2]) then
                return "freestand"
            end

            if speed > 8 then
                return "run"
            end

            return "idle"
        end
    end)()

    utils.get_enemy_state = (function()
        local tick_start = 0
        local run_tick = 0
        local current_state = "idle"

        return function(idx)
            if not idx then
                return "none"
            end

            if entity.is_dormant(idx) and entity.is_alive(idx) then
                return "dormant"
            end

            local weapon = entity.get_player_weapon(idx)
            if weapon then
                local weap_name = entity.get_classname(weapon) or ""
                local lower_name = weap_name:lower()
                if string.find(lower_name, "grenade") or string.find(lower_name, "flashbang") then
                    return "nade" -- flashbang, decoy molotov hegrenade smoke incendiary grenade
                end
            end

            local vx = entity.get_prop(idx, "m_vecVelocity[0]") or 0
            local vy = entity.get_prop(idx, "m_vecVelocity[1]") or 0
            local speed = math.floor(math.sqrt(vx^2 + vy^2))

            if entity.get_prop(idx, "m_hGroundEntity") == 0 then
                tick_start = tick_start + 1
            else
                tick_start = 0
            end

            local onground = (tick_start >= 32)

            if not onground then
                if entity.get_prop(idx, "m_flDuckAmount") == 1 then
                    return "airc"
                end
                return "air"
            end

            if entity.get_prop(idx, "m_flDuckAmount") == 1 then
                return "duck"
            end

            if speed < 8 then
                current_state = "idle"
                run_tick = 0
                return "idle"
            end

            local slow_lower = 65
            local slow_upper = 87
            local run_threshold = 90
            local exit_run_ticks_required = 3

            if speed >= slow_lower and speed <= slow_upper then
                current_state = "slow"
                run_tick = 0
            else
                if current_state == "slow" then
                    if speed >= run_threshold then
                        run_tick = run_tick + 1
                        if run_tick >= exit_run_ticks_required then
                            current_state = (speed > 5 and "run") or "idle"
                            run_tick = 0
                        end
                    else
                        run_tick = 0
                        current_state = "slow"
                    end
                else
                    current_state = (speed > 5 and "run") or "idle"
                end
            end

            return current_state
        end
    end)()

    utils.get_scoreboard_ping = function()
        local resource = entity.get_player_resource()
        local me = entity.get_local_player()
        
        if not resource or not me then return 0 end
        
        local ping = entity.get_prop(resource, "m_iPing", me)
        
        return ping or 0
    end
end
--@endregion

--@region: antiaim
antiaim = {} do
    antiaim.builder = {}
    antiaim.extensions = {}
    antiaim.exploit = {}
    antiaim.hotkeys = {}
    antiaim.use = {}

    local builder = antiaim.builder
    local extensions = antiaim.extensions
    local exploit = antiaim.exploit
    local hotkeys = antiaim.hotkeys
    local use_state = antiaim.use
    local refs = reference.antiaim.angles
    local fakelag_refs = reference.antiaim.fakelag
    local rage_binds = reference.rage.binds
    local yaw_jitter_map = {
        off = 'Off',
        offset = 'Offset',
        center = 'Center',
        random = 'Random',
        skitter = 'Skitter'
    }
    local body_yaw_map = {
        off = 'Off',
        opposite = 'Opposite',
        static = 'Static',
        jitter = 'Jitter'
    }
    local skitter = {
        -1, 1, 0,
        -1, 1, 0,
        -1, 0, 1,
        -1, 0, 1
    }

    builder.inverted = false
    builder.inverts = 0
    builder.delay_ticks = 0
    builder.delay_limit = 0

    hotkeys.manual_dir = nil
    hotkeys.manual_data = {}
    hotkeys.manual_angles = {
        left = -90,
        right = 90,
        forward = 180,
        backward = 0
    }

    function hotkeys.get_freestanding_state()
        local state = utils.get_state()

        if state == 'air' or state == 'airc' then
            return 'air'
        end

        if state == 'slow' then
            return 'slow walk'
        end

        if state == 'duck' or state == 'duck move' then
            return 'crouched'
        end

        if state == 'run' then
            return 'moving'
        end

        return 'standing'
    end

    function hotkeys.is_freestanding_active()
        local item = interface.antiaim.hotkeys.freestanding
        local disablers = interface.antiaim.hotkeys.freestanding_disablers:get()

        if ui.is_menu_open() then
            return false
        end

        if not item:get() or not item.hotkey:get() then
            return false
        end

        return not utils.multiselect_has(disablers, hotkeys.get_freestanding_state())
    end

    function hotkeys.get_hotkey_changed(item, active, mode)
        if hotkeys.manual_data[item] == nil then
            hotkeys.manual_data[item] = {
                active = active
            }
        end

        local previous = hotkeys.manual_data[item].active
        hotkeys.manual_data[item].active = active

        return (mode == 1 or mode == 2) and previous ~= active
    end

    function hotkeys.update_manual_direction(item, dir)
        local active, mode = ui.get(item)

        if not hotkeys.get_hotkey_changed(item, active, mode) then
            return
        end

        if hotkeys.manual_dir == dir then
            hotkeys.manual_dir = nil
        else
            hotkeys.manual_dir = dir
        end
    end

    function hotkeys.on_paint_ui()
        if not interface.antiaim.enabled_antiaim:get() or not interface.antiaim.hotkeys.manual_yaw:get() then
            hotkeys.manual_dir = nil
            _G.noctua_runtime.manual_active = false
            return
        end

        hotkeys.update_manual_direction(interface.antiaim.hotkeys.manual_left, 'left')
        hotkeys.update_manual_direction(interface.antiaim.hotkeys.manual_right, 'right')
        hotkeys.update_manual_direction(interface.antiaim.hotkeys.manual_forward, 'forward')
        hotkeys.update_manual_direction(interface.antiaim.hotkeys.manual_backward, 'backward')

        _G.noctua_runtime.manual_active = hotkeys.manual_dir ~= nil
    end

    function hotkeys.reset()
        hotkeys.manual_dir = nil
        hotkeys.manual_data = {}
        _G.noctua_runtime.manual_active = false
        _G.noctua_runtime.freestanding_active = false
    end

    use_state.interact_traced = false

    function use_state.reset()
        use_state.interact_traced = false
        _G.noctua_runtime.use_active = false
    end

    function use_state.get_profile()
        local profile = builder.get_profile('use')

        if profile == nil then
            return nil
        end

        if profile.enabled ~= nil and not profile.enabled:get() then
            return nil
        end

        return profile
    end

    function use_state.should_update(cmd, local_player)
        if cmd.in_use == 0 then
            use_state.interact_traced = false
            return false
        end

        local profile = use_state.get_profile()
        if profile == nil then
            return false
        end

        local weapon = entity.get_player_weapon(local_player)
        local weapon_info = weapon and csgo_weapons(weapon) or nil

        if weapon_info == nil then
            return false
        end

        local is_weapon_bomb = weapon_info.idx == 49
        local is_defusing = entity.get_prop(local_player, 'm_bIsDefusing') == 1
        local is_rescuing = entity.get_prop(local_player, 'm_bIsGrabbingHostage') == 1
        local in_bomb_site = entity.get_prop(local_player, 'm_bInBombZone') == 1

        if is_defusing or is_rescuing then
            return false
        end

        if in_bomb_site and (not extensions.is_enabled('bombsite e fix') or is_weapon_bomb) then
            return false
        end

        local team = entity.get_prop(local_player, 'm_iTeamNum')
        if team == 3 and cmd.pitch > 15 then
            local lx, ly, lz = entity.get_origin(local_player)
            local bombs = entity.get_all('CPlantedC4')

            for i = 1, #bombs do
                local bx, by, bz = entity.get_origin(bombs[i])

                if bx ~= nil then
                    local dx = bx - lx
                    local dy = by - ly
                    local dz = bz - lz

                    if ((dx * dx) + (dy * dy) + (dz * dz)) < (62 * 62) then
                        return false
                    end
                end
            end
        end

        local pitch, yaw = client.camera_angles()
        local ex, ey, ez = client.eye_position()
        local pitch_rad = math.rad(pitch)
        local yaw_rad = math.rad(yaw)
        local tx = ex + (math.cos(pitch_rad) * math.cos(yaw_rad) * 128)
        local ty = ey + (math.cos(pitch_rad) * math.sin(yaw_rad) * 128)
        local tz = ez + (-math.sin(pitch_rad) * 128)
        local fraction, entindex = client.trace_line(local_player, ex, ey, ez, tx, ty, tz)

        if fraction ~= 1 then
            if entindex == -1 then
                return true
            end

            local classname = entity.get_classname(entindex)

            if classname == 'CWorld' or classname == 'CFuncBrush' or classname == 'CCSPlayer' then
                return true
            end

            if classname == 'CHostage' then
                local hx, hy, hz = entity.get_origin(entindex)

                if hx ~= nil then
                    local dx = hx - ex
                    local dy = hy - ey
                    local dz = hz - ez

                    if ((dx * dx) + (dy * dy) + (dz * dz)) < (84 * 84) then
                        return false
                    end
                end
            end

            if not use_state.interact_traced then
                use_state.interact_traced = true
                return false
            end
        end

        return true
    end

    function use_state.update(cmd, local_player)
        _G.noctua_runtime.use_active = use_state.should_update(cmd, local_player)
        return _G.noctua_runtime.use_active
    end

    exploit.BREAK_LAG_COMPENSATION_DISTANCE_SQR = 64 * 64
    exploit.data = {
        old_origin = nil,
        old_simtime = 0,
        shift = false,
        breaking_lc = false,
        lagcompensation = {
            distance = 0,
            teleport = false
        },
        suppressed = {
            double_tap = false,
            osaa = false
        }
    }

    function exploit.restore()
        if exploit.data.suppressed.double_tap then
            rage_binds.double_tap[1]:override()
            exploit.data.suppressed.double_tap = false
        end

        if exploit.data.suppressed.osaa then
            rage_binds.on_shot_anti_aim[1]:override()
            exploit.data.suppressed.osaa = false
        end
    end

    function exploit.reset()
        exploit.restore()
        exploit.data.old_origin = nil
        exploit.data.old_simtime = 0
        exploit.data.shift = false
        exploit.data.breaking_lc = false
        exploit.data.lagcompensation.distance = 0
        exploit.data.lagcompensation.teleport = false
    end

    function exploit.get()
        return exploit.data
    end

    function exploit.is_double_tap_active()
        return ui.get(ui_references.double_tap[1]) and ui.get(ui_references.double_tap[2])
    end

    function exploit.is_osaa_active()
        return ui.get(ui_references.on_shot_anti_aim[1]) and ui.get(ui_references.on_shot_anti_aim[2])
    end

    function exploit.has_active()
        return exploit.is_double_tap_active() or exploit.is_osaa_active()
    end

    function exploit.suppress_active()
        if exploit.is_double_tap_active() then
            rage_binds.double_tap[1]:override(false)
            exploit.data.suppressed.double_tap = true
        end

        if exploit.is_osaa_active() then
            rage_binds.on_shot_anti_aim[1]:override(false)
            exploit.data.suppressed.osaa = true
        end
    end

    function exploit.update_state()
        exploit.data.shift = antiaim_funcs.get_tickbase_shifting() > 0
    end

    function exploit.update_lagcompensation(local_player)
        local x, y, z = entity.get_origin(local_player)
        local simtime = entity.get_prop(local_player, 'm_flSimulationTime')

        if x == nil or simtime == nil then
            return
        end

        local old_origin = exploit.data.old_origin
        local old_simtime = exploit.data.old_simtime
        local tickinterval = globals.tickinterval()
        local simtick = math.floor((simtime / tickinterval) + 0.5)

        if old_origin ~= nil and old_simtime ~= 0 then
            local delta = simtick - old_simtime

            if delta < 0 or (delta > 0 and delta <= 64) then
                local dx = x - old_origin.x
                local dy = y - old_origin.y
                local dz = z - old_origin.z
                local distance = (dx * dx) + (dy * dy) + (dz * dz)
                local is_teleport = distance > exploit.BREAK_LAG_COMPENSATION_DISTANCE_SQR

                exploit.data.breaking_lc = is_teleport
                exploit.data.lagcompensation.distance = distance
                exploit.data.lagcompensation.teleport = is_teleport
            end
        end

        exploit.data.old_origin = utils.new_vec(x, y, z)
        exploit.data.old_simtime = simtick
    end

    function exploit.on_net_update_start()
        local local_player = entity.get_local_player()

        if not local_player or not entity.is_alive(local_player) then
            exploit.reset()
            return
        end

        exploit.update_lagcompensation(local_player)
    end

    extensions.avoid_backstab_distance = 240
    extensions.damage_received_until = 0
    extensions.flash_until = 0
    extensions.reload_until = 0
    extensions.break_self_backtrack_cooldown = 0
    extensions.vigilant_last_state = nil
    extensions.vigilant_next_pulse = 0

    function extensions.is_enabled(name)
        return utils.multiselect_has(interface.antiaim.fake_lag.extensions:get(), name)
    end

    function extensions.is_trigger_enabled(name)
        return utils.multiselect_has(interface.antiaim.fake_lag.triggers:get(), name)
    end

    function extensions.is_safe_head_trigger_enabled(name)
        return utils.multiselect_has(interface.antiaim.fake_lag.safe_head_triggers:get(), name)
    end

    function extensions.reset()
        extensions.damage_received_until = 0
        extensions.flash_until = 0
        extensions.reload_until = 0
        extensions.break_self_backtrack_cooldown = 0
        extensions.vigilant_last_state = nil
        extensions.vigilant_next_pulse = 0
        _G.noctua_runtime.safe_head_active = false
        exploit.restore()
        fakelag_refs.on[1]:override()
        fakelag_refs.limit:override()
    end

    function extensions.is_osaa_active()
        return ui.get(ui_references.on_shot_anti_aim[1]) and ui.get(ui_references.on_shot_anti_aim[2])
    end

    function extensions.is_swapping_weapons(cmd)
        return cmd.weaponselect > 0
    end

    function extensions.is_correct_exploit_active()
        local exploit_types = interface.antiaim.fake_lag.correct_lag_exploit_type:get()
        local is_double_tap = utils.multiselect_has(exploit_types, 'double tap') and ui.get(ui_references.double_tap[1]) and ui.get(ui_references.double_tap[2])
        local is_osaa = utils.multiselect_has(exploit_types, 'osaa') and extensions.is_osaa_active()

        return is_double_tap or is_osaa
    end

    function extensions.get_eye_position(idx)
        local ox, oy, oz = entity.get_prop(idx, 'm_vecOrigin')
        if ox == nil then
            return nil
        end

        local view_z = entity.get_prop(idx, 'm_vecViewOffset[2]') or 64
        return ox, oy, oz + view_z
    end

    function extensions.can_enemy_see_local(enemy, local_player)
        if enemy == nil or not entity.is_alive(enemy) or entity.is_dormant(enemy) then
            return false
        end

        local ex, ey, ez = extensions.get_eye_position(enemy)
        if ex == nil then
            return false
        end

        local hitboxes = { 0, 2, 4 }
        for i = 1, #hitboxes do
            local hx, hy, hz = entity.hitbox_position(local_player, hitboxes[i])
            if hx ~= nil then
                local fraction, entindex = client.trace_line(enemy, ex, ey, ez, hx, hy, hz)
                if fraction == 1 or entindex == local_player then
                    return true
                end
            end
        end

        return false
    end

    function extensions.get_backtrack_threat(local_player, mode)
        local threat = client.current_threat()
        if threat ~= nil and extensions.can_enemy_see_local(threat, local_player) then
            return threat
        end

        if mode ~= 'auto' then
            return nil
        end

        local enemies = entity.get_players(true)
        for i = 1, #enemies do
            local enemy = enemies[i]
            if enemy ~= threat and extensions.can_enemy_see_local(enemy, local_player) then
                return enemy
            end
        end

        return nil
    end

    function extensions.should_break_self_backtrack_pulse(local_player, cmd)
        if not extensions.is_enabled('break self backtrack') then
            return false
        end

        local mode = interface.antiaim.fake_lag.break_self_backtrack_mode:get()
        local threat = extensions.get_backtrack_threat(local_player, mode)
        if threat == nil then
            return false
        end

        local tick = globals.tickcount()
        if tick < (extensions.break_self_backtrack_cooldown or 0) then
            return false
        end

        local _, _, _, speed = player.get_velocity(local_player)
        if speed < 70 then
            return false
        end

        local base_limit = ui.get(ui_references.fakelag_limit) or 15
        local choked = cmd.chokedcommands or 0
        local interval = globals.tickinterval()
        local estimated_shift = speed * interval * (choked + 1)
        local close_to_flush = choked >= mathematic.clamp(base_limit - 4, 5, 12)
        local meaningful_shift = estimated_shift >= 14
        local threat_distance = nil

        local lx, ly, lz = entity.get_origin(local_player)
        local tx, ty, tz = entity.get_origin(threat)
        if lx ~= nil and tx ~= nil then
            threat_distance = player.distance3d(lx, ly, lz, tx, ty, tz)
        end

        local close_enemy = threat_distance ~= nil and threat_distance < 900
        local dangerous_window = (meaningful_shift and close_to_flush) or (close_enemy and choked >= 5 and estimated_shift >= 10)

        if not dangerous_window then
            return false
        end

        extensions.break_self_backtrack_cooldown = tick + 3
        return true
    end

    function extensions.should_vigilant_pulse()
        if not extensions.is_enabled('vigilant lagcomp breaking') then
            return false
        end

        local state = utils.get_state()
        local decisive_controls = interface.antiaim.fake_lag.vigilant_controls:get()
        local tick = globals.tickcount()
        local has_threat = client.current_threat() ~= nil
        local state_changed = extensions.vigilant_last_state ~= state

        if state_changed then
            extensions.vigilant_last_state = state
        end

        if not has_threat or not utils.multiselect_has(decisive_controls, state) then
            return false
        end

        if state_changed then
            extensions.vigilant_next_pulse = tick + 8
            return true
        end

        if tick >= (extensions.vigilant_next_pulse or 0) then
            extensions.vigilant_next_pulse = tick + 8
            return true
        end

        return false
    end

    function extensions.apply_fakelag(local_player, cmd)
        local limit_override = nil
        local should_pulse = false

        if extensions.is_enabled('correct lag on exploit') and extensions.is_correct_exploit_active() then
            limit_override = 1
        else
            if extensions.should_break_self_backtrack_pulse(local_player, cmd) then
                limit_override = 1
                should_pulse = true
            end

            if extensions.should_vigilant_pulse() then
                limit_override = 1
                should_pulse = true
            end
        end

        if should_pulse then
            cmd.no_choke = true
        end

        if limit_override == nil then
            fakelag_refs.on[1]:override()
            fakelag_refs.limit:override()
            return
        end

        fakelag_refs.on[1]:override(true)
        fakelag_refs.limit:override(mathematic.clamp(limit_override, 1, 15))
    end

    function extensions.apply_fast_fall(local_player, cmd)
        if not extensions.is_enabled('fast fall') then
            return
        end

        if cmd.in_jump == 1 then
            return
        end

        local state = utils.get_state()
        if state ~= 'air' and state ~= 'airc' then
            return
        end

        if (entity.get_prop(local_player, 'm_MoveType') or 0) == 9 then
            return
        end

        if not exploit.has_active() then
            return
        end

        local velocity_z = entity.get_prop(local_player, 'm_vecVelocity[2]') or 0
        if velocity_z > -120 then
            return
        end

        local ox, oy, oz = entity.get_origin(local_player)
        local check_distance = mathematic.clamp(math.abs(velocity_z) * globals.tickinterval() * 4, 24, 96)
        local fraction = client.trace_line(local_player, ox, oy, oz, ox, oy, oz - check_distance)

        if fraction < 1 then
            exploit.suppress_active()
            cmd.no_choke = true
        end
    end

    function extensions.apply_fast_ladder(local_player, cmd)
        if not extensions.is_enabled('fast ladder') then
            return
        end

        if (entity.get_prop(local_player, 'm_MoveType') or 0) ~= 9 or cmd.forwardmove == 0 then
            return
        end

        local camera_pitch = client.camera_angles()
        local descending = cmd.forwardmove < 0 or camera_pitch > 45

        cmd.in_moveleft = descending and 1 or 0
        cmd.in_moveright = descending and 0 or 1
        cmd.in_forward = descending and 1 or 0
        cmd.in_back = descending and 0 or 1
        cmd.pitch = 89
        cmd.yaw = mathematic.normalize_yaw(cmd.yaw + 90)
    end

    function extensions.is_flashed(local_player)
        local flash_duration = entity.get_prop(local_player, 'm_flFlashDuration') or 0
        return flash_duration > 0 or globals.curtime() < extensions.flash_until
    end

    function extensions.is_reloading(local_player, cmd)
        local weapon = entity.get_player_weapon(local_player)
        local in_reload = weapon and entity.get_prop(weapon, 'm_bInReload') or 0
        return in_reload == 1 or cmd.in_reload == 1 or globals.curtime() < extensions.reload_until
    end

    function extensions.should_force_break_lc(local_player, cmd)
        if not extensions.is_enabled('force break lc') then
            return false
        end

        if extensions.is_trigger_enabled('flashed') and extensions.is_flashed(local_player) then
            return true
        end

        if extensions.is_trigger_enabled('damage received') and globals.curtime() < extensions.damage_received_until then
            return true
        end

        if extensions.is_trigger_enabled('reloading') and extensions.is_reloading(local_player, cmd) then
            return true
        end

        if extensions.is_trigger_enabled('weapon switch') and extensions.is_swapping_weapons(cmd) then
            return true
        end

        if extensions.is_trigger_enabled('osaa') and extensions.is_osaa_active() then
            return true
        end

        return false
    end

    function extensions.is_weapon_knife(weapon)
        local weapon_info = weapon and csgo_weapons(weapon) or nil
        return weapon_info ~= nil and weapon_info.type == 'knife' and weapon_info.idx ~= 31
    end

    function extensions.get_backstab_yaw(local_player)
        if not extensions.is_enabled('avoid backstab') then
            return nil
        end

        local lx, ly, lz = entity.get_origin(local_player)
        if lx == nil then
            return nil
        end

        local max_distance = extensions.avoid_backstab_distance * extensions.avoid_backstab_distance
        local best_distance = math.huge
        local best_yaw = nil
        local enemies = entity.get_players(true)

        for i = 1, #enemies do
            local enemy = enemies[i]
            local weapon = entity.get_player_weapon(enemy)

            if entity.is_alive(enemy) and not entity.is_dormant(enemy) and extensions.is_weapon_knife(weapon) then
                local ex, ey, ez = entity.get_origin(enemy)

                if ex ~= nil then
                    local dx = ex - lx
                    local dy = ey - ly
                    local dz = ez - lz
                    local distance = (dx * dx) + (dy * dy) + (dz * dz)

                    if distance < best_distance then
                        local _, yaw = utils.calc_angle(lx, ly, lz, ex, ey, ez)
                        best_distance = distance
                        best_yaw = yaw
                    end
                end
            end
        end

        if best_yaw == nil or best_distance > max_distance then
            return nil
        end

        return best_yaw
    end

    function extensions.get_safe_head_condition(local_player)
        if not extensions.is_enabled('safe head') then
            return nil
        end

        local threat = client.current_threat()
        if threat == nil then
            return nil
        end

        local weapon = entity.get_player_weapon(local_player)
        local weapon_info = weapon and csgo_weapons(weapon) or nil

        if weapon_info == nil then
            return nil
        end

        local lx, ly, lz = entity.get_origin(local_player)
        local tx, ty, tz = entity.get_origin(threat)

        if lx == nil or tx == nil then
            return nil
        end

        local dx = tx - lx
        local dy = ty - ly
        local height = lz - tz
        local distance_2d = (dx * dx) + (dy * dy)
        local state = utils.get_state()
        local crouched = entity.get_prop(local_player, 'm_flDuckAmount') == 1
        local moving = state == 'run' or state == 'slow' or state == 'duck move'
        local in_air = state == 'air' or state == 'airc'
        local is_knife = weapon_info.type == 'knife' and weapon_info.idx ~= 31
        local is_taser = weapon_info.idx == 31

        if not in_air then
            if extensions.is_safe_head_trigger_enabled('high distance') and (not moving or crouched) and height >= 10 and distance_2d > 1000 * 1000 then
                return 'high distance'
            end

            if crouched then
                if extensions.is_safe_head_trigger_enabled('duck') and height >= 48 then
                    return 'duck'
                end

                return nil
            end

            if extensions.is_safe_head_trigger_enabled('idle') and not moving and height >= 24 then
                return 'idle'
            end

            return nil
        end

        if not crouched then
            return nil
        end

        if extensions.is_safe_head_trigger_enabled('airc+zeus') and is_taser and height > -20 and distance_2d < 500 * 500 then
            return 'airc+zeus'
        end

        if extensions.is_safe_head_trigger_enabled('airc+knife') and is_knife then
            return 'airc+knife'
        end

        if extensions.is_safe_head_trigger_enabled('airc') and height > 160 then
            return 'airc'
        end

        return nil
    end

    function extensions.apply(cmd, local_player, state)
        _G.noctua_runtime.safe_head_active = false

        extensions.apply_fakelag(local_player, cmd)
        extensions.apply_fast_fall(local_player, cmd)
        extensions.apply_fast_ladder(local_player, cmd)

        if state.force_break_lc or extensions.should_force_break_lc(local_player, cmd) then
            cmd.force_defensive = true
        end

        if _G.noctua_runtime.use_active then
            return
        end

        if state.manual_dir ~= nil then
            return
        end

        local backstab_yaw = extensions.get_backstab_yaw(local_player)
        if backstab_yaw ~= nil then
            local _, camera_yaw = client.camera_angles()
            state.yaw_base = 'Local view'
            state.yaw_mode = '180'
            state.yaw_offset = mathematic.normalize_yaw(backstab_yaw - camera_yaw - 180)
            state.jitter_mode = 'off'
            state.jitter_offset = 0
            state.freestanding_body_yaw = false
            state.freestanding = false
            return
        end

        local safe_head_condition = extensions.get_safe_head_condition(local_player)
        if safe_head_condition == nil then
            return
        end

        _G.noctua_runtime.safe_head_active = true
        state.yaw_base = 'At targets'
        state.yaw_mode = '180'
        state.yaw_offset = safe_head_condition == 'airc+knife' and 37 or 0
        state.jitter_mode = 'off'
        state.jitter_offset = 0
        state.body_yaw = 'static'
        state.body_yaw_offset = safe_head_condition == 'airc+knife' and 1 or 0
        state.freestanding_body_yaw = false
        state.freestanding = false
    end

    function extensions.on_player_hurt(e)
        local local_player = entity.get_local_player()

        if local_player ~= nil and client.userid_to_entindex(e.userid) == local_player then
            extensions.damage_received_until = globals.curtime() + 0.25
        end
    end

    function extensions.on_player_blind(e)
        local local_player = entity.get_local_player()

        if local_player ~= nil and client.userid_to_entindex(e.userid) == local_player then
            local duration = tonumber(e.blind_duration) or 1
            extensions.flash_until = globals.curtime() + math.max(duration, 0.25)
        end
    end

    function extensions.on_weapon_reload(e)
        local local_player = entity.get_local_player()

        if local_player ~= nil and client.userid_to_entindex(e.userid) == local_player then
            extensions.reload_until = globals.curtime() + 1
        end
    end

    function builder.get_profile(state)
        return interface.antiaim.builder.profiles[state]
    end

    function builder.get_runtime_state()
        _G.noctua_runtime.manual_active = interface.antiaim.hotkeys.manual_yaw:get() and hotkeys.manual_dir ~= nil and not _G.noctua_runtime.use_active
        _G.noctua_runtime.freestanding_active = hotkeys.is_freestanding_active() and not _G.noctua_runtime.manual_active and not _G.noctua_runtime.use_active

        if not _G.noctua_runtime.freestanding_active then
            refs.freestanding:override(false)
        end

        if _G.noctua_runtime.use_active then
            return 'use'
        end

        if _G.noctua_runtime.manual_active then
            return 'manual'
        end

        if _G.noctua_runtime.freestanding_active then
            return 'freestand'
        end

        local state = utils.get_state()

        if state == 'freestand' then
            return 'freestand'
        end

        return utils.normalize_antiaim_state(state)
    end

    function builder.get_active_profile()
        local state = builder.get_runtime_state()
        local profile = builder.get_profile(state)

        if profile ~= nil and (profile.enabled == nil or profile.enabled:get()) then
            return state, profile
        end

        return 'default', builder.get_profile('default')
    end

    function builder.unset()
        _G.noctua_runtime.use_active = false
        _G.noctua_runtime.safe_head_active = false
        refs.freestanding:override()
        refs.freestanding_body_yaw:override()
        refs.body_yaw[2]:override()
        refs.body_yaw[1]:override()
        refs.yaw_jitter[2]:override()
        refs.yaw_jitter[1]:override()
        refs.yaw[2]:override()
        refs.yaw[1]:override()
        refs.yaw_base:override()
        refs.pitch[2]:override()
        refs.pitch[1]:override()
        refs.enabled:override()
    end

    function builder.reset()
        builder.inverted = false
        builder.inverts = 0
        builder.delay_ticks = 0
        builder.delay_limit = 0
        builder.unset()
    end

    function builder.update_inverter(profile, cmd)
        if cmd.chokedcommands ~= 0 then
            return
        end

        if builder.delay_limit < 1 then
            builder.delay_limit = client.random_int(
                profile.delay_from:get(),
                profile.delay_to:get()
            )
        end

        builder.delay_ticks = builder.delay_ticks + 1

        if builder.delay_ticks < builder.delay_limit then
            return
        end

        builder.inverts = builder.inverts + 1

        if client.random_int(0, 100) <= profile.invert_chance:get() then
            builder.inverted = not builder.inverted
        end

        builder.delay_ticks = 0
        builder.delay_limit = 0
    end

    function builder.apply(cmd, local_player)
        local _, profile = builder.get_active_profile()

        if profile == nil then
            builder.unset()
            return
        end

        builder.update_inverter(profile, cmd)

        local yaw_left = profile.yaw_left:get()
        local yaw_right = profile.yaw_right:get()
        local yaw_random = profile.yaw_random:get() * 0.01

        if yaw_random > 0 then
            local left_random = math.floor(math.abs(yaw_left) * yaw_random)
            local right_random = math.floor(math.abs(yaw_right) * yaw_random)

            yaw_left = yaw_left + client.random_int(-left_random, left_random)
            yaw_right = yaw_right + client.random_int(-right_random, right_random)
        end

        local yaw_offset = builder.inverted and yaw_right or yaw_left
        local jitter_mode = profile.yaw_jitter:get()
        local jitter_offset = profile.jitter_offset:get()

        if jitter_mode ~= 'off' then
            local jitter_random = profile.jitter_random:get() * 0.01
            local jitter_delta = math.floor(math.abs(jitter_offset) * jitter_random)
            jitter_offset = jitter_offset + client.random_int(-jitter_delta, jitter_delta)
        end

        if jitter_mode == 'offset' then
            yaw_offset = yaw_offset + (builder.inverted and jitter_offset or 0)
            jitter_mode = 'off'
            jitter_offset = 0
        elseif jitter_mode == 'center' then
            local center_offset = builder.inverted and jitter_offset or -jitter_offset
            yaw_offset = yaw_offset + (center_offset * 0.5)
            jitter_mode = 'off'
            jitter_offset = 0
        elseif jitter_mode == 'skitter' then
            local index = (builder.inverts % #skitter) + 1
            yaw_offset = yaw_offset + (jitter_offset * skitter[index])
            jitter_mode = 'off'
            jitter_offset = 0
        end

        local body_yaw_mode = profile.body_yaw:get()
        local body_yaw = body_yaw_mode
        local body_yaw_offset = profile.body_yaw_offset:get()
        local freestanding_body_yaw = body_yaw_mode ~= 'off' and body_yaw_mode ~= 'jitter' and profile.freestanding_body_yaw:get() or false
        local yaw_mode = '180'

        if body_yaw == 'static' then
            body_yaw_offset = math.abs(body_yaw_offset)
            body_yaw_offset = builder.inverted and body_yaw_offset or -body_yaw_offset
        elseif body_yaw == 'jitter' then
            body_yaw_offset = math.abs(body_yaw_offset)
            if body_yaw_offset == 0 then
                body_yaw_offset = 1
            end
            body_yaw_offset = builder.inverted and body_yaw_offset or -body_yaw_offset
            body_yaw = 'static'
        else
            body_yaw_offset = 0
        end

        local manual_dir = (not _G.noctua_runtime.use_active and interface.antiaim.hotkeys.manual_yaw:get()) and hotkeys.manual_dir or nil
        if manual_dir ~= nil then
            local angle = hotkeys.manual_angles[manual_dir] or 0
            local modifier = interface.antiaim.hotkeys.manual_modifier:get() or {}

            yaw_offset = yaw_offset + angle

            if utils.contains(modifier, 'disable yaw modifiers') then
                jitter_mode = 'off'
                jitter_offset = 0
            end

            if utils.contains(modifier, 'freestanding body') then
                body_yaw_mode = 'static'
                body_yaw = 'static'
                body_yaw_offset = 180
                freestanding_body_yaw = true
            end
        end

        local settings = {
            manual_dir = manual_dir,
            force_break_lc = profile.force_break_lc:get(),
            yaw_mode = yaw_mode,
            yaw_base = (_G.noctua_runtime.use_active or manual_dir ~= nil) and 'Local view' or 'At targets',
            yaw_offset = _G.noctua_runtime.use_active and mathematic.normalize_yaw(yaw_offset + 180) or yaw_offset,
            jitter_mode = jitter_mode,
            jitter_offset = jitter_offset,
            body_yaw = body_yaw,
            body_yaw_offset = body_yaw_offset,
            freestanding_body_yaw = freestanding_body_yaw,
            freestanding = _G.noctua_runtime.use_active and false or _G.noctua_runtime.freestanding_active,
            pitch_mode = _G.noctua_runtime.use_active and 'Custom' or 'Default',
            pitch_offset = _G.noctua_runtime.use_active and mathematic.clamp(cmd.pitch, -89, 89) or 0
        }

        extensions.apply(cmd, local_player, settings)

        refs.enabled:override(true)
        refs.pitch[1]:override(settings.pitch_mode)
        refs.pitch[2]:override(settings.pitch_offset)
        refs.yaw_base:override(settings.yaw_base)
        refs.yaw[1]:override(settings.yaw_mode)
        refs.yaw[2]:override(settings.yaw_offset)
        refs.yaw_jitter[1]:override(yaw_jitter_map[settings.jitter_mode] or 'Off')
        refs.yaw_jitter[2]:override(settings.jitter_offset)
        refs.body_yaw[1]:override(body_yaw_map[settings.body_yaw] or 'Off')
        refs.body_yaw[2]:override(settings.body_yaw_offset)
        refs.freestanding_body_yaw:override(settings.freestanding_body_yaw)
        refs.freestanding:override(settings.freestanding)
    end

    function antiaim.on_setup_command(cmd)
        local local_player = entity.get_local_player()

        if not interface.antiaim.enabled_antiaim:get() or not local_player or not entity.is_alive(local_player) then
            exploit.reset()
            use_state.reset()
            extensions.reset()
            builder.unset()
            return
        end

        exploit.restore()
        exploit.update_state()
        use_state.update(cmd, local_player)
        builder.apply(cmd, local_player)

        if _G.noctua_runtime.use_active then
            cmd.in_use = 0
        end
    end

    function antiaim.on_paint()
        local local_player = entity.get_local_player()

        if interface.antiaim.enabled_antiaim:get() and local_player and entity.is_alive(local_player) then
            return
        end

        exploit.reset()
        use_state.reset()
        extensions.reset()
        hotkeys.reset()
        builder.unset()
    end

    client.set_event_callback('setup_command', antiaim.on_setup_command)
    client.set_event_callback('net_update_start', exploit.on_net_update_start)
    client.set_event_callback('paint_ui', hotkeys.on_paint_ui)
    client.set_event_callback('paint', antiaim.on_paint)
    client.set_event_callback('player_hurt', extensions.on_player_hurt)
    client.set_event_callback('player_blind', extensions.on_player_blind)
    client.set_event_callback('weapon_reload', extensions.on_weapon_reload)
    client.set_event_callback('round_start', exploit.reset)
    client.set_event_callback('game_newmap', exploit.reset)
    client.set_event_callback('cs_game_disconnected', exploit.reset)
    client.set_event_callback('round_start', use_state.reset)
    client.set_event_callback('game_newmap', use_state.reset)
    client.set_event_callback('cs_game_disconnected', use_state.reset)
    client.set_event_callback('round_start', extensions.reset)
    client.set_event_callback('game_newmap', extensions.reset)
    client.set_event_callback('cs_game_disconnected', extensions.reset)
    client.set_event_callback('shutdown', function()
        exploit.reset()
        use_state.reset()
        extensions.reset()
        hotkeys.reset()
        builder.reset()
    end)
    client.set_event_callback('pre_config_save', function()
        exploit.reset()
        use_state.reset()
        extensions.reset()
        hotkeys.reset()
        builder.unset()
    end)
end
--@endregion

--@region: json
local json = {
    null = {}
}

function json.encode(val, pretty)
    local indent = pretty and "    " or ""
    local level = 0

    local function _encode(v, _pretty)
        if v == nil then
            return "null"
        elseif type(v) == "string" then
            return string.format("%q", v)
        elseif type(v) == "number" or type(v) == "boolean" then
            return tostring(v)
        elseif type(v) == "table" then
            if v == json.null then
                return "null"
            end
            
            level = level + 1
            local current_indent = _pretty and string.rep(indent, level) or ""
            local next_indent = _pretty and string.rep(indent, level + 1) or ""
            
            local is_array = true
            local max_index = 0
            for k, _ in pairs(v) do
                if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then
                    is_array = false
                    break
                end
                max_index = math.max(max_index, k)
            end

            local parts
            if is_array then
                parts = {}
                for i = 1, max_index do
                    parts[i] = _encode(v[i] or json.null, _pretty)
                            end
                        else
                parts = {}
                for k, val in pairs(v) do
                    parts[#parts + 1] = string.format(
                        "%s%q: %s",
                        next_indent,
                        tostring(k),
                        _encode(val, _pretty)
                    )
                end
            end
            
            level = level - 1
            
            if is_array then
                if _pretty then
                    return "[\n" .. next_indent .. table.concat(parts, ",\n" .. next_indent) .. "\n" .. current_indent .. "]"
                else
                    return "[" .. table.concat(parts, ",") .. "]"
                end
            else
                if _pretty then
                    return "{\n" .. table.concat(parts, ",\n") .. "\n" .. current_indent .. "}"
                else
                    return "{" .. table.concat(parts, ",") .. "}"
                end
            end
        end
        return "null"
    end

    return _encode(val, pretty)
end

function json.decode(str)
    local pos = 1
    
    local function skip_whitespace()
        pos = string.find(str, "[^%s]", pos) or pos
    end
    
    local function decode_string()
        local quote = str:sub(pos, pos)
        if quote ~= '"' and quote ~= "'" then return nil end
        pos = pos + 1
        local parts = {}
        while pos <= #str do
            local c = str:sub(pos, pos)
            if c == quote then
                pos = pos + 1
                return table.concat(parts)
            elseif c == "\\" then
                pos = pos + 1
                if pos > #str then return nil end
                c = str:sub(pos, pos)
                if c == "n" then 
                    parts[#parts + 1] = "\n"
                elseif c == "r" then 
                    parts[#parts + 1] = "\r"
                elseif c == "t" then 
                    parts[#parts + 1] = "\t"
                elseif c == "\\" then 
                    parts[#parts + 1] = "\\"
                elseif c == '"' then 
                    parts[#parts + 1] = '"'
                elseif c == "'" then 
                    parts[#parts + 1] = "'"
                elseif c == "/" then 
                    parts[#parts + 1] = "/"
                elseif c == "b" then 
                    parts[#parts + 1] = "\b"
                elseif c == "f" then 
                    parts[#parts + 1] = "\f"
                else
                    parts[#parts + 1] = c
                end
                pos = pos + 1
            else
                parts[#parts + 1] = c
                pos = pos + 1
            end
        end
        return nil
    end
    
    local function decode_number()
        local start = pos
        while pos <= #str and string.find(str:sub(pos, pos), "[%d%.eE%+%-]") do
            pos = pos + 1
        end
        local num = tonumber(str:sub(start, pos - 1))
        if not num then pos = start end
        return num
    end
    
    local function decode_value()
        skip_whitespace()
        if pos > #str then return nil end
        local c = str:sub(pos, pos)
        
        if c == "{" then
            pos = pos + 1
            local obj = {}
            skip_whitespace()
            while pos <= #str do
                if str:sub(pos, pos) == "}" then
                    pos = pos + 1
                    return obj
                end
                local key = decode_string()
                if not key then return nil end
                skip_whitespace()
                if str:sub(pos, pos) ~= ":" then return nil end
                pos = pos + 1
                local val = decode_value()
                obj[key] = val
                skip_whitespace()
                if str:sub(pos, pos) == "}" then
                    pos = pos + 1
                    return obj
                elseif str:sub(pos, pos) ~= "," then
                    return nil
                end
                pos = pos + 1
                skip_whitespace()
            end
        elseif c == "[" then
            pos = pos + 1
            local arr = {}
            local index = 1
            skip_whitespace()
            while pos <= #str do
                if str:sub(pos, pos) == "]" then
                    pos = pos + 1
                    return arr
                end
                local val = decode_value()
                arr[index] = val
                index = index + 1
                skip_whitespace()
                if str:sub(pos, pos) == "]" then
                    pos = pos + 1
                    return arr
                elseif str:sub(pos, pos) ~= "," then
                    return nil
                end
                pos = pos + 1
                skip_whitespace()
            end
        elseif c == '"' or c == "'" then
            return decode_string()
        else
            local num = decode_number()
            if num then return num end
            if str:sub(pos, pos + 3) == "true" then
                pos = pos + 4
                return true
            elseif str:sub(pos, pos + 4) == "false" then
                pos = pos + 5
                return false
            elseif str:sub(pos, pos + 3) == "null" then
                pos = pos + 4
                return nil
            end
        end
        return nil
    end
    
    local result = decode_value()
    return result
end

--@region: antiaim_funcs (embedded minimal)
antiaim_funcs = antiaim_funcs or {}

(function()
    local data = { tickbase = { shifting = 0, charged = 0, list = {}, tickbase_max = 0 } }
    local LIST_MAX = 16
    for i = 1, LIST_MAX do data.tickbase.list[i] = 0 end

    local function net_update_start()
        local me = entity.get_local_player()
        if not me then return end
        
        local tickbase = entity.get_prop(me, 'm_nTickBase')
        if not tickbase then return end
        
        if tickbase > data.tickbase.tickbase_max then
            data.tickbase.tickbase_max = tickbase
        end
        
        local deficit = data.tickbase.tickbase_max - tickbase
        data.tickbase.charged = math.min(14, math.max(0, deficit - 1))
        data.tickbase.shifting = data.tickbase.charged
    end
    
    local function on_round_start()
        data.tickbase.tickbase_max = 0
        data.tickbase.charged = 0
        data.tickbase.shifting = 0
    end

    client.set_event_callback('net_update_start', net_update_start)
    client.set_event_callback('round_start', on_round_start)

    function antiaim_funcs.get_tickbase_shifting()
        return math.floor((data.tickbase.shifting or 0) + 0.5)
    end
    
    function antiaim_funcs.get_tickbase_charged()
        return math.floor((data.tickbase.charged or 0) + 0.5)
    end

    function antiaim_funcs.get_double_tap()
        return utils.weapon_ready() and (antiaim_funcs.get_tickbase_shifting() > 0)
    end
end)()
--@endregion

-- --@region: debug shift overlay
-- local _debug_shift = {}
-- client.set_event_callback('paint', function()
--     if not interface or not interface.visuals or not interface.visuals.lc_status then return end
--     if not interface.visuals.enabled_visuals:get() or not interface.visuals.lc_status:get() then return end
--     local charged = 0
--     if antiaim_funcs and antiaim_funcs.get_tickbase_charged then
--         charged = tonumber(antiaim_funcs.get_tickbase_charged()) or 0
--     end
--     renderer.text(10, 10, 200, 200, 200, 200, 'l', 0, string.format('charged: %dt', charged))
-- end)
-- --@endregion

--@region: resolver
resolver = {} do
    resolver.layers      = {}
    resolver.safepoints  = {}
    resolver.cache       = {}
    resolver.history     = {}
    resolver.feedback    = {}
    resolver.state_cache = {}
    resolver.layer_cache = {}
    resolver.precision   = {}
    resolver.shot_state  = {}

    function resolver:get_feedback(idx, state)
        if not idx then
            return nil
        end

        local state_key = state or self.state_cache[idx] or "unknown"
        self.feedback[idx] = self.feedback[idx] or {}

        local feedback = self.feedback[idx][state_key]
        if feedback then
            return feedback
        end

        feedback = {
            miss_streak = 0,
            hit_streak = 0,
            brute_step = 0,
            side_bias = 0,
            amp_bias = 0,
            last_side = 0,
            last_yaw = 0,
            last_amplitude = 0,
            base_amplitude = 0
        }

        self.feedback[idx][state_key] = feedback
        return feedback
    end

    function resolver:record_shot_result(idx, did_hit, reason)
        if not idx then return end
        if not (interface.aimbot.enabled_aimbot:get() and interface.aimbot.enabled_resolver_tweaks:get()) then return end
        if interface.aimbot.resolver_mode:get() ~= 'experimental' then return end

        local state_key = self.shot_state[idx] or self.state_cache[idx] or "unknown"
        local feedback = self:get_feedback(idx, state_key)
        if not feedback then return end

        if did_hit then
            feedback.hit_streak = feedback.hit_streak + 1
            feedback.miss_streak = 0
            feedback.brute_step = 0

            if feedback.last_side ~= 0 then
                feedback.side_bias = feedback.last_side
            end

            local amplitude_delta = (feedback.last_amplitude or 0) - (feedback.base_amplitude or 0)
            feedback.amp_bias = mathematic.clamp(amplitude_delta * 0.35, -10, 10)
            self.shot_state[idx] = nil
            return
        end

        if reason ~= "resolver" then
            feedback.hit_streak = 0
            feedback.amp_bias = feedback.amp_bias * 0.5
            self.shot_state[idx] = nil
            return
        end

        feedback.hit_streak = 0
        feedback.miss_streak = feedback.miss_streak + 1
        feedback.brute_step = (feedback.brute_step % 4) + 1

        local last_side = feedback.last_side ~= 0 and feedback.last_side or 1

        if feedback.brute_step == 1 then
            feedback.side_bias = -last_side
            feedback.amp_bias = 0
        elseif feedback.brute_step == 2 then
            feedback.side_bias = last_side
            feedback.amp_bias = 12
        elseif feedback.brute_step == 3 then
            feedback.side_bias = -last_side
            feedback.amp_bias = -8
        else
            feedback.side_bias = last_side
            feedback.amp_bias = 18
        end

        self.shot_state[idx] = nil
    end
    
    function resolver:calculate_layer_delta(idx)
        if not self.layers[idx] or not self.layers[idx][6] then return 0 end
        
        local layer6 = self.layers[idx][6]
        local prev_layer = self.layer_cache[idx] and self.layer_cache[idx][6]
        
        if not prev_layer then
            self.layer_cache[idx] = self.layer_cache[idx] or {}
            self.layer_cache[idx][6] = {
                m_cycle = layer6.m_cycle or 0,
                m_playback_rate = layer6.m_playback_rate or 0
            }
            return 0
        end
        
        local cycle_delta = (layer6.m_cycle or 0) - (prev_layer.m_cycle or 0)
        local rate_delta = (layer6.m_playback_rate or 0) - (prev_layer.m_playback_rate or 0)
        
        self.layer_cache[idx][6] = {
            m_cycle = layer6.m_cycle or 0,
            m_playback_rate = layer6.m_playback_rate or 0
        }
        
        return math.abs(cycle_delta) + math.abs(rate_delta * 10)
    end
    
    function resolver:calc_side(idx, animstate, velocity_2d, lby)
        if not animstate then return 0 end
        
        local eye_yaw = animstate.flEyeYaw or 0
        local goal_feet_yaw = animstate.flGoalFeetYaw or eye_yaw
        local last_feet_yaw = animstate.flLastFeetYaw or eye_yaw
        local move_yaw = animstate.flMoveYaw or eye_yaw
        local lean_amount = animstate.flLeanAmount or 0
        
        local lby_delta = lby and mathematic.angle_diff(eye_yaw, lby) or 0
        local goal_delta = mathematic.angle_diff(eye_yaw, goal_feet_yaw)
        local feet_delta = mathematic.angle_diff(eye_yaw, last_feet_yaw)
        local move_delta = mathematic.angle_diff(eye_yaw, move_yaw)
        
        local velocity_influence = math.exp(-velocity_2d / 100)
        local static_influence = 1 - velocity_influence
        
        local layer6 = self.layers[idx] and self.layers[idx][6]
        local cycle_rate = 0
        if layer6 and layer6.m_cycle and layer6.m_playback_rate then
            cycle_rate = layer6.m_playback_rate * (1 - math.abs(layer6.m_cycle - 0.5) * 2)
        end
        
        local lean_factor = math.abs(lean_amount) / 100
        local lean_direction = mathematic.sign(lean_amount)
        
        local walk_to_run = animstate.flWalkToRunTransition or 0
        local transition_factor = walk_to_run * (1 - walk_to_run) * 4
        
        local static_yaw = lby_delta * 0.6 + goal_delta * 0.4
        local dynamic_yaw = move_delta * 0.7 + feet_delta * 0.3
        local layer_yaw = cycle_rate * goal_delta * 50
        
        local calculated_yaw = static_yaw * velocity_influence + 
                              dynamic_yaw * static_influence + 
                              layer_yaw * transition_factor +
                              lean_direction * lean_factor * 30
        
        return mathematic.sign(calculated_yaw)
    end
    
    resolver.getMaxDesyncDelta = function(idx)
        if not idx or idx <= 0 then
            return nil
        end

        local animstate = player.get_animstate(idx)
        if not animstate then
            return nil
        end
        
        local feetSpeed = mathematic.clamp(animstate.m_flFeetSpeedForwardsOrSideWays or 0, 0, 1)
        local desyncDelta = ((animstate.m_flStopToFullRunningFraction or 0) * -0.3 - 0.2) * feetSpeed + 1
        local duckAmount = animstate.flDuckAmount or 0
        
        if duckAmount > 0.0 then
            local duckSpeed = duckAmount * feetSpeed
            desyncDelta = desyncDelta + duckSpeed * (0.5 - desyncDelta)
        end
        
        return desyncDelta
    end

    resolver.updateLayers = function(self, idx)
        if not idx then return false end

        local animLayers = player.get_animlayer(idx)
        if not animLayers then return false end
        
        self.layers[idx] = self.layers[idx] or {}
        local playerLayers = self.layers[idx]

        for i = 0, 12 do
            local layer = animLayers[i]
            if layer then
                playerLayers[i] = {
                    m_sequence = layer.m_sequence,
                    m_playback_rate = layer.m_playback_rate,
                    m_cycle = layer.m_cycle,
                    m_weight = layer.m_weight,
                    m_order = layer.m_order,
                    m_anim_time = layer.m_anim_time
                }
            end
        end
        return true
    end

    resolver.logic_experimental = function(self, idx)
        local animstate = player.get_animstate(idx)
        if not animstate then return end
        if not self:updateLayers(idx) then return end

        local _, _, _, velocity_2d = player.get_velocity(idx)
        if not velocity_2d then return end

        local enemy_state = utils.get_enemy_state(idx)
        local lby = entity.get_prop(idx, "m_flLowerBodyYawTarget") or 0
        local eye_yaw = animstate.flEyeYaw or 0
        self.state_cache[idx] = enemy_state
        local feedback = self:get_feedback(idx, enemy_state)

        local layers = self.layers[idx] or {}
        local layer3 = layers[3]
        local layer6 = layers[6]

        local side = self:calc_side(idx, animstate, velocity_2d, lby)

        if enemy_state == "air" or enemy_state == "airc" then
            local lean = animstate.flLeanAmount or 0
            if math.abs(lean) > 1 then
                side = mathematic.sign(lean)
            end
        elseif enemy_state == "duck" or enemy_state == "duck move" then
            local lby_delta = mathematic.angle_diff(eye_yaw, lby)
            if math.abs(lby_delta) > 5 then
                side = mathematic.sign(lby_delta)
            end
        end

        if layer3 and (layer3.m_weight or 0) > 0.01 then
            local lby_delta = mathematic.angle_diff(eye_yaw, lby)
            if math.abs(lby_delta) > 1 then
                side = mathematic.sign(lby_delta)
            end
        end

        if layer6 and velocity_2d > 10 then
            local calc_rate = velocity_2d / 260.0
            if layer6.m_playback_rate and layer6.m_playback_rate < calc_rate * 0.5 then
                side = -side
            end
        end

        if side == 0 then
            side = 1
        end

        local max_desync = self.getMaxDesyncDelta(idx) or 0
        local cold_desync = max_desync * 58.0
        
        local precision = self:compute_precision(animstate, velocity_2d, lby)
        self.precision[idx] = precision

        local vel_factor = math.exp(-velocity_2d / 160)
        local duck_amt = animstate.flDuckAmount or 0
        local duck_factor = 1 - duck_amt * duck_amt * 0.35
        local layer_activity = self:calculate_layer_delta(idx)
        local layer_factor = 1 - mathematic.clamp(layer_activity * 2.0, 0, 0.4)

        local amplitude = cold_desync * vel_factor * duck_factor * layer_factor
        self.history[idx] = self.history[idx] or {}
        self.history[idx][enemy_state] = self.history[idx][enemy_state] or {}

        local history = self.history[idx][enemy_state]
        if history and #history > 0 then
            local history_sum = 0
            for i = 1, #history do
                history_sum = history_sum + history[i]
            end

            local history_sign = mathematic.sign(history_sum)
            if history_sign ~= 0 and (not feedback or feedback.miss_streak == 0) then
                side = mathematic.sign(side * 0.65 + history_sign * 0.35)
                if side == 0 then
                    side = history_sign
                end
            end
        end

        amplitude = mathematic.clamp(amplitude, 10, 58)

        if feedback then
            feedback.base_amplitude = amplitude

            if feedback.side_bias ~= 0 then
                side = feedback.side_bias
            end

            amplitude = mathematic.clamp(amplitude + feedback.amp_bias, 8, 58)
        end

        local yaw = side * amplitude

        yaw = mathematic.clamp(yaw, -58, 58)
        
        if yaw >= 0 then
            yaw = math.floor(yaw + 0.5)
        else
            yaw = math.ceil(yaw - 0.5)
        end

        self.cache[idx] = yaw

        table.insert(history, yaw)
        if #history > 5 then
            table.remove(history, 1)
        end

        if feedback then
            feedback.last_side = mathematic.sign(yaw)
            feedback.last_yaw = yaw
            feedback.last_amplitude = math.abs(yaw)
        end

        player_list.SetForceBodyYawCheckbox(player_list, idx, true)
        player_list.SetBodyYaw(player_list, idx, yaw)
        player_list.SetCorrection(player_list, idx, false) -- skeet resolver sucks, turn it off

        local confidence = precision
        confidence = mathematic.clamp(confidence, 0.1, 1)
        self:updateSafety(idx, side, yaw, confidence)
    end

    resolver.updateSafety = function(self, idx, side, desync, precision)
        self.safepoints[idx] = self.safepoints[idx] or {}
        local safepoints = self.safepoints[idx]

        local mag = mathematic.clamp(math.abs(desync), 0, 58)
        local p = mathematic.clamp(precision or 0.5, 0, 1)

        for i = 1, 3 do
            safepoints[i] = safepoints[i] or { m_flDesync = 0, m_playback_rate = nil }
        end

        safepoints[1].m_flDesync = 0
        safepoints[2].m_flDesync = mag
        safepoints[3].m_flDesync = -mag

        safepoints[1].m_precision = p
        safepoints[2].m_precision = p
        safepoints[3].m_precision = p
    end

    resolver.transition = function(self, walkToRun, state, updateInc, velocityXY)
        local TRANSITION_WALK_TO_RUN = false
        local TRANSITION_RUN_TO_WALK = true
        local TRANSITION_SPEED = 2.0
        local PLAYER_RUN_SPEED = 260.0
        local WALK_SPEED_MODIFIER = 0.52

        walkToRun   = walkToRun or 0
        updateInc   = updateInc or 0
        velocityXY = velocityXY or 0
        state       = state or TRANSITION_RUN_TO_WALK

        if walkToRun > 0 and walkToRun < 1 then
            if state == TRANSITION_WALK_TO_RUN then
                walkToRun = walkToRun + updateInc * TRANSITION_SPEED
            else
                walkToRun = walkToRun - updateInc * TRANSITION_SPEED
            end
            walkToRun = mathematic.clamp(walkToRun, 0, 1)
        end

        local threshold = PLAYER_RUN_SPEED * WALK_SPEED_MODIFIER
        if velocityXY > threshold and state == TRANSITION_RUN_TO_WALK then
            state = TRANSITION_WALK_TO_RUN
            walkToRun = math.max(0.01, walkToRun)
        elseif velocityXY < threshold and state == TRANSITION_WALK_TO_RUN then
            state = TRANSITION_RUN_TO_WALK
            walkToRun = math.min(0.99, walkToRun)
        end

        return walkToRun, state
    end

    resolver.predictedFootYaw = function(self, m_flFootYawLast, m_flEyeYaw, m_flLowerBodyYawTarget, m_flWalkToRunTransition, m_vecVelocity, m_flMinBodyYaw, m_flMaxBodyYaw, enemyState)
        local safeNum = function(val, default)
            return (type(val) == "number" and val) or default
        end

        local clamp              = mathematic.clamp
        local angle_diff         = mathematic.angle_diff
        local angle_normalize    = mathematic.angle_normalize
        local approach_angle     = mathematic.approach_angle

        local tick_interval = safeNum(globals.tickinterval(), 0)

        m_flFootYawLast            = safeNum(m_flFootYawLast, 0)
        m_flEyeYaw                 = safeNum(m_flEyeYaw, 0)
        m_flLowerBodyYawTarget     = safeNum(m_flLowerBodyYawTarget, 0)
        m_flMinBodyYaw             = safeNum(m_flMinBodyYaw, -58)
        m_flMaxBodyYaw             = safeNum(m_flMaxBodyYaw, 58)
        m_vecVelocity              = safeNum(m_vecVelocity, 0)

        local velocityXY = math.min(m_vecVelocity, 260.0)
        local footYaw    = clamp(m_flFootYawLast, -180, 180)
        local yawDelta   = safeNum(angle_diff(m_flEyeYaw, footYaw), 0)

        if yawDelta > m_flMaxBodyYaw then
            footYaw = m_flEyeYaw - m_flMaxBodyYaw
        elseif yawDelta < m_flMinBodyYaw then
            footYaw = m_flEyeYaw + m_flMinBodyYaw
        end

        footYaw = angle_normalize(footYaw)

        if velocityXY > 0.1 then
            footYaw = m_flEyeYaw
        else
            footYaw = approach_angle(m_flLowerBodyYawTarget, footYaw, tick_interval * 100)
        end

        return footYaw
    end
    
    resolver.compute_precision = function(self, animstate, velocity_2d, lby)
        local clamp = mathematic.clamp
        local angle_diff = mathematic.angle_diff

        local eye_yaw = animstate.flEyeYaw or 0
        local goal_feet_yaw = animstate.flGoalFeetYaw or eye_yaw
        local last_feet_yaw = animstate.flLastFeetYaw or eye_yaw
        local move_yaw = animstate.flMoveYaw or eye_yaw

        local d1 = lby and angle_diff(eye_yaw, lby) or 0
        local d2 = angle_diff(eye_yaw, goal_feet_yaw)
        local d3 = angle_diff(eye_yaw, last_feet_yaw)
        local d4 = angle_diff(eye_yaw, move_yaw)

        local mean = (d1 + d2 + d3 + d4) / 4
        local var = ((d1 - mean)^2 + (d2 - mean)^2 + (d3 - mean)^2 + (d4 - mean)^2) / 4
        local sigma = math.sqrt(var)
        local coherence = 1 - clamp(sigma / 60, 0, 1)

        local vel_norm = clamp(1 - velocity_2d / 260, 0, 1)
        local ground = (animstate.bOnGround and 1 or 0)
        local duck_inv = clamp(1 - (animstate.flDuckAmount or 0), 0, 1)
        local lby_align = lby and (1 - clamp(math.abs(angle_diff(eye_yaw, lby)) / 58, 0, 1)) or 0.5
        local cycle = animstate.flFeetCycle or 0
        local cycle_stability = 1 - math.abs(math.sin(cycle * math.pi))

        local update_prox = 0
        if type(animstate.flNextLowerBodyYawUpdateTime) == "number" then
            local dt = animstate.flNextLowerBodyYawUpdateTime - globals.curtime()
            local s = 0.18
            update_prox = math.exp(-(dt * dt) / (2 * s * s))
        end

        local precision = vel_norm * 0.25 +
                           ground   * 0.15 +
                           duck_inv * 0.10 +
                           lby_align* 0.15 +
                           cycle_stability * 0.10 +
                           coherence * 0.15 +
                           update_prox * 0.10
        return clamp(precision, 0, 1)
    end
    
    resolver.logic_autopilot = function(self, idx)
        local animstate = player.get_animstate(idx)
        if not animstate then return end
        if not resolver:updateLayers(idx) then return end

        local vx, vy, vz, velocity_2d = player.get_velocity(idx)
        if not velocity_2d then return end
        
        local max_desync = resolver.getMaxDesyncDelta(idx)
        if not max_desync then return end

        local walk_to_run, _ = resolver:transition(
            animstate.flWalkToRunTransition or 0,
            false,
            animstate.flLastUpdateIncrement or 0,
            velocity_2d
        )

        local enemy_state = utils.get_enemy_state(idx)
        local prev_state = self.state_cache[idx]
        if prev_state ~= enemy_state then
            self.history[idx] = nil
            self.state_cache[idx] = enemy_state
        end

        local lby = entity.get_prop(idx, "m_flLowerBodyYawTarget")
        if not lby then return end
        
        local predicted_yaw = resolver:predictedFootYaw(
            animstate.flLastFeetYaw or 0,
            animstate.flEyeYaw or 0,
            lby,
            walk_to_run,
            velocity_2d,
            animstate.flMinBodyYaw or -58,
            animstate.flMaxBodyYaw or 58,
            enemy_state
        )
        if not predicted_yaw then return end

        local eye_yaw = animstate.flEyeYaw or 0
        
        local side = self:calc_side(idx, animstate, velocity_2d, lby)
        
        local precision = self:compute_precision(animstate, velocity_2d, lby)
        self.precision[idx] = precision
        
        local base_desync = max_desync * 58
        
        local velocity_factor = math.exp(-velocity_2d / 130)
        
        local duck_amt = animstate.flDuckAmount or 0
        local duck_factor = 1 - duck_amt * duck_amt * 0.4
        
        local feet_cycle = animstate.flFeetCycle or 0
        local feet_speed = animstate.m_flFeetSpeedForwardsOrSideWays or 0
        local cycle_factor = 1 - math.abs(math.sin(feet_cycle * math.pi)) * feet_speed * 0.2
        
        local lean_amount = animstate.flLeanAmount or 0
        local lean_factor = 1 / (1 + math.abs(lean_amount) * 0.01)
        
        local stop_to_full = animstate.m_flStopToFullRunningFraction or 0
        local ground_factor = 0.3 + 0.7 * (1 - stop_to_full)
        
        local desync_value = base_desync * velocity_factor * duck_factor * cycle_factor * lean_factor * ground_factor
        desync_value = mathematic.clamp(desync_value, 0, 58)

        if desync_value > 0 then
            local amplitude = 0.5 + 0.5 * (self.precision[idx] or 0.5)
            local raw_yaw = side * desync_value * amplitude
            local final_yaw = raw_yaw >= 0 and math.floor(raw_yaw + 0.5) or math.ceil(raw_yaw - 0.5)
            
            final_yaw = mathematic.clamp(final_yaw, -58, 58)

            resolver.cache[idx] = final_yaw
            player_list.SetForceBodyYawCheckbox(player_list, idx, true)
            player_list.SetBodyYaw(player_list, idx, final_yaw)
            resolver:updateSafety(idx, side, final_yaw, self.precision[idx])
        end
    end

    resolver.setup = function(self)
        if not (interface.aimbot.enabled_aimbot:get() and interface.aimbot.enabled_resolver_tweaks:get()) then return end

        local local_player = entity.get_local_player()
        if not local_player then return end
        
        local health = entity.get_prop(local_player, "m_iHealth")
        if not health or health <= 0 then return end

        local enemies = entity.get_players(true)
        if not enemies then return end

        local mode = interface.aimbot.resolver_mode:get()

        for _, idx in ipairs(enemies) do
            repeat
                if not entity.is_alive(idx) or entity.is_dormant(idx) then break end
                
                local player_info = utils.get_player_info(idx)
                if not player_info then break end
                
                if player_info.__fakeplayer then
                    player_list.SetForceBodyYawCheckbox(player_list, idx, false)
                    player_list.SetForcePitchCheckbox(player_list, idx, false)
                    player_list.SetBodyYaw(player_list, idx, 0)
                    player_list.SetForcePitch(player_list, idx, 0)
                    player_list.SetCorrection(player_list, idx, false)
                    break
                end

                if mode == 'autopilot' then
                    self:logic_autopilot(idx)
                elseif mode == 'experimental' then
                    self:logic_experimental(idx)
                end
            until true
        end
    end
end

client.set_event_callback('net_update_end', function()
    resolver:setup()
end)
--@endregion

--@region: silent shot
silent_shot = {} do
    silent_shot.setup = function(self, cmd)
        if not (interface.aimbot.enabled_aimbot:get() and interface.aimbot.silent_shot:get()) then return end

        local local_player = entity.get_local_player()
        local local_wpn = entity.get_player_weapon(local_player)
        if local_wpn then
            local last_shot_time = entity.get_prop(local_wpn, "m_fLastShotTime")
            local time_since_last_shot = globals.curtime() - last_shot_time
            
            if time_since_last_shot <= 0.025 then
                cmd.no_choke = true
            end
        end
    end
end

client.set_event_callback('setup_command', function(cmd)
    silent_shot:setup(cmd)
end)
--@endregion

--@region: allow force recharge
allow_force_recharge = {} do
    allow_force_recharge.last = false
    allow_force_recharge.state = false

    allow_force_recharge.setup = function(self, cmd)
        if not (interface.aimbot.enabled_aimbot:get() and interface.aimbot.force_recharge:get()) then return end

        local exploit_active = (ui.get(ui_references.double_tap[1]) and ui.get(ui_references.double_tap[2])) or 
                             (ui.get(ui_references.on_shot_anti_aim[1]) and ui.get(ui_references.on_shot_anti_aim[2]))

        if exploit_active ~= self.last then
            self.last = exploit_active
            
            if self.last then
                self.state = false
            end
        end

        if not ui.get(ui_references.enabled[1]) then
            ui.set(ui_references.enabled[2], "Always on")
            self.state = nil
            return
        end

        if self.state == false and cmd.weaponselect == 0 then
            ui.set(ui_references.enabled[2], "On hotkey")
            self.state = true
        elseif self.state == true or cmd.weaponselect ~= 0 then
            ui.set(ui_references.enabled[2], "Always on")
            self.state = nil
        end
    end

    allow_force_recharge.shutdown = function()
        ui.set(ui_references.enabled[2], "Always on")
    end
end

client.set_event_callback('setup_command', function(cmd)
    allow_force_recharge:setup(cmd)
end)

client.set_event_callback('shutdown', allow_force_recharge.shutdown)
--@endregion

--@region: sync aimbot hotkeys
sync_aimbot_hotkeys = {} do
    sync_aimbot_hotkeys.items = {
        ui_references.enabled[2],
        ui_references.multipoint[2],
        ui_references.minimum_damage_override[2],
        ui_references.safe_point,
        ui_references.body_aim,
        ui_references.stop[2],
        ui_references.double_tap[2]
    }

    sync_aimbot_hotkeys.on_hotkey = function(item)
        utils.sync_hotkey_to_weapon_types(item, ui_references.weapon_type)
    end

    sync_aimbot_hotkeys.update = function()
        local enabled = interface.utility.sync_aimbot_hotkeys:get()

        for i = 1, #sync_aimbot_hotkeys.items do
            utils.toggle_ui_callback(sync_aimbot_hotkeys.items[i], sync_aimbot_hotkeys.on_hotkey, enabled)
        end
    end

    sync_aimbot_hotkeys.shutdown = function()
        for i = 1, #sync_aimbot_hotkeys.items do
            utils.ui_callback_unset(sync_aimbot_hotkeys.items[i], sync_aimbot_hotkeys.on_hotkey)
        end
    end

    interface.utility.sync_aimbot_hotkeys:set_callback(sync_aimbot_hotkeys.update)

    sync_aimbot_hotkeys.update()
    client.set_event_callback('shutdown', sync_aimbot_hotkeys.shutdown)
end
--@endregion

--@region: quick stop in air
quick_stop_in_air = {} do
    quick_stop_in_air.ticks = 0
    quick_stop_in_air.setup = function(self, cmd)
        if not (interface.aimbot.enabled_aimbot:get() and interface.aimbot.quick_stop:get() and interface.aimbot.quick_stop.hotkey:get()) then 
            return 
        end

        local lp = entity.get_local_player()
        if not lp or not entity.is_alive(lp) then 
            return 
        end

        local players = entity.get_players(true)
        if not players then 
            return 
        end

        local origin = entity.get_prop(lp, "m_vecOrigin")
        local lpvec = vector(origin)

        local weapon = entity.get_player_weapon(lp)
        local weap_class = entity.get_classname(weapon)

        if weap_class ~= "CWeaponSSG08" then 
            return 
        end

        local vecvelocity = { entity.get_prop(lp, "m_vecVelocity") }
        local check_vel = vecvelocity[3] > 0

        local flags = entity.get_prop(lp, "m_fFlags")
        local jumpcheck = bit.band(flags, 1) == 0 

        local enemy = client.current_threat()
        if not enemy or not jumpcheck then 
            return 
        end

        if not check_vel then 
            return 
        end

        for i = 1, #players do
            local p = players[i]
            if p then
                local x1, y1, z1 = entity.get_prop(p, "m_vecOrigin")
                local dist = player.distance3d(lpvec.x, lpvec.y, lpvec.z, x1, y1, z1)
                if dist <= 1500 then
                    if cmd.quick_stop then
                        if (globals.tickcount() - self.ticks) > 3 then
                            cmd.in_speed = 1
                        end
                    else
                        self.ticks = globals.tickcount()
                    end
                end
            end
        end
    end
end

-- client.set_event_callback('paint', function()
--     if (interface.aimbot.enabled_aimbot:get() and interface.aimbot.quick_stop:get() and interface.aimbot.quick_stop.hotkey:get()) then 
--         renderer.indicator(214, 214, 214, 255, 'AS')
--     end
-- end)

client.set_event_callback('setup_command', function(cmd)
    quick_stop_in_air:setup(cmd)
end)
--@endregion

--@region: noscope distance
noscope_distance = {} do
    noscope_distance._ref = pui.reference('rage', 'aimbot', 'automatic scope')
    noscope_distance._active = false

    noscope_distance.get_weapon_distance = function()
        local me = entity.get_local_player()
        if not me then return nil end
        local weapon = entity.get_player_weapon(me)
        if not weapon then return nil end
        local id = entity.get_prop(weapon, 'm_iItemDefinitionIndex')
        local sel = interface.aimbot.noscope_weapons:get() or {}
        if type(sel) ~= 'table' then return nil end
        if id == 38 or id == 11 then -- autosnipers
            if utils.contains(sel, 'autosnipers') then
                return interface.aimbot.noscope_distance_autosnipers:get()
            end
        elseif id == 40 then -- scout
            if utils.contains(sel, 'scout') then
                return interface.aimbot.noscope_distance_scout:get()
            end
        elseif id == 9 then -- awp
            if utils.contains(sel, 'awp') then
                return interface.aimbot.noscope_distance_awp:get()
            end
        end
        return nil
    end

    noscope_distance.loop = function()
        if not (interface.aimbot.enabled_aimbot:get() and interface.aimbot.noscope_distance:get()) then
            if noscope_distance._active then
                noscope_distance._ref:override()
                noscope_distance._active = false
            end
            return
        end

        local me = entity.get_local_player()
        if not me or not entity.is_alive(me) then
            if noscope_distance._active then
                noscope_distance._ref:override()
                noscope_distance._active = false
            end
            return
        end

        local max_distance = noscope_distance.get_weapon_distance()
        if not max_distance then
            if noscope_distance._active then
                noscope_distance._ref:override()
                noscope_distance._active = false
            end
            return
        end

        local target = client.current_threat()
        if not target or not entity.is_alive(target) or entity.is_dormant(target) then
            if noscope_distance._active then
                noscope_distance._ref:override()
                noscope_distance._active = false
            end
            return
        end

        local lx, ly, lz = entity.get_prop(me, 'm_vecOrigin')
        local tx, ty, tz = entity.get_prop(target, 'm_vecOrigin')
        if not (lx and ly and lz and tx and ty and tz) then return end
        local dist = player.distance3d(lx, ly, lz, tx, ty, tz)

        if dist <= max_distance then
            noscope_distance._ref:override(false)
            noscope_distance._active = true
        else
            noscope_distance._ref:override(true)
            noscope_distance._active = true
        end
    end
end

client.set_event_callback('paint', function()
    noscope_distance.loop()
end)

client.set_event_callback('shutdown', function()
    noscope_distance._ref:override()
end)
--@endregion

--@region: hitchance override
hitchance_override = {} do
    local SCOPED_PROFILES = {
        autosnipers = true,
        scout = true,
        awp = true
    }

    hitchance_override._active = false
    hitchance_override._hotkey_active = false
    hitchance_override._updated_this_tick = false
    hitchance_override._saved_values = { }

    local function set_override(self, value)
        local weapon_type = ui.get(ui_references.weapon_type)
        if weapon_type == nil then
            return false
        end

        if self._saved_values[weapon_type] == nil then
            self._saved_values[weapon_type] = ui.get(ui_references.minimum_hitchance)
        end

        ui.set(ui_references.minimum_hitchance, value)
        self._active = true
        return true
    end

    local function unset_override(self)
        if not self._active and next(self._saved_values) == nil then
            return
        end

        local weapon_type = ui.get(ui_references.weapon_type)

        for saved_weapon_type, saved_value in pairs(self._saved_values) do
            ui.set(ui_references.weapon_type, saved_weapon_type)
            ui.set(ui_references.minimum_hitchance, saved_value)
            self._saved_values[saved_weapon_type] = nil
        end

        if weapon_type ~= nil then
            ui.set(ui_references.weapon_type, weapon_type)
        end

        self._active = false
    end

    local function reset_tick_state(self)
        self._hotkey_active = false
        self._updated_this_tick = false
    end

    local function get_weapon_profile(weapon)
        local weapon_info = csgo_weapons(weapon)
        if not weapon_info then return nil end

        local weapon_type = weapon_info.type
        local weapon_index = weapon_info.idx

        if weapon_type == 'pistol' then
            if weapon_index == 1 then
                return 'deagle'
            end

            if weapon_index == 64 then
                return 'revolver'
            end

            return 'pistols'
        end

        if weapon_type == 'sniperrifle' then
            if weapon_index == 40 then
                return 'scout'
            end

            if weapon_index == 9 then
                return 'awp'
            end

            return 'autosnipers'
        end

        return nil
    end

    local function is_quickpeek_active()
        return ui.get(ui_references.quickpeek[1]) and ui.get(ui_references.quickpeek[2])
    end

    local function get_distance_to_threat(lp)
        local threat = client.current_threat()
        if not threat or not entity.is_alive(threat) or entity.is_dormant(threat) then
            return nil
        end

        local lx, ly, lz = entity.get_prop(lp, 'm_vecOrigin')
        local tx, ty, tz = entity.get_prop(threat, 'm_vecOrigin')
        if not (lx and ly and lz and tx and ty and tz) then
            return nil
        end

        return player.distance3d(lx, ly, lz, tx, ty, tz)
    end

    local function get_override_value(lp, profile_key, profile)
        local options = profile.options:get() or {}
        local state = utils.get_state()
        if type(options) ~= 'table' then
            return nil
        end

        if utils.contains(options, 'hotkey') and interface.aimbot.hitchance_override_hotkey:get() and interface.aimbot.hitchance_override_hotkey.hotkey:get() then
            return profile.hotkey:get(), true
        end

        if utils.contains(options, 'crouch') and (state == 'duck' or state == 'duck move') then
            return profile.crouch:get(), false
        end

        if utils.contains(options, 'peek assist') and is_quickpeek_active() then
            return profile.peek_assist:get(), false
        end

        if SCOPED_PROFILES[profile_key] and utils.contains(options, 'no scope') then
            local distance = get_distance_to_threat(lp)
            if distance and distance <= profile.no_scope_distance:get() then
                return profile.no_scope:get(), false
            end
        end

        if utils.contains(options, 'in air') and (state == 'air' or state == 'airc') then
            return profile.in_air:get(), false
        end

        return nil, false
    end

    hitchance_override.on_setup_command = function(self)
        reset_tick_state(self)

        if not (interface.aimbot.enabled_aimbot:get() and interface.aimbot.hitchance_override:get()) then
            unset_override(self)
            return
        end

        local lp = entity.get_local_player()
        if not lp or not entity.is_alive(lp) then
            unset_override(self)
            return
        end

        local weapon = entity.get_player_weapon(lp)
        if not weapon then
            unset_override(self)
            return
        end

        local profile_key = get_weapon_profile(weapon)
        if not profile_key then
            unset_override(self)
            return
        end

        local profile = interface.aimbot.hitchance_override_profiles[profile_key]
        if not profile then
            unset_override(self)
            return
        end

        local value, hotkey_active = get_override_value(lp, profile_key, profile)
        if value == nil then
            unset_override(self)
            return
        end

        if not set_override(self, value) then
            unset_override(self)
            return
        end

        self._hotkey_active = hotkey_active == true
        self._updated_this_tick = true
    end

    hitchance_override.shutdown = function(self)
        unset_override(self)
        reset_tick_state(self)
    end
end

client.set_event_callback('setup_command', function()
    hitchance_override:on_setup_command()
end)

client.set_event_callback('paint', function()
    if hitchance_override._hotkey_active and hitchance_override._updated_this_tick then
        renderer.indicator(214, 214, 214, 255, 'HC')
    end
end)

client.set_event_callback('shutdown', function()
    hitchance_override:shutdown()
end)
--@endregion

--@region: widgets
widgets = {} do
    local SNAP = 12
    local PAD = 4
    local LINE_ALPHA = 40
    local LINE_ALPHA_SNAP = 80
    local DIM_ALPHA = 120
    local DIM_COLOR = { 0, 0, 0 }

    widgets.SNAP = SNAP
    widgets.PAD = PAD
    widgets.items = {}
    widgets.order = {}
    widgets.state = {}
    widgets.is_dragging = false
    widgets.active_id = nil
    widgets.db_key_prefix = "noctua.widgets.positions"
    widgets.version = 1
    widgets.lines_alpha = 0
    widgets.frames_alpha = 0
    widgets.widget_alpha = {}
    widgets.dim_alpha = 0

    local function screen_key()
        local w, h = client.screen_size()
        return tostring(w) .. "x" .. tostring(h)
    end

    function widgets.register(def)
        if not def or not def.id then return end
        widgets.items[def.id] = def
        table.insert(widgets.order, def.id)
        local st = widgets.state[def.id] or {}
        st.anchor_x = st.anchor_x or (def.defaults and def.defaults.anchor_x or "center")
        st.anchor_y = st.anchor_y or (def.defaults and def.defaults.anchor_y or "center")
        st.offset_x = st.offset_x or (def.defaults and def.defaults.offset_x or 0)
        st.offset_y = st.offset_y or (def.defaults and def.defaults.offset_y or 0)
        widgets.state[def.id] = st
    end

    function widgets.load_from_db()
        local key = widgets.db_key_prefix .. "." .. screen_key()
        local ok, data = pcall(database.read, key)
        if ok and type(data) == "table" then
            for id, st in pairs(data) do
                if type(st) == "table" then
                    widgets.state[id] = {
                        anchor_x = st.anchor_x,
                        anchor_y = st.anchor_y,
                        offset_x = st.offset_x or 0,
                        offset_y = st.offset_y or 0,
                    }
                end
            end
        end
    end

    local function export_positions()
        local out = {}
        for id, st in pairs(widgets.state) do
            out[id] = {
                anchor_x = st.anchor_x,
                anchor_y = st.anchor_y,
                offset_x = st.offset_x,
                offset_y = st.offset_y,
            }
        end
        return out
    end

    function widgets.save_all()
        local key = widgets.db_key_prefix .. "." .. screen_key()
        local data = export_positions()
        pcall(database.write, key, data)
    end

    local function compute_center(id)
        local sw, sh = client.screen_size()
        local st = widgets.state[id]
        local cx = (st.anchor_x == "center") and (sw / 2 + (st.offset_x or 0)) or (st.offset_x or 0)
        local cy = (st.anchor_y == "center") and (sh / 2 + (st.offset_y or 0)) or (st.offset_y or 0)
        return cx, cy
    end

    local function clamp(v, mn, mx)
        if v < mn then return mn end
        if v > mx then return mx end
        return v
    end

    local function round(n)
        return math.floor(n + 0.5)
    end

    local function get_menu_rect()
        local mx, my = ui.menu_position()
        local mw, mh = 0, 0
        if ui.menu_size then
            mw, mh = ui.menu_size()
        end
        return mx or 0, my or 0, mw or 0, mh or 0
    end

    local function point_in_rect(px, py, rx, ry, rw, rh)
        return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
    end

    local function rects_intersect(ax, ay, aw, ah, bx, by, bw, bh)
        return ax < bx + bw and ax + aw > bx and ay < by + bh and ay + ah > by
    end

    local function get_rect(id)
        local def = widgets.items[id];
        if not def then return end
        local st = widgets.state[id]
        local cx, cy = compute_center(id)
        local content_w, content_h = 100, 40
        if def.get_size then
            local ok, w, h = pcall(def.get_size, st)
            if ok and type(w) == "number" and type(h) == "number" then
                content_w, content_h = w, h
            end
        end

        st._smooth_w = st._smooth_w or content_w
        st._smooth_h = st._smooth_h or content_h
        local lerp_speed = globals.frametime() * 12
        st._smooth_w = mathematic.lerp(st._smooth_w, content_w, lerp_speed)
        st._smooth_h = mathematic.lerp(st._smooth_h, content_h, lerp_speed)
        widgets.state[id] = st

        local x = cx - st._smooth_w / 2
        local y = cy - st._smooth_h / 2
        return x, y, st._smooth_w, st._smooth_h, cx, cy
    end

    local function hit_test(id, mx, my)
        local x, y, w, h = get_rect(id)
        if not x then return false end
        x = x - PAD;
        y = y - PAD;
        w = w + PAD * 2;
        h = h + PAD * 2;
        return mx >= x and mx <= x + w and my >= y and my <= y + h
    end

    function widgets.paint()
        local menuOpen = ui.is_menu_open()
        if menuOpen then return end

        local function widget_enabled_paint(id)
            if not interface.visuals.enabled_visuals:get() then return false end
            if id == "debug_window" then
                return interface.visuals.window:get()
            elseif id == "watermark" then
                return interface.visuals.watermark:get()
            elseif id == "crosshair_indicators" then
                return interface.visuals.crosshair_indicators:get()
            elseif id == "lc_status" then
                return interface.visuals.lc_status:get()
            elseif id == "screen_logging" then
                if not interface.visuals.logging:get() then return false end
                local opts = interface.visuals.logging_style:get() or {}
                return utils.contains(opts, "screen")
            elseif id == "bomb_timer" then
                return interface.visuals.bomb_timer:get()
            end
            return true
        end

        for _, id in ipairs(widgets.order) do
            if not widget_enabled_paint(id) then goto continue end
            local def = widgets.items[id]
            local x, y, w, h, cx, cy = get_rect(id)
            if w and h and w > 0 and h > 0 then
                def.draw({
                    id = id,
                    x = x, y = y, w = w, h = h,
                    cx = cx, cy = cy,
                    edit_mode = false,
                    snapped_x = false, snapped_y = false
                })
            end
            ::continue::
        end
    end

    function widgets.paint_ui()
        local menuOpen = ui.is_menu_open()
        local local_player = entity.get_local_player()

        local target_alpha = (menuOpen and widgets.is_dragging) and LINE_ALPHA or 0
        widgets.lines_alpha = mathematic.lerp(widgets.lines_alpha or 0, target_alpha, globals.frametime() * 12)

        local target_frame = menuOpen and 1 or 0
        widgets.frames_alpha = mathematic.lerp(widgets.frames_alpha or 0, target_frame, globals.frametime() * 12)

        if not menuOpen then widgets.is_dragging = false end

        local sw, sh = client.screen_size()
        local mx, my = ui.mouse_position()
        local m1 = client.key_state(0x01)
        local function widget_enabled(id)
            if not interface.visuals.enabled_visuals:get() then return false end
            if id == "debug_window" then
                return interface.visuals.window:get()
            elseif id == "watermark" then
                return interface.visuals.watermark:get()
            elseif id == "crosshair_indicators" then
                return interface.visuals.crosshair_indicators:get()
            elseif id == "lc_status" then
                return interface.visuals.lc_status:get()
            elseif id == "damage_indicator" then
                return interface.visuals.damage_indicator:get()
            elseif id == "screen_logging" then
                if not interface.visuals.logging:get() then return false end
                local opts = interface.visuals.logging_style:get() or {}
                return utils.contains(opts, "screen")
            elseif id == "bomb_timer" then
                return interface.visuals.bomb_timer:get()
            end
            return true
        end

        do
            local any_enabled = false
            for _, id in ipairs(widgets.order) do
                if widget_enabled(id) then any_enabled = true; break end
            end
            local target_alpha_do = (menuOpen and widgets.is_dragging and any_enabled) and LINE_ALPHA or 0
            widgets.lines_alpha = mathematic.lerp(widgets.lines_alpha or 0, target_alpha_do, globals.frametime() * 12)
        end

        local allow_interact = menuOpen

        local target_dim = (allow_interact and widgets.is_dragging) and DIM_ALPHA or 0
        widgets.dim_alpha = mathematic.lerp(widgets.dim_alpha or 0, target_dim, globals.frametime() * 12)
        do
            local da = math.floor((widgets.dim_alpha or 0) + 0.5)
            if da > 0 then
                renderer.rectangle(0, 0, sw, sh, DIM_COLOR[1], DIM_COLOR[2], DIM_COLOR[3], da)
            end
        end

        local a = math.floor(widgets.lines_alpha + 0.5)
        local any_enabled_draw = false
        for _, id in ipairs(widgets.order) do
            if widget_enabled(id) then any_enabled_draw = true; break end
        end
        if any_enabled_draw and widgets.is_dragging and a > 0 then
            renderer.rectangle(sw / 2, 0, 1, sh, 255, 255, 255, a)
            renderer.rectangle(0, sh / 2, sw, 1, 255, 255, 255, a)
            renderer.rectangle(0, 20, sw, 1, 255, 255, 255, a)
        end

        if not allow_interact and (widgets.frames_alpha or 0) < 0.01 then return end

        if allow_interact and m1 and not widgets.is_dragging then
            local menu_x, menu_y, menu_w, menu_h = get_menu_rect()
            if not point_in_rect(mx, my, menu_x, menu_y, menu_w, menu_h) then
                for idx = #widgets.order, 1, -1 do
                    local id = widgets.order[idx]
                    if widget_enabled(id) and hit_test(id, mx, my) then
                        widgets.is_dragging = true
                        widgets.active_id = id
                        local _, _, _, _, cx, cy = get_rect(id)
                        widgets.drag_dx = cx - mx
                        widgets.drag_dy = cy - my
                        break
                    end
                end
            end
        elseif allow_interact and widgets.is_dragging and m1 then
            -- dragging preview handled in frame drawing below
        elseif allow_interact and widgets.is_dragging and not m1 then
            local id = widgets.active_id
            if id and widgets.items[id] then
                local sw_, sh_ = client.screen_size()
                local cx = mx + (widgets.drag_dx or 0)
                local cy = my + (widgets.drag_dy or 0)
                local snapped_x = (id ~= "damage_indicator") and math.abs(cx - sw_ / 2) <= SNAP
                local snapped_y = (id ~= "damage_indicator") and math.abs(cy - sh_ / 2) <= SNAP
                local snapped_top = (id ~= "damage_indicator") and math.abs(cy - 20) <= SNAP
                if snapped_x then cx = sw_ / 2 end
                if snapped_y then cy = sh_ / 2 end
                if snapped_top then cy = 20 end
                local _, _, w, h = get_rect(id)
                if w and h then
                    local min_cx = (w / 2) + PAD
                    local max_cx = sw_ - (w / 2) - PAD
                    local min_cy = (h / 2) + PAD
                    local max_cy = sh_ - (h / 2) - PAD
                    cx = clamp(cx, min_cx, max_cx)
                    cy = clamp(cy, min_cy, max_cy)

                    local st = widgets.state[id]
                    if snapped_x then
                        st.anchor_x = "center"; st.offset_x = cx - sw_ / 2
                    else
                        st.anchor_x = nil; st.offset_x = cx
                    end
                    if snapped_y then
                        st.anchor_y = "center"; st.offset_y = cy - sh_ / 2
                    else
                        st.anchor_y = nil; st.offset_y = cy
                    end
                    widgets.state[id] = st
                end
            end
            widgets.is_dragging = false
            widgets.active_id = nil
            widgets.drag_dx = 0;
            widgets.drag_dy = 0
        end

        for _, id in ipairs(widgets.order) do
            local enabled = widget_enabled(id)
            widgets.widget_alpha = widgets.widget_alpha or {}
            local wa = widgets.widget_alpha[id] or 0
            local target = enabled and 1 or 0
            widgets.widget_alpha[id] = mathematic.lerp(wa, target, globals.frametime() * 12)

            local x, y, w, h, cx, cy = get_rect(id)
            if not (w and h and w > 0 and h > 0) then goto continue end

            local ratio_widget = (widgets.widget_alpha[id] or 0) * (widgets.frames_alpha or 0)
            if ratio_widget <= 0.01 then goto continue end

            if widgets.is_dragging and widgets.active_id == id and allow_interact and enabled then
                local sw2, sh2 = client.screen_size()
                local mx2, my2 = ui.mouse_position()
                cx = mx2 + (widgets.drag_dx or 0)
                cy = my2 + (widgets.drag_dy or 0)
                local snapped_x = (id ~= "damage_indicator") and math.abs(cx - sw2 / 2) <= SNAP
                local snapped_y = (id ~= "damage_indicator") and math.abs(cy - sh2 / 2) <= SNAP
                local snapped_top = (id ~= "damage_indicator") and math.abs(cy - 20) <= SNAP
                if snapped_x then cx = sw2 / 2 end
                if snapped_y then cy = sh2 / 2 end
                if snapped_top then cy = 20 end
                local min_cx = (w / 2) + PAD
                local max_cx = sw2 - (w / 2) - PAD
                local min_cy = (h / 2) + PAD
                local max_cy = sh2 - (h / 2) - PAD
                cx = clamp(cx, min_cx, max_cx)
                cy = clamp(cy, min_cy, max_cy)

                local menu_x, menu_y, menu_w, menu_h = get_menu_rect()
                local try_x = cx - w / 2
                local try_y = cy - h / 2
                local rect_x = try_x - PAD
                local rect_y = try_y - PAD
                local rect_w = w + PAD * 2
                local rect_h = h + PAD * 2
                if rects_intersect(rect_x, rect_y, rect_w, rect_h, menu_x, menu_y, menu_w, menu_h) then
                    if widgets.last_safe_cx and widgets.last_safe_cy then
                        cx = widgets.last_safe_cx
                        cy = widgets.last_safe_cy
                    end
                else
                    widgets.last_safe_cx = cx
                    widgets.last_safe_cy = cy
                end

                x = cx - w / 2
                y = cy - h / 2
            end

            local hovered = false
            if allow_interact and enabled then
                local mx3, my3 = ui.mouse_position()
                local menu_x, menu_y, menu_w, menu_h = get_menu_rect()
                if not point_in_rect(mx3, my3, menu_x, menu_y, menu_w, menu_h) then
                    hovered = hit_test(id, mx3, my3)
                end
            end

            local base_alpha = 20
            if allow_interact and widgets.is_dragging and widgets.active_id == id then
                base_alpha = 60
            elseif hovered then
                base_alpha = 35
            end

            local ratio = math.max(0, math.min(1, ratio_widget))
            local bg_alpha = math.floor(math.min(30, base_alpha) * ratio + 0.5)
            local border_alpha = math.floor(math.min(80, base_alpha + 25) * ratio + 0.5)

            local rect_x = x - PAD
            local rect_y = y - PAD
            local rect_w = w + PAD * 2
            local rect_h = h + PAD * 2
            local rx, ry, rw, rh = round(rect_x), round(rect_y), round(rect_w), round(rect_h)
            renderer.rectangle(rx + 1, ry + 1, rw - 2, rh - 2, 255, 255, 255, bg_alpha)

            local inset = 2
            local oa = border_alpha
            -- top & bottom
            renderer.rectangle(rx + inset, ry, rw - inset * 2, 1, 255, 255, 255, oa)
            renderer.rectangle(rx + inset, ry + rh - 1, rw - inset * 2, 1, 255, 255, 255, oa)
            -- left & right
            renderer.rectangle(rx, ry + inset, 1, rh - inset * 2, 255, 255, 255, oa)
            renderer.rectangle(rx + rw - 1, ry + inset, 1, rh - inset * 2, 255, 255, 255, oa)

            local sw3, sh3 = client.screen_size()
            local snapped_x_now, snapped_y_now, snapped_top_now = false, false, false
            if allow_interact and enabled and id ~= "damage_indicator" then
                snapped_x_now = math.abs(cx - sw3 / 2) <= SNAP
                snapped_y_now = math.abs(cy - sh3 / 2) <= SNAP
                snapped_top_now = math.abs(cy - 20) <= SNAP
            end
            if allow_interact and widgets.is_dragging and widgets.active_id ~= "damage_indicator" then
                if snapped_x_now then
                    renderer.rectangle(sw3 / 2, 0, 1, sh3, 255, 255, 255, LINE_ALPHA_SNAP)
                end
                if snapped_y_now then
                    renderer.rectangle(0, sh3 / 2, sw3, 1, 255, 255, 255, LINE_ALPHA_SNAP)
                end
                if snapped_top_now then
                    renderer.rectangle(0, 20, sw3, 1, 255, 255, 255, LINE_ALPHA_SNAP)
                end
            end

            local def = widgets.items[id]
            if allow_interact and enabled then
                def.draw({ id = id, x = x, y = y, w = w, h = h, cx = cx, cy = cy, edit_mode = true, snapped_x = snapped_x_now, snapped_y = snapped_y_now })
            end
            ::continue::
        end
    end
end
--@endregion

--@region: visuals
visuals = {} do 
    visuals.flag_texture = nil
    visuals.flag_requested = false

    visuals.fetch_flag = function()
        if visuals.flag_requested then return end
        visuals.flag_requested = true

        http.get("http://ip-api.com/json/", function(success, response)
            if success and response.status == 200 then
                local data = json.decode(response.body)
                if data and data.countryCode then
                    local cc = string.lower(data.countryCode)
                    local flag_url = string.format("https://flagcdn.com/w40/%s.png", cc)
                    
                    http.get(flag_url, function(s, r)
                        if s and r.status == 200 then
                            visuals.flag_texture = renderer.load_png(r.body, 40, 30)
                        end
                    end)
                end
            end
        end)
    end
    
    visuals.fetch_flag()

    visuals.window = function(self, base_x, base_y, align)
        self.windowAlpha = self.windowAlpha or 0
        self._ping_spike_blink_phase = self._ping_spike_blink_phase or 0

        local frameTime = globals.frametime()
        local fadeSpeedSetting = 10 * frameTime
        local local_player = entity.get_local_player()
        local health = local_player and entity.get_prop(local_player, "m_iHealth") or 0
        local menuOpen = ui.is_menu_open()

        local is_game_over = entity.get_all("CCSGameRulesProxy")[1] and entity.get_prop(entity.get_all("CCSGameRulesProxy")[1], "m_gamePhase") >= 5
        local windowEnabled = interface.visuals.enabled_visuals:get()
                            and interface.visuals.window:get()
                            and not is_game_over
                            and ((local_player and health > 0) or menuOpen)

        local targetAlpha = windowEnabled and 255 or 0
        self.windowAlpha = mathematic.lerp(self.windowAlpha, targetAlpha, fadeSpeedSetting)

        if self.windowAlpha < 1 then return end

        local show_flag = interface.visuals.window_flag:get()
        local target = client.current_threat()
        local t_name = "none"
        local t_state = "none"
        local resolver_enabled = interface.aimbot.enabled_aimbot:get() and interface.aimbot.enabled_resolver_tweaks:get()
        self._yaw_cache = self._yaw_cache or { val = "none", for_target = nil, time = 0 }
        local t_yaw = resolver_enabled and "none" or "off"
        local cur_time = globals.realtime()

        if target then
            local player_info = utils.get_player_info(target)
            if player_info then
                t_name = ffi.string(player_info.__name)
                t_state = utils.get_enemy_state(target) or "none"
                if resolver_enabled then
                    if player_info.__fakeplayer or player_info.bot then
                        t_yaw = "none (bot)"
                        self._yaw_cache = { val = t_yaw, for_target = target, time = cur_time }
                    else
                        local update = false
                        if self._yaw_cache.for_target ~= target then
                            update = true
                        elseif (cur_time - self._yaw_cache.time) > 0.15 then
                            update = true
                        end
                        if update then
                            self._yaw_cache = {
                                val = tostring(resolver.cache[target] or 0),
                                for_target = target,
                                time = cur_time
                            }
                        end
                        t_yaw = self._yaw_cache.val
                    end
                else
                    t_yaw = "off"
                    self._yaw_cache = { val = t_yaw, for_target = target, time = cur_time }
                end
            end
        end

        local line_spacing = 13
        local y = base_y
        local indent = (align == 'l') and "   " or "" 
        local r, g, b = unpack(interface.visuals.accent.color.value)
        local name_w = select(1, renderer.measure_text("lb", _name))
        local ver_w = select(1, renderer.measure_text("l", _version))
        local spacing = 4 
        local total_w = name_w + spacing + ver_w

        local start_x = base_x
        if align == 'c' then
            start_x = base_x - (total_w / 2)
        elseif align == 'r' then
            start_x = base_x - total_w
        end

        renderer.text(start_x, y, r, g, b, self.windowAlpha, "lb", 0, _name)
        renderer.text(start_x + name_w + spacing, y, 255, 255, 255, self.windowAlpha, "l", 0, _version)

        y = y + line_spacing + 5

        local nick_str = _nickname or "user"
        renderer.text(base_x, y, 255, 255, 255, self.windowAlpha, align, 0, nick_str)
        
        if show_flag and visuals.flag_texture then
            local nick_w = select(1, renderer.measure_text("l", nick_str))
            local flag_w, flag_h = 16, 11
            local padding = 4
            local flag_x = base_x
            
            if align == 'c' then
                flag_x = base_x + (nick_w / 2) + padding
            elseif align == 'r' then
                flag_x = base_x - nick_w - flag_w - padding
            else
                flag_x = base_x + nick_w + padding
            end
            
            renderer.texture(visuals.flag_texture, flag_x, y, flag_w, flag_h, 255, 255, 255, self.windowAlpha)
        end
        
        y = y + line_spacing
        
        local hits = _G.noctua_runtime.stats.hits
        local misses = _G.noctua_runtime.stats.misses
        local ratio = (hits > 0 and misses == 0) and 100 or ((hits + misses) > 0 and math.floor((hits / (hits + misses)) * 100) or 0)
        local aimbot_text = indent .. "- aimbot: " .. hits .. "/" .. misses .. " (" .. ratio .. "%)"
        renderer.text(base_x, y, 215, 215, 215, self.windowAlpha, align, 0, aimbot_text)
        y = y + line_spacing
        
        local latency_ms = math.floor(client.latency() * 1000 + 0.5)
        local latency_str = "- latency: " .. latency_ms .. "ms"
        local full_latency_text = indent .. latency_str
        
        local scoreboard_ping = utils.get_scoreboard_ping()
        local ping_diff = math.floor(scoreboard_ping - latency_ms + 0.5)
        local ping_spike_enabled = ui.get(ui_references.ps[1])
        local ping_spike_active = ping_spike_enabled and (#ui_references.ps < 2 or ui.get(ui_references.ps[2]))
        
        local latency_x = base_x
        if align == 'c' then
            latency_x = base_x - (select(1, renderer.measure_text("l", full_latency_text)) / 2)
        elseif align == 'r' then
            latency_x = base_x - select(1, renderer.measure_text("l", full_latency_text))
        end
        
        renderer.text(latency_x, y, 215, 215, 215, self.windowAlpha, "l", 0, full_latency_text)
        
        local is_local_server = latency_ms == 0
        if ping_diff >= 0 and not is_local_server then
            local r, g, b = 220, 200, 100
            
            if ping_diff < 50 then
                local ratio = ping_diff / 50
                r = 220
                g = 120 + (80 * ratio)
                b = 120
            else
                local ratio = math.min((ping_diff - 50) / 100, 1)
                r = 220 - (100 * ratio)
                g = 200
                b = 120 - (20 * ratio)
            end
            
            local diff_text = " (+" .. ping_diff .. "ms)"
            local full_w = select(1, renderer.measure_text("l", full_latency_text))
            local diff_alpha = self.windowAlpha

            if not ping_spike_active then
                local clamped_diff = math.min(math.max(ping_diff, 0), 120)
                local fade_ratio = 1 - (clamped_diff / 120)
                local blink_speed = 0.7 + (fade_ratio * 1.6)
                self._ping_spike_blink_phase = (self._ping_spike_blink_phase + (frameTime * blink_speed * math.pi * 2)) % (math.pi * 2)
                local pulse = (math.sin(self._ping_spike_blink_phase) + 1) * 0.5
                local alpha_ratio = 0.3 + (pulse * 0.7)
                diff_alpha = self.windowAlpha * alpha_ratio
            else
                self._ping_spike_blink_phase = 0
            end
            
            renderer.text(latency_x + full_w, y, r, g, b, diff_alpha, "l", 0, diff_text)
        end
        y = y + line_spacing
        
        local aa_state = utils.get_state()
        if _G.noctua_runtime.use_active then aa_state = "use"
        elseif _G.noctua_runtime.manual_active then aa_state = "manual"
        elseif _G.noctua_runtime.safe_head_active then aa_state = "safe head" end

        renderer.text(base_x, y, 215, 215, 215, self.windowAlpha, align, 0, indent .. "- state: " .. aa_state)
        y = y + line_spacing
        
        local dormant_enabled = interface.aimbot.dormant_enabled:get() and interface.aimbot.dormant_enabled.hotkey:get()
        if dormant_enabled then
            local state_prefix = indent .. "- dormant: "
            renderer.text(base_x, y, 215, 215, 215, self.windowAlpha, align, 0, state_prefix)
            local state_w = select(1, renderer.measure_text("l", state_prefix))
            
            local dormant_state = _G.noctua_runtime.dormant_state or "waiting"
            local state_color = dormant_state == "active" and {140, 200, 140} or {215, 215, 215}
            renderer.text(base_x + state_w, y, state_color[1], state_color[2], state_color[3], self.windowAlpha, "l", 0, dormant_state)
            y = y + line_spacing + 6
        else
            y = y + 6
        end

        if t_yaw ~= "off" then
            renderer.text(base_x, y, 255, 255, 255, self.windowAlpha, align, 0, "resolver")
            y = y + line_spacing
            renderer.text(base_x, y, 215, 215, 215, self.windowAlpha, align, 0, indent .. "- target: " .. t_name:lower())
            y = y + line_spacing
            renderer.text(base_x, y, 215, 215, 215, self.windowAlpha, align, 0, indent .. "- state: " .. t_state)
            y = y + line_spacing
            renderer.text(base_x, y, 215, 215, 215, self.windowAlpha, align, 0, indent .. "- yaw: " .. t_yaw)
            y = y + line_spacing + 6
        end

        local isDT = ui.get(ui_references.double_tap[1]) and ui.get(ui_references.double_tap[2])
        local isOS = ui.get(ui_references.on_shot_anti_aim[1]) and ui.get(ui_references.on_shot_anti_aim[2])
        
        if isDT or isOS then
            renderer.text(base_x, y, 255, 255, 255, self.windowAlpha, align, 0, "exploit")
            y = y + line_spacing

            local exp_type = isDT and "dt" or "osaa"
            local exp_state = "ready"

            if isDT then
                local dt_ready = antiaim_funcs.get_double_tap()
                local tickbase = antiaim_funcs.get_tickbase_shifting()
                
                if tickbase >= 4 and dt_ready then
                    exp_state = "ready"
                elseif not utils.weapon_ready() then
                    exp_state = "waiting"
                else
                    exp_state = "ready"
                end
            end

            renderer.text(base_x, y, 215, 215, 215, self.windowAlpha, align, 0, indent .. "- type: " .. exp_type)
            y = y + line_spacing
            renderer.text(base_x, y, 215, 215, 215, self.windowAlpha, align, 0, indent .. "- state: " .. exp_state)
        end
    end

    visuals.animated_text = {
        base = "noctua",
        timeSpeed = 2.1,
        colors = {
            { r = 225, g = 255, b = 255, a = 255 },
            { r = 120, g = 162, b = 183, a = 255 }
        },
        render = function(self, x, y, alignment, overallAlpha)
            local alpha1 = math.floor(self.colors[1].a * (overallAlpha / 255))
            local alpha2 = math.floor(self.colors[2].a * (overallAlpha / 255))
            local animatedStr = table.concat(colors.shimmer(
                globals.realtime() * self.timeSpeed, 
                self.base, 
                self.colors[1].r, self.colors[1].g, self.colors[1].b, alpha1, 
                self.colors[2].r, self.colors[2].g, self.colors[2].b, alpha2
            ))
            renderer.text(x, y, 255, 255, 255, overallAlpha, alignment, 1000, animatedStr)
        end
    }

    visuals.emoji = {} do
        local e = {}
        e.state = 'idle'
        e.state_until = 0
        e.blink_until = 0
        e.next_blink = (globals.realtime and globals.realtime()) or 0
        e.next_blink = e.next_blink + 1.5
        e.next_variation = e.next_blink + 0.5
        e.cached_idle_face = '( ^-^ )'
        e.cached_state_face = '( ^-^ )'
        e.override_face = nil
        e.override_until = 0

        local function rand(t)
            return t[math.random(1, #t)]
        end

        local eyes_neutral   = { '^', '-', 'o', 'O', 'u', 'U', 'x', '>', '<' }
        local eyes_happy     = { '^', 'o', 'O', 'u', 'U' }
        local eyes_sad       = { '>', '<', '-', 'x' }
        local mouths_neutral = { '-', '_', 'w', '~' }
        local mouths_happy   = { 'w', 'v', 'u', 'o' }
        local mouths_sad     = { '-', '_' }
        local cheeks_opts    = { '', '//' }

        local function compose(l_eye, mouth, r_eye, cheeks)
            cheeks = cheeks or ''
            if cheeks ~= '' then
                return string.format('( %s%s%s%s%s )', cheeks, l_eye, mouth, r_eye, cheeks)
            end
            return string.format('( %s%s%s )', l_eye, mouth, r_eye)
        end

        e.gen_face = function(state, wink)
            if wink then
                local l_eye = rand({ '^', 'o', '>' })
                local r_eye = '~'
                local mouth = '_'
                return string.format('( %s_%s )', l_eye, r_eye)
            end
            if state == 'happy' then
                local l_eye = rand(eyes_happy)
                local r_eye = rand(eyes_happy)
                local mouth = rand(mouths_happy)
                local cheeks = rand(cheeks_opts)
                return compose(l_eye, mouth, r_eye, cheeks)
            elseif state == 'sad' then
                local l_eye = rand(eyes_sad)
                local r_eye = rand(eyes_sad)
                local faces = {
                    string.format('( %s-%s )', l_eye, r_eye),
                    string.format('( %s_%s )', l_eye, r_eye),
                    '( >-< )',
                    '( >_< )'
                }
                return rand(faces)
            else -- idle
                local l_eye = rand(eyes_neutral)
                local r_eye = rand(eyes_neutral)
                local mouth = rand(mouths_neutral)
                local cheeks = rand(cheeks_opts)
                return compose(l_eye, mouth, r_eye, cheeks)
            end
        end

        e.update_idle = function()
            local now = globals.realtime()
            if now >= (e.next_blink or 0) then
                e.blink_until = now + 0.18
                e.next_blink = now + 2.0 + math.random()
            end
            if now >= (e.next_variation or 0) and now >= (e.state_until or 0) then
                e.cached_idle_face = e.gen_face('idle', false)
                e.next_variation = now + 2.0 + math.random() * 2.0
            end
        end

        e.get_face = function()
            local now = globals.realtime()
            if e.override_face and now < (e.override_until or 0) then
                return e.override_face
            end
            if now < (e.state_until or 0) then
                if (e._last_state_sample or 0) + 0.6 <= now then
                    e.cached_state_face = e.gen_face(e.state, false)
                    e._last_state_sample = now
                end
                return e.cached_state_face
            end
            if now < (e.blink_until or 0) then
                return e.gen_face('idle', true)
            end
            return e.cached_idle_face or '( ^-^ )'
        end

        e.set_state = function(st, dur)
            e.state = st
            e.state_until = globals.realtime() + (dur or 1.6)
            e.cached_state_face = e.gen_face(st, false)
        end

        e.on_player_death = function(ev)
            local me = entity.get_local_player()
            if not me then return end
            local attacker = client.userid_to_entindex(ev.attacker)
            local victim = client.userid_to_entindex(ev.userid)
            if attacker == me and victim ~= me then
                local dur = 2.5
                e.set_state('happy', dur)
                local faces = { '( //w// )', '( ^o^ )', '( ^w^ )', '( >w< )', '( ^-^ )', '( *_* )' }
                e.override_face = faces[math.random(1, #faces)]
                e.override_until = globals.realtime() + dur
            elseif victim == me then
                local dur = 3.0
                e.set_state('sad', dur)
                e.override_face = '( T_T )'
                e.override_until = globals.realtime() + dur
            end
        end
        e.on_player_spawn = function(ev)
            local me = entity.get_local_player()
            if not me then return end
            local who = client.userid_to_entindex(ev.userid)
            if who == me then
                e.state = 'idle'
                e.state_until = 0
                e.blink_until = 0
                e.next_blink = globals.realtime() + 1.5
                e.next_variation = e.next_blink + 0.5
                e.cached_idle_face = '( ^-^ )'
                e.cached_state_face = '( ^-^ )'
                e.override_face = nil
                e.override_until = 0
            end
        end
        visuals.emoji = e
    end

    client.set_event_callback('player_death', function(e)
        visuals.emoji.on_player_death(e)
    end)
    client.set_event_callback('player_spawn', function(e)
        visuals.emoji.on_player_spawn(e)
    end)

    visuals.indicators = function(self, base_x, base_y)
        local frameTime = globals.frametime()
        local fadeSpeedBase = 10
        local fadeSpeedSetting = fadeSpeedBase * frameTime
        local local_player = entity.get_local_player()
        local health = local_player and entity.get_prop(local_player, "m_iHealth") or 0
        local style = (interface.visuals.crosshair_style and interface.visuals.crosshair_style:get()) or 'default'
        local isEmoji = (style == 'emoji')
        local isCenteredStyle = (style == 'center') or isEmoji

        local fade_lerp_t = fadeSpeedSetting
        local position_lerp_t = fadeSpeedSetting

        if isCenteredStyle then
            fade_lerp_t = fade_lerp_t * 1.3
            position_lerp_t = position_lerp_t * 1.2
        end

        local is_scoreboard = client.key_state(0x09) -- TAB
        local game_rules = entity.get_all("CCSGameRulesProxy")[1]
        local menuOpen = ui.is_menu_open()

        local is_game_over = game_rules and entity.get_prop(game_rules, "m_gamePhase") >= 5
        local is_halftime = game_rules and entity.get_prop(game_rules, "m_gamePhase") == 4
        local is_timeout = game_rules and (
            entity.get_prop(game_rules, "m_bTerroristTimeOutActive") == 1 or 
            entity.get_prop(game_rules, "m_bCTTimeOutActive") == 1
        )
        local is_waiting = game_rules and entity.get_prop(game_rules, "m_bMatchWaitingForResume") == 1
        local is_restarting = game_rules and entity.get_prop(game_rules, "m_bGameRestart") == 1
        local is_freeze_period = game_rules and entity.get_prop(game_rules, "m_bFreezePeriod") == 1

        local is_scoped = local_player and entity.get_prop(local_player, "m_bIsScoped") == 1
        
        local indicatorsEnabled = interface.visuals.enabled_visuals:get()
                                  and interface.visuals.crosshair_indicators:get()
                                  and not is_game_over
                                  and not is_timeout
                                  and not is_halftime
                                  and not is_waiting
                                  and not is_restarting
                                  and ((local_player and (health > 0) and not is_scoreboard) or menuOpen)

        local scopeAlpha = is_scoped and (255 * 0.5) or 255
        self.scopeAlpha = mathematic.lerp(self.scopeAlpha or 255, scopeAlpha, fade_lerp_t)

        local targetAlpha = indicatorsEnabled and self.scopeAlpha or 0
        self.indicatorsAlpha = mathematic.lerp(self.indicatorsAlpha or 0, targetAlpha, fade_lerp_t)
        
        if self.indicatorsAlpha < 1 then 
            return
        end

        local r1, g1, b1, a1 = unpack(interface.visuals.accent.color.value)
        self.animated_text.colors[1] = { r = r1, g = g1, b = b1, a = a1 }
        local r2, g2, b2, a2 = unpack(interface.visuals.secondary.color.value)
        self.animated_text.colors[2] = { r = r2, g = g2, b = b2, a = a2 }

        local state = utils.get_state()
        if _G.noctua_runtime.use_active then
            state = "use"
        elseif _G.noctua_runtime.manual_active then
            state = "manual"
        elseif _G.noctua_runtime.safe_head_active then
            state = "safe head"
        end
        local isOS = ui.get(ui_references.on_shot_anti_aim[1]) and ui.get(ui_references.on_shot_anti_aim[2])
        local isDT = ui.get(ui_references.double_tap[1]) and ui.get(ui_references.double_tap[2])
        local isDMG = ui.get(ui_references.minimum_damage_override[1]) and ui.get(ui_references.minimum_damage_override[2])
        local isHC = hitchance_override and hitchance_override._hotkey_active == true and hitchance_override._updated_this_tick == true

        local align_text = ((style == 'center') or isEmoji) and 'c' or 'l'
        local align_title = ((style == 'center') or isEmoji) and 'cb' or 'lb'


        if not self.element_positions then
            self.element_positions = {
                noctua = base_y + 10,
                state = base_y + 20,
                rapid = base_y + 30,
                osaa = base_y + 40,
                dmg = base_y + 50,
                hc = base_y + 60
            }
            self.element_target_positions = {
                noctua = base_y + 10,
                state = base_y + 20,
                rapid = base_y + 30,
                osaa = base_y + 40,
                dmg = base_y + 50,
                hc = base_y + 60
            }
        end

        self.element_target_positions.noctua = base_y + 10
        self.element_target_positions.state = self.element_target_positions.noctua + 10

        local dt = antiaim_funcs.get_double_tap()
        local tickbase = antiaim_funcs.get_tickbase_shifting()

        local targetRapidAlpha = 0
        local targetReloadAlpha = 0

        if ui.get(ui_references.double_tap[1]) and ui.get(ui_references.double_tap[2]) then
            if tickbase >= 4 and dt then
                targetRapidAlpha = 255
                targetReloadAlpha = 0
            elseif not utils.weapon_ready() then
                targetRapidAlpha = 0
                targetReloadAlpha = 100
            else
                targetRapidAlpha = 255
                targetReloadAlpha = 0
            end
        end

        self.rapidAlpha = mathematic.lerp(self.rapidAlpha or 0, targetRapidAlpha, fade_lerp_t)
        self.reloadAlpha = mathematic.lerp(self.reloadAlpha or 0, targetReloadAlpha, fade_lerp_t)
        self.rapidAlpha = mathematic.clamp(self.rapidAlpha, 0, 255)
        self.reloadAlpha = mathematic.clamp(self.reloadAlpha, 0, 255)

        local smoothRapidAlpha = (self.rapidAlpha / 255) * self.indicatorsAlpha
        local smoothReloadAlpha = (self.reloadAlpha / 255) * self.indicatorsAlpha

        if smoothRapidAlpha >= 1 or smoothReloadAlpha >= 1 then
            self.element_target_positions.rapid = self.element_target_positions.state + 10
            local osaa_offset = 10
            self.element_target_positions.osaa = self.element_target_positions.rapid + osaa_offset
        else
            self.element_target_positions.osaa = self.element_target_positions.state + 10
        end

        self.osaaAlpha = mathematic.lerp(self.osaaAlpha or 0, isOS and 255 or 0, fade_lerp_t)
        local smoothOsaaAlpha = (self.osaaAlpha / 255) * self.indicatorsAlpha

        if smoothOsaaAlpha >= 1 then
            self.element_target_positions.dmg = self.element_target_positions.osaa + 10
        elseif smoothRapidAlpha >= 1 or smoothReloadAlpha >= 1 then
            self.element_target_positions.dmg = self.element_target_positions.rapid + 10
        else
            self.element_target_positions.dmg = self.element_target_positions.state + 10
        end

        self.dmgAlpha = mathematic.lerp(self.dmgAlpha or 0, isDMG and 255 or 0, fade_lerp_t)
        local smoothDmgAlpha = (self.dmgAlpha / 255) * self.indicatorsAlpha

        if smoothDmgAlpha >= 1 then
            self.element_target_positions.hc = self.element_target_positions.dmg + 10
        elseif smoothOsaaAlpha >= 1 then
            self.element_target_positions.hc = self.element_target_positions.osaa + 10
        elseif smoothRapidAlpha >= 1 or smoothReloadAlpha >= 1 then
            self.element_target_positions.hc = self.element_target_positions.rapid + 10
        else
            self.element_target_positions.hc = self.element_target_positions.state + 10
        end

        self.hcAlpha = mathematic.lerp(self.hcAlpha or 0, isHC and 255 or 0, fade_lerp_t)
        local smoothHcAlpha = (self.hcAlpha / 255) * self.indicatorsAlpha

        self.element_positions.noctua = mathematic.lerp(self.element_positions.noctua, self.element_target_positions.noctua, position_lerp_t)
        self.element_positions.state = mathematic.lerp(self.element_positions.state, self.element_target_positions.state, position_lerp_t)
        self.element_positions.rapid = mathematic.lerp(self.element_positions.rapid, self.element_target_positions.rapid, position_lerp_t)
        self.element_positions.osaa = mathematic.lerp(self.element_positions.osaa, self.element_target_positions.osaa, position_lerp_t)
        self.element_positions.dmg = mathematic.lerp(self.element_positions.dmg, self.element_target_positions.dmg, position_lerp_t)
        self.element_positions.hc = mathematic.lerp(self.element_positions.hc, self.element_target_positions.hc, position_lerp_t)

        local animate_on_scope = (interface.visuals.crosshair_animate_scope and interface.visuals.crosshair_animate_scope:get()) or false
        local use_scope_lerp = ((style == 'center') or isEmoji) and animate_on_scope

        self._last_scoped = self._last_scoped or false
        do
            local _, yaw = client.camera_angles()
            if yaw then
                self._last_yaw = self._last_yaw or yaw
                local dy = yaw - self._last_yaw
                while dy > 180 do dy = dy - 360 end
                while dy < -180 do dy = dy + 360 end
                local dir = (dy > 0 and 1) or (dy < 0 and -1) or 0
                local bias_speed = globals.frametime() * 10
                self._look_bias = mathematic.lerp(self._look_bias or 0, dir, bias_speed)

                if (not self._last_scoped) and is_scoped then
                    local sign = (dir ~= 0) and dir or (((self._look_bias or 0) < 0) and -1 or 1)
                    self._active_side = sign
                    self._unscoping_side = nil
                elseif self._last_scoped and (not is_scoped) then
                    self._unscoping_side = self._active_side or self._unscoping_side or 1
                    self._active_side = nil
                end

                self._last_yaw = yaw
            else
                if (not self._last_scoped) and is_scoped and (self._active_side == nil) then
                    self._active_side = (((self._look_bias or 0) < 0) and -1 or 1)
                    self._unscoping_side = nil
                end
            end
        end
        self._last_scoped = is_scoped

        local side_sign = (self._active_side or self._unscoping_side or 1)

        local scope_pos = self.scope_pos or 0
        local target_scope = is_scoped and 1 or 0
        scope_pos = mathematic.lerp(scope_pos, target_scope, position_lerp_t)
        self.scope_pos = scope_pos
        if (not is_scoped) and (scope_pos < 0.001) then
            self._unscoping_side = nil
        end

        local x_draw = base_x
        local x_title, x_state, x_rapid, x_waiting, x_osaa, x_dmg, x_hc

        if use_scope_lerp then
            local function lerp_x_centered(text, use_bold)
                local flags = use_bold and 'cb' or 'c'
                local w = select(1, renderer.measure_text(flags, text)) or 0
                local from = base_x
                local to = (side_sign > 0) and (base_x + w / 2 + 3) or (base_x - w / 2 - 3)
                return mathematic.lerp(from, to, scope_pos)
            end

            local title_text = isEmoji and ((visuals.emoji and visuals.emoji.get_face and visuals.emoji.get_face()) or ":)") or (self.animated_text.base or "noctua")
            x_title = lerp_x_centered(title_text, true)
            x_state  = lerp_x_centered(state, false)
            x_rapid  = lerp_x_centered("rapid", false)
            x_waiting = lerp_x_centered("waiting", false)
            x_osaa   = lerp_x_centered("osaa", false)
            x_dmg    = lerp_x_centered("dmg", false)
            x_hc     = lerp_x_centered("hc", false)
        end

        local state_r, state_g, state_b = 255, 255, 255

        if isEmoji then
            if visuals.emoji and visuals.emoji.update_idle then visuals.emoji.update_idle() end
            local face = (visuals.emoji and visuals.emoji.get_face and visuals.emoji.get_face()) or ':)'
            local emoji_y = self.element_positions.noctua
            if visuals.emoji and visuals.emoji.state_until and globals.realtime() < (visuals.emoji.state_until or 0) then
                local st = visuals.emoji.state
                local t = globals.realtime()
                if st == 'happy' then
                    emoji_y = emoji_y - math.sin(t * 10) * 2
                elseif st == 'sad' then
                    emoji_y = emoji_y + math.sin(t * 6) * 1
                end
            end
            renderer.text((x_title or x_draw), emoji_y, r1, g1, b1, self.indicatorsAlpha, align_title, 1000, face)
        else
            self.animated_text:render((x_title or x_draw), self.element_positions.noctua, align_title, self.indicatorsAlpha)
        end
        renderer.text((x_state or x_draw), self.element_positions.state, state_r, state_g, state_b, self.indicatorsAlpha, align_text, 1000, state)

        if smoothRapidAlpha >= 1 or smoothReloadAlpha >= 1 then
            renderer.text((x_rapid or x_draw), self.element_positions.rapid, 255, 255, 255, smoothRapidAlpha, align_text, 1000, "rapid")
            local _ts = (((self.animated_text and self.animated_text.timeSpeed)) * 3.0)
            local _a1 = math.min(255, math.floor(smoothReloadAlpha * 2.0))
            local _a2 = math.floor(smoothReloadAlpha * 0.7)
            local reloadStr = table.concat(colors.shimmer(
                globals.realtime() * _ts,
                "waiting",
                255, 255, 255, _a1,
                255, 255, 255, _a2
            ))
            renderer.text((x_waiting or x_rapid or x_draw), self.element_positions.rapid, 255, 255, 255, smoothReloadAlpha, align_text, 1000, reloadStr)
        end

        if smoothOsaaAlpha >= 1 then
            renderer.text((x_osaa or x_draw), self.element_positions.osaa, 255, 255, 255, smoothOsaaAlpha, align_text, 1000, "osaa")
        end
        
        if smoothDmgAlpha >= 1 then
            renderer.text((x_dmg or x_draw), self.element_positions.dmg, 255, 255, 255, smoothDmgAlpha, align_text, 1000, "dmg")
        end

        if smoothHcAlpha >= 1 then
            renderer.text((x_hc or x_draw), self.element_positions.hc, 255, 255, 255, smoothHcAlpha, align_text, 1000, "hc")
        end
    end

    visuals.damage_indicator = function(self, x, y)
        local me = entity.get_local_player()
        if not me or not entity.is_alive(me) then
            return
        end

        if not (interface.visuals.enabled_visuals:get() and interface.visuals.damage_indicator:get()) then
            return
        end

        local weapon = entity.get_player_weapon(me)
        local weap_name = entity.get_classname(weapon) or ""
        local lower_name = weap_name:lower()

        local is_knife = false
        local is_grenade = false

        local is_knife = false
        if weapon or weap_name then
            if entity.get_classname(weapon) == "CKnife" then
                is_knife = true
            end
            if string.find(lower_name, "grenade") or string.find(lower_name, "flashbang") then
                is_grenade = true
            end
        end

        local is_override = ui.get(ui_references.minimum_damage_override[1]) and ui.get(ui_references.minimum_damage_override[2])
        local damage_value = is_override and ui.get(ui_references.minimum_damage_override[3]) or ui.get(ui_references.minimum_damage)

        local frameTime = globals.frametime()
        local fadeSpeed = 10 * frameTime

        self.damage_indicator_state = self.damage_indicator_state or {}
        local dmg_state = self.damage_indicator_state

        dmg_state.current_value = dmg_state.current_value or damage_value
        dmg_state.current_value = mathematic.lerp(dmg_state.current_value, damage_value, frameTime * 30)

        local animation_delta = math.abs(dmg_state.current_value - damage_value)
        local display_value = math.floor(dmg_state.current_value + 0.5)
        local text = ""
        if display_value > 100 then
            text = string.format("+%d", display_value - 100)
        else
            text = tostring(display_value)
        end

        local target_alpha = is_override and 255 or 80

        if is_knife or is_grenade then
            target_alpha = 0
        end

        dmg_state.alpha = mathematic.lerp(dmg_state.alpha or 0, target_alpha, fadeSpeed)

        if dmg_state.alpha < 1 then
            return
        end

        local base_color = is_override and 255 or 215
        local r, g, b, a = base_color, base_color, base_color, dmg_state.alpha

        if animation_delta > 0.05 then
            local blur_alpha = math.min(a * 0.18, animation_delta * 8)

            renderer.text(x - 1, y, r, g, b, blur_alpha, 'c', 1000, text)
            renderer.text(x + 1, y, r, g, b, blur_alpha, 'c', 1000, text)
            renderer.text(x, y - 1, r, g, b, blur_alpha * 0.65, 'c', 1000, text)
            renderer.text(x, y + 1, r, g, b, blur_alpha * 0.65, 'c', 1000, text)
        end

        renderer.text(x, y, r, g, b, a, 'c', 1000, text)
    end

    visuals._lc_state = visuals._lc_state or { dt_prev = false, last_ticks = 0, last_label = "lc status", last_color = {255,255,255}, last_update = 0, alpha = 0, display_duration = 1.3, fade_duration = 0.25 }

    local function _lc_classify(t)
        if (t or 0) <= 0 then return "failed", {255, 70, 70} end
        if t <= 2 then return "bad", {255, 130, 80} end
        if t <= 4 then return "ok", {200, 200, 200} end
        if t <= 7 then return "good", {80, 220, 120} end
        if t <= 9 then return "great", {120, 200, 255} end
        if t <= 11 then return "excellent", {160, 255, 160} end
        if t == 12 then return "ideal lc", {120, 255, 200} end
        if t == 13 then return "god lc", {180, 130, 255} end
        return "world threat lc", {255, 120, 190}
    end

    function visuals:_update_lc_state()
        local st = self._lc_state
        local dt_on = ui.get(ui_references.double_tap[1]) and ui.get(ui_references.double_tap[2])
        local charged = tonumber(antiaim_funcs.get_tickbase_charged and antiaim_funcs.get_tickbase_charged() or 0) or 0
        if dt_on then
            st._last_shift = charged
        end
        if st.dt_prev and not dt_on then
            local ticks = tonumber(st._last_shift or 0) or 0
            st.last_ticks = ticks
            st.last_label, st.last_color = _lc_classify(ticks)
            st.last_update = (globals.realtime and globals.realtime()) or 0
        end
        st.dt_prev = dt_on
        self._lc_state = st
    end

    visuals.lc_status = function(self, base_x, base_y, edit_mode)
        self:_update_lc_state()
        local line_spacing = 12
        
        if edit_mode then
            local lines = {'lc status', 'ticks'}
            for i, line in ipairs(lines) do
                local y = base_y + (i - 1) * line_spacing
                local color = (i == 1) and {255, 255, 255} or {160, 160, 160}
                renderer.text(base_x, y, color[1], color[2], color[3], 255, 'c', 1000, line)
            end
            return
        end
        
        local st = self._lc_state or {}
        local now = (globals.realtime and globals.realtime()) or 0
        local elapsed = now - (st.last_update or 0)
        local target_alpha = 0
        
        if (st.last_update or 0) > 0 then
            local display_time = st.display_duration or 1.5
            local fade_time = st.fade_duration or 0.5
            
            if elapsed < display_time then
                target_alpha = 255
            elseif elapsed < (display_time + fade_time) then
                local fade_progress = (elapsed - display_time) / fade_time
                target_alpha = math.floor(255 * (1 - fade_progress) + 0.5)
            else
                target_alpha = 0
            end
        end
        
        local fadeSpeed = globals.frametime() * 15
        st.alpha = mathematic.lerp(st.alpha or 0, target_alpha, fadeSpeed)
        self._lc_state = st
        local a = math.floor((st.alpha or 0) + 0.5)
        if a < 1 then return end
        
        local lbl = st.last_label or 'lc status'
        local col = st.last_color or {255,255,255}
        local ticks = tonumber(st.last_ticks or 0) or 0
        
        local lines = {lbl, tostring(ticks) .. 't'}
        for i, line in ipairs(lines) do
            local y = base_y + (i - 1) * line_spacing
            local color = (i == 1) and col or {180, 180, 180}
            renderer.text(base_x, y, color[1], color[2], color[3], a, 'c', 1000, line)
        end
    end
end

--@region: stickman
stickman = {} do
    stickman.setup = function(self)
        local local_player = entity.get_local_player()
        local health = local_player and entity.get_prop(local_player, "m_iHealth") or 0
        if not local_player or health <= 0 then return end

        local visuals_enabled = interface.visuals.enabled_visuals:get()
        local stickman_enabled = interface.visuals.stickman:get()
        local csm_shadows = cvar.cl_csm_shadows
        local screen_coords = {}

        if not visuals_enabled or not stickman_enabled then
            if self.last_state ~= false then
                self:reset_materials()
                self.last_state = false
            end
            return
        end

        if ui.get(ui_references.thirdperson[1]) and not ui.get(ui_references.thirdperson[2]) then return end

        local game_rules = entity.get_all("CCSGameRulesProxy")[1]
        if game_rules and entity.get_prop(game_rules, "m_gamePhase") >= 5 then return end

        self.animation_progress = self.animation_progress or 0
        self.animation_progress = mathematic.lerp(self.animation_progress, 1, globals.frametime() * 8)

        self.current_r = self.current_r or 0
        self.current_g = self.current_g or 0 
        self.current_b = self.current_b or 0
        self.current_a = self.current_a or 0

        local r, g, b, a = unpack(interface.visuals.stickman.color.value)

        a = a * self.animation_progress
        
        self.current_r = mathematic.lerp(self.current_r, r, globals.frametime() * 8)
        self.current_g = mathematic.lerp(self.current_g, g, globals.frametime() * 8)
        self.current_b = mathematic.lerp(self.current_b, b, globals.frametime() * 8)
        self.current_a = mathematic.lerp(self.current_a, a, globals.frametime() * 8)
        
        local hitbox_pos = entity.hitbox_position
        local world_to_screen = renderer.world_to_screen

        local hitbox_map = {
            head = 0, neck = 1, chest = 2, pelvis = 3,
            left_shoulder = 4, left_elbow = 5, left_hand = 6,
            right_shoulder = 7, right_elbow = 8, right_hand = 9,
            left_hip = 10, left_knee = 11, left_foot = 12,
            right_hip = 13, right_knee = 14, right_foot = 15,
            Left_Upper_Arm = 16, Left_Forearm = 17
        }

        local needed_hitboxes = {
            "head", "neck", "chest", "pelvis", "left_shoulder",
            "left_elbow", "left_hand", "right_shoulder", "right_elbow",
            "right_hand", "left_hip", "left_knee", "left_foot", "right_hip",
            "right_knee", "right_foot", "Left_Upper_Arm", "Left_Forearm"
        }

        for _, name in ipairs(needed_hitboxes) do
            local x, y, z = hitbox_pos(local_player, hitbox_map[name])
            if x and y and z then
                local sx, sy = world_to_screen(x, y, z)
                screen_coords[name] = sx and sy and {sx = sx, sy = sy} or nil
            end
        end

        local segments = {
            {"neck", "right_foot"}, {"right_foot", "right_hip"},
            {"neck", "Left_Forearm"}, {"Left_Forearm", "right_knee"},
            {"neck", "chest"}, {"chest", "left_hip"}, 
            {"left_hip", "left_foot"}, {"chest", "right_hand"},
            {"right_hand", "left_knee"}
        }

        for _, pair in ipairs(segments) do
            local p1, p2 = screen_coords[pair[1]], screen_coords[pair[2]]
            if p1 and p2 then
                renderer.line(p1.sx, p1.sy, p2.sx, p2.sy, self.current_r, self.current_g, self.current_b, self.current_a)
            end
        end

        if self.last_state ~= true then
            local player_resource = entity.get_player_resource()
            local model_index = entity.get_prop(local_player, "m_nModelIndex")
            
            local mats = materialsystem.find_materials("models/player")
            if mats then
                for i, mat in ipairs(mats) do
                    if not self.original_values then
                        self.original_values = {
                            alpha = 1,
                            envmaptint = vector(1,1,1),
                            envmapfresnelminmaxexp = vector(0,1,2),
                            envmaplightscale = 1,
                            phongboost = 1,
                            rimlightexponent = 4,
                            rimlightboost = 1,
                            pearlescent = 0.5,
                            basemapalphaphongmask = 1
                        }
                    end
                    mat:set_shader_param("$alpha", 0)
                    mat:set_shader_param("$envmaptint", vector(0,0,0))
                    mat:set_shader_param("$envmapfresnelminmaxexp", vector(0,0,0))
                    mat:set_shader_param("$envmaplightscale", 0)
                    mat:set_shader_param("$phongboost", 0)
                    mat:set_shader_param("$rimlightexponent", 0)
                    mat:set_shader_param("$rimlightboost", 0)
                    mat:set_shader_param("$pearlescent", 0)
                    mat:set_shader_param("$basemapalphaphongmask", 0)
                end
            end
            csm_shadows:set_int(0)
            self.last_state = true
        end
    end

    stickman.reset_materials = function(self)
        self.animation_progress = 0
        self.current_r = 0
        self.current_g = 0
        self.current_b = 0
        self.current_a = 0
        
        local local_player = entity.get_local_player()
        local mats = materialsystem.find_materials("models/player")
        
        if mats then
            for i, mat in ipairs(mats) do
                if self.original_values then
                    mat:set_shader_param("$alpha", self.original_values.alpha)
                    mat:set_shader_param("$envmaptint", self.original_values.envmaptint)
                    mat:set_shader_param("$envmapfresnelminmaxexp", self.original_values.envmapfresnelminmaxexp)
                    mat:set_shader_param("$envmaplightscale", self.original_values.envmaplightscale)
                    mat:set_shader_param("$phongboost", self.original_values.phongboost)
                    mat:set_shader_param("$rimlightexponent", self.original_values.rimlightexponent)
                    mat:set_shader_param("$rimlightboost", self.original_values.rimlightboost)
                    mat:set_shader_param("$pearlescent", self.original_values.pearlescent)
                    mat:set_shader_param("$basemapalphaphongmask", self.original_values.basemapalphaphongmask)
                else
                    mat:set_shader_param("$alpha", 1)
                    mat:set_shader_param("$envmaptint", vector(1,1,1))
                    mat:set_shader_param("$envmapfresnelminmaxexp", vector(0,1,2))
                    mat:set_shader_param("$envmaplightscale", 1)
                    mat:set_shader_param("$phongboost", 1)
                    mat:set_shader_param("$rimlightexponent", 4)
                    mat:set_shader_param("$rimlightboost", 1)
                    mat:set_shader_param("$pearlescent", 0.5)
                    mat:set_shader_param("$basemapalphaphongmask", 1)
                end
            end
        end
        local csm_shadows = cvar.cl_csm_shadows
        csm_shadows:set_int(1)
        self.last_state = false
        self.original_values = nil
    end

    client.set_event_callback("round_start", function()
        if not interface.visuals.stickman:get() then
            stickman:reset_materials()
        end
    end)

    client.set_event_callback("player_spawn", function(e)
        local player_idx = client.userid_to_entindex(e.userid)
        if player_idx and player_idx == entity.get_local_player() then
            if interface.visuals.stickman:get() then
                local mats = materialsystem.find_materials("models/player")
                if mats then
                    for i, mat in ipairs(mats) do
                        mat:set_shader_param("$alpha", 0)
                    end
                end
                local csm_shadows = cvar.cl_csm_shadows
                csm_shadows:set_int(0)
            else
                stickman:reset_materials()
            end
        end
    end)

    client.set_event_callback("game_newmap", function()
        stickman:reset_materials()
    end)

    client.set_event_callback("cs_game_disconnected", function()
        stickman:reset_materials()
    end)

    client.set_event_callback("shutdown", function()
        stickman:reset_materials()
    end)
end
--@endregion

--@region: confetti
confetti = {} do
    confetti.particles = {}
    confetti.active = false
    confetti.last_time = nil
    confetti.colors = {
        {255, 0, 0},
        {0, 255, 0},
        {0, 0, 255},
        {255, 255, 0},
        {255, 0, 255},
        {0, 255, 255},
        {255, 128, 0},
        {128, 0, 255}
    }
    
    confetti._seeded = false
    confetti.ensure_seed = function(self)
        if self._seeded then return end
        local a = tonumber((tostring({}):match("0x(%x+)") or "0"), 16) or 0
        local b = math.floor((globals.realtime() or 0) * 1000)
        local c = (globals.tickcount and globals.tickcount()) or 0
        local seed = a
        if bit and bit.bxor then
            seed = bit.bxor(seed, b)
            seed = bit.bxor(seed, c)
        else
            seed = (seed + b + c) % 2147483647
        end
        if seed == 0 then seed = 1 end
        math.randomseed(seed)
        math.random(); math.random(); math.random()
        self._seeded = true
    end
    
    confetti._normalize_mode = function(self, mode)
        local n = tonumber(mode)
        if n == nil then return 1 end
        if n == 0 then self:ensure_seed(); return math.random(1, 3) end
        if n < 1 or n > 3 then n = 1 end
        return n
    end

    confetti.push = function(self, mode, play_sound)
        local m = self:_normalize_mode(mode)
        self:start(m, play_sound)
    end

    confetti.start = function(self, mode, play_sound)
        self:ensure_seed()
        local sw, sh = client.screen_size()
        local m = (self._normalize_mode and self:_normalize_mode(mode)) or (tonumber(mode) or 1)

        if m == 1 then
            local per_side = 300
            local function spawn_side(side)
                for i = 1, per_side do
                    local spawn_x, spawn_y
                    local target_x

                    if side == 'left' then
                        spawn_x = math.random(-100, -20)
                        spawn_y = math.random(sh * 0.3, sh * 0.7)
                        target_x = math.random(sw * 0.1, sw * 0.45)
                    else
                        spawn_x = math.random(sw + 20, sw + 100)
                        spawn_y = math.random(sh * 0.3, sh * 0.7)
                        target_x = math.random(sw * 0.55, sw * 0.9)
                    end

                    local target_y = -100
                    local dx = target_x - spawn_x
                    local dy = target_y - spawn_y
                    local angle_rad = math.atan2(dy, dx)
                    local speed = math.random(100, 140) / 19
                    local vx = math.cos(angle_rad) * speed
                    local vy = math.sin(angle_rad) * speed

                    local p = {
                        x = spawn_x,
                        y = spawn_y,
                        vx = vx + (math.random(-20, 20) / 100),
                        vy = vy + (math.random(-20, 20) / 100),
                        gravity = 0.008,
                        air = 0.994,
                        wind = (math.random(-1, 1) / 1000),
                        sway = math.random() * 0.05,
                        sway_speed = math.random(5, 10) / 1000,
                        sway_time = 0,
                        rotation = math.random(0, 360),
                        rotation_speed = math.random(-3, 3),
                        size = math.random(5, 9),
                        len = math.random(14, 24),
                        color = self.colors[math.random(1, #self.colors)],
                        lifetime = math.random(1000, 1250),
                        max_life = 3000,
                        bounce = 0.2
                    }
                    p.max_life = p.lifetime
                    table.insert(self.particles, p)
                end
            end
            spawn_side('left')
            spawn_side('right')

        elseif m == 2 then
            local total = 1200
            for i = 1, total do
                local spawn_x = math.random(0, sw)
                local spawn_y = math.random(-600, -20)
                local vx = (math.random(-10, 10) / 100)
                local vy = math.random(8, 15) / 10
                local p = {
                    x = spawn_x,
                    y = spawn_y,
                    vx = vx,
                    vy = vy,
                    gravity = 0.003,
                    air = 0.998,
                    wind = (math.random(-1, 1) / 1000),
                    sway = math.random() * 0.03,
                    sway_speed = math.random(3, 6) / 1000,
                    sway_time = 0,
                    rotation = math.random(0, 360),
                    rotation_speed = math.random(-2, 2),
                    size = math.random(5, 9),
                    len = math.random(14, 24),
                    color = self.colors[math.random(1, #self.colors)],
                    lifetime = math.random(1200, 1500),
                    max_life = 3000,
                    bounce = 0.15
                }
                p.max_life = p.lifetime
                table.insert(self.particles, p)
            end

        elseif m == 3 then
            local per_burst = 400
            local burst_positions = {
                { x = sw * 0.35, y = sh * 0.30 },
                { x = sw * 0.65, y = sh * 0.30 }
            }
            
            for _, pos in ipairs(burst_positions) do
                local cx = pos.x + math.random(-10, 10)
                local cy = pos.y + math.random(-5, 5)
                
                for i = 1, per_burst do
                    local angle = math.random() * math.pi * 2
                    local speed = math.random(5, 28) / 10
                    local vx = math.cos(angle) * speed
                    local vy = math.sin(angle) * speed

                    local p = {
                        x = cx + math.random(-5, 5),
                        y = cy + math.random(-3, 3),
                        vx = vx + (math.random(-5, 5) / 100),
                        vy = vy + (math.random(-5, 5) / 100),
                        gravity = 0.004,
                        air = 0.996,
                        wind = (math.random(-1, 1) / 1000),
                        sway = math.random() * 0.03,
                        sway_speed = math.random(3, 7) / 1000,
                        sway_time = 0,
                        rotation = math.random(0, 360),
                        rotation_speed = math.random(-2, 2),
                        size = math.random(5, 9),
                        len = math.random(14, 24),
                        color = self.colors[math.random(1, #self.colors)],
                        lifetime = math.random(1200, 1500),
                        max_life = 3000,
                        bounce = 0.15
                    }
                    p.max_life = p.lifetime
                    table.insert(self.particles, p)
                end
            end
        end

        self.active = true
        if play_sound ~= false then
            client.exec("play weapons/party_horn_01.wav")
        end
    end
    
    confetti.update = function(self)
        if not self.active then return end
        
        local current_time = globals.realtime()
        if not self.last_time then self.last_time = current_time end
        local frame_time = current_time - self.last_time
        self.last_time = current_time
        
        local dt = frame_time * 300
        if dt <= 0 or dt > 5 then dt = 1 end
        
        local sw, sh = client.screen_size()
        local ground = sh - 6
        for i = #self.particles, 1, -1 do
            local p = self.particles[i]
            p.sway_time = (p.sway_time or 0) + (p.sway_speed or 0.008) * dt
            local sway_offset = math.sin(p.sway_time) * (p.sway or 0.003)
            
            local air = math.pow(p.air or 0.98, dt)
            p.vx = p.vx * air + (p.wind or 0) * dt
            
            p.vy = p.vy * air
            p.vy = p.vy + (p.gravity or 0.01) * dt
            
            p.x = p.x + p.vx * dt + sway_offset
            p.y = p.y + p.vy * dt
            p.rotation = (p.rotation or 0) + (p.rotation_speed or 0) * 0.5 * dt
            p.lifetime = p.lifetime - 1 * dt
            
            if p.lifetime <= 0 or p.y > sh + 200 or p.x < -200 or p.x > sw + 200 then
                table.remove(self.particles, i)
            end
        end
        if #self.particles == 0 then
            self.active = false
        end
    end
    
    confetti.draw = function(self)
        if not self.active then return end
        
        for _, p in ipairs(self.particles) do
            local life = (p.max_life or 1)
            local alpha = math.floor(255 * math.max(0, math.min(1, (p.lifetime or 0) / life)))
            local rad = math.rad(p.rotation or 0)
            local len = (p.len or (p.size or 6) * 2)
            local x1 = math.floor(p.x + 0.5)
            local y1 = math.floor(p.y + 0.5)
            local x2 = math.floor(p.x + math.cos(rad) * len + 0.5)
            local y2 = math.floor(p.y + math.sin(rad) * len + 0.5)
            renderer.line(x1, y1, x2, y2, p.color[1], p.color[2], p.color[3], alpha)
        end
    end
end
--@endregion

--@region: snow
local snow = {} do
    snow.particles = {}
    snow.max_particles = 250
    snow.last_time = nil

    snow.spawn = function(self, sw, sh)
        table.insert(self.particles, {
            x = math.random(0, sw),
            y = math.random(-sh, 0),
            vx = math.random(-5, 5) / 10,
            vy = math.random(5, 15) / 10,
            size = math.random(1, 3),
            drift = math.random() * math.pi,
            drift_speed = math.random(1, 3) / 100,
            alpha = math.random(150, 255)
        })
    end

    snow.update = function(self)
        local is_enabled = interface.home.menu_snow:get()
        local menu_open = ui.is_menu_open()
        local sw, sh = client.screen_size()
        local current_time = globals.realtime()
        
        if not self.last_time then self.last_time = current_time end
        local dt = (current_time - self.last_time) * 100
        self.last_time = current_time
    
        if is_enabled and menu_open and #self.particles < self.max_particles then
            for i = 1, 2 do 
                if #self.particles < self.max_particles then
                    self:spawn(sw, sh)
                end
            end
        end
    
        for i = #self.particles, 1, -1 do
            local p = self.particles[i]
    
            p.drift = p.drift + p.drift_speed * dt
            p.y = p.y + p.vy * dt
            p.x = p.x + (p.vx + math.sin(p.drift) * 0.5) * dt
    
            if not menu_open or not is_enabled then
                p.alpha = p.alpha - 2 * dt
            end
    
            if p.y > sh + 10 or p.alpha <= 0 then
                table.remove(self.particles, i)
            end
        end
    end

    snow.draw = function(self)
        if #self.particles == 0 then return end

        for _, p in ipairs(self.particles) do
            renderer.rectangle(math.floor(p.x), math.floor(p.y), p.size, p.size, 255, 255, 255, math.floor(p.alpha))
        end
    end
end
--@endregion

interface.home.confetti:set_callback(function()
    confetti:push(0, false)
end)

client.set_event_callback('paint', function()
    stickman:setup()
end)

client.set_event_callback('paint_ui', function()
    widgets.paint()
    confetti:update()
    confetti:draw()
    snow:update()
    snow:draw()
end)

logging = {} do
    client.exec("con_filter_enable 1") 
    client.exec("con_filter_text noctua")
    logging.logweapon_original = ui.reference('misc', 'miscellaneous', 'log weapon purchases')
    logging.hitgroup_names = {"generic", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear"}
    logging.animatedMessages = {}
    logging.cache = {}
    logging.round_counter = 0
    logging.preview_messages = {}
    logging.preview_active = false
    logging.preview_alpha = 0
    logging.ui_alpha = 1

    logging.build_segments = function(self, fmt, ...)
        local white = {255, 255, 255}
        local gray = {212, 212, 212}
        local args = { ... }
        local segments = {}
        local pos = 1
        local arg_index = 1

        while true do
            local s, e, conv = string.find(fmt, "(%%[%-%+%.%d]*[sdf])", pos)
            if not s then
                local tail = fmt:sub(pos)
                if tail ~= "" then
                    table.insert(segments, { text = tail, color = gray, flags = "" })
                end
                break
            end

            if s > pos then
                table.insert(segments, { text = fmt:sub(pos, s - 1), color = gray, flags = "" })
            end

            local argVal = args[arg_index]
            arg_index = arg_index + 1
            table.insert(segments, { text = string.format(conv, argVal), color = white, flags = "" })
            pos = e + 1
        end

        return segments
    end

    logging.push = function(self, text, duration, is_preview, segments)
        duration = duration or 3
        table.insert(self.animatedMessages, 1, {
            text = text,
            segments = segments,
            duration = duration,
            startTime = globals.realtime(),
            currentY = -10,
            targetY = 0,
            removing = false,
            alpha = 0,
            offset = -10,
            preview = is_preview == true
        })

        if #self.animatedMessages > 10 then
            self.animatedMessages[#self.animatedMessages].removing = true
            self.animatedMessages[#self.animatedMessages].remove_started_at = globals.realtime()
        end
    end

    logging.clear_preview = function(self)
        self.preview_messages = {}
        self.preview_active = false
    end

    logging.clearCache = function(self)
        self.animatedMessages = {}
        self.cache = {}
    end

    logging.has_style = function(self, style)
        local value = interface.visuals.logging_style:get() or {}
        return utils.multiselect_has(value, style)
    end

    logging.has_event = function(self, event_name)
        local value = interface.visuals.logging_events:get() or {}
        return utils.multiselect_has(value, event_name)
    end

    logging.should_output = function(self, style, event_name)
        if not interface.visuals.logging:get() then
            return false
        end

        return self:has_style(style) and self:has_event(event_name)
    end

    logging.push_format = function(self, fmt, duration, is_preview, ...)
        self:push(string.format(fmt, ...), duration, is_preview, self:build_segments(fmt, ...))
    end

    logging.get_reason_color = function(self, reason)
        local palette = {
            ["resolver"] = {255, 70, 70},
            ["prediction error"] = {255, 130, 80},
            ["spread"] = {180, 130, 255},
            ["high inaccuracy"] = {180, 130, 255},
            ["lagcomp break"] = {120, 200, 255},
            ["backtrack failure"] = {120, 200, 255},
            ["extrapolation failure"] = {120, 200, 255},
            ["occlusion"] = {200, 200, 200},
            ["death"] = {200, 200, 200},
            ["player death"] = {200, 200, 200},
            ["unknown"] = {255, 120, 190}
        }

        return palette[reason] or {255, 120, 190}
    end

    logging.push_miss_format = function(self, fmt, duration, is_preview, ...)
        local segments = self:build_segments(fmt, ...)
        local reason = select(select("#", ...), ...)
        if segments[#segments] then
            segments[#segments].color = self:get_reason_color(reason)
        end
        self:push(string.format(fmt, ...), duration, is_preview, segments)
    end

    logging.console_miss_log = function(self, fmt, ...)
        local gray = {212, 212, 212}
        local reason = select(select("#", ...), ...)
        local reason_color = self:get_reason_color(reason)
        local segments = self:build_segments(fmt, ...)
        local r, g, b = unpack(interface.visuals.accent.color.value)

        if segments[#segments] then
            segments[#segments].color = reason_color
        end

        client.color_log(r, g, b, "noctua · \0")
        for i = 1, #segments do
            local seg = segments[i]
            local color = seg.color or gray
            local ending = (i == #segments) and "\n\0" or "\0"
            client.color_log(color[1], color[2], color[3], seg.text .. ending)
        end
    end

    logging.drawAnimatedMessages = function(self, base_x, base_y, edit_mode)
        local menuOpen = ui.is_menu_open()
        
        local real_count = 0
        for i = 1, #self.animatedMessages do
            if not self.animatedMessages[i].preview then real_count = real_count + 1 end
        end
        
        if edit_mode and real_count == 0 and not self.preview_active then
            self:push("hit keus's head for 208 / lc: 3 - yaw: -23°", 999999, true)
            self:push("missed racen's head / lc: 12 - reason: bad code", 999999, true)
            self:push("forced safe point for Axsiimov / hp: 26 - reason: cs_assault", 999999, true)
            self.preview_active = true
        end
        if (not edit_mode or real_count > 0) and self.preview_active then
            local keep = {}
            for i = 1, #self.animatedMessages do
                if not self.animatedMessages[i].preview then
                    table.insert(keep, self.animatedMessages[i])
                end
            end
            self.animatedMessages = keep
            self.preview_active = false
        end
        
        if #self.animatedMessages == 0 then
            return
        end

        local currentTime = globals.realtime()
        local line_spacing = 15

        local animTime = 0.2
        
        local function easeInOutQuad(t)
            return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t
        end

        local function render_segments(center_x, y, alpha, segments, blur_alpha)
            local total_w = 0
            local max_h = 0

            for i = 1, #segments do
                local seg = segments[i]
                local w, h = renderer.measure_text(seg.flags or "", seg.text or "")
                total_w = total_w + (w or 0)
                max_h = math.max(max_h, h or 0)
            end

            local draw_x = math.floor(center_x - (total_w / 2) + 0.5)
            for i = 1, #segments do
                local seg = segments[i]
                local seg_w, seg_h = renderer.measure_text(seg.flags or "", seg.text or "")
                local draw_y = math.floor(y - ((seg_h or max_h) / 2) + (max_h / 2) + 0.5)

                if blur_alpha > 0 then
                    renderer.text(draw_x - 1, draw_y, seg.color[1], seg.color[2], seg.color[3], blur_alpha, seg.flags or "", 0, seg.text)
                    renderer.text(draw_x + 1, draw_y, seg.color[1], seg.color[2], seg.color[3], blur_alpha, seg.flags or "", 0, seg.text)
                    renderer.text(draw_x, draw_y - 1, seg.color[1], seg.color[2], seg.color[3], blur_alpha * 0.65, seg.flags or "", 0, seg.text)
                    renderer.text(draw_x, draw_y + 1, seg.color[1], seg.color[2], seg.color[3], blur_alpha * 0.65, seg.flags or "", 0, seg.text)
                end

                renderer.text(draw_x, draw_y, seg.color[1], seg.color[2], seg.color[3], alpha, seg.flags or "", 0, seg.text)
                draw_x = draw_x + (seg_w or 0)
            end
        end

        local layout_y = 0
        for i = 1, #self.animatedMessages do
            local msg = self.animatedMessages[i]
            if msg.preview or not msg.removing then
                msg.targetY = layout_y
                layout_y = layout_y + line_spacing
            end
        end
        
        for i = 1, #self.animatedMessages do
            local msg = self.animatedMessages[i]
            local elapsedTime = currentTime - msg.startTime
        
            msg.currentY = msg.currentY or 0
            msg.alpha = msg.alpha or 0
            msg.offset = msg.offset or -10
            
            if math.abs(msg.currentY - msg.targetY) > 0.1 then
                msg.currentY = mathematic.lerp(msg.currentY, msg.targetY, globals.frametime() * 8)
            else
                msg.currentY = msg.targetY
            end
        
            if msg.preview and edit_mode then
                local targetAlpha = 255
                local targetOffset = 0
                msg.alpha = mathematic.lerp(msg.alpha, targetAlpha, globals.frametime() * 10)
                msg.offset = mathematic.lerp(msg.offset, targetOffset, globals.frametime() * 10)
                local alpha = msg.alpha or 255
                local y = math.floor(base_y + msg.currentY + msg.offset + 0.5)
                local blur_amount = math.min(46, math.abs(msg.offset or 0) * 5.5 + math.abs(255 - alpha) * 0.08)
                if msg.segments and #msg.segments > 0 then
                    render_segments(base_x, y, alpha, msg.segments, blur_amount > 1 and math.min(alpha * 0.22, blur_amount * 0.75) or 0)
                else
                    if blur_amount > 1 then
                        local blur_alpha = math.min(alpha * 0.22, blur_amount * 0.75)
                        renderer.text(base_x - 1, y, 255, 255, 255, blur_alpha, "c", 0, msg.text)
                        renderer.text(base_x + 1, y, 255, 255, 255, blur_alpha, "c", 0, msg.text)
                        renderer.text(base_x, y - 1, 255, 255, 255, blur_alpha * 0.65, "c", 0, msg.text)
                        renderer.text(base_x, y + 1, 255, 255, 255, blur_alpha * 0.65, "c", 0, msg.text)
                    end
                    renderer.text(base_x, y, 255, 255, 255, alpha, "c", 0, msg.text)
                end
            else
                local holdTime = math.max(0, tonumber(msg.duration) or 3)
                local totalDuration = animTime + holdTime

                if not msg.removing and elapsedTime >= totalDuration then
                    msg.removing = true
                    msg.remove_started_at = currentTime
                end

                if msg.removing then
                    local remove_elapsed = currentTime - (msg.remove_started_at or currentTime)
                    local progress = math.max(0, math.min(remove_elapsed / animTime, 1))
                    local easedProgress = easeInOutQuad(progress)
                    local targetAlpha = 255 * (1 - easedProgress)
                    local targetOffset = 10 * easedProgress

                    msg.alpha = mathematic.lerp(msg.alpha, targetAlpha, globals.frametime() * 12)
                    msg.offset = mathematic.lerp(msg.offset, targetOffset, globals.frametime() * 12)

                    local alpha = msg.alpha or 0
                    local y = math.floor(base_y + msg.currentY + msg.offset + 0.5)
                    local blur_amount = math.min(46, math.abs(msg.offset or 0) * 5.5 + math.abs(255 - alpha) * 0.08)

                    if msg.segments and #msg.segments > 0 then
                        render_segments(base_x, y, alpha, msg.segments, blur_amount > 1 and math.min(alpha * 0.22, blur_amount * 0.75) or 0)
                    else
                        if blur_amount > 1 then
                            local blur_alpha = math.min(alpha * 0.22, blur_amount * 0.75)
                            renderer.text(base_x - 1, y, 255, 255, 255, blur_alpha, "c", 0, msg.text)
                            renderer.text(base_x + 1, y, 255, 255, 255, blur_alpha, "c", 0, msg.text)
                            renderer.text(base_x, y - 1, 255, 255, 255, blur_alpha * 0.65, "c", 0, msg.text)
                            renderer.text(base_x, y + 1, 255, 255, 255, blur_alpha * 0.65, "c", 0, msg.text)
                        end
                        renderer.text(base_x, y, 255, 255, 255, alpha, "c", 0, msg.text)
                    end

                    if progress >= 0.98 and alpha <= 2 then
                        table.remove(self.animatedMessages, i)
                        break
                    end
                else
                    local targetAlpha, targetOffset
                    if elapsedTime < animTime then
                        targetAlpha = 255
                        targetOffset = 0
                    else
                        targetAlpha = 255
                        targetOffset = 0
                    end
            
                    msg.alpha = mathematic.lerp(msg.alpha, targetAlpha, globals.frametime() * 10)
                    msg.offset = mathematic.lerp(msg.offset, targetOffset, globals.frametime() * 10)
            
                    local alpha = msg.alpha or 255
                    local y = math.floor(base_y + msg.currentY + msg.offset + 0.5)
                    local blur_amount = math.min(46, math.abs(msg.offset or 0) * 5.5 + math.abs(targetAlpha - alpha) * 0.08)
                    if msg.segments and #msg.segments > 0 then
                        render_segments(base_x, y, alpha, msg.segments, blur_amount > 1 and math.min(alpha * 0.22, blur_amount * 0.75) or 0)
                    else
                        if blur_amount > 1 then
                            local blur_alpha = math.min(alpha * 0.22, blur_amount * 0.75)
                            renderer.text(base_x - 1, y, 255, 255, 255, blur_alpha, "c", 0, msg.text)
                            renderer.text(base_x + 1, y, 255, 255, 255, blur_alpha, "c", 0, msg.text)
                            renderer.text(base_x, y - 1, 255, 255, 255, blur_alpha * 0.65, "c", 0, msg.text)
                            renderer.text(base_x, y + 1, 255, 255, 255, blur_alpha * 0.65, "c", 0, msg.text)
                        end
                        renderer.text(base_x, y, 255, 255, 255, alpha, "c", 0, msg.text)
                    end
                end
            end
        end
    end

    logging.handleAimFire = function(self, e)
        if not e then return end
        
        local playerName = entity.get_player_name(e.target)
        local hitbox = self.hitgroup_names[e.hitgroup + 1] or "?"
        local hitChance = math.floor(e.hit_chance + 0.5)
        local damage = e.damage
        local resolverEnabled = (interface.aimbot.enabled_aimbot:get() and interface.aimbot.enabled_resolver_tweaks:get())
        local desiredYaw = resolverEnabled and (resolver.cache[e.target] or 0) or "?"
        local currentTick = globals.tickcount()
        local lagComp = math.max(currentTick - e.tick, 0)

        local vx, vy, vz = entity.get_prop(e.target, "m_vecVelocity")
        local speed = math.sqrt(vx*vx + vy*vy)

        self.cache[e.target] = { 
            hitbox = hitbox, 
            damage = damage, 
            lagComp = lagComp,
            aim_x = e.x,
            aim_y = e.y,
            aim_z = e.z,
            teleported = e.teleported,
            extrapolated = e.extrapolated,
            start_speed = speed,
            hitChance = hitChance
        }

        resolver.shot_state[e.target] = utils.get_enemy_state(e.target) or resolver.state_cache[e.target] or "unknown"

        local doConsole = self:should_output("console", "shots fired")
        local doScreen = self:should_output("screen", "shots fired")
        if not doConsole and not doScreen then return end

        local yawDisplay = (type(desiredYaw) == "number") and (desiredYaw.."°") or (tostring(desiredYaw).."°")

        if doConsole then
            argLog("fired at %s's %s for %d / lc: %d - yaw: %d°", playerName, hitbox, damage, lagComp, desiredYaw) 
        end

        if doScreen then
            self:push_format("fired at %s's %s for %d / lc: %d - yaw: %s°", nil, false, playerName, hitbox, damage, lagComp, tostring(desiredYaw))
        end
    end

    logging.handleAimHit = function(self, e)
        if not e then return end
        resolver:record_shot_result(e.target, true, "hit")
        local doConsole = self:should_output("console", "damage dealt")
        local doScreen = self:should_output("screen", "damage dealt")
        if not doConsole and not doScreen then return end

        local playerName = entity.get_player_name(e.target)
        local hitbox = self.hitgroup_names[e.hitgroup + 1] or "?"
        local damage = e.damage or 0
        local resolverEnabled = (interface.aimbot.enabled_aimbot:get() and interface.aimbot.enabled_resolver_tweaks:get())
        local desiredYaw = resolverEnabled and (resolver.cache[e.target] or 0) or "?"

        local cached = self.cache[e.target] or {}
        local lagComp = cached.lagComp or 0

        local msg = ""

        if cached and cached.hitbox and (cached.hitbox ~= "?" and cached.hitbox ~= hitbox) then
            local mismatchReason = "?"
            local weapon = entity.get_player_weapon(entity.get_local_player())
            local inaccuracy = 0
            if weapon then
                inaccuracy = entity.get_prop(weapon, "m_fAccuracyPenalty")
            end
    
            local vx, vy, vz = entity.get_prop(e.target, "m_vecVelocity")
            local current_speed = math.sqrt(vx*vx + vy*vy)
            local cached_speed = cached.start_speed or 0
            local speed_delta = math.abs(current_speed - cached_speed)
            
            if inaccuracy > 0.02 then
                mismatchReason = "high inaccuracy"
            else
                mismatchReason = "unknown"
            end
    
            if doScreen then
                self:push_format(
                    "hit %s's %s for %d / exp: %s (%d) - lc: %d - yaw: %s - reason: %s",
                    nil,
                    false,
                    playerName, hitbox, damage,
                    cached.hitbox, cached.damage,
                    lagComp,
                    type(desiredYaw) == "number" and desiredYaw.."°" or desiredYaw.."°",
                    mismatchReason
                )
            end

            if doConsole then
                argLog(
                    "hit %s's %s for %d / exp: %s (%d) - lc: %d - yaw: %s - reason: %s",
                    playerName, hitbox, damage,
                    cached.hitbox, cached.damage,
                    lagComp,
                    type(desiredYaw) == "number" and desiredYaw.."°" or desiredYaw.."°",
                    mismatchReason
                )
            end
        else
            if doScreen then
                self:push_format(
                    "hit %s's %s for %d / lc: %d - yaw: %s",
                    nil,
                    false,
                    playerName, hitbox, damage, lagComp, type(desiredYaw) == "number" and desiredYaw.."°" or desiredYaw.."°"
                )
            end

            if doConsole then
                argLog("hit %s's %s for %d / lc: %d - yaw: %s", playerName, hitbox, damage, lagComp, type(desiredYaw) == "number" and desiredYaw.."°" or desiredYaw.."°")
            end
        end
    end

    logging.handleNaded = function(self, e)
        if not e then return end
        local doConsole = self:should_output("console", "damage dealt")
        local doScreen = self:should_output("screen", "damage dealt")
        if not doConsole and not doScreen then return end

        local victim = client.userid_to_entindex(e.userid)
        if not victim then return end
        
        local playerName = entity.get_player_name(victim)
        local damage = e.dmg_health or 0
        local currentHealth = entity.get_prop(victim, "m_iHealth") or 0
        
        local remainingHealth = math.max(0, currentHealth - damage)
        
        if doConsole then
            argLog("naded %s for %d damage (%d left)", playerName, damage, remainingHealth)
        end
        
        if doScreen then self:push_format("naded %s for %d damage (%d left)", nil, false, playerName, damage, remainingHealth) end
    end
    
    logging.handleKnifed = function(self, e)
        if not e then return end
        local doConsole = self:should_output("console", "damage dealt")
        local doScreen = self:should_output("screen", "damage dealt")
        if not doConsole and not doScreen then return end

        local victim = client.userid_to_entindex(e.userid)
        if not victim then return end
        
        local playerName = entity.get_player_name(victim)
        local damage = e.dmg_health or 0
        local hitbox = self.hitgroup_names[e.hitgroup + 1] or "body"
        local currentHealth = entity.get_prop(victim, "m_iHealth") or 0
        
        local remainingHealth = math.max(0, currentHealth - damage)
        
        if doConsole then
            argLog("knifed %s's %s for %d damage (%d left)", playerName, hitbox, damage, remainingHealth)
        end
        
        if doScreen then self:push_format("knifed %s's %s for %d damage (%d left)", nil, false, playerName, hitbox, damage, remainingHealth) end
    end

    logging.handleDamageTaken = function(self, e)
        if not e then
            return
        end

        local doConsole = self:should_output("console", "damage received")
        local doScreen = self:should_output("screen", "damage received")
        if not doConsole and not doScreen then
            return
        end

        local attacker = client.userid_to_entindex(e.attacker)
        local attacker_name = attacker and entity.get_player_name(attacker) or "world"
        local damage = e.dmg_health or 0
        local hitbox = self.hitgroup_names[(e.hitgroup or 0) + 1] or "body"
        local health = e.health

        if hitbox == "generic" then
            hitbox = "body"
        end

        if health == nil then
            health = entity.get_prop(entity.get_local_player(), "m_iHealth") or 0
        end

        if doConsole then
            argLog("took %d damage in %s from %s (%d left)", damage, hitbox, attacker_name, health)
        end

        if doScreen then
            self:push_format("took %d damage in %s from %s (%d left)", nil, false, damage, hitbox, attacker_name, health)
        end
    end

    logging.handleAimMiss = function(self, e)
        if not e then return end
        
        local playerName = entity.get_player_name(e.target)
        local health = entity.get_prop(e.target, "m_iHealth") or 0
        local reason = e.reason
        local cached = self.cache[e.target] or {}
        local lagComp = cached.lagComp or 0
        local hitChance = e.hit_chance or 0
        local resolverEnabled = (interface.aimbot.enabled_aimbot:get() and interface.aimbot.enabled_resolver_tweaks:get())
        local desiredYaw = resolverEnabled and (resolver.cache[e.target] or 0) or "?"
        
        local hitgroupMapping = {
            [0] = "generic", [1] = "head", [2] = "chest",
            [3] = "stomach", [4] = "left arm", [5] = "right arm",
            [6] = "left leg", [7] = "right leg", [10] = "gear"
        }
        local hitgroup = hitgroupMapping[e.hitgroup] or "unknown"
    
        local lp = entity.get_local_player()
        local lp_alive = lp and entity.is_alive(lp)
    
        local lx, ly, lz = client.eye_position()
        local tx, ty, tz = e.x, e.y, e.z
    
        if lx and tx then
            local fraction, entindex = client.trace_line(lp, lx, ly, lz, tx, ty, tz)
            if fraction < 1 and entindex ~= e.target then
                reason = "occlusion"
            end
        end
    
        if health <= 0 then
            reason = "player death"
        elseif reason == "death" then
            if lp_alive then
                reason = "player death"
            else
                reason = "death"
            end
        elseif not reason or reason == "" or reason == "?" then 
            reason = "resolver" 
        end
    
        if reason ~= "player death" and reason ~= "death" and reason ~= "occlusion" then
            if reason == "spread" then
                local weapon = entity.get_player_weapon(lp)
                if weapon then
                    local inacc = entity.get_prop(weapon, "m_fAccuracyPenalty")
                    if inacc > 0.02 then reason = "high inaccuracy" end
                end
            elseif reason == "resolver" or reason == "prediction error" then
                if cached.teleported then
                    reason = "lagcomp break"
                elseif cached.extrapolated then
                    reason = "extrapolation failure"
                else
                    local vx, vy, vz = entity.get_prop(e.target, "m_vecVelocity")
                    local cur_speed = math.sqrt(vx*vx + vy*vy)
                    
                    if math.abs(cur_speed - (cached.start_speed or 0)) > 50 then
                        reason = "prediction error"
                    end
                end
            end
    
            if reason == "resolver" and lagComp > 14 then
                reason = "backtrack failure"
            end
        end
    
        local showYaw = true
        local noYawReasons = {
            ["backtrack failure"] = true, ["death"] = true,
            ["player death"] = true, ["spread"] = true, 
            ["high inaccuracy"] = true, ["lagcomp break"] = true,
            ["unknown"] = true, ["extrapolation failure"] = true,
            ["prediction error"] = true, ["occlusion"] = true
        }
    
        if noYawReasons[reason] then showYaw = false end

        resolver:record_shot_result(e.target, false, reason)
    
        local doConsole = self:should_output("console", "shots missed")
        local doScreen = self:should_output("screen", "shots missed")
        if not doConsole and not doScreen then return end
    
        local yawStr = (type(desiredYaw) == "number") and (desiredYaw.."°") or (tostring(desiredYaw).."°")
        local hcStr = math.floor(hitChance + 0.5) .. "%"
    
        if doConsole then
            if showYaw then
                self:console_miss_log("missed %s's %s / lc: %d - yaw: %s - hc: %s - reason: %s", playerName, hitgroup, lagComp, yawStr, hcStr, reason)
            else
                self:console_miss_log("missed %s's %s / lc: %d - hc: %s - reason: %s", playerName, hitgroup, lagComp, hcStr, reason)
            end
        end
        
        if doScreen then 
            if showYaw then
                self:push_miss_format("missed %s's %s / lc: %d - yaw: %s - hc: %s - reason: %s", nil, false, playerName, hitgroup, lagComp, yawStr, hcStr, reason)
            else
                self:push_miss_format("missed %s's %s / lc: %d - hc: %s - reason: %s", nil, false, playerName, hitgroup, lagComp, hcStr, reason)
            end
        end
    
        if _G.noctua_session and _G.noctua_session.active then
            local stats = _G.noctua_session.stats
            stats.miss_types[reason] = (stats.miss_types[reason] or 0) + 1
        end
    end

    logging.setup_logweapon = function()
        if not interface.visuals.logging:get() then 
            ui.set_enabled(logging.logweapon_original, true)
            return 
        end
        local doConsole = logging:should_output("console", "purchases")
        
        if doConsole then
            ui.set(logging.logweapon_original, false)
            ui.set_enabled(logging.logweapon_original, false)
        else
            ui.set_enabled(logging.logweapon_original, true)
        end
    end
    
    logging.on_item_purchase = function(e)
        if not interface.visuals.logging:get() then return end
        local doConsole = logging:should_output("console", "purchases")
        
        if not doConsole then return end
        
        local player_idx = client.userid_to_entindex(e.userid)
        if not player_idx or not entity.is_enemy(player_idx) then return end
        
        local weapon = e.weapon or "unknown item"
        if weapon == "weapon_unknown" then return end
        
        weapon = weapon:gsub("^weapon_", "")
        
        local playerName = entity.get_player_name(player_idx) or "unknown"
        if doConsole then
            argLog("%s bought %s", playerName, weapon)
        end
    end
    
    logging.on_round_prestart = function(e)
        if not interface.visuals.logging:get() then
            return
        end

        if not logging:has_style("console") then
            return
        end

        local game_rules = entity.get_all("CCSGameRulesProxy")[1]
        if not game_rules then
            return
        end

        if entity.get_prop(game_rules, "m_bWarmupPeriod") == 1 then
            return
        end

        local rounds_played = entity.get_prop(game_rules, "m_totalRoundsPlayed") or 0
        logging.round_counter = rounds_played + 1

        client.color_log(255, 255, 255, "\n\0")
        argLog("round %d", logging.round_counter)
    end
end

client.set_event_callback("round_prestart", logging.on_round_prestart)
client.set_event_callback("item_purchase", logging.on_item_purchase)
client.set_event_callback("paint", logging.setup_logweapon)

widgets.register({
    id = "crosshair_indicators",
    title = "Indicators",
    defaults = { anchor_x = "center", anchor_y = "center", offset_x = 0, offset_y = 10 },
    get_size = function(st)
        local maxw, lineh = 0, select(2, renderer.measure_text("c", "A")) or 12
        local samples = { "noctua", "freestand", "rapid", "reload", "osaa", "dmg", "hc" }
        for i = 1, #samples do
            local w = select(1, renderer.measure_text("c", samples[i])) or 0
            if w > maxw then maxw = w end
        end
        local lines = 4.5
        return math.max(maxw, 60), lineh * lines
    end,
    draw = function(ctx)
        visuals:indicators(ctx.x + ctx.w / 2, ctx.y)
    end,
    z = 10
})

widgets.register({
    id = "screen_logging",
    title = "Logging",
    defaults = { anchor_x = "center", anchor_y = "center", offset_x = 0, offset_y = 0 },
    get_size = function(st)
        local line_spacing = 15
        local MAX_LINES = 15
        local count = #logging.animatedMessages
        local visible = math.max(1, math.min(count, MAX_LINES))
        local maxw = 0
        local text_h = select(2, renderer.measure_text("c", "A")) or 12
        
        for i = 1, count do
            local w = select(1, renderer.measure_text("c", logging.animatedMessages[i].text or "")) or 0
            if w > maxw then maxw = w end
        end
        if maxw == 0 then maxw = 300 end
        local content_h = ((visible - 1) * line_spacing) + text_h
        local height = 10 + content_h + 10
        return maxw, height
    end,
    draw = function(ctx)
        local text_h = select(2, renderer.measure_text("c", "A")) or 12
        local real_count = 0
        for i = 1, #logging.animatedMessages do
            if not logging.animatedMessages[i].preview then
                real_count = real_count + 1
            end
        end

        local showing_preview = ctx.edit_mode and real_count == 0
        local runtime_y_offset = showing_preview and 0 or -3
        local base_y = math.floor(ctx.y + 8 + (text_h / 2) + runtime_y_offset + 0.5)
        local base_x = math.floor(ctx.cx + 0.5)
        logging:drawAnimatedMessages(base_x, base_y, ctx.edit_mode)
    end,
    z = 5
})

widgets.register({
    id = "debug_window",
    title = "Debug Window",
    defaults = {
        anchor_x = "center",
        anchor_y = "center",
        offset_x = 0,
        offset_y = -80
    },
    get_size = function(st)
        local lineh = 13
        local padding = 6 
        local total_lines = 1
        local total_pixels = 5
        
        local resolver_enabled = interface.aimbot.enabled_aimbot:get() and interface.aimbot.enabled_resolver_tweaks:get()
        if resolver_enabled then
            total_lines = total_lines + 4
            total_pixels = total_pixels + 6
        end
        
        total_lines = total_lines + 4
        total_pixels = total_pixels + 6
        
        local dormant_enabled = interface.aimbot.dormant_enabled:get() and interface.aimbot.dormant_enabled.hotkey:get()
        if dormant_enabled then
            total_lines = total_lines + 1
        end
        
        local isDT = ui.get(ui_references.double_tap[1]) and ui.get(ui_references.double_tap[2])
        local isOS = ui.get(ui_references.on_shot_anti_aim[1]) and ui.get(ui_references.on_shot_anti_aim[2])
        if isDT or isOS then
            total_lines = total_lines + 3
        end
        
        local width = 150 
        local height = (total_lines * lineh) + total_pixels + 2
        return width, height
    end,
    draw = function(ctx)
        visuals:window(ctx.x, ctx.y + 6, "l")
    end,
    z = 6
})

widgets.register({
    id = "watermark",
    title = "Watermark",
    defaults = { anchor_x = "center", anchor_y = "center", offset_x = 0, offset_y = -100 },
    get_size = function(st)
        local lineh = math.max(select(2, renderer.measure_text('b', 'A')) or 12, select(2, renderer.measure_text('', 'A')) or 12)
        local username = _nickname or 'user'
        local hours, minutes, seconds, milliseconds = client.system_time()
        local time_str = string.format('%02d:%02d', hours, minutes)
        local weekdays = {'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'}
        local unix_time = client.unix_time()
        local day_of_week = math.floor(unix_time / 86400 + 4) % 7 + 1
        local day_str = weekdays[day_of_week]
        local lat_ms = 0
        if client.latency then
            local ok, v = pcall(client.latency)
            if ok and type(v) == 'number' then lat_ms = math.floor(v * 1000 + 0.5) end
        end
        local num_str = tostring(lat_ms)
        local gap = 12
        local gap_small = 6
        local show_opts = interface.visuals.watermark_show:get() or {}
        local show_script = utils.contains(show_opts, 'script')
        local show_player = utils.contains(show_opts, 'player')
        local show_time = utils.contains(show_opts, 'time')
        local show_ping = utils.contains(show_opts, 'ping')
        local total_w = 0
        local first = true
        if show_script then
            total_w = total_w + (select(1, renderer.measure_text('b', 'noctua')) or 0)
            first = false
        end
        if show_player then
            if not first then total_w = total_w + gap end
            total_w = total_w + (select(1, renderer.measure_text('', username)) or 0)
            first = false
        end
        if show_time then
            if not first then total_w = total_w + gap end
            total_w = total_w + (select(1, renderer.measure_text('', time_str)) or 0) + gap_small + (select(1, renderer.measure_text('', day_str)) or 0)
            first = false
        end
        if show_ping then
            if not first then total_w = total_w + gap end
            total_w = total_w + (select(1, renderer.measure_text('', num_str)) or 0) + gap_small + (select(1, renderer.measure_text('', 'ms')) or 0)
            first = false
        end
        return math.max(total_w, 60), lineh + 8
    end,
    draw = function(ctx)
        local username = _nickname or 'user'
        local hours, minutes, seconds, milliseconds = client.system_time()
        local time_str = string.format('%02d:%02d', hours, minutes)
        local weekdays = {'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'}
        local unix_time = client.unix_time()
        local day_of_week = math.floor(unix_time / 86400 + 4) % 7 + 1
        local day_str = weekdays[day_of_week]
        local lat_ms = 0
        if client.latency then
            local ok, v = pcall(client.latency)
            if ok and type(v) == 'number' then lat_ms = math.floor(v * 1000 + 0.5) end
        end
        local num_str = tostring(lat_ms)
        local gap = 12
        local gap_small = 6
        local r_accent, g_accent, b_accent = unpack(interface.visuals.accent.color.value)
        
        local show_opts = interface.visuals.watermark_show:get() or {}
        local show_script = utils.contains(show_opts, 'script')
        local show_player = utils.contains(show_opts, 'player')
        local show_time = utils.contains(show_opts, 'time')
        local show_ping = utils.contains(show_opts, 'ping')
        
        local parts = {}
        if show_script then
            table.insert(parts, { text = 'noctua', color = {r_accent, g_accent, b_accent}, flags = 'b' })
        end
        if show_player then
            table.insert(parts, { text = username, color = {255,255,255}, flags = '' })
        end
        if show_time then
            table.insert(parts, { text = time_str, color = {255,255,255}, flags = '' })
            table.insert(parts, { text = day_str, color = {150,150,150}, flags = '', small_gap = true })
        end
        if show_ping then
            table.insert(parts, { text = num_str, color = {255,255,255}, flags = '' })
            table.insert(parts, { text = 'ms', color = {150,150,150}, flags = '', small_gap = true })
        end
        
        if #parts == 0 then return end
        
        local max_h = 0
        local total_w = 0
        for i = 1, #parts do
            local p = parts[i]
            local w, h = renderer.measure_text(p.flags, p.text)
            w = w or 0; h = h or 0
            if i > 1 then
                if p.small_gap then
                    total_w = total_w + gap_small
                else
                    total_w = total_w + gap
                end
            end
            total_w = total_w + w
            if h > max_h then max_h = h end
        end
        if max_h == 0 then max_h = select(2, renderer.measure_text('', 'A')) or 12 end
        
        local start_x = ctx.x + (ctx.w - total_w) / 2
        local base_y = math.floor(ctx.y + (ctx.h - max_h) / 2 + 0.5)
        local x = math.floor(start_x + 0.5)
        for i = 1, #parts do
            local p = parts[i]
            if i > 1 then
                if p.small_gap then
                    x = x + gap_small
                else
                    x = x + gap
                end
            end
            local _, h = renderer.measure_text(p.flags, p.text); h = h or max_h
            local y_i = math.floor(base_y + (max_h - h) / 2 + 0.5)
            renderer.text(x, y_i, p.color[1], p.color[2], p.color[3], 255, p.flags, 0, p.text)
            x = x + (select(1, renderer.measure_text(p.flags, p.text)) or 0)
        end
    end,
    z = 7
})

widgets.register({
    id = "damage_indicator",
    title = "Damage Indicator",
    defaults = { anchor_x = "center", anchor_y = "center", offset_x = 0, offset_y = 30 },
    get_size = function(st)
        local lineh = select(2, renderer.measure_text("c", "A")) or 12
        local samples = {"1", "120", "50"}
        local maxw = 0
        for i = 1, #samples do
            local w = select(1, renderer.measure_text("c", samples[i])) or 0
            if w > maxw then maxw = w end
        end
        return maxw + 6, lineh + 4
    end,
    draw = function(ctx)
        visuals:damage_indicator(ctx.x + ctx.w / 2, ctx.y + (ctx.h / 2))
    end,
    z = 9
})

widgets.register({
    id = "lc_status",
    title = "LC Status",
    defaults = { anchor_x = "center", anchor_y = "center", offset_x = 0, offset_y = 45 },
    get_size = function(st)
        local lineh = select(2, renderer.measure_text('c', 'A')) or 12
        local samples = { 'lc status', 'ticks', 'failed', 'bad', 'ok', 'good', 'great', 'excellent', 'ideal lc', 'god lc', 'world threat lc', '14t' }
        local maxw = 0
        for i = 1, #samples do
            local w = select(1, renderer.measure_text('c', samples[i])) or 0
            if w > maxw then maxw = w end
        end
        return math.max(maxw, 80), lineh * 2 + 6
    end,
    draw = function(ctx)
        local line_spacing = 12
        local base_x = ctx.cx
        local base_y = ctx.cy - line_spacing / 2
        visuals:lc_status(base_x, base_y, ctx.edit_mode)
    end,
    z = 8
})

widgets.load_from_db()
client.set_event_callback("paint_ui", function()
    widgets.paint_ui()
end)

client.set_event_callback('pre_config_save', function()
    widgets.save_all()
end)

client.set_event_callback('post_config_load', function() 
    widgets.load_from_db() 
    streamer_mode.load_db()
end)

if interface.utility.streamer_mode then
    interface.utility.streamer_mode:set_callback(function()
        if interface.utility.streamer_mode:get() then
            for _, img in ipairs(streamer_mode.active_images) do
                local widget_id = "streamer_mode_img_" .. img.id
                if widgets.items[widget_id] then
                    widgets.items[widget_id] = nil
                    for idx, order_id in ipairs(widgets.order) do
                        if order_id == widget_id then
                            table.remove(widgets.order, idx)
                            break
                        end
                    end
                    widgets.state[widget_id] = nil
                end
            end
        else
            for _, img in ipairs(streamer_mode.active_images) do
                local widget_id = "streamer_mode_img_" .. img.id
                widgets.items[widget_id] = nil
                for idx, order_id in ipairs(widgets.order) do
                    if order_id == widget_id then
                        table.remove(widgets.order, idx)
                        break
                    end
                end
                widgets.state[widget_id] = nil
            end
        end
    end)
end


client.set_event_callback("shutdown", function()
    logging:clearCache()
end)

client.set_event_callback("game_start", function()
    _G.noctua_runtime.stats = { hits = 0, misses = 0 }
end)

local aimHandlers = {
    aim_fire = function(e) logging:handleAimFire(e) end,
    aim_miss = function(e) logging:handleAimMiss(e); _G.noctua_runtime.stats.misses = _G.noctua_runtime.stats.misses + 1 end,
    aim_hit  = function(e) logging:handleAimHit(e); _G.noctua_runtime.stats.hits = _G.noctua_runtime.stats.hits + 1 end,
    player_hurt = function(e)
        local victim = client.userid_to_entindex(e.userid)
        local attacker = client.userid_to_entindex(e.attacker)
        local me = entity.get_local_player()

        if not me then
            return
        end

        if victim == me and attacker ~= me then
            logging:handleDamageTaken(e)
            return
        end

        if attacker ~= me then
            return
        end

        if e.weapon == "hegrenade" then
            logging:handleNaded(e)
            return
        end
        
        if e.weapon == "knife" then
            logging:handleKnifed(e)
            return
        end
        
        if victim and logging.cache[victim] then
            local cache = logging.cache[victim]
            cache.got_hurt = true
            cache.hurt_time = globals.realtime()
            cache.damage_taken = e.dmg_health
            cache.hitgroup = e.hitgroup
        end
    end,
    bullet_impact = function(e)
        local shooter = client.userid_to_entindex(e.userid)
        local me = entity.get_local_player()
        if not me or shooter ~= me then 
            return 
        end
        
        local impact = vector(e.x, e.y, e.z)
        local eye_pos = vector(client.eye_position())
        local players = entity.get_players(true)
        
        for i=1, #players do
            local player = players[i]
            if player and entity.is_alive(player) then
                local hit_ent, hit_dmg = client.trace_bullet(
                    me,
                    eye_pos.x, eye_pos.y, eye_pos.z,   -- from position (eye pos)
                    impact.x, impact.y, impact.z,      -- to position (impact)
                    false                              -- dont skip players
                )
                
                if hit_ent == player and hit_dmg > 0 then
                    if logging.cache[player] then
                        local cache = logging.cache[player]
                        cache.had_impact = true
                        cache.got_hit = true
                        cache.impact_pos = impact
                        cache.hit_dmg = hit_dmg
                        
                        local head_pos = {entity.hitbox_position(player, 0)}
                        local chest_pos = {entity.hitbox_position(player, 4)}
                        local stomach_pos = {entity.hitbox_position(player, 2)}
                        
                        if head_pos and #head_pos == 3 then
                            cache.head_dist = math.sqrt(
                                (impact.x - head_pos[1])^2 + 
                                (impact.y - head_pos[2])^2 + 
                                (impact.z - head_pos[3])^2
                            )
                        end
                        
                        if chest_pos and #chest_pos == 3 then
                            cache.chest_dist = math.sqrt(
                                (impact.x - chest_pos[1])^2 + 
                                (impact.y - chest_pos[2])^2 + 
                                (impact.z - chest_pos[3])^2
                            )
                        end
                        
                        if stomach_pos and #stomach_pos == 3 then
                            cache.stomach_dist = math.sqrt(
                                (impact.x - stomach_pos[1])^2 + 
                                (impact.y - stomach_pos[2])^2 + 
                                (impact.z - stomach_pos[3])^2
                            )
                        end
                        
                        cache.impact_time = globals.realtime()
                    end
                    break
                end
            end
        end
    end
}

for event, callback in pairs(aimHandlers) do
    client.set_event_callback(event, callback)
end

client.set_event_callback("setup_command", function(cmd)
    if widgets.is_dragging then
        cmd.in_attack = 0
    end
end)
--@endregion

--@region: unlock fd speed
unlock_fd_speed = {} do
    local FAST_SPEED = 150

    unlock_fd_speed.on_setup_command = function(cmd)
        if not interface.utility.unlock_fd_speed:get() then
            return
        end

        if not ui.get(ui_references.fakeduck) then
            return
        end

        local lp = entity.get_local_player()
        if not lp or not entity.is_alive(lp) then
            return
        end

        local vel_x, vel_y = player.get_velocity(lp)
        if math.abs(vel_x) <= 10 and math.abs(vel_y) <= 10 then
            return
        end

        local move_len = math.sqrt(cmd.forwardmove * cmd.forwardmove + cmd.sidemove * cmd.sidemove)
        if move_len <= 0 then
            return
        end

        cmd.forwardmove = (cmd.forwardmove / move_len) * FAST_SPEED
        cmd.sidemove = (cmd.sidemove / move_len) * FAST_SPEED
    end

    client.set_event_callback("setup_command", unlock_fd_speed.on_setup_command)
end
--@endregion

--@region: item anti-crash
-- anti_crash = {} do
--     local hooked = false
--     local original_dispatch = nil
--     local hooked_vtable = nil
--     local pointer = nil
--     local vtable = nil

--     local CS_UM_SendPlayerItemFound = 63

--     local DispatchUserMessage_t = ffi.typeof [[
--         bool(__thiscall*)(void*, int msg_type, int nFlags, int size, const void* msg)
--     ]]

--     local function apply_hook()
--         local VClient018 = client.create_interface("client.dll", "VClient018")
--         if not VClient018 then return end

--         pointer = ffi.cast("uintptr_t**", VClient018)
--         vtable = ffi.cast("uintptr_t*", pointer[0])

--         local size = 0
--         while vtable[size] ~= 0x0 do
--            size = size + 1
--         end

--         hooked_vtable = ffi.new("uintptr_t[?]", size)
--         for i = 0, size - 1 do
--             hooked_vtable[i] = vtable[i]
--         end
--         pointer[0] = hooked_vtable

--         original_dispatch = ffi.cast(DispatchUserMessage_t, vtable[38])

--         local function hkDispatch(thisptr, msg_type, nFlags, size, msg)
--             if msg_type == CS_UM_SendPlayerItemFound or 
--                (msg_type == 6 and ffi.string(msg, size):find("#Cstrike_Name_Change")) then
--                 return false
--             end
--             return original_dispatch(thisptr, msg_type, nFlags, size, msg)
--         end
        
--         hooked_vtable[38] = ffi.cast("uintptr_t", ffi.cast(DispatchUserMessage_t, hkDispatch))
--         hooked = true
--     end

--     local function remove_hook()
--         if hooked_vtable and vtable and pointer then
--             hooked_vtable[38] = vtable[38]
--             pointer[0] = vtable
--         end
--         hooked = false
--     end

--     function anti_crash.toggle()
--         local should_enable = interface.utility.item_anti_crash:get()
        
--         if should_enable and not hooked then
--             apply_hook()
--         elseif not should_enable and hooked then
--             remove_hook()
--         end
--     end

--     client.set_event_callback("paint_ui", function()
--         anti_crash.toggle()
--     end)
    
--     client.set_event_callback("shutdown", function()
--         if hooked then remove_hook() end
--     end)
-- end
--@endregion

--@region: hitsound
hitsound = {} do
    local hitsound_original = ui.reference("Visuals", "Player ESP", "Hit marker sound")
    hitsound.hitsound_original_state = nil
    local hitsound_enabled_prev = nil
    
    hitsound.on_player_hurt = function(e)
        if not interface.utility.hitsound:get() then return end
        
        local attacker = client.userid_to_entindex(e.attacker)
        local local_player = entity.get_local_player()
        
        if attacker == local_player then
            client.exec("play physics/wood/wood_plank_impact_hard4.wav")
        end
    end
    
    hitsound.setup = function()
        local hitsound_enabled = interface.utility.hitsound:get()
        
        if hitsound_enabled ~= hitsound_enabled_prev then
            if hitsound_enabled then
                hitsound.hitsound_original_state = ui.get(hitsound_original)
                ui.set(hitsound_original, false)
                ui.set_enabled(hitsound_original, false)
            else
                ui.set_enabled(hitsound_original, true)
                ui.set(hitsound_original, hitsound.hitsound_original_state or false)
            end
            hitsound_enabled_prev = hitsound_enabled
        end
    end
    
    client.set_event_callback("player_hurt", hitsound.on_player_hurt)
    client.set_event_callback("paint", hitsound.setup)
end
--@endregion

--@region: buybot
buybot = {} do
    buybot.current_round_number = 0

    buybot.primary_console = {
        ["-"] = "",
        ["autosnipers"] = "scar20",
        ["scout"] = "ssg08",
        ["awp"] = "awp"
    }
    
    buybot.secondary_console = {
        ["-"] = "",
        ["r8 / deagle"] = "deagle",
        ["tec-9 / five-s / cz-75"] = "tec9",
        ["duals"] = "elite",
        ["p-250"] = "p250"
    }
    
    buybot.utility_console = {
        ["kevlar"] = "vest",
        ["helmet"] = "vesthelm",
        ["defuser"] = "defuser",
        ["taser"] = "taser",
        ["he"] = "hegrenade",
        ["molotov"] = "molotov",
        ["smoke"] = "smokegrenade"
    }

    buybot.get_next_round_number = function()
        local game_rules = entity.get_all("CCSGameRulesProxy")[1]
        if not game_rules then
            return 0
        end

        if entity.get_prop(game_rules, "m_bWarmupPeriod") == 1 then
            return 0
        end

        local rounds_played = entity.get_prop(game_rules, "m_totalRoundsPlayed") or 0
        return rounds_played + 1
    end

    buybot.is_pistol_round = function()
        local next_round = buybot.current_round_number
        if next_round == nil or next_round <= 0 then
            next_round = buybot.get_next_round_number()
        end

        if next_round <= 0 then
            return false
        end

        local max_rounds = tonumber(client.get_cvar("mp_maxrounds")) or 30
        local rounds_per_half = math.max(1, math.floor(max_rounds / 2))

        return next_round == 1 or next_round == (rounds_per_half + 1)
    end

    buybot.has_primary_weapon = function()
        local local_player = entity.get_local_player()
        if not local_player then return false end
        local weapon = entity.get_player_weapon(local_player)
        
        for i = 0, 63 do
            local weapon_ent = entity.get_prop(local_player, "m_hMyWeapons", i)
            if weapon_ent then
                local weap_class = entity.get_classname(weapon_ent)
                if weap_class == "CWeaponSSG08" or
                   weap_class == "CWeaponAWP" or
                   weap_class == "CWeaponSCAR20" or
                   weap_class == "CWeaponG3SG1" then
                    return true
                end
            end
        end
        return false
    end

    buybot.on_player_spawn = function(e)
        if client.userid_to_entindex(e.userid) ~= entity.get_local_player() then
            return
        end
    end

    buybot.try_buy = function()
        client.delay_call(0.25, function()
            local local_player = entity.get_local_player()
            if not local_player then
                return
            end

            local money = entity.get_prop(local_player, "m_iAccount") or 0
            if not interface.utility.buybot:get() or money <= 1000 or buybot.is_pistol_round() then
                return
            end

            local primary_item = buybot.primary_console[interface.utility.buybot_primary:get()]
            local primary_fallback_item = buybot.primary_console[interface.utility.buybot_primary_fallback:get()]
            local secondary_item = buybot.secondary_console[interface.utility.buybot_secondary:get()]
            local selected_utilities = interface.utility.buybot_utility:get()
            local command_queue = ""

            if secondary_item and secondary_item ~= "" then
                command_queue = command_queue .. "buy " .. secondary_item .. ";"
            end

            if selected_utilities then
                for _, utility in ipairs(selected_utilities) do
                    local utility_item = buybot.utility_console[utility]
                    if utility_item and utility_item ~= "" then
                        command_queue = command_queue .. "buy " .. utility_item .. ";"
                    end
                end
            end

            if primary_item and primary_item ~= "" then
                command_queue = command_queue .. "buy " .. primary_item .. ";"

                if primary_fallback_item and primary_fallback_item ~= "" then
                    client.delay_call(0.4, function()
                        if not buybot.has_primary_weapon() then
                            client.exec("buy " .. primary_fallback_item)
                        end
                    end)
                end
            elseif primary_fallback_item and primary_fallback_item ~= "" then
                command_queue = command_queue .. "buy " .. primary_fallback_item .. ";"
            end

            if command_queue ~= "" then
                client.exec(command_queue)
            end
        end)
    end

    buybot.on_round_prestart = function()
        buybot.current_round_number = buybot.get_next_round_number()
        if buybot.current_round_number > 0 then
            buybot.try_buy()
        end
    end

    buybot.reset_round_cache = function()
        buybot.current_round_number = 0
    end
    
    client.set_event_callback("round_prestart", buybot.on_round_prestart)
    client.set_event_callback("cs_game_disconnected", buybot.reset_round_cache)
    client.set_event_callback("game_newmap", buybot.reset_round_cache)
end
--@endregion

--@region: configs
configs = {} do
    local DB_KEY = 'noctua.configs'
    local default_config = "noctua:eyJ3aWRnZXRzIjogeyJzdHJlYW1lcl9tb2RlX2ltZ18zOSI6IHsib2Zmc2V0X3kiOiA5OTcsImFuY2hvcl94IjogImNlbnRlciIsIm9mZnNldF94IjogMH0sInN0cmVhbWVyX21vZGVfaW1nXzM4IjogeyJhbmNob3JfeSI6ICJjZW50ZXIiLCJvZmZzZXRfeSI6IDk1Mi45OTQ3NDMzMDU0NywiYW5jaG9yX3giOiAiY2VudGVyIiwib2Zmc2V0X3giOiA3NzUuMjAxNTIyODU0Nzd9LCJzdHJlYW1lcl9tb2RlX2ltZ185IjogeyJhbmNob3JfeSI6ICJjZW50ZXIiLCJvZmZzZXRfeSI6IDk2ODcuMTI4NDU4OTA4OSwiYW5jaG9yX3giOiAiY2VudGVyIiwib2Zmc2V0X3giOiAxOTY1Ny45OTc0MjU0NDd9LCJkYW1hZ2VfaW5kaWNhdG9yIjogeyJvZmZzZXRfeCI6IDk3MCwib2Zmc2V0X3kiOiA1NTd9LCJzY3JlZW5fbG9nZ2luZyI6IHsib2Zmc2V0X3kiOiA4NzguNSwiYW5jaG9yX3giOiAiY2VudGVyIiwib2Zmc2V0X3giOiAwfSwic3RyZWFtZXJfbW9kZV9pbWdfMjQiOiB7ImFuY2hvcl95IjogImNlbnRlciIsIm9mZnNldF95IjogMzkyOCwiYW5jaG9yX3giOiAiY2VudGVyIiwib2Zmc2V0X3giOiA5MTExfSwibGNfc3RhdHVzIjogeyJvZmZzZXRfeSI6IDEwNiwiYW5jaG9yX3giOiAiY2VudGVyIiwib2Zmc2V0X3giOiAwfSwid2F0ZXJtYXJrIjogeyJvZmZzZXRfeSI6IDEwNTcsImFuY2hvcl94IjogImNlbnRlciIsIm9mZnNldF94IjogMH0sInN0cmVhbWVyX21vZGVfaW1nXzciOiB7ImFuY2hvcl95IjogImNlbnRlciIsIm9mZnNldF95IjogMTM1ODMsImFuY2hvcl94IjogImNlbnRlciIsIm9mZnNldF94IjogMjY5NzJ9LCJib21iX3RpbWVyIjogeyJvZmZzZXRfeSI6IDE0MiwiYW5jaG9yX3giOiAiY2VudGVyIiwib2Zmc2V0X3giOiAwfSwiZGVidWdfd2luZG93IjogeyJhbmNob3JfeSI6ICJjZW50ZXIiLCJvZmZzZXRfeSI6IDAsIm9mZnNldF94IjogOTN9LCJzdHJlYW1lcl9tb2RlX2ltZ18yMSI6IHsiYW5jaG9yX3kiOiAiY2VudGVyIiwib2Zmc2V0X3kiOiA0NDk5LjAwMDA2MDAwNiwiYW5jaG9yX3giOiAiY2VudGVyIiwib2Zmc2V0X3giOiAxMDQyNi4wMDAwNjI2NTZ9LCJzdHJlYW1lcl9tb2RlX2ltZ18xIjogeyJvZmZzZXRfeSI6IDEwMDgsImFuY2hvcl94IjogImNlbnRlciIsIm9mZnNldF94IjogMH0sImNyb3NzaGFpcl9pbmRpY2F0b3JzIjogeyJvZmZzZXRfeSI6IDU3MiwiYW5jaG9yX3giOiAiY2VudGVyIiwib2Zmc2V0X3giOiAwfX0sInZhbHVlcyI6IHsidmlzdWFscy5lbmVteV9waW5nX3dhcm4iOiB0cnVlLCJ2aXN1YWxzLndpbmRvdyI6IHRydWUsInV0aWxpdHkuYnV5Ym90X3ByaW1hcnkiOiAiYXV0b3NuaXBlcnMiLCJ2aXN1YWxzLnNlY29uZGFyeSI6ICJzZWNvbmRhcnkgY29sb3IiLCJ2aXN1YWxzLmdyZW5hZGVfcmFkaXVzX21vbG90b3ZfY29sb3IuY29sb3IiOiBbMjU1LDIwNCwyMDMsMjU1XSwidmlzdWFscy52aWV3bW9kZWwiOiB0cnVlLCJ2aXN1YWxzLmdyZW5hZGVfcmFkaXVzX3Ntb2tlX2NvbG9yIjogInNtb2tlIGNvbG9yIiwidmlzdWFscy5sb2dnaW5nX29wdGlvbnMiOiBbImNvbnNvbGUiLCJzY3JlZW4iXSwidmlzdWFscy5hc3BlY3RfcmF0aW8iOiB0cnVlLCJ2aXN1YWxzLmFzcGVjdF9yYXRpb19zbGlkZXIiOiAxMjUsInZpc3VhbHMuY3Jvc3NoYWlyX2luZGljYXRvcnMiOiBmYWxzZSwidmlzdWFscy53aW5kb3dfZmxhZyI6IGZhbHNlLCJ2aXN1YWxzLnZndWkuY29sb3IiOiBbOTEsOTEsOTEsMjU1XSwidmlzdWFscy50aGlyZHBlcnNvbl9zbGlkZXIiOiAzMCwidmlzdWFscy5sb2dnaW5nX3NsaWRlciI6IDI0MCwidmlzdWFscy52Z3VpIjogInZndWkgY29sb3IiLCJ2aXN1YWxzLnZpZXdtb2RlbF95IjogMCwidXRpbGl0eS5zdHJlYW1lcl9tb2RlIjogZmFsc2UsInV0aWxpdHkuYnV5Ym90X3V0aWxpdHkiOiBbImtldmxhciIsImhlbG1ldCIsImRlZnVzZXIiLCJ0YXNlciIsImhlIiwibW9sb3RvdiIsInNtb2tlIl0sImFpbWJvdC5yZXNvbHZlcl9tb2RlIjogImV4cGVyaW1lbnRhbCIsInV0aWxpdHkub25fYWlyX29wdGlvbnMiOiAiZnJvemVuIiwidmlzdWFscy5zdGlja21hbi5jb2xvciI6IFsyNTUsMjU1LDI1NSwxNDBdLCJ1dGlsaXR5LmtpbGxzYXkiOiBmYWxzZSwidmlzdWFscy50aGlyZHBlcnNvbiI6IHRydWUsInZpc3VhbHMuc3RpY2ttYW4iOiBmYWxzZSwidmlzdWFscy5lbmVteV9waW5nX21pbmltdW0iOiA3MCwidmlzdWFscy56b29tX2FuaW1hdGlvbiI6IGZhbHNlLCJ2aXN1YWxzLnNlY29uZGFyeS5jb2xvciI6IFsyNDEsMjMxLDI1NSwyNTVdLCJ2aXN1YWxzLndvcmxkX2RhbWFnZSI6IHRydWUsInZpc3VhbHMuZW5hYmxlZF92aXN1YWxzIjogdHJ1ZSwidmlzdWFscy5ncmVuYWRlX3JhZGl1c19tb2xvdG92X2NvbG9yIjogIm1vbG90b3YgY29sb3IiLCJhaW1ib3Quc2lsZW50X3Nob3QiOiB0cnVlLCJhaW1ib3Qubm9zY29wZV9kaXN0YW5jZV9zY291dCI6IDQ1MCwidmlzdWFscy5ncmVuYWRlX3JhZGl1cyI6IFsic21va2UiLCJtb2xvdG92Il0sInZpc3VhbHMuYWNjZW50LmNvbG9yIjogWzIwOCwxNzEsMjU1LDI1NV0sInV0aWxpdHkuYnV5Ym90X3NlY29uZGFyeSI6ICJ0ZWMtOSAvIGZpdmUtcyAvIGN6LTc1IiwidmlzdWFscy52aWV3bW9kZWxfeiI6IDAsImFpbWJvdC5lbmFibGVkX3Jlc29sdmVyX3R3ZWFrcyI6IHRydWUsInV0aWxpdHkub25fZ3JvdW5kX29wdGlvbnMiOiAiaml0dGVyIiwiYWltYm90LmVuYWJsZWRfYWltYm90IjogdHJ1ZSwidmlzdWFscy5jcm9zc2hhaXJfYW5pbWF0ZV9zY29wZSI6IHRydWUsImFpbWJvdC5mb3JjZV9yZWNoYXJnZSI6IHRydWUsInZpc3VhbHMubG9nZ2luZ19vcHRpb25zX2NvbnNvbGUiOiBbImhpdCIsIm1pc3MiLCJhaW1ib3QiXSwidXRpbGl0eS5ib2R5X2xlYW5fYW1vdW50IjogMTAwLCJ2aXN1YWxzLmNyb3NzaGFpcl9zdHlsZSI6ICJjZW50ZXIiLCJ2aXN1YWxzLmdyZW5hZGVfcmFkaXVzX3Ntb2tlX2NvbG9yLmNvbG9yIjogWzE3MywyMTYsMjMwLDI1NV0sInV0aWxpdHkuYnV5Ym90X3ByaW1hcnlfZmFsbGJhY2siOiAic2NvdXQiLCJhaW1ib3Qubm9zY29wZV9kaXN0YW5jZV9hdXRvc25pcGVycyI6IDQ1MCwidXRpbGl0eS5idXlib3QiOiB0cnVlLCJ2aXN1YWxzLmRhbWFnZV9pbmRpY2F0b3IiOiB0cnVlLCJhaW1ib3QucXVpY2tfc3RvcC5ob3RrZXlfbW9kZV9pZHgiOiAwLCJ1dGlsaXR5LmhpdHNvdW5kIjogdHJ1ZSwidXRpbGl0eS5wYXJ0eV9tb2RlIjogZmFsc2UsInZpc3VhbHMud2F0ZXJtYXJrX3Nob3ciOiBbInRpbWUiLCJwaW5nIl0sInV0aWxpdHkuYW5pbWF0aW9uX2JyZWFrZXJzIjogWyJ6ZXJvIG9uIGxhbmQiLCJlYXJ0aHF1YWtlIiwic2xpZGluZyBzbG93IG1vdGlvbiIsInNsaWRpbmcgY3JvdWNoIiwib24gZ3JvdW5kIiwib24gYWlyIiwicXVpY2sgcGVlayBsZWdzIiwiYm9keSBsZWFuIl0sInV0aWxpdHkuY2xhbnRhZyI6IGZhbHNlLCJ1dGlsaXR5LnN0cmVhbWVyX21vZGVfc2VsZWN0IjogMSwidXRpbGl0eS5raWxsc2F5X21vZGVzIjogWyJvbiBraWxsIiwib24gZGVhdGgiXSwiYWltYm90Lm5vc2NvcGVfZGlzdGFuY2VfYXdwIjogNDUwLCJ2aXN1YWxzLnpvb21fYW5pbWF0aW9uX3NwZWVkIjogNTAsInZpc3VhbHMubG9nZ2luZyI6IHRydWUsInZpc3VhbHMud29ybGRfZGFtYWdlX3R5cGUiOiAiZHluYW1pYyIsImFpbWJvdC5xdWlja19zdG9wIjogZmFsc2UsInZpc3VhbHMubGNfc3RhdHVzIjogZmFsc2UsInZpc3VhbHMud2F0ZXJtYXJrIjogZmFsc2UsImFpbWJvdC5ub3Njb3BlX2Rpc3RhbmNlIjogdHJ1ZSwidmlzdWFscy52aWV3bW9kZWxfZm92IjogMjUsInZpc3VhbHMuem9vbV9hbmltYXRpb25fdmFsdWUiOiAyLCJ2aXN1YWxzLnNwYXduX3pvb20iOiB0cnVlLCJ2aXN1YWxzLnZpZXdtb2RlbF94IjogMCwidmlzdWFscy5ib21iX3RpbWVyIjogdHJ1ZSwidmlzdWFscy5hY2NlbnQiOiAiYWNjZW50IGNvbG9yIiwiYWltYm90LnF1aWNrX3N0b3AuaG90a2V5X2tleWNvZGUiOiAzMiwidmlzdWFscy5sb2dnaW5nX29wdGlvbnNfc2NyZWVuIjogWyJoaXQiLCJtaXNzIiwiYWltYm90Il0sImFpbWJvdC5ub3Njb3BlX3dlYXBvbnMiOiBbImF1dG9zbmlwZXJzIl19LCJ2ZXJzaW9uIjogMSwiY29uZmlnX25hbWUiOiAidGVzdCJ9"

    local b64_chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local function b64_encode_fallback(str)
        return ((str:gsub('.', function(x)
            local r,b='',x:byte()
            for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
            return r
        end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
            if (#x < 6) then return '' end
            local c=0
            for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
            return b64_chars:sub(c+1,c+1)
        end)..({ '', '==', '=' })[#str%3+1])
    end

    local function b64_decode_fallback(str)
        str = string.gsub(str, '%s', '')
        str = string.gsub(str, '[^'..b64_chars..'=]', '')
        return (str:gsub('.', function(x)
            if (x == '=') then return '' end
            local r,f='',(b64_chars:find(x)-1)
            for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
            return r
        end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
            if (#x ~= 8) then return '' end
            local c=0
            for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
        end))
    end

    local function b64_encode(str)
        if ok_base64 and base64 and base64.encode then
            local ok, out = pcall(base64.encode, str)
            if ok and out then return out end
        end
        return b64_encode_fallback(str)
    end

    local function b64_decode(str)
        if ok_base64 and base64 and base64.decode then
            local ok, out = pcall(base64.decode, str)
            if ok and out then return out end
        end
        return b64_decode_fallback(str)
    end

    local state = { list = {}, data = {}, load_on_startup = nil }
    local current_loaded_config = nil

    local function screen_key()
        local w, h = client.screen_size()
        return tostring(w) .. 'x' .. tostring(h)
    end

    function configs.load_db()
        local ok, data = pcall(database.read, DB_KEY)
        if ok and type(data) == 'table' then
            state = {
                list = data.list or {},
                data = data.data or {},
                load_on_startup = data.load_on_startup or nil
            }
        else
            state = { list = {}, data = {}, load_on_startup = nil }
        end
    end

    function configs.save_db()
        pcall(database.write, DB_KEY, { list = state.list, data = state.data, load_on_startup = state.load_on_startup })
    end

    function configs.update_list_ui()
        local items = {}
        local has_default = (type(default_config) == 'string' and default_config ~= '')
        if has_default then
            table.insert(items, 'default')
        end
        if type(state.list) == 'table' and #state.list > 0 then
            for _, n in ipairs(state.list) do
                table.insert(items, n)
            end
        end
        table.insert(items, '+ new')
        interface.config.list:update(items)
        interface.config.list:set(0)
    end

    local function collect_group(prefix, group, out)
        if not group then return end
        pui.traverse(group, function(element, path)
            if not element then return end
            local key = prefix .. '.' .. table.concat(path, '.')

            local got_ok, v1, v2, v3 = false, nil, nil, nil
            if element.get then
                local ok, a, b, c = pcall(function() return element:get() end)
                if ok then got_ok, v1, v2, v3 = true, a, b, c end
            end

            if got_ok and v1 ~= nil then
                out.values[key] = v1
            end

            local okc, cv = pcall(function() return element.color.value end)
            if okc and type(cv) == 'table' then
                out.values[key .. '.color'] = cv
            end

            local okh, _active, mode_idx, keycode = pcall(function() return element.hotkey:get() end)
            if okh then
                out.values[key .. '.hotkey_mode_idx'] = mode_idx
                if keycode ~= nil then out.values[key .. '.hotkey_keycode'] = keycode end
            elseif got_ok and type(v1) == 'boolean' and type(v2) == 'number' then
                out.values[key .. '.hotkey_mode_idx'] = v2
                if v3 ~= nil then out.values[key .. '.hotkey_keycode'] = v3 end
            end
        end)
    end

    function configs.collect(config_name)
        local out = { version = 1, values = {}, widgets = {} }
        if config_name then
            out.config_name = config_name
        end
        collect_group('aimbot', interface.aimbot, out)
        collect_group('visuals', interface.visuals, out)
        collect_group('utility', interface.utility, out)
        local wkey = screen_key()
        local ok, wpos = pcall(database.read, (widgets and widgets.db_key_prefix or 'noctua.widgets.positions') .. '.' .. wkey)
        if ok and type(wpos) == 'table' then
            out.widgets = wpos
        end
        return out
    end

    local function apply_group(prefix, group, values)
        if not group then return end
        pui.traverse(group, function(element, path)
            if not element then return end
            local key = prefix .. '.' .. table.concat(path, '.')

            local val = values[key]
            if val ~= nil then
                pcall(function() element:set(val) end)
            end
            if element.color and type(val) == 'table' then element.color.value = val end

            local cval = values[key .. '.color']
            if element.color and type(cval) == 'table' then
                element.color.value = cval
            end

            local mode_idx = values[key .. '.hotkey_mode_idx']
            local keycode  = values[key .. '.hotkey_keycode']
            local map = { [0] = 'Always on', [1] = 'On hotkey', [2] = 'Toggle', [3] = 'Hold' }
            local mode_str = (type(mode_idx) == 'number') and map[mode_idx] or nil

            if element.hotkey and mode_str then
                if type(keycode) == 'number' then
                    pcall(function() element.hotkey:set(mode_str, keycode) end)
                else
                    pcall(function() element.hotkey:set(mode_str) end)
                end
            elseif element.set and mode_str then
                if type(keycode) == 'number' then
                    element:set(mode_str, keycode)
                else
                    element:set(mode_str)
                end
            end
        end)
    end

    function configs.apply(data)
        if type(data) ~= 'table' then return end
        local values = data.values or {}
        apply_group('aimbot', interface.aimbot, values)
        apply_group('visuals', interface.visuals, values)
        apply_group('utility', interface.utility, values)
        if data.widgets then
            local key = (widgets and widgets.db_key_prefix or 'noctua.widgets.positions') .. '.' .. screen_key()
            pcall(database.write, key, data.widgets)
            widgets.load_from_db()
            streamer_mode.load_db()
        end
    end

    function configs.load_default()
        if not default_config or default_config == '' then
            logMessage('noctua · config', '', 'default config is empty!')
            return
        end
        local clip = default_config
        clip = clip:gsub('^%s+', ''):gsub('%s+$', '')
        if clip:find('^noctua:') then clip = clip:sub(8) end
        clip = clip:gsub('^%s+', ''):gsub('%s+$', '')
        local decoded = b64_decode(clip)
        if not decoded or decoded == '' then
            logMessage('noctua · config', '', 'failed to decode default base64!')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        local data = json.decode(decoded)
        if type(data) ~= 'table' or not data.values then
            logMessage('noctua · config', '', 'failed to parse default config!')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        configs.apply(data)
        logMessage('noctua · config', '', 'default config loaded successfully!')
        client.exec("play ui/beepclear.wav")
    end

    function configs.create(name)
        if type(name) ~= 'string' then name = '' end
        name = name:gsub('^%s+', ''):gsub('%s+$', '')
        if name == '' or name == '<no configs>' or name == '<default>' or not name:match('%S') then
            logMessage('noctua · config', '', 'enter valid config name!')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        if state.data[name] ~= nil then
            logMessage('noctua · config', '', 'config already exists!')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        state.data[name] = configs.collect()
        table.insert(state.list, name)
        configs.save_db()
        configs.update_list_ui()
        logMessage('noctua · config', '', 'config created!')
        client.exec("play ui/beepclear.wav")
    end

    local function get_selected_name()
        local idx0 = tonumber(interface.config.list:get()) or 0
        local idx = idx0 + 1
        local has_default = (type(default_config) == 'string' and default_config ~= '')
        if has_default then
            if idx == 1 then
                return 'default'
            end
            idx = idx - 1
        end

        local total_items = (has_default and 1 or 0) + #state.list + 1 -- +1 for "+ new"
        if idx0 + 1 == total_items then
            return '+ new'
        end

        local name = state.list[idx]
        return name
    end

    function configs.export_to_clipboard()
        local config_name = get_selected_name()
        if config_name == '+ new' then
            logMessage('noctua · config', '', 'select a valid config first!')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        local payload = configs.collect(config_name)
        local ok, json_str = pcall(json.encode, payload, false)
        if not ok or not json_str then
            logMessage('noctua · config', '', 'failed to encode config!')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        -- print(json_str)
        local enc = b64_encode(json_str)
        clipboard.set('noctua:' .. enc)
        logMessage('noctua · config', '', 'config exported to clipboard!')
        client.exec("play ui/beepclear.wav")
    end

    function configs.import_from_clipboard()
        local clip = clipboard.get() or ''
        clip = clip:gsub('^%s+', ''):gsub('%s+$', '')
        if clip:find('^noctua:') then clip = clip:sub(8) end
        clip = clip:gsub('^%s+', ''):gsub('%s+$', '')
        if clip == '' then
            logMessage('noctua · config', '', 'clipboard is empty!')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        local decoded = b64_decode(clip)
        if not decoded or decoded == '' then
            logMessage('noctua · config', '', 'failed to decode base64!')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        local ok_json, data = pcall(json.decode, decoded)
        if not ok_json then
            logMessage('noctua · config', '', 'json decode error: ' .. tostring(data))
            client.exec("play ui/menu_invalid.wav")
            return
        end
        if type(data) ~= 'table' or not data.values then
            logMessage('noctua · config', '', 'failed to parse config! (invalid structure)')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        configs.apply(data)
        local config_name = data.config_name
        if config_name and config_name ~= 'default' and config_name ~= '+ new' then
            local final_name = config_name
            local counter = 1
            local exists = false
            for _, name in ipairs(state.list) do
                if name == final_name then
                    exists = true
                    break
                end
            end
            while exists do
                final_name = config_name .. ' (' .. counter .. ')'
                exists = false
                for _, name in ipairs(state.list) do
                    if name == final_name then
                        exists = true
                        break
                    end
                end
                if not exists then
                    break
                end
                counter = counter + 1
            end
            table.insert(state.list, final_name)
            state.data[final_name] = data.values
            configs.save_db()
            configs.update_list_ui()
        end
        logMessage('noctua · config', '', 'config imported successfully!')
        client.exec("play ui/beepclear.wav")
    end

    function configs.save_selected()
        local name = get_selected_name()
        if not name then
            logMessage('noctua · config', '', 'select a config first!')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        if name == 'default' or name == '+ new' then
            logMessage('noctua · config', '', 'cannot overwrite default!')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        state.data[name] = configs.collect()
        configs.save_db()
        widgets.save_all()
        logMessage('noctua · config', '', 'config saved!')
        client.exec("play ui/beepclear.wav")
    end

    function configs.save_loaded()
        local name = current_loaded_config
        if not name then
            logMessage('noctua · config', '', 'no config loaded!')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        if name == 'default' or name == '+ new' then
            logMessage('noctua · config', '', 'cannot overwrite default!')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        state.data[name] = configs.collect()
        configs.save_db()
        widgets.save_all()
        logMessage('noctua · config', '', 'config saved!')
        client.exec("play ui/beepclear.wav")
    end

    function configs.load_selected()
        local name = get_selected_name()
        if not name then
            logMessage('noctua · config', '', 'select a config first!')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        if name == 'default' then
            configs.load_default()
            current_loaded_config = 'default'
            return
        end
        if name == '+ new' then
            logMessage('noctua · config', '', 'please create a new config first!')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        local data = state.data[name]
        if type(data) ~= 'table' then
            logMessage('noctua · config', '', 'config data is invalid!')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        configs.apply(data)
        current_loaded_config = name
        logMessage('noctua · config', '', 'config loaded!')
        client.exec("play ui/beepclear.wav")
    end

    function configs.delete_selected()
        local name = get_selected_name()
        if not name then
            logMessage('noctua ·', '', 'select a config first!')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        if name == 'default' or name == '+ new' then
            logMessage('noctua · config', '', 'cannot delete default!')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        state.data[name] = nil
        local new_list = {}
        for _, n in ipairs(state.list) do
            if n ~= name then table.insert(new_list, n) end
        end
        state.list = new_list
        configs.save_db()
        configs.update_list_ui()
        interface.config.list:set(0)
        logMessage('noctua · config', '', 'config deleted!')
        client.exec("play ui/beepclear.wav")
    end

    function configs.toggle_autoload_for_current()
        local name = get_selected_name()
        if not name or name == '<no configs>' or name == '+ new' then
            return
        end

        local checkbox_state = interface.config.load_on_startup:get() or false
        
        if checkbox_state then
            state.load_on_startup = name
        else
            if state.load_on_startup == name then
                state.load_on_startup = nil
            end
        end
        
        configs.save_db()
    end
    
    local _updating_checkbox = false
    
    function configs.update_ui_visibility()
        if not interface.search or interface.search:get() ~= 'config' then return end
        
        local name = get_selected_name()
        local is_new = (name == '+ new')
        local is_default = (name == 'default')
        local has_config = name and name ~= '+ new' and name ~= '<no configs>'
        
        interface.config.name:set_visible(is_new)
        interface.config.create_button:set_visible(is_new)
        interface.config.load_button:set_visible(has_config)
        interface.config.load_on_startup:set_visible(has_config)
        if has_config and name then
            interface.config.load_on_startup:set(state.load_on_startup == name)
        end
        local show_user_buttons = has_config and not is_default
        interface.config.save_button:set_visible(show_user_buttons)
        interface.config.import_button:set_visible(not is_new)
        interface.config.export_button:set_visible(not is_new)
        interface.config.delete_button:set_visible(show_user_buttons)
    end
    
    function configs.update_load_on_startup_checkbox()
        configs.update_ui_visibility()
    end
    
    function configs.load_startup_config()
        if not state.load_on_startup then return end

        if state.load_on_startup == 'default' then
            configs.load_default()
            current_loaded_config = 'default'
            return
        end

        if state.data[state.load_on_startup] then
            configs.apply(state.data[state.load_on_startup])
            current_loaded_config = state.load_on_startup
            logMessage('noctua · config', '', 'autoloaded config: ' .. state.load_on_startup)
        else
            logMessage('noctua · config', '', 'autoload config not found: ' .. state.load_on_startup)
        end
    end

    function configs.init()
        configs.load_db()
        configs.update_list_ui()
        configs.update_load_on_startup_checkbox()
        
        client.delay_call(0.1, function()
            configs.load_startup_config()
        end)

        client.set_event_callback('paint_ui', function()
            configs.update_load_on_startup_checkbox()
        end)

        interface.config.load_on_startup:set_callback(function()
            configs.toggle_autoload_for_current()
        end)

        interface.config.create_button:set_callback(function()
            local name = ''
            name = interface.config.name:get() or ''
            if type(name) ~= 'string' then name = tostring(name or '') end
            name = name:gsub('^%s+', ''):gsub('%s+$', '')
            configs.create(name)
        end)

        interface.config.save_button:set_callback(configs.save_selected)

        interface.config.load_button:set_callback(configs.load_selected)

        interface.config.delete_button:set_callback(configs.delete_selected)

        interface.config.export_button:set_callback(configs.export_to_clipboard)

        interface.config.import_button:set_callback(configs.import_from_clipboard)

        interface.config.list:set_callback(function()
            -- replaced later
        end)
    end
end

configs.init()
client.set_event_callback('shutdown', function() pcall(database.flush) end)
--@endregion

--@region: streamer images db
streamer_images = {} do
    local DB_KEY = 'noctua.images'

    local built_in = {
        rabbit = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSPajxTkvKF1SeE1fOTFTyQOzCcYYZNjH_Afw&s",
        cat = "https://media.tenor.com/sF-65FzDeFIAAAAe/cat-pondering-cat.png",
        guinea_pig = "https://avatars.mds.yandex.net/i?id=105aeb7d42c5450af1d4f4d896b92ac2_l-4801254-images-thumbs&n=13",
        gentlemen = "https://i.ibb.co/ksJMGPwN/csgo-gge-EMXGbc-O-1.png",
        fipp = "https://i.ibb.co/RGxMXq4X/image.png"
    }

    local state = { list = {}, data = {} }
    streamer_images.current_items = {}

    function streamer_images.load_db()
        local ok, data = pcall(database.read, DB_KEY)
        if ok and type(data) == 'table' then
            state.list = data.list or {}
            state.data = data.data or {}
        else
            state.list = {}
            state.data = {}
        end
    end

    function streamer_images.save_db()
        pcall(database.write, DB_KEY, { list = state.list, data = state.data })
    end

    function streamer_images.is_builtin(name)
        return built_in[name] ~= nil
    end

    function streamer_images.get_url(name)
        if built_in[name] then
            return built_in[name]
        end
        return state.data[name]
    end

    function streamer_images.get_all_names()
        local items = {}
        for name, _ in pairs(built_in) do
            table.insert(items, name)
        end
        table.sort(items)
        if type(state.list) == 'table' then
            for _, n in ipairs(state.list) do
                if not streamer_images.is_builtin(n) then
                    table.insert(items, n)
                end
            end
        end
        return items
    end

    function streamer_images.add(name, url)
        if type(name) ~= 'string' then name = '' end
        if type(url) ~= 'string' then url = '' end

        name = name:gsub('^%s+', ''):gsub('%s+$', '')
        url = url:gsub('^%s+', ''):gsub('%s+$', '')

        if name == '' or name == 'how to use' then
            logMessage('noctua · streamer', '', 'enter valid image name!')
            client.exec("play ui/menu_invalid.wav")
            return
        end

        if url == '' then
            logMessage('noctua · streamer', '', 'enter valid image url!')
            client.exec("play ui/menu_invalid.wav")
            return
        end

        if streamer_images.is_builtin(name) then
            logMessage('noctua · streamer', '', 'cannot override built-in image!')
            client.exec("play ui/menu_invalid.wav")
            return
        end

        local exists = false
        for _, n in ipairs(state.list) do
            if n == name then
                exists = true
                break
            end
        end

        if not exists then
            table.insert(state.list, name)
        end

        state.data[name] = url
        streamer_images.save_db()
        streamer_images.update_list_ui()
        logMessage('noctua · streamer', '', 'image added: ' .. name)
        client.exec("play ui/beepclear.wav")
    end

    function streamer_images.remove(name)
        if not name or name == '' then return end
        if streamer_images.is_builtin(name) then
            logMessage('noctua · streamer', '', 'cannot delete built-in image!')
            client.exec("play ui/menu_invalid.wav")
            return
        end

        state.data[name] = nil
        local new_list = {}
        for _, n in ipairs(state.list) do
            if n ~= name then
                table.insert(new_list, n)
            end
        end
        state.list = new_list
        streamer_images.save_db()
        streamer_images.update_list_ui()
        interface.utility.streamer_mode_select:set(0)
        logMessage('noctua · streamer', '', 'image deleted: ' .. name)
        client.exec("play ui/beepclear.wav")
    end

    function streamer_images.update_list_ui()
        streamer_images.current_items = {}
        local all = streamer_images.get_all_names()
        for _, item in ipairs(all) do
            table.insert(streamer_images.current_items, item)
        end
        pcall(function() interface.utility.streamer_mode_select:update(streamer_images.current_items) end)
        pcall(function() interface.utility.streamer_mode_select:set(0) end)
    end

    function streamer_images.get_selected_name()
        local idx = tonumber(interface.utility.streamer_mode_select:get())
        if not idx or idx < 0 then return nil end
        idx = idx + 1
        if not streamer_images.current_items or not streamer_images.current_items[idx] then
            return nil
        end
        return streamer_images.current_items[idx]
    end

    function streamer_images.init()
        streamer_images.load_db()
        local all = streamer_images.get_all_names()
        streamer_images.update_list_ui()

        interface.utility.streamer_mode_delete:set_callback(function()
            local sel = streamer_images.get_selected_name()
            if not sel then
                logMessage('noctua · streamer', '', 'select image first!')
                client.exec("play ui/menu_invalid.wav")
                return
            end
            streamer_images.remove(sel)
        end)

        interface.utility.streamer_mode_add:set_callback(function()
            local sel = streamer_images.get_selected_name()
            if not sel then
                logMessage('noctua · streamer', '', 'select image first!')
                client.exec("play ui/menu_invalid.wav")
                return
            end
            streamer_mode.add_image(sel)
        end)

        interface.utility.streamer_mode_select:set_callback(function()
            local sel = streamer_images.get_selected_name()
            local is_custom = sel ~= nil and not streamer_images.is_builtin(sel)
            interface.utility.streamer_mode_delete:set_visible(is_custom and interface.utility.streamer_mode:get())
        end)

        local sel = streamer_images.get_selected_name()
        local is_custom = sel ~= nil and not streamer_images.is_builtin(sel)
        interface.utility.streamer_mode_delete:set_visible(is_custom and interface.utility.streamer_mode:get())
    end
end

--@endregion

--@region: known alias system
local kas = {} do
    kas.file_path = "kas.json"
    kas.source_presets = { "manual", "public", "community", "league", "report" }
    local menu_color_reference = ui.reference("misc", "settings", "menu color")

    kas.state = {
        database = {
            last_update = "",
            players = {}
        },
        list_items = {},
        list_lookup = {},
        selected_steam_id = nil,
        last_refresh = 0,
        last_notify_refresh = 0,
        notified_players = {}
    }

    local function default_database()
        return {
            last_update = "",
            players = {}
        }
    end

    local function trim(value)
        return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
    end

    local function contains_value(tbl, value)
        for i = 1, #tbl do
            if tostring(tbl[i]) == tostring(value) then
                return true
            end
        end
        return false
    end

    local function copy_array(values)
        local out = {}
        for i = 1, #(values or {}) do
            out[i] = values[i]
        end
        return out
    end

    local normalize_entry

    local function get_secondary_alternatives(entry)
        local normalized = normalize_entry(entry)
        local alternatives = {}

        for i = 1, #normalized.alternative do
            local alt = trim(normalized.alternative[i])
            if alt ~= "" and alt ~= normalized.primary_alias and not contains_value(alternatives, alt) then
                alternatives[#alternatives + 1] = alt
            end
        end

        return alternatives
    end

    local function parse_alternative_input(value)
        local out = {}
        value = tostring(value or "")

        for item in value:gmatch("[^,]+") do
            local alias_name = trim(item)
            if alias_name ~= "" and not contains_value(out, alias_name) then
                out[#out + 1] = alias_name
            end
        end

        return out
    end

    local function color_to_hex(r, g, b, a)
        return string.format("%02x%02x%02x%02x", r or 255, g or 255, b or 255, a or 255)
    end

    local function get_kas_highlight_prefix()
        if not menu_color_reference then
            return ""
        end

        local r, g, b, a = ui.get(menu_color_reference)
        return "\a" .. color_to_hex(r, g, b, a)
    end

    local function is_generated_storage_key(value)
        value = trim(value)
        return value:match("^steam_") ~= nil or value:match("^player_") ~= nil or value:match("^entry_") ~= nil
    end

    local function get_calendar_parts_from_unix(unix_time)
        local total_seconds = math.max(0, math.floor(tonumber(unix_time) or 0))
        local day_seconds = total_seconds % 86400
        local days = math.floor(total_seconds / 86400)
        local year = 1970

        local function is_leap_year(value)
            if value % 400 == 0 then
                return true
            end

            if value % 100 == 0 then
                return false
            end

            return value % 4 == 0
        end

        while true do
            local days_in_year = is_leap_year(year) and 366 or 365
            if days < days_in_year then
                break
            end

            days = days - days_in_year
            year = year + 1
        end

        local month_lengths = {
            31,
            is_leap_year(year) and 29 or 28,
            31,
            30,
            31,
            30,
            31,
            31,
            30,
            31,
            30,
            31
        }

        local month = 1
        while days >= month_lengths[month] do
            days = days - month_lengths[month]
            month = month + 1
        end

        local day = days + 1
        local hour = math.floor(day_seconds / 3600)
        local minute = math.floor((day_seconds % 3600) / 60)
        local second = day_seconds % 60

        return year, month, day, hour, minute, second
    end

    local function current_timestamp_utc()
        local year, month, day, hour, minute, second = get_calendar_parts_from_unix(client.unix_time())
        return string.format("%04d-%02d-%02dT%02d:%02d:%02dZ", year, month, day, hour, minute, second)
    end

    local function current_date_utc()
        local year, month, day = get_calendar_parts_from_unix(client.unix_time())
        return string.format("%04d-%02d-%02d", year, month, day)
    end

    local function resolve_storage_key(entry, fallback_steam_id, current_key)
        local alias_name = trim(entry and entry.primary_alias or "")
        if alias_name ~= "" then
            return alias_name
        end

        local steam_id = trim(fallback_steam_id)
        if steam_id ~= "" then
            return "steam_" .. steam_id
        end

        current_key = trim(current_key)
        if current_key ~= "" then
            return current_key
        end

        return "entry_" .. tostring(client.unix_time())
    end

    local function push_kas(text, duration, console_format, console_args)
        local message = tostring(text or "")
        if message:sub(1, 5) ~= "KAS: " then
            message = "KAS: " .. message
        end

        logging:push(message:gsub("^KAS:%s*", ""), duration)
        if console_format then
            argLogWithPrefix("noctua · KAS", console_format, unpack(console_args or {}))
            return
        end

        logMessage("noctua · KAS", "", message:gsub("^KAS:%s*", ""))
    end

    local function join_clauses(clauses)
        if #clauses == 0 then
            return ""
        end

        if #clauses == 1 then
            return clauses[1]
        end

        if #clauses == 2 then
            return clauses[1] .. " and " .. clauses[2]
        end

        return table.concat(clauses, ", ", 1, #clauses - 1) .. ", and " .. clauses[#clauses]
    end

    local function append_clauses(base_text, clauses, single_joiner, multi_joiner)
        if #clauses == 0 then
            return base_text .. "."
        end

        if #clauses == 1 then
            return base_text .. " " .. single_joiner .. " " .. clauses[1] .. "."
        end

        return base_text .. multi_joiner .. join_clauses(clauses) .. "."
    end

    local function build_log_message(player_name, entry)
        local normalized = normalize_entry(entry)
        local display_name = trim(player_name)
        local alias_name = trim(normalized.primary_alias)
        local source_name = trim(normalized.source)
        local group_name = trim(normalized.group)
        local note_text = trim(normalized.note)
        local clauses = {}

        local function add_clause(text, ...)
            clauses[#clauses + 1] = {
                text = text,
                args = { ... }
            }
        end

        local function format_clauses()
            local parts = {}
            local args = {}

            if #clauses == 0 then
                return "", args
            end

            for i = 1, #clauses do
                local clause = clauses[i]
                local prefix = ""

                if i > 1 then
                    if #clauses == 2 then
                        prefix = " and "
                    elseif i == #clauses then
                        prefix = ", and "
                    else
                        prefix = ", "
                    end
                end

                parts[#parts + 1] = prefix .. clause.text
                for j = 1, #(clause.args or {}) do
                    args[#args + 1] = clause.args[j]
                end
            end

            return table.concat(parts), args
        end

        if display_name == "" then
            display_name = "unknown"
        end

        if source_name ~= "" then
            add_clause('was added from "%s"', source_name)
        end

        if group_name ~= "" then
            add_clause('belongs to "%s" group', group_name)
        end

        if note_text ~= "" then
            add_clause('has a note "%s"', note_text)
        end

        if alias_name ~= "" then
            local screen_clauses = {}
            for i = 1, #clauses do
                screen_clauses[i] = string.format(clauses[i].text, unpack(clauses[i].args or {}))
            end

            local message = append_clauses(
                string.format('KAS: The player "%s" commonly known as "%s"', display_name, alias_name),
                screen_clauses,
                "and",
                ", "
            )
            local clause_format, clause_args = format_clauses()
            local console_args = { display_name, alias_name }
            for i = 1, #clause_args do
                console_args[#console_args + 1] = clause_args[i]
            end

            local console_suffix = ""
            if #clauses == 1 then
                console_suffix = " and " .. clause_format
            elseif #clauses > 1 then
                console_suffix = ", " .. clause_format
            end

            return message, 'The player "%s" commonly known as "%s"' .. console_suffix .. ".", console_args
        end

        if #clauses == 0 then
            return nil
        end

        local screen_clauses = {}
        for i = 1, #clauses do
            screen_clauses[i] = string.format(clauses[i].text, unpack(clauses[i].args or {}))
        end

        local message = append_clauses(
            string.format('KAS: The player "%s" is not in base', display_name),
            screen_clauses,
            "but",
            ", but "
        )
        local clause_format, clause_args = format_clauses()
        local console_args = { display_name }
        for i = 1, #clause_args do
            console_args[#console_args + 1] = clause_args[i]
        end

        return message, 'The player "%s" is not in base, but ' .. clause_format:gsub("^ and ", "") .. ".", console_args
    end

    normalize_entry = function(entry, alias_key)
        if type(entry) ~= "table" then
            return {
                primary_alias = trim(alias_key),
                id = {},
                alternative = trim(alias_key) ~= "" and { trim(alias_key) } or {},
                added_date = "",
                source = "",
                group = "",
                note = ""
            }
        end

        local primary_alias = trim(entry.primary_alias or entry.alias or "")
        local normalized_key = trim(alias_key)
        if primary_alias == "" and normalized_key ~= "" and not is_generated_storage_key(normalized_key) and not normalized_key:match("^%d+$") then
            primary_alias = normalized_key
        end

        local ids = {}
        if type(entry.id) == "table" then
            for i = 1, #entry.id do
                local normalized_id = trim(entry.id[i])
                if normalized_id ~= "" and not contains_value(ids, normalized_id) then
                    ids[#ids + 1] = normalized_id
                end
            end
        end

        local alternative = {}
        if type(entry.alternative) == "table" then
            for i = 1, #entry.alternative do
                local alt = trim(entry.alternative[i])
                if alt ~= "" and not contains_value(alternative, alt) then
                    alternative[#alternative + 1] = alt
                end
            end
        elseif trim(entry.alias or "") ~= "" then
            alternative[1] = trim(entry.alias)
        end

        if primary_alias ~= "" then
            local reordered = { primary_alias }
            for i = 1, #alternative do
                if alternative[i] ~= primary_alias and not contains_value(reordered, alternative[i]) then
                    reordered[#reordered + 1] = alternative[i]
                end
            end
            alternative = reordered
        end

        return {
            primary_alias = primary_alias,
            id = ids,
            alternative = alternative,
            added_date = trim(entry.added_date),
            source = tostring(entry.source or ""),
            group = tostring(entry.group or ""),
            note = tostring(entry.note or "")
        }
    end

    local function migrate_legacy_players(players)
        local migrated = {}

        for key, entry in pairs(players or {}) do
            local normalized = normalize_entry(entry, key)

            if #normalized.id == 0 and tostring(key):match("^%d+$") then
                normalized.id[1] = tostring(key)
            end

            if normalized.primary_alias ~= "" and #normalized.alternative == 0 then
                normalized.alternative = { normalized.primary_alias }
            end

            if normalized.added_date == "" then
                normalized.added_date = current_date_utc()
            end

            migrated[resolve_storage_key(normalized, normalized.id[1], tostring(key))] = normalized
        end

        return migrated
    end

    local function save_database()
        kas.state.database.last_update = current_timestamp_utc()
        local ok, encoded = pcall(json.encode, kas.state.database, true)
        if not ok or not encoded then
            return nil, "failed to encode kas database"
        end

        writefile(kas.file_path, encoded)
        return true
    end

    local function load_database()
        local body = readfile(kas.file_path)
        if not body or body == "" then
            kas.state.database = default_database()
            local ok, err = save_database()
            if not ok then
                push_kas(err, 4)
            end
            return
        end

        local ok, data = pcall(json.decode, body)
        if not ok or type(data) ~= "table" or type(data.players) ~= "table" then
            kas.state.database = default_database()
            push_kas("failed to parse kas.json, file was left untouched", 4)
            return
        end

        kas.state.database = {
            last_update = trim(data.last_update),
            players = migrate_legacy_players(data.players)
        }
    end

    local function get_empty_entry(player_name)
        return {
            primary_alias = "",
            id = {},
            alternative = {},
            added_date = "",
            source = "",
            group = "",
            note = ""
        }
    end

    local function find_entry_by_steam_id(steam_id)
        local target_id = trim(steam_id)
        if target_id == "" then
            return nil, nil
        end

        for alias_key, entry in pairs(kas.state.database.players or {}) do
            local normalized = normalize_entry(entry, alias_key)
            if contains_value(normalized.id, target_id) then
                return alias_key, normalized
            end
        end

        return nil, nil
    end

    local function find_entry_by_alias(alias_name)
        local target_alias = trim(alias_name)
        if target_alias == "" then
            return nil, nil
        end

        for alias_key, entry in pairs(kas.state.database.players or {}) do
            local normalized = normalize_entry(entry, alias_key)
            if normalized.primary_alias == target_alias or contains_value(normalized.alternative, target_alias) then
                return alias_key, normalized
            end
        end

        return nil, nil
    end

    local function get_connected_players()
        local items = {}
        local entries = {}
        local player_resource = entity.get_player_resource()
        local kas_color = get_kas_highlight_prefix()

        if not player_resource then
            return items, entries
        end

        for ent = 1, globals.maxplayers() do
            if entity.get_prop(player_resource, "m_bConnected", ent) == 1 then
                local name = entity.get_player_name(ent)
                if name and name ~= "unknown" then
                    local steam_id = entity.get_steam64(ent)
                    local label = steam_id and string.format("%s [%s]", name, tostring(steam_id)) or (name .. " [bot]")
                    if steam_id and find_entry_by_steam_id(tostring(steam_id)) then
                        label = kas_color .. label
                    end
                    entries[#entries + 1] = {
                        ent = ent,
                        steam_id = steam_id and tostring(steam_id) or nil,
                        name = name,
                        label = label
                    }
                end
            end
        end

        table.sort(entries, function(a, b)
            return a.label:lower() < b.label:lower()
        end)

        for i = 1, #entries do
            items[i] = entries[i].label
        end

        return items, entries
    end

    local function get_selected_player()
        local idx = tonumber(interface.kas.player_list:get())
        if not idx or idx < 0 then
            return nil
        end

        idx = idx + 1
        return kas.state.list_lookup[idx]
    end

    local function get_selected_options()
        local options = interface.kas.options:get() or {}
        if type(options) == "string" then
            return { options }
        end

        if type(options) ~= "table" then
            return {}
        end

        return options
    end

    local function set_selected_options(options)
        if type(options) ~= "table" or #options == 0 then
            interface.kas.options:set()
            return
        end

        interface.kas.options:set(options)
    end

    local function get_options_from_entry(entry)
        local normalized = normalize_entry(entry)
        local options = {}

        if normalized.primary_alias ~= "" then
            options[#options + 1] = "alias"
        end
        if #get_secondary_alternatives(normalized) > 0 then
            options[#options + 1] = "alternative"
        end
        if normalized.source ~= "" then
            options[#options + 1] = "source"
        end
        if normalized.group ~= "" then
            options[#options + 1] = "group"
        end
        if normalized.note ~= "" then
            options[#options + 1] = "note"
        end

        return options
    end

    local function set_form_from_entry(entry)
        local normalized = normalize_entry(entry)
        local source_value = normalized.source

        if not utils.contains(kas.source_presets, source_value) then
            source_value = "manual"
        end

        interface.kas.source:set(source_value)
        interface.kas.alias:set(normalized.primary_alias)
        interface.kas.alternative:set(table.concat(get_secondary_alternatives(normalized), ", "))
        interface.kas.group:set(normalized.group)
        interface.kas.note:set(normalized.note)
    end

    local function set_runtime(mode, selected_supported, has_record, entry)
        local runtime = interface.kas_runtime
        local normalized = normalize_entry(entry)

        runtime.mode = mode
        runtime.selected_supported = selected_supported == true
        runtime.has_record = has_record == true
        runtime.show_source = normalized.source ~= ""
        runtime.show_alias = normalized.primary_alias ~= ""
        runtime.show_alternative = #get_secondary_alternatives(normalized) > 0
        runtime.show_group = normalized.group ~= ""
        runtime.show_note = normalized.note ~= ""

        interface.kas.view_source:set(" · source: " .. (normalized.source ~= "" and normalized.source or "-"))
        interface.kas.view_alias:set(" · alias: " .. (normalized.primary_alias ~= "" and normalized.primary_alias or "-"))
        interface.kas.view_alternative:set(" · alternative: " .. (#get_secondary_alternatives(normalized) > 0 and table.concat(get_secondary_alternatives(normalized), ", ") or "-"))
        interface.kas.view_group:set(" · group: " .. (normalized.group ~= "" and normalized.group or "-"))
        interface.kas.view_note:set(" · note: " .. (normalized.note ~= "" and normalized.note or "-"))
    end

    local function update_editor_visibility()
        local runtime = interface.kas_runtime
        if runtime.mode ~= "add" and runtime.mode ~= "edit" then
            runtime.show_source = false
            runtime.show_alias = false
            runtime.show_alternative = false
            runtime.show_group = false
            runtime.show_note = false
            return
        end

        local options = get_selected_options()
        runtime.show_source = utils.contains(options, "source")
        runtime.show_alias = utils.contains(options, "alias")
        runtime.show_alternative = utils.contains(options, "alternative")
        runtime.show_group = utils.contains(options, "group")
        runtime.show_note = utils.contains(options, "note")
    end

    local function enter_idle_mode()
        local selected = get_selected_player()
        if not selected then
            kas.state.selected_steam_id = nil
            interface.kas.status:set(" · selected: none")
            interface.kas.database_status:set(" · in database: no")
            set_selected_options()
            set_form_from_entry(get_empty_entry())
            set_runtime("idle", false, false, get_empty_entry())
            return
        end

        kas.state.selected_steam_id = selected.steam_id
        interface.kas.status:set(" · selected: " .. selected.name)

        if not selected.steam_id then
            interface.kas.database_status:set(" · in database: bots are not supported")
            set_selected_options()
            set_form_from_entry(get_empty_entry(selected.name))
            set_runtime("idle", false, false, get_empty_entry())
            return
        end

        local alias_key, entry = find_entry_by_steam_id(selected.steam_id)
        if entry then
            interface.kas.database_status:set(" · in database: yes")
            set_selected_options()
            set_form_from_entry(normalize_entry(entry, alias_key))
            set_runtime("idle", true, true, entry)
            return
        end

        interface.kas.database_status:set(" · in database: no")
        set_selected_options()
        set_form_from_entry(get_empty_entry(selected.name))
        set_runtime("idle", true, false, get_empty_entry())
    end

    local function enter_add_mode()
        local selected = get_selected_player()
        if not selected or not selected.steam_id then
            return
        end

        set_selected_options()
        set_form_from_entry(get_empty_entry(selected.name))
        set_runtime("add", true, false, get_empty_entry())
        update_editor_visibility()
    end

    local function enter_edit_mode()
        local selected = get_selected_player()
        if not selected or not selected.steam_id then
            return
        end

        local alias_key, entry = find_entry_by_steam_id(selected.steam_id)
        if not entry then
            return
        end

        entry = normalize_entry(entry, alias_key)
        set_selected_options(get_options_from_entry(entry))
        set_form_from_entry(entry)
        set_runtime("edit", true, true, entry)
        update_editor_visibility()
    end

    local function update_player_list_ui()
        local previous_steam_id = kas.state.selected_steam_id
        local previous_mode = interface.kas_runtime.mode
        local items, entries = get_connected_players()
        local changed = false

        if #items == 0 then
            items = { "no players" }
            entries = {}
        end

        if #items ~= #kas.state.list_items then
            changed = true
        else
            for i = 1, #items do
                if items[i] ~= kas.state.list_items[i] then
                    changed = true
                    break
                end
            end
        end

        if not changed and previous_steam_id then
            for i = 1, #entries do
                if entries[i].steam_id == previous_steam_id then
                    kas.state.list_lookup = entries
                    if interface.kas_runtime.mode == "idle" then
                        enter_idle_mode()
                    end
                    return
                end
            end
            changed = true
        end

        if not changed and not previous_steam_id then
            kas.state.list_lookup = entries
            if interface.kas_runtime.mode == "idle" then
                enter_idle_mode()
            end
            return
        end

        kas.state.list_items = items
        kas.state.list_lookup = entries
        interface.kas.player_list:update(items)

        local selected_index = 0
        local selected_found = false
        if previous_steam_id then
            for i = 1, #entries do
                if entries[i].steam_id == previous_steam_id then
                    selected_index = i - 1
                    selected_found = true
                    break
                end
            end
        end

        pcall(function() interface.kas.player_list:set(selected_index) end)

        if previous_mode ~= "idle" and selected_found then
            return
        end

        enter_idle_mode()
    end

    local function build_entry_from_form(selected)
        local options = get_selected_options()
        local current_alias_key, current_entry = find_entry_by_steam_id(selected.steam_id)
        local normalized_current = normalize_entry(current_entry, current_alias_key)
        local next_entry = {
            primary_alias = normalized_current.primary_alias,
            id = copy_array(normalized_current.id),
            alternative = copy_array(normalized_current.alternative),
            added_date = normalized_current.added_date,
            source = normalized_current.source,
            group = normalized_current.group,
            note = normalized_current.note
        }

        if utils.contains(options, "alias") then
            next_entry.primary_alias = trim(interface.kas.alias:get())
        end
        if utils.contains(options, "alternative") then
            next_entry.alternative = parse_alternative_input(interface.kas.alternative:get())
        end
        if utils.contains(options, "source") then
            next_entry.source = tostring(interface.kas.source:get() or "manual")
        end
        if utils.contains(options, "group") then
            next_entry.group = tostring(interface.kas.group:get() or "")
        end
        if utils.contains(options, "note") then
            next_entry.note = tostring(interface.kas.note:get() or "")
        end

        if next_entry.primary_alias == "" then
            next_entry.primary_alias = trim(interface.kas.alias:get())
        end

        if next_entry.primary_alias ~= "" and not contains_value(next_entry.alternative, next_entry.primary_alias) then
            table.insert(next_entry.alternative, 1, next_entry.primary_alias)
        end

        local reordered = {}
        if next_entry.primary_alias ~= "" then
            reordered[1] = next_entry.primary_alias
        end
        for i = 1, #next_entry.alternative do
            local alt = trim(next_entry.alternative[i])
            if alt ~= "" and alt ~= next_entry.primary_alias and not contains_value(reordered, alt) then
                reordered[#reordered + 1] = alt
            end
        end
        next_entry.alternative = reordered

        if selected.steam_id and not contains_value(next_entry.id, selected.steam_id) then
            next_entry.id[#next_entry.id + 1] = tostring(selected.steam_id)
        end

        if next_entry.added_date == "" then
            next_entry.added_date = current_date_utc()
        end

        return normalize_entry(next_entry, next_entry.primary_alias)
    end

    local function apply_selected_player()
        local selected = get_selected_player()
        if not selected or not selected.steam_id then
            push_kas("select a real player first", 4)
            return
        end

        local options = get_selected_options()
        if #options == 0 then
            local action = interface.kas_runtime.mode == "edit" and "save" or "add"
            push_kas("select at least one option before " .. action, 4)
            return
        end

        local built_entry = build_entry_from_form(selected)
        local old_alias_key = find_entry_by_steam_id(selected.steam_id)
        local alias_match_key, alias_match_entry = find_entry_by_alias(built_entry.primary_alias)

        if alias_match_key and alias_match_key ~= old_alias_key then
            local merged = normalize_entry(alias_match_entry, alias_match_key)

            for i = 1, #built_entry.id do
                if not contains_value(merged.id, built_entry.id[i]) then
                    merged.id[#merged.id + 1] = built_entry.id[i]
                end
            end

            for i = 1, #built_entry.alternative do
                if not contains_value(merged.alternative, built_entry.alternative[i]) then
                    merged.alternative[#merged.alternative + 1] = built_entry.alternative[i]
                end
            end

            if utils.contains(options, "source") then
                merged.source = built_entry.source
            end
            if utils.contains(options, "group") then
                merged.group = built_entry.group
            end
            if utils.contains(options, "note") then
                merged.note = built_entry.note
            end

            merged.primary_alias = built_entry.primary_alias
            if merged.added_date == "" then
                merged.added_date = built_entry.added_date
            end

            built_entry = normalize_entry(merged, built_entry.primary_alias)
            kas.state.database.players[alias_match_key] = nil
        end

        local storage_key = resolve_storage_key(built_entry, selected.steam_id, old_alias_key)
        if old_alias_key and old_alias_key ~= storage_key then
            kas.state.database.players[old_alias_key] = nil
        end

        kas.state.database.players[storage_key] = built_entry

        local ok, err = save_database()
        if not ok then
            push_kas(err, 4)
            return
        end

        enter_idle_mode()
        push_kas("saved " .. selected.name .. " to kas.json", 3)
    end

    local function remove_selected_player()
        local selected = get_selected_player()
        if not selected or not selected.steam_id then
            push_kas("select a real player first", 4)
            return
        end

        local alias_key = find_entry_by_steam_id(selected.steam_id)
        if not alias_key then
            push_kas("selected player is not in kas.json", 4)
            return
        end

        kas.state.database.players[alias_key] = nil

        local ok, err = save_database()
        if not ok then
            push_kas(err, 4)
            return
        end

        enter_idle_mode()
        push_kas("removed " .. selected.name .. " from kas.json", 3)
    end

    local function update_runtime_after_option_change()
        update_editor_visibility()
    end

    local function reset_notification_cache()
        kas.state.notified_players = {}
    end

    local function notify_known_players()
        if not interface.kas.enabled:get() then
            reset_notification_cache()
            return
        end

        local player_resource = entity.get_player_resource()
        if not player_resource then
            return
        end

        for ent = 1, globals.maxplayers() do
            if entity.get_prop(player_resource, "m_bConnected", ent) == 1 then
                local steam_id = entity.get_steam64(ent)
                if steam_id then
                    steam_id = tostring(steam_id)
                    if not kas.state.notified_players[steam_id] then
                        local _, entry = find_entry_by_steam_id(steam_id)
                        if entry then
                            local message, console_format, console_args = build_log_message(entity.get_player_name(ent), entry)
                            if message then
                                kas.state.notified_players[steam_id] = true
                                push_kas(message, 8, console_format, console_args)
                            end
                        end
                    end
                end
            end
        end
    end

    kas.on_paint = function(self)
        local current_time = globals.realtime()
        if current_time - kas.state.last_notify_refresh >= 1 then
            kas.state.last_notify_refresh = current_time
            notify_known_players()
        end

        if interface.search:get() ~= "players" and interface.search:get() ~= "kas" then
            return
        end

        if current_time - kas.state.last_refresh < 1 then
            return
        end

        kas.state.last_refresh = current_time
        update_player_list_ui()
    end

    kas.setup = function(self)
        load_database()
        set_runtime("idle", false, false, get_empty_entry())
        set_selected_options()
        set_form_from_entry(get_empty_entry())
        update_player_list_ui()

        interface.kas.player_list:set_callback(function()
            enter_idle_mode()
        end)
        interface.kas.add_button:set_callback(function()
            enter_add_mode()
        end)
        interface.kas.edit_button:set_callback(function()
            enter_edit_mode()
        end)
        interface.kas.remove_button:set_callback(function()
            remove_selected_player()
        end)
        interface.kas.options:set_callback(function()
            update_runtime_after_option_change()
        end)
        interface.kas.add_submit:set_callback(function()
            apply_selected_player()
        end)
        interface.kas.save_submit:set_callback(function()
            apply_selected_player()
        end)

        client.set_event_callback("paint", function()
            kas:on_paint()
        end)
    end

    kas:setup()
end
--@endregion

--@region: stats (home)
stats = {} do
    local DB_KEY = 'noctua.stats'
    local state = { personal = { kills = 0, deaths = 0 }, script = { hits = 0, misses = 0, evaded = 0 } }

    local function is_local_server()
        local lat = client.real_latency()
        return not lat or lat <= 0.001
    end

    local function is_bot(idx)
        local info = utils.get_player_info and utils.get_player_info(idx)
        return info and info.__fakeplayer == true
    end

    function stats.load_db()
        local ok, data = pcall(database.read, DB_KEY)
        if ok and type(data) == 'table' then
            if type(data.personal) == 'table' then
                state.personal.kills = tonumber(data.personal.kills) or 0
                state.personal.deaths = tonumber(data.personal.deaths) or 0
            end
            if type(data.script) == 'table' then
                state.script.hits = tonumber(data.script.hits) or 0
                state.script.misses = tonumber(data.script.misses) or 0
                state.script.evaded = tonumber(data.script.evaded) or 0
            end
        end
    end

    function stats.save_db()
        pcall(database.write, DB_KEY, state)
    end

    local function fmt_ratio(a, b)
        a = tonumber(a) or 0
        b = tonumber(b) or 0
        if b == 0 then
            return (a > 0) and 'inf' or '0'
        end
        return string.format('%.2f', a / b)
    end

    function stats.update_ui()
        interface.home.kills:set(' · kills: ' .. tostring(state.personal.kills))
        interface.home.deaths:set(' · deaths: ' .. tostring(state.personal.deaths))
        interface.home.kd:set(' · kd ratio: ' .. fmt_ratio(state.personal.kills, state.personal.deaths))
        interface.home.hits:set(' · hits: ' .. tostring(state.script.hits))
        interface.home.misses:set(' · misses: ' .. tostring(state.script.misses))
        interface.home.evaded:set(' · evaded shots: ' .. tostring(state.script.evaded))
        interface.home.ratio:set(' · ratio: ' .. fmt_ratio(state.script.hits, state.script.misses))
    end

    function stats.reset()
        state.personal.kills = 0
        state.personal.deaths = 0
        state.script.hits = 0
        state.script.misses = 0
        state.script.evaded = 0
        stats.save_db()
        stats.update_ui()
    end

    client.set_event_callback('player_death', function(e)
        local me = entity.get_local_player()
        if not me then return end
        if is_local_server() then return end
        local attacker = client.userid_to_entindex(e.attacker)
        local victim = client.userid_to_entindex(e.userid)
        if attacker == me and victim ~= me then
            if is_bot(victim) then return end
            state.personal.kills = (state.personal.kills or 0) + 1
            stats.update_ui()
        elseif victim == me then
            state.personal.deaths = (state.personal.deaths or 0) + 1
            stats.update_ui()
        end
    end)

    client.set_event_callback('aim_hit', function(e)
        if not e or not e.target then return end
        if is_local_server() then return end
        if is_bot(e.target) then return end
        state.script.hits = (state.script.hits or 0) + 1
        stats.update_ui()
    end)

    client.set_event_callback('aim_miss', function(e)
        if not e or not e.target then return end
        if is_local_server() then return end
        if is_bot(e.target) then return end
        state.script.misses = (state.script.misses or 0) + 1
        stats.update_ui()
    end)

    function stats.on_evaded(attacker_name, value, mode)
        state.script.evaded = (state.script.evaded or 0) + 1
        stats.save_db()
        stats.update_ui()
    end

    function stats.init()
        stats.load_db()
        stats.update_ui()
        interface.home.reset:set_callback(stats.reset)
    end
end

stats.init()
client.set_event_callback('shutdown', function() pcall(function() stats.save_db() end) end)
--@endregion

--@region: clantag
clantag = {} do
    clantag.enabled = false
    clantag.last_update = 0
    clantag.current_index = 1
    clantag.animation = {
        "      ✧",
        "     ✦✧",
        "    ✦✧✧",
        "n  ✦✧✧✧",
        "no  ✦✧✧",
        "noc  ✦✧",
        "noct  ✦",
        "noctu  ✧",
        "noctua ✦",
        "noctua ✧",
        "noctua ✦ ",
        "octua ✧ s",
        "ctua ✦ si",
        "tua ✧ sid",
        "ua ✦ side",
        "a ✧ side ",
        " ✦ side b",
        "✧ side by",
        "✦ ide by ",
        "✧ de by s",
        "✦ e by si",
        "✧  by sid",
        "✦ by side",
        "✧ by side",
        "✦ by sid",
        "✧ by si",
        "✦ by s",
        "✧ by ",
        "✦ by",
        "✧ b",
        "✦ ",
        "✧",
        "✦"
    }
    
    clantag.setup = function()
        if not interface.utility.clantag:get() then 
            if clantag.enabled then
                client.set_clan_tag("")
                clantag.enabled = false
                client.unset_event_callback('net_update_end', clantag.update)
            end
            return 
        end
        
        if not clantag.enabled then
            clantag.enabled = true
            client.set_event_callback('net_update_end', clantag.update)
        end
    end

    clantag.update = function()
        if not entity.get_local_player() then return end
        
        local latency = client.real_latency() / globals.tickinterval()
        local tickcount = globals.tickcount() + latency
        
        local index = math.floor(math.fmod(tickcount / 22, #clantag.animation) + 1)
        
        if index ~= clantag.current_index then
            clantag.current_index = index
            client.set_clan_tag(clantag.animation[index])
        end
    end

    clantag.reset = function()
        client.set_clan_tag("")
    end

    client.set_event_callback('paint', clantag.setup)
    client.set_event_callback('shutdown', clantag.reset)
end
--@endregion

--@region: killsay
killsay = {} do
    killsay.last_say_time = 0
    killsay.cooldown = 2.0
    killsay.last_phrase_index = {
        kill = nil,
        death = nil
    }

    killsay.kill_json_url = "https://raw.githubusercontent.com/wraithsoul/noctua-gs/refs/heads/main/phrases/kill.json"
    killsay.death_json_url = "https://raw.githubusercontent.com/wraithsoul/noctua-gs/refs/heads/main/phrases/death.json"
    killsay.kill_json_path = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Counter-Strike Global Offensive\\phrases\\kill.json"
    killsay.death_json_path = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Counter-Strike Global Offensive\\phrases\\death.json"
    killsay.multi_phrases_kill = {}
    killsay.multi_phrases_death = {}

    local function killsay_log(fmt, ...)
        argLogWithPrefix("noctua · killsay", fmt, ...)
    end

    local function select_phrase_index(phrase_type, phrase_count)
        local last_index = killsay.last_phrase_index[phrase_type]

        if phrase_count <= 1 then
            return 1
        end

        if not last_index or last_index < 1 or last_index > phrase_count then
            return client.random_int(1, phrase_count)
        end

        local index = client.random_int(1, phrase_count - 1)
        if index >= last_index then
            index = index + 1
        end

        return index
    end

    killsay.apply_phrases = function(decoded, target_table, phrase_type, source_name)
        if type(decoded) ~= "table" then
            killsay_log("invalid %s phrases payload from %s", phrase_type, source_name)
            return false
        end

        for i = #target_table, 1, -1 do
            target_table[i] = nil
        end

        for i, phrase_set in ipairs(decoded) do
            target_table[i] = {}
            for j, line in ipairs(phrase_set) do
                target_table[i][j] = tostring(line)
            end
        end

        killsay_log("loaded %d %s phrase sets from %s", #target_table, phrase_type, source_name)
        return true
    end

    killsay.load_phrases_from_file = function(path, target_table, phrase_type)
        if not path or path == "" then
            killsay_log("no file path set for %s phrases", phrase_type)
            return false
        end

        local body = readfile(path)
        if not body then
            killsay_log("failed to read %s phrases file %s", phrase_type, path)
            return false
        end

        local ok, decoded = pcall(json.decode, body)
        if ok and killsay.apply_phrases(decoded, target_table, phrase_type, "file") then
            return true
        end

        killsay_log("failed to parse JSON for %s phrases file", phrase_type)
        return false
    end

    killsay.load_phrases_from_url = function(url, fallback_path, target_table, phrase_type)
        if not url or url == "" then
            killsay_log("no URL set for %s phrases, using local file", phrase_type)
            killsay.load_phrases_from_file(fallback_path, target_table, phrase_type)
            return
        end

        http.get(url, function(success, response)
            if success and response and response.status == 200 then
                local ok, decoded = pcall(json.decode, response.body)
                if ok and killsay.apply_phrases(decoded, target_table, phrase_type, "url") then
                    return
                end

                killsay_log("failed to parse JSON for %s phrases from URL, using local file", phrase_type)
            else
                local status = (response and response.status) or 'no response'
                killsay_log("failed to load %s phrases from URL (%s), using local file", phrase_type, status)
            end

            killsay.load_phrases_from_file(fallback_path, target_table, phrase_type)
        end)
    end

    killsay.load_all_phrases = function()
        killsay.load_phrases_from_url(killsay.kill_json_url, killsay.kill_json_path, killsay.multi_phrases_kill, "kill")
        killsay.load_phrases_from_url(killsay.death_json_url, killsay.death_json_path, killsay.multi_phrases_death, "death")
    end

    killsay.get_random_phrase = function(phrase_type)
        local phrases_table = phrase_type == "death" and killsay.multi_phrases_death or killsay.multi_phrases_kill
        if #phrases_table == 0 then return { "Error: No phrases loaded" } end

        local index = select_phrase_index(phrase_type, #phrases_table)
        killsay.last_phrase_index[phrase_type] = index

        return phrases_table[index]
    end
    
    killsay.calculate_delay = function(text)
        local text_length = string.len(text)
        local reaction_delay = client.random_float(0.28, 0.55)
        local reading_delay = math.sqrt(text_length) * client.random_float(0.075, 0.120)
        local typing_delay = text_length * client.random_float(0.020, 0.035)
        return reaction_delay + reading_delay + typing_delay
    end
    
    killsay.send_phrases = function(phrase_type)
        local initial_delay = client.random_float(0.95, 1.45)
        
        if phrase_type == "death" then
            initial_delay = initial_delay + client.random_float(0.55, 0.95)
        end
        
        local phrases = killsay.get_random_phrase(phrase_type)
        local phrase_count = #phrases
        
        local cumulative_delay = initial_delay
        for i = 1, phrase_count do
            local phrase_delay = killsay.calculate_delay(phrases[i])
            local min_between_delay = client.random_float(0.75, 1.20)
            
            if string.len(phrases[i]) < 10 then
                min_between_delay = client.random_float(0.90, 1.35)
            end
            
            if phrase_type == "death" then
                min_between_delay = min_between_delay + client.random_float(0.30, 0.60)
            end
            
            if i > 1 then
                cumulative_delay = cumulative_delay + min_between_delay
            end
            
            cumulative_delay = cumulative_delay + phrase_delay
            
            client.delay_call(cumulative_delay, function()
                client.exec("say " .. phrases[i])
            end)
        end
    end
    
    killsay.on_player_death = function(e)
        if not interface.utility.killsay:get() then return end

        local local_player = entity.get_local_player()
        if not local_player or not entity.is_alive(local_player) and e.userid ~= local_player then return end

        local attacker = client.userid_to_entindex(e.attacker)
        local victim = client.userid_to_entindex(e.userid)
        
        if not attacker or not victim then return end

        local modes = interface.utility.killsay_modes:get()
        local now = globals.realtime()

        if now - killsay.last_say_time < killsay.cooldown then
            return
        end
        
        if attacker == local_player and victim ~= local_player then
            if utils.contains(modes, "on kill") then
                local kd = player.get_kd(local_player)
                -- if kd ~= nil and kd <= 1.0 then return end
                
                killsay.last_say_time = now 
                killsay.send_phrases("kill")
            end
        elseif victim == local_player and attacker ~= local_player then
            if utils.contains(modes, "on death") then
                killsay.last_say_time = now
                killsay.send_phrases("death")
            end
        end
    end
    
    client.set_event_callback("player_death", killsay.on_player_death)
    killsay.load_all_phrases()
end
--@endregion

--@region: party mode
party_mode = {} do
    party_mode.on_player_death = function(e)
        if not interface.utility.party_mode:get() then return end
        
        local local_player = entity.get_local_player()
        if not local_player then return end
        
        local attacker = client.userid_to_entindex(e.attacker)
        local victim = client.userid_to_entindex(e.userid)
        
        if attacker == local_player and victim ~= local_player then
            confetti:push(0, false)
        end
    end
    
    party_mode.setup = function()
        if interface.utility.party_mode:get() then
            client.set_event_callback("player_death", party_mode.on_player_death)
        else
            client.unset_event_callback("player_death", party_mode.on_player_death)
        end
    end
    
client.set_event_callback("paint", party_mode.setup)
end
--@endregion

--@region: reveal enemy team chat
reveal_enemy_team_chat = {} do
    local ref = interface.utility.reveal_enemy_team_chat
    local game_state_api = panorama.open().GameStateAPI
    local cl_mute_enemy_team = cvar.cl_mute_enemy_team
    local cl_mute_all_but_friends_and_party = cvar.cl_mute_all_but_friends_and_party

    reveal_enemy_team_chat.chat_data = {}

    reveal_enemy_team_chat.on_player_say = function(e)
        local entindex = client.userid_to_entindex(e.userid)
        if not entity.is_enemy(entindex) then
            return
        end

        local xuid = game_state_api.GetPlayerXuidStringFromEntIndex(entindex)

        if game_state_api.IsSelectedPlayerMuted(xuid) then
            return
        end

        if cl_mute_enemy_team:get_int() == 1 then
            return
        end

        if cl_mute_all_but_friends_and_party:get_int() == 1 then
            return
        end

        client.delay_call(0.2, function()
            if reveal_enemy_team_chat.chat_data[entindex] ~= nil and math.abs(globals.realtime() - reveal_enemy_team_chat.chat_data[entindex]) < 0.4 then
                return
            end

            local player_resource = entity.get_player_resource()
            local last_place_name = entity.get_prop(entindex, 'm_szLastPlaceName')
            local player_name = entity.get_player_name(entindex)

            local team_literal = entity.get_prop(player_resource, 'm_iTeam', entindex) == 2 and 'T' or 'CT'
            local state_literal = entity.is_alive(entindex) and 'Loc' or 'Dead'
            local text = string.format('Cstrike_Chat_%s_%s', team_literal, state_literal)

            local localized_text = localize(text, {
                s1 = player_name,
                s2 = e.text,
                s3 = localize(last_place_name ~= "" and last_place_name or 'UI_Unknown')
            })

            chat.print_player(entindex, localized_text)
        end)
    end

    reveal_enemy_team_chat.on_player_chat = function(e)
        if not e.entity or not entity.is_enemy(e.entity) then
            return
        end

        reveal_enemy_team_chat.chat_data[e.entity] = globals.realtime()
    end

    reveal_enemy_team_chat.setup = function()
        if ref:get() then
            client.set_event_callback('player_say', reveal_enemy_team_chat.on_player_say)
            client.set_event_callback('player_chat', reveal_enemy_team_chat.on_player_chat)
            return
        end

        reveal_enemy_team_chat.chat_data = {}
        client.unset_event_callback('player_say', reveal_enemy_team_chat.on_player_say)
        client.unset_event_callback('player_chat', reveal_enemy_team_chat.on_player_chat)
    end

    ref:set_callback(reveal_enemy_team_chat.setup)
    reveal_enemy_team_chat.setup()
end
--@endregion

--@region: animation breakers
local animation_breakers = {} do
    local leg_ref = reference.antiaim.other.leg_movement

    function animation_breakers.is_enabled(option)
        return utils.multiselect_has(interface.utility.animation_breakers:get(), option)
    end

    function animation_breakers.is_active()
        local value = interface.utility.animation_breakers:get()

        if type(value) == 'string' then
            return value ~= ''
        end

        return type(value) == 'table' and #value > 0
    end

    function animation_breakers.reset()
        leg_ref:override()
    end

    function animation_breakers.apply_leg_override(mode)
        if mode == nil then
            leg_ref:override()
            return
        end

        leg_ref:override(mode)
    end

    function animation_breakers.run()
        local local_player = entity.get_local_player()
        if not local_player or not entity.is_alive(local_player) or not animation_breakers.is_active() then
            animation_breakers.reset()
            return
        end

        local animstate = player.get_animstate(local_player)
        local animlayers = player.get_animlayer(local_player)
        if animstate == nil or animlayers == nil then
            animation_breakers.reset()
            return
        end

        local flags = entity.get_prop(local_player, 'm_fFlags') or 0
        local move_type = entity.get_prop(local_player, 'm_MoveType') or 0
        local duck_amount = entity.get_prop(local_player, 'm_flDuckAmount') or 0
        local _, _, _, speed = player.get_velocity(local_player)
        local on_ground = bit.band(flags, 1) == 1
        local leg_override = nil

        if animation_breakers.is_enabled('on ground') and on_ground then
            local ground_mode = interface.utility.on_ground_options:get()

            if ground_mode == 'frozen' then
                entity.set_prop(local_player, 'm_flPoseParameter', 1, 0)
                leg_override = 'Always slide'
            elseif ground_mode == 'walking' then
                entity.set_prop(local_player, 'm_flPoseParameter', 0.5, 7)
                leg_override = 'Never slide'
            elseif ground_mode == 'jitter' and speed > 5 then
                entity.set_prop(local_player, 'm_flPoseParameter', client.random_float(0.65, 1), 0)
                leg_override = 'Always slide'
            elseif ground_mode == 'sliding' and speed > 5 then
                entity.set_prop(local_player, 'm_flPoseParameter', 0, 9)
                entity.set_prop(local_player, 'm_flPoseParameter', 0, 10)
                leg_override = 'Never slide'
            elseif ground_mode == 'star' then
                leg_override = globals.tickcount() % 3 == 0 and 'Off' or 'Always slide'
            end
        end

        if animation_breakers.is_enabled('on air') and not on_ground and move_type ~= 8 and move_type ~= 9 then
            local air_mode = interface.utility.on_air_options:get()

            if air_mode == 'frozen' then
                entity.set_prop(local_player, 'm_flPoseParameter', 1, 6)
            elseif air_mode == 'walking' then
                local cycle = globals.realtime() * 0.7 % 2
                if cycle > 1 then
                    cycle = 1 - (cycle - 1)
                end

                animlayers[6].m_weight = 1
                animlayers[6].m_cycle = cycle
            elseif air_mode == 'kinguru' then
                entity.set_prop(local_player, 'm_flPoseParameter', math.random(0, 10) / 10, 6)
            end
        end

        if animation_breakers.is_enabled('sliding slow motion') and ui.get(ui_references.slow_motion[1]) and ui.get(ui_references.slow_motion[2]) then
            entity.set_prop(local_player, 'm_flPoseParameter', 0, 9)
        end

        if animation_breakers.is_enabled('sliding crouch') and duck_amount == 1 then
            entity.set_prop(local_player, 'm_flPoseParameter', 0, 8)
        end

        if animation_breakers.is_enabled('zero on land') and animstate.bHitGroundAnimation and on_ground then
            entity.set_prop(local_player, 'm_flPoseParameter', 0.5, 12)
        end

        if animation_breakers.is_enabled('earthquake') then
            animlayers[12].m_weight = client.random_float(-0.3, 0.75)
        end

        if animation_breakers.is_enabled('body lean') then
            animstate.flLeanAmount = interface.utility.body_lean_amount:get() / 100
        end

        animation_breakers.apply_leg_override(leg_override)
    end

    function animation_breakers.on_setup_command(cmd)
        local local_player = entity.get_local_player()
        if not local_player or not entity.is_alive(local_player) or not animation_breakers.is_active() then
            return
        end

        if animation_breakers.is_enabled('quick peek legs') and ui.get(ui_references.quickpeek[1]) and ui.get(ui_references.quickpeek[2]) then
            local move_type = entity.get_prop(local_player, 'm_MoveType') or 0
            if move_type == 2 then
                cmd.buttons = bit.band(cmd.buttons, bit.bnot(8))
                cmd.buttons = bit.band(cmd.buttons, bit.bnot(16))
                cmd.buttons = bit.band(cmd.buttons, bit.bnot(512))
                cmd.buttons = bit.band(cmd.buttons, bit.bnot(1024))
            end
        end

        if animation_breakers.is_enabled('on ground') and interface.utility.on_ground_options:get() == 'star' then
            local flags = entity.get_prop(local_player, 'm_fFlags') or 0
            if bit.band(flags, 1) == 1 then
                animation_breakers.apply_leg_override(cmd.command_number % 3 == 0 and 'Off' or 'Always slide')
            end
        end
    end

    client.set_event_callback('pre_render', animation_breakers.run)
    client.set_event_callback('setup_command', animation_breakers.on_setup_command)
    client.set_event_callback('shutdown', animation_breakers.reset)
end
--@endregion

--@region: streamer mode
streamer_mode = {} do
    local DB_KEY = 'noctua.streamer_mode_images'
    local MIN_SIZE = 50
    local MAX_SIZE = 1200
    local DEFAULT_SIZE = 200
    local HANDLE_SIZE = 12
    local CLOSE_SIZE = 16
    local SNAP = 12

    streamer_mode.active_images = {}
    streamer_mode.image_cache = {}
    streamer_mode.loading = {}
    streamer_mode.next_id = 1
    
    streamer_mode.drag_id = nil
    streamer_mode.drag_offset_x = 0
    streamer_mode.drag_offset_y = 0
    streamer_mode.resize_id = nil
    streamer_mode.resize_start_w = 0
    streamer_mode.resize_start_h = 0
    streamer_mode.resize_start_mx = 0
    streamer_mode.resize_start_my = 0
    streamer_mode.resize_keep_ratio = false
    streamer_mode.was_m1_down = false
    streamer_mode.is_interacting = false

    local function clamp(v, mn, mx)
        if v < mn then return mn end
        if v > mx then return mx end
        return v
    end

    local function point_in_rect(px, py, rx, ry, rw, rh)
        return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
    end

    local function get_menu_rect()
        local mx, my = ui.menu_position()
        local mw, mh = 0, 0
        if ui.menu_size then
            mw, mh = ui.menu_size()
        end
        return mx or 0, my or 0, mw or 0, mh or 0
    end

    function streamer_mode.load_db()
        local ok, data = pcall(database.read, DB_KEY)
        if ok and type(data) == "table" then
            streamer_mode.active_images = data.images or {}
            streamer_mode.next_id = data.next_id or 1
            
            local valid_images = {}
            for _, img in ipairs(streamer_mode.active_images) do
                local url = streamer_images and streamer_images.get_url and streamer_images.get_url(img.name)
                if url and url ~= "" then
                    table.insert(valid_images, img)
                    streamer_mode.load_image_data(img.name)
                end
            end
            streamer_mode.active_images = valid_images
            streamer_mode.save_db()
        end
    end

    function streamer_mode.save_db()
        local data = {
            images = streamer_mode.active_images,
            next_id = streamer_mode.next_id
        }
        pcall(database.write, DB_KEY, data)
    end

    function streamer_mode.load_image_data(name)
        if streamer_mode.image_cache[name] or streamer_mode.loading[name] then
            return
        end

        local url = streamer_images and streamer_images.get_url and streamer_images.get_url(name)
        if not url or url == "" then return end

        streamer_mode.loading[name] = true

        http.get(url, function(success, response)
            if success and response and response.status == 200 then
                streamer_mode.image_cache[name] = images.load(response.body)
            end
            streamer_mode.loading[name] = false
        end)
    end

    function streamer_mode.add_image(name)
        if not name or name == "" then return end

        local sw, sh = client.screen_size()
        local id = streamer_mode.next_id
        streamer_mode.next_id = streamer_mode.next_id + 1

        local img = {
            id = id,
            name = name,
            x = math.floor(sw / 2 - DEFAULT_SIZE / 2),
            y = math.floor(sh / 2 - DEFAULT_SIZE / 2),
            w = DEFAULT_SIZE,
            h = DEFAULT_SIZE
        }

        table.insert(streamer_mode.active_images, img)
        streamer_mode.load_image_data(name)
        streamer_mode.save_db()

        client.exec("play ui/beepclear.wav")
    end

    function streamer_mode.remove_image(id)
        for i, img in ipairs(streamer_mode.active_images) do
            if img.id == id then
                table.remove(streamer_mode.active_images, i)
                streamer_mode.save_db()
                client.exec("play ui/beepclear.wav")
                return
            end
        end
    end

    function streamer_mode.bring_to_front(id)
        for i, img in ipairs(streamer_mode.active_images) do
            if img.id == id then
                table.remove(streamer_mode.active_images, i)
                table.insert(streamer_mode.active_images, img)
                return
            end
        end
    end

    function streamer_mode.draw_controls(img)
        renderer.rectangle(img.x - 1, img.y - 1, img.w + 2, 1, 255, 255, 255, 100)
        renderer.rectangle(img.x - 1, img.y + img.h, img.w + 2, 1, 255, 255, 255, 100)
        renderer.rectangle(img.x - 1, img.y, 1, img.h, 255, 255, 255, 100)
        renderer.rectangle(img.x + img.w, img.y, 1, img.h, 255, 255, 255, 100)

        local hx = img.x + img.w - HANDLE_SIZE
        local hy = img.y + img.h - HANDLE_SIZE
        renderer.rectangle(hx, hy, HANDLE_SIZE, HANDLE_SIZE, 40, 40, 40, 200)
        
        for i = 0, 2 do
            local lx = hx + 3 + i * 3
            local ly = hy + HANDLE_SIZE - 4 - i * 3
            local len = 1 + i * 3
            renderer.rectangle(lx, ly, len, 1, 255, 255, 255, 180)
        end

        local cx = img.x + img.w - CLOSE_SIZE
        local cy = img.y
        renderer.rectangle(cx, cy, CLOSE_SIZE, CLOSE_SIZE, 180, 60, 60, 220)
        
        local xc = cx + CLOSE_SIZE / 2
        local yc = cy + CLOSE_SIZE / 2
        renderer.line(xc - 3, yc - 3, xc + 3, yc + 3, 255, 255, 255, 255)
        renderer.line(xc - 3, yc + 3, xc + 3, yc - 3, 255, 255, 255, 255)
    end

    function streamer_mode.handle_input()
        if not ui.is_menu_open() then
            streamer_mode.drag_id = nil
            streamer_mode.resize_id = nil
            streamer_mode.is_interacting = false
            return
        end

        local mx, my = ui.mouse_position()
        local m1 = client.key_state(0x01)
        local shift = client.key_state(0x10)
        local menu_x, menu_y, menu_w, menu_h = get_menu_rect()
        local in_menu = point_in_rect(mx, my, menu_x, menu_y, menu_w, menu_h)

        if m1 and not streamer_mode.was_m1_down and not in_menu then
            for i = #streamer_mode.active_images, 1, -1 do
                local img = streamer_mode.active_images[i]
                
                local cx, cy = img.x + img.w - CLOSE_SIZE, img.y
                if point_in_rect(mx, my, cx, cy, CLOSE_SIZE, CLOSE_SIZE) then
                    streamer_mode.remove_image(img.id)
                    streamer_mode.was_m1_down = true
                    streamer_mode.is_interacting = true
                    return
                end

                local hx, hy = img.x + img.w - HANDLE_SIZE, img.y + img.h - HANDLE_SIZE
                if point_in_rect(mx, my, hx - 8, hy - 8, HANDLE_SIZE + 16, HANDLE_SIZE + 16) then
                    streamer_mode.resize_id = img.id
                    streamer_mode.resize_start_w = img.w
                    streamer_mode.resize_start_h = img.h
                    streamer_mode.resize_start_mx = mx
                    streamer_mode.resize_start_my = my
                    streamer_mode.resize_keep_ratio = shift
                    streamer_mode.bring_to_front(img.id)
                    streamer_mode.was_m1_down = true
                    streamer_mode.is_interacting = true
                    return
                end

                if point_in_rect(mx, my, img.x, img.y, img.w, img.h) then
                    streamer_mode.drag_id = img.id
                    streamer_mode.drag_offset_x = img.x - mx
                    streamer_mode.drag_offset_y = img.y - my
                    streamer_mode.bring_to_front(img.id)
                    streamer_mode.was_m1_down = true
                    streamer_mode.is_interacting = true
                    return
                end
            end
        end

        if m1 and streamer_mode.drag_id then
            streamer_mode.is_interacting = true
            local sw, sh = client.screen_size()
            for _, img in ipairs(streamer_mode.active_images) do
                if img.id == streamer_mode.drag_id then
                    local new_x = mx + streamer_mode.drag_offset_x
                    local new_y = my + streamer_mode.drag_offset_y

                    local cx = new_x + img.w / 2
                    local cy = new_y + img.h / 2
                    if math.abs(cx - sw / 2) <= SNAP then new_x = sw / 2 - img.w / 2 end
                    if math.abs(cy - sh / 2) <= SNAP then new_y = sh / 2 - img.h / 2 end

                    img.x = clamp(new_x, 0, sw - img.w)
                    img.y = clamp(new_y, 0, sh - img.h)
                    break
                end
            end
        end

        if m1 and streamer_mode.resize_id then
            streamer_mode.is_interacting = true
            for _, img in ipairs(streamer_mode.active_images) do
                if img.id == streamer_mode.resize_id then
                    local dx = mx - streamer_mode.resize_start_mx
                    local dy = my - streamer_mode.resize_start_my
                    
                    local new_w = streamer_mode.resize_start_w + dx
                    local new_h = streamer_mode.resize_start_h + dy

                    if shift or streamer_mode.resize_keep_ratio then
                        local delta = math.max(dx, dy)
                        new_w = streamer_mode.resize_start_w + delta
                        new_h = streamer_mode.resize_start_h + delta
                    end

                    img.w = clamp(new_w, MIN_SIZE, MAX_SIZE)
                    img.h = clamp(new_h, MIN_SIZE, MAX_SIZE)
                    break
                end
            end
        end

        if not m1 then
            if streamer_mode.drag_id or streamer_mode.resize_id then
                streamer_mode.save_db()
            end
            streamer_mode.drag_id = nil
            streamer_mode.resize_id = nil
            streamer_mode.is_interacting = false
        end

        streamer_mode.was_m1_down = m1
    end

    function streamer_mode.on_paint()
        if not interface.utility.streamer_mode:get() then return end

        streamer_mode.handle_input()

        for _, img in ipairs(streamer_mode.active_images) do
            local image_data = streamer_mode.image_cache[img.name]
            
            if image_data then
                image_data:draw(img.x, img.y, img.w, img.h, 255, 255, 255, 255)
            elseif not streamer_mode.loading[img.name] then
                streamer_mode.load_image_data(img.name)
            end

            if ui.is_menu_open() then
                streamer_mode.draw_controls(img)
            end
        end
    end

    function streamer_mode.setup_command(cmd)
        if streamer_mode.is_interacting then
            cmd.in_attack = 0
            cmd.in_attack2 = 0
        end
    end

    function streamer_mode.init()
        streamer_mode.load_db()
        client.set_event_callback("paint", streamer_mode.on_paint)
        client.set_event_callback("setup_command", streamer_mode.setup_command)
    end

    streamer_mode.init()
end

streamer_images.init()
streamer_mode.init()
--@endregion

client.set_event_callback('console_input', function(str)
    if type(str) ~= 'string' then return end
    local line = str:gsub('^%s+', ''):gsub('%s+$', '')
    if line:sub(1,4) ~= '.add' then return end

    local name, url = line:match('^%.add%s+(%S+)%s+(.+)$')
    if not name or not url then
        logMessage('noctua · streamer', '', 'usage: .add <name> <url>')
        return true
    end

    if streamer_images and streamer_images.add then
        streamer_images.add(name, url)
    end

    return true
end)

--@region: on shutdown
shutdown_handler = {} do
    local controller = {
        was_enabled = false
    }

    local function reset_player_plist(idx)
        if not idx or not entity.is_enemy(idx) then return end
        plist.set(idx, 'Add to whitelist', false)
        plist.set(idx, 'Allow shared ESP updates', false)
        plist.set(idx, 'Disable visuals', false)
        plist.set(idx, 'High priority', false)
        plist.set(idx, 'Force body yaw', false)
        plist.set(idx, 'Force body yaw value', 0)
        plist.set(idx, 'Force pitch', false)
        plist.set(idx, 'Force pitch value', 0)
        plist.set(idx, 'Correction active', false)
        plist.set(idx, 'Override safe point', "-")
        plist.set(idx, 'Override prefer body aim', "-")
    end

    shutdown_handler.reset_all_players = function()
        local enemies = entity.get_players(true)
        if not enemies then return end
        for _, idx in ipairs(enemies) do
            if idx and entity.is_alive(idx) then
                reset_player_plist(idx)
            end
        end
    end

    shutdown_handler.restore_hitsound = function()
        local hitsound_original = ui.reference("Visuals", "Player ESP", "Hit marker sound")
        ui.set_enabled(hitsound_original, true)
        if hitsound.hitsound_original_state ~= nil then
            ui.set(hitsound_original, hitsound.hitsound_original_state)
        end
    end

    shutdown_handler.setup = function()
        client.set_event_callback('paint', function()
            local enabled = (interface.aimbot.enabled_aimbot:get() and interface.aimbot.enabled_resolver_tweaks:get())
            if controller.was_enabled and not enabled then
                shutdown_handler.reset_all_players()
            end
            controller.was_enabled = enabled
        end)

        client.set_event_callback('shutdown', function()
            shutdown_handler.reset_all_players()
            shutdown_handler.restore_hitsound()
        end)
    end

    shutdown_handler.setup()
end
--@endregion

--@region: enemy ping flag
enemy_ping = {} do
    enemy_ping.alphas = {}

    enemy_ping.draw = function()
        if not interface.visuals.enabled_visuals:get() then return end
        if not interface.visuals.enemy_ping_warn:get() then return end

        local player_resource = entity.get_player_resource()
        if not player_resource then return end

        local local_player = entity.get_local_player()
        if not local_player then return end

        local local_player_team = entity.get_prop(local_player, 'm_iTeamNum')
        if not local_player_team then return end

        local maxplayers = globals.maxplayers()

        for player = 1, maxplayers do
            if not enemy_ping.alphas[player] then
                enemy_ping.alphas[player] = 0
            end
        end

        for player = 1, maxplayers do
            if entity.get_prop(player_resource, 'm_bConnected', player) == 1 then
                local player_team = entity.get_prop(player, 'm_iTeamNum')
                if player_team and player_team ~= local_player_team then
                    if entity.get_prop(player_resource, 'm_bAlive', player) == 1 then
                        local ping = entity.get_prop(player_resource, string.format('%03d', player))
                        local value = interface.visuals.enemy_ping_minimum:get()

                        if ping and ping >= value then
                            local x1, y1, x2, y2, multiplier = entity.get_bounding_box(player)

                            if x1 ~= nil and multiplier > 0 then
                                local x_center = x1 + (x2 - x1) / 2

                                local text = 'latency'
                                local r, g, b, a = 214, 214, 214, 150

                                if ping >= 150 then
                                    text = 'latency!!!'
                                    r, g, b, a = 255, 100, 100, 230
                                end

                                local target_alpha = a * multiplier
                                local current_alpha = enemy_ping.alphas[player]

                                enemy_ping.alphas[player] = mathematic.lerp(current_alpha, target_alpha, 0.2)
                                renderer.text(x_center, y1 - 16, r, g, b, enemy_ping.alphas[player], 'c', 0, text)
                            else
                                local current_alpha = enemy_ping.alphas[player]
                                enemy_ping.alphas[player] = mathematic.lerp(current_alpha, 0, 0.2)
                            end
                        end
                    end
                end
            end
        end
    end
end

client.set_event_callback('paint', function()
    enemy_ping.draw()
end)
--@endregion

--@region: predict box
predict_box = {} do
    predict_box.esp_data = {}
    predict_box.sim_ticks = {}
    predict_box.net_data = {}
    predict_box.default_box_color = {47, 117, 221, 255}
    local predictive_shot_strength = 4

    local function reset_player(idx)
        predict_box.esp_data[idx] = nil
        predict_box.sim_ticks[idx] = nil
        predict_box.net_data[idx] = nil
    end

    function predict_box.reset()
        predict_box.esp_data = {}
        predict_box.sim_ticks = {}
        predict_box.net_data = {}
    end

    local function time_to_ticks(t)
        return math.floor(0.5 + (t / globals.tickinterval()))
    end

    local function get_prediction_color(distance)
        if distance < 10 then
            return 47, 117, 221, 255
        elseif distance < 50 then
            return 255, 165, 0, 255
        end

        return 255, 0, 0, 255
    end

    local function draw_3d_box(mins, maxs, r, g, b, a)
        local points = {
            {mins.x, mins.y, mins.z},
            {mins.x, maxs.y, mins.z},
            {maxs.x, maxs.y, mins.z},
            {maxs.x, mins.y, mins.z},
            {mins.x, mins.y, maxs.z},
            {mins.x, maxs.y, maxs.z},
            {maxs.x, maxs.y, maxs.z},
            {maxs.x, mins.y, maxs.z}
        }

        local edges = {
            {1, 2}, {2, 3}, {3, 4}, {4, 1},
            {5, 6}, {6, 7}, {7, 8}, {8, 5},
            {1, 5}, {2, 6}, {3, 7}, {4, 8}
        }

        for i = 1, #edges do
            local p1 = points[edges[i][1]]
            local p2 = points[edges[i][2]]
            local x1, y1 = renderer.world_to_screen(p1[1], p1[2], p1[3])
            local x2, y2 = renderer.world_to_screen(p2[1], p2[2], p2[3])

            if x1 and y1 and x2 and y2 then
                renderer.line(x1, y1, x2, y2, r, g, b, a)
            end
        end
    end

    local function get_active_players(local_player)
        local observer_mode = entity.get_prop(local_player, "m_iObserverMode") or 0

        if observer_mode == 0 or observer_mode == 1 or observer_mode == 2 or observer_mode == 6 then
            return entity.get_players(true) or {}
        end

        if observer_mode ~= 4 and observer_mode ~= 5 then
            return {}
        end

        local observer_target = entity.get_prop(local_player, "m_hObserverTarget") or -1
        if observer_target == -1 or observer_target == 0 then
            return {}
        end

        local observer_team = entity.get_prop(observer_target, "m_iTeamNum")
        if not observer_team then
            return {}
        end

        local players = entity.get_players(false) or {}
        local result = {}

        for i = 1, #players do
            local idx = players[i]
            if idx ~= local_player and entity.get_prop(idx, "m_iTeamNum") ~= observer_team then
                result[#result + 1] = idx
            end
        end

        return result
    end

    function predict_box.on_net_update()
        local visual_runtime = interface.visuals.enabled_visuals:get() and interface.visuals.predict_box:get()
        local aimbot_runtime = interface.aimbot.enabled_aimbot:get() and interface.aimbot.predictive_shot:get()

        if not visual_runtime and not aimbot_runtime then
            predict_box.reset()
            return
        end

        local local_player = entity.get_local_player()
        if not local_player or not entity.is_alive(local_player) then
            predict_box.reset()
            return
        end

        local players = entity.get_players(true) or {}
        local visual_prediction_strength = visual_runtime and interface.visuals.predict_box_strength:get() or predictive_shot_strength
        local seen = {}

        for i = 1, #players do
            local idx = players[i]
            seen[idx] = true

            if entity.is_dormant(idx) or not entity.is_alive(idx) then
                reset_player(idx)
                goto continue
            end

            local origin = player.get_origin_vec(idx)
            local sim_time = entity.get_prop(idx, "m_flSimulationTime")

            if not origin or not sim_time then
                goto continue
            end

            local velocity, velocity_length = player.get_velocity_vec(idx)
            local simulation_tick = time_to_ticks(sim_time)
            local previous = predict_box.sim_ticks[idx]

            if previous ~= nil then
                local delta = simulation_tick - previous.tick
                local force_predict = delta <= 1 or delta > 64

                if delta < 0 or (delta > 0 and delta <= 64) or force_predict then
                    local flags = entity.get_prop(idx, "m_fFlags") or 0
                    local diff_origin = utils.vec_sub(origin, previous.origin)
                    local teleport_distance = utils.vec_length_2d(diff_origin)
                    local ticks_to_predict = delta < 0 and 1 or delta
                    local measured_speed = nil
                    if delta > 0 and delta <= 16 then
                        measured_speed = teleport_distance / (delta * globals.tickinterval())
                    end
                    local effective_speed = player.resolve_effective_speed(velocity_length, measured_speed, previous.speed)
                    local visual_prediction_ticks = 2
                    local aim_prediction_ticks = 2

                    if effective_speed > 100 then
                        visual_prediction_ticks = math.min(visual_prediction_strength, math.floor(effective_speed / 50))
                        aim_prediction_ticks = math.min(predictive_shot_strength, math.floor(effective_speed / 50))
                    end

                    local normal_prediction = delta >= 0 and teleport_distance <= 64
                    local visual_final_prediction_ticks = force_predict and visual_prediction_strength
                        or (normal_prediction and visual_prediction_ticks or ticks_to_predict)
                    local aim_final_prediction_ticks = force_predict and predictive_shot_strength
                        or (normal_prediction and aim_prediction_ticks or ticks_to_predict)
                    local final_prediction_ticks = visual_runtime and visual_final_prediction_ticks or aim_final_prediction_ticks
                    local extrapolated = player.extrapolate_position(idx, origin, flags, final_prediction_ticks)
                    local is_tickbase = delta < 0
                    local is_fakelag = teleport_distance > 64
                    local rapid_direction_change = false

                    if previous.velocity then
                        local previous_xy = utils.vec_length_2d(previous.velocity)
                        local current_xy = utils.vec_length_2d(velocity)

                        if previous_xy > 0 and current_xy > 0 then
                            local dot = ((previous.velocity.x * velocity.x) + (previous.velocity.y * velocity.y))
                                / ((previous_xy * current_xy) + 0.001)
                            rapid_direction_change = dot < 0.7 and velocity_length > 150
                        end
                    end

                    local is_defensive_peek = (is_fakelag or is_tickbase or force_predict) and rapid_direction_change

                    if is_tickbase then
                        predict_box.esp_data[idx] = 1
                    elseif is_fakelag and (predict_box.esp_data[idx] or 0) == 0 then
                        predict_box.esp_data[idx] = 0.8
                    elseif is_defensive_peek or force_predict then
                        predict_box.esp_data[idx] = 0.9
                    end

                    predict_box.net_data[idx] = {
                        tick = final_prediction_ticks,
                        aim_tick = aim_final_prediction_ticks,
                        origin = origin,
                        predicted_origin = extrapolated,
                        speed = effective_speed,
                        raw_speed = velocity_length,
                        tickbase = is_tickbase,
                        lagcomp = is_fakelag,
                        normal_prediction = normal_prediction,
                        defensive_peek = is_defensive_peek,
                        force_predict = force_predict
                    }
                end
            end

            if predict_box.esp_data[idx] == nil then
                predict_box.esp_data[idx] = 0
            end

            predict_box.sim_ticks[idx] = {
                tick = simulation_tick,
                origin = origin,
                velocity = velocity,
                speed = predict_box.net_data[idx] and predict_box.net_data[idx].speed or velocity_length
            }

            ::continue::
        end

        for idx in pairs(predict_box.sim_ticks) do
            if not seen[idx] then
                reset_player(idx)
            end
        end
    end

    function predict_box.on_paint()
        if not interface.visuals.enabled_visuals:get() or not interface.visuals.predict_box:get() then
            return
        end

        local local_player = entity.get_local_player()
        if not local_player then
            return
        end

        local active_players = get_active_players(local_player)
        if #active_players == 0 then
            return
        end

        local active_lookup = {}
        for i = 1, #active_players do
            active_lookup[active_players[i]] = true
        end

        local show_box = interface.visuals.predict_box_show_box:get()
        local show_tickbase = interface.visuals.predict_box_show_tickbase:get()
        local always_show = interface.visuals.predict_box_always_show:get()
        local debug_line = interface.visuals.predict_box_debug_line:get()
        local box_color = interface.visuals.predict_box_box_color.color.value
        local text_color = interface.visuals.predict_box_text_color.color.value

        for idx, player_data in pairs(predict_box.net_data) do
            if not active_lookup[idx] or not entity.is_alive(idx) or entity.is_dormant(idx) then
                goto continue
            end

            local predicted = player_data.predicted_origin
            if not predicted then
                goto continue
            end

            local origin = player.get_origin_vec(idx)
            if not origin then
                goto continue
            end

            local distance = utils.vec_distance(origin, predicted)
            local r, g, b, a = get_prediction_color(distance)

            if box_color[1] ~= predict_box.default_box_color[1]
                or box_color[2] ~= predict_box.default_box_color[2]
                or box_color[3] ~= predict_box.default_box_color[3]
                or box_color[4] ~= predict_box.default_box_color[4] then
                r, g, b, a = unpack(box_color)
            end

            if show_box and (always_show or player_data.lagcomp or player_data.normal_prediction or player_data.force_predict) then
                local min_x, min_y, min_z = entity.get_prop(idx, "m_vecMins")
                local max_x, max_y, max_z = entity.get_prop(idx, "m_vecMaxs")

                if min_x and max_x then
                    local mins = utils.vec_add(utils.new_vec(min_x, min_y, min_z), predicted)
                    local maxs = utils.vec_add(utils.new_vec(max_x, max_y, max_z), predicted)
                    draw_3d_box(mins, maxs, r, g, b, a)

                    if debug_line then
                        local screen_x1, screen_y1 = renderer.world_to_screen(origin.x, origin.y, origin.z)
                        local screen_x2, screen_y2 = renderer.world_to_screen(predicted.x, predicted.y, predicted.z)

                        if screen_x1 and screen_y1 and screen_x2 and screen_y2 then
                            renderer.line(screen_x1, screen_y1, screen_x2, screen_y2, 255, 255, 0, 200)
                        end
                    end
                end
            end

            local x1, y1, x2, y2, alpha_mult = entity.get_bounding_box(idx)
            if not x1 or alpha_mult <= 0 then
                goto continue
            end

            local pulse_alpha = 0
            local stored_alpha = predict_box.esp_data[idx] or 0

            if stored_alpha > 0 then
                stored_alpha = stored_alpha - (globals.frametime() * 2)
                if stored_alpha < 0 then
                    stored_alpha = 0
                end

                predict_box.esp_data[idx] = stored_alpha
                pulse_alpha = stored_alpha
            end

            local tickbase = player_data.tickbase or stored_alpha > 0
            local lagcomp = player_data.lagcomp
            local normal_prediction = player_data.normal_prediction or false
            local defensive_peek = player_data.defensive_peek or false
            local force_predict = player_data.force_predict or false

            if not tickbase and not lagcomp and not normal_prediction and not defensive_peek and not force_predict and not always_show then
                goto continue
            end

            if not tickbase or lagcomp then
                pulse_alpha = alpha_mult
            end

            if pulse_alpha <= 0 then
                goto continue
            end

            local center_x = x1 + ((x2 - x1) / 2)
            local name = entity.get_player_name(idx) or ""
            local y_add = name == "" and -8 or 0
            local text_alpha = math.floor((text_color[4] or 255) * math.min(pulse_alpha, 1))

            if show_tickbase and tickbase then
                renderer.text(center_x, y1 - 18 + y_add, text_color[1], text_color[2], text_color[3], text_alpha, 'c', 0, 'TICKBASE')
            end

            if lagcomp and show_box then
                renderer.text(center_x, y1 - 28 + y_add, text_color[1], text_color[2], text_color[3], text_alpha, 'c', 0, 'LAG COMP')
            elseif normal_prediction and show_box and not defensive_peek then
                renderer.text(center_x, y1 - 28 + y_add, text_color[1], text_color[2], text_color[3], text_alpha, 'c', 0, 'PREDICTION')
            elseif defensive_peek and show_box then
                local pulse = math.floor((math.sin(globals.realtime() * 5) * 0.5 + 0.5) * 255)
                renderer.text(center_x, y1 - 28 + y_add, 255, 20, 20, pulse, 'c', 0, 'DEFENSIVE PEEK')
            elseif force_predict and show_box then
                renderer.text(center_x, y1 - 28 + y_add, 0, 255, 0, text_alpha, 'c', 0, 'FORCE PREDICT')
            end

            if show_box and distance > 5 then
                renderer.text(center_x, y1 - 38 + y_add, text_color[1], text_color[2], text_color[3], text_alpha, 'c', 0, string.format("Pred: %.1f", distance))
            end

            ::continue::
        end
    end

    interface.visuals.predict_box:set_callback(function()
        local visual_runtime = interface.visuals.enabled_visuals:get() and interface.visuals.predict_box:get()
        local aimbot_runtime = interface.aimbot.enabled_aimbot:get() and interface.aimbot.predictive_shot:get()

        if not visual_runtime and not aimbot_runtime then
            predict_box.reset()
        end
    end)

    interface.aimbot.predictive_shot:set_callback(function()
        local visual_runtime = interface.visuals.enabled_visuals:get() and interface.visuals.predict_box:get()
        local aimbot_runtime = interface.aimbot.enabled_aimbot:get() and interface.aimbot.predictive_shot:get()

        if not visual_runtime and not aimbot_runtime then
            predict_box.reset()
        end
    end)

    client.set_event_callback('net_update_end', predict_box.on_net_update)
    client.set_event_callback('paint', predict_box.on_paint)
    client.set_event_callback('shutdown', predict_box.reset)
    client.set_event_callback('round_start', predict_box.reset)
end
--@endregion

--@region: predictive shot
predictive_shot = {} do
    predictive_shot.last_logged_command = nil

    local function is_supported_weapon(weapon)
        local weapon_info = csgo_weapons(weapon)
        if not weapon_info or weapon_info.type ~= "sniperrifle" then
            return false, nil
        end

        return weapon_info.idx == 9, weapon_info
    end

    local function should_use_prediction(data, origin_x, origin_y, origin_z, predicted_origin)
        if not data or not predicted_origin then
            return false
        end

        local shift = player.distance3d(origin_x, origin_y, origin_z, predicted_origin.x, predicted_origin.y, predicted_origin.z)

        if shift < 4 or data.lagcomp or data.tickbase then
            return false
        end

        return data.force_predict or data.defensive_peek
    end

    local function get_prediction_reason(data)
        local reasons = {}

        if data.tickbase then
            reasons[#reasons + 1] = "tickbase"
        end

        if data.defensive_peek then
            reasons[#reasons + 1] = "defensive_peek"
        end

        if data.force_predict then
            reasons[#reasons + 1] = "force_predict"
        end

        if data.lagcomp then
            reasons[#reasons + 1] = "lagcomp"
        end

        if data.normal_prediction then
            reasons[#reasons + 1] = "normal"
        end

        return #reasons > 0 and table.concat(reasons, "+") or "unknown"
    end

    local function log_shot(target, reason, shift, aim_ticks, selected_tick, speed, score, min_damage)
        local command_number = globals.tickcount()
        if predictive_shot.last_logged_command == command_number then
            return
        end

        predictive_shot.last_logged_command = command_number

        local target_name = entity.get_player_name(target) or "unknown"
        client.color_log(157, 230, 254, "noctua predictive shot \0")
        client.color_log(255, 255, 255,
            string.format(
                "target=%s weapon=%s reason=%s shift=%.1f aim_tick=%d selected_tick=%d speed=%.1f score=%.1f mindmg=%d\n\0",
                target_name,
                "awp",
                reason,
                shift,
                aim_ticks or 0,
                selected_tick or 0,
                speed or 0,
                score or 0,
                min_damage or 0
            )
        )
    end

    local function get_best_point(local_player, target, predicted_origin, min_damage)
        local ex, ey, ez = client.eye_position()
        local best_x, best_y, best_z
        local best_score = 0
        local origin = player.get_origin_vec(target)
        if not origin then
            return nil, nil, nil, 0
        end

        local delta_x = predicted_origin.x - origin.x
        local delta_y = predicted_origin.y - origin.y
        local group_hits = {}
        local group_center_point = {}
        local group_best_point = {}
        local group_best_score = {}
        local group_center_damage = {}
        local awp_points = {}
        local body_hitboxes = {
            { idx = 2, weight = 60 },
            { idx = 4, weight = 42 }
        }

        for i = 1, #body_hitboxes do
            local def = body_hitboxes[i]
            local hx, hy, hz = entity.hitbox_position(target, def.idx)
            if hx then
                group_center_point[def.idx] = {
                    x = hx + delta_x,
                    y = hy + delta_y,
                    z = hz
                }

                awp_points[#awp_points + 1] = {
                    x = hx + delta_x,
                    y = hy + delta_y,
                    z = hz,
                    weight = def.weight,
                    center = true,
                    group = def.idx
                }
                awp_points[#awp_points + 1] = {
                    x = hx + delta_x,
                    y = hy + delta_y,
                    z = hz + 1.5,
                    weight = def.weight - 8,
                    center = false,
                    group = def.idx
                }
            end
        end

        for i = 1, #awp_points do
            local point = awp_points[i]
            local _, damage = client.trace_bullet(local_player, ex, ey, ez, point.x, point.y, point.z, true)

            if damage > min_damage then
                group_hits[point.group] = (group_hits[point.group] or 0) + 1

                if point.center and damage > (group_center_damage[point.group] or 0) then
                    group_center_damage[point.group] = damage
                end

                local point_score = damage + point.weight
                if point_score > (group_best_score[point.group] or 0) then
                    group_best_score[point.group] = point_score
                    group_best_point[point.group] = point
                end
            end
        end

        local function choose_group(group_idx)
            local chosen_point = group_center_point[group_idx] or group_best_point[group_idx]
            local hits = group_hits[group_idx] or 0
            if not chosen_point or hits < 2 then
                return nil
            end

            return {
                x = chosen_point.x,
                y = chosen_point.y,
                z = chosen_point.z,
                score = (hits * 100) + (group_center_damage[group_idx] or 0)
            }
        end

        local stomach_choice = choose_group(2)
        local chest_choice = choose_group(4)
        local final_choice = stomach_choice

        if chest_choice and (not final_choice or chest_choice.score > final_choice.score) then
            final_choice = chest_choice
        end

        if final_choice then
            best_x, best_y, best_z = final_choice.x, final_choice.y, final_choice.z
            best_score = final_choice.score
        end

        return best_x, best_y, best_z, best_score
    end

    function predictive_shot.on_setup_command(cmd)
        if not (interface.aimbot.enabled_aimbot:get() and interface.aimbot.predictive_shot:get()) then
            return
        end

        local local_player = entity.get_local_player()
        if not local_player or not entity.is_alive(local_player) then
            return
        end

        local weapon = entity.get_player_weapon(local_player)
        local supported, weapon_info = is_supported_weapon(weapon)
        if not supported then
            return
        end

        local threat = client.current_threat()
        if not threat or not entity.is_alive(threat) or entity.is_dormant(threat) then
            return
        end

        if player_list.GetWhitelist(player_list, threat) then
            return
        end

        local target_origin = player.get_origin_vec(threat)
        if not target_origin then
            return
        end

        local target_flags = entity.get_prop(threat, "m_fFlags") or 0
        local net_data = predict_box.net_data[threat]
        local aim_origin, aim_ticks, target_speed = player.get_prediction_aim_origin(threat, net_data)
        local shift = aim_origin and player.distance3d(target_origin.x, target_origin.y, target_origin.z, aim_origin.x, aim_origin.y, aim_origin.z) or 0

        if not should_use_prediction(net_data, target_origin.x, target_origin.y, target_origin.z, aim_origin) then
            return
        end

        if net_data.force_predict and net_data.normal_prediction and not net_data.defensive_peek then
            if target_speed < 80 and shift > 20 then
                return
            end

            local adjusted_tick = math.min(aim_ticks, 2)

            if shift <= 12 then
                adjusted_tick = 1
            end

            if adjusted_tick ~= aim_ticks then
                aim_ticks = adjusted_tick
                aim_origin = player.extrapolate_position(threat, target_origin, target_flags, aim_ticks)
                shift = player.distance3d(target_origin.x, target_origin.y, target_origin.z, aim_origin.x, aim_origin.y, aim_origin.z)
            end

            local blend_factor = 0.86
            if shift <= 14 then
                blend_factor = 0.74
            elseif shift <= 22 then
                blend_factor = 0.8
            end

            if target_speed < 80 then
                blend_factor = math.min(blend_factor, 0.58)
            end

            aim_origin = utils.blend_vec(target_origin, aim_origin, blend_factor)
            shift = player.distance3d(target_origin.x, target_origin.y, target_origin.z, aim_origin.x, aim_origin.y, aim_origin.z)

            if aim_ticks > 1 and shift <= 8.5 then
                aim_ticks = 1
                aim_origin = player.extrapolate_position(threat, target_origin, target_flags, aim_ticks)
                aim_origin = utils.blend_vec(target_origin, aim_origin, 0.68)
                shift = player.distance3d(target_origin.x, target_origin.y, target_origin.z, aim_origin.x, aim_origin.y, aim_origin.z)
            end
        end

        local min_damage = utils.get_active_min_damage()
        local best_x, best_y, best_z, best_score = get_best_point(local_player, threat, aim_origin, min_damage)
        local best_tick = aim_ticks

        if not best_x or best_score <= 0 then
            return
        end

        local _, _, _, velocity_2d = player.get_velocity(local_player)
        local flags = entity.get_prop(local_player, "m_fFlags") or 0
        local on_ground = bit.band(flags, 1) == 1
        local scoped = entity.get_prop(local_player, "m_bIsScoped") == 1

        if not scoped then
            cmd.in_attack2 = 1
            return
        end

        if not on_ground then
            return
        end

        local spread_limit = 0.02
        local inaccuracy = entity.get_prop(weapon, "m_fAccuracyPenalty") or 0
        local max_speed = player.get_weapon_max_speed(local_player)
        local stop_speed_limit = math.min(52, max_speed * 0.24)

        if velocity_2d > stop_speed_limit or inaccuracy > spread_limit then
            local move_speed = math.sqrt((cmd.forwardmove * cmd.forwardmove) + (cmd.sidemove * cmd.sidemove))
            if move_speed > stop_speed_limit and move_speed > 0 then
                local scale = stop_speed_limit / move_speed
                cmd.forwardmove = cmd.forwardmove * scale
                cmd.sidemove = cmd.sidemove * scale
            end

            cmd.in_attack = 0
            cmd.buttons = bit.band(cmd.buttons, bit.bnot(1))
            return
        end

        local curtime = globals.curtime()
        local next_attack = entity.get_prop(local_player, "m_flNextAttack") or 0
        local next_primary = entity.get_prop(weapon, "m_flNextPrimaryAttack") or 0

        if curtime < next_attack or curtime < next_primary then
            return
        end

        local ex, ey, ez = client.eye_position()
        local pitch, yaw = utils.calc_angle(ex, ey, ez, best_x, best_y, best_z)
        cmd.pitch = pitch
        cmd.yaw = yaw
        cmd.in_attack = 1
        cmd.buttons = bit.bor(cmd.buttons, 1)
        cmd.no_choke = true
        log_shot(threat, get_prediction_reason(net_data), shift, aim_ticks, best_tick, target_speed, best_score, min_damage)
    end

    client.set_event_callback('setup_command', predictive_shot.on_setup_command)
end
--@endregion

summary = {} do
    if not _G.noctua_session then
        _G.noctua_session = {
            active = false,
            stats = {
                start_time = 0,
                kills = 0,
                deaths = 0,
                hits = 0,
                misses = 0,
                aa_misses = 0,
                miss_types = {},
                resolved = {}, 
                map_name = ""
            }
        }
    end

    local function fmt_ratio(a, b)
        a = tonumber(a) or 0
        b = tonumber(b) or 0
        if b == 0 then
            return string.format('%.2f', a)
        end
        return string.format('%.2f', a / b)
    end

    local function format_duration(seconds)
        local weeks = math.floor(seconds / 604800)
        seconds = seconds % 604800
        local days = math.floor(seconds / 86400)
        seconds = seconds % 86400
        local hours = math.floor(seconds / 3600)
        seconds = seconds % 3600
        local minutes = math.floor(seconds / 60)
        seconds = math.floor(seconds % 60)

        local result = {}
        if weeks > 0 then table.insert(result, weeks .. "w") end
        if days > 0 then table.insert(result, days .. "d") end
        if hours > 0 then table.insert(result, hours .. "h") end
        if minutes > 0 then table.insert(result, minutes .. "m") end
        table.insert(result, seconds .. "s")
        
        return table.concat(result, " ")
    end

    local function log_txt(text)
        client.color_log(212, 212, 212, text .. "\0")
    end

    local function log_val(text)
        client.color_log(255, 255, 255, text .. "\0")
    end

    local function log_accent(text)
        local r, g, b = unpack(interface.visuals.accent.color.value)
        client.color_log(r, g, b, text .. "\0")
    end

    local function update_enemy_list()
        if not _G.noctua_session.active then return end
        
        local enemies = entity.get_players(true)
        for i=1, #enemies do
            local ent = enemies[i]
            local steam_id = entity.get_steam64(ent)
            local key = nil

            if steam_id and steam_id ~= 0 then
                key = tostring(steam_id)
            else
                local name = entity.get_player_name(ent)
                if name then
                    key = "BOT_" .. name
                end
            end

            if key then
                _G.noctua_session.stats.resolved[key] = true
            end
        end
    end

    local function is_bot(idx)
        local info = utils.get_player_info and utils.get_player_info(idx)
        return info and info.__fakeplayer == true
    end

    summary.start_session = function()
        _G.noctua_session.active = true
        _G.noctua_session.stats = {
            start_time = globals.realtime(),
            kills = 0,
            deaths = 0,
            hits = 0,
            misses = 0,
            aa_misses = 0,
            miss_types = {},
            resolved = {},
            map_name = globals.mapname()
        }
        update_enemy_list()
    end

    summary.print_report = function()
        _G.noctua_session.active = false
        local s = _G.noctua_session.stats
        
        local duration = math.max(0, globals.realtime() - s.start_time)
        if duration < 1 then return end
        
        local res_count = 0
        for _ in pairs(s.resolved) do res_count = res_count + 1 end

        client.color_log(255, 255, 255, "\n")
        
        log_accent("noctua · ")
        log_txt("you've played ")
        log_val(format_duration(duration) .. " ")
        log_txt("on ")
        log_val(s.map_name)
        log_txt(".\nhere is your summary:\n")

        log_val("\npersonal\n")
        log_txt("  - you made ")
        log_val(string.format("%d ", s.kills))
        log_txt("kills and died ")
        log_val(string.format("%d ", s.deaths))
        log_txt("times (k/d: ")
        log_val(fmt_ratio(s.kills, s.deaths))
        log_txt(")\n")
        
        log_val("\nresolver\n")
        log_txt("  - processed ")
        log_val(string.format("%d ", res_count))
        log_txt("enemies total, made ")
        log_val(string.format("%d ", s.hits))
        log_txt("hits and ")
        log_val(string.format("%d ", s.misses))
        log_txt("misses (ratio: ")
        log_val(fmt_ratio(s.hits, s.misses))
        log_txt(")\n")

        if s.misses > 0 then
            log_txt("  - misses by type:\n")
            
            local sorted = {}
            for reason, count in pairs(s.miss_types) do
                table.insert(sorted, { reason = reason, count = count })
            end

            table.sort(sorted, function(a, b) 
                return a.count > b.count 
            end)

            for i = 1, #sorted do
                local item = sorted[i]
                log_txt("   - ")
                log_txt(item.reason)
                log_txt(": ")
                log_val(tostring(item.count) .. "\n")
            end
        end

        log_val("\nanti-aim\n")
        log_txt("  - enemies missed ")
        log_val(string.format("%d ", s.aa_misses))
        log_txt("times in your anti-aim\n")
        
        client.color_log(255, 255, 255, "\n")
    end

    summary.setup = function()
        client.set_event_callback('paint_ui', function()
            local in_game = globals.mapname() ~= nil

            if in_game then
                if not _G.noctua_session.active then
                    summary.start_session()
                else
                    update_enemy_list()
                end
            else
                if _G.noctua_session.active then
                    summary.print_report()
                end
            end
        end)

        client.set_event_callback('player_death', function(e)
            if not _G.noctua_session.active then return end
            
            local me = entity.get_local_player()
            local attacker = client.userid_to_entindex(e.attacker)
            local victim = client.userid_to_entindex(e.userid)

            if attacker == me and victim ~= me then
                _G.noctua_session.stats.kills = _G.noctua_session.stats.kills + 1
            elseif victim == me then
                _G.noctua_session.stats.deaths = _G.noctua_session.stats.deaths + 1
            end
        end)

        client.set_event_callback('aim_hit', function(e)
            if not _G.noctua_session.active then return end
            _G.noctua_session.stats.hits = _G.noctua_session.stats.hits + 1
        end)

        client.set_event_callback('aim_miss', function()
            if not _G.noctua_session.active then return end
            _G.noctua_session.stats.misses = _G.noctua_session.stats.misses + 1
        end)

        client.set_event_callback('bullet_impact', function(e)
            if not _G.noctua_session.active then return end
            local me = entity.get_local_player()
            if not me or not entity.is_alive(me) then return end
            local shooter = client.userid_to_entindex(e.userid)
            if not shooter or shooter == me or not entity.is_enemy(shooter) then return end
            if is_bot(shooter) then return end

            local lx, ly, lz = entity.hitbox_position(me, 0)
            local dist = math.sqrt((e.x - lx)^2 + (e.y - ly)^2 + (e.z - lz)^2)
            if dist < 60 then
                _G.noctua_session.stats.aa_misses = _G.noctua_session.stats.aa_misses + 1
            end
        end)
    end

    summary.setup()
end

--@region: bomb timer
bomb_timer = {} do
    bomb_timer.state = {
        alpha = 0,
        cached_text = "",
        cached_progress = 0,
        cached_color = {255, 255, 255},
        plant = { active = false, start_time = 0, site = "" },
        defused = false,
        defuse_time = 0
    }

    local bomb_original = ui.reference('visuals', 'other esp', 'bomb')

    local function dist_3d(x1, y1, z1, x2, y2, z2)
        return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2)
    end

    local function reset_state()
        local s = bomb_timer.state
        s.plant.active = false
        s.defused = false
        s.defuse_time = 0
        s.alpha = 0
        s.cached_progress = 0
    end

    bomb_timer.handle_ui = function()
        if not interface.visuals.bomb_timer then return end
        local enabled = interface.visuals.bomb_timer:get()
        if enabled then
            ui.set(bomb_original, false)
            ui.set_enabled(bomb_original, false)
        else
            ui.set_enabled(bomb_original, true)
        end
    end

    bomb_timer.paint_world = function()
        if not (interface.visuals.enabled_visuals:get() and interface.visuals.bomb_timer:get()) then
            return
        end

        local c4_ent = entity.get_all("CPlantedC4")[1]
        if not c4_ent then return end

        local x, y, z = entity.get_prop(c4_ent, "m_vecOrigin")
        if x then
            local sx, sy = renderer.world_to_screen(x, y, z + 20)
            if sx and sy then
                renderer.text(sx, sy, 255, 255, 255, 255, "c", 0, "bomb")
            end
        end
    end

    bomb_timer.paint = function(x, y, edit_mode)
        local s = bomb_timer.state
        if not (interface.visuals.enabled_visuals:get() and interface.visuals.bomb_timer:get()) then
            s.alpha = 0
            return
        end

        local curtime = globals.curtime()
        local active = false
        local text_str = ""
        local bar_val = 0
        local bar_col = { unpack(interface.visuals.accent.color.value) }

        local c4_ent = entity.get_all("CPlantedC4")[1]
        local is_planted = c4_ent ~= nil

        if s.defused then
            if (curtime - s.defuse_time) < 3.0 then
                active = true
                text_str = "bomb defused!"
                bar_col = {124, 195, 23}
                bar_val = 1
            end
        elseif is_planted then
            local blow = entity.get_prop(c4_ent, "m_flC4Blow") or 0
            local len = entity.get_prop(c4_ent, "m_flTimerLength") or 40
            local defused = entity.get_prop(c4_ent, "m_bBombDefused") == 1
            
            if defused then
                if not s.defused then
                    s.defused = true
                    s.defuse_time = curtime
                end
            else
                local left = blow - curtime
                if left > 0 then
                    active = true
                    local defuser = entity.get_prop(c4_ent, "m_hBombDefuser")
                    if defuser and defuser > 0 then
                        local def_end = entity.get_prop(c4_ent, "m_flDefuseCountDown") or 0
                        local def_len = entity.get_prop(c4_ent, "m_flDefuseLength") or 10
                        local def_left = def_end - curtime
                        
                        if def_end < blow then
                            bar_col = {124, 195, 23}
                            text_str = string.format("defusing in %.1fs", math.max(0, def_left))
                            bar_val = math.max(0, def_left / def_len)
                        else
                            bar_col = {255, 60, 60}
                            text_str = string.format("bomb explodes in %.1fs", left)
                            bar_val = math.max(0, left / len)
                        end
                    else
                        text_str = string.format("bomb explodes in %.1fs", left)
                        bar_val = math.max(0, left / len)
                    end
                end
            end
        elseif s.plant.active then
            active = true
            local progress = (curtime - s.plant.start_time) / 3.125
            text_str = "planting" .. s.plant.site .. "..."
            bar_val = math.max(0, math.min(1, progress))
        end

        if not active and edit_mode then
            active = true
            text_str = "bomb explodes in 20.0s"
            bar_val = 0.5
            s.alpha = 1
        end

        s.alpha = mathematic.lerp(s.alpha, active and 1 or 0, globals.frametime() * 6)

        if s.alpha < 0.01 then 
            s.cached_progress = 0
            return 
        end

        if active then
            s.cached_text = text_str
            s.cached_progress = mathematic.lerp(s.cached_progress, bar_val, globals.frametime() * 12)
            s.cached_color = bar_col
        end

        local w = 180
        local start_y = math.floor(y - 9)
        local rect_x, rect_y = math.floor(x - w / 2), start_y + 16
        local fill_w = math.floor(w * s.cached_progress)
        local r, g, b = unpack(s.cached_color)

        renderer.rectangle(rect_x, rect_y, w, 2, 50, 50, 50, math.floor(70 * s.alpha))
        renderer.rectangle(rect_x, rect_y, fill_w, 2, r, g, b, math.floor(255 * s.alpha))
        renderer.text(x, start_y, 255, 255, 255, math.floor(255 * s.alpha), "c", 0, s.cached_text)
    end

    bomb_timer.setup = function()
        client.set_event_callback("round_start", reset_state)
        client.set_event_callback("client_disconnect", reset_state)
        client.set_event_callback("shutdown", function() ui.set_enabled(bomb_original, true) end)
        client.set_event_callback("paint", bomb_timer.paint_world)

        client.set_event_callback("bomb_beginplant", function(e)
            local s = bomb_timer.state
            s.plant.active = true
            s.plant.start_time = globals.curtime()
            local player_resource = entity.get_all("CCSPlayerResource")[1]
            if e.site and player_resource then
                local o_x, o_y, o_z = entity.get_prop(e.site, "m_vecOrigin")
                local min_x, min_y, min_z = entity.get_prop(e.site, "m_vecMins")
                local max_x, max_y, max_z = entity.get_prop(e.site, "m_vecMaxs")
                local cx, cy, cz = o_x + (min_x + max_x) / 2, o_y + (min_y + max_y) / 2, o_z + (min_z + max_z) / 2
                local ax, ay, az = entity.get_prop(player_resource, "m_bombsiteCenterA")
                local bx, by, bz = entity.get_prop(player_resource, "m_bombsiteCenterB")
                s.plant.site = (dist_3d(cx, cy, cz, ax, ay, az) < dist_3d(cx, cy, cz, bx, by, bz)) and " A" or " B"
            else
                s.plant.site = ""
            end
        end)

        client.set_event_callback("bomb_abortplant", function() bomb_timer.state.plant.active = false end)
        client.set_event_callback("bomb_planted", function() bomb_timer.state.plant.active = false end)
        client.set_event_callback("bomb_defused", function() 
            bomb_timer.state.defused = true
            bomb_timer.state.defuse_time = globals.curtime()
        end)

        if interface.visuals.bomb_timer then
            bomb_timer.handle_ui()
            local timer_id = interface.visuals.bomb_timer.ref or interface.visuals.bomb_timer.id
            if timer_id then
                ui.set_callback(timer_id, bomb_timer.handle_ui)
            end
        end

        widgets.register({
            id = "bomb_timer",
            title = "Bomb Timer",
            defaults = { anchor_x = "center", anchor_y = "center", offset_x = 0, offset_y = -400 },
            get_size = function() return 180, 26 end,
            draw = function(ctx) bomb_timer.paint(ctx.cx, ctx.cy, ctx.edit_mode) end,
            z = 5
        })
    end

    bomb_timer.setup()
end
--@endregion

world_damage = {} do
    world_damage.markers = {}

    world_damage.on_player_hurt = function(e)
        if not interface.visuals.enabled_visuals:get() or not interface.visuals.world_damage:get() then return end

        local attacker = client.userid_to_entindex(e.attacker)
        local victim = client.userid_to_entindex(e.userid)
        local me = entity.get_local_player()

        if attacker ~= me or victim == me then return end

        local hitgroup = e.hitgroup
        local hitbox_idx = 2
        
        if hitgroup == 1 then hitbox_idx = 0
        elseif hitgroup == 4 or hitgroup == 5 then hitbox_idx = 16
        elseif hitgroup == 6 or hitgroup == 7 then hitbox_idx = 3
        end

        local x, y, z = entity.hitbox_position(victim, hitbox_idx)
        if not x then return end

        local damage_type = interface.visuals.world_damage_type:get()
        local is_static = damage_type == 'static'
        local spread = is_static and 0 or 15
        local drift = is_static and 0 or 15

        table.insert(world_damage.markers, {
            x = x + math.random(-spread, spread),
            y = y + math.random(-spread, spread),
            z = z,
            dest_x = math.random(-drift, drift),
            dest_y = math.random(-drift, drift),
            off_x = 0,
            off_y = 0,
            off_z = 0,
            damage = e.dmg_health,
            start_time = globals.realtime(),
            alpha = 0,
            damage_type = damage_type
        })
    end

    world_damage.on_paint = function()
        if not interface.visuals.enabled_visuals:get() or not interface.visuals.world_damage:get() then 
            world_damage.markers = {}
            return 
        end

        local curtime = globals.realtime()
        local frametime = globals.frametime()

        for i = #world_damage.markers, 1, -1 do
            local marker = world_damage.markers[i]
            local elapsed = curtime - marker.start_time
            local is_static = marker.damage_type == 'static'
            local duration = 2.5

            if elapsed > duration then
                table.remove(world_damage.markers, i)
            else
                if not is_static then
                    marker.off_x = mathematic.lerp(marker.off_x, marker.dest_x, frametime * 2)
                    marker.off_y = mathematic.lerp(marker.off_y, marker.dest_y, frametime * 2)
                    marker.off_z = marker.off_z + (frametime * 50)
                end
                
                if elapsed < 0.2 then
                    marker.alpha = mathematic.lerp(marker.alpha, 255, frametime * 15)
                elseif elapsed > 1.0 then
                    marker.alpha = mathematic.lerp(marker.alpha, 0, frametime * 5)
                else
                    marker.alpha = 255
                end

                local r_x = marker.x + marker.off_x
                local r_y = marker.y + marker.off_y
                local r_z = marker.z + marker.off_z

                local sx, sy = renderer.world_to_screen(r_x, r_y, r_z)
                if sx and sy then
                    renderer.text(sx, sy, 255, 255, 255, math.floor(marker.alpha), "c", 0, tostring(marker.damage))
                end
            end
        end
    end

    world_damage.setup = function()
        client.set_event_callback("player_hurt", world_damage.on_player_hurt)
        client.set_event_callback("paint", world_damage.on_paint)
    end

    world_damage.setup()
end

--@region: grenade radius
grenade_radius = {} do
    local anim_data = {}
    local tracks = {}
    local TWO_PI = 2 * math.pi

    local function smooth_contour(points, iterations)
        if #points < 3 then return points end
        local smoothed = points
        for k = 1, iterations do
            local next_pass = {}
            for i = 1, #smoothed do
                local prev = smoothed[(i - 2) % #smoothed + 1]
                local curr = smoothed[i]
                local next = smoothed[i % #smoothed + 1]
                
                table.insert(next_pass, {
                    x = (prev.x + curr.x + next.x) / 3,
                    y = (prev.y + curr.y + next.y) / 3,
                    z = curr.z
                })
            end
            smoothed = next_pass
        end
        return smoothed
    end

    local function draw_contour_smooth_limit(points, r, g, b, a, limit_fraction)
        if #points < 2 then return end
        
        local total_segments = #points
        local draw_amount = total_segments * limit_fraction
        
        local full_segments = math.floor(draw_amount)
        local remainder = draw_amount - full_segments

        local prev_sx, prev_sy = nil, nil
        local first_sx, first_sy = nil, nil

        for i = 1, full_segments + 1 do
            local idx = ((i - 1) % #points) + 1
            local p = points[idx]
            local sx, sy = renderer.world_to_screen(p.x, p.y, p.z)
            
            if sx and sy then
                if prev_sx and prev_sy then
                    renderer.line(prev_sx, prev_sy, sx, sy, r, g, b, a)
                else
                    first_sx, first_sy = sx, sy
                end
                prev_sx, prev_sy = sx, sy
            else
                prev_sx, prev_sy = nil, nil
            end
        end

        if remainder > 0.01 and prev_sx and prev_sy then
            local curr_idx = (full_segments % #points) + 1
            local next_idx = (curr_idx % #points) + 1
            
            local p_curr = points[curr_idx]
            local p_next = points[next_idx]

            local last_x = p_curr.x + (p_next.x - p_curr.x) * remainder
            local last_y = p_curr.y + (p_next.y - p_curr.y) * remainder
            local last_z = p_curr.z

            local last_sx, last_sy = renderer.world_to_screen(last_x, last_y, last_z)
            if last_sx and last_sy then
                renderer.line(prev_sx, prev_sy, last_sx, last_sy, r, g, b, a)
            end
        end
        
        if limit_fraction >= 0.995 and first_sx and prev_sx then
             renderer.line(prev_sx, prev_sy, first_sx, first_sy, r, g, b, a)
        end
    end

    local function draw_blob(circles, base_radius, r, g, b, a, outline_limit)
        if #circles == 0 then return end

        local avg_x, avg_y, avg_z = 0, 0, 0
        for _, c in ipairs(circles) do
            avg_x = avg_x + c.x
            avg_y = avg_y + c.y
            avg_z = avg_z + c.z
        end
        avg_x = avg_x / #circles
        avg_y = avg_y / #circles
        avg_z = avg_z / #circles

        local contour_points = {}
        local num_rays = 90
        local step = TWO_PI / num_rays

        for i = 0, num_rays - 1 do
            local theta = i * step
            local dir_x = math.cos(theta)
            local dir_y = math.sin(theta)
            local max_dist = 0

            for _, c in ipairs(circles) do
                local R = base_radius * c.scale
                local Vx = avg_x - c.x
                local Vy = avg_y - c.y
                
                local B = 2 * (Vx * dir_x + Vy * dir_y)
                local C = Vx*Vx + Vy*Vy - R*R
                local det = B*B - 4*C

                if det >= 0 then
                    local sqrt_det = math.sqrt(det)
                    local t1 = (-B + sqrt_det) / 2
                    local t2 = (-B - sqrt_det) / 2
                    max_dist = math.max(max_dist, t1, t2)
                end
            end

            if max_dist > 0 then
                table.insert(contour_points, {
                    x = avg_x + dir_x * max_dist,
                    y = avg_y + dir_y * max_dist,
                    z = avg_z
                })
            end
        end

        local smoothed_points = smooth_contour(contour_points, 3)
        
        draw_contour_smooth_limit(smoothed_points, r, g, b, a, outline_limit)
    end

    grenade_radius.on_paint = function()
        if not interface.visuals.enabled_visuals:get() then return end
        if not interface.visuals.grenade_radius:get() then return end

        local selection = interface.visuals.grenade_radius:get()
        local show_smoke = utils.contains(selection, 'smoke')
        local show_molotov = utils.contains(selection, 'molotov')
        local frame_time = globals.frametime() * 6
        local cur_time_sec = globals.curtime()
        
        local smoke_duration = 18.0

        for id, track in pairs(tracks) do
            track.updated = false
        end

        if show_molotov then
            local molotovs = entity.get_all("CInferno")
            for _, idx in ipairs(molotovs) do
                local circles = {}
                local fire_count = entity.get_prop(idx, "m_fireCount") or 0
                local ox, oy, oz = entity.get_prop(idx, "m_vecOrigin")

                for i = 0, fire_count do
                    local key = idx .. "_f_" .. i
                    local is_burning = entity.get_prop(idx, "m_bFireIsBurning", i) == 1
                    local target = is_burning and 1 or 0
                    
                    anim_data[key] = mathematic.lerp(anim_data[key] or 0, target, frame_time)

                    if anim_data[key] > 0.01 then
                        local dx = entity.get_prop(idx, "m_fireXDelta", i)
                        local dy = entity.get_prop(idx, "m_fireYDelta", i)
                        local dz = entity.get_prop(idx, "m_fireZDelta", i)
                        if dx and dy and dz then
                            table.insert(circles, {
                                x = ox + dx, y = oy + dy, z = oz + dz,
                                scale = anim_data[key]
                            })
                        end
                    end
                end
                
                if #circles > 0 then
                    if not tracks[idx] then tracks[idx] = { alpha = 0 } end
                    tracks[idx].type = 'molotov'
                    tracks[idx].circles = circles
                    tracks[idx].updated = true
                    tracks[idx].target_alpha = 1
                end
            end
        end

        if show_smoke then
            local smokes = entity.get_all("CSmokeGrenadeProjectile")
            for _, idx in ipairs(smokes) do
                local begin_tick = entity.get_prop(idx, "m_nSmokeEffectTickBegin")
                if begin_tick and begin_tick > 0 then
                    local x, y, z = entity.get_prop(idx, "m_vecOrigin")
                    
                    local key = "smoke_grow_" .. idx
                    anim_data[key] = mathematic.lerp(anim_data[key] or 0, 1, frame_time)

                    if not tracks[idx] then 
                        local tick_interval = globals.tickinterval()
                        local ticks_alive = globals.tickcount() - begin_tick
                        local time_alive = ticks_alive * tick_interval
                        
                        anim_data[key] = 0
                        
                        tracks[idx] = { 
                            alpha = 0,
                            start_time = cur_time_sec - time_alive 
                        } 
                    end
                    
                    tracks[idx].type = 'smoke'
                    tracks[idx].circles = {{ x = x, y = y, z = z, scale = anim_data[key] }}
                    tracks[idx].updated = true
                    tracks[idx].target_alpha = 1
                end
            end
        end

        local r_mol, g_mol, b_mol, a_mol = unpack(interface.visuals.grenade_radius_molotov_color.color.value)
        local r_sm, g_sm, b_sm, a_sm = unpack(interface.visuals.grenade_radius_smoke_color.color.value)

        for id, track in pairs(tracks) do
            if not track.updated then
                track.target_alpha = 0
            end
            
            track.alpha = mathematic.lerp(track.alpha, track.target_alpha, frame_time)

            if track.alpha < 0.01 and track.target_alpha == 0 then
                tracks[id] = nil
            else
                local render_alpha = track.alpha
                
                if track.type == 'molotov' then
                    local final_a = math.floor(a_mol * render_alpha)
                    if final_a > 1 then
                        draw_blob(track.circles, 60, r_mol, g_mol, b_mol, final_a, 1.0)
                    end

                elseif track.type == 'smoke' then
                    local final_a = math.floor(a_sm * render_alpha)
                    if final_a > 1 then
                        local elapsed = cur_time_sec - track.start_time
                        local progress = 1.0 - (elapsed / smoke_duration)
                        if progress < 0 then progress = 0 end
                        
                        draw_blob(track.circles, 144, r_sm, g_sm, b_sm, final_a, progress)
                    end
                end
            end
        end
    end

    client.set_event_callback("paint", grenade_radius.on_paint)
end
--@endregion

--@region: dormant aimbot
dormant_aimbot = {} do
    _G.noctua_runtime.dormant_state = "waiting"
    dormant_aimbot.targets = {}
    dormant_aimbot.refresh_window = 4
    dormant_aimbot.shot_cooldown = 10
    dormant_aimbot.max_extrapolation = 0.10
    dormant_aimbot.lead_scale = 0.55
    dormant_aimbot.stale_decay = 0.65

    local virtual_hitboxes = {
        { scale = 3.8, hitbox = "pelvis",      z = 28, duck_sub = 6,  priority = 1 },
        { scale = 3.5, hitbox = "stomach",     z = 38, duck_sub = 8,  priority = 2 },
        { scale = 3.6, hitbox = "thorax",      z = 45, duck_sub = 10, priority = 3 },
        { scale = 3.2, hitbox = "chest",       z = 51, duck_sub = 12, priority = 4 }
    }

    dormant_aimbot.reset = function()
        dormant_aimbot.targets = {}
    end

    dormant_aimbot.on_setup_command = function(cmd)
        if not interface.aimbot.dormant_enabled:get() or not interface.aimbot.dormant_enabled.hotkey:get() then return end

        local lp = entity.get_local_player()
        if not entity.is_alive(lp) then return end

        local weapon = entity.get_player_weapon(lp)
        local w_data = csgo_weapons(weapon)
        if not w_data then return end

        _G.noctua_runtime.dormant_state = "waiting"
        
        local w_type = w_data.type
        if w_type == "grenade" or w_type == "knife" or w_type == "c4" then return end
        local hc_val = interface.aimbot.dormant_hitchance:get()

        local ex, ey, ez = client.eye_position()
        local min_dmg_cfg = interface.aimbot.dormant_damage:get()
        local max_players = globals.maxplayers()
        local resource = entity.get_player_resource()
        local current_tick = globals.tickcount()
        local best_safety_score = 0
        local best_x, best_y, best_z
        local best_idx

        if hc_val == 50 then
            local w_idx = bit.band(entity.get_prop(weapon, "m_iItemDefinitionIndex") or 0, 0xFFFF)

            if w_idx == 11 or w_idx == 38 then
                hc_val = 84
            elseif w_idx == 64 then
                hc_val = 65
            elseif w_idx == 9 then
                hc_val = 90
            elseif w_idx == 40 then
                hc_val = 85
            else 
                hc_val = 80
            end
        end

        local alpha_threshold = 0.40 + ((hc_val - 50) / 50) * 0.30
        local point_score_threshold = 170 + ((hc_val - 50) * 3)
        local center_damage_bonus = math.floor((hc_val - 50) / 8)
        local require_full_confirmation = hc_val >= 78
        local ping = math.max(0.0, client.latency())
        local lerp = math.max(0.0, client.get_cvar("cl_interp") or 0.031)

        for idx = 1, max_players do
            if entity.get_prop(resource, "m_bConnected", idx) == 1 and 
               idx ~= lp and 
               entity.is_enemy(idx) and 
               entity.is_dormant(idx) and
               entity.get_prop(idx, "m_lifeState") == 0 then
                if player_list.GetWhitelist(player_list, idx) then
                    goto continue_dormant_target
                end
                
                local x1, y1, x2, y2, alpha = entity.get_bounding_box(idx)
                
                if alpha and alpha > alpha_threshold then
                    local ox, oy, oz = entity.get_origin(idx)
                    local vx, vy = player.get_velocity(idx)
                    local target_state = dormant_aimbot.targets[idx] or {}
                    local position_changed = target_state.ox == nil
                        or math.abs((target_state.ox or 0) - ox) > 1
                        or math.abs((target_state.oy or 0) - oy) > 1
                        or math.abs((target_state.oz or 0) - oz) > 1
                    local alpha_changed = target_state.alpha == nil or math.abs((target_state.alpha or 0) - alpha) > 0.02

                    if position_changed or alpha_changed then
                        target_state.updated_tick = current_tick
                    end

                    target_state.ox = ox
                    target_state.oy = oy
                    target_state.oz = oz
                    target_state.alpha = alpha
                    dormant_aimbot.targets[idx] = target_state
                    
                    if math.abs(ox) > 1 then
                        local age_ticks = target_state.updated_tick and (current_tick - target_state.updated_tick) or 999

                        if age_ticks > dormant_aimbot.refresh_window then
                            goto continue_dormant_target
                        end

                        if target_state.last_shot_tick and (current_tick - target_state.last_shot_tick) < dormant_aimbot.shot_cooldown then
                            goto continue_dormant_target
                        end

                        local dist_sq = (ox-ex)^2 + (oy-ey)^2 + (oz-ez)^2
                        
                        if dist_sq < 9000000 then 
                            local freshness = 1 - math.min(1, age_ticks / dormant_aimbot.refresh_window)
                            local lead_scale = dormant_aimbot.lead_scale * (1 - ((1 - freshness) * dormant_aimbot.stale_decay))
                            local extrapolation = math.min(dormant_aimbot.max_extrapolation, ping + lerp) * lead_scale

                            local pred_x = ox + (vx * extrapolation)
                            local pred_y = oy + (vy * extrapolation)
                            
                            local duck_amt = entity.get_prop(idx, "m_flDuckAmount") or 0
                            
                            for i = 1, #virtual_hitboxes do
                                local box = virtual_hitboxes[i]
                                local vz = oz + (box.z - (duck_amt * box.duck_sub))
                                
                                local _, yaw_to = utils.calc_angle(ex, ey, ez, pred_x, pred_y, vz)
                                local rad = math.rad(yaw_to + 90)
                                
                                local side_scale = box.scale * 0.8
                                local forward_scale = box.scale * 0.55
                                local off_x = math.cos(rad) * side_scale
                                local off_y = math.sin(rad) * side_scale
                                local fwd_x = math.cos(rad - math.pi / 2) * forward_scale
                                local fwd_y = math.sin(rad - math.pi / 2) * forward_scale
                                
                                local points = {
                                    { x = pred_x, y = pred_y, z = vz, weight = 40, center = true },
                                    { x = pred_x + off_x, y = pred_y + off_y, z = vz, weight = 28 },
                                    { x = pred_x - off_x, y = pred_y - off_y, z = vz, weight = 28 },
                                    { x = pred_x + fwd_x, y = pred_y + fwd_y, z = vz, weight = 22 },
                                    { x = pred_x - fwd_x, y = pred_y - fwd_y, z = vz, weight = 22 },
                                    { x = pred_x, y = pred_y, z = vz + 2, weight = 18 },
                                    { x = pred_x, y = pred_y, z = vz - 2, weight = 18 }
                                }

                                local points_hit = 0
                                local center_hit = false
                                local center_dmg = 0
                                local valid_point_coords = nil
                                local side_hits = 0
                                local best_point_score = 0

                                for p = 1, #points do
                                    local pt = points[p]
                                    local _, dmg = client.trace_bullet(lp, ex, ey, ez, pt.x, pt.y, pt.z, true)
                                    
                                    if dmg > min_dmg_cfg then
                                        points_hit = points_hit + 1
                                        local point_score = dmg + pt.weight
                                        if pt.center then
                                            center_hit = true
                                            center_dmg = dmg + center_damage_bonus
                                        else
                                            side_hits = side_hits + 1
                                        end
                                        if point_score > best_point_score then
                                            best_point_score = point_score
                                            valid_point_coords = pt
                                        end
                                    end
                                end

                                local min_points_needed = require_full_confirmation and 3 or (alpha > 0.72 and 2 or 3)
                                local confirmation_ok = center_hit and points_hit >= min_points_needed
                                if not confirmation_ok and points_hit >= 4 and side_hits >= 3 and best_point_score > (min_dmg_cfg + 24) then
                                    confirmation_ok = true
                                end
                                if require_full_confirmation or alpha <= 0.88 then
                                    confirmation_ok = confirmation_ok and side_hits >= 2
                                end

                                if confirmation_ok then
                                    local score = (points_hit * 100) + center_dmg - (box.priority * 5)
                                    if score >= point_score_threshold and score > best_safety_score then
                                        best_safety_score = score
                                        best_idx = idx
                                        best_x, best_y, best_z = valid_point_coords.x, valid_point_coords.y, valid_point_coords.z
                                    end
                                end
                            end
                        end
                    end
                end
            end

            ::continue_dormant_target::
        end

        if not best_x then 
            _G.noctua_runtime.dormant_state = "waiting"
            return 
        end

        _G.noctua_runtime.dormant_state = "working"

        local spread_limit = 0.02
        local _, _, _, velocity_2d = player.get_velocity(lp)
        local flags = entity.get_prop(lp, "m_fFlags") or 0
        local on_ground = bit.band(flags, 1) == 1

        if w_type == "sniperrifle" and entity.get_prop(lp, "m_bIsScoped") == 0 then
            cmd.in_attack2 = 1
            return
        end

        if not on_ground then
            _G.noctua_runtime.dormant_state = "waiting"
            return
        end

        local inaccuracy = entity.get_prop(weapon, "m_fAccuracyPenalty") or 0
        local max_spd = player.get_weapon_max_speed(lp)
        local stop_speed_limit = math.min(52, max_spd * 0.24)

        if velocity_2d > stop_speed_limit or inaccuracy > spread_limit then
            local move_speed = math.sqrt(cmd.forwardmove * cmd.forwardmove + cmd.sidemove * cmd.sidemove)
            if move_speed > stop_speed_limit and move_speed > 0 then
                local scale = stop_speed_limit / move_speed
                cmd.forwardmove = cmd.forwardmove * scale
                cmd.sidemove = cmd.sidemove * scale
            end
            cmd.in_attack = 0
            cmd.buttons = bit.band(cmd.buttons, bit.bnot(1))
            return
        end

        local curtime = globals.curtime()
        local next_att = entity.get_prop(lp, "m_flNextAttack") or 0
        local next_prim = entity.get_prop(weapon, "m_flNextPrimaryAttack") or 0
        
        if curtime < next_att or curtime < next_prim then return end

        local final_inaccuracy = entity.get_prop(weapon, "m_fAccuracyPenalty") or 0
        
        if final_inaccuracy <= spread_limit then
            local pitch, yaw = utils.calc_angle(ex, ey, ez, best_x, best_y, best_z)
            cmd.pitch = pitch
            cmd.yaw = yaw
            cmd.in_attack = 1
            cmd.buttons = bit.bor(cmd.buttons, 1)
            cmd.no_choke = true

            if best_idx then
                local target_state = dormant_aimbot.targets[best_idx] or {}
                target_state.last_shot_tick = current_tick
                dormant_aimbot.targets[best_idx] = target_state
            end
        end
    end

    client.set_event_callback('setup_command', dormant_aimbot.on_setup_command)
    client.set_event_callback('round_start', dormant_aimbot.reset)
    client.set_event_callback('cs_game_disconnected', dormant_aimbot.reset)
    client.set_event_callback('game_newmap', dormant_aimbot.reset)
    client.set_event_callback('shutdown', dormant_aimbot.reset)
end
--@endregion

--@region: auto !r8
auto_r8 = {} do
    auto_r8.has_sent = false
    auto_r8.used_r8_this_round = false
    auto_r8.freeze_started_at = nil
    auto_r8.active_pistol_round = 0

    auto_r8.reset = function()
        auto_r8.has_sent = false
        auto_r8.used_r8_this_round = false
        auto_r8.freeze_started_at = nil
        auto_r8.active_pistol_round = 0
    end

    auto_r8.reset_freeze_state = function()
        auto_r8.has_sent = false
        auto_r8.freeze_started_at = nil
    end

    auto_r8.get_next_round_number = function(game_rules)
        if not game_rules then
            return 0
        end

        if entity.get_prop(game_rules, "m_bWarmupPeriod") == 1 then
            return 0
        end

        local rounds_played = entity.get_prop(game_rules, "m_totalRoundsPlayed") or 0
        return rounds_played + 1
    end

    auto_r8.is_pistol_round = function(round_number)
        if not round_number or round_number <= 0 then
            return false
        end

        local max_rounds = tonumber(client.get_cvar("mp_maxrounds")) or 30
        local rounds_per_half = math.max(1, math.floor(max_rounds / 2))

        return round_number == 1 or round_number == (rounds_per_half + 1)
    end

    auto_r8.can_send = function()
        local local_player = entity.get_local_player()
        if not local_player then
            return false
        end

        local team = entity.get_prop(local_player, "m_iTeamNum") or 0
        if team ~= 2 and team ~= 3 then
            return false
        end

        if (entity.get_prop(local_player, "m_iHealth") or 0) <= 0 then
            return false
        end

        local observer_mode = entity.get_prop(local_player, "m_iObserverMode") or 0
        if observer_mode ~= 0 then
            return false
        end

        local observer_target = entity.get_prop(local_player, "m_hObserverTarget") or -1
        if observer_target ~= -1 and observer_target ~= 0 then
            return false
        end

        return true
    end

    auto_r8.on_paint = function()
        if not interface.utility.auto_r8:get() then
            auto_r8.reset()
        end
    end

    auto_r8.on_round_prestart = function()
        auto_r8.reset()

        if not interface.utility.auto_r8:get() then
            return
        end

        local game_rules = entity.get_all("CCSGameRulesProxy")[1]
        if not game_rules then
            return
        end

        local round_number = auto_r8.get_next_round_number(game_rules)
        if not auto_r8.is_pistol_round(round_number) then
            return
        end

        client.delay_call(0.05, function()
            if auto_r8.has_sent or not interface.utility.auto_r8:get() then
                return
            end

            if not auto_r8.can_send() then
                return
            end

            client.exec("say_team !r8")
            logging:push("swapped to revolver")
            auto_r8.has_sent = true
            auto_r8.used_r8_this_round = true
            auto_r8.active_pistol_round = round_number
        end)
    end

    auto_r8.on_round_end = function()
        if not interface.utility.auto_r8:get() then
            auto_r8.used_r8_this_round = false
            return
        end

        if not auto_r8.used_r8_this_round then
            return
        end

        if not auto_r8.can_send() then
            auto_r8.used_r8_this_round = false
            auto_r8.active_pistol_round = 0
            return
        end

        client.exec("say_team !deagle")
        logging:push("swapped back to deagle")
        auto_r8.used_r8_this_round = false
        auto_r8.active_pistol_round = 0
    end

    client.set_event_callback("round_end", auto_r8.on_round_end)
    client.set_event_callback("round_prestart", auto_r8.on_round_prestart)
    client.set_event_callback("round_freeze_end", auto_r8.reset_freeze_state)
    client.set_event_callback("cs_game_disconnected", auto_r8.reset)
    client.set_event_callback("game_newmap", auto_r8.reset)
    client.set_event_callback("paint", auto_r8.on_paint)
end
--@endregion

--@region: art
art = {} do
    local changelog = [[
    Changelog:
    - Added known alias system
    - Added predictive shot (experimental)
    - Added hitchance override
    - Added streamer mode
    - Added animation breakers
    - Added buybot fallback option
    - Added bomb timer
    - Added grenade radius visualization
    - Added world damage
    - Added world damage animations
    - Added mismatch reasons
    - Added compatibility mode
    - Added dormant aimbot
    - Added opposite knife hand
    - Added auto r8
    - Added sync aimbot hotkeys
    - Added unlock fd speed
    - Added animated text blur for damage indicator
    - Reworked miss reasons
    - Reworked buybot
    - Reworked experimental yaw correction
    - Reworked debug window
    - Reworked dormant aimbot safe point detection
    - Reworked killsay delays
    - Fixed buybot fallback purchasing after primary items
    - Fixed damage indicator color brightening during animation
    - Fixed shutdown restoration
    - Fixed config synchronization
    ]]

    local star = [[
       .-.                         .-.                    |     '      .        
      (   )    '        +         (   )                  -o-               o    
       `-'     .-.                 `-'             '      |        +          + 
              ( (    ~~+                      .               o               + 
        .      `-'.              +    .         o     * .            .          
              '                                                                 
     '       .-.    *                      /                               .  ' 
              ) )       '    noctua.sbs   /                           | o      
  '.         '-´       '                 *  version: {ver}            -+-       
 +                  *   ' .                    .-.       '            |        
         ' o                    |     . .       ) )                   +       
       .         '             -o- .         o '-´   / +        .               
       *                        |       .           /      +                    
                                                   *       '                    
                '                              .-.           .                  
               '           *                .   ) )                             
          o '     *                            '-´                      .       
   '       +      .           '               +                      +        ''
           .                                                  +'      .       . 
 +          +                         ' o           '               *     *     
    
{changelog}]]

    local function log_val(text)
        client.color_log(255, 255, 255, text .. "\0")
    end

    local function log_accent(text)
        local r, g, b = unpack(interface.visuals.accent.color.value)
        client.color_log(r, g, b, text .. "\0")
    end

    art.display = function()
        local target1 = "noctua.sbs"
        local target2 = "{ver}"
        local target3 = "{changelog}"
        local s1, e1 = star:find(target1, 1, true)
        local s2, e2 = star:find(target2, (e1 or 0) + 1, true)
        local s3, e3 = star:find(target3, (e2 or 0) + 1, true)

        if not s1 or not s2 or not s3 then
            log_val(star .. "\n")
            return
        end

        log_val(star:sub(1, s1 - 1))
        log_accent(star:sub(s1, e1))
        log_val(star:sub(e1 + 1, s2 - 1))
        log_accent(tostring(_version))
        log_val(star:sub(e2 + 1, s3 - 1))
        log_val(changelog)
        log_val(star:sub(e3 + 1) .. "\n")
    end

    art.setup = function()
        -- client.exec('clear')
        art.display()
    end

    art.setup()
end
--@endregion

--@region: menu info
menu_info = {} do
    menu_info.alpha = 0

    menu_info.paint = function()
        local is_open = ui.is_menu_open()
        local target_alpha = is_open and 255 or 0
        
        menu_info.alpha = mathematic.lerp(menu_info.alpha, target_alpha, globals.frametime() * 20)

        if menu_info.alpha < 1 then 
            return 
        end

        local x, y = ui.menu_position()
        local w, h = ui.menu_size()
        local r, g, b = unpack(interface.visuals.accent.color.value)
        local up = 18
        
        local realtime = globals.realtime()
        local pulse = (math.sin(realtime * 1.8) + 1) / 2 
        local star_alpha = menu_info.alpha * (0.4 + 0.6 * pulse)

        renderer.text(x, y - up, r, g, b, star_alpha, 'l', 0, "✦ ")
        renderer.text(x + renderer.measure_text(0, "✦ "), y - up, r, g, b, menu_info.alpha, 'lb', 0, "noctua")
        renderer.text(x + w, y - up, 255, 255, 255, menu_info.alpha, 'r', 0, _nickname or "user")
    end

    menu_info.setup = function()
        client.set_event_callback('paint_ui', menu_info.paint)
        client.set_event_callback('paint_ui', function()
            local shimmer_text = table.concat(colors.shimmer(
                globals.realtime() * 2,
                "winter mode",
                157, 230, 254, 255,
                255, 255, 255, 255
            ))
            interface.home.winter_label:set(shimmer_text)
        end)
    end

    menu_info.setup()
end
--@endregion

--@region: on load
logging:push("nice to see you at " .. _name .. " " .. _version .. " (" .. (_nickname or "user") .. ")")
client.exec("play items/flashlight1.wav")
confetti:push(0, false)
--@endregion

-- ^~^!
