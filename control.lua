require "mod-gui"

local Functions = require "functions"
local de = defines.events

script.on_init( function()
	Functions.Globals()
	Functions.Players()
end )

script.on_configuration_changed( function( event )
	local changes = event.mod_changes or {}

	if next( changes ) then
		local circuitchanges = changes["Simple_Circuit_Trains"] or {}

		if next( circuitchanges ) then
			local oldversion = circuitchanges.old_version

			if oldversion and circuitchanges.new_version then
				if oldversion <= "0.1.0" then					
					for _, p in pairs( game.players ) do
						local mod_guibutton = mod_gui.get_button_flow( p )
						local mod_guiframe = mod_gui.get_frame_flow( p )

						if mod_guibutton.CircuitTrainsGUIButton then
							mod_guibutton.CircuitTrainsGUIButton.destroy()
						end

						if mod_guiframe.CircuitTrainsGUI then
							mod_guiframe.CircuitTrainsGUI.destroy()
						end
					end

					local ScheduleLines = global.ScheduleLines
					local ScheduleLinesSignals = global.ScheduleLinesSignals
					local TrainsID = global.TrainsID

					global.Lines = nil
					global.ScheduleLines = nil
					global.ScheduleLinesSignals = nil
					global.TrainsID = nil

					Functions.Globals()
					Functions.Players()

					if next( TrainsID ) then
						for id, data in pairs( TrainsID ) do
							global.TrainsID[id] = { station = data.s, circuit = data.st }

							if data.c then
								global.TrainsID[id].couple = data.c
							end
						end
					end
					
					if next( ScheduleLines ) then
						for line, data in pairs( ScheduleLines ) do
							local stations =
							{
								Number = 0,
								Stations = {},
								ChooseElem = {}
							}
							local choosestations =
							{
								fluid = {},
								item = {},
								virtual = {}
							}
							for _, entry in pairs( ScheduleLinesSignals[line] ) do
								stations.Number = stations.Number + 1

								if stations.Number < 100 then
									local index_number = Functions.Format2Digit( stations.Number )

									stations.Stations[index_number] = entry.st
									stations.ChooseElem[index_number] = entry.s

									local signal = entry.s
									if type( signal ) == "table" then
										choosestations[signal.type][signal.name] = index_number
									end
								end
							end
							Functions.AddLines( "", nil, line, Functions.CheckSignal( data.s ) , data.sc, choosestations, stations )
						end
					end
				end

				if oldversion <= "0.2.1" then
					for _, p in pairs( game.players ) do
						if next( global.GUIS[p.index] ) then
							global.GUIS[p.index].A["01"].destroy()
							global.GUIS[p.index] = {}
						end
					end
				end
			end
		end
	end
end )

