require "util"
--local Mappings = require("qis/mappings")
local Lib = require("qis/lib")
local Mapper = require("qis/mapper")


patches = {
    require("mappings/base"),
    require("mappings/creative-mode"),
    require("mappings/LogisticTrainNetwork"),
    require("mappings/nixie-tubes"),
    require("mappings/SmartTrains"),
    require("mappings/VehicleWagon"),
    require("mappings/BatteriesNotIncluded"),
    require("mappings/ElectricVehicles3"),
    require("mappings/FARL"),
    require("mappings/TrainSupplyManager"),
    -- require("mappings/bobinserters"),
    -- require("mappings/boblogistics")
}

mappings = {}


CUSTOM_EVENTS = {
    on_qis_mappings_reset = script.generate_event_name(),  -- Fired when something causes us to reset all mappings.
    on_qis_mappings_patched = script.generate_event_name(),  -- Fired when something applies a patch (e.g. via remote.call)
}


local function initialize_globals()
    if not global.playerdata then
        global.playerdata = {}
    end

    setmetatable(global.playerdata, {
        __index = function(t, k)
            local v = {
                item_history = {},
                group_history = {},
                type_history = {},
                blacklist = {},
            }
            t[k] = v
            return v
        end
    })
end


local function rebuild_mappings(why)
    initialize_globals()

    -- Reconstructs mappings on new map/update/config change.
    mappings = nil
    for _, patch in pairs(patches) do
        if not mappings then
            mappings = Mapper:adopt(patch())
        else
            mappings:merge(patch())
        end
    end
    global.mappings = mappings
    script.raise_event(CUSTOM_EVENTS.on_qis_mappings_reset, { why = why })
end



local function add_commands()
    commands.add_command(
            "qis-clear-blacklist",
            "Resets your QuickItemSwap blacklist and whitelist to their defaults.", function()
                global.playerdata[game.player.index].blacklist = {}
                game.player.print({"qis-message.blacklist-cleared", game.player.name})
            end
    )
end


local function on_load()
    mappings = global.mappings
    initialize_globals()
    add_commands()
    if mappings then
        Mapper:adopt(mappings)
    end
end


-- Lazily create a list of what all techs produce a given item.
item_techs = Lib.lazy_table(function(items_craftable)
    local name, t
    for recipe, data in pairs(game.recipe_prototypes) do
        if data.products then
            for _, product in pairs(data.products) do
                if product.type == 'item' then
                    name = product.name
                    t = items_craftable[name]
                    if not t then
                        items_craftable[name] = { recipe }
                    else
                        t[#t + 1] = recipe
                    end
                end
            end
        end
    end
end)


script.on_init(function()
    rebuild_mappings("init")
    add_commands()
end)
script.on_load(on_load)
script.on_configuration_changed(function(_)
    if global.debug then
        game.print("[QuickItemSwap] Detected a configuration change.  Rebuilding item mappings.")
    end
    rebuild_mappings("configuration-changed")
end
)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if global.debug then
        game.print("[QuickItemSwap] Detected a mod settings change by " .. game.players[event.player_index].name .. ".  (Type: " .. event.setting_type .. ") Rebuilding item mappings.")
    end
    rebuild_mappings("settings-changed")
end)


