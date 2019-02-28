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
    -- require("mappings/bobinserters"),
    -- require("mappings/boblogistics")
}

mappings = {}


CUSTOM_EVENTS = {
    on_qis_mappings_reset = script.generate_event_name(),  -- Fired when something causes us to reset all mappings.
    on_qis_mappings_patched = script.generate_event_name(),  -- Fired when something applies a patch (e.g. via remote.call)
}


local function setup_playerdata()
    if not global.playerdata then
        global.playerdata = {}
    end

    setmetatable(global.playerdata, {
        __index = function(t, k)
            local v = {
                item_history = {},
                group_history = {},
                type_history = {},
            }
            t[k] = v
            return v
        end
    })
end


local function rebuild_mappings(why)
    setup_playerdata()

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


local function on_load()
    mappings = global.mappings
    setup_playerdata()
    if mappings then
        Mapper:adopt(mappings)
    end
end


script.on_init(function() rebuild_mappings("init") end)
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
local function cycle_bp(player, pdata, cursor, change_group, reverse)
    if cursor.item_number == nil then
        return
    end
    local number = cursor.item_number
    local qb = player.get_quickbar()
    local inv = player.get_inventory(defines.inventory.player_main)
    local stack

    local function foreachitem(fn)
        for _,where in pairs({qb, inv}) do
            for i=1,#where do
                if fn(where[i], i, where) then
                    return true
                end
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
    local found, stack
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
    player.cursor_stack.swap_stack(stack)
end



-- Cycle between related items.
local function cycle_item(event, change_group, reverse)
    local player = game.players[event.player_index]
    local pdata = global.playerdata[player.index]
    local cursor = player.cursor_stack

    if global.debug then
        player.print("In cycle item.  change_group=" .. serpent.block(change_group) .. "; reverse=" .. serpent.block(reverse))
    end

    -- Do nothing if no item is currently selected.
    if not cursor.valid_for_read then
        if global.debug then player.print("No item selected") end
        return
    end

    local name = cursor.name
    local history = pdata.item_history[name] or {}
    -- Do nothing if the selected item is not in the catalog.
    local item = mappings:find(cursor.name, history.category, history.group)
    if not item then
        if global.debug then player.print("Item " .. cursor.name .. " is not in catalog.") end
        return cycle_bp(player, pdata, cursor, change_group, reverse)
    end

    if global.debug then
        player.print(
            "Item '" .. item.name .. "' is " .. item.index .. " of " .. #item.group.sorted
            .. " in group " .. item.group.name
        )
        player.print(item.type and ("Item equivalence type: " .. item.type) or "Item has no equivalence type")
        player.print(
            "Group '" .. item.group.name .. "' is " .. item.group.index .. " of " .. #item.group.category.sorted
            .. " in category " .. item.group.category.name
        )
    end

    local stack, newitem
    local inv = player.get_main_inventory()

    local can_cheat = (
        player.cheat_mode
        and settings.get_player_settings(player)["QuickItemSwap-support-cheat-mode"].value
    )
    local will_cheat = false

    local function find_or_cheat_item(candidate)
        stack = inv.find_item_stack(candidate.name)
        if stack then
            newitem = candidate
            return true
        end

        if can_cheat and game.item_prototypes[candidate.name] and (
            not game.active_mods["creative-mode"]
            or not string.find(candidate.name, "^creative%-mode%_")
            or settings.get_player_settings(player)["QuickItemSwap-support-cheat-mode-with-creative"].value
        ) then
            will_cheat = true
            newitem = candidate
            return true
        end
        return false
    end

    if change_group then
        local candidate
        local type = item.type
        for index, group in Lib.wraparound(item.category.sorted, item.group.index, reverse) do
            if global.debug then
                player.print("Next group: #" .. index .. " = " .. group.name)
            end

            if type and group.typed[type] then
                -- Typed item, and group has this type.
                candidate = group.typed[type]
                if global.debug then
                    player.print("Candidate typed item: #" .. index .. " = " .. candidate.name)
                end
                if find_or_cheat_item(candidate) then break end
            else
                -- Untyped item, or group does not have this type.
                if pdata.group_history[group.id] then
                    candidate = pdata.group_history[group.id]
                    if global.debug then
                        player.print("Candidate item from history: #" .. index .. " = " .. candidate.name)
                    end
                    if find_or_cheat_item(candidate) then break end
                end

                -- No candidate item, or candidate item doesn't exist.
                -- Try to find something else in the group that we do have.
                for index, candidate in Lib.wraparound(group.sorted, candidate and candidate.index, reverse) do
                    if global.debug then
                        player.print("Next candidate: #" .. index .. " = " .. candidate.name)
                    end
                    if find_or_cheat_item(candidate) then break end
                end
            end -- of typed if/else
        end -- of group loop
    else
        for index, candidate in Lib.wraparound(item.group.sorted, item.index, reverse) do
            if global.debug then
                player.print("Next candidate: #" .. index .. " = " .. candidate.name)
            end
            if find_or_cheat_item(candidate) then break end
        end
    end

    if stack or will_cheat then
        pdata.group_history[item.group.id] = item
        if stack then
            player.clean_cursor()  -- May fail if inv is full, that's okay for now.
            if player.cursor_stack.swap_stack(stack) then  -- Shouldn't* fail
                pdata.group_history[newitem.group.id] = newitem
                pdata.item_history[newitem.name] = newitem
            end
        elseif player.clean_cursor() then  -- May fail if inv is full, this is doubleplusungood.
            player.cursor_stack.set_stack(newitem.name)  -- Automatically selects full stack.
            pdata.group_history[newitem.group.id] = newitem
            pdata.item_history[newitem.name] = newitem
        end
    end
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