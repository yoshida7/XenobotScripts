Module.New("follow", function(module)
	if(Self.TargetID() == 0) then
		Creature.Follow("Korujaceyz")
	end
module:Delay(1000)
end)