-- Cycle between blueprints/books/etc
local function cycle_bp(player, change_group, reverse)
    local pdata = global.playerdata[player.index]
    local cursor = player.cursor_stack

    if cursor.item_number == nil then
        return
    end
    local number = cursor.item_number
    local inv = player.get_main_inventory()
    local stack

    local function foreachitem(fn)
        for i=1,#inv do
            if fn(inv[i], i, inv) then
                return true
            end
        end
        return false
    end

    if change_group then
        local types = {"blueprint", "blueprint-book", "deconstruction-item" }
        local type_index
        for ix,type in pairs(types) do
            if cursor.type == type then
                type_index = ix
                break
            end
        end
        if not type_index then
            return
        end
        pdata.type_history = pdata.type_history or {}
        pdata.type_history[cursor.type] = number
        for index, type in Lib.wraparound(types, type_index, reverse) do
            local hist = pdata.type_history[type]
            foreachitem(function(item)
                if item.valid_for_read and item.type == type then
                    if item.item_number == hist or not hist then
                        stack = item
                        return true
                    elseif not stack then
                        stack = item
                    end

                end
            end)
            if stack then
                player.clean_cursor()  -- May fail if inv is full, that's okay for now.
                player.cursor_stack.swap_stack(stack)
                return
            end
        end
        return
    end  -- if change_group

    -- If still here, cycling between items within the group
    local found
    foreachitem(function(item)
        if not (item.valid_for_read and item.type == cursor.type and item.item_number) then
            return
        end
        n = item.item_number
        if not found then
            found, stack = n, item
            if global.debug then
                player.print("cycle_bp: [init] number=" .. number .. ", n=" .. n .. ", found=" .. found)
            end
        elseif reverse then
            if global.debug then player.print("cycle_bp: [step] number=" .. number .. ", n=" .. n .. ", found=" .. found) end
            if (found > number and (n > found or n < number)) or (n < number and n > found) then
                found = n
                stack = item
                if global.debug then player.print("cycle_bp: result=" .. found) end
            end
        else
            if global.debug then player.print("cycle_bp: [step] number=" .. number .. ", n=" .. n .. ", found=" .. found) end
            if (found < number and (n < found or n > number)) or (n > number and n < found) then
                found = n
                stack = item
                if global.debug then player.print("cycle_bp: result=" .. found) end
            end
        end
    end)

    if not stack then
        return
    end

    player.clean_cursor()  -- May fail if inv is full, that's okay for now.
    cursor.swap_stack(stack)
end


-- Determine if an item is blacklisted.
local function is_blacklisted(player, item, requires_tech)
    if requires_tech == nil then
        requires_tech = player.mod_settings['QuickItemSwap-requires-tech'].value
    end
    local blacklist = global.playerdata[player.index].blacklist
    if blacklist[item] then
        return true
    elseif blacklist[item] == false or not requires_tech then
        return false
    end

    if not item_techs[item] then
        if global.debug then
            game.print("No item techs for " .. item)
        end
        return true
    end

    local recipes = player.force.recipes
    for _, recipe in pairs(item_techs[item]) do
        if recipes[recipe].enabled then
            return false
        end
    end
    return true
end



-- Some constants for find_or_cheat_item
local FindResult = {
    NOT_FOUND = false,
    FOUND = 1,
    CHEAT = 2,
    GHOST = 3
}


