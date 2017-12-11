-- Related item data and utility functions.

--[[

Item mapping hierarchy:
    CATEGORY_NAME = {                           Category name is used by the API for other mod support
        {
            name = API_NAME_OF_GROUP            Group name is used by the API for other mod support
            order = SORT_VALUE                  Where this group falls in the sort order.  Leave gaps for other mod support.
            items = {                           List of items in this group
                {
                    order = SORT_VALUE,         Item's order within this group
                    name = ENTITY_NAME,         Item's entity name as provided by Factorio
                    type = CATEGORY,            Item's type.  May be nil.  If non-nil and changing to a group that has
                                                    an item of the same type, that item is selected.  Should be unique
                                                    (other than nil) within each group, behavior is undefined otherwise
                } ...
            }
        },
        {
            name = API_NAME_OF_ANOTHER_GROUP,
            ...
        }
    }
]]

local Mappings = {}
Mappings.dirty = true
Mappings.categories = {
    belts = {
        groups = {
            normal = {
                order = 100,
                items = {
                    ['transport-belt'   ] = { order = 100, type = 'belt' },
                    ['underground-belt' ] = { order = 200, type = 'underground' },
                    ['splitter'         ] = { order = 300, type = 'splitter' },
                },
            },
            fast = {
                order = 200,
                items = {
                    ['fast-transport-belt'   ] = { order = 100, type = 'belt' },
                    ['fast-underground-belt' ] = { order = 200, type = 'underground' },
                    ['fast-splitter'         ] = { order = 300, type = 'splitter' },
                },
            },
            express = {
                order = 300,
                items = {
                    ['express-transport-belt'   ] = { order = 100, type = 'belt' },
                    ['express-underground-belt' ] = { order = 200, type = 'underground' },
                    ['express-splitter'         ] = { order = 300, type = 'splitter' },
                },
            },
        }
    },
    liquids = {
        groups = {
            pipes = {
                order = 100,
                items = {
                    ['pipe'] = { order = 100 },
                    ['pipe-to-ground'] = { order = 200 },
                }
            },
            structures = {
                order = 200,
                items = {
                    ['offshore-pump'] = { order = 100 },
                    ['pump'] = { order = 200 },
                    ['storage-tank'] = { order = 300 },
                }
            },
        }
    },
    circuits = {
        groups = {
            wires = {
                order = 100,
                items = {
                    ['green-wire'] = { order = 100 },
                    ['red-wire'] = { order = 200 },
                    ['copper-cable'] = { order = 300 },
                }
            },
            combinators = {
                order = 200,
                items = {
                    ['constant-combinator'] = { order = 100 },
                    ['arithmetic-combinator'] = { order = 200 },
                    ['decider-combinator'] = { order = 300 },
                    ['small-lamp'] = { order = 1000 },
                    ['power-switch'] = { order = 1100 },
                    ['programmable-speaker'] = { order = 1200 },
                }
            },
        }
    },
    storage = {
        groups = {
            normal = {
                order = 100,
                items = {
                    ['wooden-chest'] = { order = 100 },
                    ['iron-chest'] = { order = 200 },
                    ['steel-chest'] = { order = 300 },
                }
            },
            logistics = {
                order = 200,
                items = {
                    ['logistic-chest-active-provider'] = { order = 100 },
                    ['logistic-chest-passive-provider'] = { order = 200 },
                    ['logistic-chest-requester'] = { order = 300 },
                    ['logistic-chest-storage'] = { order = 400 },
                }
            },
        }
    },
    rail = {
        groups = {
            track = {
                order = 100,
                items = {
                    ['rail'] = { order = 100 },
                    ['train-stop'] = { order = 200 },
                }
            },
            signals = {
                order = 200,
                items = {
                    ['rail-signal'] = { order = 100 },
                    ['rail-chain-signal'] = { order = 200 },
                }
            },
        }
    },
    trains = {
        groups = {
            trains = {
                order = 100,
                items = {
                    ['locomotive'] = { order = 100 },
                    ['cargo-wagon'] = { order = 200 },
                    ['fluid-wagon'] = { order = 300 },
                    ['artillery-wagon'] = { order = 400 },  -- 0.16 Soon(tm)
                }
            },
        }
    },
    inserters = {
        groups = {
            plain = {
                order = 100,
                items = {
                    ['burner-inserter'] = { order = 100 },
                    ['inserter'] = { order = 200 },
                    ['long-handed-inserter'] = { order = 300 },
                }
            },
            fast = {
                order = 200,
                items = {
                    ['fast-inserter'] = { order = 100, type = 'normal' },
                    ['filter-inserter'] = { order = 200, type = 'filter' },
                }
            },
            stack = {
                order = 300,
                items = {
                    ['stack-inserter'] = { order = 100, type = 'normal' },
                    ['stack-filter-inserter'] = { order = 200, type = 'filter' },
                }
            },
        }
    },
    power_production = {
        groups = {
            steam = {
                order = 100,
                items = {
                    ['boiler'] = { order = 100 },
                    ['steam-engine'] = { order = 200 },
                }
            },
            solar = {
                order = 200,
                items = {
                    ['solar-panel'] = { order = 100 },
                    ['accumulator'] = { order = 200 },
                }
            },
            nuclear = {
                order = 300,
                items = {
                    ['nuclear-reactor'] = { order = 100 },
                    ['heat-exchanger'] = { order = 200 },
                    ['heat-pipe'] = { order = 300 },
                }
            },
        }
    },
    power_distribution = {
        groups = {
            only_one_group = {
                order = 100,
                items = {
                    ['small-electric-pole'] = { order = 100 },
                    ['medium-electric-pole'] = { order = 200 },
                    ['big-electric-pole'] = { order = 300 },
                    ['substation'] = { order = 400 },
                }
            }
        }
    },
    miners = {
        groups = {
            only_one_group = {
                order = 100,
                items = {
                    ['burner-mining-drill'] = { order = 100 },
                    ['electric-mining-drill'] = { order = 200 },
                }
            },
        }
    },
    assemblers = {
        groups = {
            only_one_group = {
                order = 100,
                items = {
                    ['assembling-machine-1'] = { order = 100 },
                    ['assembling-machine-2'] = { order = 200 },
                    ['assembling-machine-3'] = { order = 300 },
                }
            },
        }
    },
    furnaces = {
        groups = {
            only_one_group = {
                order = 100,
                items = {
                    ['stone-furnace'] = { order = 100 },
                    ['steel-furnace'] = { order = 200 },
                    ['electric-furnace'] = { order = 300 },
                }
            },
        }
    },
    tiles = {
        groups = {
            only_one_group = {
                order = 100,
                items = {
                    ['stone-brick'] = { order = 100 },
                    ['concrete'] = { order = 200 },
                    ['hazard-concrete'] = { order = 300 },
                    ['landfill'] = { order = 400 },
                }
            },
        }
    },
    modules = {
        groups = {
            tier1 = {
                order = 100,
                items = {
                    ['speed-module'] = { order = 100, type='speed' },
                    ['effectivity-module'] = { order = 200, type='effectivity'  },
                    ['productivity-module'] = { order = 300, type='productivity'  },
                }
            },
            tier2 = {
                order = 200,
                items = {
                    ['speed-module-2'] = { order = 100, type='speed' },
                    ['effectivity-module-2'] = { order = 200, type='effectivity'  },
                    ['productivity-module-2'] = { order = 300, type='productivity'  },
                }
            },
            tier3 = {
                order = 300,
                items = {
                    ['speed-module-3'] = { order = 100, type='speed' },
                    ['effectivity-module-3'] = { order = 200, type='effectivity'  },
                    ['productivity-module-3'] = { order = 300, type='productivity'  },
                }
            },
        }
    },
}


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


function Mappings:refresh(if_dirty)
    if if_dirty and not self.dirty then
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
    self.dirty = false
end


function Mappings:find(name, category, group)
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


Mappings:refresh()
return Mappings