script.on_event( de.on_gui_click, function( event )
	local element = event.element
	local name = element.name
	local guitype = element.type

	if name == nil then return end
	if not ( guitype == "button" or guitype == "sprite-button" ) then return end
	if not name:find( "Circuit" ) then return end

	local player_id = event.player_index

	if name == "CircuitButton" then
		Functions.MainGUIToggle( player_id )
	elseif next( global.GUIS[player_id] ) then
		local GUI = global.GUIS[player_id]

		if not GUI.A["01"].visible then return end

		local player = game.players[player_id]

		--A
		GUI = GUI.A

		if name == "CircuitButtonAGUI01" then
			GUI = GUI["03"]

			local text = GUI["11"].text

			if text:len() > 0 then
				local entity = player.opened
				if player.opened_gui_type == defines.gui_type.entity and entity.type == "locomotive" then
					local schedule = entity.train.schedule
	
					if type( schedule ) == "table" then
						local boolean = Functions.AddLines( "addnew", player_id, text, Functions.CheckSignal( GUI["12"].elem_value ), Functions.ClearSchedule( schedule ) )
								
						if boolean then
							Functions.MainGUIAddToggle( player_id )
							GUI["11"].text = ""
							GUI["12"].elem_value = nil
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
		elseif name == "CircuitSpriteButtonAGUI01" then
			GUI["01"].visible = false
		elseif name == "CircuitSpriteButtonAGUI02" then
			Functions.MainGUIAddToggle( player_id )
		elseif name == "CircuitSpriteButtonAGUI03" then
			GUI = GUI["03"]

			local selected_index = GUI["06"].selected_index

			if selected_index > 0 then
				local index_number = Functions.Format3Digit( selected_index )
				
				local Lines = global.Lines
				local elem = Lines.ChooseElem[index_number]

				if type( elem ) == "table" then
					global.ChooseElemLines[elem.type][elem.name] = nil
				end

				global.Lines.ChooseElemStations[index_number] = nil
				global.LineNames[Lines.LineNames[index_number]] = nil

				Lines.Schedules[index_number] = nil
				Lines.LineNames[index_number] = nil
				Lines.ChooseElem[index_number] = nil
				Lines.Stations[index_number] = nil

				global.Lines =
				{
					Number = 0,
					Schedules = {},
					LineNames = {},
					ChooseElem = {},
					Stations = {},
					ChooseElemStations = {}
				}

				local Schedules = Lines.Schedules

				if next( Schedules ) then
					for entry, Schedule in pairs( Schedules ) do
						Functions.AddLines( "", player_id, Lines.LineNames[entry], Lines.ChooseElem[entry], Schedule, Lines.ChooseElemStations[entry], Lines.Stations[entry] )
					end

					GUI = global.GUIS[player_id].A
					selected_index = GUI["03"]["06"].selected_index

					if selected_index == 0 then
						GUI["03"]["07"].elem_value = nil
						global.GUIS[player_id].B["01"].destroy()
					else
						GUI["03"]["07"].elem_value = global.Lines.ChooseElem[Functions.Format3Digit( selected_index )]

						Functions.ListGUI( GUI["01"], player_id, index_number )
					end
				else
					GUI["06"].items = {}
					GUI["07"].elem_value = nil
					global.GUIS[player_id].B["01"].destroy()
				end

				game.write_file( "test.txt", serpent.block( global.Lines ) )
			else
				player.print( { "Circuit.NoLineSelected" } )
			end
		end
	end
end )

script.on_event( { de.on_gui_elem_changed, de.on_gui_selection_state_changed }, function( event )
	local player_id = event.player_index

	if next( global.GUIS[player_id] ) then
		local GUI = global.GUIS[player_id]

		if not GUI.A["01"].visible then return end

		local element = event.element
		local name = element.name

		if name == nil then return end

		if not name:find( "Circuit" ) then return end

		if name == "CircuitChooseElemAGUI01" then
			local selected_index = GUI.A["03"]["06"].selected_index

			if selected_index > 0 then
				local index_number = Functions.Format3Digit( selected_index )
				local elem_value = Functions.CheckSignal( element.elem_value )
				local elem = global.Lines.ChooseElem[index_number]

				if type( elem_value ) == "table" then
					if not global.ChooseElemLines[elem_value.type][elem_value.name] then
						if type( elem ) == "table" then
							global.ChooseElemLines[elem.type][elem.name] = nil
						end

						global.Lines.ChooseElem[index_number] = elem_value
						global.ChooseElemLines[elem_value.type][elem_value.name] = index_number
					else
						if type( elem ) == "table" then
							if type( Functions.CheckSignal( elem ) ) == "table" then
								element.elem_value = elem
							else
								Functions.ClearLineSignal( elem, index_number )
								
								element.elem_value = nil
							end
						else
							element.elem_value = nil
						end
					end
				else
					if type( elem ) == "table" then
						Functions.ClearLineSignal( elem, index_number )
					end
				end
			else
				element.elem_value = nil
			end
		elseif name:find( "ListBGUI" ) then
			local elem_value = Functions.CheckSignal( element.elem_value )
			local index_number = Functions.Format3Digit( GUI.A["03"]["06"].selected_index )
			local index = name:gsub( "CircuitChooseElemListBGUI", "" )
			local elem = global.Lines.Stations[index_number].ChooseElem[index]

			if type( elem_value ) == "table" then
				if not global.Lines.ChooseElemStations[index_number][elem_value.type][elem_value.name] then
					if type( elem ) == "table" then
						global.Lines.ChooseElemStations[index_number][elem.type][elem.name] = nil
					end

					global.Lines.Stations[index_number].ChooseElem[index] = elem_value
					global.Lines.ChooseElemStations[index_number][elem_value.type][elem_value.name] = index
				else
					if type( elem ) == "table" then
						if type( Functions.CheckSignal( elem ) ) == "table" then
							element.elem_value = elem
						else
							Functions.ClearStationSignal( elem, index, index_number )

							element.elem_value = nil
						end
					else
						element.elem_value = nil
					end
				end
			else
				if type( elem ) == "table" then
					Functions.ClearStationSignal( elem, index, index_number )
				end
			end
		elseif name == "CircuitDropDownAGUI01" then
			local index_number = Functions.Format3Digit( element.selected_index )
			local elem_value = Functions.CheckSignal( global.Lines.ChooseElem[index_number] )
			if type( elem_value ) == "table" then
				GUI.A["03"]["07"].elem_value = elem_value
			else
				GUI.A["03"]["07"].elem_value = nil

				if type( elem_value ) == "table" then
					global.Lines.ChooseElem[index_number] = nil
					global.ChooseElemLines[elem_value.type][elem_value.name] = nil
				end
			end

			Functions.ListGUI( GUI.A["01"], player_id, index_number )
		end
	end
end )

