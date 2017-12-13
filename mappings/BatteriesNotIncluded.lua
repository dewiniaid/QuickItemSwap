return function()
    local result = {}

    if not game.active_mods['BatteriesNotIncluded'] then
        return nil
    end

    return {
        categories = {
            trains = {
                groups = {
                    trains = {
                        default_order = 100,
                        items = {
                            ["bni_electric-locomotive"] = { order = 150 }
                        }
                    }
                }
            }
        }
    }
end
