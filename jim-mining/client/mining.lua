isMining = false

function breakTool(data)
    TriggerServerEvent("jim-mining:server:breakTool", data)
end

-- =========================
-- PARTICLE HELPER
-- =========================

local function playMiningFx(entity)
    if not entity or not DoesEntityExist(entity) then return end

    local coords = GetOffsetFromEntityInWorldCoords(entity, 0.0, 0.0, 0.5)

    loadPtfxDict("core")
    UseParticleFxAssetNextCall("core")

    StartNetworkedParticleFxNonLoopedAtCoord(
        "ent_dst_rocks",
        coords.x, coords.y, coords.z,
        0.0, 0.0, 0.0,
        0.8, 0.0, 0.0, 0.0
    )
end

-- =========================
-- PICKAXE
-- =========================

Mining.MineOre.pickaxe = function(data)
    local ped = PlayerPedId()
    if isMining then return else isMining = true end

    local success = lib.skillCheck({'easy'}, {'e'})
    if not success then
        lib.notify({ title = "Mining", description = "You swung and missed the vein!", type = "error" })
        isMining = false
        return
    end

    local dict = "melee@large_wpn@streamed_core"
    local anim = "ground_attack_on_spot"

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(100) end

    local PickAxe = makeProp({ prop = "prop_tool_pickaxe", coords = vec4(0,0,0,0)}, 0, 1)

    AttachEntityToEntity(PickAxe, ped, GetPedBoneIndex(ped, 57005),
        0.12, -0.35, -0.15,
        250.0, 180.0, 0.0,
        false, true, true, true, 0, true)

    TaskPlayAnim(ped, dict, anim, 3.0, 3.0, -1, 1, 0, false, false, false)

    CreateThread(function()
        while isMining do
            playMiningFx(data.stone)
            Wait(800)
        end
    end)

    if progressBar({
        label = "Mining ore...",
        time = Config.MiningSpeeds.pickaxe,
        cancel = true,
        icon = "pickaxe"
    }) then
        TriggerServerEvent(GetCurrentResourceName()..":Reward", {
            mine = true,
            setReward = data.setReward,
            tier = "pickaxe"
        })

        breakTool({
            item = "pickaxe",
            damage = math.random(Config.ToolDamage.pickaxe.min, Config.ToolDamage.pickaxe.max)
        })

        Mining.Other.stoneBreak(data.name, data.stone, data.coords, data.job, data.rot, data.emptyProp)
    end

    StopAnimTask(ped, dict, anim, 1.0)
    destroyProp(PickAxe)
    unloadPtfxDict("core")
    isMining = false
end

-- =========================
-- DRILL 
-- =========================

