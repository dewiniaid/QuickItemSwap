return function()
    local result = {}

    if not game.active_mods['SmartTrains'] then
        return nil
    end

    return {
        categories = {
            rail = {
                groups = {
                    track = {
                        items = {
                            ['smart-train-stop'] = { order = 202 }
                        }
                    }
                }
            }
        }
    }
end
