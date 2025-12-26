--[[

    noctua.sbs (side by side)
    author: t.me/ovhbypass
    note: бонус за безумный код

--]]

--@region: information
local _name = 'noctua'
local _version = '1.4c'
local _nickname = nil
_G.noctua_runtime = _G.noctua_runtime or {}

local function update_nickname()
    local local_player = entity.get_local_player()
    if local_player then
        local name = entity.get_player_name(local_player)
        if name and name ~= "" then
            _nickname = name
        end
    end
end

update_nickname()

client.set_event_callback('player_spawn', function(e)
    local me = entity.get_local_player()
    if me and client.userid_to_entindex(e.userid) == me then
        update_nickname()
    end
end)
--@endregion

--@region: news
local news_container = panorama.loadstring([[
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

news_container.create(layout)

client.set_event_callback('shutdown', function()
    news_container.destroy()
end)
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
local function try_require(moduleName, errMsg)
    local ok, mod = pcall(require, moduleName)
    if not ok then
        error(errMsg, 2)
    end
    return mod
end

local dependencies = {
    { name = "pui",            path = "gamesense/pui",            msg = "Failed to require pui" },
    { name = "ffi",            path = "ffi",                      msg = "Failed to require ffi" },
    { name = "bit",            path = "bit",                      msg = "Failed to require bit" },
    { name = "vector",         path = "vector",                   msg = "Failed to require vector" },
    { name = "color",          path = "gamesense/color",          msg = "Failed to require color" },
    { name = "http",           path = "gamesense/http",           msg = "Failed to require http" },
    { name = "antiaim_funcs",  path = "gamesense/antiaim_funcs",  msg = "Failed to require antiaim_funcs" },
    { name = "clipboard",      path = "gamesense/clipboard",      msg = "Failed to require clipboard" },
    { name = "images",         path = "gamesense/images",      msg = "Failed to require images" },
}

local modules = {}

for _, dep in ipairs(dependencies) do
    modules[dep.name] = try_require(dep.path, dep.msg)
end

local pui = modules.pui
local ffi = modules.ffi
local bit = modules.bit
local vector = modules.vector
local color = modules.color
local http = modules.http
local antiaim_funcs = modules.antiaim_funcs
local clipboard = modules.clipboard
local images = modules.images

-- optional dependencies
local ok_weapons, weapons = pcall(require, 'gamesense/csgo_weapons')
local ok_base64, base64 = pcall(require, 'gamesense/base64')
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

    viewmodel.setup = function()
        if not (interface.visuals.enabled_visuals:get() and interface.visuals.viewmodel:get()) then return end
        
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
end)

client.set_event_callback('override_view', function(ctx)
    spawn_zoom.setup(ctx)
    zoom_animation.setup(ctx)
end)
--@endregion

--@region: interface
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
 
    interface.search = interface.header.general:combobox(pui.macros.title .. ' - '.. _version, 'home', 'aimbot', 'antiaim', 'visuals', 'utility', 'models', 'config', 'other')

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
        show_updates = interface.header.general:checkbox("show what's new"),
        winter_label = interface.header.other:label('\a89cff0ff❄ winter'),
        menu_snow = interface.header.other:checkbox('menu snow'),
        world_snow = interface.header.other:checkbox('world snow')
    }

    interface.home.show_updates:override(true)
    interface.home.show_updates:set_enabled(false)
    interface.home.menu_snow:override(true)

    interface.aimbot = {
        enabled_aimbot = interface.header.general:checkbox('enable aimbot'),
        enabled_resolver_tweaks = interface.header.general:checkbox('\aa5ab55ffresolver tweaks'),
        resolver_mode = interface.header.general:combobox('mode', 'autopilot', 'experimental'),
        smart_safety = interface.header.general:checkbox('smart safety'),
        silent_shot = interface.header.general:checkbox('silent shot'),
        force_recharge = interface.header.general:checkbox('allow force recharge'),
        noscope_distance = interface.header.general:checkbox('noscope distance'),
        noscope_weapons = interface.header.general:multiselect('weapons', 'autosnipers', 'scout', 'awp'),
        noscope_distance_autosnipers = interface.header.general:slider('autosnipers distance', 1, 800, 450, true, ''),
        noscope_distance_scout = interface.header.general:slider('scout distance', 1, 800, 450, true, ''),
        noscope_distance_awp = interface.header.general:slider('awp distance', 1, 800, 450, true, ''),
        quick_stop = interface.header.general:checkbox('air stop', 0x00),
        dump_resolver_data = interface.header.other:button('dump resolver data')
    }

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
        enemy_ping_warn = interface.header.other:checkbox('enemy ping warning'),
        enemy_ping_minimum = interface.header.other:slider('minimum latency to show', 10, 100, 80, true, 'ms'),
        window = interface.header.general:checkbox('debug window'),
        window_style = interface.header.general:combobox('style', 'old', 'modern'),
        watermark = interface.header.general:checkbox('watermark'),
        watermark_show = interface.header.general:multiselect('show', 'script', 'player', 'time', 'ping'),
        -- shared = interface.header.general:checkbox('shared identity (wip)'),
        logging = interface.header.general:checkbox('logging'),
        logging_options = interface.header.general:multiselect('options', 'console', 'screen'),
        logging_options_console = interface.header.general:multiselect('console', 'fire', 'hit', 'miss', 'buy', 'aimbot', 'anti aim'),
        logging_options_screen = interface.header.general:multiselect('screen', 'fire', 'hit', 'miss', 'aimbot', 'anti aim'),
        logging_slider = interface.header.general:slider('slider', 40, 450, 240),
        aspect_ratio = interface.header.fake_lag:checkbox('override aspect ratio'),
        aspect_ratio_slider = interface.header.fake_lag:slider('value', 0, aspect_ratio.steps, aspect_ratio.steps/2, true, '', 1, aspect_ratio.ratio_table),
        thirdperson = interface.header.fake_lag:checkbox('override thirdperson distance'),
        thirdperson_slider = interface.header.fake_lag:slider('distance', 30, 150, 50, true, ''),
        viewmodel = interface.header.fake_lag:checkbox('override viewmodel'),
        viewmodel_fov = interface.header.fake_lag:slider('fov', -90, 90, cvar.viewmodel_fov:get_float()),
        viewmodel_x = interface.header.fake_lag:slider('x', -1000, 1000, cvar.viewmodel_offset_x:get_float(), true, '', 0.01),
        viewmodel_y = interface.header.fake_lag:slider('y', -1000, 1000, cvar.viewmodel_offset_y:get_float(), true, '', 0.01),
        viewmodel_z = interface.header.fake_lag:slider('z', -1000, 1000, cvar.viewmodel_offset_z:get_float(), true, '', 0.01),
        stickman = interface.header.other:checkbox('stickman', {255, 255, 255, 140}),
        zoom_animation = interface.header.other:checkbox('zoom animation'),
        zoom_animation_speed = interface.header.other:slider('speed', 10, 100, 50, true, '%'),
        zoom_animation_value = interface.header.other:slider('strength', 1, 100, 2, true, '%'),
        spawn_zoom = interface.header.other:checkbox('spawn zoom')
    }

    interface.models = {
        enabled_models = interface.header.general:checkbox('enable model changer'),
        list = interface.header.general:listbox('models', 350),
        new_model_weapon = interface.header.general:combobox('weapon', {"ak47", "aug", "famas", "galilar", "m4a1", "m4a1_silencer", "sg556", "awp", "ssg08", "scar20", "g3sg1", "m249", "negev", "nova", "xm1014", "mag7", "sawedoff", "mac10", "mp7", "mp9", "mp5sd", "ump45", "p90", "bizon", "glock", "elite", "p250", "tec9", "cz75a", "deagle", "revolver", "usp_silencer", "hkp2000", "fiveseven", "flashbang", "hegrenade", "smokegrenade", "molotov", "decoy", "incgrenade", "taser", "knife"}),
        new_model_button = interface.header.general:button('import from clipboard'),
        model_enabled = interface.header.general:checkbox('enabled'),
        delete_model_button = interface.header.general:button('delete model'),
        tip = interface.header.fake_lag:label('example: models/weapons/weapon_name.mdl'),
        tip2 = interface.header.fake_lag:label('you can configure models in noctua-models.json...'),
        tip3 = interface.header.fake_lag:label('...from game directory'),
    }

    interface.config = {
        list = interface.header.general:listbox('configs', 300),
        name = (interface.header.general.textbox and interface.header.general:textbox('config name')) or interface.header.general:combobox('config name', ''),
        create_button = interface.header.general:button('create'),
        load_on_startup = interface.header.general:checkbox('load on startup'),
        load_button = interface.header.general:button('load'),
        load_aa_button = interface.header.general:button('load aa'),
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
        party_mode = interface.header.other:checkbox('party mode'),
        animation_breakers = interface.header.other:multiselect('animation breakers', 'zero on land', 'earthquake', 'sliding slow motion', 'sliding crouch', 'on ground', 'on air', 'quick peek legs', 'keus scale', 'body lean'),
        on_ground_options = interface.header.other:combobox('on ground', {'frozen', 'walking', 'jitter', 'sliding', 'star'}),
        on_air_options = interface.header.other:combobox('on air', {'frozen', 'walking', 'kinguru'}),
        body_lean_amount = interface.header.other:slider('body lean amount', 0, 100, 50, true, '%'),
        streamer_mode = interface.header.fake_lag:checkbox('streamer mode'),
        streamer_mode_select = interface.header.fake_lag:listbox('images', 200),
        streamer_mode_add = interface.header.fake_lag:button('add'),
        streamer_mode_delete = interface.header.fake_lag:button('\aff4444ffdelete')
    }

    interface.builder = {} do
        local e_statement = {"default","idle","run","air","airc","duck","duck move","slow","use","fakelag","on shot","freestand","manual","safe head"}
        local tooltips  = {delay = {[1] = "off"}, body = {[0] = "off"}}
        interface.condition = interface.header.general:combobox("condition", e_statement)
        if interface.condition.depend then
            interface.condition:depend({ interface.search, 'antiaim' })
        end
        for _, state in ipairs(e_statement) do
            interface.builder[state] = {}
            local this = interface.builder[state]
            if state == "use" then
                this.allow_use_aa = interface.header.general:checkbox('allow antiaim on use', false)
            end
            if state ~= "default" then
                this.enable = interface.header.general:checkbox('override ' .. state, false)
                if state == "use" and this.enable.depend then
                    this.enable:depend({ this.allow_use_aa, true })
                end
            end
            this.base = interface.header.general:combobox("base", {"local view", "at targets"})
            this.add = interface.header.general:slider("yaw", -180, 180, 0, true, "°", 1)
            this.expand = interface.header.general:combobox("expand" ,{ "off", "left/right","x-way","spin"})
            this.epd_left = interface.header.general:slider("\n", -180, 180, 0, true, "°", 1):depend({this.expand,"x-way",true},{this.expand,"off",true})
            this.epd_right = interface.header.general:slider("\n", -180, 180, 0, true, "°", 1):depend({this.expand,"x-way",true},{this.expand,"off",true})
            this.delay = interface.header.general:slider("delay ", 1, 10, 0, true, "t", 1, tooltips.delay):depend({this.expand,"left/right"})
            this.speed = interface.header.general:slider("speed ", 1, 64, 1, true, "t", 1):depend({this.expand,"spin"})
            this.ways_manual = interface.header.general:checkbox('ways manual', false):depend({ this.expand, "x-way" })
            this.x_way = interface.header.general:slider("total ", 3, 7, 3, true, "w"):depend({ this.expand, "x-way" })
            this.x_waylabel = interface.header.general:label("way"):depend({this.expand,"x-way"}, {this.ways_manual,true})
            this.x_way:set_callback(function (ctx) this.x_waylabel:set("way " .. ctx.value) end, true)
            this.epd_way = interface.header.general:slider("way ", -180, 180, 0, true, "°", 1):depend({this.expand,"x-way"}, {this.ways_manual,false})
            for w = 1, 7 do
                this[w] = interface.header.general:slider(tostring(w), -180, 180, 0, true, "°", 1, {[0] = "R"}):depend({this.expand, "x-way"}, {this.ways_manual, true}, {this.x_way, w, 7})
            end
            this.jitter = interface.header.general:combobox("modifier",{ "off", "offset", "center", "random"})
            this.jitter_add = interface.header.general:slider("\n", -180, 180, 0, true,"°"):depend({this.jitter,"off",true})
            this.yaw_randomize = interface.header.general:slider("randomization", 0, 100, 0, 0, '%', 1, {[0] = "off"})
            this.by_mode = interface.header.general:combobox("body ",{ "off", "static", "opposite", "jitter" })
            this.by_num = interface.header.general:slider("\n", -180, 180, 0, true, "°", 1, tooltips.body):depend({ this.by_mode, "off", true }, { this.by_mode, "opposite", true })
            this.break_lc = interface.header.general:checkbox("\aa5ab55ffforce break lc")
            this.defensive = interface.header.general:checkbox("defensive")
            -- if this.defensive and this.defensive.depend then
            --     this.defensive:depend({ this.break_lc, true })
            -- end
            this.def_pitch = interface.header.general:combobox("pitch defensive ",{ "default", "up", "zero", "up switch","down switch", "random static","random","custom"}):depend({this.defensive,true})
            this.def_pitch_num = interface.header.general:slider("\n", -89, 89, 0, true, "°", 1):depend({this.defensive,true},{this.def_pitch,"custom"})
            this.def_yaw = interface.header.general:combobox("yaw defensive ",{ "default", "forward", "sideways", "delayed","spin","random", "random static","flick exploit","custom"}):depend({this.defensive,true})
            this.def_left = interface.header.general:slider("left yaw ", -180, 180, 0, true, "°", 1):depend({this.defensive,true},{this.def_yaw, function()
                return  this.def_yaw:get() == "delayed" or  this.def_yaw:get() == "spin" or  this.def_yaw:get() == "random" or  this.def_yaw:get() == "random static"
            end})
            this.def_right = interface.header.general:slider("right yaw ", -180, 180, 0, true, "°", 1):depend({this.defensive,true},{this.def_yaw, function()
                return  this.def_yaw:get() == "delayed" or  this.def_yaw:get() == "spin" or  this.def_yaw:get() == "random" or  this.def_yaw:get() == "random static"
            end})
            this.def_speed = interface.header.general:slider("speed yaw ", 1, 64, 1, true, "t", 1):depend({this.defensive,true},{this.def_yaw, "spin" })
            this.def_yaw_num = interface.header.general:slider("\n", -180, 180, 0, true, "°", 1):depend({this.defensive,true},{this.def_yaw,"custom"})
            this.def_body = interface.header.general:combobox("body defensive ",{ "default", "auto", "jitter"}):depend({this.defensive,true})
            for key, v in pairs(this) do
                if type(v) == 'table' and v.depend then
                    local arr = { { interface.search, 'antiaim' }, { interface.condition, state } }
                    if key ~= "enable" and state ~= "default" then
                        if not (state == "use" and key == "allow_use_aa") then
                            arr[#arr+1] = { this.enable, true }
                        end
                    end
                    v:depend(table.unpack(arr))
                end
            end
        end
    end

    interface.builder.extensions = {} do
        local extensions = interface.builder.extensions
        extensions.anti_backstab = interface.header.fake_lag:checkbox("avoid backstab")
        -- extensions.fd_edge = interface.header.fake_lag:checkbox("fakeduck edge")
        extensions.ladder = interface.header.fake_lag:checkbox("fast ladder")
        extensions.anti_bruteforce = interface.header.fake_lag:checkbox("anti-bruteforce")
        extensions.anti_bruteforce_type = interface.header.fake_lag:combobox("anti bruteforce type", "increase", "decrease")
        extensions.defensive = interface.header.fake_lag:multiselect("defensive", {"on shot", "flashed", "damage received", "reloading", "weapon switch"})
        extensions.safe_head = interface.header.fake_lag:multiselect("safe head", {"height distance", "high distance", "knife", "zeus"})
        extensions.warmup_aa = interface.header.fake_lag:multiselect("warmup aa", {"warmup", "round end"})
        extensions.automatic_osaa = interface.header.fake_lag:checkbox("automatic osaa")
        extensions.automatic_osaa_disablers = interface.header.fake_lag:multiselect("automatic osaa disablers", {"autosnipers"})
        
        extensions.edge_yaw = interface.header.other:hotkey("edge yaw")
        extensions.freestanding = interface.header.other:hotkey("freestanding")
        extensions.dis_fs = interface.header.other:multiselect("allow freestand on", {"idle", "run", "air", "airc", "duck", "duck move", "slow"})
        extensions.manual_aa = interface.header.other:checkbox("manual antiaim")
        
        for key, v in pairs(extensions) do
            if (key == "anti_backstab" or key == "ladder" or key == "anti_bruteforce" or key == "defensive" or key == "safe_head" or key == "warmup_aa" or key == "automatic_osaa") then
                v:depend({ interface.search, 'antiaim' })
            end
        end

        extensions.edge_yaw:depend({ interface.search, 'antiaim' })
        extensions.freestanding:depend({ interface.search, 'antiaim' })
        extensions.manual_aa:depend({ interface.search, 'antiaim' })
        extensions.anti_bruteforce_type:depend({ interface.search, 'antiaim' }, { extensions.anti_bruteforce, true })
        extensions.dis_fs:depend({ interface.search, 'antiaim' }, { extensions.freestanding, true })
        extensions.automatic_osaa_disablers:depend({ interface.search, 'antiaim' }, { extensions.automatic_osaa, true })
        
        extensions.manual_aa_hotkey = extensions.manual_aa_hotkey or {}
        extensions.manual_aa_hotkey.manual_left = interface.header.other:hotkey("manual left")
        extensions.manual_aa_hotkey.manual_right = interface.header.other:hotkey("manual right")
        extensions.manual_aa_hotkey.manual_forward = interface.header.other:hotkey("manual forward")
        extensions.manual_aa_hotkey.manual_back = interface.header.other:hotkey("manual backward")
        for _, v in pairs(extensions.manual_aa_hotkey) do
            v:depend({ interface.search, 'antiaim' }, { extensions.manual_aa, true })
        end
    end

    -- interface.utility.item_anti_crash:override(true) -- uncomment later

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

    interface.setup = function()
        local selection = interface.search:get()
        local groups = {
            home = interface.home,
            aimbot = interface.aimbot,
            visuals = interface.visuals,
            builder = interface.builder,
            models = interface.models,
            utility = interface.utility,
            config = interface.config
        }

        local visibility_config = {
            home = {
                groups_to_show = { groups.home },
                groups_to_hide = { groups.aimbot, groups.visuals, groups.builder, groups.models, groups.utility, groups.config }
            },
            aimbot = {
                groups_to_show = { groups.aimbot },
                groups_to_hide = { groups.home, groups.visuals, groups.builder, groups.models, groups.utility, groups.config },
                element_visibility_logic = function(element, path)
                    local key = path[#path]
                    local enabled = (interface.aimbot.enabled_aimbot:get() == true)
                    if key == 'enabled_aimbot' then
                        element:set_visible(true)
                    elseif key == 'resolver_mode' then
                        element:set_visible(enabled and interface.aimbot.enabled_resolver_tweaks:get())
                    elseif key == 'smart_safety' then
                        element:set_visible(enabled and interface.aimbot.enabled_resolver_tweaks:get())
                    elseif key == 'noscope_distance' then
                        element:set_visible(enabled)
                    elseif key == 'noscope_weapons' then
                        element:set_visible(enabled and interface.aimbot.noscope_distance:get())
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
                    elseif key == 'dump_resolver_data' then
                        element:set_visible(enabled and interface.aimbot.enabled_resolver_tweaks:get())
                    else
                        element:set_visible(enabled)
                    end
                end
            },
            visuals = {
                groups_to_show = { groups.visuals },
                groups_to_hide = { groups.home, groups.aimbot, groups.builder, groups.models, groups.utility, groups.config },
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

                    if key == 'crosshair_style' then
                        element:set_visible(interface.visuals.crosshair_indicators:get())
                        return
                    end

                    if key == 'watermark_show' then
                        element:set_visible(interface.visuals.watermark:get())
                        return
                    end

                    if key == 'window_style' then
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

                    element:set_visible(true)
                end,
                post_visibility_logic = function()
                    local visuals_enabled = interface.visuals.enabled_visuals:get()
                    
                    if interface.visuals.logging then
                        local logging_enabled = visuals_enabled and interface.visuals.logging:get() == true
                        interface.visuals.logging_options:set_visible(logging_enabled)
                        interface.visuals.logging_slider:set_visible(false)
                        if logging_enabled then
                            local opts = interface.visuals.logging_options:get()
                            local console_enabled = false
                            local screen_enabled = false
                            if type(opts) == "table" then
                                for _, v in ipairs(opts) do
                                    if v == "console" then
                                        console_enabled = true
                                    end
                                    if v == "screen" then
                                        screen_enabled = true
                                    end
                                end
                            elseif type(opts) == "string" then
                                if opts == "console" then console_enabled = true end
                                if opts == "screen" then screen_enabled = true end
                            end
                            interface.visuals.logging_options_console:set_visible(console_enabled)
                            interface.visuals.logging_options_screen:set_visible(screen_enabled)
                        else
                            interface.visuals.logging_options_console:set_visible(false)
                            interface.visuals.logging_options_screen:set_visible(false)
                        end
                    end

                    if interface.visuals.aspect_ratio then
                        local show_aspect = visuals_enabled
                        interface.visuals.aspect_ratio:set_visible(show_aspect)
                        interface.visuals.aspect_ratio_slider:set_visible(show_aspect and interface.visuals.aspect_ratio:get())
                    end

                    if interface.visuals.thirdperson then
                        local show_thirdperson = visuals_enabled
                        interface.visuals.thirdperson:set_visible(show_thirdperson)
                        interface.visuals.thirdperson_slider:set_visible(show_thirdperson and interface.visuals.thirdperson:get())
                    end

                    if interface.visuals.viewmodel then
                        local show_viewmodel = visuals_enabled
                        interface.visuals.viewmodel:set_visible(show_viewmodel)
                        local show_viewmodel_settings = show_viewmodel and interface.visuals.viewmodel:get()
                        interface.visuals.viewmodel_fov:set_visible(show_viewmodel_settings)
                        interface.visuals.viewmodel_x:set_visible(show_viewmodel_settings)
                        interface.visuals.viewmodel_y:set_visible(show_viewmodel_settings)
                        interface.visuals.viewmodel_z:set_visible(show_viewmodel_settings)
                    end

                    if interface.visuals.stickman then
                        interface.visuals.stickman:set_visible(visuals_enabled)
                    end

                    if interface.visuals.zoom_animation then
                        local show_zoom = visuals_enabled
                        interface.visuals.zoom_animation:set_visible(show_zoom)
                        local show_zoom_settings = show_zoom and interface.visuals.zoom_animation:get()
                        interface.visuals.zoom_animation_speed:set_visible(show_zoom_settings)
                        interface.visuals.zoom_animation_value:set_visible(show_zoom_settings)
                    end

                    if interface.visuals.spawn_zoom then
                        interface.visuals.spawn_zoom:set_visible(visuals_enabled)
                    end
                end
            },
            models = {
                groups_to_show = { groups.models },
                groups_to_hide = { groups.home, groups.aimbot, groups.visuals, groups.builder, groups.utility, groups.config }
            },
            utility = {
                groups_to_show = { groups.utility },
                groups_to_hide = { groups.home, groups.aimbot, groups.visuals, groups.builder, groups.models, groups.config },
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

                        if key == "animation_breakers_leg" then
                            local breakers_enabled = interface.utility.animation_breakers:get() or {}
                            element:set_visible(utils.contains(breakers_enabled, "modify legs"))
                            return
                        end

                        if key == "animation_breakers_leg_slider" then
                            local breakers_enabled = interface.utility.animation_breakers:get() or {}
                            element:set_visible(utils.contains(breakers_enabled, "modify legs") and interface.utility.animation_breakers_leg:get() == "jitter")
                            return
                        end

                        if key == "animation_breakers_static_legs_air" then
                            local breakers_enabled = interface.utility.animation_breakers:get() or {}
                            element:set_visible(utils.contains(breakers_enabled, "modify legs"))
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
                groups_to_hide = { groups.home, groups.aimbot, groups.visuals, groups.builder, groups.models, groups.utility },
                element_visibility_logic = function(element, path)
                    element:set_visible(true)
                end,
                post_visibility_logic = function()
                    -- we'll handle this later
                end
            },
            default = {
                groups_to_hide = { groups.home, groups.aimbot, groups.visuals, groups.builder, groups.models, groups.utility, groups.config }
            }
        }

        if selection == 'antiaim' then
            pui.traverse(interface.home, function(element) element:set_visible(false) end)
            pui.traverse(interface.aimbot, function(element) element:set_visible(false) end)
            pui.traverse(interface.visuals, function(element) element:set_visible(false) end)
            pui.traverse(interface.models, function(element) element:set_visible(false) end)
            pui.traverse(interface.utility, function(element) element:set_visible(false) end)
            pui.traverse(interface.config, function(element) element:set_visible(false) end)

            if type(naac) == 'function' then
                naac('')
            end

            return
        end

        local config = visibility_config[selection] or visibility_config.default

        if config.groups_to_show then
            for _, group in pairs(config.groups_to_show) do
                if group then
                    pui.traverse(group, function(element, path)
                        if config.element_visibility_logic then
                            config.element_visibility_logic(element, path)
                        else
                            element:set_visible(true)
                        end
                    end)
                end
            end
        end

        if config.groups_to_hide then
            for _, group in pairs(config.groups_to_hide) do
                if group then
                    pui.traverse(group, function(element, path)
                        element:set_visible(false)
                    end)
                end
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
local function argLog(fmt, ...)    
    local white = {255, 255, 255}
    local gray  = {212, 212, 212}
    local args  = { ... }
    local segments = {}
    local pos = 1
    local arg_index = 1

    local r, g, b = unpack(interface.visuals.accent.color.value)
    
    client.color_log(r, g, b, "noctua · \0")

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
            enabled = ui.reference('aa', 'anti-aimbot angles', 'enabled'),
            pitch = { ui.reference('aa', 'anti-aimbot angles', 'pitch') },
            roll = { ui.reference('aa', 'anti-aimbot angles', 'roll') },
            yaw_base = ui.reference('aa', 'anti-aimbot angles', 'yaw base'),
            yaw = { ui.reference('aa', 'anti-aimbot angles', 'yaw') },
            freestanding_body_yaw = ui.reference('aa', 'anti-aimbot angles', 'freestanding body yaw'),
            edge_yaw = ui.reference('aa', 'anti-aimbot angles', 'edge yaw'),
            yaw_jitter = { ui.reference('aa', 'anti-aimbot angles', 'yaw jitter') },
            body_yaw = { ui.reference('aa', 'anti-aimbot angles', 'body yaw') },
            freestanding = { ui.reference('aa', 'anti-aimbot angles', 'freestanding') }
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
    player_list.reset = {
        ForceBodyYaw = {},
        ForceBodyYawCheckbox = {},
        CorrectionActive = {},
        ForcePitch = {},
        ForcePitchCheckbox = {},
        SafePointOverrideState = {},
        SafePointOverrideValue = {}
    }
    
    player_list.values = {
        ForceBodyYaw = {},
        ForceBodyYawCheckbox = {},
        CorrectionActive = {},
        ForcePitch = {},
        ForcePitchCheckbox = {},
        SafePointOverrideState = {},
        SafePointOverrideValue = {}
    }
    
    player_list.ref = {
        selected_player = ui.reference('PLAYERS', 'Players', 'Player list', false)
    }
    
    player_list.GetPlayer = function(self)
        return ui.get(self.ref.selected_player)
    end
    
    player_list.GetCorrection = function(self, ent)
        return plist.get(ent, 'Correction active')
    end
    
    player_list.SetCorrection = function(self, ent, val)
        return plist.set(ent, 'Correction active', val)
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
    
    player_list.GetSafePointOverrideState = function(self, ent)
        if not ent then return false end
        return plist.get(ent, 'Override safe point')
    end
    
    player_list.SetSafePointOverrideState = function(self, ent, val)
        if not ent then return end
        plist.set(ent, 'Override safe point', val)
    end
    
    player_list.GetSafePointOverrideValue = function(self, ent)
        if not ent then return "Off" end
        return plist.get(ent, 'Override safe point value') or "Off"
    end
    
    player_list.SetSafePointOverrideValue = function(self, ent, val)
        if not ent then return end
        plist.set(ent, 'Override safe point value', val)
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

    player.distance3d = function(x1, y1, z1, x2, y2, z2)
        return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
    end
end
--@endregion

--@region: utils
local ui_references = {
    weapon_type = ui.reference('rage', 'weapon type', 'weapon type'),
    enabled = { ui.reference('rage', 'aimbot', 'enabled') },
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

    utils.contains = function(tbl, val)
        for _, item in ipairs(tbl) do
            if item == val then
                return true
            end
        end
        return false
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

    utils.get_player_kd = function(player)
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

            if client.key_state(69) then
                return "use"
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
end
--@endregion

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
    resolver.state_cache = {}
    resolver.layer_cache = {}
    resolver.precision   = {}
    resolver.bruteforce  = {}
    
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
    
    function resolver:on_aim_miss(e)
        if not e or not e.target then return end
        if not interface or not interface.aimbot then return end
        if not interface.aimbot.enabled_aimbot:get() or not interface.aimbot.enabled_resolver_tweaks:get() then return end
        if interface.aimbot.resolver_mode:get() ~= 'experimental' then return end

        local idx = e.target
        if not idx or not entity.is_enemy(idx) then return end

        local health = entity.get_prop(idx, "m_iHealth") or 0
        if health <= 0 then return end

        local reason = tostring(e.reason or '')
        if reason == 'spread' or reason == 'prediction error' then
            return
        end

        self.bruteforce[idx] = self.bruteforce[idx] or {}
        local data = self.bruteforce[idx]

        data.misses = (data.misses or 0) + 1
        data.hits = 0
        data.locked_yaw = nil
        data.lock_expire = nil

        local max_stage = 5
        local stage = (data.stage or 1) + 1
        if stage > max_stage then
            stage = 1
        end

        data.stage = stage
        data.last_miss_time = globals.curtime()

        self.bruteforce[idx] = data
    end

    function resolver:on_aim_hit(e)
        if not e or not e.target then return end
        if not interface or not interface.aimbot then return end
        if not interface.aimbot.enabled_aimbot:get() or not interface.aimbot.enabled_resolver_tweaks:get() then return end
        if interface.aimbot.resolver_mode:get() ~= 'experimental' then return end

        local idx = e.target
        if not idx or not entity.is_enemy(idx) then return end

        self.bruteforce[idx] = self.bruteforce[idx] or {}
        local data = self.bruteforce[idx]

        data.hits = (data.hits or 0) + 1
        data.misses = 0
        data.stage = 1

        local yaw = self.cache[idx]
        if type(yaw) == 'number' then
            local now = globals.curtime()
            local extra = math.min((data.hits or 0) * 0.5, 3)
            data.locked_yaw = yaw
            data.lock_expire = now + 1.5 + extra
        end

        self.bruteforce[idx] = data
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

        local layers = self.layers[idx] or {}
        local layer3 = layers[3]
        local layer6 = layers[6]
        local layer12 = layers[12]

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

        local max_desync = self.getMaxDesyncDelta(idx) or 1
        local base_desync = mathematic.clamp(max_desync * 58, 10, 58)

        local precision = self:compute_precision(animstate, velocity_2d, lby)
        self.precision[idx] = precision

        local vel_factor = math.exp(-velocity_2d / 160)
        local duck_amt = animstate.flDuckAmount or 0
        local duck_factor = 1 - duck_amt * duck_amt * 0.35
        local layer_activity = self:calculate_layer_delta(idx)
        local layer_factor = 1 - mathematic.clamp(layer_activity * 2.0, 0, 0.4)

        local amplitude = base_desync * vel_factor * duck_factor * layer_factor
        amplitude = amplitude * (0.75 + 0.5 * precision)
        amplitude = mathematic.clamp(amplitude, 18, 58)

        self.bruteforce[idx] = self.bruteforce[idx] or {}
        local bf = self.bruteforce[idx]

        if bf.last_state ~= enemy_state then
            bf.stage = 1
            bf.locked_yaw = nil
            bf.lock_expire = nil
            bf.last_state = enemy_state
        end

        bf.stage = bf.stage or 1
        local stage = bf.stage

        local candidates = {}
        candidates[1] = side * amplitude
        candidates[2] = -side * amplitude
        candidates[3] = side * amplitude * 0.5
        candidates[4] = -side * amplitude * 0.5
        candidates[5] = 0

        local max_stage = #candidates
        if stage < 1 or stage > max_stage then
            stage = 1
            bf.stage = stage
        end

        local yaw = candidates[stage]

        if bf.locked_yaw and bf.lock_expire and globals.curtime() < bf.lock_expire then
            yaw = bf.locked_yaw
        end

        yaw = mathematic.clamp(yaw, -58, 58)
        if yaw >= 0 then
            yaw = math.floor(yaw + 0.5)
        else
            yaw = math.ceil(yaw - 0.5)
        end

        self.bruteforce[idx] = bf
        self.cache[idx] = yaw

        self.history[idx] = self.history[idx] or {}
        table.insert(self.history[idx], yaw)
        if #self.history[idx] > 5 then
            table.remove(self.history[idx], 1)
        end

        player_list.SetForceBodyYawCheckbox(player_list, idx, true)
        player_list.SetBodyYaw(player_list, idx, yaw)

        local confidence = precision * (1 - (stage - 1) * 0.2)
        confidence = mathematic.clamp(confidence, 0.1, 1)
        self:updateSafety(idx, side, yaw, confidence)
    end

    resolver.updateSafety = function(self, idx, side, desync, precision)
        assert(idx, "resolver.updateSafety: Invalid parameters (idx is nil)")
        assert(side ~= nil and desync ~= nil, "resolver.updateSafety: Invalid parameters (side or desync is nil)")
        assert(side >= -1 and side <= 1, "resolver.updateSafety: Invalid 'side' value (" .. tostring(side) .. ")")

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

        walkToRun  = walkToRun or 0
        updateInc  = updateInc or 0
        velocityXY = velocityXY or 0
        state      = state or TRANSITION_RUN_TO_WALK

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

            resolver.cache[idx] = final_yaw
            player_list.SetForceBodyYawCheckbox(player_list, idx, true)
            player_list.SetBodyYaw(player_list, idx, final_yaw)
            resolver:updateSafety(idx, side, final_yaw, self.precision[idx])
        end
    end

    resolver.dump_data = function(self)
        local r, g, b = unpack(interface.visuals.accent.color.value)
        local white = {255, 255, 255}
        local gray = {150, 150, 150}
        local dark = {80, 80, 80}
        local green = {100, 255, 100}
        local any_data = false

        for idx = 1, 64 do
            local player_info = utils.get_player_info(idx)
            local has_data = self.bruteforce[idx] or self.cache[idx] or self.precision[idx]
            local is_enemy = entity.is_enemy(idx)
    
            if player_info and not player_info.__fakeplayer and (is_enemy or has_data) then
                any_data = true
                local name = ffi.string(player_info.__name)
    
                local status = ""
                if not entity.is_alive(idx) then status = " (DEAD)"
                elseif entity.is_dormant(idx) then status = " (DORMANT)" end
    
                client.color_log(r, g, b, " ▌ \0")
                client.color_log(white[1], white[2], white[3], name .. status)
                client.color_log(r, g, b, "    ├─ \0")
                client.color_log(r, g, b, "bruteforce data:")
    
                if self.bruteforce[idx] then
                    local bf = self.bruteforce[idx]

                    client.color_log(r, g, b, "    │   ├─ \0")
                    client.color_log(gray[1], gray[2], gray[3], "stats: \0")
                    client.color_log(white[1], white[2], white[3], string.format("hits: %d | misses: %d | stage: %d", bf.hits or 0, bf.misses or 0, bf.stage or 0))
    
                    client.color_log(r, g, b, "    │   └─ \0")
                    if bf.locked_yaw then
                        local time_left = math.max(0, (bf.lock_expire or 0) - globals.curtime())
                        client.color_log(gray[1], gray[2], gray[3], "status: \0")
                        client.color_log(green[1], green[2], green[3], string.format("LOCKED (%.1f°) for %.1fs", bf.locked_yaw, time_left))
                    else
                        client.color_log(gray[1], gray[2], gray[3], "status: \0")
                        client.color_log(dark[1], dark[2], dark[3], "searching...")
                    end
                else
                    client.color_log(r, g, b, "    │   └─ \0")
                    client.color_log(dark[1], dark[2], dark[3], "none")
                end

                client.color_log(r, g, b, "    └─ \0")
                client.color_log(r, g, b, "angle information:")

                local yaw = self.cache[idx]
                client.color_log(r, g, b, "        ├─ \0")
                client.color_log(gray[1], gray[2], gray[3], "calculated yaw: \0")
                if yaw then
                    client.color_log(white[1], white[2], white[3], string.format("%.2f°", yaw))
                else
                    client.color_log(dark[1], dark[2], dark[3], "none")
                end

                local prec = self.precision[idx]
                client.color_log(r, g, b, "        ├─ \0")
                client.color_log(gray[1], gray[2], gray[3], "precision: \0")
                if prec then
                    local prec_val = math.floor(prec * 100)
                    client.color_log(white[1], white[2], white[3], string.format("%d%%", prec_val))
                else
                    client.color_log(dark[1], dark[2], dark[3], "N/A")
                end

                client.color_log(r, g, b, "        └─ \0")
                client.color_log(gray[1], gray[2], gray[3], "yaw history: \0")
                
                if self.history[idx] and #self.history[idx] > 0 then
                    local h_str = ""
                    local hist = self.history[idx]
                    local start = math.max(1, #hist - 4)
                    for i = start, #hist do
                        h_str = h_str .. string.format("[%.0f] ", hist[i])
                    end
                    client.color_log(white[1], white[2], white[3], h_str)
                else
                    client.color_log(dark[1], dark[2], dark[3], "none")
                end
            end
        end
    
        if not any_data then
            argLog("waiting for data...")
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

--@region: automatic osaa
automatic_osaa = {} do
    automatic_osaa.state = false
    automatic_osaa.last = false
    automatic_osaa.dt_original = false

    local function is_holding_sniper(lp)
        local weapon = entity.get_player_weapon(lp)
        if not weapon then return false end

        local weap_class = entity.get_classname(weapon)
        return weap_class == "CWeaponSCAR20" or weap_class == "CWeaponG3SG1"
    end

    automatic_osaa.setup = function(self, cmd)
        if not interface.builder.extensions.automatic_osaa:get() then
            if self.state then
                ui.set(ui_references.double_tap[1], self.dt_original)
                ui.set(ui_references.on_shot_anti_aim[2], "Toggle")
                self.state = false
            end
            return
        end

        local local_player = entity.get_local_player()
        if not local_player or not entity.is_alive(local_player) then return end

        if not self.state then
            self.dt_original = ui.get(ui_references.double_tap[1])
        end

        local dt_active = (self.state and self.dt_original or ui.get(ui_references.double_tap[1])) and ui.get(ui_references.double_tap[2])
        local state = utils.get_state()
        local is_idle_or_duck = state == 'duck' or state == 'duck move'
        local disabler_selected = interface.builder.extensions.automatic_osaa_disablers:get("autosnipers")
        local holding_sniper = is_holding_sniper(local_player)

        local is_disabled_by_weapon = disabler_selected and holding_sniper
        local should_activate = dt_active and is_idle_or_duck and not is_disabled_by_weapon

        if should_activate ~= self.last then
            self.last = should_activate
            
            if should_activate then
                ui.set(ui_references.double_tap[1], false)
                ui.set(ui_references.on_shot_anti_aim[2], "Always on")
                self.state = true
            else
                ui.set(ui_references.on_shot_anti_aim[2], "Toggle")
                ui.set(ui_references.double_tap[1], self.dt_original)
                self.state = false
            end
        end
    end

    automatic_osaa.shutdown = function()
        if automatic_osaa.state then
            ui.set(ui_references.double_tap[1], true)
            ui.set(ui_references.on_shot_anti_aim[2], "Toggle")
            automatic_osaa.state = false
        end
    end
end

client.set_event_callback('setup_command', function(cmd)
    automatic_osaa:setup(cmd)
end)

client.set_event_callback('shutdown', automatic_osaa.shutdown)
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

client.set_event_callback('paint', function()
    if (interface.aimbot.enabled_aimbot:get() and interface.aimbot.quick_stop:get() and interface.aimbot.quick_stop.hotkey:get()) then 
        renderer.indicator(214, 214, 214, 255, 'AS')
    end
end)

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
                local opts = interface.visuals.logging_options:get() or {}
                return utils.contains(opts, "screen")
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
                local opts = interface.visuals.logging_options:get() or {}
                return utils.contains(opts, "screen")
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
    visuals.window = function(self, base_x, base_y, align)
        self.windowAlpha = self.windowAlpha or 0

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

        local style = interface.visuals.window_style:get()
        local target = client.current_threat()
        local t_name = "none"
        local t_state = "none"
        local resolver_enabled = interface.aimbot.enabled_aimbot:get() and interface.aimbot.enabled_resolver_tweaks:get()
        self._yaw_cache = self._yaw_cache or { val = "none", for_target = nil, time = 0 }
        local t_yaw = "none"
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

        if style == 'modern' then
            local line_spacing = 13
            local y = base_y
            local indent = (align == 'l') and "   " or "" 
            local r, g, b = unpack(interface.visuals.accent.color.value)
            local align_flags = align .. "b"
            renderer.text(base_x, y, r, g, b, self.windowAlpha, align_flags, 0, _name)
            
            local name_width = select(1, renderer.measure_text(align_flags, _name))
            local ver_x = (align == 'l') and (base_x + name_width + 4) or 
                        (align == 'c' and (base_x + name_width/2 + 4) or base_x)

            if align ~= 'r' then
                renderer.text(ver_x, y, 255, 255, 255, self.windowAlpha, align, 0, _version)
            end
            y = y + line_spacing + 5

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

            renderer.text(base_x, y, 255, 255, 255, self.windowAlpha, align, 0, "anti-aim")
            y = y + line_spacing
            
            local aa_state = utils.get_state()
            if _G.noctua_runtime.use_active then aa_state = "use"
            elseif _G.noctua_runtime.manual_active then aa_state = "manual"
            elseif _G.noctua_runtime.safe_head_active then aa_state = "safe head" end

            renderer.text(base_x, y, 215, 215, 215, self.windowAlpha, align, 0, indent .. "- state: " .. aa_state)
            y = y + line_spacing + 6 

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
        else
            local lines = {
                _name .. " " .. _version,
                "target: " .. t_name,
                "target state: " .. t_state,
                "target yaw: " .. t_yaw
            }
            local a = align or "c"
            for i, line in ipairs(lines) do
                renderer.text(base_x, base_y + (i - 1) * 12, 255, 255, 255, self.windowAlpha, a, 1000, line)
            end
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
        self.scopeAlpha = mathematic.lerp(self.scopeAlpha or 255, scopeAlpha, fadeSpeedSetting)

        local targetAlpha = indicatorsEnabled and self.scopeAlpha or 0
        self.indicatorsAlpha = mathematic.lerp(self.indicatorsAlpha or 0, targetAlpha, fadeSpeedSetting)
        
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

        local style = (interface.visuals.crosshair_style and interface.visuals.crosshair_style:get()) or 'default'
        local isEmoji = (style == 'emoji')
        local align_text = ((style == 'center') or isEmoji) and 'c' or 'l'
        local align_title = ((style == 'center') or isEmoji) and 'cb' or 'lb'


        if not self.element_positions then
            self.element_positions = {
                noctua = base_y + 10,
                state = base_y + 20,
                rapid = base_y + 30,
                osaa = base_y + 40,
                dmg = base_y + 50
            }
            self.element_target_positions = {
                noctua = base_y + 10,
                state = base_y + 20,
                rapid = base_y + 30,
                osaa = base_y + 40,
                dmg = base_y + 50
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

        self.rapidAlpha = mathematic.lerp(self.rapidAlpha or 0, targetRapidAlpha, fadeSpeedSetting)
        self.reloadAlpha = mathematic.lerp(self.reloadAlpha or 0, targetReloadAlpha, fadeSpeedSetting)
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

        self.osaaAlpha = mathematic.lerp(self.osaaAlpha or 0, isOS and 255 or 0, fadeSpeedSetting)
        local smoothOsaaAlpha = (self.osaaAlpha / 255) * self.indicatorsAlpha

        if smoothOsaaAlpha >= 1 then
            self.element_target_positions.dmg = self.element_target_positions.osaa + 10
        elseif smoothRapidAlpha >= 1 or smoothReloadAlpha >= 1 then
            self.element_target_positions.dmg = self.element_target_positions.rapid + 10
        else
            self.element_target_positions.dmg = self.element_target_positions.state + 10
        end

        self.dmgAlpha = mathematic.lerp(self.dmgAlpha or 0, isDMG and 255 or 0, fadeSpeedSetting)
        local smoothDmgAlpha = (self.dmgAlpha / 255) * self.indicatorsAlpha

        self.element_positions.noctua = mathematic.lerp(self.element_positions.noctua, self.element_target_positions.noctua, fadeSpeedSetting)
        self.element_positions.state = mathematic.lerp(self.element_positions.state, self.element_target_positions.state, fadeSpeedSetting)
        self.element_positions.rapid = mathematic.lerp(self.element_positions.rapid, self.element_target_positions.rapid, fadeSpeedSetting)
        self.element_positions.osaa = mathematic.lerp(self.element_positions.osaa, self.element_target_positions.osaa, fadeSpeedSetting)
        self.element_positions.dmg = mathematic.lerp(self.element_positions.dmg, self.element_target_positions.dmg, fadeSpeedSetting)

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
        scope_pos = mathematic.lerp(scope_pos, target_scope, fadeSpeedSetting)
        self.scope_pos = scope_pos
        if (not is_scoped) and (scope_pos < 0.001) then
            self._unscoping_side = nil
        end

        local x_draw = base_x
        local x_title, x_state, x_rapid, x_waiting, x_osaa, x_dmg

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
    end

    visuals.damage_indicator = function(self, x, y)
        local me = entity.get_local_player()
        if not me or not entity.is_alive(me) then
            return
        end

        if not (interface.visuals.enabled_visuals:get() and interface.visuals.damage_indicator:get()) then
            return
        end

        local is_override = ui.get(ui_references.minimum_damage_override[1]) 
                            and ui.get(ui_references.minimum_damage_override[2])
        
        local damage_value = is_override 
                            and ui.get(ui_references.minimum_damage_override[3]) 
                            or ui.get(ui_references.minimum_damage)

        local frameTime = globals.frametime()
        local fadeSpeed = 10 * frameTime

        self.damage_indicator_state = self.damage_indicator_state or {}
        local dmg_state = self.damage_indicator_state

        dmg_state.current_value = dmg_state.current_value or damage_value
        dmg_state.current_value = mathematic.lerp(dmg_state.current_value, damage_value, frameTime * 30)

        local display_value = math.floor(dmg_state.current_value + 0.5)
        local text = ""
        if display_value > 100 then
            text = string.format("+%d", display_value - 100)
        else
            text = tostring(display_value)
        end

        local target_alpha = is_override and 255 or 80
        dmg_state.alpha = mathematic.lerp(dmg_state.alpha or 0, target_alpha, fadeSpeed)

        if dmg_state.alpha < 1 then
            return
        end

        local r, g, b, a = 255, 255, 255, dmg_state.alpha

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

--@region: world snow
local renderer_rectangle, renderer_world_to_screen, client_trace_line, entity_get_origin, math_random, math_floor, table_remove, table_insert = renderer.rectangle, renderer.world_to_screen, client.trace_line, entity.get_origin, math.random, math.floor, table.remove, table.insert
world_snow = {} do
    world_snow.particles = {}
    world_snow.max_particles = 600
    world_snow.spawn_radius = 1500
    world_snow.spawn_height = 800
    world_snow.wind = {x = 15, y = 10}
    world_snow.last_time = 0
    world_snow.check_index = 1

    world_snow.update = function(self)
        if not interface.home.world_snow:get() then return end

        local lp = entity.get_local_player()
        if not lp then return end

        local health = entity.get_prop(lp, "m_iHealth")
        if not health or health <= 0 then return end

        local current_time = globals.realtime()
        local dt = (current_time - self.last_time)
        if dt > 0.1 then dt = 0.01 end
        self.last_time = current_time

        local ox, oy, oz = entity_get_origin(lp)
        
        local p_count = #self.particles
        if p_count < self.max_particles then
            for i = 1, 4 do
                local tx = ox + math_random(-self.spawn_radius, self.spawn_radius)
                local ty = oy + math_random(-self.spawn_radius, self.spawn_radius)
                local tz = oz + self.spawn_height + math_random(-100, 300)
                
                local f_check = client_trace_line(-1, tx, ty, tz, tx, ty, tz + 50)
                if f_check > 0.5 then
                    local f_down = client_trace_line(-1, tx, ty, tz, tx, ty, tz - 2000)
                    local ground_z = tz - (2000 * f_down)

                    if ground_z < oz + 500 then
                        table_insert(self.particles, {
                            x = tx, y = ty, z = tz,
                            ground_z = ground_z,
                            vx = self.wind.x + math_random(-5, 5),
                            vy = self.wind.y + math_random(-5, 5),
                            vz = math_random(-160, -100),
                            size = math_random(10, 25) / 10,
                            alpha = 0,
                            visible = true,
                            dist_alpha = 255
                        })
                    end
                end
            end
        end

        if p_count > 0 then
            local ex, ey, ez = client.eye_position()
            local spawn_rad = self.spawn_radius
            for i = 1, 20 do
                self.check_index = self.check_index + 1
                if self.check_index > p_count then self.check_index = 1 end
                
                local p = self.particles[self.check_index]
                if p then
                    local fraction = client_trace_line(lp, ex, ey, ez, p.x, p.y, p.z)
                    p.visible = (fraction >= 0.9)
                    
                    local dx, dy, dz = p.x - ox, p.y - oy, p.z - oz
                    local d = (dx*dx + dy*dy + dz*dz)^0.5
                    p.dist_alpha = math.max(0, 255 - (d / spawn_rad) * 255)
                end
            end
        end

        for i = p_count, 1, -1 do
            local p = self.particles[i]
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            p.z = p.z + p.vz * dt
            if p.alpha < 200 then p.alpha = p.alpha + 150 * dt end

            local dx, dy = p.x - ox, p.y - oy
            if p.z <= p.ground_z or (dx*dx + dy*dy) > 5062500 then
                table_remove(self.particles, i)
            end
        end
    end

    world_snow.draw = function(self)
        if not interface.home.world_snow:get() then return end

        local lp = entity.get_local_player()
        if not lp then return end

        local health = entity.get_prop(lp, "m_iHealth")
        if not health or health <= 0 then return end
        
        local particles = self.particles
        for i=1, #particles do
            local p = particles[i]
            if p.visible and p.dist_alpha > 5 then
                local wx, wy = renderer_world_to_screen(p.x, p.y, p.z)
                if wx ~= nil then
                    local final_alpha = p.alpha
                    if p.dist_alpha < final_alpha then final_alpha = p.dist_alpha end
                    
                    renderer_rectangle(math_floor(wx), math_floor(wy), p.size, p.size, 255, 255, 255, math_floor(final_alpha))
                end
            end
        end
    end
end
--@endregion

interface.home.confetti:set_callback(function()
    confetti:push(0, false)
end)

client.set_event_callback('paint', function()
    stickman:setup()
    world_snow:update()
    world_snow:draw()
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

    logging.push = function(self, text, duration, is_preview)
        duration = duration or 3
        for i = 1, #self.animatedMessages do
            if not self.animatedMessages[i].targetY then
                self.animatedMessages[i].targetY = self.animatedMessages[i].currentY or 0
            end
            self.animatedMessages[i].targetY = self.animatedMessages[i].targetY + 15
        end
        
        table.insert(self.animatedMessages, 1, {
            text = text,
            duration = duration,
            startTime = globals.realtime(),
            currentY = 0,
            targetY = 0,
            removing = false,
            alpha = 0,
            offset = -10,
            preview = is_preview == true
        })

        if #self.animatedMessages > 10 then
            self.animatedMessages[#self.animatedMessages].removing = true
            self.animatedMessages[#self.animatedMessages].targetY = self.animatedMessages[#self.animatedMessages].targetY + 15
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
        local holdTime = 3
        local totalDuration = animTime + holdTime + animTime
        
        local function easeInOutQuad(t)
            return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t
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
                renderer.text(base_x, y, 255, 255, 255, alpha, "c", 0, msg.text)
            else
                if (elapsedTime >= totalDuration and not msg.removing) or msg.removing then
                    if not msg.removing then
                        msg.removing = true
                        msg.targetY = msg.targetY + 15
                    end
                    
                    if math.abs(msg.currentY - msg.targetY) < 0.1 then
                        table.remove(self.animatedMessages, i)
                        break
                    end
                else
                    local targetAlpha, targetOffset
                    if elapsedTime < animTime then
                        local progress = elapsedTime / animTime
                        local easedProgress = easeInOutQuad(progress)
                        targetAlpha = 255
                        targetOffset = 0
                    elseif elapsedTime < (animTime + holdTime) then
                        targetAlpha = 255
                        targetOffset = 0
                    else
                        local progress = (elapsedTime - animTime - holdTime) / animTime
                        local easedProgress = easeInOutQuad(progress)
                        targetAlpha = 255 * (1 - easedProgress)
                        targetOffset = 10 * easedProgress
                    end
            
                    msg.alpha = mathematic.lerp(msg.alpha, targetAlpha, globals.frametime() * 10)
                    msg.offset = mathematic.lerp(msg.offset, targetOffset, globals.frametime() * 10)
            
                    local alpha = msg.alpha or 255
                    local y = math.floor(base_y + msg.currentY + msg.offset + 0.5)
            
                    renderer.text(base_x, y, 255, 255, 255, alpha, "c", 0, msg.text)
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

        self.cache[e.target] = { 
            hitbox = hitbox, 
            damage = damage, 
            lagComp = lagComp,
            had_impact = false,
            got_hurt = false
        }

        if not interface.visuals.logging:get() then return end
        
        local logOptions = interface.visuals.logging_options:get()
        local consoleOptions = interface.visuals.logging_options_console:get()
        local screenOptions = interface.visuals.logging_options_screen:get()
        
        local doConsole = utils.contains(logOptions, "console") and utils.contains(consoleOptions, "fire")
        local doScreen = utils.contains(logOptions, "screen") and utils.contains(screenOptions, "fire")
        if not doConsole and not doScreen then return end

        local yawDisplay = (type(desiredYaw) == "number") and (desiredYaw.."°") or (tostring(desiredYaw).."°")
        local msg = string.format(
            "fired at %s's %s for %d / lc: %d - yaw: %s",
            playerName, hitbox, hitChance, lagComp, yawDisplay
        )

        if doConsole then 
            argLog("fired at %s's %s for %d / lc: %d - yaw: %s", playerName, hitbox, hitChance, lagComp, yawDisplay)
        end

        if doScreen then self:push(msg) end
    end

    logging.handleAimHit = function(self, e)
        if not e then return end
        if not interface.visuals.logging:get() then return end
        
        local logOptions = interface.visuals.logging_options:get()
        local consoleOptions = interface.visuals.logging_options_console:get()
        local screenOptions = interface.visuals.logging_options_screen:get()
        
        local doConsole = utils.contains(logOptions, "console") and utils.contains(consoleOptions, "hit")
        local doScreen = utils.contains(logOptions, "screen") and utils.contains(screenOptions, "hit")
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
            msg = string.format(
                "hit %s's %s (expected: %s) for %d (expected: %d) / lc: %d - yaw: %s",
                playerName, hitbox, cached.hitbox, damage, cached.damage, lagComp, type(desiredYaw) == "number" and desiredYaw.."°" or desiredYaw.."°"
            )
        else
            msg = string.format(
                "hit %s's %s for %d / lc: %d - yaw: %s",
                playerName, hitbox, damage, lagComp, type(desiredYaw) == "number" and desiredYaw.."°" or desiredYaw.."°"
            )
        end

        if doConsole then
            if cached and cached.hitbox and (cached.hitbox ~= "?" and cached.hitbox ~= hitbox) then
                argLog("hit %s's %s (expected: %s) for %d (expected: %d) / lc: %d - yaw: %s", playerName, hitbox, cached.hitbox, damage, cached.damage, lagComp, type(desiredYaw) == "number" and desiredYaw.."°" or desiredYaw.."°")
            else
                argLog("hit %s's %s for %d / lc: %d - yaw: %s", playerName, hitbox, damage, lagComp, type(desiredYaw) == "number" and desiredYaw.."°" or desiredYaw.."°")
            end
        end
        
        if doScreen then self:push(msg) end
    end

    logging.handleNaded = function(self, e)
        if not e then return end
        if not interface.visuals.logging:get() then return end
        
        local logOptions = interface.visuals.logging_options:get()
        local consoleOptions = interface.visuals.logging_options_console:get()
        local screenOptions = interface.visuals.logging_options_screen:get()
        
        local doConsole = utils.contains(logOptions, "console") and utils.contains(consoleOptions, "hit")
        local doScreen = utils.contains(logOptions, "screen") and utils.contains(screenOptions, "hit")
        if not doConsole and not doScreen then return end

        local victim = client.userid_to_entindex(e.userid)
        if not victim then return end
        
        local playerName = entity.get_player_name(victim)
        local damage = e.dmg_health or 0
        local currentHealth = entity.get_prop(victim, "m_iHealth") or 0
        
        local remainingHealth = math.max(0, currentHealth - damage)
        
        local msg = string.format("naded %s for %d damage (%d left)", playerName, damage, remainingHealth)
        
        if doConsole then
            argLog("naded %s for %d damage (%d left)", playerName, damage, remainingHealth)
        end
        
        if doScreen then self:push(msg) end
    end
    
    logging.handleKnifed = function(self, e)
        if not e then return end
        if not interface.visuals.logging:get() then return end
        
        local logOptions = interface.visuals.logging_options:get()
        local consoleOptions = interface.visuals.logging_options_console:get()
        local screenOptions = interface.visuals.logging_options_screen:get()
        
        local doConsole = utils.contains(logOptions, "console") and utils.contains(consoleOptions, "hit")
        local doScreen = utils.contains(logOptions, "screen") and utils.contains(screenOptions, "hit")
        if not doConsole and not doScreen then return end

        local victim = client.userid_to_entindex(e.userid)
        if not victim then return end
        
        local playerName = entity.get_player_name(victim)
        local damage = e.dmg_health or 0
        local hitbox = self.hitgroup_names[e.hitgroup + 1] or "body"
        local currentHealth = entity.get_prop(victim, "m_iHealth") or 0
        
        local remainingHealth = math.max(0, currentHealth - damage)
        
        local msg = string.format("knifed %s's %s for %d damage (%d left)", playerName, hitbox, damage, remainingHealth)
        
        if doConsole then
            argLog("knifed %s's %s for %d damage (%d left)", playerName, hitbox, damage, remainingHealth)
        end
        
        if doScreen then self:push(msg) end
    end

    logging.handleAimMiss = function(self, e)
        if not e then return end
        
        local playerName = entity.get_player_name(e.target)
        local health = entity.get_prop(e.target, "m_iHealth") or 0
        local reason = e.reason
        local cached = self.cache[e.target] or {}
        local lagComp = cached.lagComp or 0
        local resolverEnabled = (interface.aimbot.enabled_aimbot:get() and interface.aimbot.enabled_resolver_tweaks:get())
        local desiredYaw = resolverEnabled and (resolver.cache[e.target] or 0) or "?"
        
        local expectedDamage = cached.damage or 0
           
        local hitgroupMapping = {
            [0] = "generic",   -- HITGROUP_GENERIC
            [1] = "head",      -- HITGROUP_HEAD
            [2] = "chest",     -- HITGROUP_CHEST
            [3] = "stomach",   -- HITGROUP_STOMACH
            [4] = "left arm",  -- HITGROUP_LEFTARM
            [5] = "right arm", -- HITGROUP_RIGHTARM
            [6] = "left leg",  -- HITGROUP_LEFTLEG
            [7] = "right leg", -- HITGROUP_RIGHTLEG
            [10] = "gear"      -- HITGROUP_GEAR
        }
        local hitgroup = hitgroupMapping[e.hitgroup] or "unknown"
    
        if reason == "?" then
            reason = "unknown"
        elseif not reason or reason == "" then
            reason = "unregistered shot"
        end
    
        if reason == "spread" or reason == "prediction error" then
            -- keep reason
        elseif health <= 0 then
            reason = "player death"
        elseif reason == "death" then
            local local_player = entity.get_local_player()
            if local_player and entity.is_alive(local_player) then
                if health <= 0 then
                    reason = "player death"
                end
            else
                -- keep reason
            end
        elseif reason == "unknown" then
            if cached.got_hit ~= nil and cached.got_hurt ~= nil then
                if cached.got_hit and not cached.got_hurt then
                    reason = "correction"
                elseif not cached.got_hit and cached.had_impact then
                    reason = "misprediction"
                end
            end
        end

        if lagComp > 14 and reason == "unknown" then
            reason = "backtrack failure"
        end

        if reason == "spread" then
            local weapon = entity.get_player_weapon(entity.get_local_player())
            if weapon then
                local inaccuracy = entity.get_prop(weapon, "m_fAccuracyPenalty") or 0
                if inaccuracy > 0.02 then
                    reason = "high inaccuracy"
                end
            end
        end
            
        if not interface.visuals.logging:get() then return end
        
        local logOptions = interface.visuals.logging_options:get()
        local consoleOptions = interface.visuals.logging_options_console:get()
        local screenOptions = interface.visuals.logging_options_screen:get()
        
        local doConsole = utils.contains(logOptions, "console") and utils.contains(consoleOptions, "miss")
        local doScreen = utils.contains(logOptions, "screen") and utils.contains(screenOptions, "miss")
        if not doConsole and not doScreen then return end
    
        local msg = ""
    
        if health <= 0 then
            msg = string.format(
                "missed %s's %s / lc: %d - reason: player death",
                playerName, hitgroup, lagComp
            )
        else
            if reason == "unknown" or reason == "correction" or reason == "misprediction" then
                msg = string.format(
                    "missed %s's %s / lc: %d - yaw: %s - reason: %s",
                    playerName, hitgroup, lagComp, type(desiredYaw) == "number" and desiredYaw.."°" or desiredYaw.."°", reason
                )
            else
                msg = string.format(
                    "missed %s's %s / lc: %d - reason: %s",
                    playerName, hitgroup, lagComp, reason
                )
            end
        end
    
        if doConsole then
            if health <= 0 then
                argLog("missed %s's %s / lc: %d - reason: player death", playerName, hitgroup, lagComp)
            else
                if reason == "unknown" or reason == "correction" or reason == "misprediction" then
                    argLog("missed %s's %s / lc: %d - yaw: %s - reason: %s", playerName, hitgroup, lagComp, type(desiredYaw) == "number" and desiredYaw.."°" or desiredYaw.."°", reason)
                else
                    argLog("missed %s's %s / lc: %d - reason: %s", playerName, hitgroup, lagComp, reason)
                end
            end
        end
        
        if doScreen then self:push(msg) end
    end

    logging.setup_logweapon = function()
        if not interface.visuals.logging:get() then 
            ui.set_enabled(logging.logweapon_original, true)
            return 
        end
        
        local logOptions = interface.visuals.logging_options:get()
        local consoleOptions = interface.visuals.logging_options_console:get()
        local doConsole = utils.contains(logOptions, "console") and utils.contains(consoleOptions, "buy")
        
        if doConsole then
            ui.set(logging.logweapon_original, false)
            ui.set_enabled(logging.logweapon_original, false)
        else
            ui.set_enabled(logging.logweapon_original, true)
        end
    end
    
    logging.on_item_purchase = function(e)
        if not interface.visuals.logging:get() then return end
        local logOptions = interface.visuals.logging_options:get()
        local consoleOptions = interface.visuals.logging_options_console:get()
        local doConsole = utils.contains(logOptions, "console") and utils.contains(consoleOptions, "buy")
        
        if not doConsole then return end
        
        local player_idx = client.userid_to_entindex(e.userid)
        if not player_idx or not entity.is_enemy(player_idx) then return end
        
        local weapon = e.weapon or "unknown item"
        if weapon == "weapon_unknown" then return end
        
        weapon = weapon:gsub("^weapon_", "")
        
        local playerName = entity.get_player_name(player_idx) or "unknown"
        argLog("%s bought %s", playerName, weapon)
    end
    
    logging.on_round_prestart = function(e)
        if not interface.visuals.logging:get() then return end
        
        local logOptions = interface.visuals.logging_options:get()
        if not utils.contains(logOptions, "console") then return end
        
        local game_rules = entity.get_all("CCSGameRulesProxy")[1]
        local is_game_over = game_rules and entity.get_prop(game_rules, "m_gamePhase") >= 5
        local is_restarting = game_rules and entity.get_prop(game_rules, "m_bGameRestart") == 1
        local is_warmup = game_rules and entity.get_prop(game_rules, "m_bWarmupPeriod") == 1
        
        if is_game_over or is_restarting then
            logging.round_counter = 0
        end
        
        if not is_warmup then
            logging.round_counter = logging.round_counter + 1
            client.color_log(255, 255, 255, "\n\0")
            argLog("round %d", logging.round_counter)
        end
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
        local samples = { "noctua", "freestand", "rapid", "reload", "osaa", "dmg" }
        for i = 1, #samples do
            local w = select(1, renderer.measure_text("c", samples[i])) or 0
            if w > maxw then maxw = w end
        end
        local lines = 3.5
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
        
        for i = 1, count do
            local w = select(1, renderer.measure_text("c", logging.animatedMessages[i].text or "")) or 0
            if w > maxw then maxw = w end
        end
        if maxw == 0 then maxw = 300 end
        local height = 10 + visible * line_spacing + 10
        return maxw, height
    end,
    draw = function(ctx)
        local line_spacing = 15
        local base_y = math.floor(ctx.y + 10 + math.ceil(line_spacing / 2) - 1 + 0.5)
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
        local style = interface.visuals.window_style:get()
        
        if style == 'modern' then
            local lineh = 13
            local padding = 6 
            local total_lines = 1
            local total_pixels = 5
            
            local resolver_enabled = interface.aimbot.enabled_aimbot:get() and interface.aimbot.enabled_resolver_tweaks:get()
            if resolver_enabled then
                total_lines = total_lines + 4
                total_pixels = total_pixels + 6
            end
            
            total_lines = total_lines + 2
            total_pixels = total_pixels + 6
            
            local isDT = ui.get(ui_references.double_tap[1]) and ui.get(ui_references.double_tap[2])
            local isOS = ui.get(ui_references.on_shot_anti_aim[1]) and ui.get(ui_references.on_shot_anti_aim[2])
            if isDT or isOS then
                total_lines = total_lines + 3
            end
            
            local width = 150 
            local height = (total_lines * lineh) + total_pixels + 2
            return width, height
        else
            return 130, 60
        end
    end,
    draw = function(ctx)
        local sw, _ = client.screen_size()
        local third = sw / 3
        local align, x
        if ctx.cx < third then align = "l"; x = ctx.x
        elseif ctx.cx > (sw - third) then align = "r"; x = ctx.x + ctx.w
        else align = "c"; x = ctx.x + ctx.w / 2 end
        
        visuals:window(x, ctx.y + 6, align)
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
        local samples = { "+100", "120", "99" }
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
client.set_event_callback('pre_config_save', function() widgets.save_all() end)
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

local aimHandlers = {
    aim_fire = function(e) logging:handleAimFire(e) end,
    aim_miss = function(e) resolver:on_aim_miss(e); logging:handleAimMiss(e) end,
    aim_hit  = function(e) resolver:on_aim_hit(e); logging:handleAimHit(e) end,
    player_hurt = function(e)
        local victim = client.userid_to_entindex(e.userid)
        local attacker = client.userid_to_entindex(e.attacker)
        local me = entity.get_local_player()
        
        if not me or attacker ~= me then
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
    
    hitsound.on_player_hurt = function(e)
        if not interface.utility.hitsound:get() then return end
        
        local attacker = client.userid_to_entindex(e.attacker)
        local local_player = entity.get_local_player()
        
        if attacker == local_player then
            client.exec("play physics/wood/wood_plank_impact_hard4.wav")
        end
    end
    
    hitsound.setup = function()
        if interface.utility.hitsound:get() then
            ui.set(hitsound_original, false)
            ui.set_enabled(hitsound_original, false)
        else
            ui.set_enabled(hitsound_original, true)
        end
    end
    
    client.set_event_callback("player_hurt", hitsound.on_player_hurt)
    client.set_event_callback("paint", hitsound.setup)
end
--@endregion

--@region: buybot
buybot = {} do
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
    
    buybot.has_primary_weapon = function()
        local local_player = entity.get_local_player()
        if not local_player then return false end

        local weapon = entity.get_player_weapon(local_player)
        if not weapon then return false end

        local weap_class = entity.get_classname(weapon)
        return weap_class == "CWeaponSSG08" or
               weap_class == "CWeaponAWP" or
               weap_class == "CWeaponSCAR20" or
               weap_class == "CWeaponG3SG1"
    end

    buybot.on_player_spawn = function(e)
        if client.userid_to_entindex(e.userid) ~= entity.get_local_player() then
            return
        end

        client.delay_call(0.5, function()
            local money = entity.get_prop(entity.get_local_player(), "m_iAccount")

            if not interface.utility.buybot:get() or (money >= 800 and money <= 1000) then
                return
            end

            local primary_item = buybot.primary_console[interface.utility.buybot_primary:get()]
            local primary_fallback_item = buybot.primary_console[interface.utility.buybot_primary_fallback:get()]
            local secondary_item = buybot.secondary_console[interface.utility.buybot_secondary:get()]
            local selected_utilities = interface.utility.buybot_utility:get()

            if primary_item and primary_item ~= "" then
                client.exec("buy " .. primary_item .. ";")

                client.delay_call(0.3, function()
                    if primary_fallback_item and primary_fallback_item ~= "" and not buybot.has_primary_weapon() then
                        client.exec("buy " .. primary_fallback_item .. ";")
                    end
                end)
            elseif primary_fallback_item and primary_fallback_item ~= "" then
                client.exec("buy " .. primary_fallback_item .. ";")
            end

            if secondary_item and secondary_item ~= "" then
                client.exec("buy " .. secondary_item .. ";")
            end

            if selected_utilities then
                for _, utility in ipairs(selected_utilities) do
                    local utility_item = buybot.utility_console[utility]
                    if utility_item and utility_item ~= "" then
                        client.exec("buy " .. utility_item .. ";")
                    end
                end
            end
        end)
    end
    
    client.set_event_callback("player_spawn", buybot.on_player_spawn)
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

local models_data_file = "noctua-models.json"
local models_data = {}

local function load_models_data()
    local content = readfile(models_data_file)
    if content then
        local success, data = pcall(json.decode, content)
        if success and type(data) == "table" then
            models_data = data
            return true
        end
    end 
    return false
end

local function save_models_data()
    local success, encoded = pcall(json.encode, models_data, true)
    if success then
        writefile(models_data_file, encoded)
        return true
    end
    client.error_log("Failed to save models")
    return false
end

--@region: gun model changer
model_changer = {} do
    ffi.cdef[[
        typedef struct {
            void*   fnHandle;        
            char    szName[260];     
            int     nLoadFlags;      
            int     nServerCount;    
            int     type;            
            int     flags;           
            float   vecMins[3];       
            float   vecMaxs[3];       
            float   radius;          
            char    pad[0x1C];       
        } model_t;

        typedef int(__thiscall* get_model_index_t)(void*, const char*);
        typedef const model_t(__thiscall* find_or_load_model_t)(void*, const char*);
        typedef int(__thiscall* add_string_t)(void*, bool, const char*, int, const void*);
        typedef void*(__thiscall* find_table_t)(void*, const char*);
        typedef void(__thiscall* set_model_index_t)(void*, int);
        typedef int(__thiscall* precache_model_t)(void*, const char*, bool);
        typedef void*(__thiscall* get_client_entity_t)(void*, int);
    ]]

    local class_ptr = ffi.typeof("void***")

    local rawientitylist = client.create_interface("client_panorama.dll", "VClientEntityList003") or error("VClientEntityList003 wasn't found", 2)
    local ientitylist = ffi.cast(class_ptr, rawientitylist) or error("rawientitylist is nil", 2)
    local get_client_entity = ffi.cast("get_client_entity_t", ientitylist[0][3]) or error("get_client_entity is nil", 2)

    local rawivmodelinfo = client.create_interface("engine.dll", "VModelInfoClient004") or error("VModelInfoClient004 wasn't found", 2)
    local ivmodelinfo = ffi.cast(class_ptr, rawivmodelinfo) or error("rawivmodelinfo is nil", 2)
    local get_model_index = ffi.cast("get_model_index_t", ivmodelinfo[0][2]) or error("get_model_index is nil", 2)
    local find_or_load_model = ffi.cast("find_or_load_model_t", ivmodelinfo[0][39]) or error("find_or_load_model is nil", 2)

    local rawnetworkstringtablecontainer = client.create_interface("engine.dll", "VEngineClientStringTable001") or error("VEngineClientStringTable001 wasn't found", 2)
    local networkstringtablecontainer = ffi.cast(class_ptr, rawnetworkstringtablecontainer) or error("rawnetworkstringtablecontainer is nil", 2)
    local find_table = ffi.cast("find_table_t", networkstringtablecontainer[0][3]) or error("find_table is nil", 2)

    local function precache_model(modelname)
        local rawprecache_table = find_table(networkstringtablecontainer, "modelprecache") or error("couldn't find modelprecache", 2)
        if rawprecache_table then 
            local precache_table = ffi.cast(class_ptr, rawprecache_table) or error("couldn't cast precache_table", 2)
            if precache_table then 
                local add_string = ffi.cast("add_string_t", precache_table[0][8]) or error("add_string is nil", 2)

                find_or_load_model(ivmodelinfo, modelname)
                local idx = add_string(precache_table, false, modelname, -1, nil)
                if idx == -1 then 
                    return false
                end
            end
        end
        return true
    end

    local function set_model_index(entindex, idx)
        if entindex and entindex > 0 then
            entity.set_prop(entindex, 'm_nModelIndex', idx)
        end
    end

    local function change_model(ent, model)
        if model:len() > 5 then 
                if precache_model(model) == false then
                return 
            end
            local idx = get_model_index(ivmodelinfo, model)
            if idx == -1 then 
                return 
            end
            set_model_index(ent, idx)
        end
    end

    model_changer.models_ui = interface.models
    model_changer.current_items = {}

    local function update_listbox()
        model_changer.current_items = {}
        for weapon, data in pairs(models_data) do
            local model_name = data.model:match(".*[/\\](.+)$") or data.model
            local color = data.enabled and "\a9FCA2BFF" or "\aCA2B2BFF"
            table.insert(model_changer.current_items, color .. weapon .. ": " .. model_name)
        end
        table.insert(model_changer.current_items, "+ add model")
        model_changer.models_ui.list:update(model_changer.current_items)
    end

    model_changer.models_ui.list:set_callback(function()
        local selected_index = (tonumber(model_changer.models_ui.list:get()) or 0) + 1
        if not model_changer.current_items or selected_index >= #model_changer.current_items then return end

        local is_add_new = selected_index == #model_changer.current_items
        local is_enabled = model_changer.models_ui.enabled_models:get()

        model_changer.models_ui.delete_model_button:set_visible(not is_add_new and is_enabled)
        model_changer.models_ui.model_enabled:set_visible(not is_add_new and is_enabled)
        model_changer.models_ui.new_model_weapon:set_visible(is_add_new and is_enabled)
        model_changer.models_ui.new_model_button:set_visible(is_add_new and is_enabled)
        model_changer.models_ui.tip:set_visible(is_add_new and is_enabled)
        model_changer.models_ui.tip2:set_visible(is_add_new and is_enabled)
        model_changer.models_ui.tip3:set_visible(is_add_new and is_enabled)

        if not is_add_new then
            local selected_item = model_changer.current_items[selected_index]
            if selected_item then
                local clean_key = selected_item
                if clean_key:sub(1,1) == "\a" then
                    clean_key = clean_key:sub(10)
                end
                local weapon_key = clean_key:match("^(.-):")
                if weapon_key then
                    weapon_key = string.lower(weapon_key:gsub("%s+", ""))
                    local enabled = false
                    if models_data[weapon_key] and models_data[weapon_key].enabled ~= nil then
                        enabled = models_data[weapon_key].enabled
                    end
                    model_changer.models_ui.model_enabled:set(enabled)
                end
            end
        end
    end)

    model_changer.models_ui.delete_model_button:set_callback(function()
        local selected_index = (tonumber(model_changer.models_ui.list:get()) or 0) + 1
        if not model_changer.current_items or selected_index >= #model_changer.current_items then
            return
        end
    
        local selected_item = model_changer.current_items[selected_index]
        if selected_item then
            local clean_key = selected_item
            if clean_key:sub(1,1) == "\a" then
                clean_key = clean_key:sub(10)
            end
            local weapon_key = clean_key:match("^(.-):")
            if weapon_key then
                weapon_key = string.lower(weapon_key:gsub("%s+", ""))
                if models_data[weapon_key] then
                    models_data[weapon_key] = nil
                    save_models_data()
                    update_listbox()
                    model_changer.models_ui.list:set(0)
                end
            end
        end
    end)
    

    model_changer.models_ui.model_enabled:set_callback(function()
        local selected_index = (tonumber(model_changer.models_ui.list:get()) or 0) + 1
        if not model_changer.current_items or selected_index >= #model_changer.current_items then
            return
        end
    
        local selected_item = model_changer.current_items[selected_index]
        if selected_item then
            local clean_key = selected_item
            if clean_key:sub(1,1) == "\a" then
                clean_key = clean_key:sub(10)
            end
            local weapon_key = clean_key:match("^(.-):")
            if weapon_key then
                weapon_key = string.lower(weapon_key:gsub("%s+", ""))
                if models_data[weapon_key] then
                    local new_state = model_changer.models_ui.model_enabled:get()
                    models_data[weapon_key].enabled = new_state
                    save_models_data()
                    update_listbox()
                end
            end
        end
    end)

    local function get_weapon_key(weapon)
        local classname = entity.get_classname(weapon)
        if classname then
            local lclass = string.lower(classname)
            if lclass:find("ssg08") then return "snip_ssg08" end
            if lclass:find("awp") then return "snip_awp" end
            if lclass:find("scar20") then return "snip_scar20" end
            if lclass:find("g3sg1") then return "snip_g3sg1" end

            if lclass:find("ak47") then return "rif_ak47" end
            if lclass:find("aug") then return "rif_aug" end
            if lclass:find("famas") then return "rif_famas" end
            if lclass:find("galilar") then return "rif_galilar" end
            if lclass:find("m4a1_silencer") then return "rif_m4a1_s" end
            if lclass:find("m4a1") then return "rif_m4a1" end
            if lclass:find("sg556") then return "rif_sg556" end

            if lclass:find("mac10") then return "smg_mac10" end
            if lclass:find("mp7") then return "smg_mp7" end
            if lclass:find("mp9") then return "smg_mp9" end
            if lclass:find("mp5sd") then return "smg_mp5sd" end
            if lclass:find("ump45") then return "smg_ump45" end
            if lclass:find("p90") then return "smg_p90" end
            if lclass:find("bizon") then return "smg_bizon" end

            if lclass:find("glock") then return "pist_glock18" end
            if lclass:find("elite") then return "pist_elite" end
            if lclass:find("p250") then return "pist_p250" end
            if lclass:find("tec9") then return "pist_tec9" end
            if lclass:find("cz75a") then return "pist_cz75" end
            if lclass:find("deagle") then return "pist_deagle" end
            if lclass:find("revolver") then return "pist_revolver" end
            if lclass:find("usp_silencer") then return "pist_usp_silencer" end
            if lclass:find("hkp2000") then return "pist_hkp2000" end
            if lclass:find("fiveseven") then return "pist_fiveseven" end

            if lclass:find("nova") then return "shot_nova" end
            if lclass:find("xm1014") then return "shot_xm1014" end
            if lclass:find("mag7") then return "shot_mag7" end
            if lclass:find("sawedoff") then return "shot_sawedoff" end
            if lclass:find("m249") then return "mach_m249" end
            if lclass:find("negev") then return "mach_negev" end

            if lclass:find("flashbang") then return "eq_flashbang" end
            if lclass:find("hegrenade") then return "eq_fraggrenade" end
            if lclass:find("smokegrenade") then return "eq_smokegrenade" end
            if lclass:find("molotov") then return "eq_molotov" end
            if lclass:find("decoy") then return "eq_decoy" end
            if lclass:find("incgrenade") then return "eq_incgrenade" end
            if lclass:find("taser") then return "eq_taser" end
            if lclass:find("knife") then return "knife_default_ct" end
        end
        return nil
    end

    model_changer.models_ui.enabled_models:set_callback(function()
        local is_enabled = model_changer.models_ui.enabled_models:get()
        
        model_changer.models_ui.list:set_visible(is_enabled)
        model_changer.models_ui.new_model_weapon:set_visible(is_enabled)
        model_changer.models_ui.new_model_button:set_visible(is_enabled)

        if is_enabled then
            local selected_index = (tonumber(model_changer.models_ui.list:get()) or 0) + 1
            local is_add_new = selected_index == #model_changer.current_items
            model_changer.models_ui.delete_model_button:set_visible(not is_add_new)
            model_changer.models_ui.model_enabled:set_visible(not is_add_new)
            model_changer.models_ui.tip:set_visible(is_add_new)
            model_changer.models_ui.tip2:set_visible(is_add_new)
            model_changer.models_ui.tip3:set_visible(is_add_new)
        else
            model_changer.models_ui.list:set_visible(false)
            model_changer.models_ui.delete_model_button:set_visible(false)
            model_changer.models_ui.model_enabled:set_visible(false)
            model_changer.models_ui.new_model_weapon:set_visible(false)
            model_changer.models_ui.new_model_button:set_visible(false)
            model_changer.models_ui.tip:set_visible(false)
            model_changer.models_ui.tip2:set_visible(false)
            model_changer.models_ui.tip3:set_visible(false)
        end
    end)

    client.set_event_callback("pre_render", function()
        local me = entity.get_local_player()
        if not me then return end
        
        local weapon = entity.get_player_weapon(me)
        if not weapon then return end
    
        local weapon_key = get_weapon_key(weapon)
        local current_weapon_key = weapon_key and weapon_key:gsub("^(%w+)_", "")
        if not current_weapon_key then return end
        
        local model_data = models_data[current_weapon_key]
        local is_enabled = model_changer.models_ui.enabled_models:get()

        if not is_enabled or not model_data or not model_data.enabled then
            local wm_handle = entity.get_prop(weapon, "m_hWeaponWorldModel")
            if wm_handle then
                local wm_index = bit.band(wm_handle, 0xFFF)
                local original_model = "models/weapons/w_" .. get_weapon_key(weapon) .. ".mdl"
                change_model(wm_index, original_model)
            end
            return
        end
        
        local model_path = model_data.model
        if not model_path then return end
    
        local wm_handle = entity.get_prop(weapon, "m_hWeaponWorldModel")
        if wm_handle then
            local wm_index = bit.band(wm_handle, 0xFFF)
            change_model(wm_index, model_path)
        end
    
        local vm_handle = entity.get_prop(me, "m_hViewModel[0]")
        if vm_handle then
            local vm_index = bit.band(vm_handle, 0xFFF)
            local vm_path = model_path:gsub("/w_", "/v_")
            change_model(vm_index, vm_path)
        end
    end)

    load_models_data()
    update_listbox()

    model_changer.models_ui.list:set_visible(false)
    model_changer.models_ui.new_model_weapon:set_visible(false)
    model_changer.models_ui.new_model_button:set_visible(false)
    model_changer.models_ui.delete_model_button:set_visible(false)
    model_changer.models_ui.model_enabled:set_visible(false)
    model_changer.models_ui.tip:set_visible(false)
    model_changer.models_ui.tip2:set_visible(false)
    model_changer.models_ui.tip3:set_visible(false)

    client.set_event_callback("paint_ui", function()
        local is_models_visible = interface.search:get():find("models") ~= nil
        local is_enabled = model_changer.models_ui.enabled_models:get()
        
        if not is_models_visible then
            model_changer.models_ui.enabled_models:set_visible(false)
            model_changer.models_ui.list:set_visible(false)
            model_changer.models_ui.new_model_weapon:set_visible(false)
            model_changer.models_ui.new_model_button:set_visible(false)
            model_changer.models_ui.delete_model_button:set_visible(false)
            model_changer.models_ui.model_enabled:set_visible(false)
            model_changer.models_ui.tip:set_visible(false)
            model_changer.models_ui.tip2:set_visible(false)
            model_changer.models_ui.tip3:set_visible(false)
            return
        end

        model_changer.models_ui.enabled_models:set_visible(true)
        
        if is_enabled then
            model_changer.models_ui.list:set_visible(true)
            
            local selected_index = (tonumber(model_changer.models_ui.list:get()) or 0) + 1
            local is_add_new = selected_index == #model_changer.current_items

            model_changer.models_ui.delete_model_button:set_visible(not is_add_new)
            model_changer.models_ui.model_enabled:set_visible(not is_add_new)
            model_changer.models_ui.new_model_weapon:set_visible(is_add_new)
            model_changer.models_ui.new_model_button:set_visible(is_add_new)
            model_changer.models_ui.tip:set_visible(is_add_new)
            model_changer.models_ui.tip2:set_visible(is_add_new)
            model_changer.models_ui.tip3:set_visible(is_add_new)
        else
            model_changer.models_ui.list:set_visible(false)
            model_changer.models_ui.delete_model_button:set_visible(false)
            model_changer.models_ui.model_enabled:set_visible(false)
            model_changer.models_ui.new_model_weapon:set_visible(false)
            model_changer.models_ui.new_model_button:set_visible(false)
            model_changer.models_ui.tip:set_visible(false)
            model_changer.models_ui.tip2:set_visible(false)
            model_changer.models_ui.tip3:set_visible(false)
        end
    end)

    model_changer.models_ui.new_model_button:set_callback(function()
        local new_path = clipboard.get()
        if not new_path or new_path == "" then
            return
        end

        if not new_path:match("^models/weapons/") then
            client.error_log("Invalid model path. It must start with 'models/weapons/'")
            return
        end
        
        local weapon = model_changer.models_ui.new_model_weapon:get()
        if not weapon or weapon == "" then
            return
        end

        weapon = string.lower(weapon)

        models_data[weapon] = {
            model = new_path,
            enabled = false
        }

        save_models_data()
        update_listbox()
    end)

    client.set_event_callback("shutdown", function()
        save_models_data()
        
        local me = entity.get_local_player()
        if me then
            local weapon = entity.get_player_weapon(me)
            if weapon then
                local wm_handle = entity.get_prop(weapon, "m_hWeaponWorldModel")
                if wm_handle then
                    local wm_index = bit.band(wm_handle, 0xFFF)
                    local original_model = "models/weapons/w_" .. get_weapon_key(weapon) .. ".mdl"
                    change_model(wm_index, original_model)
                end
            end
        end
    end)
end
--@endregion

--@region: configs
configs = {} do
    local DB_KEY = 'noctua.configs'
    local default_config = "noctua:eyJ3aWRnZXRzIjogeyJ3YXRlcm1hcmsiOiB7Im9mZnNldF95IjogMTA1NywiYW5jaG9yX3giOiAiY2VudGVyIiwib2Zmc2V0X3giOiAwfSwibGNfc3RhdHVzIjogeyJvZmZzZXRfeSI6IDEwNiwiYW5jaG9yX3giOiAiY2VudGVyIiwib2Zmc2V0X3giOiAwfSwiZGVidWdfd2luZG93IjogeyJhbmNob3JfeSI6ICJjZW50ZXIiLCJvZmZzZXRfeSI6IDAsIm9mZnNldF94IjogODJ9LCJkYW1hZ2VfaW5kaWNhdG9yIjogeyJvZmZzZXRfeSI6IDUzMCwib2Zmc2V0X3giOiA5ODB9LCJzY3JlZW5fbG9nZ2luZyI6IHsib2Zmc2V0X3kiOiA3MDEsImFuY2hvcl94IjogImNlbnRlciIsIm9mZnNldF94IjogMH0sImNyb3NzaGFpcl9pbmRpY2F0b3JzIjogeyJvZmZzZXRfeSI6IDU3MiwiYW5jaG9yX3giOiAiY2VudGVyIiwib2Zmc2V0X3giOiAwfX0sInZlcnNpb24iOiAxLCJ2YWx1ZXMiOiB7ImJ1aWxkZXIuZnJlZXN0YW5kLmRlbGF5IjogMSwidmlzdWFscy5zZWNvbmRhcnkiOiAic2Vjb25kYXJ5IGNvbG9yIiwiYnVpbGRlci5haXIuZGVmX3lhdyI6ICJkZWxheWVkIiwidmlzdWFscy52aWV3bW9kZWwiOiB0cnVlLCJidWlsZGVyLmZyZWVzdGFuZC5kZWZfc3BlZWQiOiAxLCJidWlsZGVyLmRlZmF1bHQuMiI6IDAsImJ1aWxkZXIuYWlyLmJ5X251bSI6IC0yOCwiYnVpbGRlci5zYWZlIGhlYWQuZW5hYmxlIjogdHJ1ZSwiYnVpbGRlci5vbiBzaG90LmRlZmVuc2l2ZSI6IHRydWUsImJ1aWxkZXIuZHVjayBtb3ZlLmVwZF9yaWdodCI6IC0yOCwiYnVpbGRlci5haXJjLmFkZCI6IDEzLCJidWlsZGVyLmZyZWVzdGFuZC5leHBhbmQiOiAibGVmdC9yaWdodCIsImJ1aWxkZXIuaWRsZS40IjogMCwidXRpbGl0eS5zdHJlYW1lcl9tb2RlIjogZmFsc2UsInV0aWxpdHkuYnV5Ym90X3V0aWxpdHkiOiBbImtldmxhciIsImhlbG1ldCIsImRlZnVzZXIiLCJ0YXNlciIsImhlIiwibW9sb3RvdiIsInNtb2tlIl0sImJ1aWxkZXIuaWRsZS5kZWZlbnNpdmUiOiBmYWxzZSwiYnVpbGRlci5zbG93LmRlZl9sZWZ0IjogLTM0LCJidWlsZGVyLnNhZmUgaGVhZC4yIjogMCwiYnVpbGRlci5vbiBzaG90LmJhc2UiOiAiYXQgdGFyZ2V0cyIsImJ1aWxkZXIuZmFrZWxhZy53YXlzX21hbnVhbCI6IGZhbHNlLCJ1dGlsaXR5LnN0cmVhbWVyX21vZGVfaGVscCI6ICJ0eXBlIGluIGNvbnNvbGU6IC5hZGQgbmFtZSB1cmwiLCJ2aXN1YWxzLndhdGVybWFyayI6IHRydWUsImJ1aWxkZXIudXNlLmRlZmVuc2l2ZSI6IGZhbHNlLCJidWlsZGVyLm1hbnVhbC5lbmFibGUiOiB0cnVlLCJidWlsZGVyLmZha2VsYWcuYWRkIjogMCwiYnVpbGRlci5zbG93Lnhfd2F5bGFiZWwiOiAid2F5IDMiLCJidWlsZGVyLmlkbGUuZGVmX3lhdyI6ICJkZWxheWVkIiwiYWltYm90Lm5vc2NvcGVfd2VhcG9ucyI6IFsiYXV0b3NuaXBlcnMiXSwiYnVpbGRlci5kdWNrLjIiOiAwLCJidWlsZGVyLmZyZWVzdGFuZC5kZWZfeWF3IjogImRlbGF5ZWQiLCJidWlsZGVyLmFpci43IjogMCwiYnVpbGRlci5mcmVlc3RhbmQueF93YXlsYWJlbCI6ICJ3YXkgMyIsImJ1aWxkZXIuZnJlZXN0YW5kLmJ5X251bSI6IDEyLCJidWlsZGVyLnVzZS5lcGRfbGVmdCI6IDEsImJ1aWxkZXIudXNlLndheXNfbWFudWFsIjogZmFsc2UsImJ1aWxkZXIub24gc2hvdC4zIjogMCwiYnVpbGRlci5tYW51YWwuaml0dGVyX2FkZCI6IC0xLCJidWlsZGVyLmR1Y2sgbW92ZS5kZWZfeWF3IjogInNpZGV3YXlzIiwiYnVpbGRlci5haXJjLjEiOiAwLCJidWlsZGVyLnNhZmUgaGVhZC5qaXR0ZXJfYWRkIjogMCwiYnVpbGRlci5kdWNrIG1vdmUuZGVsYXkiOiAyLCJidWlsZGVyLnVzZS5qaXR0ZXIiOiAib2ZmIiwiYnVpbGRlci5mcmVlc3RhbmQud2F5c19tYW51YWwiOiBmYWxzZSwiYnVpbGRlci5leHRlbnNpb25zLm1hbnVhbF9hYV9ob3RrZXkubWFudWFsX2ZvcndhcmQiOiBmYWxzZSwiYnVpbGRlci5mcmVlc3RhbmQuZGVmX3JpZ2h0IjogMjYsImJ1aWxkZXIuZnJlZXN0YW5kLmRlZl95YXdfbnVtIjogLTI4LCJidWlsZGVyLmFpcmMuZGVmX2JvZHkiOiAiaml0dGVyIiwiYnVpbGRlci5mYWtlbGFnLmJ5X21vZGUiOiAiaml0dGVyIiwidmlzdWFscy56b29tX2FuaW1hdGlvbl9zcGVlZCI6IDUwLCJidWlsZGVyLm9uIHNob3QuZGVmX3lhd19udW0iOiAtMjgsImJ1aWxkZXIuYWlyLnhfd2F5bGFiZWwiOiAid2F5IDMiLCJidWlsZGVyLmlkbGUuaml0dGVyIjogIm9mZnNldCIsImJ1aWxkZXIuZnJlZXN0YW5kLjUiOiAwLCJidWlsZGVyLm9uIHNob3Quaml0dGVyIjogIm9mZnNldCIsImJ1aWxkZXIuaWRsZS5qaXR0ZXJfYWRkIjogLTI4LCJidWlsZGVyLnJ1bi54X3dheWxhYmVsIjogIndheSAzIiwiYnVpbGRlci5ydW4ud2F5c19tYW51YWwiOiBmYWxzZSwiYnVpbGRlci5haXIuc3BlZWQiOiAxLCJidWlsZGVyLmZha2VsYWcueF93YXlsYWJlbCI6ICJ3YXkgMyIsImJ1aWxkZXIuc2FmZSBoZWFkLmRlZl9ib2R5IjogImppdHRlciIsImJ1aWxkZXIub24gc2hvdC5kZWZfcGl0Y2giOiAiZGVmYXVsdCIsImJ1aWxkZXIubWFudWFsLmRlZl9zcGVlZCI6IDEsImJ1aWxkZXIuZmFrZWxhZy4zIjogMCwiYnVpbGRlci5kdWNrLndheXNfbWFudWFsIjogZmFsc2UsImJ1aWxkZXIubWFudWFsLmJ5X21vZGUiOiAic3RhdGljIiwiYnVpbGRlci5pZGxlLnhfd2F5bGFiZWwiOiAid2F5IDMiLCJ2aXN1YWxzLnZpZXdtb2RlbF95IjogMCwiYnVpbGRlci5tYW51YWwud2F5c19tYW51YWwiOiBmYWxzZSwiYnVpbGRlci5ydW4uZGVmX3lhdyI6ICJkZWxheWVkIiwiYnVpbGRlci5zYWZlIGhlYWQuZGVsYXkiOiAxLCJidWlsZGVyLmV4dGVuc2lvbnMubWFudWFsX2FhX2hvdGtleS5tYW51YWxfbGVmdCI6IGZhbHNlLCJidWlsZGVyLmRlZmF1bHQuZGVmX3BpdGNoIjogImRlZmF1bHQiLCJidWlsZGVyLnNsb3cuMSI6IDAsInV0aWxpdHkua2lsbHNheV9tb2RlcyI6IFsib24ga2lsbCJdLCJidWlsZGVyLnVzZS54X3dheWxhYmVsIjogIndheSAzIiwiYnVpbGRlci5kdWNrLmRlZl95YXdfbnVtIjogLTI4LCJidWlsZGVyLmR1Y2sueWF3X3JhbmRvbWl6ZSI6IDE2LCJidWlsZGVyLmFpcmMuc3BlZWQiOiAxLCJ1dGlsaXR5LnN0cmVhbWVyX21vZGVfbGlzdCI6IDMsImFpbWJvdC5lbmFibGVkX3Jlc29sdmVyX3R3ZWFrcyI6IHRydWUsImJ1aWxkZXIudXNlLmRlZl95YXdfbnVtIjogLTI4LCJidWlsZGVyLmR1Y2suaml0dGVyX2FkZCI6IDM4LCJidWlsZGVyLmFpcmMud2F5c19tYW51YWwiOiBmYWxzZSwiYnVpbGRlci5tYW51YWwuMyI6IDAsImJ1aWxkZXIuYWlyLmJhc2UiOiAiYXQgdGFyZ2V0cyIsImJ1aWxkZXIuZHVjay5kZWZfeWF3IjogImN1c3RvbSIsImJ1aWxkZXIucnVuLjYiOiAwLCJidWlsZGVyLmR1Y2sgbW92ZS4xIjogMCwiYnVpbGRlci5mYWtlbGFnLmppdHRlcl9hZGQiOiAtMjgsImJ1aWxkZXIuaWRsZS54X3dheSI6IDMsImJ1aWxkZXIuZHVjay5kZWZlbnNpdmUiOiB0cnVlLCJidWlsZGVyLmV4dGVuc2lvbnMuYW50aV9icnV0ZWZvcmNlIjogZmFsc2UsImJ1aWxkZXIuYWlyLmVwZF9sZWZ0IjogLTMsImJ1aWxkZXIuc2xvdy5kZWxheSI6IDIsImJ1aWxkZXIub24gc2hvdC42IjogMCwiYnVpbGRlci5haXJjLmJyZWFrX2xjIjogdHJ1ZSwiYWltYm90LnF1aWNrX3N0b3AiOiBmYWxzZSwiYnVpbGRlci5leHRlbnNpb25zLmFudGlfYnJ1dGVmb3JjZV90eXBlIjogImRlY3JlYXNlIiwiYnVpbGRlci5kZWZhdWx0LjYiOiAwLCJ2aXN1YWxzLmFjY2VudCI6ICJhY2NlbnQgY29sb3IiLCJhaW1ib3QucXVpY2tfc3RvcC5ob3RrZXlfa2V5Y29kZSI6IDAsImJ1aWxkZXIuZXh0ZW5zaW9ucy5tYW51YWxfYWFfaG90a2V5Lm1hbnVhbF9iYWNrIjogZmFsc2UsImJ1aWxkZXIuaWRsZS5ieV9tb2RlIjogImppdHRlciIsImJ1aWxkZXIub24gc2hvdC5zcGVlZCI6IDEsInZpc3VhbHMubG9nZ2luZ19vcHRpb25zX3NjcmVlbiI6IFsiaGl0IiwibWlzcyIsImFpbWJvdCJdLCJ2aXN1YWxzLmxvZ2dpbmdfb3B0aW9ucyI6IFsiY29uc29sZSIsInNjcmVlbiJdLCJidWlsZGVyLm9uIHNob3Qud2F5c19tYW51YWwiOiBmYWxzZSwiYnVpbGRlci5haXJjLjQiOiAwLCJ2aXN1YWxzLmNyb3NzaGFpcl9pbmRpY2F0b3JzIjogdHJ1ZSwiYnVpbGRlci5kdWNrIG1vdmUuaml0dGVyX2FkZCI6IC0yOCwiYnVpbGRlci5kZWZhdWx0LmVwZF93YXkiOiAwLCJ2aXN1YWxzLmxvZ2dpbmdfc2xpZGVyIjogMjQwLCJidWlsZGVyLmFpci5kZWZfcGl0Y2hfbnVtIjogLTI4LCJidWlsZGVyLnNhZmUgaGVhZC41IjogMCwiYnVpbGRlci5kdWNrLmRlZl9waXRjaF9udW0iOiAtMjgsImJ1aWxkZXIuZnJlZXN0YW5kLmJyZWFrX2xjIjogZmFsc2UsImJ1aWxkZXIuc2xvdy5kZWZfcGl0Y2giOiAiemVybyIsImJ1aWxkZXIuc2xvdy5qaXR0ZXIiOiAib2Zmc2V0IiwiYnVpbGRlci5kdWNrIG1vdmUuYmFzZSI6ICJhdCB0YXJnZXRzIiwiYWltYm90Lm5vc2NvcGVfZGlzdGFuY2Vfc2NvdXQiOiA0NTAsImJ1aWxkZXIuaWRsZS53YXlzX21hbnVhbCI6IGZhbHNlLCJidWlsZGVyLmFpcmMuZGVmZW5zaXZlIjogZmFsc2UsImJ1aWxkZXIuZHVjay43IjogMCwiYnVpbGRlci5vbiBzaG90LjIiOiAwLCJidWlsZGVyLmlkbGUuYmFzZSI6ICJhdCB0YXJnZXRzIiwiYnVpbGRlci5vbiBzaG90LmRlZl95YXciOiAiZGVsYXllZCIsImJ1aWxkZXIuZnJlZXN0YW5kLmRlZl9ib2R5IjogImppdHRlciIsImJ1aWxkZXIuc2FmZSBoZWFkLmppdHRlciI6ICJvZmYiLCJidWlsZGVyLnVzZS5qaXR0ZXJfYWRkIjogLTUsImJ1aWxkZXIuZHVjayBtb3ZlLjQiOiAwLCJidWlsZGVyLmFpcmMuZGVmX2xlZnQiOiAtMzQsImJ1aWxkZXIuc2xvdy42IjogMCwiYnVpbGRlci5mcmVlc3RhbmQuYnlfbW9kZSI6ICJqaXR0ZXIiLCJidWlsZGVyLnVzZS55YXdfcmFuZG9taXplIjogMCwiYnVpbGRlci5kdWNrLjMiOiAwLCJhaW1ib3Qubm9zY29wZV9kaXN0YW5jZV9hd3AiOiA0NTAsImJ1aWxkZXIuaWRsZS41IjogMCwiYnVpbGRlci51c2UuNCI6IDAsImJ1aWxkZXIuYWlyLmRlZl9yaWdodCI6IDI2LCJidWlsZGVyLmRlZmF1bHQuYWRkIjogMCwiYnVpbGRlci5ydW4uMyI6IDAsImJ1aWxkZXIub24gc2hvdC5kZWZfYm9keSI6ICJqaXR0ZXIiLCJidWlsZGVyLmZha2VsYWcuMiI6IDAsImJ1aWxkZXIucnVuLjIiOiAwLCJidWlsZGVyLnVzZS5leHBhbmQiOiAib2ZmIiwiYnVpbGRlci5tYW51YWwuc3BlZWQiOiAxLCJ2aXN1YWxzLnZpZXdtb2RlbF9mb3YiOiA0MywiYnVpbGRlci5kdWNrLmFkZCI6IDAsImJ1aWxkZXIub24gc2hvdC5ieV9udW0iOiAtMjgsImJ1aWxkZXIudXNlLmRlZl9waXRjaF9udW0iOiAtMjgsImJ1aWxkZXIucnVuLmRlZl95YXdfbnVtIjogLTI4LCJidWlsZGVyLmZha2VsYWcuZGVmZW5zaXZlIjogdHJ1ZSwiYnVpbGRlci5kdWNrIG1vdmUuZGVmX3lhd19udW0iOiAtMjgsImJ1aWxkZXIuZnJlZXN0YW5kLnNwZWVkIjogMSwiYnVpbGRlci5zYWZlIGhlYWQuc3BlZWQiOiAxLCJ1dGlsaXR5LmFuaW1hdGlvbl9icmVha2VycyI6IFsiZWFydGhxdWFrZSIsIm9uIGdyb3VuZCIsIm9uIGFpciIsImJvZHkgbGVhbiJdLCJidWlsZGVyLmRlZmF1bHQuZGVmZW5zaXZlIjogdHJ1ZSwiYnVpbGRlci5kZWZhdWx0LndheXNfbWFudWFsIjogZmFsc2UsImJ1aWxkZXIucnVuLjciOiAwLCJidWlsZGVyLmR1Y2sueF93YXkiOiAzLCJidWlsZGVyLm9uIHNob3QuZXhwYW5kIjogImxlZnQvcmlnaHQiLCJidWlsZGVyLmZyZWVzdGFuZC5lcGRfd2F5IjogMCwidmlzdWFscy52Z3VpIjogInZndWkgY29sb3IiLCJidWlsZGVyLmV4dGVuc2lvbnMuZnJlZXN0YW5kaW5nIjogZmFsc2UsImJ1aWxkZXIuZHVjayBtb3ZlLndheXNfbWFudWFsIjogZmFsc2UsInZpc3VhbHMudmlld21vZGVsX3giOiAwLCJidWlsZGVyLmFpcmMuZW5hYmxlIjogdHJ1ZSwiYnVpbGRlci5kdWNrIG1vdmUuZGVmX2xlZnQiOiAtMzQsInZpc3VhbHMuem9vbV9hbmltYXRpb24iOiBmYWxzZSwiYnVpbGRlci5haXIuNCI6IDAsImJ1aWxkZXIuaWRsZS42IjogMCwidmlzdWFscy5lbmFibGVkX3Zpc3VhbHMiOiB0cnVlLCJhaW1ib3Quc2lsZW50X3Nob3QiOiB0cnVlLCJidWlsZGVyLnJ1bi5qaXR0ZXJfYWRkIjogLTMxLCJidWlsZGVyLmFpcmMuaml0dGVyIjogIm9mZiIsImJ1aWxkZXIuZmFrZWxhZy4xIjogMCwiYnVpbGRlci51c2UuZGVmX3BpdGNoIjogImRlZmF1bHQiLCJidWlsZGVyLnJ1bi54X3dheSI6IDMsImJ1aWxkZXIuZHVjayBtb3ZlLmVuYWJsZSI6IHRydWUsImJ1aWxkZXIuYWlyYy5kZWZfeWF3X251bSI6IC0yOCwiYnVpbGRlci5kZWZhdWx0LmVwZF9yaWdodCI6IC0yOCwiYnVpbGRlci5leHRlbnNpb25zLm1hbnVhbF9hYV9ob3RrZXkubWFudWFsX2xlZnQuaG90a2V5X2tleWNvZGUiOiA5MCwiYnVpbGRlci5pZGxlLmVuYWJsZSI6IHRydWUsImJ1aWxkZXIuYWlyYy41IjogMCwiYnVpbGRlci5tYW51YWwuMiI6IDAsImJ1aWxkZXIuZGVmYXVsdC5qaXR0ZXJfYWRkIjogLTI4LCJidWlsZGVyLmlkbGUuYnlfbnVtIjogLTI4LCJidWlsZGVyLmFpci4xIjogMCwiYnVpbGRlci5ydW4uYWRkIjogMCwiYnVpbGRlci5zbG93LndheXNfbWFudWFsIjogZmFsc2UsImJ1aWxkZXIuZGVmYXVsdC41IjogMCwiYnVpbGRlci5pZGxlLmRlZl9sZWZ0IjogLTM0LCJidWlsZGVyLmZha2VsYWcuZGVmX3BpdGNoIjogImRlZmF1bHQiLCJ2aXN1YWxzLmRhbWFnZV9pbmRpY2F0b3IiOiB0cnVlLCJidWlsZGVyLmV4dGVuc2lvbnMubWFudWFsX2FhX2hvdGtleS5tYW51YWxfYmFjay5ob3RrZXlfbW9kZV9pZHgiOiAxLCJidWlsZGVyLm1hbnVhbC5kZWZfeWF3IjogImRlbGF5ZWQiLCJidWlsZGVyLmR1Y2suZGVsYXkiOiAyLCJidWlsZGVyLmR1Y2sgbW92ZS5qaXR0ZXIiOiAib2Zmc2V0IiwiYnVpbGRlci5zYWZlIGhlYWQuZXBkX3JpZ2h0IjogMCwiYnVpbGRlci5haXJjLmRlbGF5IjogMiwiYnVpbGRlci5kZWZhdWx0LjEiOiAwLCJidWlsZGVyLmFpci5kZWZfcGl0Y2giOiAiZGVmYXVsdCIsImJ1aWxkZXIudXNlLmRlZl95YXciOiAiZGVsYXllZCIsImJ1aWxkZXIuc2xvdy5lcGRfd2F5IjogMCwidmlzdWFscy53aW5kb3ciOiB0cnVlLCJ1dGlsaXR5LmJ1eWJvdF9wcmltYXJ5IjogInNjb3V0IiwiYnVpbGRlci5tYW51YWwuYWRkIjogMCwiYnVpbGRlci5tYW51YWwuZXBkX2xlZnQiOiAtMTIsImJ1aWxkZXIuZHVjayBtb3ZlLmRlZl9zcGVlZCI6IDEsImJ1aWxkZXIuYWlyYy5ieV9udW0iOiAzOCwiYnVpbGRlci5ydW4uZGVmX2JvZHkiOiAiYXV0byIsImJ1aWxkZXIuYWlyLnlhd19yYW5kb21pemUiOiAwLCJ1dGlsaXR5LnBhcnR5X21vZGUiOiBmYWxzZSwiYnVpbGRlci5haXJjLmVwZF9yaWdodCI6IDAsImJ1aWxkZXIuZnJlZXN0YW5kLmVuYWJsZSI6IGZhbHNlLCJidWlsZGVyLmR1Y2sgbW92ZS4zIjogMCwiYnVpbGRlci5mYWtlbGFnLmV4cGFuZCI6ICJsZWZ0L3JpZ2h0IiwiYnVpbGRlci5zYWZlIGhlYWQuNCI6IDAsImJ1aWxkZXIub24gc2hvdC5qaXR0ZXJfYWRkIjogLTI4LCJidWlsZGVyLmlkbGUuZXhwYW5kIjogImxlZnQvcmlnaHQiLCJidWlsZGVyLmZyZWVzdGFuZC5iYXNlIjogImF0IHRhcmdldHMiLCJidWlsZGVyLm9uIHNob3QuZGVmX3JpZ2h0IjogMjYsImJ1aWxkZXIuZGVmYXVsdC5kZWZfc3BlZWQiOiAxLCJidWlsZGVyLm9uIHNob3QuNSI6IDAsInZpc3VhbHMubG9nZ2luZyI6IHRydWUsImJ1aWxkZXIuc2xvdy4zIjogMCwiYnVpbGRlci5kdWNrIG1vdmUuNyI6IDAsImJ1aWxkZXIuc2FmZSBoZWFkLmRlZl95YXciOiAiZGVsYXllZCIsImJ1aWxkZXIuc2FmZSBoZWFkLmJyZWFrX2xjIjogZmFsc2UsImJ1aWxkZXIubWFudWFsLmRlZl9ib2R5IjogImppdHRlciIsImJ1aWxkZXIub24gc2hvdC5hZGQiOiAwLCJidWlsZGVyLmZyZWVzdGFuZC5kZWZlbnNpdmUiOiBmYWxzZSwiYnVpbGRlci5haXJjLjMiOiAwLCJidWlsZGVyLm1hbnVhbC54X3dheSI6IDMsImJ1aWxkZXIuaWRsZS5kZWZfcGl0Y2giOiAiZGVmYXVsdCIsImJ1aWxkZXIudXNlLmRlZl9yaWdodCI6IDI2LCJ1dGlsaXR5Lm9uX2dyb3VuZF9vcHRpb25zIjogImppdHRlciIsInZpc3VhbHMuY3Jvc3NoYWlyX2FuaW1hdGVfc2NvcGUiOiB0cnVlLCJidWlsZGVyLmR1Y2sgbW92ZS54X3dheSI6IDMsImJ1aWxkZXIuZmFrZWxhZy5kZWZfc3BlZWQiOiAxLCJ1dGlsaXR5LmJvZHlfbGVhbl9hbW91bnQiOiAxMDAsImJ1aWxkZXIuc2FmZSBoZWFkLnhfd2F5IjogMywiYnVpbGRlci5mYWtlbGFnLjUiOiAwLCJidWlsZGVyLnNsb3cuaml0dGVyX2FkZCI6IC0yOCwiYnVpbGRlci5mcmVlc3RhbmQuNyI6IDAsImJ1aWxkZXIubWFudWFsLmJyZWFrX2xjIjogZmFsc2UsInV0aWxpdHkuYnV5Ym90IjogdHJ1ZSwiYnVpbGRlci5mYWtlbGFnLmJhc2UiOiAiYXQgdGFyZ2V0cyIsImJ1aWxkZXIuZXh0ZW5zaW9ucy5mcmVlc3RhbmRpbmcuaG90a2V5X21vZGVfaWR4IjogMSwidmlzdWFscy53YXRlcm1hcmtfc2hvdyI6IFsic2NyaXB0IiwicGxheWVyIiwidGltZSIsInBpbmciXSwiYnVpbGRlci5haXIuZGVmX3NwZWVkIjogMSwiYnVpbGRlci5vbiBzaG90Lnhfd2F5IjogMywiYWltYm90Lm5vc2NvcGVfZGlzdGFuY2UiOiB0cnVlLCJidWlsZGVyLmlkbGUuZXBkX3dheSI6IDAsImJ1aWxkZXIuYWlyLndheXNfbWFudWFsIjogZmFsc2UsImJ1aWxkZXIuZnJlZXN0YW5kLmppdHRlcl9hZGQiOiAtNSwiYnVpbGRlci5zYWZlIGhlYWQuZGVmX3BpdGNoX251bSI6IC0yOCwiYnVpbGRlci5haXIuaml0dGVyX2FkZCI6IDUsInZpc3VhbHMuYXNwZWN0X3JhdGlvX3NsaWRlciI6IDEyMCwiYnVpbGRlci5pZGxlLnNwZWVkIjogMSwiYnVpbGRlci5vbiBzaG90LmVwZF93YXkiOiAwLCJidWlsZGVyLm1hbnVhbC41IjogMCwiYnVpbGRlci5leHRlbnNpb25zLm1hbnVhbF9hYSI6IHRydWUsImJ1aWxkZXIuZGVmYXVsdC5leHBhbmQiOiAibGVmdC9yaWdodCIsImJ1aWxkZXIuc2xvdy5ieV9udW0iOiAtMjgsImJ1aWxkZXIuc2FmZSBoZWFkLmRlZl9zcGVlZCI6IDEsImJ1aWxkZXIudXNlLmVwZF93YXkiOiAwLCJidWlsZGVyLmZyZWVzdGFuZC55YXdfcmFuZG9taXplIjogMCwiYnVpbGRlci5zYWZlIGhlYWQuYmFzZSI6ICJhdCB0YXJnZXRzIiwiYnVpbGRlci5kdWNrLmJhc2UiOiAiYXQgdGFyZ2V0cyIsImJ1aWxkZXIubWFudWFsLmppdHRlciI6ICJvZmYiLCJidWlsZGVyLmFpcmMuMiI6IDAsImJ1aWxkZXIuZmFrZWxhZy40IjogMCwiYnVpbGRlci5mcmVlc3RhbmQuZGVmX3BpdGNoIjogImRlZmF1bHQiLCJidWlsZGVyLmFpci41IjogMCwiYnVpbGRlci5haXJjLmRlZl9waXRjaF9udW0iOiAtMjgsImJ1aWxkZXIuZGVmYXVsdC5kZWZfeWF3IjogImRlbGF5ZWQiLCJidWlsZGVyLmRlZmF1bHQuNCI6IDAsImJ1aWxkZXIuc2xvdy43IjogMCwiYnVpbGRlci5pZGxlLmRlbGF5IjogMiwidmlzdWFscy52aWV3bW9kZWxfeiI6IDAsInV0aWxpdHkuY2xhbnRhZyI6IGZhbHNlLCJhaW1ib3QuZW5hYmxlZF9haW1ib3QiOiB0cnVlLCJ2aXN1YWxzLnNwYXduX3pvb20iOiB0cnVlLCJidWlsZGVyLmZha2VsYWcuYnJlYWtfbGMiOiB0cnVlLCJidWlsZGVyLmFpcmMuYmFzZSI6ICJhdCB0YXJnZXRzIiwiYnVpbGRlci5kdWNrLmRlZl9ib2R5IjogImppdHRlciIsImJ1aWxkZXIubWFudWFsLnlhd19yYW5kb21pemUiOiAwLCJidWlsZGVyLmZyZWVzdGFuZC5kZWZfbGVmdCI6IC0zNCwiYnVpbGRlci5zbG93LmVuYWJsZSI6IHRydWUsImJ1aWxkZXIucnVuLmRlZl9waXRjaCI6ICJkZWZhdWx0IiwiYWltYm90Lm5vc2NvcGVfZGlzdGFuY2VfYXV0b3NuaXBlcnMiOiA0NTAsImJ1aWxkZXIuaWRsZS5icmVha19sYyI6IHRydWUsImJ1aWxkZXIuZnJlZXN0YW5kLmFkZCI6IDAsImJ1aWxkZXIub24gc2hvdC5ieV9tb2RlIjogImppdHRlciIsImJ1aWxkZXIuZHVjayBtb3ZlLmRlZl9waXRjaCI6ICJkZWZhdWx0IiwiYnVpbGRlci5kdWNrLmppdHRlciI6ICJjZW50ZXIiLCJidWlsZGVyLmFpcmMuZGVmX3NwZWVkIjogMSwiYnVpbGRlci5zYWZlIGhlYWQud2F5c19tYW51YWwiOiBmYWxzZSwiYnVpbGRlci5haXJjLnhfd2F5IjogMywiYnVpbGRlci5mYWtlbGFnLmJ5X251bSI6IC0yOCwiYnVpbGRlci5kZWZhdWx0LmppdHRlciI6ICJvZmZzZXQiLCJidWlsZGVyLnJ1bi5ieV9udW0iOiAtOCwiYnVpbGRlci5kdWNrIG1vdmUuNiI6IDAsImJ1aWxkZXIubWFudWFsLmRlZl9waXRjaF9udW0iOiAtMjgsImJ1aWxkZXIuZGVmYXVsdC5iYXNlIjogImF0IHRhcmdldHMiLCJidWlsZGVyLmRlZmF1bHQueF93YXlsYWJlbCI6ICJ3YXkgMyIsImJ1aWxkZXIuZGVmYXVsdC5kZWZfcGl0Y2hfbnVtIjogLTI4LCJidWlsZGVyLmRlZmF1bHQuYnJlYWtfbGMiOiB0cnVlLCJidWlsZGVyLmRlZmF1bHQuZGVmX3lhd19udW0iOiAtMjgsImJ1aWxkZXIubWFudWFsLjEiOiAwLCJidWlsZGVyLmZha2VsYWcuZGVmX3BpdGNoX251bSI6IC0yOCwiYnVpbGRlci5vbiBzaG90LjEiOiAwLCJidWlsZGVyLmRlZmF1bHQuZGVmX2JvZHkiOiAiaml0dGVyIiwiYnVpbGRlci5kZWZhdWx0LmRlZl9yaWdodCI6IDI2LCJidWlsZGVyLmRlZmF1bHQuYnlfbW9kZSI6ICJqaXR0ZXIiLCJidWlsZGVyLmlkbGUuZGVmX2JvZHkiOiAiaml0dGVyIiwiYnVpbGRlci5kdWNrIG1vdmUuYnJlYWtfbGMiOiB0cnVlLCJidWlsZGVyLmRlZmF1bHQuYnlfbnVtIjogLTI4LCJidWlsZGVyLmRlZmF1bHQuZGVsYXkiOiAyLCJidWlsZGVyLnVzZS4xIjogMCwiYnVpbGRlci5haXJjLjYiOiAwLCJidWlsZGVyLmRlZmF1bHQuZGVmX2xlZnQiOiAtMzQsImJ1aWxkZXIuZGVmYXVsdC5zcGVlZCI6IDEsImJ1aWxkZXIuZHVjay5lbmFibGUiOiB0cnVlLCJidWlsZGVyLmRlZmF1bHQuZXBkX2xlZnQiOiAtMjgsImJ1aWxkZXIuZHVjay5kZWZfc3BlZWQiOiAxLCJidWlsZGVyLnNsb3cuZGVmX3lhd19udW0iOiAtMjgsImJ1aWxkZXIuZmFrZWxhZy5kZWZfeWF3X251bSI6IC0yOCwiYnVpbGRlci5haXIuZGVmZW5zaXZlIjogZmFsc2UsImJ1aWxkZXIuZGVmYXVsdC43IjogMCwiYnVpbGRlci5kZWZhdWx0LjMiOiAwLCJidWlsZGVyLmR1Y2sgbW92ZS55YXdfcmFuZG9taXplIjogMCwiYnVpbGRlci5kdWNrIG1vdmUueF93YXlsYWJlbCI6ICJ3YXkgMyIsImJ1aWxkZXIuc2FmZSBoZWFkLmRlZl95YXdfbnVtIjogLTI4LCJidWlsZGVyLmZha2VsYWcuZXBkX3dheSI6IDAsImJ1aWxkZXIuZHVjayBtb3ZlLmRlZmVuc2l2ZSI6IGZhbHNlLCJidWlsZGVyLmZyZWVzdGFuZC5kZWZfcGl0Y2hfbnVtIjogLTI4LCJidWlsZGVyLnVzZS5kZWZfYm9keSI6ICJqaXR0ZXIiLCJidWlsZGVyLmlkbGUuNyI6IDAsInZpc3VhbHMubGNfc3RhdHVzIjogZmFsc2UsImJ1aWxkZXIuZXh0ZW5zaW9ucy5lZGdlX3lhdyI6IGZhbHNlLCJidWlsZGVyLmR1Y2sgbW92ZS5lcGRfd2F5IjogMCwiYnVpbGRlci51c2UuYWRkIjogMCwiYnVpbGRlci5kdWNrIG1vdmUuZGVmX2JvZHkiOiAiaml0dGVyIiwiYnVpbGRlci5zbG93LnNwZWVkIjogMSwiYnVpbGRlci5kdWNrIG1vdmUuZGVmX3JpZ2h0IjogMjYsImJ1aWxkZXIub24gc2hvdC5kZWxheSI6IDIsImJ1aWxkZXIudXNlLmJ5X21vZGUiOiAiaml0dGVyIiwiYnVpbGRlci5zYWZlIGhlYWQuMyI6IDAsImJ1aWxkZXIuaWRsZS5hZGQiOiAwLCJidWlsZGVyLmR1Y2sgbW92ZS5ieV9tb2RlIjogImppdHRlciIsImJ1aWxkZXIuZHVjayBtb3ZlLmFkZCI6IDAsImJ1aWxkZXIuZHVjay41IjogMCwiYWltYm90LnNtYXJ0X3NhZmV0eSI6IGZhbHNlLCJ2aXN1YWxzLnpvb21fYW5pbWF0aW9uX3ZhbHVlIjogMiwiYnVpbGRlci5kdWNrIG1vdmUuZXBkX2xlZnQiOiAxMiwiYnVpbGRlci5zbG93LmRlZl9waXRjaF9udW0iOiAtMjgsImJ1aWxkZXIudXNlLmRlZl9sZWZ0IjogLTM0LCJidWlsZGVyLmR1Y2suZGVmX2xlZnQiOiAtMzQsImJ1aWxkZXIuYWlyYy5kZWZfeWF3IjogImRlbGF5ZWQiLCJidWlsZGVyLmlkbGUuZXBkX2xlZnQiOiAyNCwiYnVpbGRlci5pZGxlLnlhd19yYW5kb21pemUiOiA3LCJidWlsZGVyLm9uIHNob3QuZXBkX2xlZnQiOiAtMjgsImJ1aWxkZXIudXNlLmVuYWJsZSI6IHRydWUsImJ1aWxkZXIuaWRsZS4yIjogMCwiYnVpbGRlci5tYW51YWwuZGVmX3JpZ2h0IjogMjYsImJ1aWxkZXIub24gc2hvdC43IjogMCwiYnVpbGRlci5vbiBzaG90LmRlZl9waXRjaF9udW0iOiAtMjgsImJ1aWxkZXIudXNlLmJyZWFrX2xjIjogZmFsc2UsImJ1aWxkZXIuc2FmZSBoZWFkLmRlZl9yaWdodCI6IDI2LCJidWlsZGVyLm1hbnVhbC5leHBhbmQiOiAib2ZmIiwiYnVpbGRlci5kdWNrLjYiOiAwLCJ1dGlsaXR5LmtpbGxzYXkiOiB0cnVlLCJidWlsZGVyLmlkbGUuMSI6IDAsImJ1aWxkZXIucnVuLnNwZWVkIjogMSwiYnVpbGRlci5zYWZlIGhlYWQueF93YXlsYWJlbCI6ICJ3YXkgMyIsImJ1aWxkZXIuZHVjay4xIjogMCwiYnVpbGRlci5haXJjLmppdHRlcl9hZGQiOiAyMiwiYnVpbGRlci5pZGxlLjMiOiAwLCJidWlsZGVyLm1hbnVhbC42IjogMCwiYWltYm90LnF1aWNrX3N0b3AuaG90a2V5X21vZGVfaWR4IjogMCwidXRpbGl0eS5idXlib3Rfc2Vjb25kYXJ5IjogInRlYy05IC8gZml2ZS1zIC8gY3otNzUiLCJidWlsZGVyLmR1Y2suYnlfbnVtIjogNSwiYnVpbGRlci5ydW4uZGVmZW5zaXZlIjogdHJ1ZSwiYnVpbGRlci5leHRlbnNpb25zLm1hbnVhbF9hYV9ob3RrZXkubWFudWFsX2xlZnQuaG90a2V5X21vZGVfaWR4IjogMSwiYnVpbGRlci5zYWZlIGhlYWQuZXBkX3dheSI6IDAsImJ1aWxkZXIuc2xvdy5hZGQiOiAwLCJidWlsZGVyLnNhZmUgaGVhZC42IjogMCwiYnVpbGRlci5mYWtlbGFnLmVwZF9yaWdodCI6IC0yOCwiYnVpbGRlci5mYWtlbGFnLnhfd2F5IjogMywiYnVpbGRlci5tYW51YWwuZGVmX2xlZnQiOiAtMzQsImJ1aWxkZXIuYWlyYy5lcGRfbGVmdCI6IDAsImJ1aWxkZXIucnVuLmJyZWFrX2xjIjogdHJ1ZSwidmlzdWFscy5zdGlja21hbiI6IGZhbHNlLCJidWlsZGVyLm9uIHNob3QueWF3X3JhbmRvbWl6ZSI6IDAsImJ1aWxkZXIubWFudWFsLjciOiAwLCJidWlsZGVyLmFpcmMueF93YXlsYWJlbCI6ICJ3YXkgMyIsImJ1aWxkZXIudXNlLjYiOiAwLCJidWlsZGVyLmlkbGUuZGVmX3JpZ2h0IjogMjYsImJ1aWxkZXIubWFudWFsLmJ5X251bSI6IDAsImJ1aWxkZXIuZXh0ZW5zaW9ucy53YXJtdXBfYWEiOiBbIndhcm11cCJdLCJidWlsZGVyLnNhZmUgaGVhZC4xIjogMCwiYnVpbGRlci5haXIuZXBkX3dheSI6IDAsImJ1aWxkZXIuZmFrZWxhZy5qaXR0ZXIiOiAib2Zmc2V0IiwiYnVpbGRlci5haXIuZGVmX2xlZnQiOiAtMzQsImJ1aWxkZXIuYWlyLmJ5X21vZGUiOiAiaml0dGVyIiwiYnVpbGRlci5tYW51YWwuZXBkX3JpZ2h0IjogMTAsImJ1aWxkZXIudXNlLmJ5X251bSI6IDEyLCJidWlsZGVyLnNsb3cuNCI6IDAsImJ1aWxkZXIuc2xvdy55YXdfcmFuZG9taXplIjogMCwiYnVpbGRlci5zbG93LmVwZF9yaWdodCI6IC0yOCwidmlzdWFscy5zdGlja21hbi5jb2xvciI6IFsyNTUsMjU1LDI1NSwxNDBdLCJidWlsZGVyLmZyZWVzdGFuZC42IjogMCwiYnVpbGRlci5tYW51YWwuYmFzZSI6ICJhdCB0YXJnZXRzIiwiYnVpbGRlci5haXJjLmVwZF93YXkiOiAwLCJidWlsZGVyLm9uIHNob3QueF93YXlsYWJlbCI6ICJ3YXkgMyIsImJ1aWxkZXIuc2FmZSBoZWFkLmFkZCI6IDAsImJ1aWxkZXIubWFudWFsLmRlZl95YXdfbnVtIjogLTI4LCJidWlsZGVyLmZha2VsYWcuZGVmX3JpZ2h0IjogMjYsImJ1aWxkZXIuYWlyLmRlZl95YXdfbnVtIjogLTI4LCJidWlsZGVyLnVzZS4yIjogMCwiYnVpbGRlci5vbiBzaG90LmVuYWJsZSI6IGZhbHNlLCJidWlsZGVyLnNsb3cuZGVmX3NwZWVkIjogMSwiYnVpbGRlci5kdWNrIG1vdmUuYnlfbnVtIjogLTI4LCJidWlsZGVyLnNsb3cuZGVmX3JpZ2h0IjogMjYsImJ1aWxkZXIuc2xvdy4yIjogMCwiYnVpbGRlci5kdWNrIG1vdmUuZXhwYW5kIjogImxlZnQvcmlnaHQiLCJidWlsZGVyLnJ1bi5qaXR0ZXIiOiAib2Zmc2V0IiwidmlzdWFscy5zZWNvbmRhcnkuY29sb3IiOiBbMTkzLDE5MywxOTMsMjU1XSwiYnVpbGRlci5kdWNrLmRlZl9yaWdodCI6IDI2LCJ1dGlsaXR5LmhpdHNvdW5kIjogdHJ1ZSwiYnVpbGRlci5ydW4uZGVmX3BpdGNoX251bSI6IC0yOCwiYnVpbGRlci5ydW4uZXBkX3dheSI6IDAsInZpc3VhbHMuYXNwZWN0X3JhdGlvIjogdHJ1ZSwiYnVpbGRlci5zYWZlIGhlYWQuZGVmX2xlZnQiOiAtMzQsImJ1aWxkZXIuc2xvdy5leHBhbmQiOiAibGVmdC9yaWdodCIsImJ1aWxkZXIuZnJlZXN0YW5kLjIiOiAwLCJidWlsZGVyLnNhZmUgaGVhZC55YXdfcmFuZG9taXplIjogMCwiYnVpbGRlci5zbG93LmRlZl95YXciOiAiZGVsYXllZCIsInZpc3VhbHMudGhpcmRwZXJzb24iOiB0cnVlLCJidWlsZGVyLmZha2VsYWcuNiI6IDAsImJ1aWxkZXIuc2FmZSBoZWFkLmJ5X251bSI6IDAsImJ1aWxkZXIucnVuLjUiOiAwLCJidWlsZGVyLmV4dGVuc2lvbnMubWFudWFsX2FhX2hvdGtleS5tYW51YWxfcmlnaHQuaG90a2V5X21vZGVfaWR4IjogMSwiYnVpbGRlci5haXIuNiI6IDAsImJ1aWxkZXIuZmFrZWxhZy55YXdfcmFuZG9taXplIjogMCwiYnVpbGRlci5zbG93LmRlZmVuc2l2ZSI6IHRydWUsImJ1aWxkZXIudXNlLmRlbGF5IjogMSwiYnVpbGRlci51c2UuMyI6IDAsImJ1aWxkZXIuYWlyYy5ieV9tb2RlIjogImppdHRlciIsImJ1aWxkZXIub24gc2hvdC5kZWZfc3BlZWQiOiAxLCJidWlsZGVyLmV4dGVuc2lvbnMubWFudWFsX2FhX2hvdGtleS5tYW51YWxfcmlnaHQuaG90a2V5X2tleWNvZGUiOiA2NywiYnVpbGRlci5vbiBzaG90LmJyZWFrX2xjIjogdHJ1ZSwiYnVpbGRlci5kdWNrLmVwZF9yaWdodCI6IDAsImJ1aWxkZXIuYWlyYy55YXdfcmFuZG9taXplIjogMCwidmlzdWFscy52Z3VpLmNvbG9yIjogWzEzNSwxMzUsMTM1LDI1NV0sImJ1aWxkZXIuZmFrZWxhZy5lcGRfbGVmdCI6IC0yOCwiYnVpbGRlci5vbiBzaG90LmVwZF9yaWdodCI6IC0yOCwiYnVpbGRlci5leHRlbnNpb25zLmFudGlfYmFja3N0YWIiOiB0cnVlLCJidWlsZGVyLnNhZmUgaGVhZC5leHBhbmQiOiAib2ZmIiwiYnVpbGRlci5tYW51YWwuZXBkX3dheSI6IDAsImJ1aWxkZXIuZmFrZWxhZy5lbmFibGUiOiB0cnVlLCJidWlsZGVyLnNsb3cuZGVmX2JvZHkiOiAiaml0dGVyIiwiYnVpbGRlci5mYWtlbGFnLnNwZWVkIjogMSwiYnVpbGRlci5haXIuYnJlYWtfbGMiOiB0cnVlLCJidWlsZGVyLmZha2VsYWcuZGVmX2xlZnQiOiAtMzQsInZpc3VhbHMudGhpcmRwZXJzb25fc2xpZGVyIjogNDUsImJ1aWxkZXIubWFudWFsLnhfd2F5bGFiZWwiOiAid2F5IDMiLCJidWlsZGVyLnNsb3cuYmFzZSI6ICJhdCB0YXJnZXRzIiwiYnVpbGRlci5leHRlbnNpb25zLnNhZmVfaGVhZCI6IFsia25pZmUiLCJ6ZXVzIl0sImJ1aWxkZXIudXNlLmVwZF9yaWdodCI6IC0yOCwiYnVpbGRlci5mYWtlbGFnLmRlZl95YXciOiAiZGVsYXllZCIsImJ1aWxkZXIuaWRsZS5kZWZfc3BlZWQiOiAxLCJidWlsZGVyLmRlZmF1bHQueWF3X3JhbmRvbWl6ZSI6IDAsImJ1aWxkZXIuZHVjay5ieV9tb2RlIjogIm9wcG9zaXRlIiwiYWltYm90LnJlc29sdmVyX21vZGUiOiAiZXhwZXJpbWVudGFsIiwidXRpbGl0eS5vbl9haXJfb3B0aW9ucyI6ICJmcm96ZW4iLCJidWlsZGVyLnNsb3cueF93YXkiOiAzLCJidWlsZGVyLmFpci5lcGRfcmlnaHQiOiAtMywiYnVpbGRlci5kdWNrLmRlZl9waXRjaCI6ICJkZWZhdWx0IiwiYnVpbGRlci5ydW4uZXhwYW5kIjogImxlZnQvcmlnaHQiLCJidWlsZGVyLnJ1bi5lcGRfcmlnaHQiOiAxMiwiYnVpbGRlci5ydW4uZXBkX2xlZnQiOiAtMTIsImJ1aWxkZXIuZmFrZWxhZy43IjogMCwiYnVpbGRlci5haXIuaml0dGVyIjogIm9mZnNldCIsImJ1aWxkZXIucnVuLmJhc2UiOiAiYXQgdGFyZ2V0cyIsImJ1aWxkZXIuYWlyYy43IjogMCwiYnVpbGRlci5zbG93LmJyZWFrX2xjIjogdHJ1ZSwiYnVpbGRlci5tYW51YWwuZGVmX3BpdGNoIjogImRlZmF1bHQiLCJidWlsZGVyLmRlZmF1bHQueF93YXkiOiAzLCJidWlsZGVyLnVzZS5zcGVlZCI6IDEsImJ1aWxkZXIudXNlLmRlZl9zcGVlZCI6IDEsImJ1aWxkZXIub24gc2hvdC5kZWZfbGVmdCI6IC0zNCwiYnVpbGRlci5ydW4uZW5hYmxlIjogdHJ1ZSwiYnVpbGRlci5ydW4ueWF3X3JhbmRvbWl6ZSI6IDAsImJ1aWxkZXIubWFudWFsLmRlbGF5IjogMiwiYnVpbGRlci5haXIuZXhwYW5kIjogImxlZnQvcmlnaHQiLCJidWlsZGVyLmZyZWVzdGFuZC40IjogMCwiYnVpbGRlci5mcmVlc3RhbmQuZXBkX3JpZ2h0IjogMTAsImJ1aWxkZXIucnVuLmRlZl9yaWdodCI6IDM0LCJidWlsZGVyLmZyZWVzdGFuZC5lcGRfbGVmdCI6IC04LCJidWlsZGVyLmR1Y2suZXBkX3dheSI6IDAsImJ1aWxkZXIuZHVjayBtb3ZlLnNwZWVkIjogMSwiYnVpbGRlci5ydW4uZGVmX3NwZWVkIjogMSwiYnVpbGRlci5kdWNrLmVwZF9sZWZ0IjogMCwiYnVpbGRlci51c2UuNyI6IDAsInZpc3VhbHMuYWNjZW50LmNvbG9yIjogWzI1NSwyNTUsMjU1LDI1NV0sImJ1aWxkZXIuZXh0ZW5zaW9ucy5mcmVlc3RhbmRpbmcuaG90a2V5X2tleWNvZGUiOiA2LCJidWlsZGVyLmZyZWVzdGFuZC5qaXR0ZXIiOiAiY2VudGVyIiwiYnVpbGRlci5vbiBzaG90LjQiOiAwLCJidWlsZGVyLmFpci4yIjogMCwiYnVpbGRlci5ydW4uZGVsYXkiOiAyLCJidWlsZGVyLmFpci5lbmFibGUiOiB0cnVlLCJidWlsZGVyLmlkbGUuZGVmX3BpdGNoX251bSI6IC0yOCwiYnVpbGRlci5mcmVlc3RhbmQuMyI6IDAsImJ1aWxkZXIuc2FmZSBoZWFkLjciOiAwLCJidWlsZGVyLm1hbnVhbC5kZWZlbnNpdmUiOiBmYWxzZSwiYnVpbGRlci5haXIuZGVmX2JvZHkiOiAiaml0dGVyIiwiYnVpbGRlci5zbG93LmJ5X21vZGUiOiAiaml0dGVyIiwiYnVpbGRlci5ydW4uYnlfbW9kZSI6ICJqaXR0ZXIiLCJidWlsZGVyLm1hbnVhbC40IjogMCwiYnVpbGRlci5zbG93LjUiOiAwLCJidWlsZGVyLmFpci54X3dheSI6IDMsImJ1aWxkZXIuYWlyLmFkZCI6IDAsImFpbWJvdC5mb3JjZV9yZWNoYXJnZSI6IHRydWUsInZpc3VhbHMuY3Jvc3NoYWlyX3N0eWxlIjogImNlbnRlciIsImJ1aWxkZXIuaWRsZS5kZWZfeWF3X251bSI6IC0yOCwiYnVpbGRlci5zbG93LmVwZF9sZWZ0IjogLTI4LCJidWlsZGVyLmR1Y2sgbW92ZS5kZWZfcGl0Y2hfbnVtIjogLTI4LCJidWlsZGVyLmFpcmMuZGVmX3BpdGNoIjogImRlZmF1bHQiLCJidWlsZGVyLnJ1bi4xIjogMCwiYnVpbGRlci5leHRlbnNpb25zLm1hbnVhbF9hYV9ob3RrZXkubWFudWFsX3JpZ2h0IjogZmFsc2UsImJ1aWxkZXIuZXh0ZW5zaW9ucy5kZWZlbnNpdmUiOiBbIm9uIHNob3QiLCJmbGFzaGVkIiwiZGFtYWdlIHJlY2VpdmVkIiwicmVsb2FkaW5nIiwid2VhcG9uIHN3aXRjaCJdLCJidWlsZGVyLnJ1bi5kZWZfbGVmdCI6IC0zNCwiYnVpbGRlci5kdWNrIG1vdmUuMiI6IDAsImJ1aWxkZXIuYWlyLjMiOiAwLCJ2aXN1YWxzLmxvZ2dpbmdfb3B0aW9uc19jb25zb2xlIjogWyJoaXQiLCJtaXNzIiwiYnV5IiwiYWltYm90Il0sImJ1aWxkZXIuYWlyYy5kZWZfcmlnaHQiOiAyNiwiYnVpbGRlci5haXJjLmV4cGFuZCI6ICJsZWZ0L3JpZ2h0IiwiYnVpbGRlci5kdWNrLnhfd2F5bGFiZWwiOiAid2F5IDMiLCJidWlsZGVyLmZha2VsYWcuZGVmX2JvZHkiOiAiaml0dGVyIiwiYnVpbGRlci51c2UueF93YXkiOiAzLCJidWlsZGVyLnNhZmUgaGVhZC5kZWZlbnNpdmUiOiBmYWxzZSwiYnVpbGRlci5leHRlbnNpb25zLmxhZGRlciI6IHRydWUsImJ1aWxkZXIuZHVjay40IjogMCwiYnVpbGRlci5kdWNrLmJyZWFrX2xjIjogdHJ1ZSwiYnVpbGRlci5mcmVlc3RhbmQuMSI6IDAsImJ1aWxkZXIuZHVjay5leHBhbmQiOiAibGVmdC9yaWdodCIsImJ1aWxkZXIuZmFrZWxhZy5kZWxheSI6IDIsImJ1aWxkZXIuZXh0ZW5zaW9ucy5lZGdlX3lhdy5ob3RrZXlfbW9kZV9pZHgiOiAxLCJidWlsZGVyLmR1Y2suc3BlZWQiOiAxLCJidWlsZGVyLmZyZWVzdGFuZC54X3dheSI6IDMsImJ1aWxkZXIuZHVjayBtb3ZlLjUiOiAwLCJidWlsZGVyLnNhZmUgaGVhZC5lcGRfbGVmdCI6IDAsImJ1aWxkZXIucnVuLjQiOiAwLCJidWlsZGVyLnVzZS41IjogMCwiYnVpbGRlci51c2UuYmFzZSI6ICJsb2NhbCB2aWV3IiwiYnVpbGRlci5zYWZlIGhlYWQuYnlfbW9kZSI6ICJzdGF0aWMiLCJidWlsZGVyLnVzZS5hbGxvd191c2VfYWEiOiB0cnVlLCJidWlsZGVyLmlkbGUuZXBkX3JpZ2h0IjogLTEwLCJidWlsZGVyLnNhZmUgaGVhZC5kZWZfcGl0Y2giOiAiZGVmYXVsdCIsImJ1aWxkZXIuYWlyLmRlbGF5IjogMSwiYnVpbGRlci5leHRlbnNpb25zLm1hbnVhbF9hYV9ob3RrZXkubWFudWFsX2ZvcndhcmQuaG90a2V5X21vZGVfaWR4IjogMSwiYnVpbGRlci5leHRlbnNpb25zLmRpc19mcyI6IFsiaWRsZSIsInJ1biJdfX0="

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

    function configs.collect()
        local out = { version = 1, values = {}, widgets = {} }
        collect_group('aimbot', interface.aimbot, out)
        collect_group('visuals', interface.visuals, out)
        collect_group('utility', interface.utility, out)
        collect_group('builder', interface.builder, out)
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
        apply_group('builder', interface.builder, values)
        if data.widgets then
            local key = (widgets and widgets.db_key_prefix or 'noctua.widgets.positions') .. '.' .. screen_key()
            pcall(database.write, key, data.widgets)
            widgets.load_from_db()
            streamer_mode.load_db()
        end
    end

    function configs.apply_aa_only(data)
        if type(data) ~= 'table' then return end
        local values = data.values or {}
        apply_group('builder', interface.builder, values)
    end

    function configs.export_to_clipboard()
        local payload = configs.collect()
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
        logMessage('noctua · config', '', 'config imported successfully!')
        client.exec("play ui/beepclear.wav")
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

    function configs.load_selected()
        local name = get_selected_name()
        if not name then
            logMessage('noctua · config', '', 'select a config first!')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        if name == 'default' then
            configs.load_default()
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
        logMessage('noctua · config', '', 'config loaded!')
        client.exec("play ui/beepclear.wav")
    end

    function configs.load_aa_only()
        local name = get_selected_name()
        if not name then
            logMessage('noctua · config', '', 'select a config first!')
            client.exec("play ui/menu_invalid.wav")
            return
        end
        if name == 'default' then
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
            configs.apply_aa_only(data)
            logMessage('noctua · config', '', 'anti-aim loaded from default!')
            client.exec("play ui/beepclear.wav")
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
        configs.apply_aa_only(data)
        logMessage('noctua · config', '', 'anti-aim loaded!')
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
        
        if interface.config.name then
            interface.config.name:set_visible(is_new)
        end

        if interface.config.create_button then
            interface.config.create_button:set_visible(is_new)
        end
        
        if interface.config.load_button then
            interface.config.load_button:set_visible(has_config)
        end
        
        if interface.config.load_aa_button then
            interface.config.load_aa_button:set_visible(has_config)
        end
        
        if interface.config.load_on_startup then
            interface.config.load_on_startup:set_visible(has_config)
            if has_config and name then
                interface.config.load_on_startup:set(state.load_on_startup == name)
            end
        end
        
        local show_user_buttons = has_config and not is_default
        if interface.config.save_button then
            interface.config.save_button:set_visible(show_user_buttons)
        end
        
        if interface.config.import_button then
            interface.config.import_button:set_visible(not is_new)
        end

        if interface.config.export_button then
            interface.config.export_button:set_visible(not is_new)
        end

        if interface.config.delete_button then
            interface.config.delete_button:set_visible(show_user_buttons)
        end
    end
    
    function configs.update_load_on_startup_checkbox()
        configs.update_ui_visibility()
    end
    
    function configs.load_startup_config()
        if not state.load_on_startup then return end

        if state.load_on_startup == 'default' then
            configs.load_default()
            return
        end

        if state.data[state.load_on_startup] then
            configs.apply(state.data[state.load_on_startup])
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

        interface.config.load_aa_button:set_callback(configs.load_aa_only)

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

--@region: lethal_shot_handler
lethal_shot_handler = {} do
    lethal_shot_handler.cache = {}
    lethal_shot_handler.lethal_threshold = 75
    lethal_shot_handler.settings_persist_time = 2.0
    lethal_shot_handler.min_misses_for_safety = 2
    
    lethal_shot_handler.is_lethal = function(self, idx)
        if not idx or not entity.is_alive(idx) then
            return false
        end
        
        local health = entity.get_prop(idx, "m_iHealth")
        if not health or health >= 100 then
            return false
        end
        
        local local_player = entity.get_local_player()
        if not local_player or not entity.is_alive(local_player) then
            return health <= self.lethal_threshold
        end
        
        local local_eye_pos = {client.eye_position()}
        if not local_eye_pos[1] then
            return health <= self.lethal_threshold
        end
        
        local hitboxes = {0, 3, 4, 5, 6}
        local max_damage = 0
        
        for _, hitbox in ipairs(hitboxes) do
            local target_pos = {entity.hitbox_position(idx, hitbox)}
            if target_pos[1] then
                local _, damage = client.trace_bullet(
                    local_player,
                    local_eye_pos[1], local_eye_pos[2], local_eye_pos[3],
                    target_pos[1], target_pos[2], target_pos[3],
                    false
                )
                
                if damage and damage > max_damage then
                    max_damage = damage
                end
            end
        end
        
        if max_damage <= 0 then
            local weapon_damage = self:get_weapon_damage(local_player)
            local has_armor = entity.get_prop(idx, "m_ArmorValue") > 0
            max_damage = has_armor and weapon_damage * 0.8 or weapon_damage
        end
        
        return health <= max_damage and health <= self.lethal_threshold and max_damage >= health * 0.9
    end
    
    lethal_shot_handler.get_weapon_damage = function(self, local_player)
        local weapon = entity.get_player_weapon(local_player)
        if not weapon then return 0 end
        
        local weapon_idx = entity.get_prop(weapon, "m_iItemDefinitionIndex")
        if not weapon_idx then return 0 end
        
        local damage_table = {
            [1] = 29,   -- deagle
            [2] = 38,   -- dual berettas
            [3] = 27,   -- fiveseven
            [4] = 30,   -- glock
            [7] = 30,   -- ak47
            [8] = 25,   -- aug
            [9] = 115,  -- awp
            [10] = 26,  -- famas
            [11] = 30,  -- g3sg1
            [13] = 30,  -- galil
            [14] = 30,  -- m249
            [16] = 33,  -- m4a1
            [17] = 29,  -- mac10
            [19] = 32,  -- p90
            [23] = 92,  -- ssg08
            [24] = 25,  -- ump45
            [25] = 30,  -- xm1014
            [26] = 86,  -- pp-bizon
            [27] = 30,  -- mag7
            [28] = 23,  -- negev
            [29] = 35,  -- sawed off
            [30] = 88,  -- tec9
            [31] = 30,  -- zeus
            [32] = 35,  -- p2000
            [33] = 27,  -- mp7
            [34] = 29,  -- mp9
            [35] = 115, -- nova
            [36] = 37,  -- p250
            [38] = 115, -- scar-20
            [39] = 26,  -- sg553
            [40] = 33,  -- ssg08
            [41] = 35,  -- knife
            [42] = 35,  -- knife
            [59] = 33,  -- m4a1-s
            [60] = 29,  -- usp-s
            [61] = 35,  -- cz75a
            [63] = 115, -- revolver
            [64] = 35,  -- knife
        }
        
        return damage_table[weapon_idx] or 30
    end
    
    lethal_shot_handler.should_force_safe_point = function(self, idx)
        local health = entity.get_prop(idx, "m_iHealth")
        if health and health >= 100 then
            return false, 0.0
        end

        local cache = self:update_cache(idx)
        local curtime = globals.curtime()

        local should_persist = cache.was_lethal and (curtime - cache.last_visible_time < self.settings_persist_time)
        
        if cache.is_lethal or should_persist then
            return true, 1.0
        end
        
        if cache.misses > 2 then
            return true, 0.8
        end
        
        return false, 0.0
    end
    
    lethal_shot_handler.on_miss = function(self, idx)
        if not self.cache[idx] then
            self.cache[idx] = {
                last_check = 0,
                is_lethal = false,
                misses = 0,
                hits = 0,
                safe_point_misses = 0,
                last_visible_time = 0,
                was_lethal = false,
                logged_safe_point = false,
                logged_body_aim = false
            }
        end
        
        self.cache[idx].misses = self.cache[idx].misses + 1
        
        local safe_point_status = plist.get(idx, 'Override safe point')
        local body_aim_status = plist.get(idx, 'Override prefer body aim')
        
        if safe_point_status == "On" then
            self.cache[idx].safe_point_misses = self.cache[idx].safe_point_misses + 1
            
            if body_aim_status == "-" or body_aim_status == "" then
                plist.set(idx, 'Override prefer body aim', "On")
            elseif body_aim_status == "On" then
                plist.set(idx, 'Override prefer body aim', "Force")
            end
        end
    end
    
    lethal_shot_handler.on_hit = function(self, idx)
        if not self.cache[idx] then
            self.cache[idx] = {
                last_check = 0,
                is_lethal = false,
                misses = 0,
                hits = 0,
                safe_point_misses = 0,
                last_visible_time = 0,
                was_lethal = false,
                logged_safe_point = false,
                logged_body_aim = false
            }
        end
        
        self.cache[idx].hits = self.cache[idx].hits + 1
        self.cache[idx].misses = math.max(0, self.cache[idx].misses - 1)
        self.cache[idx].safe_point_misses = 0

        local health = entity.get_prop(idx, "m_iHealth")
        if health and health > self.lethal_threshold then
            self.cache[idx].was_lethal = false
        end
    end
    
    lethal_shot_handler.reset = function(self, idx)
        if self.cache[idx] then
            self.cache[idx].misses = 0
            self.cache[idx].hits = 0
            self.cache[idx].safe_point_misses = 0
            self.cache[idx].last_visible_time = 0
            self.cache[idx].was_lethal = false
            self.cache[idx].logged_safe_point = false
            self.cache[idx].logged_body_aim = false

            if idx and type(idx) == "number" and entity.is_enemy(idx) then
                plist.set(idx, 'Override safe point', "-")
                plist.set(idx, 'Override prefer body aim', "-")
            end
        end
    end

    lethal_shot_handler.setup = function(self)
        if not (interface.aimbot.enabled_aimbot:get() and interface.aimbot.enabled_resolver_tweaks:get() and interface.aimbot.smart_safety:get()) then 
            return 
        end

        local local_player = entity.get_local_player()
        if not local_player or not entity.is_alive(local_player) then
            return
        end

        local target = client.current_threat()
        if not target or not entity.is_alive(target) or not entity.is_enemy(target) then
            return
        end

        self:check_respawn(target)

        local should_force, confidence = self:should_force_safe_point(target)
        local cache = self.cache[target]
        
        if should_force then
            if target and type(target) == "number" then
                local current_safe_point = plist.get(target, 'Override safe point')
                
                plist.set(target, 'Override safe point', "On")
                
                if current_safe_point ~= "On" and interface.visuals.logging:get() then
                    local playerName = entity.get_player_name(target)
                    local health = entity.get_prop(target, "m_iHealth") or 0
                    local reason = ""
                    
                        local curtime = globals.curtime()
                        local should_persist = cache.was_lethal and (curtime - cache.last_visible_time < self.settings_persist_time)
                        
                        if cache.is_lethal or should_persist then
                            reason = "lethal target"
                        elseif cache.misses > 2 then
                            reason = "aim struggle"
                        else
                            reason = "unknown"
                        end
                    
                    local msg = string.format("forced safe point for %s / hp: %d - reason: %s", playerName, health, reason)
                    
                    local logOptions = interface.visuals.logging_options:get()
                    local consoleOptions = interface.visuals.logging_options_console:get()
                    local screenOptions = interface.visuals.logging_options_screen:get()
                    
                    local doConsole = utils.contains(logOptions, "console") and utils.contains(consoleOptions, "aimbot")
                    local doScreen = utils.contains(logOptions, "screen") and utils.contains(screenOptions, "aimbot")
                    
                    if doConsole then
                        argLog("forced safe point for %s / hp: %d - reason: %s", playerName, health, reason)
                    end
                    
                    if doScreen then
                        logging:push(msg)
                    end
                    
                    self.cache[target].logged_safe_point = true
                end
            end
        else
            local curtime = globals.curtime()
            local time_since_visible = curtime - cache.last_visible_time
            
            if time_since_visible > self.settings_persist_time or not cache.was_lethal then
                if target and type(target) == "number" then
                    plist.set(target, 'Override safe point', "-")
                    plist.set(target, 'Override prefer body aim', "-")
                    self.cache[target].logged_safe_point = false
                end
            end
        end
    end
    
    lethal_shot_handler.process_all_players = function(self)
        if not (interface.aimbot.enabled_aimbot:get() and interface.aimbot.enabled_resolver_tweaks:get() and interface.aimbot.smart_safety:get()) then 
            return 
        end
        
        local local_player = entity.get_local_player()
        if not local_player or not entity.is_alive(local_player) then
            return
        end

        local enemies = entity.get_players(true)
        if not enemies then return end

        local smart_safety_enabled = interface.aimbot.smart_safety:get()

        if not smart_safety_enabled then
        for _, idx in ipairs(enemies) do
                if idx and type(idx) == "number" and entity.is_alive(idx) and entity.is_enemy(idx) then
                    plist.set(idx, 'Override safe point', "-")
                    plist.set(idx, 'Override prefer body aim', "-")
                end
            end
            return
        end
        
        for _, idx in ipairs(enemies) do
            if idx and type(idx) == "number" and entity.is_alive(idx) and entity.is_enemy(idx) then
                self:check_respawn(idx)
                
                local should_force, confidence = self:should_force_safe_point(idx)
                
                if not self.cache[idx] then
                    self.cache[idx] = {
                        last_check = 0,
                        is_lethal = false,
                        misses = 0,
                        hits = 0,
                        safe_point_misses = 0,
                        last_visible_time = 0,
                        was_lethal = false,
                        logged_safe_point = false,
                        logged_body_aim = false
                    }
                end
                
                if self:is_visible(idx) then
                    self.cache[idx].last_visible_time = globals.curtime()
                end
                
                if should_force then
                    local current_safe_point = plist.get(idx, 'Override safe point')
                    
                    plist.set(idx, 'Override safe point', "On")
                    
                    if not self.cache[idx].logged_safe_point and interface.visuals.logging:get() then
                        local playerName = entity.get_player_name(idx)
                        local health = entity.get_prop(idx, "m_iHealth") or 0
                        local reason = ""
                        
                        local curtime = globals.curtime()
                        local should_persist = self.cache[idx].was_lethal and (curtime - self.cache[idx].last_visible_time < self.settings_persist_time)
                        
                        if self.cache[idx].is_lethal or should_persist then
                            reason = "lethal target"
                        elseif self.cache[idx].misses > 2 then
                            reason = "aim struggle"
                        else
                            reason = "unknown"
                        end
                        
                        local msg = string.format("forced safe point for %s / hp: %d - reason: %s", playerName, health, reason)
                        
                        local logOptions = interface.visuals.logging_options:get()
                        local consoleOptions = interface.visuals.logging_options_console:get()
                        local screenOptions = interface.visuals.logging_options_screen:get()
                        
                        local doConsole = utils.contains(logOptions, "console") and utils.contains(consoleOptions, "aimbot")
                        local doScreen = utils.contains(logOptions, "screen") and utils.contains(screenOptions, "aimbot")
                        
                        if doConsole then
                            argLog("forced safe point for %s / hp: %d - reason: %s", playerName, health, reason)
                        end
                        
                        if doScreen then
                            logging:push(msg)
                        end
                        
                        self.cache[idx].logged_safe_point = true
                    end
                else
                    local curtime = globals.curtime()
                    local time_since_visible = curtime - self.cache[idx].last_visible_time
                    
                    if time_since_visible > self.settings_persist_time or not self.cache[idx].was_lethal then
                        plist.set(idx, 'Override safe point', "-")
                        plist.set(idx, 'Override prefer body aim', "-")
                        
                        self.cache[idx].logged_safe_point = false
                        self.cache[idx].logged_body_aim = false
                    end
                end
            end
        end
    end

    lethal_shot_handler.is_visible = function(self, idx)
        if not idx or not entity.is_alive(idx) then
            return false
        end
        
        local local_player = entity.get_local_player()
        if not local_player or not entity.is_alive(local_player) then
            return false
        end
        
        local hitboxes = {0, 3, 4, 5, 6}
        
        for _, hitbox in ipairs(hitboxes) do
            local target_pos = {entity.hitbox_position(idx, hitbox)}
            if target_pos[1] then
                if client.visible(target_pos[1], target_pos[2], target_pos[3]) then
                    return true
                end
            end
        end
        
        return false
    end

    lethal_shot_handler.update_cache = function(self, idx)
        if not self.cache[idx] then
            self.cache[idx] = {
                last_check = 0,
                is_lethal = false,
                misses = 0,
                hits = 0,
                safe_point_misses = 0,
                last_visible_time = 0,
                was_lethal = false,
                logged_safe_point = false,
                logged_body_aim = false
            }
        end
        
        local health = entity.get_prop(idx, "m_iHealth")
        if health and health >= 100 then
            self.cache[idx].is_lethal = false
            self.cache[idx].was_lethal = false
            self.cache[idx].logged_safe_point = false
            self.cache[idx].logged_body_aim = false
            
            return self.cache[idx]
        end
        
        if self:is_visible(idx) then
            self.cache[idx].last_visible_time = globals.curtime()
            
            local curtime = globals.curtime()
            if curtime - self.cache[idx].last_check > 1.0 then
                self.cache[idx].last_check = curtime
                self.cache[idx].is_lethal = self:is_lethal(idx)
                
                if self.cache[idx].is_lethal then
                    self.cache[idx].was_lethal = true
                end
            end
        end
        
        return self.cache[idx]
    end

    lethal_shot_handler.check_respawn = function(self, idx)
        if not idx or not entity.is_alive(idx) then
            return
        end
        
        local health = entity.get_prop(idx, "m_iHealth")
        if not health then
            return
        end

        if health >= 100 then
            self:reset(idx)
            
            if self.cache[idx] then
                self.cache[idx].is_lethal = false
                self.cache[idx].was_lethal = false
                self.cache[idx].logged_safe_point = false
                self.cache[idx].logged_body_aim = false
            end
            
            if idx and type(idx) == "number" and entity.is_enemy(idx) then
                plist.set(idx, 'Override safe point', "-")
                plist.set(idx, 'Override prefer body aim', "-")
            end
            
            self:update_cache(idx)
        end
    end
end

client.set_event_callback('aim_fire', function(e)
    local target = e.target
    if target and entity.is_enemy(target) then
        lethal_shot_handler:setup()
    end
end)

client.set_event_callback('aim_miss', function(e)
    if e.reason ~= "spread" then
        lethal_shot_handler:on_miss(e.target)
    end
end)

client.set_event_callback('player_hurt', function(e)
    local attacker = client.userid_to_entindex(e.attacker)
    local victim = client.userid_to_entindex(e.userid)
    
    if attacker == entity.get_local_player() and victim ~= attacker and entity.is_enemy(victim) then
        lethal_shot_handler:on_hit(victim)
    end
end)

client.set_event_callback('run_command', function()
    lethal_shot_handler:process_all_players()
end)

client.set_event_callback('player_spawn', function(e)
    local player_idx = client.userid_to_entindex(e.userid)
    if player_idx and entity.is_enemy(player_idx) then
        lethal_shot_handler:reset(player_idx)
        plist.set(player_idx, 'Override safe point', "-")
        plist.set(player_idx, 'Override prefer body aim', "-")
    end
end)

client.set_event_callback('round_start', function()
    local enemies = entity.get_players(true)
    if enemies then
        for _, idx in ipairs(enemies) do
            if idx and entity.is_enemy(idx) then
                lethal_shot_handler:reset(idx)
                plist.set(idx, 'Override safe point', "-")
                plist.set(idx, 'Override prefer body aim', "-")
            end
        end
    end
end)

client.set_event_callback('player_death', function(e)
    local player_idx = client.userid_to_entindex(e.userid)
    if player_idx and entity.is_enemy(player_idx) then
        lethal_shot_handler:reset(player_idx)
        plist.set(player_idx, 'Override safe point', "-")
        plist.set(player_idx, 'Override prefer body aim', "-")
    end
end)

client.set_event_callback('player_spawned', function(e)
    local player_idx = client.userid_to_entindex(e.userid)
    if player_idx and entity.is_enemy(player_idx) then
        lethal_shot_handler:reset(player_idx)
        plist.set(player_idx, 'Override safe point', "-")
        plist.set(player_idx, 'Override prefer body aim', "-")
    end
end)
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

    killsay.kill_json_url = "https://raw.githubusercontent.com/wraithsoul/noctua-gs/refs/heads/main/phrases/kill.json"
    killsay.death_json_url = "https://raw.githubusercontent.com/wraithsoul/noctua-gs/refs/heads/main/phrases/death.json"
    killsay.multi_phrases_kill = {}
    killsay.multi_phrases_death = {}

    killsay.load_phrases_from_url = function(url, target_table, phrase_type)
        if not url or url == "" then
            logMessage('noctua · killsay', '', 'no URL set for ' .. phrase_type .. ' phrases')
            return
        end
    
        http.get(url, function(success, response)
            if success and response and response.status == 200 then
                local ok, decoded = pcall(json.decode, response.body)
                if ok and decoded and type(decoded) == "table" then
                    for i = #target_table, 1, -1 do
                        target_table[i] = nil
                    end
                    for i, phrase_set in ipairs(decoded) do
                        target_table[i] = {}
                        for j, line in ipairs(phrase_set) do
                            target_table[i][j] = tostring(line)
                        end
                    end
                    logMessage('noctua · killsay', '', 'loaded ' .. #target_table .. ' ' .. phrase_type .. ' phrase sets')
                else
                    logMessage('noctua · killsay', '', 'failed to parse JSON for ' .. phrase_type .. ' phrases')
                end
            else
                logMessage('noctua · killsay', '', 'failed to load ' .. phrase_type .. ' phrases (' .. (success and response.status or 'no response') .. ')')
            end
        end)
    end

    killsay.load_all_phrases = function()
        killsay.load_phrases_from_url(killsay.kill_json_url, killsay.multi_phrases_kill, "kill")
        killsay.load_phrases_from_url(killsay.death_json_url, killsay.multi_phrases_death, "death")
    end

    killsay.get_random_phrase = function(phrase_type)
        local current_time = globals.realtime()
        math.randomseed(current_time * 9182)
        
        local phrases_table = phrase_type == "death" and killsay.multi_phrases_death or killsay.multi_phrases_kill
        local index = math.random(1, #phrases_table)
        
        return phrases_table[index]
    end
    
    killsay.calculate_delay = function(text)
        local base_delay = 0.03
        
        local char_delay = 0.035
        
        local human_randomness = 1 + (math.random() * 0.4 - 0.2)
        
        return base_delay + (string.len(text) * char_delay * human_randomness)
    end
    
    killsay.send_phrases = function(phrase_type)
        local initial_delay = 1.0 + math.random() * 0.40
        
        if phrase_type == "death" then
            initial_delay = initial_delay + 1.75
        end
        
        local phrases = killsay.get_random_phrase(phrase_type)
        
        local phrase_count = #phrases
        local total_chars = 0
        
        for i = 1, phrase_count do
            total_chars = total_chars + string.len(phrases[i])
        end
        
        local cumulative_delay = initial_delay
        for i = 1, phrase_count do
            local phrase_delay = killsay.calculate_delay(phrases[i])
            
            local min_between_delay = 0.70
            
            if string.len(phrases[i]) < 10 then
                min_between_delay = 1.00
            end
            
            if phrase_type == "death" then
                min_between_delay = min_between_delay + 1.20
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
        
        local now = globals.realtime()
        if now - killsay.last_say_time < killsay.cooldown then
            return
        end
        
        local attacker = client.userid_to_entindex(e.attacker)
        local victim = client.userid_to_entindex(e.userid)
        local modes = interface.utility.killsay_modes:get()
        
        if attacker == local_player and victim ~= local_player then
            if utils.contains(modes, "on kill") then
                local kd = utils.get_player_kd(local_player)
                if kd ~= nil and kd <= 1.0 then return end
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
    
    killsay.setup = function()
        if interface.utility.killsay:get() then
            client.set_event_callback("player_death", killsay.on_player_death)
        else
            client.unset_event_callback("player_death", killsay.on_player_death)
        end
    end
    
    client.set_event_callback("paint", killsay.setup)

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


do
    local u_reference = {} do
        u_reference.ragebot = {} do
            u_reference.ragebot.enabled = pui.reference("RAGE", "Aimbot", "Enabled")
            u_reference.ragebot.double_tap = pui.reference("RAGE", "Aimbot", "Double tap")
            u_reference.ragebot.dt_limit = {pui.reference("rage", "aimbot", "Double tap fake lag limit")}
            u_reference.ragebot.duck = pui.reference("RAGE", "Other", "Duck peek assist")
            u_reference.ragebot.quick_peek =  pui.reference("Rage", "Other", "Quick peek assist")
            u_reference.ragebot.ovr = { pui.reference('rage', 'aimbot', 'minimum damage override') }
            u_reference.ragebot.force_bodyaim = pui.reference('RAGE', 'Aimbot', 'Force body aim')
            u_reference.ragebot.force_safepoint = pui.reference('RAGE', 'Aimbot', 'Force safe point')
        end

        u_reference.antiaim = {} do
            u_reference.antiaim.enable = pui.reference("AA", "Anti-Aimbot angles", "Enabled")
            u_reference.antiaim.pitch = { pui.reference("AA", "Anti-Aimbot angles", "Pitch") }
            u_reference.antiaim.yaw = { pui.reference("AA", "Anti-Aimbot angles", "Yaw") }
            u_reference.antiaim.base = pui.reference("AA", "Anti-Aimbot angles", "Yaw base")
            u_reference.antiaim.jitter = { pui.reference("AA", "Anti-Aimbot angles", "Yaw jitter") }
            u_reference.antiaim.body = { pui.reference("AA", "Anti-Aimbot angles", "Body yaw") }
            u_reference.antiaim.edge = pui.reference("AA", "Anti-Aimbot angles", "Edge yaw")
            u_reference.antiaim.fs_body = pui.reference("AA", "Anti-Aimbot angles", "Freestanding body yaw")
            u_reference.antiaim.freestand = pui.reference("AA", "Anti-Aimbot angles", "Freestanding")
            u_reference.antiaim.roll = pui.reference("AA", "Anti-Aimbot angles", "Roll")
            u_reference.antiaim.slowmotion = pui.reference("AA", "Other", "Slow motion")
            u_reference.antiaim.onshot = pui.reference("AA", "Other", "On shot anti-aim")
            u_reference.antiaim.leg_movement = pui.reference('AA', 'Other', 'Leg movement')
        end

        u_reference.fakelag = {} do
            u_reference.fakelag.enable = {pui.reference('AA', 'Fake lag', 'Enabled')}
            u_reference.fakelag.amount = pui.reference('AA', 'Fake lag', 'Amount')
            u_reference.fakelag.variance = pui.reference('AA', 'Fake lag', 'Variance')
            u_reference.fakelag.limit = pui.reference('AA', 'Fake lag', 'Limit')
        end
    end

    local u_memory = {} do
        local ffi_ok = true
        pcall(function()
            u_memory.get_client_entity = vtable_bind('client.dll', 'VClientEntityList003', 3, 'void*(__thiscall*)(void***, int)')
        end)

        u_memory.animstate = {} do
            local animstate_t = ffi.typeof 'struct { char pad0[0x18]; float anim_update_timer; char pad1[0xC]; float started_moving_time; float last_move_time; char pad2[0x10]; float last_lby_time; char pad3[0x8]; float run_amount; char pad4[0x10]; void* entity; void* active_weapon; void* last_active_weapon; float last_client_side_animation_update_time; int last_client_side_animation_update_framecount; float eye_timer; float eye_angles_y; float eye_angles_x; float goal_feet_yaw; float current_feet_yaw; float torso_yaw; float last_move_yaw; float lean_amount; char pad5[0x4]; float feet_cycle; float feet_yaw_rate; char pad6[0x4]; float duck_amount; float landing_duck_amount; char pad7[0x4]; float current_origin[3]; float last_origin[3]; float velocity_x; float velocity_y; char pad8[0x4]; float unknown_float1; char pad9[0x8]; float unknown_float2; float unknown_float3; float unknown; float m_velocity; float jump_fall_velocity; float clamped_velocity; float feet_speed_forwards_or_sideways; float feet_speed_unknown_forwards_or_sideways; float last_time_started_moving; float last_time_stopped_moving; bool on_ground; bool hit_in_ground_animation; char pad10[0x4]; float time_since_in_air; float last_origin_z; float head_from_ground_distance_standing; float stop_to_full_running_fraction; char pad11[0x4]; float magic_fraction; char pad12[0x3C]; float world_force; char pad13[0x1CA]; float min_yaw; float max_yaw; } **'
            u_memory.animstate.offset = 0x9960
            u_memory.animstate.get = function (self, ent)
                if not ent then return end
                local client_entity = u_memory.get_client_entity and u_memory.get_client_entity(ent)
                if not client_entity then return end
                return ffi.cast(animstate_t, ffi.cast('uintptr_t', client_entity) + self.offset)[0]
            end
        end

        u_memory.animlayers = {} do
            if not pcall(ffi.typeof, 'bt_animlayer_t') then
                ffi.cdef[[
                    typedef struct {
                        float   anim_time;
                        float   fade_out_time;
                        int     nil;
                        int     activty;
                        int     priority;
                        int     order;
                        int     sequence;
                        float   prev_cycle;
                        float   weight;
                        float   weight_delta_rate;
                        float   playback_rate;
                        float   cycle;
                        int     owner;
                        int     bits;
                    } bt_animlayer_t, *pbt_animlayer_t;
                ]]
            end
            local ok, offset = pcall(function()
                return ffi.cast('int*', ffi.cast('uintptr_t', client.find_signature('client.dll', '\x8B\x89\xCC\xCC\xCC\xCC\x8D\x0C\xD1')) + 2)[0]
            end)
            u_memory.animlayers.offset = ok and offset or 0x2990
            u_memory.animlayers.get = function (self, ent)
                local client_entity = u_memory.get_client_entity and u_memory.get_client_entity(ent)
                if not client_entity then return end
                return ffi.cast('pbt_animlayer_t*', ffi.cast('uintptr_t', client_entity) + self.offset)[0]
            end
        end

        u_memory.activity = {} do
            if not pcall(ffi.typeof, 'bt_get_sequence') then
                ffi.cdef[[ typedef int(__fastcall* bt_get_sequence)(void* entity, void* studio_hdr, int sequence); ]]
            end
            u_memory.activity.offset = 0x2950
            local ok, loc = pcall(function()
                return ffi.cast('bt_get_sequence', client.find_signature('client.dll', '\x55\x8B\xEC\x53\x8B\x5D\x08\x56\x8B\xF1\x83'))
            end)
            u_memory.activity.location = ok and loc or nil
            u_memory.activity.get = function (self, sequence, ent)
                if not self.location then return 0 end
                local client_entity = u_memory.get_client_entity and u_memory.get_client_entity(ent)
                if not client_entity then return 0 end
                local studio_hdr = ffi.cast('void**', ffi.cast('uintptr_t', client_entity) + self.offset)[0]
                if not studio_hdr then return 0 end
                return self.location(client_entity, studio_hdr, sequence)
            end
        end

        u_memory.user_input = {} do
            if not pcall(ffi.typeof, 'bt_cusercmd_t') then
                ffi.cdef[[
                    typedef struct {
                        struct bt_cusercmd_t (*cusercmd)();
                        int     command_number;
                        int     tick_count;
                        float   view[3];
                        float   aim[3];
                        float   move[3];
                        int     buttons;
                    } bt_cusercmd_t;
                ]]
            end
            if not pcall(ffi.typeof, 'bt_get_usercmd') then
                ffi.cdef[[ typedef bt_cusercmd_t*(__thiscall* bt_get_usercmd)(void* input, int, int command_number); ]]
            end
            local ok, vtbl = pcall(function()
                return ffi.cast('void***', ffi.cast('void**', ffi.cast('uintptr_t', client.find_signature('client.dll', '\xB9\xCC\xCC\xCC\xCC\x8B\x40\x38\xFF\xD0\x84\xC0\x0F\x85') or error('sig')) + 1)[0])
            end)
            if ok and vtbl then
                u_memory.user_input.vtbl = vtbl
                u_memory.user_input.location = ffi.cast('bt_get_usercmd', vtbl[0][8])
                u_memory.user_input.get_command = function (self, command_number)
                    return self.location(self.vtbl, 0, command_number)
                end
            else
                u_memory.user_input.get_command = function() return nil end
            end
        end

        u_memory.get_simtime = function(ent)
            local pointer = u_memory.get_client_entity and u_memory.get_client_entity(ent)
            if pointer then
                return entity.get_prop(ent, "m_flSimulationTime"), ffi.cast("float*", ffi.cast("uintptr_t", pointer) + 620)[0]
            else
                return 0
            end
        end
    end

--@region: animation breakers
animation_breakers = {} do
    local char_ptr = ffi.typeof('char*')
    local class_ptr = ffi.typeof('void***')
    local animation_layer_t = ffi.typeof([[struct {
        char pad0[0x18];
        uint32_t sequence;
        float prev_cycle, weight, weight_delta_rate, playback_rate, cycle;
        void *entity;
        char pad1[0x4];
    }**]])

    local nullptr = ffi.new('void*')
    local ground_ticks = 0
    local end_time = 0

    local leg_movement_ref = u_reference.antiaim.leg_movement
    local slowmotion_ref = u_reference.antiaim.slowmotion
    local quick_peek_ref = u_reference.ragebot.quick_peek

    local function get_player_state()
        local me = entity.get_local_player()
        if not me then return 'stand' end

        local vx, vy = entity.get_prop(me, 'm_vecVelocity')
        local speed = math.sqrt(vx*vx + vy*vy)
        local flags = entity.get_prop(me, 'm_fFlags')
        local on_ground = bit.band(flags, 1) == 1
        local duck_amount = entity.get_prop(me, 'm_flDuckAmount')

        if not on_ground then
            return 'air'
        elseif duck_amount > 0.7 then
            return speed > 4 and 'crouch move' or 'crouch'
        elseif speed > 4 then
            return 'move'
        else
            return 'stand'
        end
    end

    animation_breakers.update_pose_params = function(cmd)
        local me = entity.get_local_player()
        if not me or not entity.is_alive(me) then
            return
        end

        local animlayers = u_memory.animlayers:get(me)
        if not animlayers then
            return
        end

        local breakers_enabled = interface.utility.animation_breakers:get()
        if not breakers_enabled then
            return
        end

        if utils.contains(breakers_enabled, 'keus scale') then
            entity.set_prop(me, 'm_flModelScale', 0.5)
            entity.set_prop(me, 'm_ScaleType', 1)
        else
            entity.set_prop(me, 'm_flModelScale', 1)
            entity.set_prop(me, 'm_ScaleType', 0)
        end

        local player_state = get_player_state()
        local on_ground = bit.band(entity.get_prop(me, 'm_fFlags'), 1) == 1

        if utils.contains(breakers_enabled, 'on ground') and on_ground then
            local leg_move = interface.utility.on_ground_options:get()

            if leg_move == 'frozen' then
                entity.set_prop(me, 'm_flPoseParameter', 1, 0)
                leg_movement_ref:set('Always slide')
            elseif leg_move == 'walking' then
                entity.set_prop(me, 'm_flPoseParameter', 0.5, 7)
                leg_movement_ref:set('Never slide')
            elseif leg_move == 'jitter' and player_state == 'move' then
                entity.set_prop(me, 'm_flPoseParameter', client.random_float(0.65, 1), 0)
                leg_movement_ref:set('Always slide')
            elseif leg_move == 'sliding' and player_state == 'move' then
                entity.set_prop(me, 'm_flPoseParameter', 0, 9)
                entity.set_prop(me, 'm_flPoseParameter', 0, 10)
                leg_movement_ref:set('Never slide')
            elseif leg_move == 'star' then
                entity.set_prop(me, 'm_flPoseParameter', 1, globals.tickcount() % 4 > 1 and 0.5 / 10 or 1)
            end
        end

        local move_type = entity.get_prop(me, 'm_MoveType')
        if utils.contains(breakers_enabled, 'on air') and not on_ground and not (move_type == 9 or move_type == 8) then
            local air_legs = interface.utility.on_air_options:get()

            if air_legs == 'frozen' then
                entity.set_prop(me, 'm_flPoseParameter', 1, 6)
            elseif air_legs == 'walking' then
                local cycle = globals.realtime() * 0.7 % 2
                if cycle > 1 then
                    cycle = 1 - (cycle - 1)
                end
                animlayers[6]['weight'] = 1
                animlayers[6]['cycle'] = cycle
            elseif air_legs == 'kinguru' then
                entity.set_prop(me, 'm_flPoseParameter', math.random(0, 10) / 10, 6)
            end
        end

        if utils.contains(breakers_enabled, 'sliding slow motion') and slowmotion_ref.hotkey:get() then
            entity.set_prop(me, 'm_flPoseParameter', 0, 9)
        end

        if utils.contains(breakers_enabled, 'sliding crouch') and (player_state == 'crouch' or player_state == 'crouch move') then
            entity.set_prop(me, 'm_flPoseParameter', 0, 8)
        end

        if utils.contains(breakers_enabled, 'zero on land') and u_memory.animstate:get(me).hit_in_ground_animation and on_ground then
            entity.set_prop(me, 'm_flPoseParameter', 0.5, 12)
        end

        if utils.contains(breakers_enabled, 'earthquake') then
            local player_ptr = ffi.cast(class_ptr, u_memory.get_client_entity(ffi.cast('int', me)))
            if player_ptr ~= nullptr then
                local anim_layers = ffi.cast(animation_layer_t, ffi.cast(char_ptr, player_ptr) + 0x2990)[0]
                if anim_layers ~= nullptr then
                    anim_layers[12].weight = client.random_float(-0.3, 0.75)
                end
            end
        end

        if utils.contains(breakers_enabled, 'body lean') then
            local player_ptr = ffi.cast(class_ptr, u_memory.get_client_entity(ffi.cast('int', me)))
            if player_ptr ~= nullptr then
                local anim_layers = ffi.cast(animation_layer_t, ffi.cast(char_ptr, player_ptr) + 0x2990)[0]
                if anim_layers ~= nullptr then
                    local body_lean_value = interface.utility.body_lean_amount:get() or 50
                    anim_layers[12].weight = body_lean_value / 100
                end
            end
        end
    end

    animation_breakers.post = function(cmd)
        if utils.contains(interface.utility.animation_breakers:get() or {}, 'quick peek legs') and quick_peek_ref.hotkey:get() then
            local me = entity.get_local_player()
            local move_type = entity.get_prop(me, 'm_MoveType')

            if move_type == 2 then
                local command = u_memory.user_input:get_command(cmd.command_number)
                if command then
                    command.buttons = bit.band(command.buttons, bit.bnot(8))
                    command.buttons = bit.band(command.buttons, bit.bnot(16))
                    command.buttons = bit.band(command.buttons, bit.bnot(512))
                    command.buttons = bit.band(command.buttons, bit.bnot(1024))
                end
            end
        end
    end

    animation_breakers.setup = function()
        if interface.utility.animation_breakers:get() then
            client.set_event_callback('pre_render', animation_breakers.update_pose_params)
            client.set_event_callback('post', animation_breakers.post)
        else
            client.unset_event_callback('pre_render', animation_breakers.update_pose_params)
            client.unset_event_callback('post', animation_breakers.post)
        end
    end

    client.set_event_callback('paint', animation_breakers.setup)
end
--@endregion

    local u_math = {} do
        u_math.normalize_yaw = function(a)
            while a > 180 do a = a - 360 end
            while a < -180 do a = a + 360 end
            return a
        end
        u_math.lerp = function(a, b, w) return a + (b - a) * w end
        u_math.contains = function(tbl, value)
            local tbl_len = #tbl
            for i=1, tbl_len do if tbl[i] == value then return true end end
            return false
        end
        u_math.extend_vector = function(pos, length, angle)
            local rad = angle * math.pi / 180
            if not angle or not pos or not length then return end
            return { pos[1] + (math.cos(rad) * length), pos[2] + (math.sin(rad) * length), pos[3] }
        end
        u_math.closest_ray_point = function(p, s, e)
            local t, d = p - s, e - s
            local l = d:length()
            d = d / l
            local r = d:dot(t)
            if r < 0 then return s elseif r > l then return e end
            return s + d * r
        end
    end

    local u_player = {
        shifting = false,
        defensive = false,
        onground = false,
        is_fs_peek = false,
        duckamount = 0,
        speed = 0,
        packets = 0,
        fs_side = 'none',
        state = 'idle',
        body_yaw = 0.0,
        get_players = {},
        lc_left = 0.0,
        crouching = false,
    }

    do
        local last_commandnumber
        local tickbase_max = 0
        local function get_double_tap()
            local me = entity.get_local_player()
            local m_nTickBase = me and entity.get_prop(me, 'm_nTickBase') or 0
            local client_latency = client.latency()
            local shift = math.floor(m_nTickBase - globals.tickcount() - 3 - toticks(client_latency) * .5 + .5 * (client_latency * 10))
            local wanted = -14 + ((u_reference.ragebot.dt_limit[1] and u_reference.ragebot.dt_limit[1]:get() or 1) - 1) + 3
            return shift <= wanted
        end
        local function defensive_predict(cmd)
            local me = entity.get_local_player()
            if not me or last_commandnumber ~= cmd.command_number then return false end
            local tickbase = entity.get_prop(me, "m_nTickBase") or 0
            if math.abs(tickbase - tickbase_max) > 64 then tickbase_max = 0 end
            if tickbase > tickbase_max then
                tickbase_max = tickbase
            end
            u_player.lc_left = math.min(14, math.max(0, tickbase_max - tickbase - 1))
            return u_player.lc_left ~= 1 and u_player.lc_left > 2 and globals.chokedcommands() < 13
        end
        client.set_event_callback("run_command", function(cmd)
            last_commandnumber = cmd.command_number
            u_player.shifting = get_double_tap()
        end)
        local function is_onground()
            local animstate = u_memory.animstate:get(entity.get_local_player())
            if not animstate then return true end
            local ptr_addr = ffi.cast('uintptr_t', ffi.cast('void*', animstate))
            local landed_on_ground_this_frame = ffi.cast('bool*', ptr_addr + 0x120)[0]
            return animstate.on_ground and not landed_on_ground_this_frame
        end
        local function is_fs_peek()
            local me = entity.get_local_player()
            local enemy = client.current_threat()
            if not me or entity.is_dormant(enemy) then return false end
            local _, yaw = client.camera_angles(me)
            local left2 = u_math.extend_vector({entity.get_origin(me)},30,yaw + 60)
            local right2 = u_math.extend_vector({entity.get_origin(me)},30,yaw - 60)
            local _, yaw_e = entity.get_prop(enemy, "m_angEyeAngles")
            local enemy_right2 = u_math.extend_vector({entity.get_origin(enemy)},20,yaw_e - 35)
            local enemy_left2 = u_math.extend_vector({entity.get_origin(enemy)},20,yaw_e + 35)
            local _, dmg_left2 =  client.trace_bullet(enemy, enemy_left2[1], enemy_left2[2], enemy_left2[3] + 30, left2[1], left2[2], left2[3], true)
            local _, dmg_right2 = client.trace_bullet(enemy, enemy_right2[1], enemy_right2[2], enemy_right2[3] + 30, right2[1], right2[2], right2[3], true)
            if  dmg_right2 > 0 and dmg_left2 > 0 then return false
            elseif dmg_left2 > 0 then return true
            elseif dmg_right2 > 0 then return true end
            return false
        end
        local function get_state()
            if not u_player.onground then
                if u_player.duckamount > 0.5 then return 'airc' else return 'air' end
            end
            if u_player.duckamount > 0.5 or (u_reference.ragebot.duck and u_reference.ragebot.duck:get()) then
                if u_player.speed > 4 then return 'duck move' else return 'duck' end
            end
            local slowmotion_state = u_reference.antiaim.slowmotion.hotkey:get()
            if slowmotion_state then return 'slow' end
            if u_player.speed > 4 then return 'run' end
            return 'idle'
        end
        local function get_side(target)
            local local_pos, enemy_pos = vector(entity.hitbox_position(entity.get_local_player(), 0)), vector(entity.hitbox_position(target, 0))
            local _, yaw = (local_pos-enemy_pos):angles()
            local l_dir, r_dir = vector():init_from_angles(0, yaw+90), vector():init_from_angles(0, yaw-90)
            local l_pos, r_pos = local_pos + l_dir * 110, local_pos + r_dir * 110
            local fraction = client.trace_line(target, enemy_pos.x, enemy_pos.y, enemy_pos.z, l_pos.x, l_pos.y, l_pos.z)
            local fraction_s = client.trace_line(target, enemy_pos.x, enemy_pos.y, enemy_pos.z, r_pos.x, r_pos.y, r_pos.z)
            if fraction > fraction_s then return 'left'
            elseif fraction_s > fraction then return 'right'
            elseif fraction == fraction_s then return 'none' end
            return 'none'
        end
        local function get_fs_side()
            local me = entity.get_local_player()
            local target, cross_target,best_yaw = nil, nil, 362
            local enemy_list = entity.get_players(true)
            local stomach_origin = vector(entity.hitbox_position(me, 2))
            local camera_angles = vector(client.camera_angles())
            for idx=1, #enemy_list do
                local ent = enemy_list[idx]
                local ent_wpn = entity.get_player_weapon(ent)
                if ent_wpn then
                    local enemy_head = vector(entity.hitbox_position(ent, 2))
                    local _, yaw = (stomach_origin-enemy_head):angles()
                    local base_diff = math.abs(camera_angles.y-yaw)
                    if base_diff < best_yaw then cross_target = ent; best_yaw = base_diff end
                end
            end
            if not target then target = cross_target end
            return target and get_side(target) or 'none'
        end
        function u_player.predict_command(cmd)
            local me = entity.get_local_player()
            u_player.speed = vector(entity.get_prop(me, 'm_vecVelocity')):length()
            u_player.state = get_state()
            u_player.fs_side = get_fs_side()
            u_player.defensive = defensive_predict(cmd)
            u_player.onground = is_onground()
            u_player.is_fs_peek = is_fs_peek()
            u_player.duckamount = entity.get_prop(me, 'm_flDuckAmount')
        end
        function u_player.setup_command(cmd)
            u_player.get_players = entity.get_players()
            u_player.crouching = cmd.in_duck == 1
            u_player.walking = u_player.speed > 5 and (cmd.in_speed == 1)
        end
    end



    local anti_aim = { features = {}, builder = {}, venture = {} }

    do
        anti_aim.features.use_aa = false
        anti_aim.features.stab = false
        anti_aim.features.fast_ladder = false
        anti_aim.features.safe_head = false
        anti_aim.features.manual = 0.0
        anti_aim.features.defensive = false
        anti_aim.features.warmup_aa = false

        do -- legit_antiaim
            local start_time = globals.realtime()
            function anti_aim.features.legit_run(cmd)
                local use_cfg = interface.builder['use']
                if not use_cfg or not use_cfg.allow_use_aa or not use_cfg.allow_use_aa:get() then return false end
                if cmd.in_use == 0 then start_time = globals.realtime(); return end
                local player = entity.get_local_player()
                if player == nil then return end
                local player_origin = { entity.get_origin(player) }
                local CPlantedC4 = entity.get_all('CPlantedC4')
                local dist_to_bomb = 999
                if #CPlantedC4 > 0 then
                    local bomb = CPlantedC4[1]
                    local bomb_origin = { entity.get_origin(bomb) }
                    dist_to_bomb = vector(player_origin[1], player_origin[2], player_origin[3]):dist(vector(bomb_origin[1], bomb_origin[2], bomb_origin[3]))
                end
                local CHostage = entity.get_all('CHostage')
                local dist_to_hostage = 999
                if CHostage ~= nil then
                    if #CHostage > 0 then
                        local hostage_origin = { entity.get_origin(CHostage[1]) }
                        dist_to_hostage = math.min(
                            vector(player_origin[1], player_origin[2], player_origin[3]):dist(vector(hostage_origin[1], hostage_origin[2], hostage_origin[3])),
                            vector(player_origin[1], player_origin[2], player_origin[3]):dist(vector(hostage_origin[1], hostage_origin[2], hostage_origin[3])))
                    end
                end
                if dist_to_hostage < 65 and entity.get_prop(player, 'm_iTeamNum') ~= 2 then return end
                if dist_to_bomb < 65 and entity.get_prop(player, 'm_iTeamNum') ~= 2 then return end
                if cmd.in_use then if globals.realtime() - start_time < 0.02 then return end end
                cmd.in_use = false
                return true
            end
        end

        function anti_aim.features.anti_backstab()
            local players = entity.get_players(true)
            for i = 1, #players do
                local x, y, z = entity.get_prop(players[i], 'm_vecOrigin')
                local origin = vector(entity.get_prop(entity.get_local_player(), 'm_vecOrigin'))
                local distance = math.sqrt((x - origin.x) ^ 2 + (y - origin.y) ^ 2 + (z - origin.z) ^ 2)
                local weapon = entity.get_player_weapon(players[i])
                if entity.get_classname(weapon) == 'CKnife' and distance <= 200 then
                    return true
                end
            end
            return false
        end

        function anti_aim.features.ladder_run(cmd)
            if not interface.builder.extensions.ladder:get() then return false end
            if entity.get_prop(entity.get_local_player(), "m_MoveType") ~= 9 or cmd.forwardmove == 0 then return false end
            local camera_pitch, camera_yaw = client.camera_angles()
            local descending = cmd.forwardmove < 0 or camera_pitch > 45
            cmd.in_moveleft, cmd.in_moveright = descending and 1 or 0, not descending and 1 or 0
            cmd.in_forward, cmd.in_back = descending and 1 or 0, not descending and 1 or 0
            cmd.pitch, cmd.yaw = 89, u_math.normalize_yaw(cmd.yaw + 90)
            return true
        end

        function anti_aim.features.safe_run(cmd)
            local result = math.huge
            local heightDifference = 0
            local localplayer = entity.get_local_player()
            local entities = entity.get_players(true)
            for i = 1, #entities do
                local ent = entities[i]
                local ent_origin = { entity.get_origin(ent) }
                local lp_origin = { entity.get_origin(localplayer) }
                if ent ~= localplayer and entity.is_alive(ent) then
                    local distance = (vector(ent_origin[1], ent_origin[2], ent_origin[3]) - vector(lp_origin[1], lp_origin[2], lp_origin[3])):length2d()
                    if distance < result then result = distance; heightDifference = ent_origin[3] - lp_origin[3] end
                end
            end
            local distance_to_enemy = { math.floor(result / 10), math.floor(heightDifference) }
            local weapon = entity.get_player_weapon(entity.get_local_player())
            local knife = weapon ~= nil and entity.get_classname(weapon) == 'CKnife'
            local zeus = weapon ~= nil and entity.get_classname(weapon) == 'CWeaponTaser'
            local safe_knife = (interface.builder.extensions.safe_head:get('knife')) and knife and not u_player.onground
            local safe_zeus = (interface.builder.extensions.safe_head:get('zeus')) and zeus and  not u_player.onground
            local distance_height = (interface.builder.extensions.safe_head:get('height distance')) and distance_to_enemy[2] < -50
            local distance_hight = (interface.builder.extensions.safe_head:get('high distance')) and  distance_to_enemy[1] > 119
            if safe_knife or safe_zeus  or distance_hight or distance_height then return true end
            return false
        end

        do -- manual
            local manual_cur = nil
            local manual_keys = {
                { "left",    yaw = -90, item = interface.builder.extensions.manual_aa_hotkey.manual_left },
                { "right",   yaw = 90,  item = interface.builder.extensions.manual_aa_hotkey.manual_right },
                { "reset",   yaw = nil, item = interface.builder.extensions.manual_aa_hotkey.manual_back },
                { "forward", yaw = 180, item = interface.builder.extensions.manual_aa_hotkey.manual_forward },
            }
            local toggled = { false, false, false, false }
            local prev = { false, false, false, false }
            function anti_aim.features.manual_run()
                if not interface.builder.extensions.manual_aa:get() then
                    manual_cur = nil
                    return 0
                end
                for i, v in ipairs(manual_keys) do
                    local active = v.item.get and select(1, v.item:get()) or (v.item.ref and ui.get(v.item.ref)) or false
                    local pressed = active and not prev[i]
                    prev[i] = active
                    if pressed then
                        if v.yaw == nil then
                            -- reset to center
                            for j = 1, #manual_keys do toggled[j] = false end
                            manual_cur = nil
                        else
                            -- switch immediately to this direction, turning others off
                            for j = 1, #manual_keys do if j ~= i then toggled[j] = false end end
                            toggled[i] = not toggled[i]
                            manual_cur = toggled[i] and i or nil
                        end
                    end
                end
                if manual_cur and not toggled[manual_cur] then manual_cur = nil end
                if not manual_cur then
                    if toggled[2] then manual_cur = 2
                    elseif toggled[1] then manual_cur = 1
                    elseif toggled[4] then manual_cur = 4 end
                end
                return manual_cur and manual_keys[manual_cur].yaw or 0
            end
        end

        function anti_aim.features.on_hotkey()
            local is_allowed_state = u_math.contains(interface.builder.extensions.dis_fs:get(), u_player.state)
            local want_fs = interface.builder.extensions.freestanding:get() and (anti_aim.features.manual == 0)
            local fs_on_hotkey = is_allowed_state and want_fs and (not anti_aim.features.use_aa)
            local edge_on_hotkey = interface.builder.extensions.edge_yaw:get() -- local edge_on_hotkey = interface.builder.extensions.edge_yaw:get() or (interface.builder.extensions.fd_edge:get() and  u_reference.ragebot.duck:get() )
            u_reference.antiaim.edge:set(edge_on_hotkey)
            u_reference.antiaim.freestand:set(fs_on_hotkey)
            u_reference.antiaim.freestand.hotkey:set(fs_on_hotkey and "Always on" or "On hotkey")
        end

        function anti_aim.features.defensive_run(cmd)
            local me = entity.get_local_player()
            if not me then return false end
            local wpn = entity.get_player_weapon(me)
            local function is_exploit_ready_and_active(w)
                local doubletap_active = u_reference.ragebot.double_tap.hotkey:get()
                local onshot_active = u_reference.antiaim.onshot.hotkey:get()
                local fakeduck_active = u_reference.ragebot.duck:get()
                if fakeduck_active or not (onshot_active or doubletap_active) or doubletap_active and not u_player.shifting then return false end
                if ok_weapons and w then
                    local wpn_info = weapons(w)
                    if wpn_info and wpn_info.is_revolver then return false end
                end
                return true
            end
            if not is_exploit_ready_and_active(wpn) then return false end
            local animlayers = u_memory.animlayers:get(me)
            if not animlayers then return false end
            local weapon_activity_number = u_memory.activity:get(animlayers[1]['sequence'], me)
            local flash_activity_number = u_memory.activity:get(animlayers[9]['sequence'], me)
            local is_reloading = animlayers[1]['weight'] ~= 0.0 and weapon_activity_number == 967
            local is_flashed = animlayers[9]['weight'] > 0.1 and flash_activity_number == 960
            local is_under_attack = animlayers[10]['weight'] > 0.1
            local is_swapping_weapons = cmd.weaponselect > 0
            if (interface.builder.extensions.defensive:get("flashed") and is_flashed)
            or (interface.builder.extensions.defensive:get("damage received") and is_under_attack)
            or (interface.builder.extensions.defensive:get("reloading") and is_reloading)
            or (interface.builder.extensions.defensive:get("weapon switch") and is_swapping_weapons) 
            or (interface.builder.extensions.defensive:get("on shot") and u_reference.antiaim.onshot.hotkey:get() ) then
                return false
            end
            return true
        end

        function anti_aim.features.warmup_run()
            local game_rules = entity.get_game_rules()
            if not game_rules then return false end
            local warmup_period do
                local is_active = interface.builder.extensions.warmup_aa:get("warmup")
                local is_warmup = entity.get_prop(game_rules, 'm_bWarmupPeriod') == 1
                warmup_period = is_active and is_warmup
            end
            if not warmup_period then
                local player_resource = entity.get_player_resource()
                if player_resource then
                    local are_all_enemies_dead = true
                    for i=1, globals.maxplayers() do
                        if entity.get_prop(player_resource, 'm_bConnected', i) == 1 then
                            if entity.is_enemy(i) and entity.is_alive(i) then
                                are_all_enemies_dead = false
                                break
                            end
                        end
                    end
            warmup_period = (are_all_enemies_dead and globals.curtime() < (entity.get_prop(game_rules, 'm_flRestartRoundTime') or 0)) and interface.builder.extensions.warmup_aa:get("round end")
                end
            end
            return warmup_period and true or false
        end

        function anti_aim.features.main(cmd)
            anti_aim.features.use_aa = anti_aim.features.legit_run(cmd)
            anti_aim.features.stab = interface.builder.extensions.anti_backstab:get() and anti_aim.features.anti_backstab() or false
            anti_aim.features.fast_ladder = anti_aim.features.ladder_run(cmd)
            anti_aim.features.safe_head = anti_aim.features.safe_run(cmd)
            anti_aim.features.manual = anti_aim.features.manual_run()
            anti_aim.features.defensive = anti_aim.features.defensive_run(cmd)
            anti_aim.features.on_hotkey()
            anti_aim.features.warmup_aa = anti_aim.features.warmup_run(cmd)

            _G.noctua_runtime = _G.noctua_runtime or {}
            _G.noctua_runtime.manual_active = (anti_aim.features.manual ~= 0)
            _G.noctua_runtime.safe_head_active = (anti_aim.features.safe_head == true)
            _G.noctua_runtime.use_active = (anti_aim.features.use_aa == true)
        end
    end

    do -- builder core
        anti_aim.builder.venture = false
        anti_aim.builder.latest = 0
        anti_aim.builder.switch = false
        anti_aim.builder.delay = 0
        anti_aim.builder.restrict = 0
        anti_aim.builder.last_packets = 0
        anti_aim.builder.way = 0

        local function get_state(state)
            local double_tap = u_reference.ragebot.double_tap.hotkey:get()
            local onshot = u_reference.antiaim.onshot.hotkey:get()
            local fake_duck = u_reference.ragebot.duck:get()
            local freestand_allowed = u_math.contains(interface.builder.extensions.dis_fs:get(), u_player.state)
            local freestand_hotkey = interface.builder.extensions.freestanding:get()
            local freestand = (freestand_hotkey or u_player.is_fs_peek) and freestand_allowed
            if interface.builder['use'] and interface.builder['use'].enable and interface.builder['use'].enable:get()  and  anti_aim.features.use_aa then return  'use' end
            if interface.builder['manual'] and interface.builder['manual'].enable and interface.builder['manual'].enable:get() and anti_aim.features.manual ~= 0 then return 'manual' end
            if interface.builder['freestand'] and interface.builder['freestand'].enable and interface.builder['freestand'].enable:get() and freestand then return 'freestand' end
            if interface.builder['safe head'] and interface.builder['safe head'].enable and interface.builder['safe head'].enable:get() and anti_aim.features.safe_head then return 'safe head' end
            if interface.builder['on shot'] and interface.builder['on shot'].enable and interface.builder['on shot'].enable:get() and onshot and not double_tap and not fake_duck then return 'on shot' end
            if interface.builder['fakelag'] and interface.builder['fakelag'].enable and interface.builder['fakelag'].enable:get() and not onshot and not double_tap and not fake_duck then return 'fakelag' end
            return state
        end

        local choke = 1
        local function yaw_base_for(this)
            if  anti_aim.features.use_aa then return 0 , "180" ,this.base.value end
            if anti_aim.features.stab then return 0 , "off" ,this.base.value end
            return 'default', "180", (u_reference.antiaim.edge:get() and "local view" or this.base.value)
        end

        local function modifier(this)
            local add , expand = this.add.value, this.expand.value
            local delay = (expand ~= "left/right" or not u_player.shifting)  and 1 or this.delay.value
            if globals.chokedcommands() == 0 then choke = choke + 1 end
            local add_ab_left , add_ab_right= 0 , 0
            if interface.builder.extensions.anti_bruteforce:get() and anti_aim.builder.venture then
                if interface.builder.extensions.anti_bruteforce_type:get() == "increase" then
                    add_ab_right = anti_aim.builder.restrict * 3; add_ab_left= anti_aim.builder.restrict * -3
                elseif interface.builder.extensions.anti_bruteforce_type:get() == "decrease" then
                    add_ab_right = anti_aim.builder.restrict * -3; add_ab_left= anti_aim.builder.restrict * 3
                end
            end
            if (choke - anti_aim.builder.last_packets >= anti_aim.builder.delay)  then
                anti_aim.builder.delay = delay
                anti_aim.builder.switch = not anti_aim.builder.switch
                anti_aim.builder.last_packets = choke
            end
            if expand == "left/right" then
                local  epd_left , epd_right = this.epd_left.value , this.epd_right.value
                add = add + ( anti_aim.builder.switch and epd_left +add_ab_left or epd_right + add_ab_right)
            elseif expand == "x-way" then
                local x_way , epd_way= this.x_way.value ,this.epd_way.value
                anti_aim.builder.way = anti_aim.builder.way < (x_way - 1) and (anti_aim.builder.way + 1) or 0
                if this.ways_manual.value then add = add +  this[anti_aim.builder.way+1]:get()
                else
                    local step = (anti_aim.builder.way) / (x_way - 1)
                    add = add + u_math.lerp(-epd_way, epd_way, step)
                end
            elseif expand == "spin" then
                local  epd_left , epd_right , speed = this.epd_left.value , this.epd_right.value , this.speed.value
                add = add + u_math.lerp(epd_left, epd_right , globals.curtime() * (speed * 0.1) % 1)
            end
            local jitter_mode, jitter_degree = this.jitter.value, this.jitter_add.value
            if jitter_mode == "offset" then
                add = add + (anti_aim.builder.switch and jitter_degree +add_ab_left or 0 + add_ab_right)
            elseif jitter_mode == "center" then
                add = add + (anti_aim.builder.switch and -jitter_degree / 2 +add_ab_left or jitter_degree / 2 + add_ab_right)
            elseif jitter_mode == "random" then
                add = add + (math.random(0, jitter_degree) - jitter_degree / 2)
            end
            if not anti_aim.features.use_aa  then
                add = add + anti_aim.features.manual + math.random(this.yaw_randomize:get() * 0.01 * -add, this.yaw_randomize:get() * 0.01 * add)
            end
            if anti_aim.features.use_aa then add = add + 180 end
            return u_math.normalize_yaw(add)
        end

        local function body(this)
            local by_mdoe , by_num , by_tpye  = this.by_mode.value , 0 , "static"
            if by_mdoe == "static" then
                by_tpye = "static"; by_num = this.by_num.value
            elseif by_mdoe == "jitter" then
                by_tpye = "static"; by_num = anti_aim.builder.switch and this.by_num.value or - this.by_num.value
            elseif by_mdoe == "opposite" then
                by_tpye = "static"
                if u_player.fs_side == 'left' then by_num = 180
                elseif u_player.fs_side == 'right' then by_num = -180 else by_num = 0 end
            elseif by_mdoe == "off" then
                by_tpye = "off"
            end
            return u_math.normalize_yaw(by_num)  ,  by_tpye
        end

        local srx, pitch_srx
        local function defensive_builder(cmd,this)
            cmd.force_defensive = this.break_lc.value
            local yaw , pitch = this.def_yaw.value , this.def_pitch.value
            local pitch_num , yaw_num , body_tpye , body_num = 'default' ,nil ,nil ,nil
            if pitch == "up" then pitch_num = -88
            elseif pitch == "zero" then pitch_num = 0
            elseif pitch == "up switch" then pitch_num = client.random_int(-45, 65)
            elseif pitch == "down switch" then pitch_num = client.random_int(45, 65)
            elseif pitch == "random" then pitch_num =  client.random_int(-89, 89)
            elseif pitch == "random static" then
                if not pitch_srx then pitch_srx = client.random_int(-89, 89) end
                pitch_num = pitch_srx
            elseif pitch == "custom" then pitch_num = this.def_pitch_num.value end
            if yaw == "sideways" then
                yaw_num = (anti_aim.builder.switch and 90 or -90 ) + client.random_int(-15, 15)
            elseif yaw == "forward" then
                yaw_num = 180  + client.random_int(-30, 30)
            elseif yaw == "delayed" then
                local left ,  right  = this.def_left.value , this.def_right.value
                yaw_num = (anti_aim.builder.switch and left or right )
            elseif yaw == "spin" then
                local left ,  right  , speed = this.def_left.value , this.def_right.value , this.def_speed.value
                yaw_num =  u_math.lerp(left, right , globals.curtime() * (speed * 0.1) % 1)
            elseif yaw == "random" then
                local left ,  right  = this.def_left.value , this.def_right.value
                yaw_num =  client.random_int(left,right)
            elseif yaw == "random static" then
                local left ,  right  = this.def_left.value , this.def_right.value
                if not srx then srx = client.random_int(left,right) end
                yaw_num = srx
            elseif yaw == "flick exploit" then
                yaw_num = (u_player.fs_side  ==  'left' and -90 or 90) +client.random_int(-20,20)
            elseif yaw == "custom" then
                yaw_num = u_player.fs_side  ==  'left' and  this.def_yaw_num.value  or -this.def_yaw_num.value
            end
            local body = this.def_body.value
            if body == "default" then
                body_tpye = "static"; body_num = 120
            elseif body == "auto" then
                if yaw_num ~= nil then body_tpye = "static"; body_num =  yaw_num < 0 and -60 or 60 end
            elseif  body == "jitter" then
                body_tpye = "static"; body_num = anti_aim.builder.switch and -120 or 120
            end
            return pitch_num , yaw_num , body_tpye , body_num
        end

        function anti_aim.builder.main(cmd)
            local state = get_state(u_player.state)
            local ok = pcall(function()
                if ui.get(reference.antiaim.angles.enabled) ~= true then
                    ui.set(reference.antiaim.angles.enabled, true)
                end
            end)
            local this =  (interface.builder[state] and interface.builder[state].enable and interface.builder[state].enable.value and interface.builder[state]) or interface.builder["default"]
            local pitch , yaw_type , yaw_base = yaw_base_for(this)
            local yaw_add = modifier(this)
            local by_num , by_tpye = body(this)
            local pitch_num , yaw_num , body_tpye , body_num  = defensive_builder(cmd,this)
            if  (u_player.defensive  and not anti_aim.features.fast_ladder and not  anti_aim.features.use_aa  and u_player.shifting) and this.defensive.value and anti_aim.features.defensive then
                pitch = pitch_num ~= nil and pitch_num or pitch
                yaw_add = yaw_num ~= nil and yaw_num or yaw_add
                by_num = body_num ~= nil and body_num or by_num
                by_tpye =  body_tpye ~= nil and body_tpye or by_tpye
            else
                srx = nil; pitch_srx = nil
            end
            if anti_aim.features.warmup_aa then
                pitch = 0; yaw_type = "spin"; yaw_add = 42; by_tpye = "off"
            end
            if anti_aim.builder.venture then
                if anti_aim.builder.latest + 2 == globals.curtime() then anti_aim.builder.venture = false end
            end
            u_reference.antiaim.pitch[1]:set(type(pitch) == "number" and 'custom' or pitch)
            u_reference.antiaim.pitch[2]:set(type(pitch) == "number" and pitch or 0 )
            u_reference.antiaim.yaw[1]:set(yaw_type)
            u_reference.antiaim.yaw[2]:set( u_math.normalize_yaw(yaw_add) )
            u_reference.antiaim.base:set(yaw_base)
            u_reference.antiaim.fs_body:set(false)
            u_reference.antiaim.jitter[1]:set("off")
            u_reference.antiaim.jitter[2]:set(0)
            u_reference.antiaim.body[1]:set(by_tpye)
            u_reference.antiaim.body[2]:set(by_num)
        end
    end

    do -- venture
        local latest = 0
        local last_hurt_by = {}
        local last_death_tick = 0
        local pending_evade_logs = {}

        client.set_event_callback('player_hurt', function(e)
            local me = entity.get_local_player()
            if not me then return end
            local victim = client.userid_to_entindex(e.userid)
            local attacker = client.userid_to_entindex(e.attacker)
            if victim == me and attacker and entity.is_enemy(attacker) then
                last_hurt_by[attacker] = globals.tickcount()
            end
        end)

        client.set_event_callback('player_death', function(e)
            local me = entity.get_local_player()
            if not me then return end
            local victim = client.userid_to_entindex(e.userid)
            if victim == me then
                last_death_tick = globals.tickcount()
            end
        end)

        local function process_pending()
            local tick = globals.tickcount()
            for attacker, data in pairs(pending_evade_logs) do
                if tick > data.created_tick then
                    local hurt_tick = last_hurt_by[attacker] or 0
                    local killed_recently = (last_death_tick ~= 0) and (last_death_tick >= data.created_tick) and (last_death_tick <= data.created_tick + 2)
                    local hurt_recently = (hurt_tick >= data.created_tick) and (hurt_tick <= data.created_tick + 2)
                    if not hurt_recently and not killed_recently then
                        if interface.visuals.logging:get() then
                            local logOptions = interface.visuals.logging_options:get()
                            local screenOptions = interface.visuals.logging_options_screen:get()
                            local consoleOptions = interface.visuals.logging_options_console:get()

                            local doScreen = utils.contains(logOptions, 'screen') and utils.contains(screenOptions, 'anti aim')
                            local doConsole = utils.contains(logOptions, 'console') and utils.contains(consoleOptions, 'anti aim')

                            if doScreen then
                                logging:push(string.format("evaded %s's shot / value: %s - mode: %s", data.name, data.value, tostring(data.mode)))
                            end

                            if doConsole then
                                argLog("evaded %s's shot / value: %s - mode: %s", data.name, data.value, tostring(data.mode))
                            end
                        end

                        stats.on_evaded(data.name, data.value, data.mode)
                    end
                    pending_evade_logs[attacker] = nil
                end
            end
        end

        local function trigger(event)
            local ab_enabled = interface.builder.extensions.anti_bruteforce:get()

            local me = entity.get_local_player()
            local valid = (me and entity.is_alive(me))
            if not valid or latest == globals.tickcount() then return end
            local attacker = client.userid_to_entindex(event.userid)
            if not attacker or not entity.is_enemy(attacker) or entity.is_dormant(attacker) then return end
            local attacker_info = utils.get_player_info(attacker)

            if attacker_info.__fakeplayer then return end

            local curtick = globals.tickcount()
            local hurt_tick = last_hurt_by[attacker] or 0
            if (hurt_tick ~= 0 and (curtick - hurt_tick) <= 2) or (last_death_tick ~= 0 and (curtick - last_death_tick) <= 2) then
                return
            end

            if not u_player.get_players or #u_player.get_players == 0 then return end

            local impact = vector(event.x, event.y, event.z)
            local enemy_view = vector(entity.get_origin(attacker))
            enemy_view.z = enemy_view.z + 64
            local dists = {}
            for i = 1, #u_player.get_players do
                local v = u_player.get_players[i]
                if not entity.is_enemy(v) then
                    local head = vector(entity.hitbox_position(v, 0))
                    local point = u_math.closest_ray_point(head, enemy_view, impact)
                    dists[#dists+1] = head:dist(point)
                    if v == me then dists.mine = dists[#dists] end
                end
            end

            if #dists == 0 then return end
            local closest = math.min( unpack(dists) )
            if (dists.mine and closest) and dists.mine < 40 or (closest == dists.mine and dists.mine < 128) then
                latest = globals.tickcount()
                if ab_enabled then
                    anti_aim.builder.latest = globals.curtime()
                    anti_aim.builder.venture = true
                end
                local restrict = math.random(1, 3)
                if ab_enabled then anti_aim.builder.restrict = restrict end

                local mode = interface.builder.extensions.anti_bruteforce_type and interface.builder.extensions.anti_bruteforce_type:get() or "increase"
                local name = entity.get_player_name(attacker) or "enemy"
                local value = tostring(restrict)

                pending_evade_logs[attacker] = { name = name, value = value, mode = mode, created_tick = curtick }
            end
        end
        client.set_event_callback("bullet_impact", trigger)
        client.set_event_callback("run_command", process_pending)
    end

    client.set_event_callback('predict_command', function(cmd) u_player.predict_command(cmd) end)
    client.set_event_callback('setup_command', function(cmd)
        u_player.setup_command(cmd)
        anti_aim.features.main(cmd)
        anti_aim.builder.main(cmd)
    end)

    naac = function(page)
        local show_builder = (page == 'builder')
        local show_settings = (page == 'extensions')
        pui.traverse(interface.builder, function(element)
            element:set_visible(show_builder)
        end)
        pui.traverse(interface.builder.extensions, function(element)
            element:set_visible(show_settings)
        end)
        pui.traverse(interface.builder.extensions.manual_aa_hotkey, function(element)
            element:set_visible(show_settings and interface.builder.extensions.manual_aa:get())
        end)
    end
end
--@endregion: antiaim

--@region: streamer mode
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

interface.aimbot.dump_resolver_data:set_callback(function()
    resolver:dump_data()
end)

--@region: on shutdown
local function reset_player_plist(idx)
    if not idx or not entity.is_enemy(idx) then return end
    plist.set(idx, 'Force body yaw', false)
    plist.set(idx, 'Force body yaw value', 0)
    plist.set(idx, 'Force pitch', false)
    plist.set(idx, 'Force pitch value', 0)
    plist.set(idx, 'Correction active', false)
    plist.set(idx, 'Override safe point', "-")
    plist.set(idx, 'Override safe point value', "Off")
    plist.set(idx, 'Override prefer body aim', "-")
end

local function reset_all_players()
    local enemies = entity.get_players(true)
    if not enemies then return end
    for _, idx in ipairs(enemies) do
        if idx and entity.is_alive(idx) then
            reset_player_plist(idx)
        end
    end
end

local resolver_controller = { was_enabled = false }
client.set_event_callback('paint', function()
    local enabled = (interface.aimbot.enabled_aimbot:get() and interface.aimbot.enabled_resolver_tweaks:get())
    if resolver_controller.was_enabled and not enabled then
        reset_all_players()
    end
    resolver_controller.was_enabled = enabled
end)

client.set_event_callback('shutdown', function()
    reset_all_players()
end)
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

--@region: menu info
menu_info = {} do
    menu_info.alpha = 0
    menu_info.expanded = true
    menu_info.mouse_pressed = false
    menu_info.is_interacting = false 

    local function point_in_rect(px, py, rx, ry, rw, rh)
        return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
    end

    local function get_menu_rect()
        local mx, my = ui.menu_position()
        local mw, mh = ui.menu_size()
        return mx or 0, my or 0, mw or 0, mh or 0
    end

    menu_info.paint = function()
        local is_open = ui.is_menu_open()
        local target_alpha = is_open and 255 or 0
        
        menu_info.alpha = mathematic.lerp(menu_info.alpha, target_alpha, globals.frametime() * 20)

        if menu_info.alpha < 1 then 
            menu_info.is_interacting = false
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

        local list_x = x - 7
        local list_y = y + 10
        local line_height = 13
        
        local status_text = menu_info.expanded and "(close)" or "(open)"
        local update_header = string.format("what's new %s", status_text)
        local tw, th = renderer.measure_text(0, update_header)

        local mx, my = ui.mouse_position()
        local m1 = client.key_state(0x01)

        if is_open then
            local menu_x, menu_y, menu_w, menu_h = get_menu_rect()
            local is_hovering = point_in_rect(mx, my, list_x - tw, list_y, tw, th) and not point_in_rect(mx, my, menu_x, menu_y, menu_w, menu_h)

            if m1 then
                if is_hovering or menu_info.is_interacting then
                    menu_info.is_interacting = true 
                    if not menu_info.mouse_pressed and is_hovering then
                        menu_info.expanded = not menu_info.expanded
                        menu_info.mouse_pressed = true
                    end
                end
            else
                menu_info.is_interacting = false
                menu_info.mouse_pressed = false
            end
        else
            menu_info.is_interacting = false
        end

        renderer.text(list_x, list_y, r, g, b, menu_info.alpha, 'rb', 0, update_header)
        
        if menu_info.expanded then
            local update_list = {
                "streamer mode",
                "animation breakers",
                "buybot fallback option",
                "enemy ping warning",
                "dump resolver data",
                "automatic osaa & disablers",
                "winter mode ❄️"
            }
            for i, line in ipairs(update_list) do
                renderer.text(list_x, list_y + (i * line_height), 255, 255, 255, menu_info.alpha, 'r', 0, line)
            end
        end
    end

    menu_info.setup_command = function(cmd)
        if menu_info.is_interacting then
            cmd.in_attack = 0
            cmd.in_attack2 = 0
        end
    end
end

client.set_event_callback('paint_ui', menu_info.paint)
client.set_event_callback('setup_command', menu_info.setup_command)

client.set_event_callback('paint_ui', function()
    local shimmer_text = table.concat(colors.shimmer(
        globals.realtime() * 2,
        "winter mode",
        157, 230, 254, 255,
        255, 255, 255, 255
    ))
    interface.home.winter_label:set(shimmer_text)
end)
--@endregion

--@region: on load
logging:push("happy new year! ❄️")
logging:push("nice to see you at " .. _name .. " " .. _version .. " (" .. (_nickname or "user") .. ")")
client.exec("play items/flashlight1.wav")
confetti:push(0, true)
--@endregion

--@region: art
local star = [[
       .-.                         .-.                    |     '      .        
      (   )    '        +         (   )                  -o-               o    
       `-'     .-.                 `-'             '      |        +          + 
              ( (    ~~+                      .               o               + 
        .      `-'.              +    .         o     * .            .          
              '                                                                 
     '       .-.    *                      /                               .  ' 
              ) )       '    noctua.sbs   /                           | o      
  '.         '-´       '    o            *   version: {ver}          -+-       
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
]]

local function artHighlight()
    local r, g, b = unpack(interface.visuals.accent.color.value)
    local white_r, white_g, white_b = 255, 255, 255
    
    local target1 = "noctua.sbs"
    local placeholder = "{ver}"
    local s1, e1 = star:find(target1, 1, true)
    local s2, e2 = star:find(placeholder, (e1 or 0) + 1, true)

    if not s1 or not s2 then
        client.color_log(white_r, white_g, white_b, star .. "\n\0")
        return
    end

    client.color_log(white_r, white_g, white_b, star:sub(1, s1 - 1) .. "\0")
    client.color_log(r, g, b, star:sub(s1, e1) .. "\0")
    client.color_log(white_r, white_g, white_b, star:sub(e1 + 1, s2 - 1) .. "\0")
    client.color_log(r, g, b, tostring(_version) .. "\0")
    client.color_log(white_r, white_g, white_b, star:sub(e2 + 1) .. "\n\0")
end

client.exec('clear')
artHighlight()
--@endregion

-- ^~^!
