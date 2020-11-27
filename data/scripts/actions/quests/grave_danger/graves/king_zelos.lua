local setting = {
	centerRoom = {x = 33456, y = 31437, z = 13}, -- centro sala
	storage = Storage.GraveDanger.Tombs.KingZelosTimer,
	bossPosition = {x = 33456, y = 31436, z = 13}, -- posicao boss
	kickPosition = {x = 33458, y = 31406, z = 13}, -- pra onde toma kick
	playerTeleport = {x = 33457, y = 31443, z = 13} -- pra onde player vai
}

local vlarkorthLever = Action()

-- Start Script
function vlarkorthLever.onUse(creature, item, fromPosition, target, toPosition, isHotkey)
	if item.itemid == 9825 and item.actionid == 57611 then
	local clearVlarkorthRoom = Game.getSpectators(Position(setting.centerRoom), false, false, 25, 25, 25, 25)       
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
		Game.createMonster("Count Vlarkorth", setting.bossPosition, false, true)
	local players = {}
	for i = 0, 4 do
		local player1 = Tile({x = (Position(item:getPosition()).x + 1) + i, y = Position(item:getPosition()).y, z = Position(item:getPosition()).z}):getTopCreature()
		players[#players+1] = player1
	end
		for i, player in ipairs(players) do
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			player:teleportTo(Position(setting.playerTeleport), false)
			doSendMagicEffect(player:getPosition(), CONST_ME_TELEPORT)
			setPlayerStorageValue(player,setting.storage, os.time() + 15 * 60 * 60 * 60)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'You have 30 minute(s) to defeat the King Zelos.')
				addEvent(function()
					local spectatorsVlarkorth = Game.getSpectators(Position(setting.centerRoom), false, false, 25, 25, 25, 25)
						for u = 1, #spectatorsVlarkorth, 1 do
							if spectatorsVlarkorth[u]:isPlayer() and (spectatorsVlarkorth[u]:getName() == player:getName()) then
								player:teleportTo(Position(setting.kickPosition))
								player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
								player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'Time is over.')
							end
						end
				end, 30 * 60 * 1000)
		end
	end
	return true
end

vlarkorthLever:aid(57611)
vlarkorthLever:register()
