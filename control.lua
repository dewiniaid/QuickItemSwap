require "util"
local Mappings = require("qis/mappings")
local Lib = require("qis/lib")


function on_load()
    setmetatable(global.playerdata, {
        __index = function(t, k)
            local v = {
                item_history = {},
                group_history = {},
            }
            t[k] = v
            return v
        end
    })
end
function on_init()
    global.playerdata = {}
    on_load()
end


script.on_init(on_init)
script.on_load(on_load)


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
    local item = Mappings:find(cursor.name, history.category, history.group)
    if not item then
        if global.debug then player.print("Item " .. cursor.name .. " is not in catalog.") end
        return
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

    local stack, slot, newitem
    local quickbar = player.get_quickbar()
    local inv = player.get_inventory(defines.inventory.player_main)

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
                stack, slot = Lib.find_item(candidate.name, quickbar, inv)
                if stack then
                    newitem = candidate
                    break
                end
            else
                -- Untyped item, or group does not have this type.
                if pdata.group_history[group.id] then
                    candidate = pdata.group_history[group.id]
                    if global.debug then
                        player.print("Candidate item from history: #" .. index .. " = " .. candidate.name)
                    end
                    stack, slot = Lib.find_item(candidate.name, quickbar, inv)
                    if stack then
                        newitem = candidate
                        break
                    end
                end

                -- No candidate item, or candidate item doesn't exist.
                -- Try to find something else in the group that we do have.
                for index, candidate in Lib.wraparound(group.sorted, candidate and candidate.index, reverse) do
                    if global.debug then
                        player.print("Next candidate: #" .. index .. " = " .. candidate.name)
                    end

                    stack, slot = Lib.find_item(candidate.name, quickbar, inv)
                    if stack then
                        newitem = candidate
                        break
                    end
                end
            end -- of typed if/else
        end -- of group loop
    else
        for index, candidate in Lib.wraparound(item.group.sorted, item.index, reverse) do
            if global.debug then
                player.print("Next candidate: #" .. index .. " = " .. candidate.name)
            end

            stack, slot = Lib.find_item(candidate.name, quickbar, inv)
            if stack then
                newitem = candidate
                break
            end
        end
    end

    -- TODO: Handle quickbar preservation hacks for 0.15
    if stack then
        pdata.group_history[item.group.id] = item
        player.clean_cursor()  -- May fail if inv is full, that's okay for now.
        if player.cursor_stack.swap_stack(stack) then  -- Shouldn't* fail
            pdata.group_history[newitem.group.id] = newitem
            pdata.item_history[newitem.name] = newitem
        end
    end
end


local function dump_inventory(inv)
    for i=1,#inv do
        item = inv[i]
        if item.valid_for_read then
            game.print(i .. ": " .. item.name .. " x" .. item.count)
        else
            game.print(i .. ": --EMPTY--")
        end
    end
end


local function dump_quickbar(player)
    player = player or game.players[1]
    quickbar = player.get_quickbar()
    if not quickbar.valid then
        return false
    end
    dump_inventory(quickbar)
end

-- Core functionality
script.on_event("qis-item-next", function(event) return cycle_item(event, false, false) end)
script.on_event("qis-item-prev", function(event) return cycle_item(event, false, true) end)
script.on_event("qis-group-next", function(event) return cycle_item(event, true, false) end)
script.on_event("qis-group-prev", function(event) return cycle_item(event, true, true) end)


-- Housekeeping
script.on_event({defines.events.on_player_removed, defines.events.on_player_left_game}, function(event)
    if global.playerdata then
        global.playerdata[event.player_index] = nil
    end
end)


remote.add_interface(
    "QuickItemSwap",
    {
        dump_quickbar = dump_quickbar,
        dump_inventory = dump_inventory,
        debug = function(new)
            if new ~= nil then
                global.debug = new
            end
            return global.debug
        end,
        -- eval = function(code) return loadstring(code)() end
    }
)
