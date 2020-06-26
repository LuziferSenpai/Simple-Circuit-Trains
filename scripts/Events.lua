require "util"
require "mod-gui"

local player_lib = require "scripts/player"
local definesevents = defines.events

local script_data =
{
    players = {},
    trainsids = {},
    lines =
    {
        number = 0,
        schedules = {},
        names = {},
        chooseelem = {},
        stations = {},
        chooseelemstations = {}
    },
    chooseelemlines =
    {
        fluid = {},
        item = {},
        virtual = {}
    },
    names = {}
}

local checksignal = function( signal )
    if type( signal ) == "table" then
        local name = signal.name
        local signaltype = signal.type

        if game.active_mods["Automatic_Coupling_System"] and ( name == "signal-couple" or name == "signal-decouple" ) then
            return nil
        elseif signaltype == "fluid" and not game.fluid_prototypes[name] then
            return nil
        elseif signaltype == "item" and not game.item_prototypes[name] then
            return nil
        elseif signaltype == "virtual" and not game.virtual_signal_prototypes[name] then
            return nil
        end

        return signal
    else
        return nil
    end
end

local addline = function( add_type, player_id, text, chooseelem, schedule, choosestations, stations )
    if add_type == "addnew" then
        local player = game.players[player_id]

        if script_data.names[text] then
            player.print( { "Circuit.AlreadyExist" } )

            return false
        elseif type( chooseelem ) == "table" then
            if script_data.chooseelemlines[chooseelem.type][chooseelem.name] then
                player.print( { "Circuit.Signalused" } )

                return false
            end
        end
    end

    local lines = script_data.lines
    lines.number = lines.number + 1

    local index = tostring( lines.number )

    lines.schedules[index] = schedule
    lines.names[index] = text
    lines.chooseelem[index] = chooseelem
    lines.chooseelemstations[index] = choosestations or
    {
        fluid = {},
        item = {},
        virtual = {}
    }

    if type ( chooseelem ) == "table" then
        script_data.chooseelemlines[chooseelem.type][chooseelem.name] = index
    end

    script_data.names[text] = index

    local Stations = stations or
    {
        number = 0,
        stations = {},
        chooseelem = {}
    }

    if Stations.number == 0 then
        for _, entry in pairs( schedule.records ) do
            Stations.number = Stations.number + 1

            local index_number = tostring( Stations.number )

            Stations.stations[index_number] = entry.station
            Stations.chooseelem[index_number] = nil
        end
    end

    lines.stations[index] = Stations

    for _, player in pairs( script_data.players ) do
        if player.listbox then
            player.listbox.items = lines.names
        end
    end
end

local PlayerStart = function( player_index )
    if not script_data.players[tostring( player_index )] then
        local player = player_lib.new( game.players[player_index] )
        
        script_data.players[player.index] = player
    end
end

local PlayerLoad = function()
    for _, player in pairs( game.players ) do
        PlayerStart( player.index )
    end
end

