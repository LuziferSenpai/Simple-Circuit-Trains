local util = require("__Simple_Circuit_Trains__/scripts/util")
local flibGui = require("__flib__/gui-lite")
local flibPosition = require("__flib__/position")
local modGui = require("__core__/lualib/mod-gui")
local eventsDefine = defines.events
local guiPosition = { x = 15, y = 58 + 15 }
local simpleGui = {}

--mainGuiHandlers
local function toggleMainGui(eventData)
    local globalPlayer = global.players[tostring(eventData.player_index)]
    local simpleGuiMain = globalPlayer.guis.simpleGuiMain

    if simpleGuiMain and simpleGuiMain.valid then
        if simpleGuiMain.visible then
            simpleGuiMain.visible = false
        else
            simpleGuiMain.visible = true
        end
    else
        simpleGui.buildMainGui(globalPlayer, game.players[eventData.player_index])
    end
end

local function openAddNewLine(eventData)
    local player = game.players[eventData.player_index]
    local entities = player.surface.find_entities_filtered({
        position = player.position,
        radius = 5,
        type = "locomotive",
        force = player.force,
        limit = 1
    })

    if entities and entities[1] and entities[1].valid then
        local entity = entities[1]
        local trainIdString = tostring(entity.train.id)

        if not global.openTrains[trainIdString] then
            local globalPlayer = global.players[tostring(eventData.player_index)]

            player.opened = entity

            globalPlayer.guis.simpleGuiButton.enabled = false
            globalPlayer.guis.simpleGuiMain.visible = false
            globalPlayer.locomotive = entity
            globalPlayer.schedule = entity.train.schedule

            global.openTrains[trainIdString] = { playerIndex = eventData.player_index, schedule = nil }

            entity.train.schedule = nil

            simpleGui.createSubAddGui(globalPlayer, player)
        else
            player.print({ "sct-gui-error-messages.train-in-use" })
        end
    else
        player.print({ "sct-gui-error-messages.no-locomotive" })
    end
end

local function openEditLine(eventData)
    local player = game.players[eventData.player_index]
    local entities = player.surface.find_entities_filtered({
        position = player.position,
        radius = 5,
        type = "locomotive",
        force = player.force,
        limit = 1
    })

    if entities and entities[1] and entities[1].valid then
        local entity = entities[1]
        local trainIdString = tostring(entity.train.id)

        if not global.openTrains[trainIdString] then
            local globalPlayer = global.players[tostring(eventData.player_index)]
            local forceIndexString = tostring(player.force_index)
            local selectedIndex = globalPlayer.selectedIndex
            local selectedLineName = global.lineList[forceIndexString][selectedIndex]
            local selectedLine = global.lines[forceIndexString][selectedLineName]

            player.opened = entity

            globalPlayer.guis.simpleGuiButton.enabled = false
            globalPlayer.guis.simpleGuiMain.visible = false
            globalPlayer.locomotive = entity
            globalPlayer.schedule = entity.train.schedule

            global.openTrains[trainIdString] = { playerIndex = eventData.player_index, schedule = nil }

            entity.train.schedule = selectedLine.schedule

            simpleGui.createSubEditGui(globalPlayer, player, selectedLineName, selectedLine)
        else
            player.print({ "sct-gui-error-messages.train-in-use" })
        end
    else
        player.print({ "sct-gui-error-messages.no-locomotive" })
    end
end

