local eventHandler = require("__core__/lualib/event_handler")
local eventsDefine = defines.events
local eventsLib = {}

eventsLib.events = {
    [eventsDefine.on_game_created_from_scenario] = function()
        global.lineList = {
            ["1"] = {
                "Empty Load",
                "Empty Unload",
                "Full Load",
                "Full Unload",
                "Load End",
                "Load Front",
                "Unload End",
                "Unload Front",
                "Switch"
            },
            ["2"] = {},
            ["3"] = {}
        }

        global.lineListDisplay = {
            ["1"] = {
                "[img=virtual-signal/signal-Z] - Empty Load",
                "[img=virtual-signal/signal-Y] - Empty Unload",
                "[img=virtual-signal/signal-X] - Full Load",
                "[img=virtual-signal/signal-W] - Full Unload",
                "[img=virtual-signal/signal-V] - Load End",
                "[img=virtual-signal/signal-U] - Load Front",
                "[img=virtual-signal/signal-T] - Unload End",
                "[img=virtual-signal/signal-S] - Unload Front",
                "[img=virtual-signal/signal-R] - Switch"
            },
            ["2"] = {},
            ["3"] = {}
        }

        global.lines = {
            ["1"] = {
                ["Empty Load"] = {
                    schedule = {
                        current = 1,
                        records = {
                            {
                                station = "Empty Load 01"
                            },
                            {
                                station = "Empty Load 02"
                            },
                            {
                                station = "Empty Load 03"
                            },
                            {
                                station = "Empty Load 04"
                            },
                            {
                                station = "Empty Load 05"
                            },
                            {
                                station = "Empty Load 06"
                            }
                        }
                    },
                    signal = {
                        name = "signal-Z",
                        type = "virtual"
                    },
                    stations = {
                        {
                            name = "Empty Load 01",
                            signal = {
                                name = "signal-0",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Empty Load 02",
                            signal = {
                                name = "signal-1",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Empty Load 03",
                            signal = {
                                name = "signal-2",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Empty Load 04",
                            signal = {
                                name = "signal-3",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Empty Load 05",
                            signal = {
                                name = "signal-4",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Empty Load 06",
                            signal = {
                                name = "signal-5",
                                type = "virtual"
                            }
                        }
                    }
                },
                ["Empty Unload"] = {
                    schedule = {
                        current = 1,
                        records = {
                            {
                                station = "Empty Unload 01"
                            },
                            {
                                station = "Empty Unload 02"
                            },
                            {
                                station = "Empty Unload 03"
                            },
                            {
                                station = "Empty Unload 04"
                            },
                            {
                                station = "Empty Unload 05"
                            },
                            {
                                station = "Empty Unload 06"
                            }
                        }
                    },
                    signal = {
                        name = "signal-Y",
                        type = "virtual"
                    },
                    stations = {
                        {
                            name = "Empty Unload 01",
                            signal = {
                                name = "signal-0",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Empty Unload 02",
                            signal = {
                                name = "signal-1",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Empty Unload 03",
                            signal = {
                                name = "signal-2",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Empty Unload 04",
                            signal = {
                                name = "signal-3",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Empty Unload 05",
                            signal = {
                                name = "signal-4",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Empty Unload 06",
                            signal = {
                                name = "signal-5",
                                type = "virtual"
                            }
                        }
                    }
                },
                ["Full Load"] = {
                    schedule = {
                        current = 1,
                        records = {
                            {
                                station = "Full Load 01"
                            },
                            {
                                station = "Full Load 02"
                            },
                            {
                                station = "Full Load 03"
                            },
                            {
                                station = "Full Load 04"
                            },
                            {
                                station = "Full Load 05"
                            },
                            {
                                station = "Full Load 06"
                            }
                        }
                    },
                    signal = {
                        name = "signal-X",
                        type = "virtual"
                    },
                    stations = {
                        {
                            name = "Full Load 01",
                            signal = {
                                name = "signal-0",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Full Load 02",
                            signal = {
                                name = "signal-1",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Full Load 03",
                            signal = {
                                name = "signal-2",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Full Load 04",
                            signal = {
                                name = "signal-3",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Full Load 05",
                            signal = {
                                name = "signal-4",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Full Load 06",
                            signal = {
                                name = "signal-5",
                                type = "virtual"
                            }
                        }
                    }
                },
                ["Full Unload"] = {
                    schedule = {
                        current = 1,
                        records = {
                            {
                                station = "Full Unload 01"
                            },
                            {
                                station = "Full Unload 02"
                            },
                            {
                                station = "Full Unload 03"
                            },
                            {
                                station = "Full Unload 04"
                            },
                            {
                                station = "Full Unload 05"
                            },
                            {
                                station = "Full Unload 06"
                            }
                        }
                    },
                    signal = {
                        name = "signal-W",
                        type = "virtual"
                    },
                    stations = {
                        {
                            name = "Full Unload 01",
                            signal = {
                                name = "signal-0",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Full Unload 02",
                            signal = {
                                name = "signal-1",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Full Unload 03",
                            signal = {
                                name = "signal-2",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Full Unload 04",
                            signal = {
                                name = "signal-3",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Full Unload 05",
                            signal = {
                                name = "signal-4",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Full Unload 06",
                            signal = {
                                name = "signal-5",
                                type = "virtual"
                            }
                        }
                    }
                },
                ["Load End"] = {
                    schedule = {
                        current = 1,
                        records = {
                            {
                                station = "Load 01 End"
                            },
                            {
                                station = "Load 02 End"
                            },
                            {
                                station = "Load 03 End"
                            },
                            {
                                station = "Load 04 End"
                            },
                            {
                                station = "Load 05 End"
                            }
                        }
                    },
                    signal = {
                        name = "signal-V",
                        type = "virtual"
                    },
                    stations = {
                        {
                            name = "Load 01 End",
                            signal = {
                                name = "signal-0",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Load 02 End",
                            signal = {
                                name = "signal-1",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Load 03 End",
                            signal = {
                                name = "signal-2",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Load 04 End",
                            signal = {
                                name = "signal-3",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Load 05 End",
                            signal = {
                                name = "signal-4",
                                type = "virtual"
                            }
                        }
                    }
                },
                ["Load Front"] = {
                    schedule = {
                        current = 1,
                        records = {
                            {
                                station = "Load 01 Front"
                            },
                            {
                                station = "Load 02 Front"
                            },
                            {
                                station = "Load 03 Front"
                            },
                            {
                                station = "Load 04 Front"
                            },
                            {
                                station = "Load 05 Front"
                            }
                        }
                    },
                    signal = {
                        name = "signal-U",
                        type = "virtual"
                    },
                    stations = {
                        {
                            name = "Load 01 Front",
                            signal = {
                                name = "signal-0",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Load 02 Front",
                            signal = {
                                name = "signal-1",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Load 03 Front",
                            signal = {
                                name = "signal-2",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Load 04 Front",
                            signal = {
                                name = "signal-3",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Load 05 Front",
                            signal = {
                                name = "signal-4",
                                type = "virtual"
                            }
                        }
                    }
                },
                Switch = {
                    schedule = {
                        current = 1,
                        records = {
                            {
                                station = "Switch Empty Load",
                                wait_conditions = {
                                    {
                                        compare_type = "or",
                                        condition = {
                                            comparator = "=",
                                            constant = 1,
                                            first_signal = {
                                                name = "signal-check",
                                                type = "virtual"
                                            }
                                        },
                                        type = "circuit"
                                    }
                                }
                            },
                            {
                                station = "Dummy Empty Load"
                            },
                            {
                                station = "Switch Empty Unload",
                                wait_conditions = {
                                    {
                                        compare_type = "or",
                                        condition = {
                                            comparator = "=",
                                            constant = 1,
                                            first_signal = {
                                                name = "signal-check",
                                                type = "virtual"
                                            }
                                        },
                                        type = "circuit"
                                    }
                                }
                            },
                            {
                                station = "Dummy Empty Unload"
                            },
                            {
                                station = "Switch Full Load",
                                wait_conditions = {
                                    {
                                        compare_type = "or",
                                        condition = {
                                            comparator = "=",
                                            constant = 1,
                                            first_signal = {
                                                name = "signal-check",
                                                type = "virtual"
                                            }
                                        },
                                        type = "circuit"
                                    }
                                }
                            },
                            {
                                station = "Dummy Full Load"
                            },
                            {
                                station = "Switch Full Unload",
                                wait_conditions = {
                                    {
                                        compare_type = "or",
                                        condition = {
                                            comparator = "=",
                                            constant = 1,
                                            first_signal = {
                                                name = "signal-check",
                                                type = "virtual"
                                            }
                                        },
                                        type = "circuit"
                                    }
                                }
                            },
                            {
                                station = "Dummy Full Unload"
                            }
                        }
                    },
                    signal = {
                        name = "signal-R",
                        type = "virtual"
                    },
                    stations = {
                        {
                            name = "Switch Empty Load",
                            signal = {
                                name = "signal-0",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Dummy Empty Load"
                        },
                        {
                            name = "Switch Empty Unload",
                            signal = {
                                name = "signal-1",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Dummy Empty Unload"
                        },
                        {
                            name = "Switch Full Load",
                            signal = {
                                name = "signal-2",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Dummy Full Load"
                        },
                        {
                            name = "Switch Full Unload",
                            signal = {
                                name = "signal-3",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Dummy Full Unload"
                        }
                    }
                },
                ["Unload End"] = {
                    schedule = {
                        current = 1,
                        records = {
                            {
                                station = "Unload 01 End"
                            },
                            {
                                station = "Unload 02 End"
                            },
                            {
                                station = "Unload 03 End"
                            },
                            {
                                station = "Unload 04 End"
                            },
                            {
                                station = "Unload 05 End"
                            }
                        }
                    },
                    signal = {
                        name = "signal-T",
                        type = "virtual"
                    },
                    stations = {
                        {
                            name = "Unload 01 End",
                            signal = {
                                name = "signal-0",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Unload 02 End",
                            signal = {
                                name = "signal-1",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Unload 03 End",
                            signal = {
                                name = "signal-2",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Unload 04 End",
                            signal = {
                                name = "signal-3",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Unload 05 End",
                            signal = {
                                name = "signal-4",
                                type = "virtual"
                            }
                        }
                    }
                },
                ["Unload Front"] = {
                    schedule = {
                        current = 1,
                        records = {
                            {
                                station = "Unload 01 Front"
                            },
                            {
                                station = "Unload 02 Front"
                            },
                            {
                                station = "Unload 03 Front"
                            },
                            {
                                station = "Unload 04 Front"
                            },
                            {
                                station = "Unload 05 Front"
                            }
                        }
                    },
                    signal = {
                        name = "signal-S",
                        type = "virtual"
                    },
                    stations = {
                        {
                            name = "Unload 01 Front",
                            signal = {
                                name = "signal-0",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Unload 02 Front",
                            signal = {
                                name = "signal-1",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Unload 03 Front",
                            signal = {
                                name = "signal-2",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Unload 04 Front",
                            signal = {
                                name = "signal-3",
                                type = "virtual"
                            }
                        },
                        {
                            name = "Unload 05 Front",
                            signal = {
                                name = "signal-4",
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

    require("__Automatic_Coupling_System__/scripts/events"),

    require("__Simple_Circuit_Trains__/scripts/events"),
    require("__Simple_Circuit_Trains__/scripts/gui"),

    eventsLib
})
