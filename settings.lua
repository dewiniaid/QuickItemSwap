
-- Cheat Mode options
data:extend({
    {
        type = "bool-setting",
        name = "QuickItemSwap-support-cheat-mode",
        default_value = true,
        setting_type = "runtime-per-user",
        order = 100,
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
if mods["creative-mode"] then
    data:extend({
        {
            type = "bool-setting",
            name = "QuickItemSwap-support-creative-mode",
            default_value = true,
            setting_type = "runtime-global",
            order = 200,
        },
        {
            type = "bool-setting",
            name = "QuickItemSwap-creative-mode-split",
            default_value = false,
            setting_type = "runtime-global",
            order = 210,
        },
        {
            type = "bool-setting",
            name = "QuickItemSwap-support-cheat-mode-with-creative",
            default_value = false,
            setting_type = "runtime-per-user",
            order = 220,
        },
    })
end
