function dropItem(id, cnt) 
    local cont = Container.GetFirst() 

    while (cont:isOpen()) do 
        for spot = 0, cont:ItemCount() do 
            local item = cont:GetItemData(spot) 
            if (item.id == id) then 
                if(cont:CountItemsOfID(id) >= cnt) then
                    cont:MoveItemToGround(spot, Self.Position().x, Self.Position().y, Self.Position().z) 
                    return true 
                end
            end 
        end 

        cont = cont:GetNext() 
    end 
     
    return false 
end 


while (true) do 
    dropItem(285, 5)
	dropItem(284, 2)
	dropItem(2881, 1)
    wait(200) 
end 