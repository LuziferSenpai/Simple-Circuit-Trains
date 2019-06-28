local F = {}

F.Globals = function()
	global.Lines = global.Lines or {}
	global.ScheduleLines = global.ScheduleLines or {}
	global.ScheduleLinesSignals = global.ScheduleLinesSignals or {}
	global.TrainsID = global.TrainsID or {}
end

F.Players = function()
	for _, p in pairs( game.players ) do
		local m = mod_gui.get_button_flow( p )
		if not m.CircuitTrainsGUIButton then
			local b = F.AddSpriteButton( m, "CircuitTrainsGUIButton", "Senpais-Smart-Stop-Icon" )
		end
	end
end

F.MainGUI = function( p )
	local A01 = F.AddFrame( p, "CircuitTrainsGUI", "outer_frame_without_shadow" )
	local A02 = F.AddTable( A01, "CircuitTrainsTable01", 2 )
	A02.vertical_centering = false
	local A03 =
	{
		F.AddFrame( A02, "CircuitTrainsHiddenFrame01", "outer_frame_without_shadow" ),
		F.AddFrame( A02, "CircuitTrainsHiddenFrame02", "outer_frame_without_shadow" ),
	}

	local A04 = F.AddFrame( A03[1], "CircuitTrainsFrame01", nil, { "CircuitTrains.Line" } )
	local A05 = F.AddTable( A04, "CircuitTrainsTable02", 4 )
	local A06 =
	{
		F.AddDropDown( A05, "CircuitTrainsDropDown", global.Lines ),
		F.AddChooseElemButton( A05, "CircuitTrainsChooseElemButton01", nil ),
		F.AddSpriteButton( A05, "CircuitTrainsSpriteButton01", "Senpais-plus" ),
		F.AddSpriteButton( A05, "CircuitTrainsSpriteButton02", "utility/trash_bin" )
	}
end

F.ListGUI = function( p, l )
	local B01 = F.AddScrollPane( p, "CircuitTrainsScrollPane" )
	B01.style.maximal_height = 300

	local B02 = F.AddFrame( B01, "CircuitTrainsFrame02", "image_frame", nil )
	B02.style.left_padding = 4
	B02.style.right_padding = 8
	B02.style.bottom_padding = 4
	B02.style.top_padding = 4

	local B03 = 
	{
		F.AddTable( B02, "CircuitTrainsTable03", 2 ),
		F.AddLabel( B02, "CircuitTrainsHiddenLabel01", l )
	}
	B03[1].style.horizontal_spacing = 16
	B03[1].style.vertical_spacing = 8
	B03[1].style.column_alignments[2] = "right"
	B03[1].draw_horizontal_line_after_headers = true
	B03[1].draw_vertical_lines = true
	B03[2].visible = false

	local B04 =
	{
		F.AddLabel( B03[1], "CircuitTrainsLabel01", { "CircuitTrains.Stations" } ),
		F.AddLabel( B03[1], "CircuitTrainsLabel02", { "CircuitTrains.Signals" } )
	}

	for _, c in pairs( global.ScheduleLinesSignals[l] ) do
		local st = c.st
		local s = F.CheckSignal( c.s )
		if s == nil then
			c.s = nil
		end
		local B05 =
		{
			F.AddLabel( B03[1], "CircuitTrainsLabel03_" .. st, st ),
			F.AddChooseElemButton( B03[1], "CircuitTrainsChooseElemButton02_" .. st, s )
		}
	end
end

F.AddGUI = function( p )
	local C01 = F.AddFrame( p, "CircuitTrainsFrame03", nil, { "CircuitTrains.NewLine" } )
	local C02 = 
	{
		F.AddTable( C01, "CircuitTrainsTable04", 2 ),
		F.AddButton( C01, "CircuitTrainsButton", { "CircuitTrains.AddLine" } )
	}

	local C03 =
	{
		F.AddTextField( C02[1], "CircuitTrainsTextField", nil ),
		F.AddChooseElemButton( C02[1], "CircuitTrainsChooseElemButton03", nil )
	}
end

F.AddButton = function( f, n, c )
	return f.add{ type = "button", name = n, caption = c }
end

F.AddChooseElemButton = function( f, n, s )
	return f.add{ type = "choose-elem-button", name = n, elem_type = "signal", signal = s }
end

F.AddDropDown = function( f, n, i )
	return f.add{ type = "drop-down", name = n, items = i }
end

F.AddFrame = function( f, n, s, c )
	return f.add{ type = "frame", name = n, direction = "vertical", style = s, caption = c }
end

F.AddLabel = function( f, n, c )
	return f.add{ type = "label", name = n, caption = c }
end

F.AddScrollPane = function( f, n )
	return f.add{ type = "scroll-pane", name = n }
end

F.AddSpriteButton = function( f, n, s )
	return f.add{ type = "sprite-button", name = n, sprite = s }
end

F.AddTable = function( f, n, c )
	return f.add{ type = "table", name = n, column_count = c }
end

F.AddTextField = function( f, n, t )
	return f.add{ type = "textfield", name = n, text = t }
end

F.CheckSignal = function( s )
	if s ~= nil then
		local n = s.name
		local t = s.type
		if game.active_mods["Automatic_Coupling_System"] and ( n == "signal-couple" or n == "signal-decouple" ) then
			return nil
		elseif t == "fluid" then
			if not game.fluid_prototypes[n] then
				return nil
			end
		elseif t == "item" then
			if not game.item_prototypes[n] then
				return nil
			end
		elseif t == "virtual" then
			if not game.virtual_signal_prototypes[n] then
				return nil
			end
		end
		return s
	else
		return nil
	end
end

F.ClearSchedule = function( s )
	local u = {}
	local r = {}
	for i, o in pairs( s.records ) do
		if u[o.station] then
			s.records[i] = nil
		else
			u[o.station] = true
		end
	end
	for _, o in pairs( s.records ) do
		table.insert( r, o )
	end
	s.records = r
	return s
end

return F