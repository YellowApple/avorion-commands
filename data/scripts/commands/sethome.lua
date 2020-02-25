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

   	player:addScriptOnce("cmd/sethome.lua")
    return 0, "", ""
end

function getDescription()
    return "Allows player to change home sector to current if friendly or own station is present."
end

function getHelp()
    return "Allows player to change home sector to current if friendly or own station is present. Usage: /sethome"
end