local function changeLineSignal(eventData)
    local playerIndexString = tostring(eventData.player_index)
    local globalPlayer = global.players[playerIndexString]
    local player = game.players[eventData.player_index]
    local playerForceIndexString = tostring(player.force_index)
    local selectedIndex = globalPlayer.selectedIndex
    local lineName = global.lineList[playerForceIndexString][selectedIndex]
    local signal = eventData.element.elem_value

    if signal then
        global.lines[playerForceIndexString][lineName].signal = signal
        global.lineListDisplay[playerForceIndexString][selectedIndex] = util.signalToRichTextImg(signal) .. " - " .. lineName

        globalPlayer.guis.simpleGuiStationListBox.items = global.lineListDisplay[playerForceIndexString]

        if game.is_multiplayer() then
            for otherPlayerStringIndex, otherGlobalPlayer in pairs(global.players) do
                if otherPlayerStringIndex ~= playerIndexString then
                    local otherPlayer = game.players[tonumber(otherPlayerStringIndex)]

                    if otherPlayer.force_index == player.force_index then
                        if otherGlobalPlayer.guis.simpleGuiStationListBox then
                            otherGlobalPlayer.guis.simpleGuiStationListBox.items = global.lineListDisplay[playerForceIndexString]

                            if otherGlobalPlayer.selectedIndex == selectedIndex then
                                otherGlobalPlayer.guis.simpleGuiLineChooseElem.elem_value = signal
                            end
                        end
                    end
                end
            end
        end
    else
        eventData.element.elem_value = global.lines[playerForceIndexString][lineName].signal
    end
end

local function changeLineStationSignal(eventData)
    local playerIndexString = tostring(eventData.player_index)
    local globalPlayer = global.players[playerIndexString]
    local player = game.players[eventData.player_index]
    local playerForceIndexString = tostring(player.force_index)
    local selectedIndex = globalPlayer.selectedIndex
    local lineName = global.lineList[playerForceIndexString][selectedIndex]
    local element = eventData.element
    local signal = element.elem_value
    local stationIndex = element.tags.stationIndex

    global.lines[playerForceIndexString][lineName].stations[stationIndex].signal = element.elem_value

    if game.is_multiplayer() then
        for otherPlayerStringIndex, otherGlobalPlayer in pairs(global.players) do
            if otherPlayerStringIndex ~= playerIndexString then
                local otherPlayer = game.players[tonumber(otherPlayerStringIndex)]

                if otherPlayer.force_index == player.force_index then
                    if otherGlobalPlayer.selectedIndex == selectedIndex then
                        otherGlobalPlayer.guis.simpleGuiLineStationTable["simpleGuiLineStationSignal" .. stationIndex].elem_value = element.elem_value
                    end
                end
            end
        end
    end
end

local function deleteSelectedLine(eventData)
    local playerIndexString = tostring(eventData.player_index)
    local globalPlayer = global.players[playerIndexString]
    local player = game.players[eventData.player_index]
    local playerForceIndexString = tostring(player.force_index)
    local selectedIndex = globalPlayer.selectedIndex
    local lineName = global.lineList[playerForceIndexString][selectedIndex]

    global.lineList[playerForceIndexString][selectedIndex] = nil
    global.lineListDisplay[playerForceIndexString][selectedIndex] = nil
    global.lines[playerForceIndexString][lineName] = nil

    globalPlayer.guis.simpleGuiStationListBox.selected_index = 0
    globalPlayer.guis.simpleGuiStationListBox.items = global.lineListDisplay[playerForceIndexString]
    globalPlayer.guis.simpleGuiLineFrame.destroy()
    globalPlayer.selectedIndex = nil

    if game.is_multiplayer() then
        for otherPlayerStringIndex, otherGlobalPlayer in pairs(global.players) do
            if otherPlayerStringIndex ~= playerIndexString then
                local otherPlayer = game.players[tonumber(otherPlayerStringIndex)]

                if otherPlayer.force_index == player.force_index then
                    if otherGlobalPlayer.guis.simpleGuiStationListBox then
                        otherGlobalPlayer.guis.simpleGuiStationListBox.selected_index = 0
                        otherGlobalPlayer.guis.simpleGuiStationListBox.items = global.lineListDisplay[playerForceIndexString]
                    end

                    if otherGlobalPlayer.selectedIndex == selectedIndex then
                        globalPlayer.selectedIndex = nil

                        globalPlayer.guis.simpleGuiLineFrame.destroy()
                    end
                end
            end
        end
    end
