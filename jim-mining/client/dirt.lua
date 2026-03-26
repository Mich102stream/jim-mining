-- =========================
-- DIRT SYSTEM
-- =========================

function GetEmptyBag()
    for type, data in pairs(Config.DirtSystem.Bags) do
        local count = exports.ox_inventory:Search('count', data.empty)
        if count and count > 0 then
            return type, data
        end
    end
    return nil
end

function DigDirt()
    print("DigDirt Triggered")

    local bagType, bag = GetEmptyBag()
    if not bagType then
        lib.notify({ description = "You need an empty dirt bag", type = "error" })
        return
    end

    if exports.ox_inventory:Search('count', Config.DirtSystem.shovelItem) < 1 then
        lib.notify({ description = "You need a shovel", type = "error" })
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local dict = "amb@world_human_gardener_plant@male@base"
    local anim = "base"

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end

    local model = `prop_tool_shovel`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local shovel = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)

    AttachEntityToEntity(shovel, ped, GetPedBoneIndex(ped, 57005),
        0.1, 0.0, -0.05,
        90.0, -90.0, 180.0,
        true, true, false, true, 1, true)

    TaskPlayAnim(ped, dict, anim, 3.0, 3.0, -1, 1, 0, false, false, false)
    FreezeEntityPosition(ped, true)

    if lib.progressBar({
        duration = Config.DirtSystem.DigTime,
        label = "Digging dirt...",
        canCancel = true,
        disable = { move = true, combat = true }
    }) then
        print("Progress complete")
        TriggerServerEvent("jim-mining:fillBag", bagType)
    end

    ClearPedTasks(ped)
    FreezeEntityPosition(ped, false)

    DeleteObject(shovel)
    SetModelAsNoLongerNeeded(model)
end

RegisterNetEvent("jim-mining:client:DigDirt", function()
    DigDirt()
end)

-- =========================
-- DIG ZONES
-- =========================

CreateThread(function()
    for i, loc in pairs(Config.DigZones) do
        exports.ox_target:addSphereZone({
            coords = loc.coords,
            radius = loc.radius,
            debug = false,
            options = {
                {
                    name = "dig_dirt_"..i,
                    icon = "fa-solid fa-shovel",
                    label = "Dig "..(loc.label or "Dirt"),
                    onSelect = function()

                        print("DIG START")

                        local bagType = nil
                        local bag = nil

                        for type, data in pairs(Config.DirtSystem.Bags) do
                            if exports.ox_inventory:Search('count', data.empty) > 0 then
                                bagType = type
                                bag = data
                                break
                            end
                        end

                        if not bagType then
                            lib.notify({ description = "You need an empty dirt bag", type = "error" })
                            return
                        end

                        if exports.ox_inventory:Search('count', Config.DirtSystem.shovelItem) < 1 then
                            lib.notify({ description = "You need a shovel", type = "error" })
                            return
                        end

                        local ped = PlayerPedId()
                        local coords = GetEntityCoords(ped)

                        local dict = "amb@world_human_gardener_plant@male@base"
                        local anim = "base"

                        RequestAnimDict(dict)
                        while not HasAnimDictLoaded(dict) do Wait(0) end

                        local model = `prop_cs_trowel`
                        RequestModel(model)
                        while not HasModelLoaded(model) do Wait(0) end

                        local shovel = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)

                        AttachEntityToEntity(shovel, ped, GetPedBoneIndex(ped, 57005),
                            0.1, 0.0, -0.05,
                            90.0, -90.0, 180.0,
                            true, true, false, true, 1, true)

                        TaskPlayAnim(ped, dict, anim, 3.0, 3.0, -1, 1, 0, false, false, false)
                        FreezeEntityPosition(ped, true)

                        -- =========================
                        -- DIG TIME SCALING
                        -- =========================

                        local baseTime = Config.DirtSystem.DigTime
                        local multiplier = bag.uses / 3
                        local digTime = math.floor(baseTime * multiplier)

                        if lib.progressBar({
                            duration = digTime,
                            label = "Filling "..bagType.." dirt bag...",
                            canCancel = true,
                            disable = { move = true, combat = true }
                        }) then
                            print("DIG SUCCESS")
                            TriggerServerEvent("jim-mining:fillBag", bagType)
                        end

                        ClearPedTasks(ped)
                        FreezeEntityPosition(ped, false)
                        DeleteObject(shovel)
                        SetModelAsNoLongerNeeded(model)
                    end,

                    canInteract = function()
                        if exports.ox_inventory:Search('count', Config.DirtSystem.shovelItem) < 1 then return false end

                        for _, data in pairs(Config.DirtSystem.Bags) do
                            if exports.ox_inventory:Search('count', data.empty) > 0 then
                                return true
                            end
                        end

                        return false
                    end
                }
            }
        })
    end
end)