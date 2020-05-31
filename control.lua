if script.active_mods["debugadapter"] then require('__debugadapter__/debugadapter.lua') end

local handler = require "event_handler"

handler.add_lib( require "scripts/Events" )