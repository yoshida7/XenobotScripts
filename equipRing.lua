local RingID = 3004

Module.New('equip-ring', function(mod)

    if Self.Ring().id == 0 then
        Self.Equip(RingID, "ring")
    end

    mod:Delay(1500,2500)
end)
