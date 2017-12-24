return { categories = {
    belts = {
        groups = {
            normal = {
                order = 100,
                items = {
                    ['transport-belt'   ] = { order = 100, type = 'belt' },
                    ['underground-belt' ] = { order = 200, type = 'underground' },
                    ['splitter'         ] = { order = 300, type = 'splitter' },
                },
            },
            fast = {
                order = 200,
                items = {
                    ['fast-transport-belt'   ] = { order = 100, type = 'belt' },
                    ['fast-underground-belt' ] = { order = 200, type = 'underground' },
                    ['fast-splitter'         ] = { order = 300, type = 'splitter' },
                },
            },
            express = {
                order = 300,
                items = {
                    ['express-transport-belt'   ] = { order = 100, type = 'belt' },
                    ['express-underground-belt' ] = { order = 200, type = 'underground' },
                    ['express-splitter'         ] = { order = 300, type = 'splitter' },
                },
            },
        }
    },
    fluids = {
        groups = {
            pipes = {
                order = 100,
                items = {
                    ['pipe'] = { order = 100 },
                    ['pipe-to-ground'] = { order = 200 },
                }
            },
            structures = {
                order = 200,
                items = {
                    ['offshore-pump'] = { order = 100 },
                    ['pump'] = { order = 200 },
                    ['storage-tank'] = { order = 300 },
                }
            },
        }
    },
    circuits = {
        groups = {
            wires = {
                order = 100,
                items = {
                    ['green-wire'] = { order = 100 },
                    ['red-wire'] = { order = 200 },
                    ['copper-cable'] = { order = 300 },
                }
            },
            combinators = {
                order = 200,
                items = {
                    ['constant-combinator'] = { order = 100 },
                    ['arithmetic-combinator'] = { order = 200 },
                    ['decider-combinator'] = { order = 300 },
                    ['small-lamp'] = { order = 1000 },
                    ['power-switch'] = { order = 1100 },
                    ['programmable-speaker'] = { order = 1200 },
                }
            },
        }
    },
    storage = {
        groups = {
            normal = {
                order = 100,
                items = {
                    ['wooden-chest'] = { order = 100 },
                    ['iron-chest'] = { order = 200 },
                    ['steel-chest'] = { order = 300 },
                }
            },
            logistics = {
                order = 200,
                items = {
                    ['logistic-chest-active-provider'] = { order = 100 },
                    ['logistic-chest-passive-provider'] = { order = 200 },
                    ['logistic-chest-storage'] = { order = 300 },
                    ['logistic-chest-buffer'] = { order = 400 },
                    ['logistic-chest-requester'] = { order = 500 },
                }
            },
        }
    },
    rail = {
        groups = {
            track = {
                order = 100,
                items = {
                    ['rail'] = { order = 100 },
                    ['train-stop'] = { order = 200 },
                }
            },
            signals = {
                order = 200,
                items = {
                    ['rail-signal'] = { order = 100 },
                    ['rail-chain-signal'] = { order = 200 },
                }
            },
        }
    },
    trains = {
        groups = {
            trains = {
                order = 100,
                items = {
                    ['locomotive'] = { order = 100 },
                    ['cargo-wagon'] = { order = 200 },
                    ['fluid-wagon'] = { order = 300 },
                }
            },
        }
    },
    inserters = {
        groups = {
            plain = {
                order = 100,
                items = {
                    ['burner-inserter'] = { order = 100 },
                    ['inserter'] = { order = 200 },
                    ['long-handed-inserter'] = { order = 300 },
                }
            },
            fast = {
                order = 200,
                items = {
                    ['fast-inserter'] = { order = 100, type = 'normal' },
                    ['filter-inserter'] = { order = 200, type = 'filter' },
                }
            },
            stack = {
                order = 300,
                items = {
                    ['stack-inserter'] = { order = 100, type = 'normal' },
                    ['stack-filter-inserter'] = { order = 200, type = 'filter' },
                }
            },
        }
    },
    power_production = {
        groups = {
            steam = {
                order = 100,
                items = {
                    ['boiler'] = { order = 100 },
                    ['steam-engine'] = { order = 200 },
                }
            },
            solar = {
                order = 200,
                items = {
                    ['solar-panel'] = { order = 100 },
                    ['accumulator'] = { order = 200 },
                }
            },
            nuclear = {
                order = 300,
                items = {
                    ['nuclear-reactor'] = { order = 100 },
                    ['heat-exchanger'] = { order = 200 },
                    ['heat-pipe'] = { order = 300 },
                }
            },
        }
    },
    power_distribution = {
        groups = {
            only_one_group = {
                order = 100,
                items = {
                    ['small-electric-pole'] = { order = 100 },
                    ['medium-electric-pole'] = { order = 200 },
                    ['big-electric-pole'] = { order = 300 },
                    ['substation'] = { order = 400 },
                }
            }
        }
    },
    miners = {
        groups = {
            only_one_group = {
                order = 100,
                items = {
                    ['burner-mining-drill'] = { order = 100 },
                    ['electric-mining-drill'] = { order = 200 },
                }
            },
        }
    },
    assemblers = {
        groups = {
            only_one_group = {
                order = 100,
                items = {
                    ['assembling-machine-1'] = { order = 100 },
                    ['assembling-machine-2'] = { order = 200 },
                    ['assembling-machine-3'] = { order = 300 },
                }
            },
        }
    },
    furnaces = {
        groups = {
            only_one_group = {
                order = 100,
                items = {
                    ['stone-furnace'] = { order = 100 },
                    ['steel-furnace'] = { order = 200 },
                    ['electric-furnace'] = { order = 300 },
                }
            },
        }
    },
    tiles = {
        groups = {
            only_one_group = {
                order = 100,
                items = {
                    ['stone-brick'] = { order = 100 },
                    ['concrete'] = { order = 200 },
                    ['hazard-concrete'] = { order = 300 },
                    ['landfill'] = { order = 400 },
                }
            },
        }
    },
    modules = {
        groups = {
            tier1 = {
                order = 100,
                items = {
                    ['speed-module'] = { order = 100, type='speed' },
                    ['effectivity-module'] = { order = 200, type='effectivity'  },
                    ['productivity-module'] = { order = 300, type='productivity'  },
                }
            },
            tier2 = {
                order = 200,
                items = {
                    ['speed-module-2'] = { order = 100, type='speed' },
                    ['effectivity-module-2'] = { order = 200, type='effectivity'  },
                    ['productivity-module-2'] = { order = 300, type='productivity'  },
                }
            },
            tier3 = {
                order = 300,
                items = {
                    ['speed-module-3'] = { order = 100, type='speed' },
                    ['effectivity-module-3'] = { order = 200, type='effectivity'  },
                    ['productivity-module-3'] = { order = 300, type='productivity'  },
                }
            },
        }
    },
}}
