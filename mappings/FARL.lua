return function()
    local result = {}

    if not game.active_mods['FARL'] then
        return nil
    end

    return {
        categories = {
            trains = {
                groups = {
                    trains = {
                        default_order = 100,
                        items = {
                            ["farl"] = { order = 190 }
                        }
                    }
                }
            }
        }
    }
end