end

local function changeSelectedLine(eventData)
    local globalPlayer = global.players[tostring(eventData.player_index)]
    local forceIndexString = tostring(game.players[eventData.player_index].force_index)
    local selectedLineName = global.lineList[forceIndexString][eventData.element.selected_index]

    if not selectedLineName then return end

    local selectedLine = global.lines[forceIndexString][selectedLineName]

    if not selectedLine then return end

    simpleGui.buildLineFrame(globalPlayer, selectedLineName, selectedLine)

    globalPlayer.selectedIndex = eventData.element.selected_index
end

local function closeMainGui(eventData)
    local simpleGuiMain = global.players[tostring(eventData.player_index)].guis.simpleGuiMain

    if simpleGuiMain and simpleGuiMain.valid then
        simpleGuiMain.visible = false
    end
end

--subGuiHandlers
local function addNewLine(eventData)
    local player = game.players[eventData.player_index]
    local playerIndexString = tostring(eventData.player_index)
    local globalPlayer = global.players[playerIndexString]
    local entity = globalPlayer.locomotive

    if entity and entity.valid then
        local train = entity.train

        if train.schedule and next(train.schedule.records) then
            local playerForceIndexString = tostring(player.force_index)
            local simpleSubGuiAddChooseElem = globalPlayer.guis.simpleSubGuiAddChooseElem
            local simpleSubGuiAddTextField = globalPlayer.guis.simpleSubGuiAddTextField
            local signal = simpleSubGuiAddChooseElem.elem_value
            local lineName = simpleSubGuiAddTextField.text

            if not signal then
                player.print({ "sct-gui-error-messages.no-signal" })

                return
            end

            if string.len(lineName) == 0 then
                player.print({ "sct-gui-error-messages.no-line-name" })

                return
            end

            if global.lines[playerForceIndexString][lineName] then
                player.print({ "sct-gui-error-messages.line-name-already-used" })

                return
            end

            local schedule = train.schedule
            local records = schedule.records
            local lineObj = {
                signal = signal,
                schedule = schedule,
                stations = {}
            }

            for i = 1, #records do
                table.insert(lineObj.stations, { name = records[i].station })
            end

            player.opened = nil

            train.schedule = globalPlayer.schedule

            global.openTrains[tostring(train.id)] = nil
            global.lines[playerForceIndexString][lineName] = lineObj

            table.insert(global.lineList[playerForceIndexString], lineName)
            table.insert(global.lineListDisplay[playerForceIndexString], util.signalToRichTextImg(signal) .. " - " .. lineName)

            globalPlayer.guis.simpleGuiStationListBox.items = global.lineListDisplay[playerForceIndexString]
            globalPlayer.guis.simpleGuiButton.enabled = true
            globalPlayer.guis.simpleSubGuiAddTop.destroy()
            globalPlayer.locomotive = nil
            globalPlayer.schedule = nil

            if game.is_multiplayer() then
                for otherPlayerIndexString, otherGlobalPlayer in pairs(global.players) do
                    if otherPlayerIndexString ~= playerIndexString then
                        local otherPlayer = game.players[tonumber(otherPlayerIndexString)]

                        if otherPlayer.force_index == player.force_index then
                            if otherGlobalPlayer.guis.simpleGuiStationListBox then
                                otherGlobalPlayer.guis.simpleGuiStationListBox.items = global.lineListDisplay[playerForceIndexString]
                            end
                        end
                    end
                end
            end
        else
            player.print({ "sct-gui-error-messages.no-schedule" })
        end
    else
        if globalPlayer.guis.simpleSubGuiAddTop and globalPlayer.guis.simpleSubGuiAddTop.valid then
            globalPlayer.guis.simpleSubGuiAddTop.destroy()
        end
    end
end