-- Cycle between related items.
local function cycle_item(event, change_group, reverse)
    local player = game.players[event.player_index]
    local pdata = global.playerdata[player.index]
    local cursor = player.cursor_stack
    local blacklist = pdata.blacklist

    local source  -- Found mapping for source name.

    if global.debug then
        player.print("In cycle item.  change_group=" .. serpent.block(change_group) .. "; reverse=" .. serpent.block(reverse))
    end

    -- Do nothing if no item is currently selected.
    if not cursor.valid_for_read then
        if player.cursor_ghost then
            source = player.cursor_ghost.name
        else
            if global.debug then player.print("No item selected") end
            return
        end
    else
        source = cursor.name
    end

    -- Find item in the catalog.
    local history = pdata.item_history[source] or {}
    source = mappings:find(source, history.category, history.group)

    -- If not found, pretend it's a blueprint and see what happens.
    if not source then
        if global.debug then player.print("Item " .. cursor.name .. " is not in catalog.") end
        return cycle_bp(player, change_group, reverse)
    end

    -- Still here?  Time to get to work.
    if global.debug then
        player.print(
                "Item '" .. source.name .. "' is " .. source.index .. " of " .. #source.group.sorted
                        .. " in group " .. source.group.name
        )
        player.print(source.type and ("Item equivalence type: " .. source.type) or "Item has no equivalence type")
        player.print(
                "Group '" .. source.group.name .. "' is " .. source.group.index .. " of " .. #source.group.category.sorted
                        .. " in category " .. source.group.category.name
        )
    end

    -- Look for suitable replacements
    local inv = player.get_main_inventory()
    local stack  -- Item stack for replacement
    local target  -- Mapping for replacement.
    local result = FindResult.NOT_FOUND

    -- Are we allowed to cheat new items in?
    local can_cheat = (
            player.cheat_mode
            and player.mod_settings["QuickItemSwap-support-cheat-mode"].value
    )

    -- Can we create item ghosts?
    local can_ghost = player.mod_settings["QuickItemSwap-use-ghosts"].value

    local function find_or_cheat_item(entry)
        -- Search for the item in the inventory
        stack = inv.find_item_stack(entry.name)
        if stack then
            -- Well, that was easy.
            target = entry
            return FindResult.FOUND
        end

        -- If we didn't find the item and we can't ghost or cheat, bail here.
        if not (can_cheat or can_ghost) then
            return FindResult.NOT_FOUND
        end


        if not game.item_prototypes[entry.name] then
            -- No prototype exists, so bail
            return FindResult.NOT_FOUND
        end

        if (
                can_cheat and not is_blacklisted(player, entry.name, false)
                    and (
                    not game.active_mods["creative-mode"]
                            or not string.find(entry.name, "^creative%-mode%_")
                            or settings.get_player_settings(player)["QuickItemSwap-support-cheat-mode-with-creative"].value
                ))
        then
            target = entry
            return FindResult.CHEAT
        end

        if can_ghost and not is_blacklisted(player, entry.name) then
            target = entry
            return FindResult.GHOST
        end
    end


    if change_group then
        local type = source.type
        local candidate
        for index, group in Lib.wraparound(source.category.sorted, source.group.index, reverse) do
            if global.debug then
                player.print("Next group: #" .. index .. " = " .. group.name)
            end

            if type and group.typed[type] then
                -- Typed item, and group has this type.
                candidate = group.typed[type]
                if global.debug then
                    player.print("Candidate typed item: #" .. index .. " = " .. candidate.name)
                end

                result = find_or_cheat_item(candidate)
                if result then break end
            else
                -- Untyped item, or group does not have this type.
                if pdata.group_history[group.id] then
                    candidate = pdata.group_history[group.id]
                    if global.debug then
                        player.print("Candidate item from history: #" .. index .. " = " .. candidate.name)
                    end
                    result = find_or_cheat_item(candidate)
                    if result then break end
                end

                -- No candidate item, or candidate item doesn't exist.
                -- Try to find something else in the group that we do have.
                for index, candidate in Lib.wraparound(group.sorted, candidate and candidate.index, reverse) do
                    if global.debug then
                        player.print("Next candidate: #" .. index .. " = " .. candidate.name)
                    end
                    result = find_or_cheat_item(candidate)
                    if result then break end
                end
            end -- of typed if/else
        end -- of group loop
    else
        for index, candidate in Lib.wraparound(source.group.sorted, source.index, reverse) do
            if global.debug then
                player.print("Next candidate: #" .. index .. " = " .. candidate.name)
            end
            result = find_or_cheat_item(candidate)
            if result then break end
        end
    end

    if not result then return end

    -- Save the last thing we used in this group.
    pdata.group_history[source.group.id] = source

    -- Found an actual real item.

    -- Check the various possible results and attempt to update things.  If the update fails, return so that history
    -- does not update.
    if result == FindResult.FOUND then
        player.clean_cursor()  -- May fail if inv is full, that's okay for now because we'll just swap it if that's the case
        if not player.cursor_stack.swap_stack(stack) then
            -- This SHOULDN'T fail, but might with a full and filtered inventory.
            return
        end
    elseif result == FindResult.CHEAT then
        if not player.clean_cursor() then
            -- If this happens, there's no way to conjure an item out of thin air without destroying something.
            -- So don't.
            return
        end
        cursor.set_stack(target.name)  -- Will automatically pick a full stack.
    elseif result == FindResult.GHOST then
        if not player.clean_cursor() then
            -- If this happens, there's no way to conjure an item out of thin air without destroying something.
            -- So don't.
            return
        end
        player.cursor_ghost = target.name
    end

    pdata.group_history[target.group.id] = target
    pdata.item_history[target.name] = target
