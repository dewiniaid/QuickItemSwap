return function()
    local result = {}

    if not game.active_mods['LogisticTrainNetwork'] then
        return nil
    end

    return {
        categories = {
            rail = {
                groups = {
                    track = {
                        items = {
                            ['logistic-train-stop'] = { order = 201 }
                        }
                    }
                }
            }
        }
    }
end
