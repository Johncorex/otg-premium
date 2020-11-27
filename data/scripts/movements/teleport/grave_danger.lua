local config = {
	[58001] = {position = Position(33458, 31406, 13)}, --Count Vlarkorth - Edron
	[58002] = {position = Position(33425, 31499, 13)}, --Lord Azaram - Ghostland
	[58003] = {position = Position(33519, 31437, 13)}, --Earl Osam - Cormaya
	[58004] = {position = Position(33428, 31406, 13)}, --Sir Baeloc & Sir Nictros - Darashia
	[58005] = {position = Position(33456, 31499, 13)}, --Duke Krule - Thais
	[58006] = {position = Position(33492, 31546, 13)} --King Zelos - Isle of the Kings

}

local graveDangerTp = MoveEvent()

function graveDangerTp.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return false
	end

	for index, value in pairs(config) do
		if item.actionid == index then
			doSendMagicEffect(player:getPosition(), CONST_ME_TELEPORT)
			player:teleportTo(value.position)
			doSendMagicEffect(value.position, CONST_ME_TELEPORT)		
		end
	end
end

graveDangerTp:type("stepin")

for index, value in pairs(config) do
	graveDangerTp:aid(index)
end

graveDangerTp:register()