local on_gui_click = function( event )
    local name = event.element.name
    
    if name:sub( 1, 12 ) == "SIMPLE_CLICK" then
        local player_id = event.player_index
        local player = game.players[player_id]
        local playermeta = script_data.players[tostring( player_id )]
        local number = name:sub( 14, 15 )

        if number == "01" then
            if playermeta.frame then
                playermeta:clear()
            else
                playermeta:gui( script_data.lines.names )
            end
        elseif number == "02" then
            playermeta:clear()
        elseif number == "03" then
            local selected_index = playermeta.listbox.selected_index

            if selected_index > 0 then
                local index = tostring( selected_index )
                local lines = script_data.lines
                local elem = lines.chooseelem[index]

                if type( elem ) == "table" then
                    script_data.chooseelemlines[elem.type][elem.name] = nil
                end

                script_data.names[lines.names[index]] = nil

                lines.schedules[index] = nil
                lines.names[index] = nil
                lines.chooseelem[index] = nil
                lines.stations[index] = nil
                lines.chooseelemstations[index] = nil

                script_data.lines =
                {
                    number = 0,
                    schedules = {},
                    names = {},
                    chooseelem = {},
                    stations = {},
                    chooseelemstations = {}
                }

                local schedules = lines.schedules

                if next( schedules ) then
                    for entry, schedule in pairs( schedules ) do
                        addline( "", player_id, lines.names[entry], lines.chooseelem[entry], schedule, lines.chooseelemstations[entry], lines.stations[entry] )
                    end

                    for _, player in pairs( script_data.players ) do
                        local listbox = player.listbox
                        if listbox then
                            listbox.items = script_data.lines.names
                            
                            selected_index = listbox.selected_index

                            if selected_index == 0 then
                                player.linechooseelem.elem_value = nil

                                player:update_station_frame( {} )
                            else
                                index = tostring( selected_index )
                                
                                player.linechooseelem.elem_value = script_data.lines.chooseelem[index]

                                player:update_station_frame( script_data.lines.stations[index] )
                            end
                        end
                    end
                else
                    for _, player in pairs( script_data.players ) do
                        if player.listbox then
                            player.listbox.items = {}
                            player.linechooseelem.elem_value = nil
                            player:update_station_frame( {} )
                        end
                    end
                end
            else
                player.print( { "Circuit.NoLineSelected" } )
            end
        elseif number == "04" then
            local selected_index = playermeta.listbox.selected_index

            if selected_index > 0 then
                local entity = player.opened

                if player.opened_gui_type == defines.gui_type.entity and entity.type == "locomotive" then
                    local entityschedule = entity.train.schedule
                    
                    if type( entityschedule ) == "table" then
                        local index = tostring( selected_index )
                        local schedule = script_data.lines.schedules[index]
                        local entityschedulerecords = entityschedule.records
                        local schedulerecords = schedule.records

                        if #entityschedulerecords > #schedulerecords then
                            local comparerecords = {}

                            for i = 1, #schedulerecords do
                                comparerecords[i] = entityschedulerecords[i]
                            end

                            if util.table.compare( schedulerecords, comparerecords ) then
                                local stations = script_data.lines.stations[index]
                                
                                for i = 1 + #schedulerecords, #entityschedulerecords do
                                    stations.number = stations.number + 1

                                    local index_number = tostring( stations.number )

                                    stations.stations[index_number] = entityschedulerecords[i].station
                                    stations.chooseelem[index_number] = nil
                                end

                                for _, Player in pairs( script_data.players ) do
                                    if Player.frame then
                                        local playerselected = Player.listbox.selected_index

                                        if playerselected == selected_index then
                                            Player:update_station_frame( stations )
                                        end
                                    end
                                end
                            else
                                player.print( { "Circuit.NotTheSameSchedule" } )
                            end
                        else
                            player.print( { "Circuit.NotTheSameSchedule" } )
                        end
                    else
                        player.print( { "Circuit.NoSchedule" } )
                    end
                else
                    player.print( { "Circuit.NoTrainOpen" } )
                end
            end
        elseif number == "05" then
            local text = playermeta.textfield.text

            if #text > 0 then
                local entity = player.opened

                if player.opened_gui_type == defines.gui_type.entity and entity.type == "locomotive" then
                    local schedule = entity.train.schedule

                    if type ( schedule ) == "table" then
                        local boolean = addline( "addnew", player_id, text, checksignal( playermeta.addchooseelem.elem_value ), schedule )

                        if boolean then
                            playermeta.textfield.text = ""
                            playermeta.addchooseelem.elem_value = nil
                        end
                    else
                        player.print( { "Circuit.NoSchedule" } )
                    end
                else
                    player.print( { "Circuit.NoTrainOpen" } )
                end
            else
                player.print( { "Circuit.NoName" } )
            end
        elseif number == "06" then
            playermeta:toggle_editingfield( name:sub( 17 ) )
        elseif number == "07" then
            local index = name:sub( 17 )
            local number = tonumber( index )
            local index_number = tostring( playermeta.listbox.selected_index )
            local lines = script_data.lines
            local linesstations = lines.stations[index_number]
            local new_data =
            {
                number = 0,
                chooseelem = {},
                stations = {}
            }

            linesstations.chooseelem[index] = nil
            linesstations.stations[index] = nil

            local stations = linesstations.stations

            for entry, station in pairs( stations ) do
                new_data.number = new_data.number + 1
                new_data.stations[tostring( new_data.number )] = station
                new_data.chooseelem[tostring( new_data.number )] = linesstations.chooseelem[entry]
            end

            lines.stations[index_number] = new_data

            table.remove( lines.schedules[index_number].records, number )

            for _, playermetatable in pairs( script_data.players ) do
                if playermetatable.listbox and playermetatable.listbox.selected_index == playermeta.listbox.selected_index then
                    playermetatable:update_station_frame( script_data.lines.stations[index_number] )
                end
            end
        end
    end
