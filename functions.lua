local Functions = {}

Functions.Globals = function()
	global.Position = global.Position or {}
	global.GUIS = global.GUIS or {}
	global.TrainsID = global.TrainsID or {}
	global.Lines = global.Lines or
	{
		Number = 0,
		Schedules = {},
		LineNames = {},
		ChooseElem = {},
		Stations = {},
		ChooseElemStations = {}
	}
	global.ChooseElemLines = global.ChooseElemLines or
	{
		fluid = {},
		item = {},
		virtual = {}
	}
	global.LineNames = global.LineNames or {}
end

Functions.Players = function()
	for _, p in pairs( game.players ) do
		Functions.PlayerStart( p.index )
	end
end

Functions.MainGUI = function( parent, player_id )
	local A = {}

	A["01"] = Functions.AddFrame( parent, "CircuitFrameAGUI01", "dialog_frame" )
	A["02"] =
	{
		["01"] = Functions.AddFlow( A["01"], "CircuitFlowAGUI01", "horizontal", "circuittitlebarfow" ),
		["02"] = Functions.AddLine( A["01"], "CircuitLineAGUI01", "horizontal" ),
		["03"] = Functions.AddFlow( A["01"], "CircuitFlowAGUI02", "horizontal", "circuittitlebarfow" ),
		["04"] = Functions.AddLine( A["01"], "CircuitLineAGUI02", "horizontal" ),
		["05"] = Functions.AddFlow( A["01"], "CircuitFlowAGUI03", "horizontal" )
	}
	A["03"] =
	{
		["01"] = Functions.AddLabel( A["02"]["01"], "CircuitLabelAGUI01", { "Circuit.Title"}, "frame_title" ),
		["02"] = Functions.AddWidget( A["02"]["01"], "CircuitWidgetAGUI01", "draggable_space_header" ),
		["03"] = Functions.AddSpriteButton( A["02"]["01"], "CircuitSpriteButtonAGUI01", "utility/close_white", "close_button" ),
		
		["04"] = Functions.AddLabel( A["02"]["03"], "CircuitLabelAGUI02", { "Circuit.LineTitle" }, "caption_label" ),
		["05"] = Functions.AddWidget( A["02"]["03"], "CircuitWidgetAGUI02" ),
		["06"] = Functions.AddDropDown( A["02"]["03"], "CircuitDropDownAGUI01", global.Lines.LineNames ),
		["07"] = Functions.AddChooseElemButton( A["02"]["03"], "CircuitChooseElemAGUI01", "circuitchooselem" ),
		["08"] = Functions.AddSpriteButton( A["02"]["03"], "CircuitSpriteButtonAGUI02", "Senpais-plus", "circuitclosebutton" ),
		["09"] = Functions.AddSpriteButton( A["02"]["03"], "CircuitSpriteButtonAGUI03", "utility/remove", "circuitclosebutton" ),
		
		["10"] = Functions.AddLabel( A["02"]["05"], "CircuitLabelAGUI03", { "Circuit.Name" } ),
		["11"] = Functions.AddTextField( A["02"]["05"], "CircuitTextFieldAGUI01", "" ),
		["12"] = Functions.AddChooseElemButton( A["02"]["05"], "CircuitChooseElemAGUI02", "circuitchooselem" ),
		["13"] = Functions.AddWidget( A["02"]["05"], "CircuitWidgetAGUI03" ),
		["14"] = Functions.AddButton( A["02"]["05"], "CircuitButtonAGUI01", { "Circuit.AddLine" } )
	}

	A["01"].location = global.Position[player_id]
	
	A["02"]["02"].style.top_margin = 4
	A["02"]["02"].style.bottom_margin = 8
	A["02"]["03"].style.bottom_margin = 8
	A["02"]["04"].style.top_margin = 0
	A["02"]["04"].style.bottom_margin = 8
	A["02"]["04"].visible = false
	A["02"]["05"].style.horizontally_stretchable = true
	A["02"]["05"].style.vertical_align = "center"
	A["02"]["05"].style.horizontal_align = "left"
	A["02"]["05"].style.horizontal_spacing = 6
	A["02"]["05"].style.bottom_margin = 8
	A["02"]["05"].visible = false

	A["03"]["02"].style.horizontally_stretchable = true
	A["03"]["02"].style.natural_height = 24
	A["03"]["02"].style.minimal_width = 24
	A["03"]["02"].drag_target = A["01"]
	A["03"]["05"].style.horizontally_stretchable = true
	A["03"]["05"].style.minimal_width = 24
	A["03"]["11"].style.width = 110
	A["03"]["13"].style.horizontally_stretchable = true

	global.GUIS[player_id].A = A