local function editLine(eventData)
    local playerIndexString = tostring(eventData.player_index)
    local player = game.players[eventData.player_index]
    local globalPlayer = global.players[playerIndexString]
    local entity = globalPlayer.locomotive

    if entity and entity.valid then
        local train = entity.train

        if train.schedule and next(train.schedule.records) then
            local playerForceIndexString = tostring(player.force_index)
            local selectedIndex = globalPlayer.selectedIndex
            local selectedLineName = global.lineList[playerForceIndexString][selectedIndex]
            local signal = globalPlayer.guis.simpleSubGuiEditChooseElem.elem_value
            local lineName = globalPlayer.guis.simpleSubGuiEditTextField.text

            if not signal then
                player.print({ "sct-gui-error-messages.no-signal" })

                return
            end

            if string.len(lineName) == 0 then
                player.print({ "sct-gui-error-messages.no-line-name" })

                return
            end

            if selectedLineName == lineName then
                goto continueEditLine
            end

            if global.lines[playerForceIndexString][lineName] then
                player.print({ "sct-gui-error-messages.line-name-already-used" })

                return
            else
                goto continueEditLine
            end

            ::continueEditLine::

            local schedule = train.schedule
            local records = schedule.records
            local lineObj = {
                signal = signal,
                schedule = schedule,
                stations = {}
            }

            for i = 1, #records do
                table.insert(lineObj.stations, { name = records[i].station })
            end

            player.opened = nil

            train.schedule = globalPlayer.schedule

            global.openTrains[tostring(train.id)] = nil
            global.lines[playerForceIndexString][selectedLineName] = nil
            global.lines[playerForceIndexString][lineName] = lineObj
            global.lineList[playerForceIndexString][selectedIndex] = lineName
            global.lineListDisplay[playerForceIndexString][selectedIndex] = util.signalToRichTextImg(signal) ..
                " - " .. lineName

            globalPlayer.guis.simpleGuiStationListBox.items = global.lineListDisplay[playerForceIndexString]
            globalPlayer.guis.simpleGuiButton.enabled = true
            globalPlayer.guis.simpleGuiMain.visible = true
            globalPlayer.guis.simpleSubGuiEditTop.destroy()
            globalPlayer.locomotive = nil
            globalPlayer.schedule = nil

            if game.is_multiplayer() then
                for otherPlayerIndexString, otherGlobalPlayer in pairs(global.players) do
                    if otherPlayerIndexString ~= playerIndexString then
                        local otherPlayer = game.players[tonumber(otherPlayerIndexString)]

                        if otherPlayer.force_index == player.force_index then
                            if otherGlobalPlayer.guis.simpleGuiStationListBox then
                                otherGlobalPlayer.guis.simpleGuiStationListBox.items = global.lineListDisplay[playerForceIndexString]

                                if otherGlobalPlayer.selectedIndex == selectedIndex then
                                    simpleGui.buildLineFrame(otherGlobalPlayer, lineName, lineObj)
                                end
                            end
                        end
                    end
                end
            end

            simpleGui.buildLineFrame(globalPlayer, lineName, lineObj)
        else
            player.print({ "sct-gui-error-messages.no-schedule" })
        end
    else
        if globalPlayer.guis.simpleSubGuiEdiTop and globalPlayer.guis.simpleSubGuiEditTop.valid then
            global.guis.simpleSubGuiEditTop.destroy()
        end
    end
end

local function handleCloseGui(eventData)
    local globalPlayer = global.players[tostring(eventData.player_index)]
    local entity = eventData.entity

    if entity then
        if globalPlayer.locomotive and globalPlayer.locomotive.unit_number == entity.unit_number then
            local simpleSubGuiAddTop = globalPlayer.guis.simpleSubGuiAddTop
            local simpleSubGuiEditTop = globalPlayer.guis.simpleSubGuiEditTop

            entity.train.schedule = globalPlayer.schedule

            globalPlayer.guis.simpleGuiButton.enabled = true

            if simpleSubGuiAddTop and simpleSubGuiAddTop.valid then
                simpleSubGuiAddTop.destroy()
            end

            if simpleSubGuiEditTop and simpleSubGuiEditTop.valid then
                simpleSubGuiEditTop.destroy()
            end

            globalPlayer.locomotive = nil
            globalPlayer.schedule = nil

            global.openTrains[tostring(entity.train.id)] = nil
        end
    end
