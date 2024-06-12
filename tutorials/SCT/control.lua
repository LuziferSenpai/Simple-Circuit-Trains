local eventHandler = require("__core__/lualib/event_handler")
local eventsDefine = defines.events
local eventsLib = {}

eventsLib.events = {
    [eventsDefine.on_game_created_from_scenario] = function()
        global.lineList = {
            ["1"] = {
                "Right01-06",
                "Left01-06"
            },
            ["2"] = {},
            ["3"] = {}
        }

        global.lineListDisplay = {
            ["1"] = {
                "[img=virtual-signal/signal-red] - Right01-06",
                "[img=virtual-signal/signal-green] - Left01-06"
            },
            ["2"] = {},
            ["3"] = {}
        }

        global.lines = {
            ["1"] = {
                ["Left01-06"] = {
                    schedule = {
                        current = 1,
                        records = {
                            {
                                station = "Left01"
                            },
                            {
                                station = "Left02"
                            },
                            {
                                station = "Left03"
                            },
                            {
                                station = "Left04"
                            },
                            {
                                station = "Left05"
                            },
                            {
                                station = "Left06"
                            }
                        }
                    },
                    signal = {
                        name = "signal-green",
                        type = "virtual"
                    },
                    stations = {
                        {
                            name = "Left01",
                            signal = {
                                name = "signal-1",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Left02",
                            signal = {
                                name = "signal-2",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Left03",
                            signal = {
                                name = "signal-3",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Left04",
                            signal = {
                                name = "signal-4",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Left05",
                            signal = {
                                name = "signal-5",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Left06",
                            signal = {
                                name = "signal-6",
                                type = "virtual"
                            }
                        }
                    }
                },
                ["Right01-06"] = {
                    schedule = {
                        current = 1,
                        records = {
                            {
                                station = "Right01"
                            },
                            {
                                station = "Right02"
                            },
                            {
                                station = "Right03"
                            },
                            {
                                station = "Right04"
                            },
                            {
                                station = "Right05"
                            },
                            {
                                station = "Right06"
                            }
                        }
                    },
                    signal = {
                        name = "signal-red",
                        type = "virtual"
                    },
                    stations = {
                        {
                            name = "Right01",
                            signal = {
                                name = "signal-1",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Right02",
                            signal = {
                                name = "signal-2",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Right03",
                            signal = {
                                name = "signal-3",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Right04",
                            signal = {
                                name = "signal-4",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Right05",
                            signal = {
                                name = "signal-5",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Right06",
                            signal = {
                                name = "signal-6",
                                type = "virtual"
                            }
                        }
                    }
                }
            },
            ["2"] = {},
            ["3"] = {}
        }

        local locomotives = game.surfaces[1].find_entities_filtered({
            type = "locomotive"
        })

        for i = 1, #locomotives do
            locomotives[i].train.manual_mode = false
        end
    end
}

eventHandler.add_libraries({
    require("__flib__/gui-lite"),

    require("__Simple_Circuit_Trains__/scripts/events"),
    require("__Simple_Circuit_Trains__/scripts/gui"),

    eventsLib
})

if script.active_mods["Automatic_Coupling_System"] then
    eventHandler.add_lib(require("__Automatic_Coupling_System__/scripts/events"))
end
