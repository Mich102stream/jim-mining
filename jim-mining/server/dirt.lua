-- =========================
-- DIRT SYSTEM
-- =========================

local function GetDirtData(coords)
    for _, zone in pairs(Config.DigZones or {}) do
        if #(coords - zone.coords) <= zone.radius then
            return zone.quality, zone.label
        end
    end
    return 1.0, "Unknown Soil"
end

RegisterNetEvent("jim-mining:fillBag", function(bagType)
    local src = tonumber(source)
    local bag = Config.DirtSystem.Bags[bagType]
    if not bag then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)

    local quality, label = GetDirtData(coords)

    if exports.ox_inventory:RemoveItem(src, bag.empty, 1) then
        exports.ox_inventory:AddItem(src, bag.filled, 1, {
            uses = bag.uses,
            durability = 100,
            quality = quality,
            location = label,
            description = label
        })
    end
end)

RegisterNetEvent("jim-mining:washBag", function(bagType)
    local src = tonumber(source)
    local bag = Config.DirtSystem.Bags[bagType]
    if not bag then return end

    local items = exports.ox_inventory:Search(src, 'slots', bag.filled)
    if not items or not items[1] then return end

    local slot = items[1].slot
    local metadata = items[1].metadata or {}

    local usesLeft = tonumber(metadata.uses) or bag.uses
    local quality = tonumber(metadata.quality) or 1.0

    if usesLeft <= 0 then
        exports.ox_inventory:RemoveItem(src, bag.filled, 1, nil, slot)
        return
    end

    local rewardsGiven = false

    local cfg = Config.Rewards.Panning
    local pool = Config[cfg.pool]

    local successCount = math.random(cfg.successes[1], cfg.successes[2])
    successCount = math.floor(successCount * (bag.uses / 3) * quality)

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
        if math.random(1,100) <= 75 then
            local item = GetWeightedItem(pool)
            if item then
                local amount = math.random(cfg.baseAmount[1], cfg.baseAmount[2])

                local metadataReward = nil

                if item.item == "goldnugget" then
                    local size = math.random(1,100)
                    local purity = math.random(60,100)

                    metadataReward = {
                        size = size,
                        purity = purity,
                        description = "Size: "..size.."g\nPurity: "..purity.."%"
                    }

                    if size >= 90 then
                        TriggerClientEvent("ox_lib:notify", src, {
                            description = "JACKPOT! You found a massive gold nugget!",
                            type = "success"
                        })
                    end
                end

                local canCarry = exports.ox_inventory:CanCarryAmount(src, item.item)
                canCarry = tonumber(canCarry) or 0

                if canCarry >= amount then
                    exports.ox_inventory:AddItem(src, item.item, amount, metadataReward)
                    rewardsGiven = true
                else
                    TriggerClientEvent("ox_lib:notify", src, {
                        description = "Inventory full",
                        type = "error"
                    })
                    break
                end
            end
        end
    end

    if not rewardsGiven then
        TriggerClientEvent("ox_lib:notify", src, {
            description = "You found nothing...",
            type = "error"
        })
    else
        TriggerClientEvent("ox_lib:notify", src, {
            description = "You found something in the dirt!",
            type = "success"
        })
    end

    usesLeft = usesLeft - 1

    if usesLeft <= 0 then
        exports.ox_inventory:RemoveItem(src, bag.filled, 1, nil, slot)
    else
        local percent = math.floor((usesLeft / bag.uses) * 100)

        exports.ox_inventory:SetMetadata(src, slot, {
            uses = usesLeft,
            durability = percent,
            quality = quality,
            location = metadata.location
        })
    end
end)