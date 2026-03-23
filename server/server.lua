local QBCore = exports['qb-core']:GetCoreObject()

-- Sự kiện bắt đầu Job
RegisterNetEvent('f17_nghebus:sv:StartJob', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Cập nhật trạng thái đang làm việc
    Player.Functions.SetMetaData("danglamviec", "Nghề Bus")
    
    exports['f17notify']:Notify(src, "Bạn đã nhận việc lái xe bus. Hãy lấy xe và bắt đầu tuyến!", "success", 5000)
end)

-- Sự kiện trả thưởng sau khi hoàn thành điểm dừng
RegisterNetEvent('f17_nghebus:sv:StopReached', function(stopIndex, isFinal)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local pay = Config.BusJob.Reward.PayPerStop
    
    -- Trả tiền
    Player.Functions.AddMoney('tienkhoa', pay, "bus-job-stop")
    
    -- Thông báo
    local msg = string.format("~y~[Nghề Bus]~w~ Bạn nhận được:\n+ ~g~$%d Tiền IC~s~", pay)
    TriggerClientEvent("QBCore:Notify", src, msg, "success", 5000)
end)

-- Sự kiện hoàn thành toàn bộ công việc
RegisterNetEvent('f17_nghebus:sv:FinishJob', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local bonus = Config.BusJob.Reward.CompletionBonus
    
    -- Trả thưởng bonus
    Player.Functions.AddMoney('cash', bonus, "bus-job-bonus")
    
    -- Reset trạng thái
    Player.Functions.SetMetaData("danglamviec", "none")
    
    -- Thông báo hoàn thành
    local msg = string.format("~y~[Nghề Bus]~w~ Hoàn thành tuyến đường!\nThưởng bonus: ~g~$%d~s~", bonus)
    TriggerClientEvent("QBCore:Notify", src, msg, "success", 10000)
    
    -- Cập nhật nhiệm vụ hàng ngày
    exports['f17_nhiemvu']:UpdateMissionProgress(src, 'daynghebus', 'ns_bus', 1)
end)