end

local on_gui_confirmed = function( event )
    local element = event.element
    local name = element.name

    if name:sub( 1, 17 ) == "SIMPLE_CONFIRM_01" then
        local text = element.text
        if #text > 0 then
            local index = name:sub( 19 )
            local number = tonumber( index )
            local playermeta = script_data.players[tostring( event.player_index )]
            local index_number = tostring( playermeta.listbox.selected_index )

            script_data.lines.schedules[index_number].records[number].station = text
            script_data.lines.stations[index_number].stations[index] = text

            for _, playermetatable in pairs( script_data.players ) do
                if playermetatable.listbox and playermetatable.listbox.selected_index == playermeta.listbox.selected_index then
                    playermetatable:update_station_frame( script_data.lines.stations[index_number] )
                end
            end
        end
    end
end

local on_gui_elem_changed = function( event )
    local element = event.element
    local name = element.name

    if name:sub( 1, 11 ) == "SIMPLE_ELEM" then
        local player_id = event.player_index
        local playermeta = script_data.players[tostring( player_id )]
        local number = name:sub( 13, 14 )

        if number == "01" then
            local selected_index = playermeta.listbox.selected_index

            if selected_index > 0 then
                local index = tostring( selected_index )
                local lines = script_data.lines
                local elem_value = checksignal( element.elem_value )
                local elem = lines.chooseelem[index]

                if type( elem_value ) == "table" then
                    if type( elem ) == "table" and util.table.compare( elem_value, elem ) then return end
                    
                    if script_data.chooseelemlines[elem_value.type][elem_value.name] then
                        if type( elem ) == "table" then
                            element.elem_value = elem
                        else
                            element.elem_value = nil
                        end
                    else
                        if type( elem ) == "table" then
                            script_data.chooseelemlines[elem.type][elem.name] = nil
                        end

                        lines.chooseelem[index] = elem_value
                        script_data.chooseelemlines[elem_value.type][elem_value.name] = index
                    end
                else
                    if type( elem ) == "table" then
                        lines.chooseelem[index] = nil
                        script_data.chooseelemlines[elem.type][elem.name] = nil
                    end
                end
            else
                element.elem_value = nil
            end
        elseif number == "02" then
            local index = name:sub( 16 )
            local index_number = tostring( playermeta.listbox.selected_index )
            local lines = script_data.lines
            local elem_value = checksignal( element.elem_value )
            local elem = lines.stations[index_number].chooseelem[index]

            if type( elem_value ) == "table" then
                if type( elem ) == "table" and util.table.compare( elem_value, elem ) then return end
                
                if lines.chooseelemstations[index_number][elem_value.type][elem_value.name] then
                    if type( elem ) == "table" then
                        element.elem_value = elem
                    else
                        element.elem_value = nil
                    end
                else
                    if type( elem ) == "table" then
                        lines.chooseelemstations[index_number][elem.type][elem.name] = nil
                    end

                    lines.stations[index_number].chooseelem[index] = elem_value
                    lines.chooseelemstations[index_number][elem_value.type][elem_value.name] = index

                    for _, playermetatable in pairs( script_data.players ) do
                        if playermetatable.listbox and playermetatable.listbox.selected_index == playermeta.listbox.selected_index then
                            playermetatable:update_station_frame( script_data.lines.stations[index_number] )
                        end
                    end
                end
            else
                if type( elem ) == "table" then
                    lines.stations[index_number].chooseelem[index] = nil
                    lines.chooseelemstations[index_number][elem.type][elem.name] = nil
                end
            end
        end
    end
end

local on_gui_location_changed = function( event )
    local playermeta = script_data.players[tostring( event.player_index )]
    local element = event.element
    if playermeta.frame and element.index == playermeta.frame.index then
        playermeta.location = element.location
    end
end

