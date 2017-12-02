require "util"

-- Sorts a table based on the 'order' field of its subtables.  Returns a new table.
-- The subtables are also modified to also have an 'index' field specifying their location.
local function sorted(t)
    local result = {}
    for _, v in pairs(t) do
        table.insert(result, v)
    end

    table.sort(result, function(a, b) return a.order < b.order end)

    for i, v in ipairs(result) do
        v.index = i
    end

    return result
end


-- Used temporarily during Mappings:refresh to ensure every access returns a table of some form.
local DefaultCatalogValues = {
    __index = function(table, key)
        v = {}
        table[key] = v
        return v
    end
}


local Mapper = {
    catalog = {},
    is_dirty = true
}

local MapperMeta = {__index = Mapper }


function Mapper:refresh(if_dirty)
    if if_dirty and not self.is_dirty then
        return
    end

    self.catalog = {}
    setmetatable(self.catalog, DefaultCatalogValues)

    for name, category in pairs(self.categories) do
        category.name = name    -- To aid inspection later on
        category.sorted = sorted(category.groups)

        for name, group in pairs(category.groups) do
            group.name = name
            group.id = category.name .. "/" .. group.name
            group.sorted = sorted(group.items)
            group.category = category
            group.typed = {}

            for name,item in pairs(group.items) do
                item.name = name
                item.group = group
                item.category = category
                table.insert(self.catalog[name], item)
                if item.type then
                    group.typed[item.type] = item
                end
            end
        end
    end

    setmetatable(self.catalog, nil)
    self.is_dirty = false
end


local EXPORT_FIELD_IGNORE, EXPORT_FIELD_RECURSE = 1, 2
local EXPORT_FIELDS = {
    groups = EXPORT_FIELD_RECURSE,
    items = EXPORT_FIELD_RECURSE,
    sorted = EXPORT_FIELD_IGNORE,
    typed = EXPORT_FIELD_IGNORE,
    category = EXPORT_FIELD_IGNORE,
    group = EXPORT_FIELD_IGNORE,
    name = EXPORT_FIELD_IGNORE
}


function Mapper:export(category, group, item)
    local function export_recursive(src)
        local tgt = {}

        for k, v in pairs(src) do
            action = EXPORT_FIELDS[k]
            if not action then
                tgt[k] = v
            elseif action == EXPORT_FIELD_RECURSE then
                local copy = {}
                for k2, v2 in pairs(v) do
                    copy[k2] = export_recursive(v2)
                end
                tgt[k] = copy
            end
        end

        return tgt
    end

    if category then
        category = self.categories[category]
        if not category then
            return nil
        end
        if group then
            group = category.groups[group]
            if not group then
                return nil
            end
            if item then
                item = group.items[item]
                if not item then
                    return nil
                end
                return export_recursive(item)
            end
            return export_recursive(group)
        end
        return export_recursive(category)
    end
    local categories = { }
    for k, v in pairs(self.categories) do
        categories[k] = export_recursive(v)
    end
    return { categories = categories }
end


function Mapper:find(name, category, group)
    --[[
     - Looks for the item 'name' in the catalog.

       If it exists, returns the first matching entry for the item

       If `category` and `group` are both specified and an entry matches them, that entry is returned instead.

       Returns nil for nonexistant items.
      ]]
    self:refresh(true)

    if category and group then
        category = self.categories[category]
        if category then
            group = category.groups[group]
            if group and group.items[name] then
                return group.items[name]
            end
        end
    end

    return (self.catalog[name] and self.catalog[name][1]) or nil
end


function Mapper:merge(other)
    --[[
    Merge definitions from another Mapper.

    Adds new categories from the other Mapper.
    Adds new groups within existing categories from the other Mapper.
    Adds new items within existing groups from the other Mapper.
    Replaces existing items with matching items in the other Mapper.

    If the other Mapper explicitly sets a category, group or item to `false`, it is deleted.
    It is not an error to delete a category/group/item that does not exist.

    The other mapper does not need to be refreshed for the update to succeed.  In fact, it can be a plain table.
     ]]
    if not other then return end

    self.is_dirty = true  -- We're probably about to be...

    local function set_order(to, from)
        if from.order ~= nil then
            to.order = from.order
            return
        end
        if to.order ~= nil then
            return
        end
        to.order = from.default_order
    end

    for name, other_category in pairs(other.categories) do
        if not other_category then
            self.categories[name] = nil
        else
            local category = self.categories[name] or { groups={} }
            self.categories[name] = category

            for name, other_group in pairs(other_category.groups) do
                if not other_group then
                    category.groups[name] = nil
                else
                    local group = category.groups[name] or { items={} }
                    category.groups[name] = group
                    set_order(group, other_group)

                    for name, other_item in pairs(other_group.items) do
                        if other_item then
                            group.items[name] = table.deepcopy(other_item)
                        else
                            group.items[name] = nil
                        end
                    end
                end
            end
        end
    end
end


function Mapper:adopt(t)
    setmetatable(t, MapperMeta)
    return t
end

function Mapper:clone()
    return self:adopt(table.deepcopy(self))
end


function Mapper:validate(printfn)
    if not printfn then
        printfn = game.print
    end

    local prototypes = game.item_prototypes

    self:refresh(true)
    for name, entries in pairs(self.catalog) do
        if not prototypes[name] then
            printfn("Item '" .. name .. "' has no prototype!  Defined at: ")
            for _,e in pairs(entries) do
                printfn("Category " .. e.category.name .. ", Group " .. e.group.name .. ", Order " .. e.order)
            end
        end
    end
end

return Mapper
