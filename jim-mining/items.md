	-- =========================
	-- JIM MINING REWORK
	-- =========================

	-- =========================
	-- CORE MATERIALS
	-- =========================

	stone = {
		label = "Stone",
		weight = 10000,
		width = 2,
		height = 2,
		stack = true,
		close = false,
		description = "Stone fragment",
		client = {
			event = 'jim-mining:client:useStone',
		},
		stackSize = 100,
		rarity = 'common',
	},

	carbon = {
		label = "Carbon",
		weight = 100,
		width = 1,
		height = 1,
		stack = true,
		close = false,
		description = "Carbon, a base ore.",
		stackSize = 100,
		rarity = 'common',
	},
	
	geode = {
		label = "Geode",
		weight = 200,
		width = 1,
		height = 1,
		stack = true,
		close = false,
		description = "A rough geode. Might contain something valuable inside.",
		client = {
		},
		stackSize = 50,
		rarity = 'uncommon',
	},

	fossil = {
		label = "Fossil",
		weight = 300,
		width = 1,
		height = 1,
		stack = true,
		close = false,
		description = "An ancient fossil. Collectors might pay well for this.",
		client = {
		},
		stackSize = 50,
		rarity = 'rare',
	},	

	-- =========================
	-- ORES
	-- =========================

	ironore = {
		label = "Iron Ore",
		weight = 1000,
		width = 2,
		height = 1,
		stack = true,
		close = false,
		description = "Iron ore",
		stackSize = 100,
		rarity = 'common',
	},

	copperore = {
		label = "Copper Ore",
		weight = 1000,
		width = 1,
		height = 1,
		stack = true,
		close = false,
		description = "Copper ore",
		stackSize = 100,
		rarity = 'common',
	},

	aluminiumore = {
		label = "Aluminium Ore",
		weight = 1000,
		width = 1,
		height = 1,
		stack = true,
		close = false,
		description = "Aluminium ore",
		stackSize = 100,
		rarity = 'common',
	},

	goldore = {
		label = "Gold Ore",
		weight = 1000,
		width = 1,
		height = 1,
		stack = true,
		close = false,
		description = "Gold ore",
		stackSize = 100,
		rarity = 'uncommon',
	},

	silverore = {
		label = "Silver Ore",
		weight = 1000,
		width = 1,
		height = 1,
		stack = true,
		close = false,
		description = "Silver ore",
		stackSize = 100,
		rarity = 'uncommon',
	},

	-- =========================
	-- INGOTS
	-- =========================

	iron = {
		label = "Iron Ingot",
		weight = 1000,
		width = 2,
		height = 1,
		stack = true,
		close = false,
		stackSize = 100,
		rarity = 'common',
	},

	aluminium = {
		label = "Aluminium Ingot",
		weight = 1000,
		width = 1,
		height = 1,
		stack = true,
		close = false,
		stackSize = 100,
		rarity = 'common',
	},

	goldingot = {
		label = "Gold Ingot",
		weight = 1000,
		width = 2,
		height = 1,
		stack = true,
		close = false,
		stackSize = 100,
		rarity = 'rare',
	},

	silveringot = {
		label = "Silver Ingot",
		weight = 1000,
		width = 2,
		height = 1,
		stack = true,
		close = false,
		stackSize = 100,
		rarity = 'rare',
	},

	-- =========================
	-- UNCUT GEMS
	-- =========================

	uncut_emerald = {
		label = "Uncut Emerald",
		weight = 100,
		width = 1,
		height = 1,
		stack = true,
		close = false,
		description = "A rough Emerald",
		stackSize = 100,
		rarity = 'rare',
	},

	uncut_ruby = {
		label = "Uncut Ruby",
		weight = 100,
		width = 1,
		height = 1,
		stack = true,
		close = false,
		description = "A rough Ruby",
		stackSize = 100,
		rarity = 'rare',
	},

	uncut_diamond = {
		label = "Uncut Diamond",
		weight = 100,
		width = 1,
		height = 1,
		stack = true,
		close = false,
		description = "A rough Diamond",
		stackSize = 100,
		rarity = 'epic',
	},

	uncut_sapphire = {
		label = "Uncut Sapphire",
		weight = 100,
		width = 1,
		height = 1,
		stack = true,
		close = false,
		description = "A rough Sapphire",
		stackSize = 100,
		rarity = 'rare',
	},

	-- =========================
	-- TOOLS
	-- =========================

	pickaxe = {
		label = "Pickaxe",
		weight = 1000,
		width = 1,
		height = 2,
		stack = false,
		description = "Basic mining tool",
		durability = true,
		buttons = {
			{
				label = "Repair Pickaxe",
				action = function(slot)
					TriggerServerEvent("jim-mining:server:RepairToolFromTool", slot)
				end
			}
		}
	},

	miningdrill = {
		label = "Mining Drill",
		weight = 1000,
		width = 3,
		height = 2,
		stack = false,
		description = "Electric mining drill",
		durability = true,
		buttons = {
			{
				label = "Repair Drill",
				action = function(slot)
					TriggerServerEvent("jim-mining:server:RepairToolFromTool", slot)
				end
			}
		}
	},

	mininglaser = {
		label = "Mining Laser",
		weight = 1000,
		width = 3,
		height = 2,
		stack = false,
		description = "High tech laser drill",
		durability = true,
		buttons = {
			{
				label = "Repair Laser",
				action = function(slot)
					TriggerServerEvent("jim-mining:server:RepairToolFromTool", slot)
				end
			}
		}
	},

	shovel = {
		label = "Shovel",
		weight = 1500,
		width = 2,
		height = 2,
		stack = false,
		description = "Used to collect dirt",
		durability = true,
	},

	jackhammer = {
		label = "Jackhammer",
		weight = 3000,
		width = 3,
		height = 2,
		stack = false,
		description = "Used for breaking large rock clusters",
		durability = true,
	},

	-- =========================
	-- REPAIR ITEMS
	-- =========================

	sharpening_stone = {
		label = "Whetstone",
		weight = 100,
		stack = true,
		description = "Used to repair a pickaxe",
	},

	drillbit = {
		label = "Drill Bit",
		weight = 100,
		stack = true,
		description = "Used to repair a drill",
	},

	laser_lens = {
		label = "Laser Lens",
		weight = 100,
		stack = true,
		description = "Used to repair a laser",
	},

	-- =========================
	-- DIRT SYSTEM
	-- =========================

	dirtbag_empty_small = {
		label = "Empty Dirt Bag",
		weight = 200,
		stack = true,
	},

	dirtbag_small = {
		label = "Small Dirt Bag",
		weight = 1000,
		stack = false,
	},

	dirtbag_empty_medium = {
		label = "Empty Medium Dirt Bag",
		weight = 300,
		stack = true,
	},

	dirtbag_medium = {
		label = "Medium Dirt Bag",
		weight = 2000,
		stack = false,
	},

	dirtbag_empty_large = {
		label = "Empty Large Dirt Bag",
		weight = 500,
		stack = true,
	},

	dirtbag_large = {
		label = "Large Dirt Bag",
		weight = 4000,
		stack = false,
	},

	-- =========================
	-- MISC
	-- =========================

	goldpan = {
		label = "Gold Panning Tray",
		weight = 100,
		stack = true,
		description = "Used for panning dirt",
	},
