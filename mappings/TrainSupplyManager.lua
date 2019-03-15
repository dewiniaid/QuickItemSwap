return function()
    local result = {}

    if not game.active_mods['train-pubsub'] then
        return nil
    end

    return {
        categories = {
            rail = {
                groups = {
                    track = {
                        items = {
                            ['publisher-train-stop'] = { order = 210 },
                            ['subscriber-train-stop'] = { order = 211 },
                        }
                    }
                }
            }
        }
    }
end
