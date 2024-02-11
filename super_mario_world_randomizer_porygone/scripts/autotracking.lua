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

    for _, location_array in pairs(LOCATION_MAPPING) do
        for _, location in pairs(location_array) do
            if location then
                local obj = Tracker:FindObjectForCode(location)
                if obj then
                    if location:sub(1, 1) == "@" then
                        obj.AvailableChestCount = obj.ChestCount
                    else
                        obj.Active = false
                    end
                end
            end
        end
    end

    if SLOT_DATA == nil then
        return
    end

    if slot_data['dragon_coin_checks'] then
        local dragon_coins = Tracker:FindObjectForCode("dragon_coin_checks")
        dragon_coins.Active = (slot_data['dragon_coin_checks'] ~= 0)
    end
    if slot_data['moon_checks'] then
        local moons = Tracker:FindObjectForCode("moon_checks")
        moons.Active = (slot_data['moon_checks'] ~= 0)
    end
    if slot_data['hidden_1up_checks'] then
        local hidden_1ups = Tracker:FindObjectForCode("hidden_1up_checks")
        hidden_1ups.Active = (slot_data['hidden_1up_checks'] ~= 0)
    end
    if slot_data['bonus_block_checks'] then
        local bonus_blocks = Tracker:FindObjectForCode("bonus_block_checks")
        bonus_blocks.Active = (slot_data['bonus_block_checks'] ~= 0)
    end
    if slot_data['blocksanity'] then
        local blocksanity = Tracker:FindObjectForCode("blocksanity")
        blocksanity.Active = (slot_data['blocksanity'] ~= 0)
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
    local location_array = LOCATION_MAPPING[location_id]
    if not location_array or not location_array[1] then
        print(string.format("onLocation: could not find location mapping for id %s", location_id))
        return
    end

    for _, location in pairs(location_array) do
        local obj = Tracker:FindObjectForCode(location)
        if obj then
            if location:sub(1,1) == "@" then
                obj.AvailableChestCount = obj.AvailableChestCount - 1 
            else
                obj.Active = true
            end
        else 
            print(string.format("onLocation: could not find object for code %s", location))
        end
    end
end


Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)