end

Functions.MainGUIToggle = function( player_id )
	local player = game.players[player_id]
	local screen = player.gui.screen

	if screen.CircuitFrameAGUI01 then
		local GUI = global.GUIS[player_id].A["01"]
		GUI.visible = not GUI.visible
	else
		Functions.MainGUI( screen, player_id )
	end
end

Functions.MainGUIAddToggle = function( player_id )
	local GUI = global.GUIS[player_id].A["02"]
	GUI["04"].visible = not GUI["04"].visible
	GUI["05"].visible = not GUI["05"].visible
end

Functions.ListGUI = function( parent, player_id, index_number )
	if type( global.GUIS[player_id].B ) == "table" then global.GUIS[player_id].B["01"].destroy() end
	
	local B = {}

	B["01"] = Functions.AddScrollPane( parent, "CircuitScrollPaneBGUI01", "vertical" )
	B["02"] = Functions.AddFrame( B["01"], "CircuitFrameBGUI01", "image_frame" )
	B["03"] =
	{
		["01"] = Functions.AddFlow( B["02"], "CircuitFlowBGUI01", "horizontal", "circuitlistflow" ),
		["02"] = Functions.AddLine( B["02"], "CircuitLineBGUI01", "horizontal" )
	}
	B["04"] =
	{
		["01"] = Functions.AddLabel( B["03"]["01"], "CircuitLabelBGUI01", { "Circuit.Stations" } ),
		["02"] = Functions.AddWidget( B["03"]["01"], "CircuitWidgetBGUI01" ),
		["03"] = Functions.AddLabel( B["03"]["01"], "CircuitLabelBGUI02", { "Circuit.Signals" } )
	}
	B["05"] = {}
	B["06"] = {}
	B["07"] = {}
	B["08"] = {}
	B["09"] = {}

	B["01"].style.maximal_height = 350

	B["02"].style.left_padding = 4
	B["02"].style.right_padding = 8
	B["02"].style.bottom_padding = 4
	B["02"].style.top_padding = 4
	B["03"]["01"].style.vertical_align = "center"

	B["04"]["02"].style.horizontally_stretchable = true
	B["04"]["02"].style.minimal_width = 30

	local Stations = global.Lines.Stations[index_number]
	local stations = Stations.Stations

	for index, station in pairs( stations ) do
		B["05"][index] = Functions.AddFlow( B["02"], "CircuitFlowListBGUI" .. index, "horizontal", "circuitlistflow" )
		B["06"][index] = Functions.AddLabel( B["05"][index], "CircuitLabelListBGUI" .. index, station )
		B["07"][index] = Functions.AddWidget( B["05"][index], "CircuitWidgetListBGUI" .. index )
		B["08"][index] = Functions.AddChooseElemButton( B["05"][index], "CircuitChooseElemListBGUI" .. index, "circuitchooselem" )
		if type( stations[Functions.Format2Digit( tonumber( index ) + 1 ) ] ) == "string" then
			B["09"][index] = Functions.AddLine( B["02"], "CircuitLineListBGUI" .. index, "horizontal" )
		end

		B["05"][index].style.vertical_align = "center"
		B["06"][index].style.maximal_width = 400
		B["06"][index].style.single_line = false
		B["07"][index].style.horizontally_stretchable = true
		B["07"][index].style.minimal_width = 30
		B["08"][index].elem_value = Stations.ChooseElem[index]
	end

	global.GUIS[player_id].B = B
end

--Player Data creation
Functions.PlayerStart = function( player_id )
	local player = game.players[player_id]
	local button_flow = mod_gui.get_button_flow( player )

	if not button_flow.CircuitButton then
		local b = Functions.AddSpriteButton( button_flow, "CircuitButton", "Senpais-Smart-Stop-Icon" )
	end

	global.Position[player_id] = global.Position[player_id] or { x = 5, y = 85 * player.display_scale }
	global.GUIS[player_id] = global.GUIS[player_id] or {}
end

