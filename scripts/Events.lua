local util = require("__Simple_Circuit_Trains__/scripts/util")
local simpleGui = require("__Simple_Circuit_Trains__/scripts/gui")
local waitStationTrainStateDefine = defines.train_state.wait_station
local redWireTypeDefine = defines.wire_type.red
local greenWireTypeDefine = defines.wire_type.green
local eventsDefine = defines.events
local eventsLib = {}

local function initPlayer(player)
    local playerIndexString = tostring(player.index)

    if not global.players[playerIndexString] then
        global.players[playerIndexString] = {
            guis = {}
        }

        simpleGui.buildGuiButton(global.players[playerIndexString], player)
    end
end

local function initGlobals()
    global.players = global.players or {}
    global.openTrains = global.openTrains or {}
    global.trainIds = global.trainIds or {}
    global.lines = global.lines or {}
    global.lineList = global.lineList or {}
    global.lineListDisplay = global.lineListDisplay or {}

    for _, force in pairs(game.forces) do
        local forceIndexString = tostring(force.index)

        global.lines[forceIndexString] = global.lines[forceIndexString] or {}
        global.lineList[forceIndexString] = global.lineList[forceIndexString] or {}
        global.lineListDisplay[forceIndexString] = global.lineListDisplay[forceIndexString] or {}
    end
end

