-- Cheat Mode options
data:extend({
    {
        type = "bool-setting",
        name = "QuickItemSwap-support-cheat-mode",
        default_value = true,
        setting_type = "runtime-per-user",
        order = 100,
    },
    {
        type = "bool-setting",
        name = "QuickItemSwap-use-ghosts",
        default_value = true,
        setting_type = "runtime-per-user",
        order = 220,
    },
    {
        type = "bool-setting",
        name = "QuickItemSwap-requires-tech",
        default_value = true,
        setting_type = "runtime-per-user",
        order = 221,
    },
    --    {
    --        type = "bool-setting",
    --        name = "QuickItemSwap-destroy-cheated-items",
    --        default_value = true,
    --        setting_type = "runtime-per-user",
    --        order = 110,
    --    },
})

-- Creative Mode support
if mods["creative-mode"] or mods["creative-mode-fix"] then
    data:extend({
        {
            type = "bool-setting",
            name = "QuickItemSwap-support-creative-mode",
            default_value = true,
            setting_type = "runtime-global",
            order = 300,
        },
        {
            type = "bool-setting",
            name = "QuickItemSwap-creative-mode-split",
            default_value = false,
            setting_type = "runtime-global",
            order = 310,
        },
        {
            type = "bool-setting",
            name = "QuickItemSwap-support-cheat-mode-with-creative",
            default_value = false,
            setting_type = "runtime-per-user",
            order = 320,
        },
        --{
        --    type = "string-setting",
        --    name = "QuickItemSwap-initial-blacklist",
        --    default_value = "burner-inserter,burner-mining-drill",
        --    setting_type = "runtime-per-user",
        --    order = 220,
        --},
    })
end
