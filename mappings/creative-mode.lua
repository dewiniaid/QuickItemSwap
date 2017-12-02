--
return function()
    if not game.active_mods['creative-mode'] or not settings.global["QuickItemSwap-support-creative-mode"].value then
        return nil
    end

    local split = settings.global["QuickItemSwap-creative-mode-split"].value
    local prefix = (split and "creative-mode_") or ""

    return { categories = {
        [prefix .. "storage"] = {
            groups = {
                creative = {
                    order = 10000,
                    items = {
                        ['creative-mode_creative-chest'] = { order = 100 },
                        ['creative-mode_creative-provider-chest'] = { order = 200 },
                        ['creative-mode_autofill-requester-chest'] = { order = 300 },
                        ['creative-mode_duplicating-chest'] = { order = 400 },
                        ['creative-mode_duplicating-provider-chest'] = { order = 500 },
                        ['creative-mode_void-requester-chest'] = { order = 600 },
                        ['creative-mode_void-storage-chest'] = { order = 700 },
                    }
                },
            },
        },
        [prefix .. "trains"] = {
            groups = {
                creative = {
                    order = 10000,
                    items = {
                        ['creative-mode_creative-cargo-wagon'] = { order = 10000 },
                        ['creative-mode_duplicating-cargo-wagon'] = { order = 10100 },
                        ['creative-mode_void-cargo-wagon'] = { order = 10200 },
                    }
                },
            },
        },
        [prefix .. "power_distribution"] = {
            groups = {
                creative = {
                    order = 10000,
                    items = {
                        ['creative-mode_super-electric-pole'] = { order = 100 },
                        ['creative-mode_super-substation'] = { order = 200 },
                    }
                }
            },
        },
        [prefix .. "power_production"] = {
            groups = {
                creative_producers = {
                    order = 10000,
                    items = {
                        ['creative-mode_active-electric-energy-interface-output'] = { order = 100 },
                        ['creative-mode_passive-electric-energy-interface'] = { order = 200 },
                        ['creative-mode_energy-source'] = { order = 300 },
                        ['creative-mode_passive-energy-source'] = { order = 400 },
                    }
                },
                creative_consumers = {
                    order = 10100,
                    items = {
                        ['creative-mode_active-electric-energy-interface-input'] = { order = 100 },
                        ['creative-mode_energy-void'] = { order = 300 },
                        ['creative-mode_passive-energy-void'] = { order = 400 },
                    }
                },
            },
        },
        [prefix .. "modules"] = {
            groups = {
                creative = {
                    order = 10000,
                    items = {
                        ['creative-mode_super-speed-module'] = { order = 100, type='speed' },
                        ['creative-mode_super-effectivity-module'] = { order = 200, type='effectivity' },
                        ['creative-mode_super-productivity-module'] = { order = 300, type='productivity' },
                        ['creative-mode_super-clean-module'] = { order = 400 },
                        ['creative-mode_super-slow-module'] = { order = 500 },
                        ['creative-mode_super-consumption-module'] = { order = 600 },
                        ['creative-mode_super-pollution-module'] = { order = 700 },
                    }
                },
            }
        },
        [prefix .. "fluids"] = {
            groups = {
                creative_items = {
                    order = 10000,
                    items = {
                        ['creative-mode_fluid-source'] = { order = 100 },
                        ['creative-mode_fluid-void'] = { order = 200 },
                    }
                },
                creative_temperature_control = {
                    order = 10100,
                    items = {
                        ['creative-mode_super-boiler'] = { order = 100 },
                        ['creative-mode_configurable-super-boiler'] = { order = 200 },
                        ['creative-mode_super-cooler'] = { order = 300 },
                        ['creative-mode_heat-source'] = { order = 400 },
                        ['creative-mode_heat-void'] = { order = 500 },
                    }
                },
            }
        },
    } }
end