end

--mainGuiCreation
function simpleGui.buildGuiButton(globalPlayer, player)
    local simpleGuiButton = globalPlayer.guis.simpleGuiButton

    if not simpleGuiButton or not simpleGuiButton.valid then
        local elems = flibGui.add(modGui.get_button_flow(player), {
            type = "sprite-button",
            name = "simpleGuiButton",
            sprite = "simple-stop-icon",
            style = modGui.button_style,
            handler = { [eventsDefine.on_gui_click] = toggleMainGui }
        })

        globalPlayer.guis.simpleGuiButton = elems.simpleGuiButton
    end
end

function simpleGui.buildMainGui(globalPlayer, player)
    local simpleGuiMain = globalPlayer.guis.simpleGuiMain

    if not simpleGuiMain or not simpleGuiMain.valid then
        local scale = player.display_scale
        local elems = flibGui.add(player.gui.screen, {
            type = "frame",
            name = "simpleGuiMain",
            direction = "vertical",
            {
                type = "flow",
                style = "flib_titlebar_flow",
                drag_target = "simpleGuiMain",
                {
                    type = "label",
                    style = "frame_title",
                    caption = { "sct-gui-labels.title" },
                    ignored_by_interaction = true
                },
                {
                    type = "empty-widget",
                    style = "flib_titlebar_drag_handle",
                    ignored_by_interaction = true
                },
                {
                    type = "sprite-button",
                    name = "simpleCloseButton",
                    style = "frame_action_button",
                    sprite = "utility/close_white",
                    hovered_sprite = "utility/close_black",
                    clicked_sprite = "utility/close_black",
                    mouse_button_filter = { "left" },
                    handler = { [eventsDefine.on_gui_click] = closeMainGui }
                }
            },
            {
                type = "flow",
                name = "simpleGuiMainFlow",
                direction = "horizontal",
                style_mods = { horizontal_spacing = 8 },
                {
                    type = "frame",
                    style = "inside_shallow_frame",
                    direction = "vertical",
                    {
                        type = "frame",
                        style = "subheader_frame",
                        direction = "horizontal",
                        {
                            type = "label",
                            style = "subheader_caption_label",
                            caption = { "sct-gui-labels.select-line" }
                        },
                        {
                            type = "empty-widget",
                            style = "flib_horizontal_pusher"
                        },
                        {
                            type = "sprite-button",
                            name = "simpleGuiAddButton",
                            style = "flib_tool_button_light_green",
                            sprite = "utility/add",
                            hovered_sprite = "simple-add-white",
                            clicked_sprite = "simple-add-white",
                            mouse_button_filter = { "left" },
                            tooltip = { "sct-gui-labels.add-new-line" },
                            handler = { [eventsDefine.on_gui_click] = openAddNewLine }
                        }
                    },
                    {
                        type = "list-box",
                        name = "simpleGuiStationListBox",
                        items = global.lineListDisplay[tostring(player.force_index)],
                        style_mods = { width = 225, height = 280 },
                        handler = { [eventsDefine.on_gui_selection_state_changed] = changeSelectedLine }
                    }
                }
            }
        })

        elems.simpleGuiMain.location = flibPosition.mul(guiPosition, { scale, scale })

        globalPlayer.guis.simpleGuiMain = elems.simpleGuiMain
        globalPlayer.guis.simpleGuiMainFlow = elems.simpleGuiMainFlow
        globalPlayer.guis.simpleGuiAddButton = elems.simpleGuiAddButton
        globalPlayer.guis.simpleGuiStationListBox = elems.simpleGuiStationListBox
    end
end

