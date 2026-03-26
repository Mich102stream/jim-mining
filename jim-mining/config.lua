Config = {

-- =========================
-- LANGUAGE / SYSTEM
-- =========================

    Lan = "en",

    System = {
        Debug = false,
        Menu = "ox",
        ProgressBar = "ox",
        Notify = "ox",
        drawText = "ox"
    },

-- =========================
-- GENERAL SETTINGS
-- =========================

    General = {
        JimShops = false,
        DrillSound = true,
        K4MB1Prop = false,
        AltMining = false,
        K4MB1Cart = false,
        requiredJob = nil,
    },

-- =========================
-- CRAFTING
-- =========================

    Crafting = {
        craftCam = false,
        MultiCraft = true,
    },

-- =========================
-- TIMINGS
-- =========================

    Timings = {
        Cracking = { 15000, 25000 },
        Washing = { 15000, 25000 },
        Panning = { 6000, 10000 },
        OreRespawn = math.random(55000, 75000),
        Crafting = 5000,
    },

-- =========================
-- MINING SETTINGS
-- =========================

    MiningSpeeds = {
        pickaxe = 6500,
        miningdrill = 3500,
        mininglaser = 1200
    },

    ToolDurability = {
        pickaxe = 50,
        miningdrill = 75,
        mininglaser = 100
    },

    ToolDamage = {
        pickaxe = { min = 2, max = 3 },
        miningdrill = { min = 1, max = 2 },
        mininglaser = { min = 1, max = 1 }
    },

-- =========================
-- REWARD POOLS
-- =========================

    CrackPool = {
        { item = "carbon", rarity = "60" },
        { item = "copperore", rarity = "30" },
        { item = "ironore", rarity = "30" },
        { item = "uncut_ruby", rarity = "6" },
        { item = "uncut_emerald", rarity = "6" },
        { item = "uncut_diamond", rarity = "3" },
        { item = "uncut_sapphire", rarity = "5" },
    },

    WashPool = {
        { item = "carbon", rarity = "50" },
        { item = "copperore", rarity = "20" },
        { item = "ironore", rarity = "20" },
        { item = "aluminiumore", rarity = "40" },
    },

    PanPool = {
        { item = "stone", rarity = "50" },
        { item = "goldnugget", rarity = "18" },
        { item = "fossil", rarity = "8" },
        { item = "geode", rarity = "10" },
        { item = "ancient_coin", rarity = "14" }
    },

-- =========================
-- MINING NODE TABLE
-- =========================

    setMiningTable = {
        { name = "carbon", rarity = "common", prop = "k4mb1_coal2" },
        { name = "copperore", rarity = "common", prop = "k4mb1_copperore2" },
        { name = "ironore", rarity = "common", prop = "k4mb1_ironore2" },
        { name = "metalscrap", rarity = "common", prop = "k4mb1_leadore2" },
        { name = "goldore", rarity = "rare", prop = "k4mb1_goldore2" },
        { name = "silverore", rarity = "rare", prop = "k4mb1_tinore2" },
        { name = "uncut_ruby", rarity = "ultra_rare", prop = "k4mb1_crystalred" },
        { name = "uncut_emerald", rarity = "ultra_rare", prop = "k4mb1_crystalgreen" },
        { name = "uncut_diamond", rarity = "ultra_rare", prop = "k4mb1_diamond" },
        { name = "uncut_sapphire", rarity = "ultra_rare", prop = "k4mb1_crystalblue" },
        { name = "stone", rarity = "common", prop = "cs_x_rubweec" },
    },

-- =========================
-- STORE ITEMS
-- =========================

    Items = {
        label = "Mining Store",
        slots = 12,
        items = {
            { name = "water", price = 10, amount = 500, info = {}, type = "item", slot = 1 },
            { name = "sandwich", price = 10, amount = 500, info = {}, type = "item", slot = 2 },
            { name = "bandage", price = 20, amount = 500, info = {}, type = "item", slot = 3 },
            { name = "weapon_flashlight", price = 75, amount = 500, info = {}, type = "item", slot = 4 },
            { name = "goldpan", price = 25, amount = 500, info = {}, type = "item", slot = 5 },
            { name = "pickaxe", price = 100, amount = 500, info = { durability = 50 }, type = "item", slot = 6 },
            { name = "miningdrill", price = 5000, amount = 500, info = { durability = 75 }, type = "item", slot = 7 },
            { name = "mininglaser", price = 50000, amount = 500, info = { durability = 100 }, type = "item", slot = 8 },
            { name = "drillbit", label = "Drill Bit", price = 10, amount = 500, info = { restore = 25 }, type = "item", slot = 9 },
            { name = "sharpening_stone", label = "Sharpening Stone", price = 50, amount = 500, info = { restore = 15 }, type = "item", slot = 10 },
            { name = "laser_lens", label = "Laser Lens", price = 500, amount = 500, info = { restore = 50 }, type = "item", slot = 11 },
        },
    },

-- =========================
-- REWARD SYSTEM
-- =========================

    Rewards = {
        Mining = {
            baseAmount = { 1, 3 },
            Tools = {
                pickaxe = { multiplier = 1.0, bonus = nil },
                miningdrill = { multiplier = 1.4, bonus = { item = "goldnugget", chance = 12, amount = 1 } },
                mininglaser = { multiplier = 2.0, bonus = { item = "goldore", chance = 10, amount = 1 } }
            }
        },

        Cracking = {
            baseAmount = { 1, 3 },
            pool = "CrackPool"
        },

        Washing = {
            baseAmount = { 1, 2 },
            successes = { 1, 2 },
            pool = "WashPool"
        },

        Panning = {
            baseAmount = { 1, 2 },
            successes = { 1, 2 },
            pool = "PanPool"
        }
    },

-- =========================
-- DIRT SYSTEM
-- =========================

    DirtSystem = {
        shovelItem = "shovel",

        Bags = {
            small = {
                empty = "dirtbag_empty_small",
                filled = "dirtbag_small",
                uses = 3,
                weight = 1000
            },
            medium = {
                empty = "dirtbag_empty_medium",
                filled = "dirtbag_medium",
                uses = 6,
                weight = 2000
            },
            large = {
                empty = "dirtbag_empty_large",
                filled = "dirtbag_large",
                uses = 10,
                weight = 4000
            }
        },

        DigTime = 4000,
        WashTime = 5000
    },

-- =========================
-- DIG / DIRT ZONES
-- =========================

DigZones = {
    [1] = {
        coords = vec3(-1587.07, 1411.53, 118.87),
        radius = 5.0,
        quality = 0.8,
        label = "Poor Soil"
    },
    [2] = {
        coords = vec3(2945.33, 2810.22, 42.15),
        radius = 5.0,
        quality = 1.5,
        label = "Rich Soil"
    }
},

-- =========================
-- JACKHAMMER SYSTEM
-- =========================

Jackhammer = {
    Prop = "prop_rock_1_a",
    RespawnTime = 60000
},

LargeRocks = {
    [1] = {
        coords = vec3(2990.15, 2771.40, 42.91),
        health = 6
    }
},

-- =========================
-- PICKUP ROCK SYSTEM
-- =========================

PickupRocks = {
    Prop = "prop_rock_5_smash1",

    BigRockAmount = { min = 6, max = 12 },
    SmallRockChance = 10,

    Rewards = {
        { item = "stone", min = 1, max = 2, chance = 100 },
        { item = "ironore", min = 1, max = 2, chance = 35 },
        { item = "copperore", min = 1, max = 2, chance = 30 },
        { item = "goldore", min = 1, max = 1, chance = 10 },
        { item = "geode", min = 1, max = 1, chance = 12 },
        { item = "fossil", min = 1, max = 1, chance = 6 }
        }
    },

}


-- =========================
-- LOCALE FUNCTION
-- =========================

function locale(section, string)
    if not Loc then return string or "missing_locale" end
    if not Config or not Config.Lan then return string or "missing_locale" end

    local localTable = Loc[Config.Lan]
    if not localTable then return string or "missing_locale" end
    if not localTable[section] then return string or "missing_locale" end
    if not localTable[section][string] then return string or "missing_locale" end

    return localTable[section][string]
end