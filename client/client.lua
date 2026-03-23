local QBCore = exports['qb-core']:GetCoreObject()
local currentStop = 0
local jobStarted = false
local missionBlip = nil
local busVehicle = nil
local isWaitingAtStop = false

-- Hàm tạo Blip dẫn đường
local function AddMissionBlip(coords, label)
    if missionBlip then RemoveBlip(missionBlip) end
    
    missionBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(missionBlip, 164)
    SetBlipDisplay(missionBlip, 4)
    SetBlipScale(missionBlip, 0.8)
    SetBlipColour(missionBlip, 2)
    SetBlipRoute(missionBlip, true)
    SetBlipRouteColour(missionBlip, 2)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(label)
    EndTextCommandSetBlipName(missionBlip)
end

-- Hàm cập nhật NUI HUD
local function UpdateBusHUD(visible, statusText)
    local nextName = "---"
    local nextIndex = currentStop + 1
    
    if visible then
        if nextIndex <= #Config.BusJob.Stops then
            nextName = Config.BusJob.Stops[nextIndex].name
        else
            nextName = "Depot (Về bãi)"
        end
    end

    SendNUIMessage({
        action = "updateHud",
        visible = visible,
        current = currentStop,
        total = #Config.BusJob.Stops,
        nextStop = nextName,
        status = statusText or "Đang di chuyển",
        playSound = statusText and statusText:find("đón khách") ~= nil
    })
end

-- Hàm dọn dẹp sau khi xong việc hoặc hủy job
local function CleanupJob()
    if missionBlip then RemoveBlip(missionBlip) end
    if busVehicle then DeleteVehicle(busVehicle) end
    UpdateBusHUD(false)
    currentStop = 0
    jobStarted = false
    missionBlip = nil
    busVehicle = nil
    isWaitingAtStop = false
end

-- Vòng lặp hiển thị Marker nhận việc tại Depot
CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local depot = Config.BusJob.Depot
        
        -- Chỉ hiện marker khi chưa bắt đầu job
        if not jobStarted then
            local dist = #(pos - vector3(depot.x, depot.y, depot.z))
            
            if dist < 10.0 then
                wait = 0
                -- Vẽ Marker (Vòng sáng tại điểm nhận việc)
                DrawMarker(2, depot.x, depot.y, depot.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 0, 150, true, true, 2, false, false, false, false)
                
                if dist < 1.5 then
                    DrawText3D(depot.x, depot.y, depot.z + 0.5, "Ấn ~g~[E]~w~ để bắt đầu Nghề Bus")
                    
                    if IsControlJustReleased(0, 38) then -- Phím E
                        local pd = QBCore.Functions.GetPlayerData()
                        local dlv = pd.metadata.danglamviec
                        
                        if dlv == "none" or dlv == "Nghề Bus" then
                            TriggerServerEvent('f17_nghebus:sv:StartJob')
                            StartBusJob()
                        else
                            exports['f17notify']:Notify("Bạn đang làm việc "..dlv..", vui lòng kết thúc công việc trước!", "error", 5000)
                        end
                    end
                end
            end
        end
        Wait(wait)
    end
end)

-- Bắt đầu Job
function StartBusJob()
    if jobStarted then return end
    jobStarted = true
    currentStop = 0
    
    local depot = Config.BusJob.Depot
    local model = Config.BusJob.VehicleModel
    
    -- Spawn xe bus
    QBCore.Functions.SpawnVehicle(model, function(veh)
        busVehicle = veh
        SetVehicleNumberPlateText(veh, "BUS" .. tostring(GetPlayerServerId(PlayerId())))
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        SetEntityAsMissionEntity(veh, true, true)
        
        -- Cập nhật HUD (Hiện 0/4)
        UpdateBusHUD(true, "Đang di chuyển")
        
        -- Blip tới điểm đầu tiên (Stops[1])
        local nextIndex = currentStop + 1
        AddMissionBlip(Config.BusJob.Stops[nextIndex].coords, "~y~[Nghề Bus]~w~ Điểm dừng số " .. nextIndex)
        exports['f17notify']:Notify("Tuyến đường đã bắt đầu. Hãy di chuyển tới điểm dừng đầu tiên!", "primary", 5000)
    end, depot, true)
end

-- Vòng lặp chính xử lý check-point
CreateThread(function()
    while true do
        local wait = 1000
        if jobStarted and not isWaitingAtStop then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local target = nil
            local label = ""
            local isFinalReturn = false
            
            local nextIndex = currentStop + 1
            if nextIndex <= #Config.BusJob.Stops then
                target = Config.BusJob.Stops[nextIndex].coords
                label = "Dừng xe để đón/trả khách"
            else
                -- Quay về depot
                target = Config.BusJob.Depot
                label = "Quay về Depot để kết thúc"
                isFinalReturn = true
            end
            
            local dist = #(pos - vector3(target.x, target.y, target.z))
            
            if dist < 20.0 then
                wait = 0
                -- Vẽ Marker
                DrawMarker(1, target.x, target.y, target.z - 0.99, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 2.0, 26, 124, 173, 100, false, true, 2, false, false, false, false)
                
                if dist < 5.0 then
                    local veh = GetVehiclePedIsIn(ped, false)
                    if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
                        -- Kiểm tra xe có dừng hẳn không
                        if GetEntitySpeed(veh) < 0.1 then
                            DrawText3D(target.x, target.y, target.z + 0.5, "Đang chuẩn bị đón khách...")
                            
                            isWaitingAtStop = true
                            
                            local progressLabel = isFinalReturn and "Đang trả xe và kiểm kê..." or "Đang đón/trả khách..."
                            local progressTime = Config.BusJob.WaitTimeAtStop
                            
                            -- Cập nhật HUD trạng thái đón khách
                            UpdateBusHUD(true, progressLabel)
                            
                            QBCore.Functions.Progressbar("bus_stop", progressLabel, progressTime, false, false, {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            }, {}, {}, {}, function() -- Done
                                if isFinalReturn then
                                    UpdateBusHUD(true, "Hoàn thành tuyến")
                                    Wait(2000)
                                    TriggerServerEvent('f17_nghebus:sv:FinishJob')
                                    CleanupJob()
                                    exports['f17notify']:Notify("Đã hoàn thành tuyến đường và trả xe!", "success", 5000)
                                else
                                    -- Hoàn thành trạm hiện tại -> tăng currentStop
                                    currentStop = currentStop + 1
                                    TriggerServerEvent('f17_nghebus:sv:StopReached', currentStop, false)
                                    
                                    local statusText = "Tiếp tục tuyến"
                                    local followingIndex = currentStop + 1
                                    
                                    if followingIndex <= #Config.BusJob.Stops then
                                        AddMissionBlip(Config.BusJob.Stops[followingIndex].coords, "~y~[Nghề Bus]~w~ Điểm dừng số " .. followingIndex)
                                    else
                                        AddMissionBlip(Config.BusJob.Depot, "~y~[Nghề Bus]~w~ Quay về Depot")
                                        statusText = "Quay về bãi"
                                    end
                                    
                                    UpdateBusHUD(true, statusText)
                                    isWaitingAtStop = false
                                end
                            end, function() -- Cancel
                                UpdateBusHUD(true, "Đang di chuyển")
                                isWaitingAtStop = false
                            end)
                        else
                            DrawText3D(target.x, target.y, target.z + 0.5, "~r~Hãy dừng xe hẳn để đón khách")
                        end
                    end
                end
            end
        end
        Wait(wait)
    end
end)

-- Hàm DrawText3D (nếu chưa có trong shared)
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 90)
end
