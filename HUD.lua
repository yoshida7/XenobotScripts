CONFIG = {
	["Drokkor"] = {
		LOOT = {"Crystalline Armor","Focus Cape","Glacier Amulet","Glacier Kilt","Leviathan's Amulet","Northwind Rod","Platinum Coin","Sea Serpent Scale","Small Sapphire"},
		SUPPLIES = {"great spirit potion"}
	},
	["Character2"] = {
		LOOT = {"gold coin", "small sapphire", "strong health potion", "energy ring", "life crystal", "strange helmet", "red dragon scale", "red dragon leather", "fire sword", "tower shield", "dragon slayer", "dragon lord trophy", "royal helmet", "dragon scale mail"},
		SUPPLIES = {"avalanche rune", "sudden death rune", "great mana potion", "power bolt", "brown mushroom"}
	},
	["Character3"] = {
		LOOT = {"gold coin", "spiky club", "bola", "ratana", "cheesy figurine", "life preserver", "earflap", "spike shield", "leather harness", "rat god doll", "cheese cutter", "spiky club"},
		SUPPLIES = {"mana potion", "great health potion"}
	},
	REFRESH_TIME = 10
}

INITIALIZED = false

LOOT_ITEMS_EXCEPTIONS = {
	["small rubies"] = function()
		return Item.GetID("small ruby")
	end,
	["small topazes"] = function()
		return Item.GetID("small topaz")
	end,
	["giant shimmering pearl"] = function()
		return math.random(Item.GetID("giant shimmering pearl", 1), Item.GetID("giant shimmering pearl", 2))
	end,
	["music sheet"] = function(CREATURE_NAME)
		if (CREATURE_NAME == "novice of the cult") then
			return Item.GetID("music sheet", 1)
		elseif (CREATURE_NAME == "acolyte of the cult") then
			return Item.GetID("music sheet", 2)
		elseif (CREATURE_NAME == "adept of the cult") then
			return Item.GetID("music sheet", 3)
		elseif (CREATURE_NAME == "enlightened of the cult") then
			return Item.GetID("music sheet", 4)
		elseif (CREATURE_NAME == "grandfather tridian") then
			return math.random(Item.GetID("music sheet", 1), Item.GetID("music sheet", 4))
		end
		return -1
	end,
	["orc teeth"] = function()
		return Item.GetID("orc tooth")
	end,
	["pig feet"] = function()
		return Item.GetID("pig foot")
	end,
}

HEADS_UP_DISPLAY = {
	STATISTICS = HUD.New(0, 0, "", 0, 0, 0),
	SESSION = {
		TEXT = HUD.New(0, 0, "", 0, 0, 0),
		VALUE = HUD.New(0, 0, "", 0, 0, 0)
	},
	EXPERIENCE = {
		TEXT = HUD.New(0, 0, "", 0, 0, 0),
		VALUE = HUD.New(0, 0, "", 0, 0, 0)
	},
	PROFIT = {
		TEXT = HUD.New(0, 0, "", 0, 0, 0),
		VALUE = HUD.New(0, 0, "", 0, 0, 0)
	},
	LOOTED = {
		TEXT = HUD.New(0, 0, "", 0, 0, 0),
		VALUE = HUD.New(0, 0, "", 0, 0, 0)
	},
	WASTED = {
		TEXT = HUD.New(0, 0, "", 0, 0, 0),
		VALUE = HUD.New(0, 0, "", 0, 0, 0)
	},
	BALANCE = {
		TEXT = HUD.New(0, 0, "", 0, 0, 0),
		VALUE = HUD.New(0, 0, "", 0, 0, 0)
	},
	LOOT_HEADER = HUD.New(0, 0, "", 0, 0, 0),
	SUPPLY_HEADER = HUD.New(0, 0, "", 0, 0, 0),
	ITEMS_COUNT = {},
	SUPPLIES_COUNT = {},
	TOTAL_LOOT_HEADER = {
		TEXT = HUD.New(0, 0, "", 0, 0, 0),
		WORTH = HUD.New(0, 0, "", 0, 0, 0)
	}
}

COLORS = {
	LIGHT = {
		FIRST = {255, 255, 255},
		SECOND = {255, 243, 204},
		THIRD = {206, 206, 206}
	},
	DARK = {
		FIRST = {255, 255, 255},
		SECOND = {135, 135, 135},
		THIRD = {206, 206, 206}
	},
	ORANGE = {
		FIRST = {255, 255, 255},
		SECOND = {240, 199, 166},
		THIRD = {206, 206, 206}
	},
	PINK = {
		FIRST = {255, 255, 255},
		SECOND = {242, 193, 193},
		THIRD = {206, 206, 206}
	},
	GREEN = {
		FIRST = {255, 255, 255},
		SECOND = {193, 240, 183},
		THIRD = {206, 206, 206}
	},
	BLUE = {
		FIRST = {255, 255, 255},
		SECOND = {135, 210, 207},
		THIRD = {206, 206, 206}
	},
	PURPLE = {
		FIRST = {255, 255, 255},
		SECOND = {247, 225, 252},
		THIRD = {206, 206, 206}
	}
}

