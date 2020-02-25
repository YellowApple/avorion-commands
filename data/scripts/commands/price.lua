package.path = package.path .. ";data/scripts/lib/?.lua"
include ("common")

function execute(sender, commandName, ...)
	local player = Player(sender)
    local args = {...}
    local rest_command = ""
    for i,v in pairs(args) do
        rest_command = rest_command .. " " .. tostring(v)
    end
    player:sendChatMessage(player.name, 0, commandName .. rest_command)

   	player:addScriptOnce("cmd/price.lua")
    return 0, "", ""
end

function getDescription()
    return "Prints price of currently boarded ship."
end

function getHelp()
    return "Prints price of currently boarded ship. Usage: /price"
end