eventsLib.events = {
    [eventsDefine.on_force_created] = function(eventData)
        local forceIndexString = tostring(eventData.force.index)

        global.lines[forceIndexString] = {}
        global.lineList[forceIndexString] = {}
        global.lineListDisplay[forceIndexString] = {}
    end,
    [eventsDefine.on_forces_merged] = function(eventData)
        local removedForceIndexString = tostring(eventData.source_index)
        local removedForceLineList = global.lineList[removedForceIndexString]
        local removedForceLineListLength = #removedForceLineList
        local destinationForceIndexString = tostring(eventData.destination.index)

        if removedForceLineListLength > 0 then
            local destinationForceLines = global.lines[destinationForceIndexString]

            if #global.lineList[destinationForceIndexString] > 0 then
                local removedForceLines = global.lines[removedForceIndexString]

                for i = 1, removedForceLineListLength do
                    local lineName = removedForceLineList[i]

                    if destinationForceLines[lineName] then
                        lineName = lineName .. " (2)"
                    end

                    global.lines[destinationForceIndexString][lineName] = removedForceLines[removedForceLineList[i]]

                    table.insert(global.lineList[destinationForceIndexString], lineName)
                    table.insert(global.lineListDisplay[destinationForceIndexString],
                        util.signalToRichTextImg(removedForceLines[i].signal) .. " - " .. lineName)
                end
            else
                global.lines[destinationForceIndexString] = global.lines[removedForceIndexString]
                global.lineList[destinationForceIndexString] = global.lineList[removedForceIndexString]
                global.lineListDisplay[destinationForceIndexString] = global.lineListDisplay[removedForceIndexString]
            end
        end
    end,
    [eventsDefine.on_game_created_from_scenario] = function()
        initGlobals()

        for _, player in pairs(game.players) do
            initPlayer(player)
        end
    end,
    [eventsDefine.on_player_created] = function(eventData)
        initPlayer(game.players[eventData.player_index])
    end,
    [eventsDefine.on_player_removed] = function(eventData)
        if global.players then
            global.players[tostring(eventData.player_index)] = nil
        end
    end,
    [eventsDefine.on_train_changed_state] = function(eventData)
        local train = eventData.train
        local trainIdString = tostring(train.id)

        if train.state == waitStationTrainStateDefine then
            local station = train.station

            if not (station and station.valid) then return end

            local locomotive = train.front_stock or train.back_stock

            if not locomotive then return end
            if not station.force_index == locomotive.force_index then return end

            local trainLineData = { station = station, hasCircuitNetwork = false }

            if station.get_circuit_network(redWireTypeDefine) and station.get_circuit_network(greenWireTypeDefine) then
                trainLineData.hasCircuitNetwork = true
            end

            if trainLineData.hasCircuitNetwork then
                if game.active_mods["Automatic_Coupling_System"] then
                    if remote.call("automaticCoupling", "checkCoupleSignals", train) then
                        trainLineData.automaticCoupling = true
                    end
                end

                global.trainIds[trainIdString] = trainLineData
            end
        elseif eventData.old_state == waitStationTrainStateDefine and global.trainIds[trainIdString] then
            local trainLineData = global.trainIds[trainIdString]
            local station = trainLineData.station

            global.trainIds[trainIdString] = nil

            if train.state == defines.train_state.manual_control then return end
            if not (station and station.valid) then return end
            if not trainLineData.hasCircuitNetwork then return end

            local redWireCircuitNetwork = station.get_circuit_network(redWireTypeDefine)
            local greenWireCircuitNetwork = station.get_circuit_network(greenWireTypeDefine)

            if not (redWireCircuitNetwork and greenWireCircuitNetwork) then return end

            local forceIndexString = tostring(station.force_index)
            local globalLines = global.lines[forceIndexString]

            if not next(globalLines) then return end

            local highestLineSignal = { signalValue = 0 }

            train.manual_mode = true

            for lineName, lineObj in pairs(globalLines) do
                local signalValue = redWireCircuitNetwork.get_signal(lineObj.signal)

                if signalValue > highestLineSignal.signalValue then
                    highestLineSignal = { signalValue = signalValue, lineName = lineName }
                end
            end

            if not highestLineSignal.lineName then goto setTrainToAutomatic end

            do
                local lineObj = globalLines[highestLineSignal.lineName]
                local lineStations = lineObj.stations

                if not lineStations[1] then goto setTrainToAutomatic end

                local highestLineStationSignal = { signalValue = 0 }

                for i = 1, #lineStations do
                    local stationObj = lineStations[i]

                    if stationObj.signal then
                        local signalValue = greenWireCircuitNetwork.get_signal(stationObj.signal)

                        if signalValue > highestLineStationSignal.signalValue then
                            highestLineStationSignal = { signalValue = signalValue, stationIndex = i }
                        end
                    end
                end

                if highestLineStationSignal.stationIndex then
                    train.schedule = {
                        current = highestLineStationSignal.stationIndex,
                        records = lineObj.schedule.records
                    }
                end
            end

            ::setTrainToAutomatic::

            train.manual_mode = false

            if trainLineData.automaticCoupling and game.active_mods["Automatic_Coupling_System"] then
                remote.call("automaticCoupling", "doTrainCoupleLogic", train)
            end
        end
    end,
    [eventsDefine.on_train_created] = function(eventData)
        local oldTrainIdString1 = tostring(eventData.old_train_id_1)
        local oldTrainIdString2 = tostring(eventData.old_train_id_2)
        local newTrainIdString = tostring(eventData.train.id)

        if global.openTrains[oldTrainIdString1] then
            global.openTrains[newTrainIdString] = global.openTrains[oldTrainIdString1]
            global.openTrains[oldTrainIdString1] = nil
        elseif global.openTrains[oldTrainIdString2] then
            global.openTrains[newTrainIdString] = global.openTrains[oldTrainIdString2]
            global.openTrains[oldTrainIdString2] = nil
        end

        if global.trainIds[oldTrainIdString1] then
            global.trainIds[oldTrainIdString1] = nil
        end

        if global.trainIds[oldTrainIdString2] then
            global.trainIds[oldTrainIdString2] = nil
        end
    end,
    [eventsDefine.on_train_schedule_changed] = function(eventData)
        local trainIdString = tostring(eventData.train.id)

        if global.openTrains[trainIdString] then
            local globalOpenTrain = global.openTrains[trainIdString]

            if eventData.player_index then
                if globalOpenTrain.playerIndex == eventData.player_index then
                    local train = eventData.train
                    local newTrainSchedule = train.schedule

                    if newTrainSchedule then
                        for i = 1, #newTrainSchedule.records do
                            if newTrainSchedule.records[i].temporary then
                                table.remove(newTrainSchedule.records, i)
                            end
                        end

                        if #newTrainSchedule.records == 0 then
                            train.schedule = nil
                        else
                            train.schedule = newTrainSchedule
                        end
                    end

                    train.manual_mode = true
                else
                    eventData.train.schedule = globalOpenTrain.schedule
                end
            end
        end
    end
}