STATS = {}
STATS.MONSTERS_KILLED = 0
STATS.ITEMS_INDEX = -1
STATS.EXPERIENCE = Self.Experience()
STATS.BALANCE = 0
STATS.COLOR = nil

STATS.ITEMS_LOOTED = {}
STATS.ITEMS_LOOTED_WORTH = 0
STATS.TEMP_ITEMS_LIST = {}

SUPPLIES_LOG = {}
STATS.SUPPLIES = {}
STATS.SUPPLIES_USED_WORTH = 0
STATS.TEMP_SUPPLIES_LIST = {}

STATS.TIME_RUNNING = os.time()
STATS.HUD_TIME = os.time()

function string:explode(DELIMITER)
local RETURN_VALUE, FROM = {}, 1
local DELIMITER_FROM, DELIMITER_TO = string.find(self, DELIMITER, FROM)
	while (DELIMITER_FROM) do
		RETURN_VALUE[#RETURN_VALUE + 1] = string.sub(self, FROM, DELIMITER_FROM - 1)
		FROM = DELIMITER_TO + 1
		DELIMITER_FROM, DELIMITER_TO = string.find(self, DELIMITER, FROM)
	end
	RETURN_VALUE[#RETURN_VALUE + 1] = string.sub(self, FROM)
return RETURN_VALUE
end

function sprintf(FORMAT_STRING, ...)
	return #{...} > 0 and tostring(FORMAT_STRING):format(...) or tostring(FORMAT_STRING)
end

function ParseLootMessage(MESSAGE_POINTER, WITH_QUANTITY)
	local LOOT_INFO, LOOT_INFO_TEMP = {NAME = "", ITEMS = {}}
	LOOT_INFO.NAME, LOOT_INFO_TEMP = MESSAGE_POINTER:match("Loot of (.+): (.+)")
	if (LOOT_INFO.NAME) then
		LOOT_INFO.NAME = LOOT_INFO.NAME:gsub("^a ", ""):gsub("^an ", ""):gsub("^the ", ""):lower()
		if (LOOT_INFO_TEMP ~= "nothing") then
			for _, ITEM_NAME in ipairs(LOOT_INFO_TEMP:explode(", ")) do
				local ITEM_QUANTITY, ITEM_NAME_TEMP = tonumber(ITEM_NAME:explode(" ")[1]) or 1, ITEM_NAME:gsub("%d", ""):gsub("^a ", ""):gsub("^an ", ""):trim():lower()
				if (ITEM_QUANTITY > 1) then
					ITEM_NAME_TEMP = ITEM_NAME_TEMP:gsub("s$", "")
				end
				local ITEM_ID = LOOT_ITEMS_EXCEPTIONS[ITEM_NAME_TEMP] and LOOT_ITEMS_EXCEPTIONS[ITEM_NAME_TEMP](LOOT_INFO.NAME) or Item.GetID(ITEM_NAME_TEMP)
				local ITEM_NAME = Item.GetName(ITEM_ID)
				for _, ITEM in pairs(STATS.TEMP_ITEMS_LIST) do
					if (ITEM.ID == ITEM_ID) then
						if (#ITEM_NAME > 0) then
							if (WITH_QUANTITY) then
							local ITEM_FOUND = table.find(LOOT_INFO.ITEMS, ITEM_ID, "ID")
								if (ITEM_FOUND) then
									LOOT_INFO.ITEMS[ITEM_FOUND].QUANTITY = LOOT_INFO.ITEMS[ITEM_FOUND].QUANTITY + ITEM_QUANTITY
								else
									LOOT_INFO.ITEMS[#LOOT_INFO.ITEMS + 1] = {ID = ITEM_ID, NAME = ITEM_NAME, QUANTITY = ITEM_QUANTITY}
								end
							elseif (not table.find(LOOT_INFO.ITEMS, ITEM_NAME)) then
								LOOT_INFO.ITEMS[#LOOT_INFO.ITEMS + 1] = ITEM_NAME
							end
						end
					end
				end
			end
		end
		return LOOT_INFO
	end
return {NAME = "", ITEMS = {}}
end

function table:isempty()
	return next(self) == nil
end

function AddItemsLooted(ITEM_ID, ITEM_AMOUNT, ITEM_VALUE)
local ITEM_ID = Item.GetID(ITEM_ID)
	if (ITEM_ID > 0) then
		if (STATS.ITEMS_LOOTED[ITEM_ID]) then
			STATS.ITEMS_LOOTED[ITEM_ID].QUANTITY = STATS.ITEMS_LOOTED[ITEM_ID].QUANTITY + ITEM_AMOUNT		
			if (ITEM_VALUE) then
				STATS.ITEMS_LOOTED[ITEM_ID].VALUE = ITEM_VALUE
			end
		else
			STATS.ITEMS_LOOTED[ITEM_ID] = {ID = ITEM_ID, NAME = Item.GetName(ITEM_ID), QUANTITY = ITEM_AMOUNT, VALUE = ITEM_VALUE and ITEM_VALUE or Item.GetValue(ITEM_ID)}
		end
	end
return nil
end

function AddSuppliesUsed(ITEM_ID, ITEM_AMOUNT, ITEM_PRICE)
	local ITEM_ID = Item.GetID(ITEM_ID)
	if (ITEM_ID > 0) then
		if (STATS.SUPPLIES[ITEM_ID]) then
		STATS.SUPPLIES[ITEM_ID].QUANTITY = STATS.SUPPLIES[ITEM_ID].QUANTITY + ITEM_AMOUNT
			if (ITEM_PRICE) then
				STATS.SUPPLIES[ITEM_ID].PRICE = ITEM_PRICE
			end
		else
			STATS.SUPPLIES[ITEM_ID] = {ID = ITEM_ID, NAME = Item.GetName(ITEM_ID), TYPE = 0, CURRENT_QUANTITY = 0, QUANTITY = ITEM_AMOUNT, PRICE = ITEM_PRICE and ITEM_PRICE or Item.GetCost(ITEM_ID)}
		end
	end
return nil
end

function FormatNumber(n)
	local left, num, right = string.match(n,"^([^%d]*%d)(%d*)(.-)$")
	return left .. (num:reverse():gsub("(%d%d%d)","%1,"):reverse()) .. right
end

function SessionTime(time)
	local diff = os.time() - time
	local h, m, s = math.floor(diff / 3600), math.floor(diff / 60) % 60, diff % 60
	return ("%02d:%02d:%02d"):format(h, m, s)
end

function SlotCount(ITEM_ID, LOCATION_NAME)
	if (ITEM_ID) then
		if (LOCATION_NAME and table.find({"Helmet", "Armor", "Legs", "Feet", "Amulet", "Weapon", "Ring", "Back", "Shield", "Ammo"}, LOCATION_NAME)) then
		local SLOT_POINTER = Self[LOCATION_NAME]()
			if (ITEM_ID == SLOT_POINTER.id) then
				return SLOT_POINTER.count
			end
		end
	end
end

function GetSuppliesUsed(ITEM_ID) 
	if (ITEM_ID) then
		return STATS.SUPPLIES[Item.GetID(ITEM_ID)].QUANTITY or 0
	end
	return STATS.SUPPLIES
end

function getServerCount(ITEM_ID)
	if (ITEM_ID == SUPPLIES_LOG.ID) then
		return SUPPLIES_LOG.CURRENT_QUANTITY
	end
end

function Initialize()
local X_POSITION, Y_POSITION = 5, 30
	if (not INITIALIZED) then
	local VALUE = CONFIG[Self.Name()]
		STATS.COLOR = VALUE.THEME or nil
		for _, LOOT_ITEM in ipairs(VALUE.LOOT) do
		local LOOT_ITEM_ID = Item.GetID(type(LOOT_ITEM) ~= "table" and LOOT_ITEM or unpack(LOOT_ITEM))
			AddItemsLooted(LOOT_ITEM_ID, 0, Item.GetValue(LOOT_ITEM_ID))
			STATS.TEMP_ITEMS_LIST[#STATS.TEMP_ITEMS_LIST + 1] = {ID = LOOT_ITEM_ID, NAME = LOOT_ITEM, VALUE = Item.GetValue(LOOT_ITEM_ID)}
		end
		
		for _, SUPPLIES_ITEM in ipairs(VALUE.SUPPLIES) do
		local SUPPLIES_ITEM_ID = Item.GetID(type(SUPPLIES_ITEM) ~= "table" and SUPPLIES_ITEM or unpack(SUPPLIES_ITEM))
			AddSuppliesUsed(SUPPLIES_ITEM_ID, 0, Item.GetCost(SUPPLIES_ITEM_ID))
			STATS.TEMP_SUPPLIES_LIST[#STATS.TEMP_SUPPLIES_LIST + 1] = {ID = SUPPLIES_ITEM_ID, NAME = SUPPLIES_ITEM, VALUE = Item.GetCost(SUPPLIES_ITEM_ID)}
		end

		if (table.isempty(STATS.SUPPLIES)) then
			for SUPPLY_SECTION_ID, SUPPLY_SECTION_ITEMS in ipairs({{236, 237, 238, 239, 266, 268, 836, 841, 901, 904, 3148, 3149, 3152, 3153, 3155, 3156, 3158, 3160, 3161, 3164, 3165, 3166, 3172, 3173, 3174, 3175, 3176, 3177, 3178, 3179, 3180, 3182, 3188, 3189, 3190, 3191, 3192, 3195, 3197, 3198, 3200, 3202, 3203, 3577, 3578, 3579, 3580, 3581, 3582, 3583, 3584, 3585, 3586, 3587, 3588, 3589, 3590, 3591, 3592, 3593, 3594, 3595, 3596, 3597, 3598, 3599, 3600, 3601, 3602, 3604, 3606, 3607, 3723, 3724, 3725, 3725, 3726, 3727, 3728, 3729, 3730, 3731, 3732, 5096, 5678, 6125, 6276, 6277, 6278, 6392, 6393, 6500, 6541, 6542, 6543, 6544, 6545, 6569, 6574, 7158, 7159, 7372, 7373, 7375, 7439, 7440, 7443, 7642, 7643, 7644, 7876, 8010, 8011, 8012, 8013, 8014, 8015, 8016, 8017, 8018, 8019, 8020, 8177, 8197, 10328, 10329, 11459, 11460, 11461, 11462, 11681, 11682, 11683, 12310, 13992}, {761, 762, 762, 763, 774, 3446, 3447, 3448, 3449, 3450, 6528, 7363, 7365, 15793, 16141, 16142, 16143}, {1781, 2992, 3277, 3287, 3298, 3347, 7366, 7367, 7368, 7378}}) do
				for _, SUPPLY_SECTION_ITEM in ipairs(SUPPLY_SECTION_ITEMS) do
					for _, ITEM in pairs(STATS.TEMP_SUPPLIES_LIST) do
						if (ITEM.ID == SUPPLY_SECTION_ITEM) then
							STATS.SUPPLIES[SUPPLY_SECTION_ITEM] = {ID = SUPPLY_SECTION_ITEM, NAME = Item.GetName(SUPPLY_SECTION_ITEM), TYPE = SUPPLY_SECTION_ID, CURRENT_QUANTITY = (SUPPLY_SECTION_ID == 1 and getServerCount(SUPPLY_SECTION_ITEM)) or (SUPPLY_SECTION_ID == 2 and SlotCount(SUPPLY_SECTION_ITEM, "Ammo")) or (SUPPLY_SECTION_ID == 3 and SlotCount(SUPPLY_SECTION_ITEM, "Weapon")) or 0, QUANTITY = 0, PRICE = Item.GetCost(SUPPLY_SECTION_ITEM)}
						end
					end
				end
			end
		end

		HEADS_UP_DISPLAY.STATISTICS:SetText("[Statistics]")
		HEADS_UP_DISPLAY.STATISTICS:SetPosition(X_POSITION, Y_POSITION)
		HEADS_UP_DISPLAY.STATISTICS:SetTextColor(STATS.COLOR and unpack(COLORS[STATS.COLOR].FIRST) or 255, 165, 0)

		Y_POSITION = Y_POSITION + 15

		HEADS_UP_DISPLAY.SESSION.TEXT:SetText("Session: ")
		HEADS_UP_DISPLAY.SESSION.TEXT:SetPosition(X_POSITION + 5, Y_POSITION)
		HEADS_UP_DISPLAY.SESSION.TEXT:SetTextColor(STATS.COLOR and unpack(COLORS[STATS.COLOR].SECOND) or 205, 200, 177)
		
		Y_POSITION = Y_POSITION + 15
		
		HEADS_UP_DISPLAY.EXPERIENCE.TEXT:SetText("Experience: ")
		HEADS_UP_DISPLAY.EXPERIENCE.TEXT:SetPosition(X_POSITION + 5, Y_POSITION)
		HEADS_UP_DISPLAY.EXPERIENCE.TEXT:SetTextColor(STATS.COLOR and unpack(COLORS[STATS.COLOR].SECOND) or 205, 200, 177)

		Y_POSITION = Y_POSITION + 15
		
		HEADS_UP_DISPLAY.PROFIT.TEXT:SetText("Profit: ")
		HEADS_UP_DISPLAY.PROFIT.TEXT:SetPosition(X_POSITION + 5, Y_POSITION)
		HEADS_UP_DISPLAY.PROFIT.TEXT:SetTextColor(STATS.COLOR and unpack(COLORS[STATS.COLOR].SECOND) or 205, 200, 177)

		Y_POSITION = Y_POSITION + 15
		
		HEADS_UP_DISPLAY.LOOTED.TEXT:SetText("Looted: ")
		HEADS_UP_DISPLAY.LOOTED.TEXT:SetPosition(X_POSITION + 5, Y_POSITION)
		HEADS_UP_DISPLAY.LOOTED.TEXT:SetTextColor(STATS.COLOR and unpack(COLORS[STATS.COLOR].SECOND) or 205, 200, 177)
		
		Y_POSITION = Y_POSITION + 15
		
		HEADS_UP_DISPLAY.WASTED.TEXT:SetText("Wasted: ")
		HEADS_UP_DISPLAY.WASTED.TEXT:SetPosition(X_POSITION + 5, Y_POSITION)
		HEADS_UP_DISPLAY.WASTED.TEXT:SetTextColor(STATS.COLOR and unpack(COLORS[STATS.COLOR].SECOND) or 205, 200, 177)

		Y_POSITION = Y_POSITION + 15
		
		HEADS_UP_DISPLAY.BALANCE.TEXT:SetText("Balance: ")
		HEADS_UP_DISPLAY.BALANCE.TEXT:SetPosition(X_POSITION + 5, Y_POSITION)
		HEADS_UP_DISPLAY.BALANCE.TEXT:SetTextColor(STATS.COLOR and unpack(COLORS[STATS.COLOR].SECOND) or 205, 200, 177)

		INITIALIZED = true
	end
end

NpcMessageProxy.OnReceive("HUD:GET_BALANCE", function(proxy, npcName, message)
	if (INITIALIZED) then
	local c = string.match(message, "Your account balance is (.+) gold.")
		if (c) then
			STATS.BALANCE =	 c + 0
		end
	end
end)

LootMessageProxy.OnReceive("HUD:GET_LOOT", function(proxy, message)
	if (INITIALIZED) then
	local LOOT_INFO = ParseLootMessage(message, true)
		if (#LOOT_INFO.NAME > 0) then
		STATS.MONSTERS_KILLED = (STATS.MONSTERS_KILLED or 0) + 1
			for _, LOOT_ITEM in ipairs(LOOT_INFO.ITEMS) do
				if (STATS.ITEMS_LOOTED[LOOT_ITEM.ID]) then
					STATS.ITEMS_LOOTED[LOOT_ITEM.ID].QUANTITY = STATS.ITEMS_LOOTED[LOOT_ITEM.ID].QUANTITY + LOOT_ITEM.QUANTITY
				else
					STATS.ITEMS_INDEX = STATS.ITEMS_INDEX + 1
					STATS.ITEMS_LOOTED[LOOT_ITEM.ID] = {INDEX = STATS.ITEMS_INDEX, ID = LOOT_ITEM.ID, NAME = LOOT_ITEM.NAME, QUANTITY = LOOT_ITEM.QUANTITY, VALUE = Item.GetValue(LOOT_ITEM.ID)}
				end
			end
		end
	end
end)

GenericTextMessageProxy.OnReceive("HUD:GET_SUPPLIES", function(proxy, message)
local QUANTITY, NAME = message:match("Using one of (%w+) (.+)...")
	if (NAME) then
	local ITEM_ID = Item.GetID(NAME:gsub("s$", ""))
	local ITEM_NAME = Item.GetName(ITEM_ID)
		for _, ITEM in pairs(STATS.TEMP_SUPPLIES_LIST) do
			if (ITEM.ID == ITEM_ID) then
				SUPPLIES_LOG = {ID = ITEM_ID, NAME = ITEM_NAME, CURRENT_QUANTITY = QUANTITY}
			end
		end
	end
end)

Module.New("HUD:SET_LOOT", function(moduleObject)
local X_POSITION, Y_POSITION, ITEMS_LOOTED_WORTH = 5, 150, 0
	if (INITIALIZED) then
		for _, LOOT_ITEM in pairs(STATS.ITEMS_LOOTED) do
			if (LOOT_ITEM.QUANTITY > 0) then
				HEADS_UP_DISPLAY.LOOT_HEADER:SetText("[Items Looted]")
				HEADS_UP_DISPLAY.LOOT_HEADER:SetPosition(X_POSITION, Y_POSITION - 15)
				HEADS_UP_DISPLAY.LOOT_HEADER:SetTextColor(STATS.COLOR and unpack(COLORS[STATS.COLOR].FIRST) or 255, 165, 0)
			if not (HEADS_UP_DISPLAY.ITEMS_COUNT[LOOT_ITEM.ID]) then
				HEADS_UP_DISPLAY.ITEMS_COUNT[LOOT_ITEM.ID] = {}
				HEADS_UP_DISPLAY.ITEMS_COUNT[LOOT_ITEM.ID].ITEM = HUD.New(0, 0, "", 0, 0, 0)
				HEADS_UP_DISPLAY.ITEMS_COUNT[LOOT_ITEM.ID].WORTH = HUD.New(0, 0, "", 0, 0, 0)
			end

				HEADS_UP_DISPLAY.ITEMS_COUNT[LOOT_ITEM.ID].ITEM:SetText(((#LOOT_ITEM.NAME > 15 and sprintf("%s... ", string.match(string.sub(LOOT_ITEM.NAME, 1, 15), "(.-)%s?$"))) or LOOT_ITEM.NAME):titlecase()) 
				HEADS_UP_DISPLAY.ITEMS_COUNT[LOOT_ITEM.ID].ITEM:SetPosition(X_POSITION + 5, Y_POSITION + (LOOT_ITEM.INDEX * 15))
				HEADS_UP_DISPLAY.ITEMS_COUNT[LOOT_ITEM.ID].ITEM:SetTextColor(STATS.COLOR and unpack(COLORS[STATS.COLOR].SECOND) or 205, 200, 177)
				if os.difftime(os.time(), STATS.HUD_TIME) <= CONFIG.REFRESH_TIME then
					HEADS_UP_DISPLAY.ITEMS_COUNT[LOOT_ITEM.ID].WORTH:SetText((table.contains({3031, 3035, 3043}, LOOT_ITEM.ID) and sprintf("%s gp", FormatNumber(math.floor(LOOT_ITEM.VALUE * LOOT_ITEM.QUANTITY)))) or (LOOT_ITEM.VALUE > 0 and sprintf("%s (%s gp)", FormatNumber(LOOT_ITEM.QUANTITY), FormatNumber(math.floor(LOOT_ITEM.VALUE * LOOT_ITEM.QUANTITY)))) or FormatNumber(LOOT_ITEM.QUANTITY))
				elseif os.difftime(os.time(), STATS.HUD_TIME) >= CONFIG.REFRESH_TIME and os.difftime(os.time(), STATS.HUD_TIME) <= CONFIG.REFRESH_TIME * 2 then
					STATS.ITEM_VALUE_PER_HOUR = math.floor(LOOT_ITEM.QUANTITY / (os.difftime(os.time(), STATS.TIME_RUNNING) / 3600))
					if (STATS.ITEM_VALUE_PER_HOUR == 0) then
						STATS.ITEM_VALUE_PER_HOUR = 1
					end
					HEADS_UP_DISPLAY.ITEMS_COUNT[LOOT_ITEM.ID].WORTH:SetText("" .. FormatNumber(STATS.ITEM_VALUE_PER_HOUR) .. "/hr")
				end
				HEADS_UP_DISPLAY.ITEMS_COUNT[LOOT_ITEM.ID].WORTH:SetPosition(X_POSITION + 115, Y_POSITION + (LOOT_ITEM.INDEX * 15))
				HEADS_UP_DISPLAY.ITEMS_COUNT[LOOT_ITEM.ID].WORTH:SetTextColor(STATS.COLOR and unpack(COLORS[STATS.COLOR].THIRD) or 107, 142, 35)
				ITEMS_LOOTED_WORTH = ITEMS_LOOTED_WORTH + (LOOT_ITEM.VALUE * LOOT_ITEM.QUANTITY)
			end
		end
		STATS.ITEMS_LOOTED_WORTH = ITEMS_LOOTED_WORTH
	end
end)

Module.New("HUD:UPDATE_SUPPLIES", function(moduleObject)
	if (INITIALIZED) then
		for _, SUPPLY_ITEM in pairs(STATS.SUPPLIES) do
			if (SUPPLY_ITEM.TYPE == 1) then
			local SUPPLY_ITEM_QUANTITY = getServerCount(SUPPLY_ITEM.ID)
				if SUPPLY_ITEM_QUANTITY then
					if (SUPPLY_ITEM_QUANTITY ~= SUPPLY_ITEM.CURRENT_QUANTITY) then
						SUPPLY_ITEM.CURRENT_QUANTITY, SUPPLY_ITEM.QUANTITY = SUPPLY_ITEM_QUANTITY, SUPPLY_ITEM.QUANTITY + 1
					end
				end
			elseif (SUPPLY_ITEM.TYPE == 2) then
				if (Self.Ammo().id == SUPPLY_ITEM.ID) then
				local SUPPLY_ITEM_QUANTITY = Self.Ammo().count
					if (SUPPLY_ITEM_QUANTITY < SUPPLY_ITEM.CURRENT_QUANTITY) then
						SUPPLY_ITEM.QUANTITY = SUPPLY_ITEM.QUANTITY + SUPPLY_ITEM.CURRENT_QUANTITY - SUPPLY_ITEM_QUANTITY
					end
					SUPPLY_ITEM.CURRENT_QUANTITY = SUPPLY_ITEM_QUANTITY
				end
			elseif (SUPPLY_ITEM.TYPE == 3) then
				if (Self.Weapon().id == SUPPLY_ITEM.ID) then
				local SUPPLY_ITEM_QUANTITY = Self.Weapon().count
					if (SUPPLY_ITEM_QUANTITY < SUPPLY_ITEM.CURRENT_QUANTITY) then
						SUPPLY_ITEM.QUANTITY = SUPPLY_ITEM.QUANTITY + SUPPLY_ITEM.CURRENT_QUANTITY - SUPPLY_ITEM_QUANTITY
					end
					SUPPLY_ITEM.CURRENT_QUANTITY = SUPPLY_ITEM_QUANTITY
				end
			end
		end
	end
end)

Module.New("HUD:SUPPLIES", function(moduleObject)
local X_POSITION, Y_POSITION, INDEX, SUPPLIES_USED_WORTH = HUDGetDimensions().eqwindowx - 90, 5, 0, 0
	if (INITIALIZED) then
		for _, SUPPLY_ITEM in pairs(GetSuppliesUsed()) do
			if (SUPPLY_ITEM.QUANTITY > 0) then
				HEADS_UP_DISPLAY.SUPPLY_HEADER:SetText("[Supplies Used]")
				HEADS_UP_DISPLAY.SUPPLY_HEADER:SetPosition(X_POSITION, Y_POSITION)
				HEADS_UP_DISPLAY.SUPPLY_HEADER:SetTextColor(STATS.COLOR and unpack(COLORS[STATS.COLOR].FIRST) or 255, 165, 0)

				if not (HEADS_UP_DISPLAY.SUPPLIES_COUNT[SUPPLY_ITEM.ID]) then
					HEADS_UP_DISPLAY.SUPPLIES_COUNT[SUPPLY_ITEM.ID] = {}
					HEADS_UP_DISPLAY.SUPPLIES_COUNT[SUPPLY_ITEM.ID].ITEM = HUD.New(0, 0, 0, 0, 0, 0)
					HEADS_UP_DISPLAY.SUPPLIES_COUNT[SUPPLY_ITEM.ID].WORTH = HUD.New(0, 0, "", 0, 0, 0)
					HEADS_UP_DISPLAY.SUPPLIES_COUNT[SUPPLY_ITEM.ID].QUANTITY = HUD.New(0, 0, "", 0, 0, 0)
				end

				HEADS_UP_DISPLAY.SUPPLIES_COUNT[SUPPLY_ITEM.ID].ITEM:SetItemID(SUPPLY_ITEM.ID)
				HEADS_UP_DISPLAY.SUPPLIES_COUNT[SUPPLY_ITEM.ID].ITEM:SetItemSize(32)
				HEADS_UP_DISPLAY.SUPPLIES_COUNT[SUPPLY_ITEM.ID].ITEM:SetItemCount(100)
				HEADS_UP_DISPLAY.SUPPLIES_COUNT[SUPPLY_ITEM.ID].ITEM:SetPosition(X_POSITION, Y_POSITION + 10 + (25 * INDEX))

				HEADS_UP_DISPLAY.SUPPLIES_COUNT[SUPPLY_ITEM.ID].WORTH:SetText(sprintf("%s gp", FormatNumber(math.floor(SUPPLY_ITEM.PRICE * SUPPLY_ITEM.QUANTITY))))
				HEADS_UP_DISPLAY.SUPPLIES_COUNT[SUPPLY_ITEM.ID].WORTH:SetPosition(X_POSITION + 30, Y_POSITION + 13 + (25 * INDEX))
				HEADS_UP_DISPLAY.SUPPLIES_COUNT[SUPPLY_ITEM.ID].WORTH:SetTextColor(STATS.COLOR and unpack(COLORS[STATS.COLOR].THIRD) or 107, 142, 35)

				if os.difftime(os.time(), STATS.HUD_TIME) <= CONFIG.REFRESH_TIME then
					HEADS_UP_DISPLAY.SUPPLIES_COUNT[SUPPLY_ITEM.ID].QUANTITY:SetText(sprintf("%s", FormatNumber(SUPPLY_ITEM.QUANTITY)))
				elseif os.difftime(os.time(), STATS.HUD_TIME) >= CONFIG.REFRESH_TIME and os.difftime(os.time(), STATS.HUD_TIME) <= CONFIG.REFRESH_TIME * 2 then
					STATS.SUPPLY_VALUE_PER_HOUR = math.floor(SUPPLY_ITEM.QUANTITY / (os.difftime(os.time(), STATS.TIME_RUNNING) / 3600))
					if (STATS.SUPPLY_VALUE_PER_HOUR == 0) then
						STATS.SUPPLY_VALUE_PER_HOUR = 1
					end
					HEADS_UP_DISPLAY.SUPPLIES_COUNT[SUPPLY_ITEM.ID].QUANTITY:SetText("" .. FormatNumber(STATS.SUPPLY_VALUE_PER_HOUR) .. "/hr")
				end
				HEADS_UP_DISPLAY.SUPPLIES_COUNT[SUPPLY_ITEM.ID].QUANTITY:SetPosition(X_POSITION + 30, Y_POSITION + 25 + (25 * INDEX))
				HEADS_UP_DISPLAY.SUPPLIES_COUNT[SUPPLY_ITEM.ID].QUANTITY:SetTextColor(STATS.COLOR and unpack(COLORS[STATS.COLOR].THIRD) or 107, 142, 35)
				INDEX, SUPPLIES_USED_WORTH = INDEX + 1, SUPPLIES_USED_WORTH + (SUPPLY_ITEM.PRICE * SUPPLY_ITEM.QUANTITY)
			end
		end
		STATS.SUPPLIES_USED_WORTH = SUPPLIES_USED_WORTH
	end
end)

Module.New("HUD:STATISTICS", function(moduleObject)
local X_POSITION, Y_POSITION = 120, 45
	if (INITIALIZED) then
		STATS.EXPERIENCE_GAINED = Self.Experience() - STATS.EXPERIENCE
		STATS.EXPERIENCE_PER_HOUR = STATS.EXPERIENCE_GAINED / (os.difftime(os.time(), STATS.TIME_RUNNING) / 3600)
		STATS.LOOT_PER_HOUR = STATS.ITEMS_LOOTED_WORTH / (os.difftime(os.time(), STATS.TIME_RUNNING) / 3600)
		STATS.PROFIT_PER_HOUR = (STATS.ITEMS_LOOTED_WORTH - STATS.SUPPLIES_USED_WORTH) / (os.difftime(os.time(), STATS.TIME_RUNNING) / 3600)
		STATS.WASTED_PER_HOUR = STATS.SUPPLIES_USED_WORTH / (os.difftime(os.time(), STATS.TIME_RUNNING) / 3600)

		HEADS_UP_DISPLAY.SESSION.VALUE:SetText(SessionTime(STATS.TIME_RUNNING))
		HEADS_UP_DISPLAY.SESSION.VALUE:SetPosition(X_POSITION, Y_POSITION)
		HEADS_UP_DISPLAY.SESSION.VALUE:SetTextColor(STATS.COLOR and unpack(COLORS[STATS.COLOR].THIRD) or 255, 255, 255)

		Y_POSITION = Y_POSITION + 15
		if os.difftime(os.time(), STATS.HUD_TIME) <= CONFIG.REFRESH_TIME then
			HEADS_UP_DISPLAY.EXPERIENCE.VALUE:SetText(FormatNumber(STATS.EXPERIENCE_GAINED))
		elseif os.difftime(os.time(), STATS.HUD_TIME) >= CONFIG.REFRESH_TIME and os.difftime(os.time(), STATS.HUD_TIME) <= CONFIG.REFRESH_TIME * 2 then
			HEADS_UP_DISPLAY.EXPERIENCE.VALUE:SetText("" .. FormatNumber(math.floor(STATS.EXPERIENCE_PER_HOUR)) .. "/hr")
		end
		HEADS_UP_DISPLAY.EXPERIENCE.VALUE:SetPosition(X_POSITION, Y_POSITION)
		HEADS_UP_DISPLAY.EXPERIENCE.VALUE:SetTextColor(STATS.COLOR and unpack(COLORS[STATS.COLOR].THIRD) or 255, 255, 255)

		Y_POSITION = Y_POSITION + 15
		if os.difftime(os.time(), STATS.HUD_TIME) <= CONFIG.REFRESH_TIME then
			HEADS_UP_DISPLAY.PROFIT.VALUE:SetText("" .. FormatNumber(STATS.ITEMS_LOOTED_WORTH - STATS.SUPPLIES_USED_WORTH) .. " gp")
		elseif os.difftime(os.time(), STATS.HUD_TIME) >= CONFIG.REFRESH_TIME and os.difftime(os.time(), STATS.HUD_TIME) <= CONFIG.REFRESH_TIME * 2 then
			HEADS_UP_DISPLAY.PROFIT.VALUE:SetText("" .. FormatNumber(math.floor(STATS.PROFIT_PER_HOUR)) .. "/hr")
		end
		HEADS_UP_DISPLAY.PROFIT.VALUE:SetPosition(X_POSITION, Y_POSITION)
		HEADS_UP_DISPLAY.PROFIT.VALUE:SetTextColor(STATS.COLOR and unpack(COLORS[STATS.COLOR].THIRD) or 255, 255, 255)

		Y_POSITION = Y_POSITION + 15
		if os.difftime(os.time(), STATS.HUD_TIME) <= CONFIG.REFRESH_TIME then
			HEADS_UP_DISPLAY.LOOTED.VALUE:SetText("" .. FormatNumber(STATS.ITEMS_LOOTED_WORTH) .. " gp")
		elseif os.difftime(os.time(), STATS.HUD_TIME) >= CONFIG.REFRESH_TIME and os.difftime(os.time(), STATS.HUD_TIME) <= CONFIG.REFRESH_TIME * 2 then
			HEADS_UP_DISPLAY.LOOTED.VALUE:SetText("" .. FormatNumber(math.floor(STATS.LOOT_PER_HOUR)) .. "/hr")
		end
		HEADS_UP_DISPLAY.LOOTED.VALUE:SetPosition(X_POSITION, Y_POSITION)
		HEADS_UP_DISPLAY.LOOTED.VALUE:SetTextColor(STATS.COLOR and unpack(COLORS[STATS.COLOR].THIRD) or 255, 255, 255)
		
		Y_POSITION = Y_POSITION + 15
		if os.difftime(os.time(), STATS.HUD_TIME) <= CONFIG.REFRESH_TIME then
			HEADS_UP_DISPLAY.WASTED.VALUE:SetText("" .. FormatNumber(STATS.SUPPLIES_USED_WORTH) .. " gp")
		elseif os.difftime(os.time(), STATS.HUD_TIME) >= CONFIG.REFRESH_TIME and os.difftime(os.time(), STATS.HUD_TIME) <= CONFIG.REFRESH_TIME * 2 then
			HEADS_UP_DISPLAY.WASTED.VALUE:SetText("" .. FormatNumber(math.floor(STATS.WASTED_PER_HOUR)) .. "/hr")
		else
			STATS.HUD_TIME = os.time()
		end
		HEADS_UP_DISPLAY.WASTED.VALUE:SetPosition(X_POSITION, Y_POSITION)
		HEADS_UP_DISPLAY.WASTED.VALUE:SetTextColor(STATS.COLOR and unpack(COLORS[STATS.COLOR].THIRD) or 255, 255, 255)
		
		Y_POSITION = Y_POSITION + 15
		HEADS_UP_DISPLAY.BALANCE.VALUE:SetText("" .. FormatNumber(STATS.BALANCE) .. " gp")
		HEADS_UP_DISPLAY.BALANCE.VALUE:SetPosition(X_POSITION, Y_POSITION)
		HEADS_UP_DISPLAY.BALANCE.VALUE:SetTextColor(STATS.COLOR and unpack(COLORS[STATS.COLOR].THIRD) or 255, 255, 255)
	end
end)

Initialize()