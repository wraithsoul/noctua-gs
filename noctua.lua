--[[

    noctua.sbs (side by side)
    author: t.me/ovhbypass
    note: бонус за безумный код

--]]

--@region: information
local _name = 'noctua debug'
local _version = '1.3'
local _nickname = entity.get_player_name(entity.get_local_player())

local update = [[
changelog 1.3 (18/10/2025):
 - added "on death" to balabolka (killsay) mode
 - added crosshair indicator "center" mode
 - added spawn zoom effect
 - added zoom animation
 - added round counter
 - added buy logging
 - added hitsound
 - added buybot
 - reworked "resolver tweaks" logic
 - reworked smart safety
 - reworked widgets
 - fixed game crashes
 - fixed stickman shaders
 - removed chat filter

changelog 1.2 (18/03/2025):
 - reworked chat filter, now it blocks crash & noise
 - fixed a bug where the animation of indicators depended on client fps
 
changelog 1.1.2 (08/03/2025):
 - added clantag
 - added killsay
 - added yaw display fallback
 - optimized vgui color manipulation
 - fixed stickman reset on shutdown
 - fixed vgui reset on shutdown

changelog 1.1.1 (05/03/2025):
 - added aspect ratio override
 - added third person distance override
 - added viewmodel override
 - added animations to stickman
 - added new animations to crosshair indicators
 - added vgui color manipulation
 - reworked stickman
 - reworked crosshair indicators
 - reworked logging animations
 - fixed a bug when smart safety was always working
 - fixed color of air stop indicator
 - fixed model changer bug that failed to properly restore weapon world models
 - removed builder (temporary)
]]
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
    
    colors.animate_text = function(time, text, r, g, b, a, r2, g2, b2, a2)
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
        general = pui.group('players', 'adjustments')
    }

    interface.additional = {
        empty = '⠀'
    }

    prepare_aa = {
        onground = false,
        ticks = 0,
        state = 'idle',
        condition = {},
        condition_names = {
            'default',
            'idle',
            'run',
            'air',
            'airc',
            'duck',
            'duck move',
            'slow',
            'use',
            'freestand',
            'manual'
        },
        extensions = {
            'adjust manual anti-aim',
            'legit anti-aim',
            'bombsite e fix',
            'fast ladder'
        }
    }
    
    interface.search = interface.header.general:combobox(pui.macros.title .. ' - '.. _version, 'aimbot', 'visuals', 'models', 'utility', 'other') -- add builder later

    interface.aimbot = {
        enabled_aimbot = interface.header.general:checkbox('enable aimbot'),
        enabled_resolver_tweaks = interface.header.general:checkbox('\aa5ab55ffresolver tweaks'),
        resolver_mode = interface.header.general:combobox('mode', 'owl'),
        smart_safety = interface.header.general:checkbox('smart safety'),
        silent_shot = interface.header.general:checkbox('silent shot'),
        force_recharge = interface.header.general:checkbox('allow force recharge'),
        quick_stop = interface.header.general:checkbox('air stop', 0x00)
    }
    
    interface.builder = {
        enabled_builder = interface.header.general:checkbox('enable builder'),
        current_state = interface.header.general:combobox('state', prepare_aa.condition_names),
        condition = {}
    }

    gs_tooltips = {[0] = "GS"}

    for i, name in pairs(prepare_aa.condition_names) do
        interface.builder.condition[name] = {
            override = interface.header.general:checkbox('override ' .. prepare_aa.condition_names[i]),
            yaw_base = interface.header.general:combobox('yaw base', {'local view', 'at targets'}),
            offset_left = interface.header.general:slider('offset left', -180, 180, 0, true, '°'),
            offset_right = interface.header.general:slider('offset right', -180, 180, 0, true, '°'),
            yaw_modifier = interface.header.general:combobox('yaw modifier', {'off', 'center', 'offset', 'random', 'skitter', 'spin', '3-way', '5-way'}),
            yaw_modifier_offset = interface.header.general:slider('way offset', -180, 180, 0, true, '°'),
            left_limit = interface.header.general:slider('left limit', -180, 180, 0),
            right_limit = interface.header.general:slider('right limit', -180, 180, 0),
            spin_angle = interface.header.general:slider('spin angle', -180, 180, 0, true, '°'),
            fake_options = interface.header.general:combobox('fake options', {'off', 'opposite', 'jitter', 'static'}),
            delay_tick = interface.header.general:slider('delay tick', 0, 100, 0, true, '%', 1, gs_tooltips),
            offset = interface.header.general:slider('offset', -180, 180, 0, true, '°'),
            
            hide_lc = interface.header.general:checkbox('\aa5ab55ffhide lc anti aim'),
            pitch = interface.header.general:combobox('pitch', {'disabled', 'zero', 'up', 'medium', 'random', 'switch up', 'switch down', 'custom'}),
            pitch_angle = interface.header.general:slider('angle', -89, 89, 0, true, '°'),
            type = interface.header.general:combobox('type', {'disabled', 'meta', 'switch', 'spin', 'free sway', 'forward', 'switch left', 'switch right', 'custom'}),
            spin_speed = interface.header.general:slider('spin speed', 0, 100, 0, true, '%'),
            type_offset_left = interface.header.general:slider('type offset left', -180, 180, 0, true, '°'),
            type_offset_right = interface.header.general:slider('type offset right', -180, 180, 0, true, '°'),
            empty = interface.header.general:label(interface.additional.empty)
        }
    end

    interface.visuals = {
        enabled_visuals = interface.header.general:checkbox('enable visuals'),
        group = interface.header.general:combobox('group', 'general', 'other'),
        accent = interface.header.general:label('accent color', {120, 160, 180}),
        secondary = interface.header.general:label('secondary color', {215, 240, 255}),
        vgui = interface.header.general:label('vgui color', {255, 255, 255}), -- 140, 140, 140
        crosshair_indicators = interface.header.general:checkbox('crosshair indicators'),
        crosshair_style = interface.header.general:combobox('style', {'default', 'center'}),
        window = interface.header.general:checkbox('debug window'),
        -- shared = interface.header.general:checkbox('shared identity (wip)'),
        logging = interface.header.general:checkbox('logging'),
        logging_options = interface.header.general:multiselect('options', 'console', 'screen'),
        logging_options_console = interface.header.general:multiselect('console', 'aimbot', 'fire', 'hit', 'miss', 'buy'),
        logging_options_screen = interface.header.general:multiselect('screen', 'aimbot', 'fire', 'hit', 'miss'),
        logging_slider = interface.header.general:slider('slider', 40, 450, 240),
        aspect_ratio = interface.header.general:checkbox('override aspect ratio'),
        aspect_ratio_slider = interface.header.general:slider('value', 0, aspect_ratio.steps, aspect_ratio.steps/2, true, '', 1, aspect_ratio.ratio_table),
        thirdperson = interface.header.general:checkbox('override thirdperson distance'),
        thirdperson_slider = interface.header.general:slider('distance', 30, 150, 50, true, ''),
        viewmodel = interface.header.general:checkbox('override viewmodel'),
        viewmodel_fov = interface.header.general:slider('fov', -90, 90, cvar.viewmodel_fov:get_float()),
        viewmodel_x = interface.header.general:slider('x', -1000, 1000, cvar.viewmodel_offset_x:get_float(), true, '', 0.01),
        viewmodel_y = interface.header.general:slider('y', -1000, 1000, cvar.viewmodel_offset_y:get_float(), true, '', 0.01),
        viewmodel_z = interface.header.general:slider('z', -1000, 1000, cvar.viewmodel_offset_z:get_float(), true, '', 0.01),
        zoom_animation = interface.header.general:checkbox('zoom animation'),
        zoom_animation_speed = interface.header.general:slider('speed', 10, 100, 60, true, '%'),
        zoom_animation_value = interface.header.general:slider('strength', 1, 100, 5, true, '%'),
        spawn_zoom = interface.header.general:checkbox('spawn zoom'),
        stickman = interface.header.general:checkbox('stickman', {255, 255, 255, 140})
    }

    interface.models = {
        enabled_models = interface.header.general:checkbox('enable model changer'),
        list = interface.header.general:listbox('models', 350),
        new_model_weapon = interface.header.general:combobox('weapon', {"ak47", "aug", "famas", "galilar", "m4a1", "m4a1_silencer", "sg556", "awp", "ssg08", "scar20", "g3sg1", "m249", "negev", "nova", "xm1014", "mag7", "sawedoff", "mac10", "mp7", "mp9", "mp5sd", "ump45", "p90", "bizon", "glock", "elite", "p250", "tec9", "cz75a", "deagle", "revolver", "usp_silencer", "hkp2000", "fiveseven", "flashbang", "hegrenade", "smokegrenade", "molotov", "decoy", "incgrenade", "taser", "knife"}),
        new_model_button = interface.header.general:button('import from clipboard'),
        model_enabled = interface.header.general:checkbox('enabled'),
        delete_model_button = interface.header.general:button('delete model'),
        tip = interface.header.general:label('example: models/weapons/weapon_name.mdl'),
        tip2 = interface.header.general:label('you can configure models in noctua-models.json from game directory'),
    }

    interface.utility = {
        -- item_anti_crash = interface.header.general:checkbox('\aa5ab55ffchat filter (crash & noise)'),
        clantag = interface.header.general:checkbox('clantag'),
        killsay = interface.header.general:checkbox('balabolka'),
        killsay_modes = interface.header.general:multiselect('modes', 'on kill', 'on death'),
        hitsound = interface.header.general:checkbox('hitsound'),
        buybot = interface.header.general:checkbox('buybot'),
        buybot_primary = interface.header.general:combobox('primary weapon', '-', 'autosnipers', 'scout', 'awp'),
        buybot_secondary = interface.header.general:combobox('secondary weapon', '-', 'r8 / deagle', 'tec-9 / five-s / cz-75', 'duals', 'p-250'),
        buybot_utility = interface.header.general:multiselect('utility', 'kevlar', 'helmet', 'defuser', 'taser', 'he', 'molotov', 'smoke'),
        -- animation_breakers = interface.header.general:multiselect('animation breakers (wip)', 'global', 'ground', 'air'),
        -- animation_breakers_global = interface.header.general:multiselect('global', 'smooth animation', '2021 animation', 'model scale', 'zero pitch'),
        -- animation_breakers_ground = interface.header.general:combobox('ground', '-', 'follow', 'follow invert', 'jitter', 'jitter freeze', 'freeze', 'freeze invert', 'bug'),
        -- animation_breakers_air = interface.header.general:combobox('air', '-', 'freeze', 'jitter', 'walk')
        -- uncomment later
        -- import_config = interface.header.general:button('import config'),
        -- export_config = interface.header.general:button('export config'),
        -- default_config = interface.header.general:button('default config'),
    }

    -- interface.utility.item_anti_crash:override(true) -- uncomment later

    interface.hide_references = {
        pui.reference('players', 'adjustments', 'add to whitelist'),
        pui.reference('players', 'adjustments', 'allow shared ESP updates'),
        pui.reference('players', 'adjustments', 'disable visuals'),
        pui.reference('players', 'adjustments', 'high priority'),
        pui.reference('players', 'adjustments', 'override prefer body aim'),
        pui.reference('players', 'adjustments', 'override safe point'),
        pui.reference('players', 'adjustments', 'apply to all'),
        pui.reference('players', 'adjustments', 'force pitch'),
        pui.reference('players', 'adjustments', 'force body yaw'),
        pui.reference('players', 'adjustments', 'correction active'),
        pui.reference('players', 'adjustments', 'force body yaw value'),
        pui.reference('players', 'adjustments', 'force pitch value'),
        pui.reference('players', 'adjustments', 'apply to all')
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

    interface.setup = function()
        local selection = interface.search:get()
        local groups = {
            aimbot = interface.aimbot,
            visuals = interface.visuals,
            builder = interface.builder,
            models = interface.models,
            utility = interface.utility
        }

        local visibility_config = {
            aimbot = {
                groups_to_show = { groups.aimbot },
                groups_to_hide = { groups.visuals, groups.builder, groups.models, groups.utility },
                element_visibility_logic = function(element, path)
                    local key = path[#path]
                    if key == 'enabled_aimbot' then
                        element:set_visible(true)
                    elseif key == 'resolver_mode' then
                        element:set_visible(interface.aimbot.enabled_aimbot:get() and interface.aimbot.enabled_resolver_tweaks:get())
                    elseif key == 'smart_safety' then
                        element:set_visible(interface.aimbot.enabled_aimbot:get() and interface.aimbot.enabled_resolver_tweaks:get())
                    else
                        element:set_visible(interface.aimbot.enabled_aimbot:get() == true)
                    end
                end
            },
            visuals = {
                groups_to_show = { groups.visuals },
                groups_to_hide = { groups.aimbot, groups.builder, groups.models, groups.utility },
                element_visibility_logic = function(element, path)
                    local key = path[#path]
                    local is_other_selected = interface.visuals.group:get() == 'other'
                    local visuals_enabled = interface.visuals.enabled_visuals:get()

                    if key == 'enabled_visuals' then
                        element:set_visible(true)
                        return
                    end

                    if not visuals_enabled then
                        element:set_visible(false)
                        return
                    end

                    local other_only_elements = {
                        aspect_ratio = true,
                        aspect_ratio_slider = true,
                        thirdperson = true,
                        thirdperson_slider = true,
                        viewmodel = true,
                        viewmodel_fov = true,
                        viewmodel_x = true,
                        viewmodel_y = true,
                        viewmodel_z = true,
                        zoom_animation = true,
                        zoom_animation_speed = true,
                        zoom_animation_value = true,
                        spawn_zoom = true,
                        logging_options = true,
                        logging_options_console = true,
                        logging_options_screen = true
                    }

                    if other_only_elements[key] then
                        element:set_visible(is_other_selected)
                        return
                    end

                    if key == 'group' then
                        element:set_visible(true)
                        return
                    end

                    if key == 'logging' or key:find('logging_') then
                        element:set_visible(not is_other_selected)
                        return
                    end

                    if key == 'crosshair_style' then
                        element:set_visible((not is_other_selected) and interface.visuals.crosshair_indicators:get())
                        return
                    end

                    element:set_visible(not is_other_selected)
                end,
                post_visibility_logic = function()
                    local visuals_enabled = interface.visuals.enabled_visuals:get()
                    
                    if interface.visuals.logging then
                        local logging_enabled = visuals_enabled and interface.visuals.logging:get() == true
                        interface.visuals.logging_options:set_visible(logging_enabled and not (interface.visuals.group:get() == 'other'))
                        interface.visuals.logging_slider:set_visible(false)
                        if logging_enabled and not (interface.visuals.group:get() == 'other') then
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
                        local show_aspect = interface.visuals.group:get() == 'other' and visuals_enabled
                        interface.visuals.aspect_ratio:set_visible(show_aspect)
                        interface.visuals.aspect_ratio_slider:set_visible(show_aspect and interface.visuals.aspect_ratio:get())
                    end

                    if interface.visuals.thirdperson then
                        local show_thirdperson = interface.visuals.group:get() == 'other' and visuals_enabled
                        interface.visuals.thirdperson:set_visible(show_thirdperson)
                        interface.visuals.thirdperson_slider:set_visible(show_thirdperson and interface.visuals.thirdperson:get())
                    end

                    if interface.visuals.viewmodel then
                        local show_viewmodel = interface.visuals.group:get() == 'other' and visuals_enabled
                        interface.visuals.viewmodel:set_visible(show_viewmodel)
                        local show_viewmodel_settings = show_viewmodel and interface.visuals.viewmodel:get()
                        interface.visuals.viewmodel_fov:set_visible(show_viewmodel_settings)
                        interface.visuals.viewmodel_x:set_visible(show_viewmodel_settings)
                        interface.visuals.viewmodel_y:set_visible(show_viewmodel_settings)
                        interface.visuals.viewmodel_z:set_visible(show_viewmodel_settings)
                    end

                    if interface.visuals.zoom_animation then
                        local show_zoom = interface.visuals.group:get() == 'other' and visuals_enabled
                        interface.visuals.zoom_animation:set_visible(show_zoom)
                        local show_zoom_settings = show_zoom and interface.visuals.zoom_animation:get()
                        interface.visuals.zoom_animation_speed:set_visible(show_zoom_settings)
                        interface.visuals.zoom_animation_value:set_visible(show_zoom_settings)
                    end
                end
            },
            builder = {
                groups_to_show = { groups.builder },
                groups_to_hide = { groups.aimbot, groups.visuals, groups.models, groups.utility },
                element_visibility_logic = function(element, path)
                    local key = path[#path]
                    if key == 'enabled_builder' then
                        element:set_visible(true)
                        return
                    end

                    if not interface.builder.enabled_builder:get() then
                        element:set_visible(false)
                        return
                    end

                    if key == 'current_state' then
                        element:set_visible(true)
                        return
                    end

                    local current_state = interface.builder.current_state:get()
                    local element_state = nil

                    for _, state in ipairs(prepare_aa.condition_names) do
                        if path[2] == state then
                            element_state = state
                            break
                        end
                    end

                    if element_state then
                        local should_show = current_state == element_state
                        if not should_show then
                            element:set_visible(false)
                            return
                        end

                        if key == 'override' then
                            element:set_visible(element_state ~= 'default')
                            return
                        end

                        if element_state ~= 'default' then
                            local override_enabled = interface.builder.condition[element_state].override:get()
                            if not override_enabled then
                                element:set_visible(false)
                                return
                            end
                        end

                        if key == 'yaw_modifier_offset' then
                            local yaw_modifier = interface.builder.condition[element_state].yaw_modifier:get()
                            element:set_visible(yaw_modifier == '3-way' or yaw_modifier == '5-way')
                            return
                        end

                        if key == 'left_limit' or key == 'right_limit' then
                            local yaw_modifier = interface.builder.condition[element_state].yaw_modifier:get()
                            element:set_visible(yaw_modifier ~= 'off' and yaw_modifier ~= 'spin' and yaw_modifier ~= '3-way' and yaw_modifier ~= '5-way')
                            return
                        end

                        if key == 'spin_angle' then
                            local yaw_modifier = interface.builder.condition[element_state].yaw_modifier:get()
                            element:set_visible(yaw_modifier == 'spin')
                            return
                        end

                        if key == 'body_yaw_offset' then
                            local body_yaw = interface.builder.condition[element_state].body_yaw:get()
                            element:set_visible(body_yaw ~= 'off' and body_yaw ~= 'opposite')
                            return
                        end

                        if key == 'delay_tick' then
                            local fake_options = interface.builder.condition[element_state].fake_options:get()
                            element:set_visible(fake_options == 'jitter')
                            return
                        end

                        if key == 'offset' then
                            local fake_options = interface.builder.condition[element_state].fake_options:get()
                            element:set_visible(fake_options == 'jitter' or fake_options == 'static')
                            return
                        end

                        local hide_lc = interface.builder.condition[element_state].hide_lc:get()
                        
                        if key == 'pitch' or key == 'type' then
                            element:set_visible(hide_lc)
                            return
                        end

                        if key == 'pitch_angle' then
                            local pitch_mode = interface.builder.condition[element_state].pitch:get()
                            element:set_visible(hide_lc and pitch_mode == 'custom')
                            return
                        end

                        if key == 'type_offset_left' or key == 'type_offset_right' then
                            local type_mode = interface.builder.condition[element_state].type:get()
                            element:set_visible(hide_lc and type_mode == 'custom')
                            return
                        end

                        if key == 'lc_mode' then
                            element:set_visible(hide_lc)
                            return
                        end

                        if key == 'lc_type' then
                            local lc_mode = interface.builder.condition[element_state].lc_mode:get()
                            element:set_visible(hide_lc and lc_mode ~= 'off' and lc_mode ~= 'custom')
                            return
                        end

                        if key == 'spin_speed' then
                            local type_mode = interface.builder.condition[element_state].type:get()
                            element:set_visible(hide_lc and type_mode == 'spin')
                            return
                        end

                        if key:find("defensive_") then
                            local lc_mode = interface.builder.condition[element_state].lc_mode:get()
                            
                            if not (hide_lc and lc_mode == "custom") then
                                element:set_visible(false)
                                return
                            end

                            if key == "defensive_pitch_value" then
                                local pitch_mode = interface.builder.condition[element_state].defensive_pitch:get()
                                element:set_visible(pitch_mode == "custom")
                                return
                            end

                            if key == "defensive_yaw_value" then
                                local yaw_mode = interface.builder.condition[element_state].defensive_yaw:get()
                                element:set_visible(yaw_mode == "custom")
                                return
                            end

                            if key == "defensive_modifier_value" then
                                local modifier_mode = interface.builder.condition[element_state].defensive_modifier:get()
                                element:set_visible(modifier_mode ~= "off")
                                return
                            end

                            element:set_visible(true)
                            return
                        end

                        if key:find("lc_custom_") then
                            if not hide_lc then
                                element:set_visible(false)
                                return
                            end

                            local lc_mode = interface.builder.condition[element_state].lc_mode:get()
                            local lc_type = interface.builder.condition[element_state].lc_type:get()

                            if key:find("pitch_") or key:find("yaw_") then
                                element:set_visible(lc_mode == "custom")
                            elseif key:find("ticks_") or key:find("timing_") or key:find("offset") then
                                element:set_visible(lc_type == "custom")
                            else
                                element:set_visible(false)
                            end
                            return
                        end

                        element:set_visible(true)
                    else
                        element:set_visible(false)
                    end
                end
            },
            models = {
                groups_to_show = { groups.models },
                groups_to_hide = { groups.aimbot, groups.visuals, groups.builder, groups.utility }
            },
            utility = {
                groups_to_show = { groups.utility },
                groups_to_hide = { groups.aimbot, groups.visuals, groups.builder, groups.models },
                element_visibility_logic = function(element, path)
                    if element and element.set_visible then
                        local key = path[#path]
                        
                        if key == "animation_breakers_global" then
                            element:set_visible(interface.utility.animation_breakers:get("global"))
                            return
                        end
                        
                        if key == "animation_breakers_ground" then
                            element:set_visible(interface.utility.animation_breakers:get("ground"))
                            return
                        end
                        
                        if key == "animation_breakers_air" then
                            element:set_visible(interface.utility.animation_breakers:get("air"))
                            return
                        end
                        
                        if key == "buybot_primary" or key == "buybot_secondary" or key == "buybot_utility" then
                            element:set_visible(interface.utility.buybot:get())
                            return
                        end
                        
                        if key == "killsay_modes" then
                            element:set_visible(interface.utility.killsay:get())
                            return
                        end
                        
                        element:set_visible(true)
                    end
                end
            },
            default = {
                groups_to_hide = { groups.aimbot, groups.visuals, groups.builder, groups.models, groups.utility }
            }
        }

        local config = visibility_config[selection] or visibility_config.default

        if config.groups_to_show then
            for _, group in ipairs(config.groups_to_show) do
                pui.traverse(group, function(element, path)
                    if element and element.set_visible then
                        if config.element_visibility_logic then
                            config.element_visibility_logic(element, path)
                        else
                            element:set_visible(true)
                        end
                    end
                end)
            end
        end

        if config.groups_to_hide then
            for _, group in ipairs(config.groups_to_hide) do
                pui.traverse(group, function(element, path)
                    if element and element.set_visible then
                        element:set_visible(false)
                    end
                end)
            end
        end

        if config.post_visibility_logic then
            config.post_visibility_logic()
        end
    end
end

client.set_event_callback('paint_ui', function()
    interface.update_visibility()
    interface.setup()
end)

client.set_event_callback('shutdown', interface.show)

-- 1:1 thirdperson distance: apply only on slider change
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
--@endregion

logMessage("noctua ·", "", update)

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

--@region: configs
-- configs = {} do
--     configs.encode = function(str)
--         local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
--         return ((str:gsub('.', function(x) 
--             local r,b='',x:byte()
--             for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
--             return r;
--         end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
--             if (#x < 6) then return '' end
--             local c=0
--             for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
--             return b:sub(c+1,c+1)
--         end)..({ '', '==', '=' })[#str%3+1])
--     end

--     configs.decode = function(str)
--         local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
--         str = string.gsub(str, '[^'..b..'=]', '')
--         return (str:gsub('.', function(x)
--             if (x == '=') then return '' end
--             local r,f='',(b:find(x)-1)
--             for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
--             return r;
--         end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
--             if (#x ~= 8) then return '' end
--             local c=0
--             for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
--             return string.char(c)
--         end))
--     end

--     configs.export = function()
--         if not interface.builder.enabled_builder:get() then
--             logMessage("noctua ·", "Enable builder first!")
--             return
--         end

--         local config = {
--             conditions = {}
--         }

--         for _, condition_name in ipairs(prepare_aa.condition_names) do
--             config.conditions[condition_name] = {
--                 override = interface.builder.condition[condition_name].override:get(),
--                 yaw_base = interface.builder.condition[condition_name].yaw_base:get(),
--                 offset_left = interface.builder.condition[condition_name].offset_left:get(),
--                 offset_right = interface.builder.condition[condition_name].offset_right:get(),
--                 yaw_modifier = interface.builder.condition[condition_name].yaw_modifier:get(),
--                 yaw_modifier_offset = interface.builder.condition[condition_name].yaw_modifier_offset:get(),
--                 left_limit = interface.builder.condition[condition_name].left_limit:get(),
--                 right_limit = interface.builder.condition[condition_name].right_limit:get(),
--                 spin_angle = interface.builder.condition[condition_name].spin_angle:get(),
--                 fake_options = interface.builder.condition[condition_name].fake_options:get(),
--                 delay_tick = interface.builder.condition[condition_name].delay_tick:get(),
--                 offset = interface.builder.condition[condition_name].offset:get(),
--                 hide_lc = interface.builder.condition[condition_name].hide_lc:get(),
--                 pitch = interface.builder.condition[condition_name].pitch:get(),
--                 pitch_angle = interface.builder.condition[condition_name].pitch_angle:get(),
--                 type = interface.builder.condition[condition_name].type:get(),
--                 spin_speed = interface.builder.condition[condition_name].spin_speed:get(),
--                 type_offset_left = interface.builder.condition[condition_name].type_offset_left:get(),
--                 type_offset_right = interface.builder.condition[condition_name].type_offset_right:get()
--             }
--         end

--         local json_str = json.stringify(config)
--         local encoded = configs.encode(json_str)
        
--         clipboard.set("noctua:" .. encoded)
--         logMessage("noctua ·", "", "Config exported to clipboard!")
--     end

--     configs.import = function()
--         local clipboard_content = clipboard.get()
        
--         if not clipboard_content:match("^noctua:") then
--             logMessage("noctua ·", "Invalid config format in clipboard!")
--             return
--         end

--         local encoded = clipboard_content:sub(8)
--         local decoded = configs.decode(encoded)
        
--         local jsonPart = decoded:match("^(%b{})")
--         if not jsonPart then
--             logMessage("noctua ·", "Failed to extract valid JSON from imported config!")
--             return
--         end

--         local success, config = pcall(json.parse, jsonPart)
--         if not success or not config.conditions then
--             logMessage("noctua ·", "Failed to parse config!")
--             return
--         end

--         for condition_name, settings in pairs(config.conditions) do
--             if interface.builder.condition[condition_name] then
--                 for setting_name, value in pairs(settings) do
--                     local element = interface.builder.condition[condition_name][setting_name]
--                     if element and element.set then
--                         element:set(value)
--                     end
--                 end
--             end
--         end

--         logMessage("noctua ·", "", "Config imported successfully!")
--     end

--     configs.default = function()
--         local default_config = "noctua:eyJjb25kaXRpb25zIjp7InVzZSI6eyJ5YXdfbW9kaWZpZXJfb2Zmc2V0IjowLCJwaXRjaCI6InJhbmRvbSIsImRlbGF5X3RpY2siOjgsImhpZGVfbGMiOnRydWUsIm9mZnNldCI6NTAsInJpZ2h0X2xpbWl0IjowLCJvZmZzZXRfbGVmdCI6LTExLCJvdmVycmlkZSI6ZmFsc2UsInBpdGNoX2FuZ2xlIjowLCJ5YXdfYmFzZSI6ImF0IHRhcmdldHMiLCJsZWZ0X2xpbWl0IjowLCJ0eXBlX29mZnNldF9yaWdodCI6MTgwLCJ0eXBlX29mZnNldF9sZWZ0Ijo5LCJzcGluX3NwZWVkIjowLCJvZmZzZXRfcmlnaHQiOjQsInR5cGUiOiJjdXN0b20iLCJ5YXdfbW9kaWZpZXIiOiJza2l0dGVyIiwiZmFrZV9vcHRpb25zIjoiaml0dGVyIiwic3Bpbl9hbmdsZSI6MTZ9LCJzbG93Ijp7Inlhd19tb2RpZmllcl9vZmZzZXQiOjM5LCJwaXRjaCI6InVwIiwiZGVsYXlfdGljayI6MCwiaGlkZV9sYyI6dHJ1ZSwib2Zmc2V0IjoyMywicmlnaHRfbGltaXQiOjAsIm9mZnNldF9sZWZ0IjotMjcsIm92ZXJyaWRlIjp0cnVlLCJwaXRjaF9hbmdsZSI6MCwieWF3X2Jhc2UiOiJhdCB0YXJnZXRzIiwibGVmdF9saW1pdCI6MCwidHlwZV9vZmZzZXRfcmlnaHQiOjE4MCwidHlwZV9vZmZzZXRfbGVmdCI6OSwic3Bpbl9zcGVlZCI6NjcsIm9mZnNldF9yaWdodCI6MjcsInR5cGUiOiJzcGluIiwieWF3X21vZGlmaWVyIjoib2ZmIiwiZmFrZV9vcHRpb25zIjoiaml0dGVyIiwic3Bpbl9hbmdsZSI6MTZ9LCJtYW51YWwiOnsieWF3X21vZGlmaWVyX29mZnNldCI6MCwicGl0Y2giOiJyYW5kb20iLCJkZWxheV90aWNrIjo4LCJoaWRlX2xjIjp0cnVlLCJvZmZzZXQiOjUwLCJyaWdodF9saW1pdCI6MCwib2Zmc2V0X2xlZnQiOi0xMSwib3ZlcnJpZGUiOmZhbHNlLCJwaXRjaF9hbmdsZSI6MCwieWF3X2Jhc2UiOiJhdCB0YXJnZXRzIiwibGVmdF9saW1pdCI6MCwidHlwZV9vZmZzZXRfcmlnaHQiOjE4MCwidHlwZV9vZmZzZXRfbGVmdCI6OSwic3Bpbl9zcGVlZCI6MCwib2Zmc2V0X3JpZ2h0Ijo0LCJ0eXBlIjoiY3VzdG9tIiwieWF3X21vZGlmaWVyIjoic2tpdHRlciIsImZha2Vfb3B0aW9ucyI6ImppdHRlciIsInNwaW5fYW5nbGUiOjE2fSwicnVuIjp7Inlhd19tb2RpZmllcl9vZmZzZXQiOjAsInBpdGNoIjoic3dpdGNoIHVwIiwiZGVsYXlfdGljayI6OCwiaGlkZV9sYyI6dHJ1ZSwib2Zmc2V0Ijo1MCwicmlnaHRfbGltaXQiOi0yMywib2Zmc2V0X2xlZnQiOi0xMSwib3ZlcnJpZGUiOnRydWUsInBpdGNoX2FuZ2xlIjowLCJ5YXdfYmFzZSI6ImF0IHRhcmdldHMiLCJsZWZ0X2xpbWl0IjotMTgsInR5cGVfb2Zmc2V0X3JpZ2h0IjozMCwidHlwZV9vZmZzZXRfbGVmdCI6MzksInNwaW5fc3BlZWQiOjAsIm9mZnNldF9yaWdodCI6MCwidHlwZSI6ImN1c3RvbSIsInlhd19tb2RpZmllciI6InNraXR0ZXIiLCJmYWtlX29wdGlvbnMiOiJqaXR0ZXIiLCJzcGluX2FuZ2xlIjoxNn0sImZyZWVzdGFuZCI6eyJ5YXdfbW9kaWZpZXJfb2Zmc2V0IjowLCJwaXRjaCI6InJhbmRvbSIsImRlbGF5X3RpY2siOjAsImhpZGVfbGMiOmZhbHNlLCJvZmZzZXQiOjUwLCJyaWdodF9saW1pdCI6MjcsIm9mZnNldF9sZWZ0IjotMTEsIm92ZXJyaWRlIjp0cnVlLCJwaXRjaF9hbmdsZSI6MCwieWF3X2Jhc2UiOiJhdCB0YXJnZXRzIiwibGVmdF9saW1pdCI6LTI1LCJ0eXBlX29mZnNldF9yaWdodCI6MTgwLCJ0eXBlX29mZnNldF9sZWZ0Ijo5LCJzcGluX3NwZWVkIjowLCJvZmZzZXRfcmlnaHQiOjksInR5cGUiOiJjdXN0b20iLCJ5YXdfbW9kaWZpZXIiOiJjZW50ZXIiLCJmYWtlX29wdGlvbnMiOiJqaXR0ZXIiLCJzcGluX2FuZ2xlIjoxNn0sImFpciI6eyJ5YXdfbW9kaWZpZXJfb2Zmc2V0IjowLCJwaXRjaCI6ImN1c3RvbSIsImRlbGF5X3RpY2siOjE2LCJoaWRlX2xjIjp0cnVlLCJvZmZzZXQiOjUwLCJyaWdodF9saW1pdCI6LTIwLCJvZmZzZXRfbGVmdCI6LTExLCJvdmVycmlkZSI6dHJ1ZSwicGl0Y2hfYW5nbGUiOjg5LCJ5YXdfYmFzZSI6ImF0IHRhcmdldHMiLCJsZWZ0X2xpbWl0IjoxOCwidHlwZV9vZmZzZXRfcmlnaHQiOjYwLCJ0eXBlX29mZnNldF9sZWZ0IjotMzYsInNwaW5fc3BlZWQiOjAsIm9mZnNldF9yaWdodCI6MTEsInR5cGUiOiJjdXN0b20iLCJ5YXdfbW9kaWZpZXIiOiJvZmZzZXQiLCJmYWtlX29wdGlvbnMiOiJqaXR0ZXIiLCJzcGluX2FuZ2xlIjoxNn0sImFpcmMiOnsieWF3X21vZGlmaWVyX29mZnNldCI6MCwicGl0Y2giOiJzd2l0Y2ggdXAiLCJkZWxheV90aWNrIjowLCJoaWRlX2xjIjp0cnVlLCJvZmZzZXQiOjE4LCJyaWdodF9saW1pdCI6MCwib2Zmc2V0X2xlZnQiOi0xOCwib3ZlcnJpZGUiOnRydWUsInBpdGNoX2FuZ2xlIjowLCJ5YXdfYmFzZSI6ImF0IHRhcmdldHMiLCJsZWZ0X2xpbWl0IjowLCJ0eXBlX29mZnNldF9yaWdodCI6MTgwLCJ0eXBlX29mZnNldF9sZWZ0Ijo5LCJzcGluX3NwZWVkIjowLCJvZmZzZXRfcmlnaHQiOjI3LCJ0eXBlIjoic3dpdGNoIiwieWF3X21vZGlmaWVyIjoib2ZmIiwiZmFrZV9vcHRpb25zIjoiaml0dGVyIiwic3Bpbl9hbmdsZSI6MTZ9LCJkdWNrIjp7Inlhd19tb2RpZmllcl9vZmZzZXQiOjAsInBpdGNoIjoic3dpdGNoIHVwIiwiZGVsYXlfdGljayI6NDQsImhpZGVfbGMiOnRydWUsIm9mZnNldCI6LTMwLCJyaWdodF9saW1pdCI6MCwib2Zmc2V0X2xlZnQiOi0zNiwib3ZlcnJpZGUiOnRydWUsInBpdGNoX2FuZ2xlIjowLCJ5YXdfYmFzZSI6ImF0IHRhcmdldHMiLCJsZWZ0X2xpbWl0Ijo0LCJ0eXBlX29mZnNldF9yaWdodCI6MTgwLCJ0eXBlX29mZnNldF9sZWZ0Ijo5LCJzcGluX3NwZWVkIjowLCJvZmZzZXRfcmlnaHQiOjMyLCJ0eXBlIjoibWV0YSIsInlhd19tb2RpZmllciI6Im9mZiIsImZha2Vfb3B0aW9ucyI6ImppdHRlciIsInNwaW5fYW5nbGUiOjE2fSwiaWRsZSI6eyJ5YXdfbW9kaWZpZXJfb2Zmc2V0IjowLCJwaXRjaCI6InJhbmRvbSIsImRlbGF5X3RpY2siOjI2LCJoaWRlX2xjIjp0cnVlLCJvZmZzZXQiOjI3LCJyaWdodF9saW1pdCI6MCwib2Zmc2V0X2xlZnQiOi0xMSwib3ZlcnJpZGUiOnRydWUsInBpdGNoX2FuZ2xlIjowLCJ5YXdfYmFzZSI6ImF0IHRhcmdldHMiLCJsZWZ0X2xpbWl0IjowLCJ0eXBlX29mZnNldF9yaWdodCI6MTgwLCJ0eXBlX29mZnNldF9sZWZ0Ijo5LCJzcGluX3NwZWVkIjowLCJvZmZzZXRfcmlnaHQiOjQsInR5cGUiOiJtZXRhIiwieWF3X21vZGlmaWVyIjoic2tpdHRlciIsImZha2Vfb3B0aW9ucyI6ImppdHRlciIsInNwaW5fYW5nbGUiOjE2fSwiZHVjayBtb3ZlIjp7Inlhd19tb2RpZmllcl9vZmZzZXQiOjAsInBpdGNoIjoic3dpdGNoIHVwIiwiZGVsYXlfdGljayI6OCwiaGlkZV9sYyI6dHJ1ZSwib2Zmc2V0Ijo1MCwicmlnaHRfbGltaXQiOjAsIm9mZnNldF9sZWZ0IjotMTEsIm92ZXJyaWRlIjp0cnVlLCJwaXRjaF9hbmdsZSI6MCwieWF3X2Jhc2UiOiJhdCB0YXJnZXRzIiwibGVmdF9saW1pdCI6MCwidHlwZV9vZmZzZXRfcmlnaHQiOjE4MCwidHlwZV9vZmZzZXRfbGVmdCI6OSwic3Bpbl9zcGVlZCI6MCwib2Zmc2V0X3JpZ2h0Ijo0LCJ0eXBlIjoibWV0YSIsInlhd19tb2RpZmllciI6InNraXR0ZXIiLCJmYWtlX29wdGlvbnMiOiJqaXR0ZXIiLCJzcGluX2FuZ2xlIjoxNn0sImRlZmF1bHQiOnsieWF3X21vZGlmaWVyX29mZnNldCI6MCwicGl0Y2giOiJyYW5kb20iLCJkZWxheV90aWNrIjo4LCJoaWRlX2xjIjp0cnVlLCJvZmZzZXQiOjUwLCJyaWdodF9saW1pdCI6MCwib2Zmc2V0X2xlZnQiOi0xMSwib3ZlcnJpZGUiOmZhbHNlLCJwaXRjaF9hbmdsZSI6MCwieWF3X2Jhc2UiOiJhdCB0YXJnZXRzIiwibGVmdF9saW1pdCI6MCwidHlwZV9vZmZzZXRfcmlnaHQiOjE4MCwidHlwZV9vZmZzZXRfbGVmdCI6OSwic3Bpbl9zcGVlZCI6MCwib2Zmc2V0X3JpZ2h0Ijo0LCJ0eXBlIjoiY3VzdG9tIiwieWF3X21vZGlmaWVyIjoic2tpdHRlciIsImZha2Vfb3B0aW9ucyI6ImppdHRlciIsInNwaW5fYW5nbGUiOjE2fX19"

--         if default_config:sub(1, 7) ~= "noctua:" then
--             logMessage("noctua ·", "Invalid config format!")
--             return
--         end

--         local jsonPart = default_config:sub(8)
--         local decoded = configs.decode(jsonPart)
--         if not decoded then
--             logMessage("noctua ·", "Failed to decode base64!")
--             return
--         end

--         local success, config = pcall(json.parse, decoded)
--         if not success or not config.conditions then
--             logMessage("noctua ·", "Failed to parse config!")
--             return
--         end

--         for condition_name, settings in pairs(config.conditions) do
--             if interface.builder.condition[condition_name] then
--                 for setting_name, value in pairs(settings) do
--                     local element = interface.builder.condition[condition_name][setting_name]
--                     if element and element.set then
--                         element:set(value)
--                     end
--                 end
--             end
--         end

--         logMessage("noctua ·", "", "Default config loaded successfully!")
--     end

--     -- uncomment later
--     -- interface.utility.export_config:set_callback(configs.export)
--     -- interface.utility.import_config:set_callback(configs.import)
--     -- interface.utility.default_config:set_callback(configs.default)
-- end
-- --@endregion

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
    thirdperson = { ui.reference("visuals", "effects", "force third person (alive)") }
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

--@region: resolver
resolver = {} do
    resolver.layers     = {}
    resolver.safepoints = {}
    resolver.cache      = {}
    resolver.history    = {}
    resolver.state_cache = {}
    resolver.layer_cache = {}
    resolver.precision  = {}
    
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
        -- empty block
    end

    function resolver:on_aim_hit(e)
        -- empty block
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
        if not idx then
            return false
        end

        local animLayers = player.get_animlayer(idx)
        if not animLayers then
            return false
        end
        
        self.layers[idx] = self.layers[idx] or {}
        local playerLayers = self.layers[idx]

        for i = 1, 12 do
            local layer = animLayers[i]
            if layer then
                playerLayers[i] = playerLayers[i] or {}
                local currentLayer = playerLayers[i]
                currentLayer.m_playback_rate = layer.m_playback_rate or currentLayer.m_playback_rate or 0
                currentLayer.m_sequence = layer.m_sequence or currentLayer.m_sequence or 0
            end
        end
        return true
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
    
    resolver.setup = function(self)
        if not (interface.aimbot.enabled_aimbot:get() and interface.aimbot.enabled_resolver_tweaks:get()) then return end

        local local_player = entity.get_local_player()
        if not local_player then return end
        
        local health = entity.get_prop(local_player, "m_iHealth")
        if not health or health <= 0 then return end

        local enemies = entity.get_players(true)
        if not enemies then return end

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

                local animstate = player.get_animstate(idx)
                if not animstate then break end
                if not resolver:updateLayers(idx) then break end

                local vx, vy, vz, velocity_2d = player.get_velocity(idx)
                if not velocity_2d then break end
                
                local max_desync = resolver.getMaxDesyncDelta(idx)
                if not max_desync then break end

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
                if not lby then break end
                
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
                if not predicted_yaw then break end

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
            until true
        end
    end
end

client.set_event_callback('net_update_end', function()
    resolver:setup()
end)

--@endregion

--@region: animation breakers
-- animation_breakers = {} do
--     animation_breakers.global = function()
--         local animation_breakers = interface.utility.animation_breakers:get()
--         if not animation_breakers or not animation_breakers[1] then print("no animation breakers") return end

--         local local_player = entity.get_local_player()
--         if not local_player then return end

--         if animation_breakers and interface.utility.animation_breakers_global:get('model scale') then
--             entity.set_prop(local_player, 'm_flModelScale', 0.5)
--             entity.set_prop(local_player, 'm_ScaleType', 1)
--         else
--             entity.set_prop(local_player, 'm_flModelScale', 1)
--             entity.set_prop(local_player, 'm_ScaleType', 0)
--         end
--     end
-- end

-- client.set_event_callback('pre_render', function()
--     animation_breakers.global()
-- end)
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

--@region: widgets
widgets = {} do
    local SNAP = 8
    local PAD = 4
    local LINE_ALPHA = 40
    local LINE_ALPHA_SNAP = 80

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

    local function get_rect(id)
        local def = widgets.items[id]; if not def then return end
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
        x = x - PAD; y = y - PAD; w = w + PAD * 2; h = h + PAD * 2
        return mx >= x and mx <= x + w and my >= y and my <= y + h
    end

    function widgets.paint()
        local menuOpen = ui.is_menu_open()
        if menuOpen then return end -- Don't render widget content in edit mode
        
        local function widget_enabled_paint(id)
            if not interface.visuals.enabled_visuals:get() then return false end
            if id == "debug_window" then
                return interface.visuals.window:get()
            elseif id == "crosshair_indicators" then
                return interface.visuals.crosshair_indicators:get()
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
            if def and def.draw then
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
            end
            ::continue::
        end
    end

    function widgets.paint_ui()
        local menuOpen = ui.is_menu_open()
        local local_player = entity.get_local_player()
        
        local target_alpha = menuOpen and LINE_ALPHA or 0
        widgets.lines_alpha = mathematic.lerp(widgets.lines_alpha or 0, target_alpha, globals.frametime() * 12)

        -- Fade for widget edit containers
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
            elseif id == "crosshair_indicators" then
                return interface.visuals.crosshair_indicators:get()
            elseif id == "screen_logging" then
                if not interface.visuals.logging:get() then return false end
                local opts = interface.visuals.logging_options:get() or {}
                return utils.contains(opts, "screen")
            end

            return true
        end

        -- Recompute lines alpha based on whether any widget is enabled
        do
            local any_enabled = false
            for _, id in ipairs(widgets.order) do
                if widget_enabled(id) then any_enabled = true; break end
            end
            local target_alpha = (menuOpen and any_enabled) and LINE_ALPHA or 0
            widgets.lines_alpha = mathematic.lerp(widgets.lines_alpha or 0, target_alpha, globals.frametime() * 12)
        end

        local a = math.floor(widgets.lines_alpha + 0.5)
        local any_enabled_draw = false
        for _, id in ipairs(widgets.order) do
            if widget_enabled(id) then any_enabled_draw = true; break end
        end
        if any_enabled_draw and a > 0 then
            -- Draw crisp 1px guide lines
            renderer.rectangle(sw / 2, 0, 1, sh, 255, 255, 255, a)
            renderer.rectangle(0, sh / 2, sw, 1, 255, 255, 255, a)
        end
        local allow_interact = menuOpen
        if not allow_interact and (widgets.frames_alpha or 0) < 0.01 then return end

        if allow_interact and m1 and not widgets.is_dragging then
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
        elseif allow_interact and widgets.is_dragging and m1 then
            -- dragging preview handled in frame drawing below
        elseif allow_interact and widgets.is_dragging and not m1 then
            local id = widgets.active_id
            if id then
                local sw_, sh_ = client.screen_size()
                local cx = mx + (widgets.drag_dx or 0)
                local cy = my + (widgets.drag_dy or 0)
                local snapped_x = math.abs(cx - sw_ / 2) <= SNAP
                local snapped_y = math.abs(cy - sh_ / 2) <= SNAP
                if snapped_x then cx = sw_ / 2 end
                if snapped_y then cy = sh_ / 2 end
                local _, _, w, h = get_rect(id)
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
                widgets.save_all()
            end
            widgets.is_dragging = false
            widgets.active_id = nil
            widgets.drag_dx = 0; widgets.drag_dy = 0
        end

        for _, id in ipairs(widgets.order) do
            local enabled = widget_enabled(id)
            -- per-widget fade alpha
            widgets.widget_alpha = widgets.widget_alpha or {}
            local wa = widgets.widget_alpha[id] or 0
            local target = enabled and 1 or 0
            widgets.widget_alpha[id] = mathematic.lerp(wa, target, globals.frametime() * 12)

            local x, y, w, h, cx, cy = get_rect(id)
            if not (w and h and w > 0 and h > 0) then goto continue end

            -- combined visibility ratio (menu fade * widget fade)
            local ratio_widget = (widgets.widget_alpha[id] or 0) * (widgets.frames_alpha or 0)
            if ratio_widget <= 0.01 then goto continue end

            if widgets.is_dragging and widgets.active_id == id and allow_interact and enabled then
                local sw2, sh2 = client.screen_size()
                local mx2, my2 = ui.mouse_position()
                cx = mx2 + (widgets.drag_dx or 0)
                cy = my2 + (widgets.drag_dy or 0)
                local snapped_x = math.abs(cx - sw2 / 2) <= SNAP
                local snapped_y = math.abs(cy - sh2 / 2) <= SNAP
                if snapped_x then cx = sw2 / 2 end
                if snapped_y then cy = sh2 / 2 end
                local min_cx = (w / 2) + PAD
                local max_cx = sw2 - (w / 2) - PAD
                local min_cy = (h / 2) + PAD
                local max_cy = sh2 - (h / 2) - PAD
                cx = clamp(cx, min_cx, max_cx)
                cy = clamp(cy, min_cy, max_cy)
                x = cx - w / 2
                y = cy - h / 2
            end

            local hovered = false
            if allow_interact and enabled then
                local mx3, my3 = ui.mouse_position()
                hovered = hit_test(id, mx3, my3)
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

            -- Subtle background (snap to whole pixels for crisp borders)
            local rect_x = x - PAD
            local rect_y = y - PAD
            local rect_w = w + PAD * 2
            local rect_h = h + PAD * 2
            local rx, ry, rw, rh = round(rect_x), round(rect_y), round(rect_w), round(rect_h)
            renderer.rectangle(rx + 1, ry + 1, rw - 2, rh - 2, 255, 255, 255, bg_alpha)
            
            -- Border with small corner insets for a rounded look
            local inset = 2
            local oa = border_alpha
            -- top & bottom
            renderer.rectangle(rx + inset, ry, rw - inset * 2, 1, 255, 255, 255, oa)
            renderer.rectangle(rx + inset, ry + rh - 1, rw - inset * 2, 1, 255, 255, 255, oa)
            -- left & right
            renderer.rectangle(rx, ry + inset, 1, rh - inset * 2, 255, 255, 255, oa)
            renderer.rectangle(rx + rw - 1, ry + inset, 1, rh - inset * 2, 255, 255, 255, oa)

            local sw3, sh3 = client.screen_size()
            local snapped_x_now, snapped_y_now = false, false
            if allow_interact and enabled then
                snapped_x_now = math.abs(cx - sw3 / 2) <= SNAP
                snapped_y_now = math.abs(cy - sh3 / 2) <= SNAP
            end
            if allow_interact and widgets.is_dragging then
                if snapped_x_now then
                    renderer.rectangle(sw3 / 2, 0, 1, sh3, 255, 255, 255, LINE_ALPHA_SNAP)
                end
                if snapped_y_now then
                    renderer.rectangle(0, sh3 / 2, sw3, 1, 255, 255, 255, LINE_ALPHA_SNAP)
                end
            end

            local def = widgets.items[id]
            if def and def.draw and allow_interact and enabled then
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
        
        local windowEnabled = interface.visuals.enabled_visuals:get() 
                            and interface.visuals.window:get()
                            and not is_game_over
                            and not is_timeout
                            and not is_halftime
                            and not is_waiting
                            and not is_restarting
                            and ((local_player and (health > 0)) or menuOpen)

        local targetAlpha = windowEnabled and 255 or 0
        self.windowAlpha = mathematic.lerp(self.windowAlpha, targetAlpha, fadeSpeedSetting)

        if self.windowAlpha < 1 then
            return
        end

        local target = client.current_threat()
        local target_text = "target: none"
        local target_yaw_text = "target yaw: none"
        local enemy_state = "target state: none"

        if target then
            local player_info = utils.get_player_info(target)
            if player_info then
                target_text = "target: " .. ffi.string(player_info.__name)
                if interface.aimbot.enabled_aimbot:get() and interface.aimbot.enabled_resolver_tweaks:get() then
                    if player_info.__fakeplayer then
                        target_yaw_text = "target yaw: none (bot)"
                    else
                        target_yaw_text = "target yaw: " .. (resolver.cache[target] or 0)
                    end
                else
                    target_yaw_text = "target yaw: off"
                end
                enemy_state = "target state: " .. utils.get_enemy_state(target)
            end
        end

        local lines = {
            _name .. " " .. _version,
            target_text,
            enemy_state,
            target_yaw_text
        }

        local line_spacing = 12
        local total_height = #lines * line_spacing

        local a = align or "c"
        for i, line in ipairs(lines) do
            local y = base_y + (i - 1) * line_spacing
            renderer.text(base_x, y, 255, 255, 255, self.windowAlpha, a, 1000, line)
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
            local animatedStr = table.concat(colors.animate_text(
                globals.realtime() * self.timeSpeed, 
                self.base, 
                self.colors[1].r, self.colors[1].g, self.colors[1].b, alpha1, 
                self.colors[2].r, self.colors[2].g, self.colors[2].b, alpha2
            ))
            renderer.text(x, y, 255, 255, 255, overallAlpha, alignment, 1000, animatedStr)
        end
    }

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
        local isOS = ui.get(ui_references.on_shot_anti_aim[1]) and ui.get(ui_references.on_shot_anti_aim[2])
        local isDT = ui.get(ui_references.double_tap[1]) and ui.get(ui_references.double_tap[2])
        local isDMG = ui.get(ui_references.minimum_damage_override[1]) and ui.get(ui_references.minimum_damage_override[2])

        local style = (interface.visuals.crosshair_style and interface.visuals.crosshair_style:get()) or 'default'
        local align_text = (style == 'center') and 'c' or 'l'
        local align_title = (style == 'center') and 'cb' or 'lb'

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

        self.animated_text:render(base_x, self.element_positions.noctua, align_title, self.indicatorsAlpha)
        renderer.text(base_x, self.element_positions.state, 255, 255, 255, self.indicatorsAlpha, align_text, 1000, state)

        if smoothRapidAlpha >= 1 or smoothReloadAlpha >= 1 then
            renderer.text(base_x, self.element_positions.rapid, 255, 255, 255, smoothRapidAlpha, align_text, 1000, "rapid")
            renderer.text(base_x, self.element_positions.rapid, 255, 255, 255, smoothReloadAlpha, align_text, 1000, "reload")
        end

        if smoothOsaaAlpha >= 1 then
            renderer.text(base_x, self.element_positions.osaa, 255, 255, 255, smoothOsaaAlpha, align_text, 1000, "osaa")
        end
        
        if smoothDmgAlpha >= 1 then
            renderer.text(base_x, self.element_positions.dmg, 255, 255, 255, smoothDmgAlpha, align_text, 1000, "dmg")
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
                    if mat and mat.set_shader_param then
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
            end
            if csm_shadows then csm_shadows:set_int(0) end
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
                if mat and mat.set_shader_param then
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
        end
        local csm_shadows = cvar.cl_csm_shadows
        if csm_shadows then csm_shadows:set_int(1) end
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
                        if mat and mat.set_shader_param then
                            mat:set_shader_param("$alpha", 0)
                        end
                    end
                end
                local csm_shadows = cvar.cl_csm_shadows
                if csm_shadows then csm_shadows:set_int(0) end
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

client.set_event_callback('paint', function()
    widgets.paint()
    stickman:setup()
end)

logging = {} do
    client.exec("con_filter_enable 1") 
    client.exec("con_filter_text noctua")
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

        local msg = string.format(
            "fired at %s's %s for %d / lc: %d - yaw: %s",
            playerName, hitbox, hitChance, damage, lagComp, type(desiredYaw) == "number" and desiredYaw.."°" or desiredYaw.."°"
        )

        if doConsole then 
            argLog("fired at %s's %s for %d / lc: %d - yaw: %s", playerName, hitbox, hitChance, damage, lagComp, type(desiredYaw) == "number" and desiredYaw.."°" or desiredYaw.."°")
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
            reason = "resolver"
        elseif not reason or reason == "" then
            reason = "unregistered shot"
        end
    
        if reason == "spread" or reason == "prediction error" or reason == "death" then
            -- keep original reason
        elseif health <= 0 then
            reason = "player death"
        elseif reason == "resolver" then
            if cached.got_hit ~= nil and cached.got_hurt ~= nil then
                if cached.got_hit and not cached.got_hurt then
                    reason = "correction"
                elseif not cached.got_hit and cached.had_impact then
                    reason = "misprediction"
                end
            end
        end

        if lagComp > 14 and reason == "resolver" then
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
                "missed %s's %s / lc: %d - reason: death",
                playerName, hitgroup, lagComp
            )
        else
            if reason == "resolver" or reason == "correction" or reason == "misprediction" then
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
                argLog("missed %s's %s / lc: %d - reason: death", playerName, hitgroup, lagComp)
            else
                if reason == "resolver" or reason == "correction" or reason == "misprediction" then
                    argLog("missed %s's %s / lc: %d - yaw: %s - reason: %s", playerName, hitgroup, lagComp, type(desiredYaw) == "number" and desiredYaw.."°" or desiredYaw.."°", reason)
                else
                    argLog("missed %s's %s / lc: %d - reason: %s", playerName, hitgroup, lagComp, reason)
                end
            end
        end
        
        if doScreen then self:push(msg) end
    end
    
    logging.on_item_purchase = function(e)
        if not interface.visuals.logging:get() then return end
        
        local logOptions = interface.visuals.logging_options:get()
        local consoleOptions = interface.visuals.logging_options_console:get()
        
        local doConsole = utils.contains(logOptions, "console") and utils.contains(consoleOptions, "buy")
        if not doConsole then return end
        
        local player_idx = client.userid_to_entindex(e.userid)
        if not player_idx or not entity.is_enemy(player_idx) then return end
        
        local playerName = entity.get_player_name(player_idx) or "unknown"
        local weapon = e.weapon or "unknown item"
        
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
        local lines = 5
        return math.max(maxw, 80), lineh * lines
    end,
    draw = function(ctx)
        visuals:indicators(ctx.x + ctx.w / 2, ctx.y + 10)
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
    defaults = { anchor_x = "center", anchor_y = "center", offset_x = 0, offset_y = -80 },
    get_size = function(st)
        local lineh = 12
        local lines = 4
        local maxw = 0
        local samples = { _name .. " " .. _version, "target: none", "target state: none", "target yaw: none" }
        for i = 1, #samples do
            local w = select(1, renderer.measure_text("c", samples[i])) or 0
            if w > maxw then maxw = w end
        end
        return math.max(maxw, 120), lineh * lines + 12
    end,
    draw = function(ctx)
        local sw, _ = client.screen_size()
        local third = sw / 3
        local align, x
        if ctx.cx < third then
            align = "l"; x = ctx.x
        elseif ctx.cx > (sw - third) then
            align = "r"; x = ctx.x + ctx.w
        else
            align = "c"; x = ctx.x + ctx.w / 2
        end
        visuals:window(x, ctx.y + 6, align)
    end,
    z = 6
})

widgets.load_from_db()
client.set_event_callback("paint_ui", function() widgets.paint_ui() end)
client.set_event_callback("shutdown", function() widgets.save_all() end)


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
    if widgets and widgets.is_dragging then
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
            local secondary_item = buybot.secondary_console[interface.utility.buybot_secondary:get()]
            local selected_utilities = interface.utility.buybot_utility:get()
            
            if primary_item and primary_item ~= "" then
                client.exec("buy " .. primary_item .. ";")
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
                c = str:sub(pos, pos)
                if c == "n" then c = "\n"
                elseif c == "r" then c = "\r"
                elseif c == "t" then c = "\t"
                end
            end
            parts[#parts + 1] = c
            pos = pos + 1
        end
        return nil
    end
    
    local function decode_number()
        local start = pos
        while pos <= #str and string.find(str:sub(pos, pos), "[%d%.%-]") do
            pos = pos + 1
        end
        local num = tonumber(str:sub(start, pos - 1))
        if not num then pos = start end
        return num
    end
    
    local function decode_value()
        skip_whitespace()
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
                local key = decode_string() or decode_number()
                if not key then return nil end
                skip_whitespace()
                if str:sub(pos, pos) ~= ":" then return nil end
                pos = pos + 1
                local val = decode_value()
                if val == nil then return nil end
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
                if val == nil then return nil end
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
                return json.null
            end
        end
        return nil
    end
    
    local result = decode_value()
    skip_whitespace()
    if pos <= #str then return nil end
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
        else
            model_changer.models_ui.list:set_visible(false)
            model_changer.models_ui.delete_model_button:set_visible(false)
            model_changer.models_ui.model_enabled:set_visible(false)
            model_changer.models_ui.new_model_weapon:set_visible(false)
            model_changer.models_ui.new_model_button:set_visible(false)
            model_changer.models_ui.tip:set_visible(false)
            model_changer.models_ui.tip2:set_visible(false)
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
        else
            model_changer.models_ui.list:set_visible(false)
            model_changer.models_ui.delete_model_button:set_visible(false)
            model_changer.models_ui.model_enabled:set_visible(false)
            model_changer.models_ui.new_model_weapon:set_visible(false)
            model_changer.models_ui.new_model_button:set_visible(false)
            model_changer.models_ui.tip:set_visible(false)
            model_changer.models_ui.tip2:set_visible(false)
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

--@region: anti-aim
-- anti_aim = {} do
--     anti_aim.jitter_side = false
--     anti_aim.jitter_ticks = 0
--     anti_aim.last_time = 0
--     anti_aim.defensive_active = false
--     anti_aim.defensive_ticks = 0
--     anti_aim.last_tickcount = 0
--     anti_aim.force_next_update = false
--     anti_aim.body_yaw_delay = 0
--     anti_aim.last_body_update = 0
--     anti_aim.body_jitter_side = false

--     anti_aim.reset = function(self)
--         self.jitter_side = false
--         self.jitter_ticks = 0
--         self.last_time = 0
--         self.force_next_update = true
        
--         self.body_yaw_delay = 0
--         self.last_body_update = 0
--         self.body_jitter_side = false
        
--         self.defensive_active = false
--         self.defensive_ticks = 0
--         self.last_tickcount = 0
        
--         ui.set(reference.antiaim.angles.pitch[1], "Off")
--         ui.set(reference.antiaim.angles.pitch[2], 0)
--         ui.set(reference.antiaim.angles.yaw[1], "180")
--         ui.set(reference.antiaim.angles.yaw[2], 0)
--         ui.set(reference.antiaim.angles.yaw_jitter[1], "Off")
--         ui.set(reference.antiaim.angles.yaw_jitter[2], 0)
--         ui.set(reference.antiaim.angles.body_yaw[1], "Off")
--         ui.set(reference.antiaim.angles.body_yaw[2], 0)
--     end

--     anti_aim.get_jitter_side = function(self)
--         local tickcount = globals.tickcount()

--         if self.force_next_update or tickcount < self.last_tickcount then
--             self.jitter_side = not self.jitter_side
--             self.jitter_ticks = tickcount + 1
--             self.force_next_update = false
--         end

--         if tickcount > self.jitter_ticks then
--             self.jitter_side = not self.jitter_side
--             self.jitter_ticks = tickcount + 1
--         end

--         self.last_tickcount = tickcount
--         return self.jitter_side
--     end

--     anti_aim.handle_defensive = function(self, cmd, condition)
--         if not condition.hide_lc:get() then
--             return
--         end

--         local local_player = entity.get_local_player()
--         if not local_player or not entity.is_alive(local_player) then
--             return
--         end

--         local exploit_active = (ui.get(ui_references.double_tap[1]) and ui.get(ui_references.double_tap[2])) or 
--                              (ui.get(ui_references.on_shot_anti_aim[1]) and ui.get(ui_references.on_shot_anti_aim[2]))

--         if not exploit_active then
--             self.defensive_active = false
--             return
--         end

--         local inverter = (10 / 2 <= (globals.tickcount() % 10))
        
--         if exploit_active then
--             if not condition.hide_lc:get() then
--                 return
--             end
--             if globals.tickcount() % 20 >= 10 then
--                 cmd.force_defensive = true
                
--                 local pitch_mode = condition.pitch:get()
--                 local pitch_angle = condition.pitch_angle:get()
--                 if pitch_mode == "zero" then
--                     ui.set(reference.antiaim.angles.pitch[1], "Custom")
--                     ui.set(reference.antiaim.angles.pitch[2], inverter and 89 or 0)
--                 elseif pitch_mode == "up" then
--                     ui.set(reference.antiaim.angles.pitch[1], "Custom")
--                     ui.set(reference.antiaim.angles.pitch[2], inverter and 89 or -89)
--                 elseif pitch_mode == "medium" then
--                     ui.set(reference.antiaim.angles.pitch[1], "Custom")
--                     ui.set(reference.antiaim.angles.pitch[2], inverter and 89 or math.random(-89, -70))
--                 elseif pitch_mode == "random" then
--                     ui.set(reference.antiaim.angles.pitch[1], "Custom")
--                     ui.set(reference.antiaim.angles.pitch[2], math.random(-89, 89))
--                 elseif pitch_mode == "switch up" then
--                     ui.set(reference.antiaim.angles.pitch[1], "Up")
--                     ui.set(reference.antiaim.angles.pitch[2], inverter and -89 or 89)
--                 elseif pitch_mode == "switch down" then
--                     ui.set(reference.antiaim.angles.pitch[1], "Custom")
--                     ui.set(reference.antiaim.angles.pitch[2], inverter and 0 or -89)
--                 elseif pitch_mode == "custom" then
--                     ui.set(reference.antiaim.angles.pitch[1], "Custom")
--                     ui.set(reference.antiaim.angles.pitch[2], pitch_angle)
--                 end

--                 local type_mode = condition.type:get()
--                 if type_mode == "meta" then
--                     ui.set(reference.antiaim.angles.yaw[1], "180")
--                     ui.set(reference.antiaim.angles.yaw[2], 180)

--                     ui.set(reference.antiaim.angles.yaw_jitter[1], "Center")
--                     ui.set(reference.antiaim.angles.yaw_jitter[2], 45)
--                 elseif type_mode == "spin" then
--                     local spin_speed = condition.spin_speed:get()
                    
--                     if spin_speed > 0 then
--                         local angle = (globals.tickcount() * spin_speed) % 360

--                         if angle > 180 then
--                             angle = angle - 360
--                         end

--                         ui.set(reference.antiaim.angles.yaw[1], "180")
--                         ui.set(reference.antiaim.angles.yaw[2], angle)

--                         ui.set(reference.antiaim.angles.yaw_jitter[1], "Off")
--                         ui.set(reference.antiaim.angles.yaw_jitter[2], 0)
--                     else
--                         ui.set(reference.antiaim.angles.yaw[1], "180")
--                         ui.set(reference.antiaim.angles.yaw[2], 0)
--                         ui.set(reference.antiaim.angles.yaw_jitter[1], "Off")
--                         ui.set(reference.antiaim.angles.yaw_jitter[2], 0)
--                     end
--                 elseif type_mode == "free sway" then
--                     ui.set(reference.antiaim.angles.yaw[1], "180")
--                     ui.set(reference.antiaim.angles.yaw[2], 90)

--                     ui.set(reference.antiaim.angles.yaw_jitter[1], "Center")
--                     ui.set(reference.antiaim.angles.yaw_jitter[2], 45)
--                 elseif type_mode == "forward" then
--                     ui.set(reference.antiaim.angles.yaw[1], "180")
--                     ui.set(reference.antiaim.angles.yaw[2], 180)
--                 elseif type_mode == "switch left" then
--                     ui.set(reference.antiaim.angles.yaw[1], "180")
--                     ui.set(reference.antiaim.angles.yaw[2], -90)
--                 elseif type_mode == "switch right" then
--                     ui.set(reference.antiaim.angles.yaw[1], "180")
--                     ui.set(reference.antiaim.angles.yaw[2], 90)
--                 elseif type_mode == "custom" then
--                     local offset_left = condition.type_offset_left:get()
--                     local offset_right = condition.type_offset_right:get()

--                     ui.set(reference.antiaim.angles.yaw[1], "180")
--                     ui.set(reference.antiaim.angles.yaw[2], globals.tickcount() % 2 == 0 and offset_left or offset_right)
--                 end
--             end
--         end
--     end

--     anti_aim.setup = function(self, cmd)
--         if not entity.get_local_player() then 
--             self.force_next_update = true
--             return 
--         end

--         if not interface.builder.enabled_builder:get() then 
--             self.force_next_update = true
--             return 
--         end
        
--         local state = utils.get_state()
        
--         if not interface.builder.condition[state] then
--             state = "default"
--         end

--         local condition = interface.builder.condition[state]
--         local default = interface.builder.condition["default"]

--         if state ~= "default" and not condition.override:get() then
--             condition = default
--         end

--         ui.set(reference.antiaim.angles.enabled, true)
--         ui.set(reference.antiaim.angles.pitch[1], "Down")

--         local yaw_base = condition.yaw_base:get()
--         ui.set(reference.antiaim.angles.yaw_base, yaw_base == "at targets" and "At targets" or "Local view")

--         local delay_tick = condition.delay_tick:get()
--         local fake_option = condition.fake_options:get()

--         if fake_option == 'jitter' and delay_tick > 0 then
--             local interval = math.max(2, math.floor(1 + (delay_tick * 0.05)))
--             if globals.tickcount() % interval == 0 then
--                 self.jitter_side = not self.jitter_side
--             end
--             current_jitter = self.jitter_side

--             ui.set(reference.antiaim.angles.body_yaw[1], "Static")
--             local offset = condition.offset:get()
--             ui.set(reference.antiaim.angles.body_yaw[2], current_jitter and offset or -offset)
--         else
--             current_jitter = self:get_jitter_side()
--             if fake_option == "static" then
--                 local offset = condition.offset:get()
--                 ui.set(reference.antiaim.angles.body_yaw[2], offset)
--             end
--             ui.set(reference.antiaim.angles.body_yaw[1], fake_option)
--         end

--         ui.set(reference.antiaim.angles.yaw[1], "180")
--         local current_offset = current_jitter and condition.offset_left:get() or condition.offset_right:get()
--         ui.set(reference.antiaim.angles.yaw[2], current_offset)

--         local yaw_modifier = condition.yaw_modifier:get()
--         local left_limit = condition.left_limit:get()
--         local right_limit = condition.right_limit:get()

--         if yaw_modifier == "off" then
--             ui.set(reference.antiaim.angles.yaw_jitter[1], "Off")
--         elseif yaw_modifier == "center" then
--             ui.set(reference.antiaim.angles.yaw_jitter[1], "Center")
--             ui.set(reference.antiaim.angles.yaw_jitter[2], current_jitter and left_limit or right_limit)
--         elseif yaw_modifier == "offset" then
--             ui.set(reference.antiaim.angles.yaw_jitter[1], "Offset")
--             ui.set(reference.antiaim.angles.yaw_jitter[2], current_jitter and left_limit or right_limit)
--         elseif yaw_modifier == "random" then
--             ui.set(reference.antiaim.angles.yaw_jitter[1], "Random")
--             ui.set(reference.antiaim.angles.yaw_jitter[2], math.random(left_limit, right_limit))
--         elseif yaw_modifier == "skitter" then
--             ui.set(reference.antiaim.angles.yaw_jitter[1], "Skitter")
--             ui.set(reference.antiaim.angles.yaw_jitter[2], current_jitter and left_limit or right_limit)
--         elseif yaw_modifier == "spin" then
--             local target_angle = condition.spin_angle:get()
--             local current_tick = globals.tickcount()
--             local cycle = current_tick % 32
--             local base_offset = current_jitter and condition.offset_left:get() or condition.offset_right:get()
            
--             if cycle == 0 then
--                 ui.set(reference.antiaim.angles.yaw[2], base_offset)
--             else
--                 local progress = cycle / 31
--                 local current_angle = target_angle * progress
--                 ui.set(reference.antiaim.angles.yaw[2], base_offset + current_angle)
--             end

--             ui.set(reference.antiaim.angles.yaw_jitter[1], "Off")
--             ui.set(reference.antiaim.angles.yaw_jitter[2], 0)
--         elseif yaw_modifier == "3-way" then
--             local base_offset = current_jitter and condition.offset_left:get() or condition.offset_right:get()
--             local modifier_offset = current_jitter and condition.yaw_modifier_offset:get() or 0
--             local step = modifier_offset / 2
--             local ways = {base_offset, base_offset + step, base_offset + modifier_offset}
--             local index = (globals.tickcount() % 3) + 1
--             ui.set(reference.antiaim.angles.yaw[2], ways[index])
--         elseif yaw_modifier == "5-way" then
--             local base_offset = current_jitter and condition.offset_left:get() or condition.offset_right:get()
--             local modifier_offset = current_jitter and condition.yaw_modifier_offset:get() or 0
--             local step = modifier_offset / 4
--             local ways = {base_offset, base_offset + step, base_offset + step * 2, base_offset + step * 3, base_offset + modifier_offset}
--             local index = (globals.tickcount() % 5) + 1
--             ui.set(reference.antiaim.angles.yaw[2], ways[index])
--         end

--         ui.set(reference.antiaim.angles.freestanding_body_yaw, false)

--         self:handle_defensive(cmd, condition)
--     end

--     client.set_event_callback('setup_command', function(cmd)
--         anti_aim:setup(cmd)
--     end)

--     client.set_event_callback('game_newmap', function()
--         anti_aim:reset()
--     end)

--     client.set_event_callback('cs_game_disconnected', function()
--         anti_aim:reset()
--     end)
-- end
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
        "     ✧",
        "    ✦",
        "   ✦✧",
        "  ✦✧✧",
        " ✦✧✧✧",
        "✦✧✧✧✧",
        "n✦✧✧✧",
        "no✦✧✧",
        "noc✦✧",
        "noct✦",
        "noctu✦",
        "noctua✦",
        "noctua✧",
        "noctua✨",
        "noctua",
        "noctua",
        "noctua",
        "noctua",
        "noctua✦",
        "noctu✦a",
        "noct✦ua",
        "noc✦tua",
        "no✦ctua",
        "n✦octua",
        "✦noctua",
        "✧noctua",
        "✨noctua",
        "✦ octua",
        "✧  ctua",
        "✦   tua",
        "✧    ua",
        "✦     a",
        "✧      ",
        "✦     ",
        "✧    ",
        "✦   ",
        "✧  ",
        "✦ ",
        "✧"
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
    
    killsay.multi_phrases_kill = {
        {
            "1"
        },
        {
            "1\\"
        },
        {
            "1w"
        },
        {
            "11"
        },
        {
            "1'"
        },
        {
            "12"
        },
        {
            "1",
            "хуесос", 
            "заебал мя уже"
        },
        {
            "АХАХАХАХ ТЫ ЭТО ВИДЕЛ?",
            "БАЙ НОКТА"
        },
        {
            "ебать у меня ща заделеило",
            "пиздец"
        },
        {
            "бай дер босс фарлиг получаеца"
        },
        {
            "ты наигрался?",
            "иди траву потрогай"
        },
        {
            "1\\",
            "хохол",
            "блядский"
        },
        {
            "1",
            "идиот"
        },
        {
            "ебанный астетик юзер",
            "спи шлюха"
        },
        {
            "ебать ты поскользнулся"
        },
        {
            "спи шлюха"
        },
        {
            "быстрее хуесос",
            "у меня елка через 30 минут"
        },
        {
            "1 долбаеб",
            "заебал"
        },
        {
            "учи мапу ньюкам"
        },
        {
            "нокта загружена",
            "#pizdavam"
        },
        {
            "1",
            "не игрок"
        },
        {
            "1",
            "бек то киев"
        },      
        {
            "ебать",
            "справа пожалуйста"
        },
        {
            "ебать чит бодрый"
        },
        {
            "ЪЪЪЪ)))) ооппоповап ЪЪЪ БББЮ"
        },
        {
            "noctua owns me and all (◣_◢)"
        },
        {
            "Тронуло до самой души! Читать всем! Звонок в час ночи: -Алло."
        },
        {
            "ликвидирован"
        },
        {
            "ＦＵＣＫ ＹＯＵ ＡＮＤ ＹＯＵＲ ＦＡＭＩＬＹ $$$"
        },
        {
            "нокта сегодня бодрая"
        },
        {
            "𝘍𝘙𝘌𝘌 𝘎𝘈𝘔𝘌 𝘈𝘎𝘈𝘐𝘕"
        },
        {
            "ｓｐｏｎｓｏｒ ｏｆ ｙｏｕｒ ｄｅａｔｈ >>> ｎｏｃｔｕａ $$$"
        },
        {
            "▄︻デ₲Ꝋ ꞨŁɆɆꝐ ⱲɆȺҞ ĐꝊ₲ ══━一"
        },
        {
            "☆꧁✬◦°˚°◦. ɮʏ ɮɛֆȶ ʟʊǟ .◦°˚°◦✬꧂☆"
        },
        {
            "Ｉ`Ｍ ＧＯＤ ＷＩＴＨ ＧＯＤＭＯＤＥ ＡＡ"
        },
        {
            "ＧＯＤ ＢＬＥＳＳ ＲＵＳＳＩＡ"
        },
        {
            "ＡＬＬ ＤＯＧＳ ＷＡＮＮＡ ＢＥ ＬＩＫＥ ＭＥ"
        },
        {
            "если ты хочешь сходить 5х5 то пиши --> Axsiimov#7777"
        },
        {
            "Я играю на лайфхакерском конфиге от Витмы (◣_◢)"
        },
        {
            "пидорасы.xyz/refund.php - тебе это нужнее"
        },
        {
            "лол как же я тебя выебал #noctua"
        },
        {
            "ХАХАХАХАХХАХА НИЩИЙ УЛЕТЕЛ (◣_◢)"
        },
        {
            "спи шлюха пусть тебе будет снится noctua"
        },
        {
            "𝐧𝐨 𝐞𝐬𝐜𝐚𝐩𝐞, 𝐧𝐨 𝐡𝐨𝐩𝐞, 𝐣𝐮𝐬𝐭 𝐧𝐨𝐜𝐭𝐮𝐚"
        },
        {
            "как всегда 𝙣𝙤𝙘𝙩𝙪𝙖 прокерила"
        },
        {
            "ААААААА НАПАДАЙТЕ НА МЕНЯ МЕНЯ ТАК ПРОСТО НЕ ВЗЯТЬ С #noctua"
        },
        {
            "ТЕБЯ ОТПУСТЯТ ПО УДО ЕСЛИ ТЫ ВЫПОЛНИШЬ МОИ УСЛОВИЯ ЗДЕСЬ - noctua.sbs/discord"
        },
        {
            "кстати у меня #noctua работает через dma карту так что при проверке читов у меня не найдут ничего"
        },
        {
            "𝙣𝙤𝙘𝙩𝙪𝙖 𝙥𝙧𝙚𝙙𝙞𝙘𝙩𝙞𝙤𝙣 𝙩𝙚𝙘𝙝𝙣𝙤𝙡𝙤𝙜𝙞𝙚𝙨 (◣_◢)"
        },
        {
            "G o d M o d e A c t i v a t e d, your career D e a c t i v a t e d #noctua"
        },
        {
            "прикупил ненужную луашку за деньги? Молодец, ебу тебя с #noctua"
        },
        {
            "почему же я убил тебя? Всё просто, 𝐧𝐨𝐜𝐭𝐮𝐚 творит чудеса"
        },
        {
            "𝕘𝕠𝕕 𝕘𝕒𝕧𝕖 𝕞𝕖 𝕡𝕠𝕨𝕖𝕣 𝕠𝕗 𝕣𝕖𝕫𝕠𝕝𝕧𝕖𝕣 𝕟𝕠𝕔𝕥𝕦𝕒"
        },
        {
            "𝕟𝕠 𝕤𝕜𝕚𝕝𝕝 𝕛𝕦𝕤𝕥 𝕟𝕠𝕔𝕥𝕦𝕒"
        },
        {
            "𝕚 𝕒𝕞 𝕕𝕠𝕟𝕥 𝕝𝕠𝕤𝕖 (◣_◢) "
        },
        {
            "я непобидимый, моя сила в - noctua.lua "
        },
        {
            "умер - не игрок"
        },
        {
            "я люблю белый зефир а еще люблю - noctua..."
        },
        {
            "сек чет в зубах застряло... а это зефир с ноктой"
        },
        {
            "Я апнул 6lvl анмачеда благодоря noctua(◣_◢)"
        },
        {
            "Тебе не устоять перед моими антиаимами #noctua"
        },
        {
            "LIFEEEEHAAAACK BITCH!!! (◣_◢)"
        },
        {
            "круто вчера туалет помыла шлюха"
        },
        {
            "гвоздь мне в кеды вот это хедшот"
        },
        {
            "noctua over all pidoras"
        },
        {
            "куда ты сынок ебаный"
        },
        {
            "ez owned weak dog + rat"
        },
        {
            "адольф гитлер 19 срать дрочить говно сиськи мясо карандаш комбайн 78"
        },
        {
            "как же мне похуй ботик"
        },
        {
            "опять умер моча"
        },
        {
            "подруга опять умерла"
        },
        {
            "𝗻𝗼𝗰𝘁𝘂𝗮 𝗴𝗮𝘃𝗲 𝗺𝗲 𝗮 𝗰𝗵𝗮𝗻𝗰𝗲 𝘁𝗼 𝗱𝗲𝗽𝗼𝗿𝘁 𝘁𝗵𝗼𝘀𝗲 𝗮𝗻𝗴𝗲𝗹𝘀 𝗯𝗮𝗰𝗸 𝘁𝗼 𝗵𝗲𝗹𝗹"
        },
        {
            "racen handed me noctua beta and i killed all faggots *emberlash,angelwings,xo-yaw* were sent to hell"
        },
        {
            "трепещите антиаимы - я изобрел резольвер #noctua"
        },
        {
            "КТО СУКА ЗА ТОБОЙ ЗУБЫ БУДЕТ ПОДБИРАТЬ?"
        },
        {
            "у тебя ник не тверкать ярослав?? я тебя вчера на ловсинк арене видел"
        },
        {
            "!medic НЮХАЙ БЭБРУ я полечился"
        },
        {
            "免费破解 noctua 最强配置 免费下载 racen$$ 无病毒 2025 免费工作 LUA SCRIPT 如果你读到这个"
        },
        {
            "ебать скит юзер поскользнулся"
        },
        {
            "Loading noctua.lua [][][] 77% #pizdavam"
        },
        {
            "мир, это как фантик... ХАХАХА ЗАБУДЬТЕ БЛЯТЬ ЧЕЕ КАКОЙ ФАНТИК :D"
        },
        {
            "бля карта пота +в не походишь"
        },
        {
            "Самый ТУПОЙ САМОГОН ЮЗЕР - ШКОЛЬНИК ПОТЕРЯЛ ВСЕ БАБКИ / Расследование"
        },
        {
            "fuck aesthetic, my homies use 𝙣𝙤𝙘𝙩𝙪𝙖✟"
        },
        {
            "NOCTUA? ДАВАЙ ПОЖМУ ЛАПУ"
        },
        {
            "нокту мне и моему сыну тоже"
        },
        {
            "noctua leveling season 2"
        },
        {
            "залетаю в челябу челкастый оооо добро пожаловать"
        },
        {
            "купил aesthetic - ошибка новичка",
            "купил emberlash - ебать ты долбаеб"
        },
        {
            "𝕕𝕠𝕟'𝕥 𝕓𝕝𝕒𝕞𝕖 𝕞𝕖, 𝕓𝕝𝕒𝕞𝕖 𝕟𝕠𝕔𝕥𝕦𝕒"
        },
        {
            "𝙩𝙝𝙞𝙨 𝙞𝙨 𝙩𝙝𝙚 𝙥𝙤𝙬𝙚𝙧 𝙤𝙛 𝙣𝙤𝙘𝙩𝙪𝙖 (◣_◢)"
        },
        {
            "твоя смерть была предрешена когда я запустил noctua"
        },
        {
            "вот это я понимаю - сидишь на хуе, а я на noctua"
        },
        {
            "НОКТА РЕШАЕТ, НОКТА ПОБЕЖДАЕТ"
        },
        {
            "ты только что познакомился с #noctua"
        },
        {
            "взлом самой мощной версии noctua.lua"
        },
        {
            "лови арбуз"
        },
        {
            "сорян мужик"
        },
        {
            "нокта чек оформлен"
        },
        {
            "да ну нахуй",
            "лил пип за окном выступает"
        },
        {
            "все девочки хотят эту #noctua"
        },
        {
            "разъебу вас в шахматы писать сюда @mirai_network"
        },
        {
            "наратан найтли не проблема для #noctua"
        },
        {
            "где лучшие тусовки? у нас в #noctua"
        },
        {
            "1",
            "?",
            "ты че такой тупой ребенок бляди"
        },
        {
            "скачать нокту можно здесь:",
            "а хуй тебе"
        },
        {
            "заюш ты выебан бай нокта"
        },
        {
            "пацаны а нокта сейчас крашит? просто боюсь загружать"
        },
        {
            "прикупи курсы хвх у Axsiimov#7777"
        },
        {
            "когда я был в прайме, меня все называли i.diman"
        },
        {
            "всенокты.нет"
        },
        {
            "нокта любит таких же решительных, как я"
        },
        {
            "и это анти-аимы? для #noctua это мелочь"
        },
        {
            "станед хуянед резольвер? гет нокта - зетс олл"
        },
        {
            "я твоей маме колени выбил битой хуесос"
        },
        {
            "ОЙ"
        }
    }

    killsay.multi_phrases_death = {
        {
            "анлак"
        },
        {
            "ШЬТО",
            "КАК ТЫ УБИЛ"
        },
        {
            "CERF",
            "сука"
        },
        {
            "нокта сегодня не бодрая"
        },
        {
            "блять",
            "ебаный попрыгунчик убил"
        },
        {
            "тьывотльбФЫВотльбФЫЯВЧ",
            "не везет пиздец",
            "когда нибудь я тебя убью хуесос"
        },
        {
            "?",
            "че"
        },
        {
            "!admin",
            "ливай шлюха у тя 5 сек"
        },
        {
            "свинокта опять мисснула пиздец"
        },
        {
            "ХАХАХА",
            "да ебаный",
            "дегенерат",
            "я реально мать тебе выебу",
            "сын шалаыв",
            "никчемной"
        },
        {
            "ну опять не выбил",
            "сын бабки ебаной"
        },
        {
            "я щас админку байну и забаню тебя хуесос",
            "ходи оглядывайся"
        },
        {
            "опять какой то долбаеб убил",
            "статс в чат прописал нахуй"
        },
        {
            "сыно шлюхи",
            "я мать те резал"
        },
        {
            "КАК ЖЕ ТЫ МЕНЯ ЗАЕБАЛ УЖЕ",
            "ТЛЬДБфыячОТЛЬДБфыяч"
        },
        {
            ",KZNM RFR",
            "БЛЯТЬ КАК ЖЕ ТЫ ЗАЕБАЛ"
        },
        {
            "lf ,kznm",
            "да блять",
            "опять мисснул"
        },
        {
            "ПАРНИ не подскажете че такое трешток"
        },
        {
            "опять анрег",
            "что за пиздец"
        }
    }
    
    killsay.get_random_phrase = function(phrase_type)
        local current_time = globals.realtime()
        math.randomseed(current_time * 1000)
        
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
        
        local now = globals.realtime()
        if now - killsay.last_say_time < killsay.cooldown then
            return
        end
        
        local attacker = client.userid_to_entindex(e.attacker)
        local victim = client.userid_to_entindex(e.userid)
        local local_player = entity.get_local_player()
        local modes = interface.utility.killsay_modes:get()
        
        if attacker == local_player and victim ~= local_player then
            if utils.contains(modes, "on kill") then
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
end
--@endregion

logging:push("checkout latest update in console")
logging:push("nice to see you at " .. _name .. " " .. _version .. " (" .. _nickname .. ")")