eventsLib.on_init = function()
    initGlobals()

    for _, player in pairs(game.players) do
        initPlayer(player)
    end
end

eventsLib.on_configuration_changed = function(eventData)
    local gameItemPrototypes = game.item_prototypes
    local gameFluidPrototypes = game.fluid_prototypes
    local gameVirtualSignalPrototypes = game.virtual_signal_prototypes
    local simpleModChanges = eventData.mod_changes and eventData.mod_changes["Simple_Circuit_Trains"] or {}

    initGlobals()

    for _, player in pairs(game.players) do
        local playerIndexString = tostring(player.index)

        initPlayer(player)

        if global.players[playerIndexString].guis.simpleGuiMain then
            global.players[playerIndexString].guis.simpleGuiMain.destroy()
        end
    end

    if next(simpleModChanges) then
        local simpleOldVersion = simpleModChanges.old_version

        if simpleOldVersion and simpleModChanges.new_version then
            if simpleOldVersion > "0.2.2" and simpleOldVersion <= "0.3.8" then
                local scriptData = global.script_data

                global.script_data = nil

                for _, player in pairs(scriptData.players) do
                    if player.frame then
                        player.frame.destroy()
                    end

                    if player.button then
                        player.button.destroy()
                    end
                end

                if scriptData.lines.number > 0 then
                    local lines = scriptData.lines
                    local stations = lines.stations

                    for lineNumber, lineName in pairs(lines.names) do
                        local stationsLineData = stations[lineNumber]
                        local lineObj = {
                            signal = lines.chooseelem[lineNumber],
                            schedule = lines.schedules[lineNumber],
                            stations = {}
                        }

                        for stationNumber, stationName in pairs(stationsLineData.stations) do
                            table.insert(lineObj.stations, {name = stationName, signal = stationsLineData.chooseelem[stationNumber]})
                        end

                        global.lines["1"][lineName] = lineObj

                        table.insert(global.lineList["1"], lineName)
                        table.insert(global.lineListDisplay["1"], util.signalToRichTextImg(lines.chooseelem[lineNumber]) .. " - " .. lineName)
                    end
                end

                for trainId, trainLineData in pairs(scriptData.trainsids) do
                    global.trainIds[trainId] = {station = trainLineData.station, hasCircuitNetwork = trainLineData.circuit}
                end
            end
        end
    end

    for _, forceLines in pairs(global.lines) do
        if next(forceLines) then
            for _, lineObj in pairs(forceLines) do
                local lineSignal = lineObj.signal
                local stations = lineObj.stations

                if lineSignal then
                    if (lineSignal.type == "item" and not gameItemPrototypes[lineSignal.name]) or (lineSignal.type == "fluid" and not gameFluidPrototypes[lineSignal.name]) or (lineSignal.type == "virtual" and not gameVirtualSignalPrototypes[lineSignal.name]) then
                        lineObj.signal = nil
                    end
                end

                for i = 1, #stations do
                    local stationSignal = stations[i].signal

                    if stationSignal then
                        if (stationSignal.type == "item" and not gameItemPrototypes[stationSignal.name]) or (stationSignal.type == "fluid" and not gameFluidPrototypes[stationSignal.name]) or (stationSignal.type == "virtual" and not gameVirtualSignalPrototypes[stationSignal.name]) then
                            stations[i].signal = nil
                        end
                    end
                end
            end
        end
    end
end

return eventsLib
