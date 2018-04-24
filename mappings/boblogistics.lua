-- Not finished, and not in this release.  Bob's just adds more stuff than I feel like supporting at the moment.
-- (Maybe you can ask him to add support on his end instead?)

return function()
    local result = {}

    if not game.active_mods['boblogistics'] then
        return nil
    end

    return {
        categories = {
            trains = {
                groups = {
                    trains = {
                        default_order = 100,
                        items = {
                            ["bob-locomotive-2"] = { order = 102 },
                            ["bob-locomotive-3"] = { order = 103 },
                            ["bob-armoured-locomotive"] = { order = 110 },
                            ["bob-armoured-locomotive-2"] = { order = 111 },
                            ["bob-cargo-wagon-2"] = { order = 202 },
                            ["bob-cargo-wagon-3"] = { order = 203 },
                            ["bob-armoured-cargo-wagon"] = { order = 210 },
                            ["bob-armoured-cargo-wagon-2"] = { order = 211 },
                            ["bob-fluid-wagon-2"] = { order = 302 },
                            ["bob-fluid-wagon-3"] = { order = 303 },
                            ["bob-armoured-fluid-wagon"] = { order = 310 },
                            ["bob-armoured-fluid-wagon-2"] = { order = 311 },
                        }
                    }
                }
            },
            inserters = {
                groups = {
                    express = {
                        order = 1200,
                        items = {
                            ['express-inserter'] = { order = 100, type = 'normal' },
                            ['express-filter-inserter'] = { order = 200, type = 'filter' },
                        }
                    },
                    stack = {
                        order = 1300,
                        items = {
                            ['express-stack-inserter'] = { order = 100, type = 'normal' },
                            ['express-stack-filter-inserter'] = { order = 200, type = 'filter' },
                        }
                    },
                }
            },
        },
        fluids = {
            groups = {
                pipes = {
                    default_order = 100,
                    items = {
                        ['bob-valve'] = { order = 1000 },
                    }
                },
                structures = {
                    default_order = 200,
                    items = {
                        ['offshore-pump'] = { order = 100 },
                        ['bob-pump-2'] = { order = 202 },
                        ['bob-pump-3'] = { order = 203 },
                        ['bob-pump-4'] = { order = 204 },
                        ['storage-tank'] = { order = 300 },
                        ['storage-tank-2'] = { order = 302 },
                        ['storage-tank-3'] = { order = 303 },
                        ['storage-tank-4'] = { order = 304 },
                    }
                },
            }
        },

    }
end
