local config = {
GoldContainer = "backpack",
Gold = {"Gold Coin"},
GoldEnabled = true,

StackableContainer = "backpack",
Stackables = {"Gold Coin", "Platinum Coin"},

NonStackableContainer = "fur backpack",
NonStackables = {"Crystalline Armor","Focus Cape","Glacier Amulet","Glacier Kilt","Leviathan's Amulet","Northwind Rod","Sea Serpent Scale","Small Sapphire","Stealth Ring"}
}

while true do
for i = 0, #Container.GetIndexes() - 1 do
local c = Container.GetFromIndex(i)
if c:isOpen() and (c:Name():find("The") or c:Name():find("Demonic") or c:Name():find("Dead") or c:Name():find("Slain") or c:Name():find("Dissolved") or c:Name():find("Remains") or c:Name():find("Elemental")) then
for s = 0, c:ItemCount() - 1 do
local item = Item.GetName(c:GetItemData(s).id):titlecase()
if config.GoldEnabled and table.contains(config.Gold, item) and Self.Cap() > 100 then
local destCont = Container.GetByName(config.GoldContainer)
c:MoveItemToContainer(s, destCont:Index(), math.min(destCont:ItemCount() + 1, destCont:ItemCapacity() - 1))
wait(150, 180)
break
elseif table.contains(config.Stackables, item) then
local destCont = Container.GetByName(config.StackableContainer)
c:MoveItemToContainer(s, destCont:Index(), math.min(destCont:ItemCount() + 1, destCont:ItemCapacity() - 1))
wait(150, 180)
break
elseif table.contains(config.NonStackables, item) then
local destCont = Container.GetByName(config.NonStackableContainer)
c:MoveItemToContainer(s, destCont:Index(), math.min(destCont:ItemCount() + 1, destCont:ItemCapacity() - 1))
wait(150, 180)
break
end
end
end
end
wait(50)
end