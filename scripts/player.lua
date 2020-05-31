local player_data = {}

player_data.metatable = { __index = player_data }

function player_data.new( player )
    local module =
    {
        player = player,
        index = tostring( player.index ),
        location = { x = 5, y = 85 * player.display_scale },
        button = mod_gui.get_button_flow( player ).add{ type = "sprite-button", name = "SIMPLE_CLICK_01", sprite = "Senpais-Smart-Stop-Icon", style = mod_gui.button_style },
    }

    setmetatable( module, player_data.metatable )

    return module
end

function player_data:gui( linenames )
    local frame = self.player.gui.screen.add{ type = "frame", name = "SIMPLE_LOCATION", direction = "vertical", style = "inner_frame_in_outer_frame" }
    local titleflow = frame.add{ type = "flow", direction = "horizontal", style = "circuittitlebarflow" }
    titleflow.add{ type = "label", caption = { "Circuit.Title" }, style = "frame_title" }
    titleflow.add{ type = "empty-widget", style = "circuitdragwidget" }.drag_target = frame
    titleflow.add{ type = "sprite-button", name = "SIMPLE_CLICK_02", sprite = "utility/close_white", style = "frame_action_button" }
    local lineflow = frame.add{ type = "flow", direction = "horizontal", style = "circuitflowcenterleft88" }
    lineflow.add{ type = "label", caption = { "Circuit.LineTitle" }, style = "caption_label" }
    self.linechooseelem = lineflow.add{ type = "choose-elem-button", name = "SIMPLE_ELEM_01", elem_type = "signal", style = "circuitchooseelem28" }
    lineflow.add{ type = "sprite-button", name = "SIMPLE_CLICK_03", sprite = "Senpais-remove", style = "circuittoolbutton" }
    local horizontalflow = frame.add{ type = "flow", direction = "horizontal", style = "circuitflow20" }
    self.listbox = horizontalflow.add{ type = "frame", direction = "vertical", style = "circuitlistboxframe" }.add{ type = "list-box", name = "SIMPLE_DROP_01", items = linenames, style = "circuitlistbox" }
    local stationframe = horizontalflow.add{ type = "scroll-pane", direction = "vertical", style = "circuitlistscrollpane" }.add{ type = "frame", direction = "vertical", style = "circuitstationframe" }
    local stationflow = stationframe.add{ type = "flow", direction = "horizontal", style = "circuitflowcenterleft8" }
    stationflow.add{ type = "label", caption = { "Circuit.Stations" } }
    stationflow.add{ type = "empty-widget", style = "circuitlistwidget" }
    stationflow.add{ type = "label", caption = { "Circuit.Buttons" } }
    stationframe.add{ type = "line", direction = "horizontal", style = "circuitstationline" }
    self.stationframe = stationframe
    local addflow = frame.add{ type = "flow", direction = "horizontal", style = "circuitflowcenterleft8" }
    addflow.add{ type = "label", caption = { "Circuit.Name" } }
    self.textfield = addflow.add{ type = "textfield" }
    self.addchooseelem = addflow.add{ type = "choose-elem-button", elem_type = "signal", style = "circuitchooseelem28" }
    addflow.add{ type = "button", name = "SIMPLE_CLICK_04", caption = { "Circuit.AddLine" } }

    frame.location = self.location

    self.frame = frame
end

function player_data:update_station_frame( stations )
    local stationframe = self.stationframe
    local children = stationframe.children

    if #children > 2 then
        for i = 3, #children do
            children[i].destroy()
        end
    end

    self.labels = {}
    self.textfields = {}

    if next( stations ) and stations.number > 0 then
        for i = 1, stations.number do
            local index = tostring( i )
            local name = stations.stations[index]
            local flow = stationframe.add{ type = "flow", direction = "horizontal", style = "circuitflowcenterleft8" }
            self.labels[index] = flow.add{ type = "label", caption = name, style = "circuitstationlabel" }
            self.textfields[index] = flow.add{ type = "textfield", name = "SIMPLE_CONFIRM_01_" .. i, text = name, style = "circuitstationtextfield" }
            flow.add{ type = "empty-widget", style = "circuitlistwidget" }
            flow.add{ type = "choose-elem-button", name = "SIMPLE_ELEM_02_" .. i, elem_type = "signal", signal = stations.chooseelem[index], style = "circuitchooseelem28" }
            flow.add{ type = "sprite-button", name = "SIMPLE_CLICK_05_" .. i, sprite = "utility/rename_icon_small_black", style = "circuittoolbutton" }
            flow.add{ type = "sprite-button", name = "SIMPLE_CLICK_06_" .. i, sprite = "Senpais-remove", style = "circuittoolbutton" }
            
            if i + 1 <= stations.number then
                stationframe.add{ type = "line", direction = "horizontal", style = "circuitstationline" }
            end

            self.textfields[index].visible = false
        end
    end
end

function player_data:clear()
    self.frame.destroy()
    self.frame = nil
    self.linechooseelem = nil
    self.listbox = nil
    self.stationframe = nil
    self.textfield = nil
    self.addchooseelem = nil
    self.labels = nil
    self.textfields = nil
end

function player_data:toggle_editingfield( index )
    local labels = self.labels
    local textfields = self.textfields

    labels[index].visible = not labels[index].visible
    textfields[index].visible = not labels[index].visible
end



return player_data