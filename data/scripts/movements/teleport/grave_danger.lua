local config = {
	[58001] = {position = Position(33458, 31406, 13)}, --Count Vlarkorth - Edron
	[58002] = {position = Position(33425, 31499, 13)}, --Lord Azaram - Ghostland
	[58003] = {position = Position(33519, 31437, 13)}, --Earl Osam - Cormaya
	[58004] = {position = Position(33428, 31406, 13)}, --Sir Baeloc & Sir Nictros - Darashia
	[58005] = {position = Position(33456, 31499, 13)}, --Duke Krule - Thais
	[58006] = {position = Position(33492, 31546, 13)} --King Zelos - Isle of the Kings

}

local graveDanger = MoveEvent()

function graveDanger.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return false
	end

	for index, value in pairs(config) do
		if item.actionid == index then
			if(item.actionid == 58001)then
				if(player:getStorageValue(Storage.GraveDanger.Tombs.CountVlarkorthTimer) > os.time())then
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have faced this boss in the last 20 hours.\nNext time date:  " .. os.date("%d/%b/%Y - %X", player:getStorageValue(52313))..".")
					player:teleportTo(fromPosition, true)
					player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
					return false
				end
			end
			if(item.actionid == 58002)then
				if(player:getStorageValue(Storage.GraveDanger.Tombs.LordAzaramTimer) > os.time())then
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have faced this boss in the last 20 hours.\nNext time date:  " .. os.date("%d/%b/%Y - %X", player:getStorageValue(52314))..".")
					player:teleportTo(fromPosition, true)
					player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
					return false
				end
			end
			if(item.actionid == 58003)then
				if(player:getStorageValue(Storage.GraveDanger.Tombs.EarlOsamTimer) > os.time())then
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have faced this boss in the last 20 hours.\nNext time date:  " .. os.date("%d/%b/%Y - %X", player:getStorageValue(52315))..".")
					player:teleportTo(fromPosition, true)
					player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
					return false
				end
			end
			if(item.actionid == 58004)then
				if(player:getStorageValue(Storage.GraveDanger.Tombs.SirBaelocTimer) > os.time())then
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have faced this boss in the last 20 hours.\nNext time date:  " .. os.date("%d/%b/%Y - %X", player:getStorageValue(52316))..".")
					player:teleportTo(fromPosition, true)
					player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
					return false
				end
			end
			if(item.actionid == 58005)then
				if(player:getStorageValue(Storage.GraveDanger.Tombs.DukeKruleTimer) > os.time())then
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have faced this boss in the last 20 hours.\nNext time date:  " .. os.date("%d/%b/%Y - %X", player:getStorageValue(52317))..".")
					player:teleportTo(fromPosition, true)
					player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
					return false
				end
			end
			if(item.actionid == 58006)then
				if(player:getStorageValue(Storage.GraveDanger.Tombs.KingZelosTimer) > os.time())then
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have faced this boss in the last 15 days.\nNext time date:  " .. os.date("%d/%b/%Y - %X", player:getStorageValue(52318))..".")
					player:teleportTo(fromPosition, true)
					player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
					return false
				end
			end
			doSendMagicEffect(player:getPosition(), CONST_ME_TELEPORT)
			player:teleportTo(value.position)
			doSendMagicEffect(value.position, CONST_ME_TELEPORT)		
		end
	end
end

function mathtime(table) -- by dwarfer
    local unit = {"sec", "min", "hour", "day"}
    for i, v in pairs(unit) do
        if v == table[2] then
            return table[1]*(60^(v == unit[4] and 2 or i-1))*(v == unit[4] and 24 or 1)
        end
    end
    return error("Bad declaration in mathtime function.")
end

graveDanger:type("stepin")

for index, value in pairs(config) do
	graveDanger:aid(index)
end

graveDanger:register()
