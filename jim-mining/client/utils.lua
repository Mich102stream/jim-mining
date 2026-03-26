-- =========================
-- CORE TABLE
-- =========================

Mining = {
	Functions = {},
	MineOre = {},
	Other = {},
	Menus = {},

	Targets = {},
	Props = {},
	Peds = {},
	Blips = {},
}

local soundId = GetSoundId()

-- =========================
-- PROP TABLE
-- =========================

Mining.PropTable = {
	{ full = "cs_x_rubweec", empty = "prop_rock_5_a" },
}

if Config.General.K4MB1Prop then
	Mining.PropTable = {
		{ full = "cs_x_rubweec", empty = "prop_rock_5_a" },
		{ full = "k4mb1_crystalblue", empty = "k4mb1_crystalempty" },
		{ full = "k4mb1_crystalgreen", empty = "k4mb1_crystalempty" },
		{ full = "k4mb1_crystalred", empty = "k4mb1_crystalempty" },
		{ full = "k4mb1_bauxiteore2", empty = "k4mb1_emptyore2" },
		{ full = "k4mb1_coal2" },
		{ full = "k4mb1_copperore2", empty = "k4mb1_emptyore2" },
		{ full = "k4mb1_ironore2", empty = "k4mb1_emptyore2" },
		{ full = "k4mb1_goldore2", empty = "k4mb1_emptyore2" },
		{ full = "k4mb1_leadore2", empty = "k4mb1_emptyore2" },
		{ full = "k4mb1_tinore2", empty = "k4mb1_emptyore2" },
		{ full = "k4mb1_diamond" },
	}
end

-- =========================
-- JOB CHECK
-- =========================

Mining.Functions.checkForJob = function()
	if Config.General.requiredJob then
		if hasJob(Config.General.requiredJob) then
			Mining.Functions.makeJob()
		else
			Mining.Functions.removeJob()
		end
	else
		Mining.Functions.makeJob()
	end
end

-- =========================
-- RANDOM REWARD
-- =========================

Mining.Functions.weightedRandomReward = function()
	local totalWeight, weightedTable = 0, {}

	for _, item in ipairs(Config.setMiningTable) do
		local weight = item.rarity == "common" and 5 or item.rarity == "rare" and 3 or 1
		totalWeight += weight

		local prop = item.prop
		if not Config.General.K4MB1Prop then prop = "cs_x_rubweec" end

		table.insert(weightedTable, {
			name = item.name,
			weight = totalWeight,
			prop = prop
		})
	end

	local randValue = math.random(1, totalWeight)

	for _, item in ipairs(weightedTable) do
		if randValue <= item.weight then
			return item
		end
	end
end

-- =========================
-- PROP SPAWN
-- =========================

Mining.Functions.spawnProp = function(coords, propName, adjustHeight)
	local propCoords = vec4(coords.x, coords.y, coords.z + adjustHeight, coords.a)
	local prop = makeProp({coords = propCoords, prop = propName}, 1, false)

	local rot = GetEntityRotation(prop)
	SetEntityRotation(prop, rot.x - math.random(60,100), rot.y, rot.z, 0, 0)

	return prop
end

-- =========================
-- TARGET SETUP
-- =========================

Mining.Functions.setupMiningTarget = function(name, coords, stone, emptyProp, setReward, job)
	Mining.Targets[name] = createCircleTarget({
		name,
		coords.xyz,
		1.5,
		{ name = name, debugPoly = debugMode, useZ = true }
	},{
		{
			action = function()
				Mining.MineOre.pickaxe({
					name = name,
					stone = stone,
					coords = coords,
					setReward = setReward,
					job = job,
					emptyProp = emptyProp
				})
			end,
			icon = "fas fa-hammer",
			label = "Mine Rock (Pickaxe)",
			canInteract = function()
				return exports.ox_inventory:Search('count', 'pickaxe') > 0
			end,
		},
		{
			action = function()
				Mining.MineOre.miningDrill({
					name = name,
					stone = stone,
					coords = coords,
					setReward = setReward,
					job = job,
					emptyProp = emptyProp
				})
			end,
			icon = "fas fa-screwdriver-wrench",
			label = "Mine Rock (Drill)",
			canInteract = function()
				return exports.ox_inventory:Search('count', 'miningdrill') > 0
			end,
		},
		{
			action = function()
				Mining.MineOre.miningLaser({
					name = name,
					stone = stone,
					coords = coords,
					setReward = setReward,
					job = job,
					emptyProp = emptyProp
				})
			end,
			icon = "fas fa-bolt",
			label = "Mine Rock (Laser)",
			canInteract = function()
				return exports.ox_inventory:Search('count', 'mininglaser') > 0
			end,
		},
	}, 2.0)
end