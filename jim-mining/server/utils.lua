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

	if #items == 0 then goto start end

	local rand = math.random(1, #items)
	local selectedItem = items[rand]

	debugPrint("^5Debug^7: ^2Selected item ^7'^3"..selectedItem.."^7' - ^2rand^7: "..rand.." ^2length^7: "..#items)

	return selectedItem
end