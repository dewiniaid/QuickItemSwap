-- Add keybindings

data:extend({
    {
        type = "custom-input",
        name = "qis-item-prev",
        key_sequence = "CONTROL + Y",
        consuming = "game-only"
    },
    {
        type = "custom-input",
        name = "qis-item-next",
        key_sequence = "Y",
        consuming = "game-only"
    },
    {
        type = "custom-input",
        name = "qis-group-prev",
        key_sequence = "CONTROL + SHIFT + Y",
        consuming = "game-only"
    },
    {
        type = "custom-input",
        name = "qis-group-next",
        key_sequence = "SHIFT + Y",
        consuming = "game-only"
    },
    {
        type = "custom-input",
        name = "qis-toggle-blacklist",
        key_sequence = "ALT + Y",
        consuming = "game-only"
    },
})
