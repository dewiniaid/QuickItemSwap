return function()
    local result = {}

    if not game.active_mods['ElectricVehicles3'] then
        return nil
    end

    return {
        categories = {
            trains = {
                groups = {
                    trains = {
                        default_order = 100,
                        items = {
                            ["electric-vehicles-electric-locomotive"] = { order = 140 }
                        }
                    }
                }
            }
        }
    }
end