local on_gui_selection_state_changed = function( event )
    local element = event.element

    if element.name == "SIMPLE_DROP_01" then
        local playermeta = script_data.players[tostring( event.player_index )]
        local index = tostring( element.selected_index )
        local lines = script_data.lines
        local elem = lines.chooseelem[index]

        if type( elem ) == "table" then
            playermeta.linechooseelem.elem_value = elem
        else
            playermeta.linechooseelem.elem_value = nil
        end

        playermeta:update_station_frame( lines.stations[index] )
    end
end

local on_player_created = function( event )
    PlayerStart( event.player_index )
end

local on_player_removed = function( event )
    script_data.players[tostring( event.player_index )] = nil
end

local on_train_changed_state = function( event )
    local train = event.train
    local statedefines = defines.train_state.wait_station
    local defineswire = { red = defines.wire_type.red, green = defines.wire_type.green }
    
    if train.state == statedefines then
        local station = train.station

        if type ( station ) == "table" then
            local conditions = { station = station, circuit = false }

            if station.get_circuit_network( defineswire.red ) and station.get_circuit_network( defineswire.green ) then
                conditions.circuit = true
            end

            if game.active_mods["Automatic_Coupling_System"] then
                local check = remote.call( "Couple", "Check", train )
                
                if check then
                    conditions.couple = true
                end
            end

            script_data.trainsids[train.id] = conditions
        end
    elseif event.old_state == statedefines and script_data.trainsids[train.id] then
        local data = script_data.trainsids[train.id]
        local station = data.station

        script_data.trainsids[train.id] = nil

        if not ( station and station.valid ) then return end
        
        if data.circuit then
            local red = station.get_circuit_network( defineswire.red )
            local green = station.get_circuit_network( defineswire.green )

            if red and green then
                train.manual_mode = true

                local linehighestsignal = { signal = nil, value = 0, lineindex = "" }
                local signal = {}
                local value = 0
                local chooseelemlines = script_data.chooseelemlines

                for signaltype, signaltable in pairs( chooseelemlines ) do
                    for name, lineindex in pairs( signaltable ) do
                        signal = { type = signaltype, name = name }
                        value = red.get_signal( signal )

                        if value > linehighestsignal.value then
                            linehighestsignal = { signal = signal, value = value, lineindex = lineindex }
                        end
                    end
                end

                if #linehighestsignal.lineindex > 0 then
                    local lineindex = linehighestsignal.lineindex
                    local stationghighestsignal = { signal = nil, value = 0, stationindex = "" }
                    local chooseelemstations = script_data.lines.chooseelemstations[lineindex]

                    for signaltype, signaltable in pairs( chooseelemstations ) do
                        for name, stationindex in pairs( signaltable ) do
                            signal = { type = signaltype, name = name }
                            value = green.get_signal( signal )

                            if value > stationghighestsignal.value then
                                stationghighestsignal = { signal = signal, value = value, stationindex = stationindex }
                            end
                        end
                    end

                    if #stationghighestsignal.stationindex > 0 then
                        train.schedule = { current = tonumber( stationghighestsignal.stationindex ), records = script_data.lines.schedules[linehighestsignal.lineindex].records }
                    end
                end

                train.manual_mode = false
            end
        end

        if data.couple and game.active_mods["Automatic_Coupling_System"] then
            remote.call( "Couple", "Couple", train )
        end
    end
end

local on_train_created = function( event )
    if script_data.trainsids[event.old_train_id_1] then
        script_data.trainsids[event.old_train_id_1] = nil
    end

    if script_data.trainsids[event.old_train_id_2] then
        script_data.trainsids[event.old_train_id_2] = nil
    end
end

local lib = {}

lib.events =
{
    [definesevents.on_gui_click] = on_gui_click,
    [definesevents.on_gui_confirmed] = on_gui_confirmed,
    [definesevents.on_gui_elem_changed] = on_gui_elem_changed,
    [definesevents.on_gui_location_changed] = on_gui_location_changed,
    [definesevents.on_gui_selection_state_changed] = on_gui_selection_state_changed,
    [definesevents.on_player_created] = on_player_created,
    [definesevents.on_player_removed] = on_player_removed,
    [definesevents.on_train_changed_state] = on_train_changed_state,
    [definesevents.on_train_created] = on_train_created
}

