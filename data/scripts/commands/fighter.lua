package.path = package.path .. ";data/scripts/lib/?.lua"
include ("common")

function execute(sender, commandName, action, ...)
	local player = Player(sender)
	local args = {...}
    local rest_command = ""
    for i,v in pairs(args) do
        rest_command = rest_command .. " " .. tostring(v)
    end
	player:sendChatMessage(player.name, 0, commandName .. " " .. action .. rest_command)
	Player(sender):addScriptOnce("cmd/fighter.lua", action, ...)
	return 0, "", ""
end

function getDescription()
	return "Adds fighters to players hangar."
end

function getHelp()
	return "Adds fighters to players hangar. Usage:\n/fighter add <weapon> [rarity] [material] [tech]\n"
end
