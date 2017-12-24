--
return function()
    if not (game.active_mods['creative-mode'] or game.active_mods['creative-mode-fix']) or not settings.global["QuickItemSwap-support-creative-mode"].value then
        return nil
    end

    local entity_prefix
    if game.active_mods['creative-mode'] then
        entity_prefix = "creative-mode_"
    else
        entity_prefix = "creative-mode-fix_"
    end
    local split = settings.global["QuickItemSwap-creative-mode-split"].value
    local prefix = (split and "creative-mode_") or ""

    return { categories = {
        [prefix .. "storage"] = {
            groups = {
                creative = {
                    order = 10000,
                    items = {
                        [entity_prefix .. 'creative-chest'] = { order = 100 },
                        [entity_prefix .. 'creative-provider-chest'] = { order = 200 },
                        [entity_prefix .. 'autofill-requester-chest'] = { order = 300 },
                        [entity_prefix .. 'duplicating-chest'] = { order = 400 },
                        [entity_prefix .. 'duplicating-provider-chest'] = { order = 500 },
                        [entity_prefix .. 'void-requester-chest'] = { order = 600 },
                        [entity_prefix .. 'void-storage-chest'] = { order = 700 },
                    }
                },
            },
        },
        [prefix .. "trains"] = {
            groups = {
                creative = {
                    order = 10000,
                    items = {
                        [entity_prefix .. 'creative-cargo-wagon'] = { order = 10000 },
                        [entity_prefix .. 'duplicating-cargo-wagon'] = { order = 10100 },
                        [entity_prefix .. 'void-cargo-wagon'] = { order = 10200 },
                    }
                },
            },
        },
        [prefix .. "power_distribution"] = {
            groups = {
                creative = {
                    order = 10000,
                    items = {
                        [entity_prefix .. 'super-electric-pole'] = { order = 100 },
                        [entity_prefix .. 'super-substation'] = { order = 200 },
                    }
                }
            },
        },
        [prefix .. "power_production"] = {
            groups = {
                creative_producers = {
                    order = 10000,
                    items = {
                        [entity_prefix .. 'active-electric-energy-interface-output'] = { order = 100 },
                        [entity_prefix .. 'passive-electric-energy-interface'] = { order = 200 },
                        [entity_prefix .. 'energy-source'] = { order = 300 },
                        [entity_prefix .. 'passive-energy-source'] = { order = 400 },
                    }
                },
                creative_consumers = {
                    order = 10100,
                    items = {
                        [entity_prefix .. 'active-electric-energy-interface-input'] = { order = 100 },
                        [entity_prefix .. 'energy-void'] = { order = 300 },
                        [entity_prefix .. 'passive-energy-void'] = { order = 400 },
                    }
                },
            },
        },
        [prefix .. "modules"] = {
            groups = {
                creative = {
                    order = 10000,
                    items = {
                        [entity_prefix .. 'super-speed-module'] = { order = 100, type='speed' },
                        [entity_prefix .. 'super-effectivity-module'] = { order = 200, type='effectivity' },
                        [entity_prefix .. 'super-productivity-module'] = { order = 300, type='productivity' },
                        [entity_prefix .. 'super-clean-module'] = { order = 400 },
                        [entity_prefix .. 'super-slow-module'] = { order = 500 },
                        [entity_prefix .. 'super-consumption-module'] = { order = 600 },
                        [entity_prefix .. 'super-pollution-module'] = { order = 700 },
                    }
                },
            }
        },
        [prefix .. "fluids"] = {
            groups = {
                creative_items = {
                    order = 10000,
                    items = {
                        [entity_prefix .. 'fluid-source'] = { order = 100 },
                        [entity_prefix .. 'fluid-void'] = { order = 200 },
                    }
                },
                creative_temperature_control = {
                    order = 10100,
                    items = {
                        [entity_prefix .. 'super-boiler'] = { order = 100 },
                        [entity_prefix .. 'configurable-super-boiler'] = { order = 200 },
                        [entity_prefix .. 'super-cooler'] = { order = 300 },
                        [entity_prefix .. 'heat-source'] = { order = 400 },
                        [entity_prefix .. 'heat-void'] = { order = 500 },
                    }
                },
            }
        },
    } }
end