Functions.AddLines = function( addtype, player_id, text, chooselem, schedule, choosestations, stations )
	if addtype == "new" then
		local player = game.players[player_id]

		if global.LineNames[text] then
			player.print( { "Circuit.AlreadyExist" } )

			return false
		elseif type( chooselem ) == "table" then
			if global.ChooseElemLines[chooselem.type][chooselem.name] then
				player.print( { "Circuit.Signalused" } )

				return false
			end
		end
	end

	local Lines = global.Lines
	Lines.Number = Lines.Number + 1

	if Lines.Number < 1000 then
		local index_number = Functions.Format3Digit( Lines.Number )

		Lines.Schedules[index_number] = schedule
		Lines.LineNames[index_number] = text
		Lines.ChooseElem[index_number] = chooselem
		Lines.ChooseElemStations[index_number] = choosestations or
		{
			fluid = {},
			item = {},
			virtual = {}
		}

		if type( chooselem ) == "table" then
			global.ChooseElemLines[chooselem.type][chooselem.name] = index_number
		end
		
		global.LineNames[text] = index_number

		local Stations = stations or
		{
			Number = 0,
			Stations = {},
			ChooseElem = {}
		}

		if Stations.Number == 0 then
			for _, entry in pairs( schedule.records ) do
				Stations.Number = Stations.Number + 1
	
				if Stations.Number < 100 then
					local index_number2 = Functions.Format2Digit( Stations.Number )
	
					Stations.Stations[index_number2] = entry.station
					Stations.ChooseElem[index_number2] = nil
				else
					break
				end
			end
		end

		Lines.Stations[index_number] = Stations
		global.Lines = Lines

		if type( player_id ) == "number" then
			global.GUIS[player_id].A["03"]["06"].items = Lines.LineNames
		end
		
		return true
	else
		if type( player_id ) == "number" then
			player.print( "CircuitPresetsError1000" )
		end

		return false
	end
end

--Checks the Signal if they still exist and if they are allowed
Functions.CheckSignal = function( signal )
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

--Clears Schedules from duplicates
Functions.ClearSchedule = function( schedule )
	local used = {}
	local tablerecords = {}
	local records = schedule.records

	for index, entry in pairs( records ) do
		if used[entry.station] then
			records[index] = nil
		else
			used[entry.station] = true
		end
	end

	for _, record in pairs( records ) do
		table.insert( tablerecords, record )
	end

	schedule.records = tablerecords

	return schedule
end

Functions.ClearLineSignal = function( signal, index_number )
	global.Lines.ChooseElem[index_number] = nil
	global.ChooseElemLines[signal.type][signal.name] = nil
end

Functions.ClearStationSignal = function( signal, index, index_number )
	global.Lines.Stations[index_number].ChooseElem[index] = nil
	global.Lines.ChooseElemStations[index_number][signal.type][signal.name] = nil
end

--Formation every Number to a 2long Number
Functions.Format2Digit = function( number )
	return string.format( "%02d", number )
end

--Formation every Number to a 3long Number
Functions.Format3Digit = function( number )
	return string.format( "%03d", number )
end

Functions.AddButton = function( parent, name, caption, style )
	return parent.add{ type = "button", name = name, caption = caption, style = style }
end

Functions.AddChooseElemButton = function( parent, name, style )
	return parent.add{ type = "choose-elem-button", name = name, elem_type = "signal", style = style }
end

Functions.AddDropDown = function( parent, name, items )
	return parent.add{ type = "drop-down", name = name, items = items }
end

Functions.AddFlow = function( parent, name, direction, style )
	return parent.add{ type = "flow", name = name, direction = direction, style = style }
end

Functions.AddFrame = function( parent, name, style )
	return parent.add{ type = "frame", name = name, direction = "vertical", style = style }
end

Functions.AddLabel = function( parent, name, caption, style )
	return parent.add{ type = "label", name = name, caption = caption, style = style }
end

Functions.AddLine = function( parent, name, direction )
	return parent.add{ type = "line", name = name, direction = direction }
end

Functions.AddScrollPane = function( parent, name, direction )
	return parent.add{ type = "scroll-pane", name = name, direction = direction }
end

Functions.AddSpriteButton = function( parent, name, sprite, style )
	return parent.add{ type = "sprite-button", name = name, sprite = sprite, style = style }
end

Functions.AddTable = function( parent, name, column_count )
	return parent.add{ type = "table", name = name, column_count = column_count }
end

Functions.AddTextField = function( parent, name, text )
	return parent.add{ type = "textfield", name = name, text = text }
end

Functions.AddWidget = function( parent, name, style )
	return parent.add{ type = "empty-widget", name = name, style = style }
end

return Functions