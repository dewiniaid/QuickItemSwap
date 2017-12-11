return function()
    local result = {}

    if not game.active_mods['nixie-tubes'] then
        return nil
    end

    return {
        categories = {
            circuits = {
                groups = {
                    combinators = {
                        items = {
                            ['nixie-tube'] = { order = 1300 },
                            ['nixie-tube-alpha'] = { order = 1301 },
                            ['nixie-tube-small'] = { order = 1302 },
                        }
                    }
                }
            }
        }
    }
end