end


-- Core functionality
script.on_event("qis-item-next", function(event) return cycle_item(event, false, false) end)
script.on_event("qis-item-prev", function(event) return cycle_item(event, false, true) end)
script.on_event("qis-group-next", function(event) return cycle_item(event, true, false) end)
script.on_event("qis-group-prev", function(event) return cycle_item(event, true, true) end)


-- Housekeeping
script.on_event(defines.events.on_player_removed, function(event)
    if global.playerdata then
        global.playerdata[event.player_index] = nil
    end
end)


-- Blacklist support.
script.on_event("qis-toggle-blacklist", function(event)
    local player = game.players[event.player_index]
    local pdata = global.playerdata[player.index]
    local blacklist = pdata.blacklist

    local proto

    if player.cursor_stack.valid_for_read then
        proto = player.cursor_stack.prototype
    elseif player.cursor_ghost then
        proto = player.cursor_ghost
    else
        return
    end

    local name = proto.name

    if blacklist[name] == nil then
        blacklist[name] = true
        player.print({"qis-message.item-blacklisted", proto.localised_name})
    elseif blacklist[name] == true then
        blacklist[name] = false
        player.print({"qis-message.item-whitelisted", proto.localised_name})
    else
        blacklist[name] = nil
        player.print({"qis-message.item-defaulted", proto.localised_name})
    end
end)



-- API
api = {}

function api.dump_inventory(inv)
    local item
    for i=1,#inv do
        item = inv[i]
        if item.valid_for_read then
            game.print(i .. ": " .. item.name .. " x" .. item.count)
--        else
--            game.print(i .. ": --EMPTY--")
        end
    end
end

function api.dump_quickbar(player)
    player = player or game.players[1]
    local quickbar = player.get_quickbar()
    if not quickbar.valid then
        return false
    end
    api.dump_inventory(quickbar)
end

function api.debug(new)
    if new ~= nil then
        global.debug = new
    end
    return global.debug
end

--function api.eval(code)
--    return loadstring(code)()
--end

function api.get_events()
    return CUSTOM_EVENTS
end

function api.get_mappings(category, group, item)
    return mappings:export(category, group, item)
end

function api.reset_mappings()
    rebuild_mappings('remote')
end

function api.apply_patch(patchinfo, source)
    local msg
    if source then
        msg = { "While applying a patch from '" .. source .. "':" }
    else
        msg = { "While applying a patch from an unknown source:" }
    end

    local function fail(message)
        return error(table.concat(msg, "\n") .. "\n\n" .. message .. "\n\nThis is an error in the other mod, not in QuickItemSwap.\n\n" .. serpent.block(patchinfo))
    end

    -- Validate patch.
    if not patchinfo.categories then
        return fail("No `categories` attribute present.")
    end

    for name, category in pairs(patchinfo.categories) do
        if category then
            msg[2] = "In category `" .. name .. "`:"
            msg[3] = nil
            if not category.groups then
                return fail("No `groups` attribute present.")
            end
            for name, group in pairs(category.groups) do
                if group then
                    msg[3] = "In group `" .. name .. "`:"
                    if not group.items then
                        return fail("No `items` attribute present.")
                    end
                end
            end
        end
    end

    mappings:merge(patchinfo)
    script.raise_event(CUSTOM_EVENTS.on_qis_mappings_patched, { patch = patchinfo, source = source  })
end

function api.refresh(only_if_dirty)
    mappings:refresh(only_if_dirty)
end

function api.validate_mappings(player)
    mappings:validate((player and player.print) or game.print)
end

function api.dump_mappings(category, group, item)
    game.write_file(
        "quickitemswap-mappings.txt",
        serpent.block(
            mappings:export(category, group, item)
        )
    )
end

remote.add_interface("QuickItemSwap", api)
