-- Add keybindings

data:extend({
    {
        type = "custom-input",
        name = "qis-item-prev",
        key_sequence = "CTRL + Y",
        consuming = "all"
    },
    {
        type = "custom-input",
        name = "qis-item-next",
        key_sequence = "Y",
        consuming = "all"
    },
    {
        type = "custom-input",
        name = "qis-group-prev",
        key_sequence = "CTRL + SHIFT + Y",
        consuming = "all"
    },
    {
        type = "custom-input",
        name = "qis-group-next",
        key_sequence = "SHIFT + Y",
        consuming = "all"
    },
})
