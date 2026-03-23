Config = Config or {}

Config.BusJob = {
    -- Vị trí lấy xe (Depot)
    Depot = vector4(-1183.81, -1495.84, 4.38, 291.61),
    
    -- Model xe bus
    VehicleModel = "bus",
    
    -- Danh sách các điểm dừng theo thứ tự
    Stops = {
        { coords = vector4(-1212.28, -1218.97, 7.59, 5.12), name = "Downtown" },
        { coords = vector4(-557.64, -846.14, 27.54, 313.86), name = "Legion Square" },
        { coords = vector4(785.77, -777.21, 26.33, 97.54), name = "Vinewood" },
        { coords = vector4(-147.12, -1985.99, 22.81, 338.83), name = "Little Seoul" },
    },
    
    -- Cài đặt phần thưởng
    Reward = {
        PayPerStop = 500,        -- Tiền cho mỗi điểm dừng
        CompletionBonus = 2000, -- Thưởng khi hoàn thành toàn bộ tuyến
    },
    
    -- Cài đặt thời gian
    WaitTimeAtStop = 15000, -- 15 giây chờ khách (để NPC lên/xuống xe)

    -- Danh sách model NPC đón xe
    BusPeds = {
        "a_m_m_skater_01",
        "a_m_m_salton_01",
        "a_m_y_beach_01",
        "a_m_y_business_02",
        "a_f_m_bevhills_01",
        "a_f_y_fitness_01",
    }
}
