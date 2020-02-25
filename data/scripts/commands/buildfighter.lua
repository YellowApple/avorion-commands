package.path = package.path .. ";data/scripts/lib/?.lua"

function execute(sender, commandName, ...)
	local player = Player(sender)
	local args = {...}
    local rest_command = ""
    for i,v in pairs(args) do
        rest_command = rest_command .. " " .. tostring(v)
    end
	player:sendChatMessage(player.name, 0, commandName .. " " .. rest_command)
	Player(sender):addScriptOnce("cmd/buildfighter.lua", ...)
	return 0, "", ""
end

function getDescription()
	return "Builds a fighter from a squad's blueprint."
end

function getHelp()
	return "Builds a fighter from a squad's blueprint. Usage:\n/buildFighter <squad number> <amount>\n"
end
