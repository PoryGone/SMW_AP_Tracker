ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

LEVEL_UNLOCKS = {}



CUR_INDEX = -1
SLOT_DATA = nil


function onClear(slot_data)
    SLOT_DATA = slot_data
    CUR_INDEX = -1

    for _, v in pairs(ITEM_MAPPING) do
        if v[1] then
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[2] == "toggle" then
                    obj.Active = false
                elseif v[2] == "progressive" then
                    if obj.Active then
                        obj.CurrentStage = 0
                    --else
                    --    obj.Active = true
                    end
                elseif v[2] == "consumable" then
                    obj.AcquiredCount = 0
                end
            end
        end
    end
    for _, v in pairs(SETTINGS_MAPPING) do
        if v[1] then
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                obj.AcquiredCount = 0
            end
        end
    end

    for k, v in pairs(LOCATION_MAPPING) do
        local loc_data = LOCATION_MAPPING[k]
        local loc_name = loc_data[1]
        local loc_type = loc_data[2]
        local level_str = "@" .. loc_name .. "/" .. loc_type
        local obj = Tracker:FindObjectForCode(level_str)
        if obj then
                obj.AvailableChestCount = obj.ChestCount
        end
        
    end

    if SLOT_DATA == nil then
        return
    end

    if slot_data['dragon_coin_checks'] then
        local dragon_coins = Tracker:FindObjectForCode("dragon_coin_checks")
        dragon_coins.Active = (slot_data['dragon_coin_checks'] ~= 0)
    end
end

function onItem(index, item_id, item_name, player_number)
    if index <= CUR_INDEX then return end
    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index;
    
    local v = ITEM_MAPPING[item_id]
    if not v then
        return
    end

    if not v[1] then
        return
    end

    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[2] == "toggle" then
            obj.Active = true
        elseif v[2] == "progressive" then
            if obj.Active then
                obj.CurrentStage = obj.CurrentStage + 1
            else
                obj.Active = true
            end
        elseif v[2] == "consumable" then
            obj.AcquiredCount = obj.AcquiredCount + obj.Increment
        end
    end
end

function onLocation(location_id, location_name)

    print(location_name)

    local loc_data = LOCATION_MAPPING[location_id]
    if not loc_data then
        return
    end
    local loc_name = loc_data[1]
    local loc_type = loc_data[2]
    local level_str = "@" .. loc_name .. "/" .. loc_type
    local obj = Tracker:FindObjectForCode(level_str)
    if obj then
        obj.AvailableChestCount = obj.AvailableChestCount - 1
    end
end


Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)
