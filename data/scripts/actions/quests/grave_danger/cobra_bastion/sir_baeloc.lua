local setting = {
	centerRoom = {x = 33424, y = 31440, z = 13}, -- centro sala
	storage = Storage.GraveDanger.Tombs.SirBaelocTimer,
	boss1Position = {x = 33422, y = 31428, z = 13}, -- posicao boss 1
	boss2Position = {x = 33427, y = 31428, z = 13}, -- posicao boss 2
	kickPosition = {x = 33290, y = 32474, z = 9}, -- pra onde toma kick
	playerTeleport = {x = 33424, y = 31431, z = 13} -- pra onde player vai
}

local vlarkorthLever = Action()

-- Start Script
function vlarkorthLever.onUse(creature, item, fromPosition, target, toPosition, isHotkey)
	if item.itemid == 9825 and item.actionid == 57609 then
	local clearVlarkorthRoom = Game.getSpectators(Position(setting.centerRoom), false, false, 11, 11, 11, 11)       
	for index, spectatorcheckface in ipairs(clearVlarkorthRoom) do
		if spectatorcheckface:isPlayer() then
			creature:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Someone is fighting against the boss! You need wait awhile.")
			return false
		end
	end	
	for index, removeVlarkorth in ipairs(clearVlarkorthRoom) do
		if (removeVlarkorth:isMonster()) then
			removeVlarkorth:remove()
		end
	end
		Game.createMonster("Sir Baeloc", setting.boss1Position, false, true)
		Game.createMonster("Sir Nictros", setting.boss2Position, false, true)
	local players = {}
	for i = 0, 4 do
		local player1 = Tile({x = (Position(item:getPosition()).x + 1) + i, y = Position(item:getPosition()).y, z = Position(item:getPosition()).z}):getTopCreature()
		players[#players+1] = player1
	end
		for i, player in ipairs(players) do
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			player:teleportTo(Position(setting.playerTeleport), false)
			doSendMagicEffect(player:getPosition(), CONST_ME_TELEPORT)
			setPlayerStorageValue(player,setting.storage, os.time() + 20 * 60 * 60)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'You have 20 minute(s) to defeat the boss.')
				addEvent(function()
					local spectatorsVlarkorth = Game.getSpectators(Position(setting.centerRoom), false, false, 11, 11, 11, 11)
						for u = 1, #spectatorsVlarkorth, 1 do
							if spectatorsVlarkorth[u]:isPlayer() and (spectatorsVlarkorth[u]:getName() == player:getName()) then
								player:teleportTo(Position(setting.kickPosition))
								player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
								player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'Time is over.')
							end
						end
				end, 20 * 60 * 1000)
		end
	end
	return true
end

vlarkorthLever:aid(57609)
vlarkorthLever:register()
