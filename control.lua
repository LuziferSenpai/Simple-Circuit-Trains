local eventHandler = require("__core__/lualib/event_handler")

eventHandler.add_libraries({
    require("__flib__/gui-lite"),

    require("__Simple_Circuit_Trains__/scripts/events"),
    require("__Simple_Circuit_Trains__/scripts/gui")
})