function simpleGui.buildLineFrame(globalPlayer, selectedLineName, selectedLine)
    local simpleGuiLineFrame = globalPlayer.guis.simpleGuiLineFrame

    if simpleGuiLineFrame and simpleGuiLineFrame.valid then
        simpleGuiLineFrame.destroy()
    end

    local stationTable = {
        type = "table",
        name = "simpleGuiLineStationTable",
        column_count = 2
    }

    for i = 1, #selectedLine.stations do
        table.insert(stationTable, {
            type = "label",
            caption = selectedLine.stations[i].name,
            style_mods = { horizontally_squashable = true, horizontally_stretchable = true }
        })

        table.insert(stationTable, {
            type = "choose-elem-button",
            name = "simpleGuiLineStationSignal" .. i,
            style = "flib_slot_default",
            elem_type = "signal",
            signal = selectedLine.stations[i].signal,
            tags = { stationIndex = i },
            handler = { [eventsDefine.on_gui_elem_changed] = changeLineStationSignal },
            style_mods = { size = 35 }
        })
    end

    local elems = flibGui.add(globalPlayer.guis.simpleGuiMainFlow, {
        type = "frame",
        name = "simpleGuiLineFrame",
        style = "inside_shallow_frame",
        direction = "vertical",
        {
            type = "frame",
            style = "subheader_frame",
            direction = "horizontal",
            style_mods = { minimal_width = 225, maximal_width = 500 },
            {
                type = "label",
                style = "subheader_caption_label",
                caption = selectedLineName,
                style_mods = { horizontally_squashable = true }
            },
            {
                type = "empty-widget",
                style = "flib_horizontal_pusher"
            },
            {
                type = "choose-elem-button",
                name = "simpleGuiLineChooseElem",
                style = "flib_slot_default",
                elem_type = "signal",
                signal = selectedLine.signal,
                style_mods = { size = 30 },
                handler = { [eventsDefine.on_gui_elem_changed] = changeLineSignal }
            },
            {
                type = "sprite-button",
                name = "simpleGuiLineEdit",
                style = "tool_button",
                sprite = "utility/change_recipe",
                hovered_sprite = "simple-change-recipe-white",
                clicked_sprite = "simple-change-recipe-white",
                mouse_button_filter = { "left" },
                tooltip = { "sct-gui-labels.edit-line" },
                handler = { [eventsDefine.on_gui_click] = openEditLine }
            },
            {
                type = "sprite-button",
                name = "simpleGuiLineRemove",
                style = "flib_tool_button_dark_red",
                sprite = "utility/trash",
                hovered_sprite = "utility/trash_white",
                clicked_sprite = "utility/trash_white",
                mouse_button_filter = { "left" },
                tooltip = { "sct-gui-labels.delete-line" },
                handler = { [eventsDefine.on_gui_click] = deleteSelectedLine }
            }
        },
        {
            type = "scroll-pane",
            style = "flib_shallow_scroll_pane",
            style_mods = { minimal_width = 225, maximal_width = 500, horizontally_stretchable = true, height = 280, padding = 4 },
            stationTable
        }
    })

    globalPlayer.guis.simpleGuiLineFrame = elems.simpleGuiLineFrame
    globalPlayer.guis.simpleGuiLineChooseElem = elems.simpleGuiLineChooseElem
    globalPlayer.guis.simpleGuiLineEdit = elems.simpleGuiLineEdit
    globalPlayer.guis.simpleGuiLineStationTable = elems.simpleGuiLineStationTable
end

