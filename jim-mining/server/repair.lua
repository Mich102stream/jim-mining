RegisterNetEvent("jim-mining:server:RepairToolFromTool", function(slot)
    local src = source
    local item = exports.ox_inventory:GetSlot(src, slot)
    if not item then return end

    local repairItems = {
        pickaxe = "sharpening_stone",
        miningdrill = "drillbit",
        mininglaser = "laser_lens"
    }

    local repairItem = repairItems[item.name]
    if not repairItem then return end

    if exports.ox_inventory:Search(src, "count", repairItem) < 1 then return end

    exports.ox_inventory:RemoveItem(src, repairItem, 1)

    local meta = item.metadata or {}
    local durability = meta.durability or 0
    meta.durability = math.min(durability + 50, 100)

    exports.ox_inventory:SetMetadata(src, item.slot, meta)
end)