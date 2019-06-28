require "mod-gui"

local F = require "functions"
local de = defines.events

script.on_init( function()
	F.Globals()
	F.Players()
end )

script.on_configuration_changed( function()
	F.Globals()
	F.Players()
end )

script.on_event( de.on_gui_click, function( ee )
	local id = ee.player_index
	local p = game.players[id]
	local e = ee.element
	local n = e.name
	local pa = e.parent

	if ( n == nil or pa == nil ) then return end

	local m = mod_gui.get_frame_flow( p )

	if n == "CircuitTrainsGUIButton" then
		if m.CircuitTrainsGUI then
			m.CircuitTrainsGUI.destroy()
		else
			F.MainGUI( m )
		end
		return
	elseif n == "CircuitTrainsSpriteButton01" then
		local pa2 = pa.parent.parent.parent.children[2]
		pa2.clear()
		if p.opened and p.opened.train then
			F.AddGUI( pa2 )
		end
	elseif n == "CircuitTrainsSpriteButton02" then
		local i = pa.children[1].selected_index
		if i > 0 then
			local l = global.Lines[i]
			global.ScheduleLines[l] = nil
			global.ScheduleLinesSignals[l] = nil
			table.remove( global.Lines, i )
			m.CircuitTrainsGUI.destroy()
			F.MainGUI( m )
		else
			p.print( { "CircuitTrains.NoLineSelected" } )
		end
	elseif n == "CircuitTrainsButton" then
		local t = pa.children[1].children[1].text
		local o = p.opened
		if o and o.train then
			o = o.train
			if o.schedule ~= nil then
				if t ~= nil and not global.ScheduleLines[t] then
					table.insert( global.Lines, t )
					local sc = F.ClearSchedule( o.schedule )
					global.ScheduleLines[t] = { s = F.CheckSignal( pa.children[1].children[2].elem_value ), sc = sc }
					local p = {}
					for _, r in pairs( sc.records ) do
						table.insert( p, { s = nil, st = r.station } )
					end
					global.ScheduleLinesSignals[t] = p
					m.CircuitTrainsGUI.destroy()
					F.MainGUI( m )
				else
					pa.parent.clear()
					p.print( { "CircuitTrains.NoName" } )
				end
			else
				pa.parent.clear()
				p.print( { "CircuitTrains.NoSchedule" } )
			end
		else
			pa.parent.clear()
			p.print( { "CircuitTrains.NoTrainOpen" } )
		end
	end
end )

script.on_event( { de.on_gui_selection_state_changed, de.on_gui_elem_changed }, function( ee )
	local id = ee.player_index
	local p = game.players[id]
	local e = ee.element
	local n = e.name
	local pa = e.parent
	local i = e.selected_index or 0

	if ( n == nil or pa == nil ) then return end

	if n == "CircuitTrainsDropDown" and i > 0 then
		local pa2 = pa.parent.children[2]
		if pa2 then
			pa2.destroy()
		end

		local l = global.Lines[i]
		local s = F.CheckSignal( global.ScheduleLines[l].s )
		pa2 = pa.children[2]
		if s ~= nil then
			pa2.elem_value = s
		else
			pa2.elem_value = nil
			global.ScheduleLines[l].s = nil
			p.print( { "CircuitTrains.NoValidSignal" } )
		end
		F.ListGUI( pa.parent, l )
	elseif n == "CircuitTrainsChooseElemButton01" then
		i = pa.children[1].selected_index
		if i > 0 then
			local s = F.CheckSignal( e.elem_value )
			if s ~= nil then
				global.ScheduleLines[global.Lines[i]].s = s
			else
				e.elem_value = global.ScheduleLines[global.Lines[i]].s
				p.print( { "CircuitTrains.NoValidSignal" } )
			end
		else
			e.elem_value = nil
			p.print( { "CircuitTrains.NoLineSelected" } )
		end
	elseif pa.name == "CircuitTrainsTable03" then
		for _, r in pairs( global.ScheduleLinesSignals[pa.parent.children[2].caption] ) do
			if n == "CircuitTrainsChooseElemButton02_" .. r.st then
				local s = F.CheckSignal( e.elem_value )
				if s ~= nil then
					r.s = s
				else
					e.elem_value = r.s
					p.print( { "CircuitTrains.NoValidSignal" } )
				end
				break
			end
		end
	end
end )

script.on_event( de.on_player_created, function( ee )
	local id = ee.player_index
	local p = game.players[id]
	local m = mod_gui.get_button_flow( p )
	if m.CircuitTrainsGUIButton then
		local b = F.AddSpriteButton( m, "CircuitTrainsGUIButton", "Senpais-Smart-Stop-Icon" )
	end
end )

script.on_event( de.on_train_changed_state, function( ee )
	local t = ee.train
	local d = defines.train_state.wait_station
	if t.state == d then
		local s = t.station
		if s ~= nil then
			local c = { s = s, st = false }
			if s.get_circuit_network( defines.wire_type.red ) and s.get_circuit_network( defines.wire_type.green ) then
				c.st = true
			end
			if game.active_mods["Automatic_Coupling_System"] then
				local ch = remote.call( "Couple", "Check", t )
				if ch then
					c.c = true
				end
			end
			global.TrainsID[t.id] = c
		end
	elseif ee.old_state == d and global.TrainsID[t.id] then
		local tg = global.TrainsID[t.id]
		global.TrainsID[t.id] = nil

		local s = tg.s

		if not ( s and s.valid ) then return end
		if tg.st then
			t.manual_mode = true

			local r = s.get_circuit_network( defines.wire_type.red )
			local g = s.get_circuit_network( defines.wire_type.green )
			local ls = {}
			local si = {}

			for l, ss in pairs( global.ScheduleLines ) do
				si = F.CheckSignal( ss.s )
				if si ~= nil then
					ls[l] = si
				else
					ss.s = nil
				end
			end

			local lhs = { s = nil, v = 0, l = nil }

			for ll, y in pairs( ls ) do
				si = r.get_signal( y )
				if si ~= nil and si > lhs.v then
					lhs = { s = y, v = si, l = ll }
				end
			end

			if lhs.l ~= nil then
				local l = lhs.l
				local sig = {}

				for _, ss in pairs( global.ScheduleLinesSignals[l] ) do
					si = F.CheckSignal( ss.s )
					if si ~= nil then
						sig[ss.st] = si
					else
						ss.s = nil
					end
				end

				local shs = { s = nil, v = 0, st = nil }

				for st, y in pairs( sig ) do
					si = g.get_signal( y )
					if si ~= nil and si > shs.v then
						shs = { s = y, v = si, st = st }
					end
				end

				if shs.st ~= nil then
					local st = shs.st
					local c = 0
					local re = global.ScheduleLines[l].sc.records
					for i = 1, table_size( re ) do
						if re[i].station == st then
							c = i
							break
						end
					end
					t.schedule = { current = c, records = re }
				end
			end
			t.manual_mode = false
		end
		if tg.c and game.active_mods["Automatic_Coupling_System"] then
			local ch = remote.call( "Couple", "Couple", t )
		end
	end
end )