--subGuiCreation
function simpleGui.createSubAddGui(globalPlayer, player)
    local simpleSubGuiAddTop = globalPlayer.guis.simpleSubGuiAddTop

    if not simpleSubGuiAddTop or not simpleSubGuiAddTop.valid then
        local elems = flibGui.add(player.gui.relative, {
            type = "frame",
            name = "simpleSubGuiAddTop",
            style = "quick_bar_window_frame",
            style_mods = { horizontally_stretchable = false },
            anchor = { gui = defines.relative_gui_type.train_gui, position = defines.relative_gui_position.top },
            {
                type = "flow",
                style = "flib_titlebar_flow",
                {
                    type = "label",
                    style = "frame_title",
                    caption = { "sct-gui-labels.sub-title" }
                },
                {
                    type = "textfield",
                    name = "simpleSubGuiAddTextField",
                    style_mods = { width = 150 }
                },
                {
                    type = "choose-elem-button",
                    name = "simpleSubGuiAddChooseElem",
                    style = "flib_slot_default",
                    elem_type = "signal",
                    style_mods = { size = 30 }
                },
                {
                    type = "sprite-button",
                    style = "flib_tool_button_light_green",
                    sprite = "utility/add",
                    hovered_sprite = "simple-add-white",
                    clicked_sprite = "simple-add-white",
                    mouse_button_filter = { "left" },
                    tooltip = { "sct-gui-labels.add-this-line" },
                    handler = { [eventsDefine.on_gui_click] = addNewLine }
                },
            },
        })

        globalPlayer.guis.simpleSubGuiAddTop = elems.simpleSubGuiAddTop
        globalPlayer.guis.simpleSubGuiAddTextField = elems.simpleSubGuiAddTextField
        globalPlayer.guis.simpleSubGuiAddChooseElem = elems.simpleSubGuiAddChooseElem
    end
end

function simpleGui.createSubEditGui(globalPlayer, player, selectedLineName, selectedLine)
    local simpleSubGuiEditTop = globalPlayer.guis.simpleSubGuiEditTop

    if not simpleSubGuiEditTop or not simpleSubGuiEditTop.valid then
        local elems = flibGui.add(player.gui.relative, {
            type = "frame",
            name = "simpleSubGuiEditTop",
            style = "quick_bar_window_frame",
            style_mods = { horizontally_stretchable = false },
            anchor = { gui = defines.relative_gui_type.train_gui, position = defines.relative_gui_position.top },
            {
                type = "flow",
                style = "flib_titlebar_flow",
                {
                    type = "label",
                    style = "frame_title",
                    caption = { "sct-gui-labels.sub-title" }
                },
                {
                    type = "textfield",
                    name = "simpleSubGuiEditTextField",
                    style_mods = { width = 150 },
                    text = selectedLineName
                },
                {
                    type = "choose-elem-button",
                    name = "simpleSubGuiEditChooseElem",
                    style = "flib_slot_default",
                    elem_type = "signal",
                    signal = selectedLine.signal,
                    style_mods = { size = 30 }
                },
                {
                    type = "sprite-button",
                    style = "tool_button",
                    sprite = "utility/change_recipe",
                    hovered_sprite = "simple-change-recipe-white",
                    clicked_sprite = "simple-change-recipe-white",
                    mouse_button_filter = { "left" },
                    tooltip = { "sct-gui-labels.edit-this-line" },
                    handler = { [eventsDefine.on_gui_click] = editLine }
                },
            },
        })

        globalPlayer.guis.simpleSubGuiEditTop = elems.simpleSubGuiEditTop
        globalPlayer.guis.simpleSubGuiEditTextField = elems.simpleSubGuiEditTextField
        globalPlayer.guis.simpleSubGuiEditChooseElem = elems.simpleSubGuiEditChooseElem
    end
end

simpleGui.events = {
    [eventsDefine.on_gui_closed] = handleCloseGui
}

flibGui.add_handlers({
    toggleMainGui = toggleMainGui,
    closeMainGui = closeMainGui,
    openAddNewLine = openAddNewLine,
    openEditLine = openEditLine,
    changeLineSignal = changeLineSignal,
    changeLineStationSignal = changeLineStationSignal,
    deleteSelectedLine = deleteSelectedLine,
    changeSelectedLine = changeSelectedLine,
    addNewLine = addNewLine,
    editLine = editLine
})

return simpleGui
