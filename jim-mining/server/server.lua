local function GetRandItemFromTable(table)
	debugPrint("^5Debug^7: ^2Picking random item from table^7")
	::start::
	local randNum = math.random(1, 100)
	local items = {}
	for _, item in ipairs(table) do
		if randNum <= tonumber(item.rarity) then
			items[#items+1] = item.item
		end
	end
	if #items == 0 then
		goto start
	end
	local rand = math.random(1, #items)
	local selectedItem = items[rand]
	debugPrint("^5Debug^7: ^2Selected item ^7'^3"..selectedItem.."^7' - ^2rand^7: "..rand.." ^2length^7: "..#items)
	return selectedItem
end

RegisterServerEvent(GetCurrentResourceName()..":Reward", function(data)
    local src = source

    local function GiveOrDropItem(player, item, amount, metadata, label)
        local canCarryAmount = exports.ox_inventory:CanCarryAmount(player, item)

        if canCarryAmount >= amount then
            exports.ox_inventory:AddItem(player, item, amount, metadata)
            return true
        elseif canCarryAmount > 0 then
            exports.ox_inventory:AddItem(player, item, canCarryAmount, metadata)
            local remaining = amount - canCarryAmount
            exports.ox_inventory:CustomDrop(label or "Reward", {
                {item, remaining, metadata}
            }, GetEntityCoords(GetPlayerPed(player)))
            triggerNotify(nil, "Inventory full! Remaining items dropped.", "error", player)
            return true
        else
            exports.ox_inventory:CustomDrop(label or "Reward", {
                {item, amount, metadata}
            }, GetEntityCoords(GetPlayerPed(player)))
            triggerNotify(nil, "Inventory full! Items dropped on ground.", "error", player)
            return false
        end
    end

    ------------------------------------------
    -- MINING (Pickaxe, Drill, Laser)
    ------------------------------------------
    if data.mine then
        local cfg = Config.Rewards.Mining
        local baseAmount = math.random(cfg.baseAmount[1], cfg.baseAmount[2])
        local toolConfig = cfg.Tools[data.tier]

        if toolConfig then
            baseAmount = math.floor(baseAmount * toolConfig.multiplier)
        end

        local success = GiveOrDropItem(src, data.setReward, baseAmount, nil, "Mining Reward")

        -- Bonus item
        if toolConfig and toolConfig.bonus and math.random(1,100) <= toolConfig.bonus.chance then
            GiveOrDropItem(src, toolConfig.bonus.item, toolConfig.bonus.amount, nil, "Mining Bonus")
        end

    ------------------------------------------
    -- CRACKING
    ------------------------------------------
    elseif data.crack then
        local cfg = Config.Rewards.Cracking
        local pool = Config[cfg.pool]  -- ✅ get actual table

        if not pool then
            print("^1ERROR: Cracking pool '" .. tostring(cfg.pool) .. "' not found^7")
            return
        end

        -- Remove the stone first
        local removed, reason = exports.ox_inventory:RemoveItem(src, "stone", data.cost or 1)
        if not removed then
            triggerNotify(nil, "You don't have enough stones to crack!", "error", src)
            return
        end

        local successCount = math.random(cfg.baseAmount[1], cfg.baseAmount[2])
        local rewards = {}

        -- Randomly pick items from the pool
        local function GetWeightedItem(pool)
            local totalWeight = 0
            for _, v in pairs(pool) do
                totalWeight = totalWeight + tonumber(v.rarity)
            end
            local rand = math.random(1, totalWeight)
            local running = 0
            for _, v in pairs(pool) do
                running = running + tonumber(v.rarity)
                if rand <= running then return v end
            end
        end

        for i = 1, successCount do
            if math.random(1, 100) <= 70 then -- 70% success chance per roll
                local selectedItem = GetWeightedItem(pool)
                if selectedItem and selectedItem.item then
                    rewards[selectedItem.item] = (rewards[selectedItem.item] or 0) + 1
                end
            end
        end

        if next(rewards) == nil then
            triggerNotify(nil, "You failed to find anything of value.", "error", src)
            return
        end

        -- Give items or drop if inventory full
        local coords = GetEntityCoords(GetPlayerPed(src))
        local dropItems = {}

        for item, amt in pairs(rewards) do
            local carryAmount = exports.ox_inventory:CanCarryAmount(src, item)
            if carryAmount > 0 then
                exports.ox_inventory:AddItem(src, item, math.min(carryAmount, amt))
                amt = amt - carryAmount
            end
            if amt > 0 then
                table.insert(dropItems, { item, amt })
            end
        end

        if #dropItems > 0 then
            exports.ox_inventory:CustomDrop("Cracking Reward", dropItems, coords)
            triggerNotify(nil, "Some items dropped on the ground because your inventory was full.", "error", src)
        else
            triggerNotify(nil, "You collected your rewards!", "success", src)
        end



    ------------------------------------------
    -- WASHING
    ------------------------------------------
    elseif data.wash then
        local cfg = Config.Rewards.Washing
        local pool = Config[cfg.pool]

        if not pool then
            print("^1ERROR: Washing pool '"..tostring(cfg.pool).."' not found^7")
            return
        end

        -- Remove the stone first
        local removed, reason = exports.ox_inventory:RemoveItem(src, "stone", data.cost or 1)
        if not removed then
            triggerNotify(nil, "You don't have enough stones to wash!", "error", src)
            return
        end

        local successCount = math.random(cfg.successes[1], cfg.successes[2])
        local rewards = {}

        local function GetWeightedItem(pool)
            local totalWeight = 0
            for _, v in pairs(pool) do totalWeight = totalWeight + tonumber(v.rarity) end
            local rand = math.random(1, totalWeight)
            local running = 0
            for _, v in pairs(pool) do
                running = running + tonumber(v.rarity)
                if rand <= running then return v end
            end
        end

        for i = 1, successCount do
            if math.random(1,100) <= 70 then
                local selectedItem = GetWeightedItem(pool)
                if selectedItem and selectedItem.item then
                    local minAmount, maxAmount = table.unpack(cfg.baseAmount)
                    local amt = math.random(minAmount, maxAmount)
                    rewards[selectedItem.item] = (rewards[selectedItem.item] or 0) + amt

                    if cfg.bonus and math.random(1,100) <= cfg.bonus.chance then
                        rewards[cfg.bonus.item] = (rewards[cfg.bonus.item] or 0) + cfg.bonus.amount
                    end
                end
            end
        end

        if next(rewards) == nil then
            triggerNotify(nil, "You failed to find anything of value.", "error", src)
            return
        end

        local coords = GetEntityCoords(GetPlayerPed(src))
        local dropItems = {}

        for item, amt in pairs(rewards) do
            local carryAmount = exports.ox_inventory:CanCarryAmount(src, item)
            if carryAmount > 0 then
                addItem(item, math.min(carryAmount, amt), nil, src)
                amt = amt - carryAmount
            end
            if amt > 0 then
                table.insert(dropItems, {item, amt})
            end
        end

        if #dropItems > 0 then
            exports.ox_inventory:CustomDrop("Stone Wash", dropItems, coords)
            triggerNotify(nil, "Some items dropped on the ground because your inventory was full.", "error", src)
        else
            triggerNotify(nil, "You collected your rewards!", "success", src)
        end
    



    ------------------------------------------
    -- GOLD PANNING
    ------------------------------------------
    elseif data.pan then
        local cfg = Config.Rewards.Panning
        local pool = Config[cfg.pool]

        if not pool then return end

        local successCount = math.random(cfg.successes[1], cfg.successes[2])
        local rewards = {}

        -- Weighted random selection
        local function GetWeightedItem(pool)
            local totalWeight = 0
            for _, v in pairs(pool) do totalWeight = totalWeight + tonumber(v.rarity) end
            local rand = math.random(1, totalWeight)
            local running = 0
            for _, v in pairs(pool) do
                running = running + tonumber(v.rarity)
                if rand <= running then return v end
            end
        end

        for i = 1, successCount do
            if math.random(1,100) <= 70 then
                local selectedItem = GetWeightedItem(pool)
                if selectedItem and selectedItem.item then
                    local minAmount, maxAmount = table.unpack(cfg.baseAmount)
                    local amt = math.random(minAmount, maxAmount)
                    rewards[selectedItem.item] = (rewards[selectedItem.item] or 0) + amt

                    if cfg.bonus and math.random(1,100) <= cfg.bonus.chance then
                        rewards[cfg.bonus.item] = (rewards[cfg.bonus.item] or 0) + cfg.bonus.amount
                    end
                end
            end
        end

        -- Check if any rewards were generated
        if next(rewards) == nil then
            triggerNotify(nil, "You failed to find anything of value.", "error", src)
            return
        end

        -- Give items or drop if over weight
        local canCarryAll = true
        for item, amt in pairs(rewards) do
            local carryAmount = exports.ox_inventory:CanCarryAmount(src, item)
            if carryAmount < amt then
                canCarryAll = false
                break
            end
        end

        if canCarryAll then
            for item, amt in pairs(rewards) do
                addItem(item, amt, nil, src)
            end
            triggerNotify(nil, "You collected your rewards!", "success", src)
        else
            local coords = GetEntityCoords(GetPlayerPed(src))
            local dropItems = {}
            for item, amt in pairs(rewards) do
                local carryAmount = exports.ox_inventory:CanCarryAmount(src, item)
                if carryAmount > 0 then
                    addItem(item, carryAmount, nil, src)
                    amt = amt - carryAmount
                end
                if amt > 0 then
                    table.insert(dropItems, { item, amt })
                end
            end
            exports.ox_inventory:CustomDrop("Gold Pan", dropItems, coords)
            triggerNotify(nil, "Your inventory is full! Items dropped on the ground.", "error", src)
        end
    end

end)


RegisterNetEvent("jim-mining:server:RepairToolFromTool", function(slot)
    local src = source
    local item = exports.ox_inventory:GetSlot(src, slot)
    if not item then return end

    -- Define which repair item each tool needs
    local repairItems = {
        pickaxe = "sharpening_stone",
        miningdrill = "drillbit",
        mininglaser = "laser_lens"
    }

    local repairItem = repairItems[item.name]
    if not repairItem then
        TriggerClientEvent("ox_lib:notify", src, { type = "error", description = "This tool cannot be repaired." })
        return
    end

    -- Make sure player has the repair item
    if exports.ox_inventory:Search(src, "count", repairItem) < 1 then
        TriggerClientEvent("ox_lib:notify", src, { type = "error", description = "You need a " .. exports.ox_inventory:Items()[repairItem].label .. " to repair this." })
        return
    end

    -- Remove one repair item
    exports.ox_inventory:RemoveItem(src, repairItem, 1)

    -- Get current metadata (durability)
    local meta = item.metadata or {}
    local durability = meta.durability or 0
    local restoreAmount, maxDurability = 50, 100

    -- Repair logic
    meta.durability = math.min(durability + restoreAmount, maxDurability)
    exports.ox_inventory:SetMetadata(src, item.slot, meta)

    TriggerClientEvent("ox_lib:notify", src, {
        type = "success",
        description = ("Your %s has been repaired to %d%%."):format(item.label, meta.durability)
    })
end)






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

	--registerShop("miningShop", Config.Items.label, Config.Items.items)

	for k in pairs(Selling) do
		if Selling[k].Items then
			for b in pairs(Selling[k].Items) do
				if not Items[b] then print("Selling: Missing Item from Items: '"..b.."'") end
			end
		else
			for l in pairs(Selling[k]) do
				if l ~= "Header" then
					for b in pairs(Selling[k][l].Items) do
						if not Items[b] then print("Selling: Missing Item from Items: '"..b.."'") end
					end
				end
			end
		end
	end
	for i = 1, #Config.CrackPool do if not Items[Config.CrackPool[i].item] then print("CrackPool: Missing Item from Items: '"..Config.CrackPool[i].item.."'") end end
	for i = 1, #Config.WashPool do if not Items[Config.WashPool[i].item] then print("WashPool: Missing Item from Items: '"..Config.WashPool[i].item.."'") end end
	for i = 1, #Config.PanPool do if not Items[Config.PanPool[i].item] then print("PanPool: Missing Item from Items: '"..Config.PanPool[i].item.."'") end end
	for i = 1, #Config.Items.items do if not Items[Config.Items.items[i].name] then print("Shop: Missing Item from Items: '"..Config.Items.items[i].name.."'") end end
	local itemcheck = {}
	for _, v in pairs(Crafting) do
		if type(v) == "table" then
			for _, b in pairs(v.Recipes) do
				for k, l in pairs(b) do
					if k ~= "amount" then
						itemcheck[k] = {}
						for j in pairs(l) do
							itemcheck[j] = {}
						end
					end
				end
			end
		end
	end
	for k in pairs(itemcheck) do
		if not Items[k] then print("Crafting recipe couldn't find item '"..k.."' in the shared") end
	end
end, true)