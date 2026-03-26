-- =========================
-- JOB SETUP / TARGET SPAWN
-- =========================

Mining.Functions.makeJob = function()
	Mining.Functions.removeJob()

	if Locations["Mines"]["MineShaft"].Enable then
		CreateModelHide(vec3(-596.04, 2089.01, 131.41), 10.5, `prop_mineshaft_door`, true)
	end

	for mine, loc in pairs(Locations["Mines"]) do
		if loc.Enable then

		-- ORE SPAWNING
			if loc["OrePositions"] then
				for i, coords in ipairs(loc["OrePositions"]) do
					local name = "Ore_"..mine.."_"..i
					local chosenProp, reward = Mining.PropTable[math.random(#Mining.PropTable)], "stone"

					if Config.General.AltMining then
						local weightedReward = Mining.Functions.weightedRandomReward()
						chosenProp = { full = weightedReward.prop, empty = nil }
						reward = weightedReward.name
					end

					local mainProp = Mining.Functions.spawnProp(coords, chosenProp.full, Config.General.K4MB1Prop and 0.8 or 1.1)
					local emptyProp

					if chosenProp.empty then
						emptyProp = Mining.Functions.spawnProp(coords, chosenProp.empty, Config.General.K4MB1Prop and 0.8 or 1.1)
					end

					Mining.Functions.setupMiningTarget(name, coords, mainProp, emptyProp, reward, loc.Job)
				end
			end

		-- BLIPS
			if loc.Blip.Enable then
				Mining.Blips[#Mining.Blips+1] = makeBlip(loc["Blip"])
			end

		-- STORE 
			if loc["Store"] then
				for i = 1, #loc["Store"] do
					local name = getScript()..":Store:"..mine..":"..i

					Mining.Peds[#Mining.Peds+1] = makePed(loc["Store"][i].model, loc["Store"][i].coords, 1, 1, loc["Store"][i].scenario)

					Mining.Targets[name] = createCircleTarget({
						name, loc["Store"][i].coords.xyz, 1.0,
						{ name=name, debugPoly=debugMode, useZ=true }
					},{
						{
							action = function()
								openShop({ items = Config.Items, shop = "miningShop", coords = loc["Store"][i].coords })
							end,
							icon = "fas fa-store",
							label = locale("info", "browse_store"),
							job = loc.Job,
						},
					}, 2.0)
				end
			end

		-- SMELTING 
			if loc["Smelting"] then
				for i = 1, #loc["Smelting"] do
					local name = getScript()..":Smelting:"..i

					if loc["Smelting"][i].Enable then
						Mining.Blips[#Mining.Blips+1] = makeBlip(loc["Smelting"][i])
					end

					Mining.Targets[name] = createCircleTarget({
						name, loc["Smelting"][i].coords.xyz, 3.0,
						{ name=name, debugPoly=debugMode, useZ=true }
					},{
						{
							action = function()
								craftingMenu({ craftable = Crafting.SmeltMenu, coords = loc["Smelting"][i].coords })
							end,
							icon = "fas fa-fire-burner",
							label = locale("info", "use_smelter"),
							job = loc.Job,
							canInteract = function() return not CraftLock end,
						},
					}, 10.0)
				end
			end

		-- CRACKING 
			if loc["Cracking"] then
				for i = 1, #loc["Cracking"] do
					local name = getScript()..":Cracking:"..mine..":"..i

					Mining.Props[#Mining.Props+1] = makeProp(loc["Cracking"][i], 1, false)
					local bench = Mining.Props[#Mining.Props]

					Mining.Targets[name] = createCircleTarget({
						name, loc["Cracking"][i].coords.xyz, 1.2,
						{ name=name, debugPoly=debugMode, useZ=true }
					},{
						{
							action = function()
								Mining.Other.crackStart({ bench = bench })
							end,
							icon = "fas fa-compact-disc",
							label = locale("info", "crackingbench"),
							item = "stone",
							canInteract = function() return not Cracking end,
						},
					}, 2.0)
				end
			end

		-- ORE BUYER 
			if loc["OreBuyer"] then
				for i = 1, #loc["OreBuyer"] do
					local name = getScript()..":OreBuyer:"..mine..":"..i

					Mining.Peds[#Mining.Peds+1] = makePed(loc["OreBuyer"][i].model, loc["OreBuyer"][i].coords, 1, 1, loc["OreBuyer"][i].scenario)
					local ped = Mining.Peds[#Mining.Peds]

					Mining.Targets[name] = createCircleTarget({
						name, loc["OreBuyer"][i].coords.xyz, 0.9,
						{ name=name, debugPoly=debugMode, useZ=true }
					},{
						{
							action = function()
								sellMenu({ ped = ped, sellTable = Selling["OreSell"] })
							end,
							icon = "fas fa-sack-dollar",
							label = locale("info", "sell_ores"),
						},
					}, 2.0)
				end
			end

		end
	end
end

-- =========================
-- STONE RESPAWN
-- =========================

Mining.Other.stoneBreak = function(name, stone, coords, job, rot, empty)
	CreateThread(function()
		removeZoneTarget(Mining.Targets[name])
		Mining.Targets[name] = nil

		SetEntityAlpha(stone, 0)
		Wait(GetTiming(Config.Timings["OreRespawn"]))
		SetEntityAlpha(stone, 255)

		Mining.Functions.setupMiningTarget(name, coords, stone, empty, "stone", job)
	end)
end

-- =========================
-- CLEANUP / EVENTS
-- =========================

Mining.Functions.removeJob = function()
	for k in pairs(Mining.Targets) do removeZoneTarget(k) end
	for _, v in pairs(Mining.Peds) do DeletePed(v) end
	for i = 1, #Mining.Props do DeleteObject(Mining.Props[i]) end
	for i = 1, #Mining.Blips do RemoveBlip(Mining.Blips[i]) end
end

onResourceStop(Mining.Functions.removeJob, true)

onPlayerLoaded(function()
	Wait(1000)
	Mining.Functions.checkForJob()
end, true)

-- =========================
-- DIRT SYSTEM
-- =========================

function DigDirt(bagType)
    local bag = Config.DirtSystem.Bags[bagType]
    if not bag then return end

    if exports.ox_inventory:Search('count', bag.empty) < 1 then
        lib.notify({ description = "You need an empty bag", type = "error" })
        return
    end

    if exports.ox_inventory:Search('count', Config.DirtSystem.shovelItem) < 1 then
        lib.notify({ description = "You need a shovel", type = "error" })
        return
    end

    if lib.progressBar({
        duration = Config.DirtSystem.DigTime,
        label = "Filling dirt bag..."
    }) then
        TriggerServerEvent("jim-mining:fillBag", bagType)
    end
end

-- =========================
-- JACKHAMMER
-- =========================

function UseJackhammer(id)
    if lib.progressBar({
        duration = 5000,
        label = "Breaking rock..."
    }) then
        TriggerServerEvent("jim-mining:damageRock", id)
    end
end

-- =========================
-- BOSS ROCK SYSTEM
-- =========================

local spawnedBossRocks = {}

CreateThread(function()
    for id, data in pairs(Config.LargeRocks) do
        spawnBossRock(id, data)
    end
end)

function spawnBossRock(id, data)
    local rock = makeProp({
        prop = Config.Jackhammer.Prop,
        coords = vec4(data.coords.x, data.coords.y, data.coords.z - 1.0, 0.0)
    }, true, false)

    spawnedBossRocks[id] = rock

    exports.ox_target:addLocalEntity(rock, {
        {
            name = "bossrock_"..id,
            icon = "fa-solid fa-hammer",
            label = "Break Large Rock",
            items = "jackhammer",
            onSelect = function()
                Mining.MineOre.jackhammer({
                    id = id,
                    stone = rock
                })
            end,
            canInteract = function(entity)
                return entity == rock
            end
        }
    })
end

-- =========================
-- BOSS ROCK EVENTS
-- =========================

RegisterNetEvent("jim-mining:client:bossRockBreak", function(id)
    local rock = spawnedBossRocks[id]
    if not rock then return end

    local coords = GetEntityCoords(rock)

    RequestNamedPtfxAsset("core")
    while not HasNamedPtfxAssetLoaded("core") do Wait(0) end

    UseParticleFxAssetNextCall("core")

    StartParticleFxNonLoopedAtCoord(
        "ent_dst_rocks",
        coords.x, coords.y, coords.z + 0.3,
        0.0, 0.0, 0.0,
        1.5,
        false, false, false
    )

    DeleteObject(rock)
    spawnedBossRocks[id] = nil
end)

RegisterNetEvent("jim-mining:client:bossRockRespawn", function(id, data)
    spawnBossRock(id, data)
end)

-- =========================
-- PICKUP ROCK SYSTEM
-- =========================

local spawnedPickupRocks = {}

RegisterNetEvent("jim-mining:client:spawnPickupRocks", function(id, coords, amount)
    for i = 1, amount do
        local offset = vector3(
            math.random(-6, 6),
            math.random(-6, 6),
            0.0
        )

        local x = coords.x + offset.x
        local y = coords.y + offset.y
        local z = coords.z + 2.5

        local prop = makeProp({
            prop = Config.PickupRocks.Prop,
            coords = vec4(x, y, z, 0.0)
        }, true, false)

        Wait(100)

        PlaceObjectOnGroundProperly(prop)
        SetEntityRotation(prop, 0.0, 0.0, math.random(0, 360), 2, true)
        FreezeEntityPosition(prop, true)

        local name = "pickupRock_"..id.."_"..i
        spawnedPickupRocks[name] = prop
    end
end)

function CollectPickupRock(name)
    if not spawnedPickupRocks[name] then return end

    if lib.progressBar({
        duration = 2500,
        label = "Collecting rock...",
        canCancel = true
    }) then
        TriggerServerEvent("jim-mining:collectPickupRock")
        DeleteObject(spawnedPickupRocks[name])
        spawnedPickupRocks[name] = nil
        Wait(500)
    end
end

RegisterNetEvent("jim-mining:client:clearPickupRocks", function(id)
    for name, ent in pairs(spawnedPickupRocks) do
        if string.find(name, "pickupRock_"..id) then
            DeleteObject(ent)
            spawnedPickupRocks[name] = nil
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for name, ent in pairs(spawnedPickupRocks) do
            if DoesEntityExist(ent) then
                local rockCoords = GetEntityCoords(ent)
                local dist = #(coords - rockCoords)

                if dist < 2.0 then
                    sleep = 0

                    lib.showTextUI("[E] Collect Rock")

                    if IsControlJustReleased(0, 38) then
                        lib.hideTextUI()
                        CollectPickupRock(name)
                    end
                end
            end
        end

        if sleep > 0 then
            lib.hideTextUI()
        end

        Wait(sleep)
    end
end)

-- =========================
-- GOLD PAN USE EVENT
-- =========================

RegisterNetEvent("jim-mining:useGoldPan", function()
    Mining.Other.panStart()
end)