script.on_event( de.on_gui_location_changed, function( event )
	local player_id = event.player_index

	if next( global.GUIS[player_id] ) then
		local element = event.element

		if element.name == "CircuitFrameAGUI01" then
			global.Position[player_id] = element.location
		end
	end
end )

script.on_event( de.on_player_created, function( event )
	Functions.PlayerStart( event.player_index )
end )

script.on_event( de.on_train_changed_state, function( event )
	local train = event.train
	local statedefines = defines.train_state.wait_station
	local defineswire =
	{
		red = defines.wire_type.red,
		green = defines.wire_type.green
	}

	if train.state == statedefines then
		local station = train.station

		if type( station ) == "table" then
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

			global.TrainsID[train.id] = conditions
		end
	elseif event.old_state == statedefines and global.TrainsID[train.id] then
		local data = global.TrainsID[train.id]
		local station = data.station

		global.TrainsID[train.id] = nil

		if not ( station and station.valid ) then return end

		if data.circuit then
			train.manual_mode = true

			local red = station.get_circuit_network( defineswire.red )
			local green = station.get_circuit_network( defineswire.green )
			local linesignals = {}
			local linehighestsignal = { signal = nil, value = 0, line = "" }
			local signal = {}
			local value = 0
			local ChooseElemLines = global.ChooseElemLines
			
			for signaltype, signaltable in pairs( ChooseElemLines ) do
				for name, index in pairs( signaltable ) do
					signal = Functions.CheckSignal( { type = signaltype, name = name } )

					if type( signal ) == "table" then
						if red.get_signal( signal ) > 0 then
							linesignals[index] = signal
						end
					else
						Functions.ClearLineSignal( { type = signaltype, name = name }, index )
					end
				end
			end

			for line, Signal in pairs( linesignals ) do
				value = red.get_signal( Signal )
				
				if value > linehighestsignal.value then
					linehighestsignal = { signal = Signal, value = value, line = line }
				end
			end

			if linehighestsignal.line:len() > 0 then
				local line = linehighestsignal.line
				local stationsignals = {}
				local stationghighestsignal = { signal = nil, value = 0, station = "" }
				local ChooseElemStations = global.Lines.ChooseElemStations[line]

				for signaltype, signaltable in pairs( ChooseElemStations ) do
					for name, index in pairs( signaltable ) do
						signal = Functions.CheckSignal( { type = signaltype, name = name } )

						if type( signal ) == "table" then
							if green.get_signal( signal ) > 0 then
								stationsignals[index] = signal
							end
						else
							Functions.ClearStationSignal( { type = signaltype, name = name }, index, line )
						end
					end
				end

				for station, Signal in pairs( stationsignals ) do
					value = green.get_signal( Signal )
					
					if value > stationghighestsignal.value then
						stationghighestsignal = { signal = Signal, value = value, station = station }
					end
				end
				
				if stationghighestsignal.station:len() > 0 then
					train.schedule = { current = tonumber( stationghighestsignal.station ), records = global.Lines.Schedules[linehighestsignal.line].records }
				end
			end

			train.manual_mode = false
		end

		if data.couple and game.active_mods["Automatic_Coupling_System"] then
			local check = remote.call( "Couple", "Couple", train )
		end
	end
end )

remote.add_interface
(
	"LineName",
	{
		Change = function( player_id, text )
			local GUI = global.GUIS[player_id]

			if next( GUI ) and GUI.A["01"].visible and GUI.A["02"]["05"].visible then
				GUI.A["03"]["11"].text = text

				return false
			else
				return true
			end
		end
	}
)