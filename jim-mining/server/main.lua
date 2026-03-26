onResourceStart(function()
	Wait(1000)

	for k, v in pairs(Locations["Mines"]) do
		for l, b in pairs(v) do
			if l == "Store" then
				for i = 1, #b do
					registerShop("miningShop", Config.Items.label, Config.Items.items, nil, b[i].coords.xyz)
				end
			end
		end
	end

	for i = 1, #Config.CrackPool do
		if not Items[Config.CrackPool[i].item] then
			print("Missing CrackPool item: "..Config.CrackPool[i].item)
		end
	end

	for i = 1, #Config.WashPool do
		if not Items[Config.WashPool[i].item] then
			print("Missing WashPool item: "..Config.WashPool[i].item)
		end
	end

	for i = 1, #Config.PanPool do
		if not Items[Config.PanPool[i].item] then
			print("Missing PanPool item: "..Config.PanPool[i].item)
		end
	end
end, true)


RegisterNetEvent("jim-mining:server:breakTool", function(data)
    local src = source
    local itemName = data.item
    local damage = data.damage or 1

    local items = exports.ox_inventory:Search(src, 'slots', itemName)
    if not items or not items[1] then return end

    local slot = items[1].slot
    local durability = items[1].metadata and items[1].metadata.durability or 100

    durability = durability - damage

    if durability <= 0 then
        exports.ox_inventory:RemoveItem(src, itemName, 1, nil, slot)
    else
        exports.ox_inventory:SetMetadata(src, slot, {
            durability = durability
        })
    end
end)


-- =========================
-- BOSS ROCK SYSTEM
-- =========================

local BossRockHealth = {}

RegisterNetEvent("jim-mining:jackhammerHit", function(id)
    local src = source

    print("^3[JACKHAMMER] HIT RECEIVED | ID:^7", id)

    local rockData = Config.LargeRocks[id]
    if not rockData then
        print("^1[JACKHAMMER] ERROR: INVALID ROCK ID^7")
        return
    end

    if BossRockHealth[id] == nil then
        BossRockHealth[id] = rockData.health
        print("^2[JACKHAMMER] SET HEALTH:^7", BossRockHealth[id])
    else
        print("^5[JACKHAMMER] EXISTING HEALTH:^7", BossRockHealth[id])
    end

    BossRockHealth[id] = BossRockHealth[id] - 1

    print("^6[JACKHAMMER] AFTER HIT HEALTH:^7", BossRockHealth[id])

    local hp = BossRockHealth[id]
    local max = rockData.health

    if hp == math.floor(max * 0.5) then
        print("^3[JACKHAMMER] HALF WAY TRIGGER^7")
        TriggerClientEvent("ox_lib:notify", src, {
            description = "The rock is starting to crack...",
            type = "inform"
        })
    end

    if hp == 2 then
        print("^3[JACKHAMMER] LOW HP TRIGGER^7")
        TriggerClientEvent("ox_lib:notify", src, {
            description = "The rock is about to break!",
            type = "warning"
        })
    end

    if hp <= 0 then
        print("^2[JACKHAMMER] ROCK BROKEN^7")

        BossRockHealth[id] = nil

        local amount = math.random(
            Config.PickupRocks.BigRockAmount.min,
            Config.PickupRocks.BigRockAmount.max
        )

        print("^2[JACKHAMMER] SPAWNING PICKUP ROCKS:^7", amount)

        TriggerClientEvent("jim-mining:client:bossRockBreak", -1, id)
        TriggerClientEvent("jim-mining:client:spawnPickupRocks", -1, id, rockData.coords, amount)

        TriggerClientEvent("ox_lib:notify", src, {
            description = "The rock breaks apart!",
            type = "success"
        })

        SetTimeout(Config.Jackhammer.RespawnTime, function()
            print("^3[JACKHAMMER] ROCK RESPAWN^7")
            TriggerClientEvent("jim-mining:client:clearPickupRocks", -1, id)
            TriggerClientEvent("jim-mining:client:bossRockRespawn", -1, id, rockData)
        end)
    end
end)

-- =========================
-- PICKUP ROCK REWARDS
-- =========================

RegisterNetEvent("jim-mining:collectPickupRock", function()
    local src = source

    for _, reward in pairs(Config.PickupRocks.Rewards) do
        if math.random(1,100) <= reward.chance then
            local amount = math.random(reward.min, reward.max)
            exports.ox_inventory:AddItem(src, reward.item, amount)
        end
    end
end)


-- =========================
-- GOLD PAN USE
-- =========================

local panCooldown = false

RegisterNetEvent("jim-mining:useGoldPan", function()
    if panCooldown then
        lib.notify({
            description = "You're already doing that...",
            type = "error"
        })
        return
    end

    panCooldown = true

    Mining.Other.panStart()

    SetTimeout(2000, function()
        panCooldown = false
    end)
end)