Mining.MineOre.miningDrill = function(data)
    local ped = PlayerPedId()
    if isMining then return else isMining = true end

    local success = lib.skillCheck({'easy','medium'}, {'e'})
    if not success then
        lib.notify({ title = "Mining", description = "The drill slipped!", type = "error" })
        isMining = false
        return
    end

    loadDrillSound()

    local dict, anim = "anim@heists@fleeca_bank@drilling", "drill_straight_fail"
    local DrillObj = makeProp({ prop = "hei_prop_heist_drill", coords = vec4(0,0,0,0)}, 0, 1)

    AttachEntityToEntity(DrillObj, ped, GetPedBoneIndex(ped, 57005), 0.14, 0, -0.01, 90.0, -90.0, 180.0, true, true, false, true, 1, true)

    local rockcoords = GetEntityCoords(data.stone)
    lookEnt(data.stone)
    TaskGoStraightToCoord(ped, rockcoords, 0.5, 400, 0.0, 0)

    playAnim(dict, anim, -1, 1)

    if Config.General.DrillSound then
        PlaySoundFromEntity(soundId, "Drill", DrillObj, "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
    end

    if progressBar({
        label = "Drilling ore...",
        time = Config.MiningSpeeds.miningdrill,
        cancel = true,
        icon = "miningdrill"
    }) then
        TriggerServerEvent(GetCurrentResourceName()..":Reward", {
            mine = true,
            setReward = data.setReward,
            tier = "drill"
        })

        breakTool({
            item = "miningdrill",
            damage = math.random(Config.ToolDamage.miningdrill.min, Config.ToolDamage.miningdrill.max)
        })

        Mining.Other.stoneBreak(data.name, data.stone, data.coords, data.job, data.rot, data.emptyProp)
    end

    stopAnim(dict, anim)
    destroyProp(DrillObj)
    unloadDrillSound()
    isMining = false
end

-- =========================
-- LASER 
-- =========================

Mining.MineOre.miningLaser = function(data)
    local ped = PlayerPedId()
    if isMining then return else isMining = true end

    local success = lib.skillCheck({'medium','medium'}, {'e'})
    if not success then
        lib.notify({ title = "Mining", description = "The laser overheated!", type = "error" })
        isMining = false
        return
    end

    RequestAmbientAudioBank("DLC_HEIST_BIOLAB_DELIVER_EMP_SOUNDS", 0)
    RequestAmbientAudioBank("dlc_xm_silo_laser_hack_sounds", 0)

    local soundId = GetSoundId()

    local dict, anim = "anim@heists@fleeca_bank@drilling", "drill_straight_fail"
    local LaserObj = makeProp({ prop = "ch_prop_laserdrill_01a", coords = vec4(0,0,0,0)}, 0, 1)

    AttachEntityToEntity(LaserObj, ped, GetPedBoneIndex(ped, 57005),
        0.14, 0.0, -0.01,
        90.0, -90.0, 180.0,
        true, true, false, true, 1, true)

    local rockcoords = GetEntityCoords(data.stone)
    lookEnt(data.stone)

    playAnim(dict, 'drill_straight_idle', -1, 1)
    PlaySoundFromEntity(soundId, "Pass", LaserObj, "dlc_xm_silo_laser_hack_sounds", 1, 0)

    Wait(1000)

    playAnim(dict, anim, -1, 1)
    PlaySoundFromEntity(soundId, "EMP_Vehicle_Hum", LaserObj, "DLC_HEIST_BIOLAB_DELIVER_EMP_SOUNDS", 1, 0)

    -- =========================
    -- PARTICLES
    -- =========================

    CreateThread(function()
        loadPtfxDict("core")

        while isMining do
            local lasercoords = GetOffsetFromEntityInWorldCoords(LaserObj, 0.0, -0.5, 0.02)

            UseParticleFxAssetNextCall("core")
            StartNetworkedParticleFxNonLoopedAtCoord(
                "muz_railgun",
                lasercoords.x, lasercoords.y, lasercoords.z,
                0, -10.0, GetEntityHeading(LaserObj)+270,
                1.0, 0.0, 0.0, 0.0
            )

            UseParticleFxAssetNextCall("core")
            StartNetworkedParticleFxNonLoopedAtCoord(
                "ent_dst_rocks",
                rockcoords.x, rockcoords.y, rockcoords.z,
                0.0, 0.0, GetEntityHeading(ped)-180.0,
                1.0, 0.0, 0.0, 0.0
            )

            Wait(60)
        end
    end)

    if progressBar({
        label = "Drilling ore...",
        time = Config.MiningSpeeds.mininglaser,
        cancel = true,
        icon = "mininglaser"
    }) then
        TriggerServerEvent(GetCurrentResourceName()..":Reward", {
            mine = true,
            setReward = data.setReward,
            tier = "laser"
        })

        breakTool({
            item = "mininglaser",
            damage = math.random(Config.ToolDamage.mininglaser.min, Config.ToolDamage.mininglaser.max)
        })

        Mining.Other.stoneBreak(data.name, data.stone, data.coords, data.job, data.rot, data.emptyProp)
    end

    StopSound(soundId)
    ReleaseSoundId(soundId)

    ClearPedTasks(ped)
    destroyProp(LaserObj)
    unloadPtfxDict("core")

    isMining = false
end

-- =========================
-- JACKHAMMER
-- =========================

Mining.MineOre.jackhammer = function(data)
    local ped = PlayerPedId()
    if isMining then return else isMining = true end

    local dict = "amb@world_human_const_drill@male@drill@base"
    local anim = "base"

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end

    local rockCoords = GetEntityCoords(data.stone)
    local pedCoords = GetEntityCoords(ped)

    local heading = GetHeadingFromVector_2d(
        rockCoords.x - pedCoords.x,
        rockCoords.y - pedCoords.y
    )

    SetEntityHeading(ped, heading)

    local tool = makeProp({ prop = "prop_tool_jackham", coords = vec4(0,0,0,0)}, 0, 1)

    TaskPlayAnim(ped, dict, anim, 3.0, 3.0, -1, 1, 0, false, false, false)

    Wait(200)

    AttachEntityToEntity(tool, ped, GetPedBoneIndex(ped, 24816),
        -0.15, 0.30, 0.0,
        90.0, 0.0, 20.0,
        true, true, false, true, 1, true)

    FreezeEntityPosition(ped, true)

    if lib.progressBar({
        duration = 4500,
        label = "Breaking Rock...",
        canCancel = true
    }) then
        TriggerServerEvent("jim-mining:jackhammerHit", data.id)
    end

    ClearPedTasks(ped)
    FreezeEntityPosition(ped, false)
    DeleteObject(tool)
    isMining = false
end