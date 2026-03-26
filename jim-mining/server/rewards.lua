RegisterServerEvent(GetCurrentResourceName()..":Reward", function(data)
    local src = source

    local function GiveOrDropItem(player, item, amount, metadata, label)
        if not player or player <= 0 then return false end
        if not item or item == "" then return false end

        amount = tonumber(amount) or 0
        if amount <= 0 then return false end

        local canCarryAmount = tonumber(exports.ox_inventory:CanCarryAmount(player, item)) or 0

        if canCarryAmount >= amount then
            exports.ox_inventory:AddItem(player, item, amount, metadata)
            return true

        elseif canCarryAmount > 0 then
            exports.ox_inventory:AddItem(player, item, canCarryAmount, metadata)

            local remaining = amount - canCarryAmount
            if remaining > 0 then
                exports.ox_inventory:CustomDrop(label or "Reward", {
                    {item, remaining, metadata}
                }, GetEntityCoords(GetPlayerPed(player)))
            end
            return true

        else
            exports.ox_inventory:CustomDrop(label or "Reward", {
                {item, amount, metadata}
            }, GetEntityCoords(GetPlayerPed(player)))
            return false
        end
    end

    ------------------------------------------
    -- MINING
    ------------------------------------------
    if data.mine then
        local cfg = Config.Rewards.Mining
        local baseAmount = math.random(cfg.baseAmount[1], cfg.baseAmount[2])
        local toolConfig = cfg.Tools[data.tier]

        if toolConfig then
            baseAmount = math.floor(baseAmount * toolConfig.multiplier)
        end

        GiveOrDropItem(src, data.setReward, baseAmount, nil, "Mining Reward")

        if toolConfig and toolConfig.bonus and math.random(1,100) <= toolConfig.bonus.chance then
            GiveOrDropItem(src, toolConfig.bonus.item, toolConfig.bonus.amount, nil, "Mining Bonus")
        end

        if math.random(1,100) <= Config.PickupRocks.SmallRockChance then
            local ped = GetPlayerPed(src)
            if ped and ped ~= 0 then
                local coords = GetEntityCoords(ped)
                TriggerClientEvent("jim-mining:client:spawnPickupRocks", src, "bonus", coords, 1)
            end
        end

    ------------------------------------------
    -- CRACKING
    ------------------------------------------
    elseif data.crack then
        local cfg = Config.Rewards.Cracking
        local pool = Config[cfg.pool]

        local removed = exports.ox_inventory:RemoveItem(src, "stone", data.cost or 1)
        if not removed then return end

        local successCount = math.random(cfg.baseAmount[1], cfg.baseAmount[2])
        local rewards = {}

        local function GetWeightedItem(pool)
            local totalWeight = 0
            for _, v in pairs(pool) do totalWeight += tonumber(v.rarity) end
            local rand = math.random(1, totalWeight)
            local running = 0
            for _, v in pairs(pool) do
                running += tonumber(v.rarity)
                if rand <= running then return v end
            end
        end

        for i = 1, successCount do
            if math.random(1,100) <= 70 then
                local item = GetWeightedItem(pool)
                if item then
                    rewards[item.item] = (rewards[item.item] or 0) + 1
                end
            end
        end

        for item, amt in pairs(rewards) do
            GiveOrDropItem(src, item, amt, nil, "Cracking Reward")
        end

    ------------------------------------------
    -- WASHING
    ------------------------------------------
    elseif data.wash then
        local cfg = Config.Rewards.Washing
        local pool = Config[cfg.pool]

        local removed = exports.ox_inventory:RemoveItem(src, "stone", data.cost or 1)
        if not removed then return end

        local successCount = math.random(cfg.successes[1], cfg.successes[2])

        for i = 1, successCount do
            if math.random(1,100) <= 70 then
                local item = pool[math.random(#pool)]
                local amt = math.random(cfg.baseAmount[1], cfg.baseAmount[2])
                GiveOrDropItem(src, item.item, amt, nil, "Wash Reward")
            end
        end
    end
end)