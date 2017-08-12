local useWalker = true
local lastFished = 0
local walking = false

local BP = "backpack"

local mod = Module.New("FishingModule", function(module)
	p=Self.Position()

	for a = -7,7 do
		for b=-5,5 do
			if table.contains({4597,4598,4599,4600,4601,4602}, Map.GetTopUseItem(p.x+a,p.y+b,p.z).id) and Self.Cap() >= 10 and Self.ItemCount(Item.GetID("worm")) > 0 and not walking and not Self.isInPz() then
				selfUseItemWithGround(3483,p.x+a,p.y+b,p.z)
				lastFished = os.time()
				wait(1000)
			end
		end
	end
	if os.time() - lastFished >= 10 and useWalker and not walking then
		Walker.Start()
		walking = true
	end
	module:Delay(1000)
end)

registerEventListener(WALKER_SELECTLABEL, "onWalkerSelectLabel")

function onWalkerSelectLabel(labelName)
	if labelName == "Fish" then
		Walker.Stop()
		walking = false
	elseif labelName == "Depot" then
		Walker.Stop()
		wait(2000,4000)
		Self.ReachDepot()
		wait(2000)
		Self.DepositItems({3578,0})
		wait(1000)
		Walker.Start()
	end
end

Self.ReachDepot = function (tries)
	local tries = tries or 3
	Walker.Stop()
	local DepotIDs = {3497, 3498, 3499, 3500}
	local DepotPos = {}
	for i = 1, #DepotIDs do
		local dps = Map.GetUseItems(DepotIDs[i])
		for j = 1, #dps do
			table.insert(DepotPos, dps[j])
		end
	end
	local function gotoDepot()
		local pos = Self.Position()
		print("Depots found: " .. tostring(#DepotPos))
		for i = 1, #DepotPos do
			location = DepotPos[i]
			Self.UseItemFromGround(location.x, location.y, location.z)
			wait(1000, 2000)
			if Self.DistanceFromPosition(pos.x, pos.y, pos.z) >= 1 then
				wait(5000, 6000)
				if Self.DistanceFromPosition(location.x, location.y, location.z) == 1 then
					Walker.Start()
					return true
				end
			else
				print("Something is blocking the path. Trying next depot.")
			end
		end
		return false
	end
	
	repeat
		reachedDP = gotoDepot()
		if reachedDP then
			return true
		end
		tries = tries - 1
		sleep(100)
		print("Attempt to reach depot was unsuccessfull. " .. tries .. " tries left.")
	until tries <= 0

	return false
end

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
	
	