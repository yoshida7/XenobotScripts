local Loot = {12683, 14040, 14042, 14250, 14043, 14248, 14247, 12308, 7426, 7424, 3566, 3067, 3055, 2995, 5668, 5801, 3071, 3567, 3324, 3052, 14142, 13987, 13990, 281}
local Product = {12730, 14017, 14041, 14012, 14013, 14011, 14044, 14010, 14008, 5895, 3029, 3030, 3032, 3033}
local LootPos = {}

Map.GetUseItems = function (id)
    if type(id) == "string" then
        id = Item.GetID(id)
    end
    local pos = Self.Position()
    local store = {}
    for x = -7, 7 do
        for y = -5, 5 do
            if Map.GetTopUseItem(pos.x + x, pos.y + y, pos.z).id == id then
                itemPos = {x = pos.x + x, y = pos.y + y, z = pos.z}
                table.insert(store, itemPos)
            end
        end
    end
    return store
end

while(true) do
	local creatures = 0
	local spect = Self.GetSpectators(false)
	for _, creature in ipairs(spect) do
		if creature:isValid() and creature:ID() ~= Self.ID() and creature:isOnScreen() and creature:isVisible() and creature:isAlive() and creature:isMonster() then
			creatures = creatures + 1
		end
	end

	if creatures < 1 then
		for _, id in ipairs(Loot) do
			local t = Map.GetUseItems(id)
			for k = 1, #t do
				table.insert(LootPos, {pos = t[k], type = 1})
			end
		end

		for _, id in ipairs(Product) do
			local t = Map.GetUseItems(id)
			for k = 1, #t do
				table.insert(LootPos, {pos = t[k], type = 2})
			end
		end

		if #LootPos > 0 then
			Walker.Stop()
			Looter.Stop()
			for _, it in ipairs(LootPos) do
				Map.PickupItem(it.pos.x, it.pos.y, it.pos.z, (it.type == 1 and Item.GetID(LootBP) or Item.GetID(ProductBP)), 19, 100)
				wait(200)
			end
			LootPos = {}
			Walker.Start()
			Looter.Start()
		end
	end
	wait(1000)
end
	
	