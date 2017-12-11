return function()
    local result = {}

    if not game.active_mods['Vehicle Wagon'] then
        return nil
    end

    return {
        categories = {
            trains = {
                groups = {
                    trains = {
                        items = {
                            ["vehicle-wagon"] = { order = 500 }
                        }
                    }
                }
            }
        }
    }
end
