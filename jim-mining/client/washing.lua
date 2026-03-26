-- =========================
-- STATES
-- =========================

Mining.Washing = false
Mining.Panning = false

-- =========================
-- GET DIRT BAG
-- =========================

local function GetDirtBag()
    for type, data in pairs(Config.DirtSystem.Bags) do
        local count = exports.ox_inventory:Search('count', data.filled)
        if count and count > 0 then
            return type, data
        end
    end
    return nil
end

-- =========================
-- WATER CHECK 
-- =========================

local function IsPlayerInWater(ped)
    local coords = GetEntityCoords(ped)

    if IsEntityInWater(ped) then return true end

    local found, waterHeight = GetWaterHeight(coords.x, coords.y, coords.z)
    if found and waterHeight > coords.z - 1.0 then
        return true
    end

    return false
end

-- =========================
-- WASHING
-- =========================

Mining.Other.washStart = function(data)
    local Ped = PlayerPedId()
    if Mining.Washing then return end

    if not IsPlayerInWater(Ped) then
        lib.notify({
            description = "You need to be in water",
            type = "error"
        })
        return
    end

    local bagType, bagData = GetDirtBag()
    local usingBag = bagType ~= nil
    local cost = 1

    if not usingBag and not hasItem("stone", cost) then
        triggerNotify(nil, locale("error", "no_stone"), 'error')
        return
    end

    Mining.Washing = true
    lockInv(true)

    local Rock = makeProp({ prop = "prop_rock_5_smash1", coords = vec4(0, 0, 0, 0)}, 0, 1)
    AttachEntityToEntity(Rock, Ped, GetPedBoneIndex(Ped, 60309),
        0.1, 0.0, 0.05,
        90.0, -90.0, 90.0,
        true, true, false, true, 1, true)

    local dict = "amb@world_human_bum_wash@male@low@base"
    local anim = "base"

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(100) end

    TaskPlayAnim(Ped, dict, anim, 3.0, 3.0, -1, 1, 0, false, false, false)

    CreateThread(function()
        while Mining.Washing do
            if not IsEntityPlayingAnim(Ped, dict, anim, 3) then
                TaskPlayAnim(Ped, dict, anim, 3.0, 3.0, -1, 1, 0, false, false, false)
            end
            Wait(1000)
        end
    end)

    local waterFx
    CreateThread(function()
        Wait(3000)
        loadPtfxDict("core")
        while Mining.Washing do
            UseParticleFxAssetNextCall("core")
            waterFx = StartNetworkedParticleFxLoopedOnEntity(
                "water_splash_veh_out",
                Ped,
                0.0, 1.0, -0.2,
                0.0, 0.0, 0.0,
                2.0, 0, 0, 0
            )
            Wait(500)
        end
    end)

    if progressBar({
        label = usingBag and "Washing dirt..." or locale("info", "washing_stone"),
        time = usingBag and Config.DirtSystem.WashTime or GetTiming(Config.Timings["Washing"]),
        cancel = true,
        icon = "stone"
    }) then
        if usingBag then
            TriggerServerEvent("jim-mining:washBag", bagType)
        else
            TriggerServerEvent(getScript()..":Reward", { wash = true, cost = cost })
        end
    end

    StopAnimTask(Ped, dict, anim, 1.0)
    StopParticleFxLooped(waterFx, 0)
    destroyProp(Rock)
    unloadPtfxDict("core")

    lockInv(false)
    Mining.Washing = false
    ClearPedTasks(Ped)
end

-- =========================
-- PANNING SYSTEM
-- =========================

local isPanning = false

local function IsInWater()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    return IsEntityInWater(ped)
        or TestVerticalProbeAgainstAllWater(coords.x, coords.y, coords.z, 0, 1)
end

local function OpenPanMenu()
    local options = {}

    for type, data in pairs(Config.DirtSystem.Bags) do
        local items = exports.ox_inventory:Search('slots', data.filled)

        if items and items[1] then
            local metadata = items[1].metadata or {}
            local usesLeft = metadata.uses or data.uses
            local durability = metadata.durability or 100

            options[#options+1] = {
                title = type:gsub("^%l", string.upper).." Dirt Bag",
                description = "Uses left: "..usesLeft.." | "..durability.."%",
                icon = "fas fa-water",
                onSelect = function()
                    StartPanning(type)
                end
            }
        end
    end

    if #options == 0 then
        lib.notify({
            description = "You have no filled dirt bags",
            type = "error"
        })
        return
    end

    lib.registerContext({
        id = 'pan_menu',
        title = 'Select Dirt Bag',
        options = options
    })

    lib.showContext('pan_menu')
end

function StartPanning(bagType)
    local ped = PlayerPedId()

    if not IsInWater() then
        lib.notify({
            description = "You must be near water",
            type = "error"
        })
        return
    end

    if exports.ox_inventory:Search('count', "goldpan") < 1 then
        lib.notify({
            description = "You need a gold pan",
            type = "error"
        })
        return
    end

    local bag = Config.DirtSystem.Bags[bagType]
    if not bag then return end

    local baseTime = Config.DirtSystem.WashTime
    local multiplier = bag.uses / 3
    local panTime = math.floor(baseTime * multiplier)

    TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_KNEEL", 0, true)

    if lib.progressBar({
        duration = panTime,
        label = "Panning "..bagType.." dirt...",
        canCancel = true,
        disable = { move = true, combat = true }
    }) then
        TriggerServerEvent("jim-mining:washBag", bagType)
    end

    ClearPedTasks(ped)
end

Mining.Other.panStart = function()
    OpenPanMenu()
end

-- =========================
-- USE STONE EVENT
-- =========================

RegisterNetEvent('jim-mining:client:useStone', function()
    if not IsPlayerInWater(PlayerPedId()) then
        lib.notify({
            description = "You need to be in water to wash stone",
            type = "error"
        })
        return
    end

    Mining.Other.washStart()
end)