lib.add_remote_interface = function()
	remote.add_interface
	(
		"LineName",
		{
			Change = function( player_id, text )
                local playermeta = script_data.players[tostring( player_id )]
                
                if playermeta.textfield then
                    playermeta.textfield.text = text

                    return false
                else
                    return true
                end
			end
		}
	)
end

lib.on_init = function()
    global.script_data = global.script_data or script_data

    PlayerLoad()
end

lib.on_load = function()
    script_data = global.script_data or script_data

    for _, player in pairs( script_data.players ) do
        setmetatable( player, player_lib.metatable )
    end
end

lib.on_configuration_changed = function( event )
    global.script_data = global.script_data or script_data

    PlayerLoad()

    local chooseelemlines = script_data.chooseelemlines
    local lines = script_data.lines
    
    for signalname, lineindex in pairs( chooseelemlines.fluid ) do
        if not game.fluid_prototypes[signalname] then
            lines.chooseelem[lineindex] = nil
            chooseelemlines.fluid[signalname] = nil
        end
    end

    for signalname, lineindex in pairs( chooseelemlines.item ) do
        if not game.item_prototypes[signalname] then
            lines.chooseelem[lineindex] = nil
            chooseelemlines.item[signalname] = nil
        end
    end

    for signalname, lineindex in pairs( chooseelemlines.virtual ) do
        if not game.virtual_signal_prototypes[signalname] then
            lines.chooseelem[lineindex] = nil
            chooseelemlines.virtual[signalname] = nil
        end
    end

    for entry, datatable in pairs( lines.chooseelemstations ) do
        local stations = lines.stations

        for signalname, lineindex in pairs( datatable.fluid ) do
            if not game.fluid_prototypes[signalname] then
                stations[entry].chooseelem[lineindex] = nil
                lines.chooseelemstations.fluid[signalname] = nil
            end
        end

        for signalname, lineindex in pairs( datatable.item ) do
            if not game.item_prototypes[signalname] then
                stations[entry].chooseelem[lineindex] = nil
                lines.chooseelemstations.item[signalname] = nil
            end
        end

        for signalname, lineindex in pairs( datatable.virtual ) do
            if not game.virtual_signal_prototypes[signalname] then
                stations[entry].chooseelem[lineindex] = nil
                lines.chooseelemstations.virtual[signalname] = nil
            end
        end
    end

    for _, player in pairs( script_data.players ) do
        if player.frame then
            player:clear()
        end
    end

    local changes = event.mod_changes and event.mod_changes["Simple_Circuit_Trains"] or {}

    if next( changes ) then
        local oldchanges = changes.old_version
        if oldchanges and changes.new_version then
            if oldchanges == "0.2.2" then
                for _, player in pairs( game.players ) do
                    local id = player.index
                    script_data.players[tostring( id )].location = global.Position[id] or { x = 5, y = 85 * player.display_scale }
                    
                    if next( global.GUIS[id] ) then
                        global.GUIS[id].A["01"].destroy()
                    end

                    mod_gui.get_button_flow( player ).CircuitButton.destroy()
                end

                script_data.trainsids = global.TrainsID or {}

                local lines = global.Lines or { Number = 0 }

                if lines.Number > 0 then
                    local chooseelem = lines.ChooseElem
                    local chooseelemstations = lines.ChooseElemStations
                    local linenames = lines.LineNames
                    local schedules = lines.Schedules
                    local stations = lines.Stations
                    
                    for _, entrytable in pairs( stations ) do
                        entrytable.stations = {}
                        entrytable.chooseelem = {}

                        for i = 1, entrytable.Number do
                            local index = string.format( "%02d", i )
                            local index_number = tostring( i )
                            entrytable.stations[index_number] = entrytable.Stations[index]
                            entrytable.chooseelem[index_number] = entrytable.ChooseElem[index]
                        end

                        entrytable.Stations = nil
                        entrytable.ChooseElem = nil
                        entrytable.number = entrytable.Number
                        entrytable.Number = nil
                    end

                    for entry, Station in pairs( stations ) do
                        addline( "", nil, linenames[entry], chooseelem[entry], schedules[entry], chooseelemstations[entry], Station )
                    end

                    global.ChooseElemLines = nil
                    global.GUIS = nil
                    global.LineNames = nil
                    global.Lines = nil
                    global.Position = nil
                    global.TrainsID = nil
                end
            end
        end
    end
end

return lib