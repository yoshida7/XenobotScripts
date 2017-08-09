listedMessages = {"An ancient evil is awakening in the mines beneath Hrodmir.",
                  "Demonic entities are entering the mortal realm in the Hrodmir mines.",
                  "The demonic master has revealed itself in the mines of Hrodmir.",
                  "The ancient volcano on Goroma slowly becomes active once again.",
                  "There is an evil presence at the volcano of Goroma.",
                  "Evil Cultists have called an ancient evil into the volcano on Goroma. Beware of its power mortals.",
                  "The seals on Ferumbras old cidatel are glowing. Prepare for HIS return mortals.",
                  "Ferumbras return is at hand. The Edron Academy calls for Heroes to fight that evil.",
                  "Ferumbras has returned to his citadel once more. Stop him before its too late.",
                  "Orshabaal's minions are working on his return to the World. LEAVE Edron at once, mortals.",
                  "Orshabaal is about to make his way into the mortal realm. Run for your lives!",
                  "Orshabaal has been summoned from hell to plague the lands of mortals again.",
}

hotkeyName = "Entf"
hotkeyID = 46

--If you want to change the hotkeys:
--Home = 36, PGUP = 33, PGDOWN = 34, END = 35, DELETE = 46

local channel = Channel.New("Raid Messages", onSpeak, onClose)
GenericTextMessageProxy.OnReceive("GenProxy", function (proxy, message)
	x = string.match(message, "(%d+)")
	if tonumber(x) == nil and table.contains(listedMessages, message) then
		channel:SendOrangeMessage("Raid Catcher", message)
                alerting = true
	end
end)

function onClose(channel)
	print(channel .. " was closed.")
end

if not Hotkeys.Register(hotkeyID) then
    print("Failed to register raid disable hotkey")
end

function pressHandler(key, control, shift)
    if alerting then
        alerting = false
        print("Alarm disabled.")
    end
end

Hotkeys.AddPressHandler(pressHandler)

Module.New('checkAlerting', function(checkAlerting)
    if alerting then
        alert()
        print("Press " .. hotkeyName .. " to disable alarm and move your ass to BOSS.")
    end
    checkAlerting:Delay(4000)
end)
