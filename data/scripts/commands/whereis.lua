package.path = package.path .. ";data/scripts/lib/?.lua"

include ("common")

function execute(sender, commandName, otherPlayerName, ...)
	local player = Player(sender)
	if otherPlayerName then
		local args = {...}
		local rest_command = ""
		if #args > 0 then
			for i,v in pairs(args) do
				rest_command = rest_command .. " " .. tostring(v)
			end
		end
		player:sendChatMessage(player.name, 0, commandName .. " " .. otherPlayerName .. rest_command)
		local wantedPlayer = findPlayerByName(otherPlayerName)
		if wantedPlayer then
			-- Push the applicable scripts to the clients.
			player:sendChatMessage(player.name, 0, "Targeted player " .. wantedPlayer.name)
			wantedPlayer:addScriptOnce("cmd/tellposition.lua", player.index)
		else
			player:sendChatMessage("Whereis", 0, "ERROR: could not find player " .. otherPlayerName)
		end
	else
		player:sendChatMessage(player.name, 0, commandName)
		player:sendChatMessage("Whereis", 0, "ERROR: target player not specified")
	end
	return 0, "", ""
end

function getDescription()
	return "Gets the current positon of a player."
end

function getHelp()
	return "Gets the position of a player. Usage: /whereis <name>"
end
