return function()
    local result = {}

    if not game.active_mods['bobinserters'] then
        return nil
    end

    return {
        categories = {
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
        }
    }
end
