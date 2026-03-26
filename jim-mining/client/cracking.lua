Cracking = false

Mining.Other.crackStart = function(data)
    local ped = PlayerPedId()
    if Cracking then return end
    local cost = 1
    if hasItem("stone", cost) then
        Cracking = true
        lockInv(true)

        local benchcoords = GetOffsetFromEntityInWorldCoords(data.bench, 0.0, -0.2, 2.08)
        lookEnt(data.bench)

        if #(benchcoords - GetEntityCoords(ped)) > 1.5 then
            TaskGoStraightToCoord(ped, benchcoords, 0.5, 400, 0.0, 0)
            Wait(400)
        end

        local Rock = makeProp({ prop = "prop_rock_5_smash1", coords = vec4(benchcoords.x, benchcoords.y, benchcoords.z, 0)}, 0, 1)

        local dict, anim = "anim@heists@ornate_bank@grab_cash", "grab"
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(100) end
        TaskPlayAnim(ped, dict, anim, 3.0, 3.0, -1, 1, 0, false, false, false)

        CreateThread(function()
            while Cracking do
                UseParticleFxAssetNextCall("core")
                StartNetworkedParticleFxNonLoopedAtCoord("ent_dst_rocks", benchcoords.x, benchcoords.y, benchcoords.z-0.9, 0.0,0.0,0.0,0.2,0.0,0.0,0.0)
                Wait(100)
            end
        end)

        if progressBar({ label = "Cracking stone...", time = GetTiming(Config.Timings["Cracking"]), cancel = true, icon = "stone" }) then
            TriggerServerEvent(GetCurrentResourceName()..":Reward", { crack = true, cost = cost })
        end

        StopAnimTask(ped, dict, anim, 1.0)
        unloadPtfxDict("core")
        destroyProp(Rock)
        lockInv(false)
        Cracking = false
    else
        triggerNotify(nil, locale("error", "no_stone"), 'error')
    end
end