package.path = package.path .. ";data/scripts/lib/?.lua"
include("utility")

local utility_execute = execute

function execute(sender, commandName, ...)
    local player = Player(sender)
    if not player or not player.craft then
        return 1, "", "Eval: You're not in a ship!"
    end
    if not Server():hasAdminPrivileges(player) then
        return 1, "", "Eval: You're not an admin!"
    end

    local code = table.concat({...}, ' ')
    player:sendChatMessage(player.name, 0, "Eval: Executing code: "..code)
    printlog(string.format("Player '%s'(%i) executes code (/eval): %s", player.name, player.index, code))
    
    code = [[
        package.path = package.path .. ";data/scripts/lib/?.lua"
        package.path = package.path .. ";data/scripts/?.lua"
        include("faction")
        include("galaxy")
        include("randomext")
        include("relations")
        include("utility")
        local ShipUtility = include("shiputility")
        local SpawnUtility = include("spawnutility")

        function run(player, entity)
        ]]..code..[[
        end
    ]]
    local result = {utility_execute(code, player, player.craft)}
    for k, v in pairs(result) do
        result[k] = tostring(v)
    end
    result = table.concat(result, ', ')
    player:sendChatMessage(player.name, 0, "Eval: Result: "..result)
    printlog(string.format("Player '%s'(%i) executed code (/eval) with result: %s", player.name, player.index, result))

    return 0, "", ""
end

function getDescription()
    return "Executes code properly without screaming about imaginary errors, unlike /run."
end

function getHelp()
    return "Executes code properly without screaming about imaginary errors, unlike /run. Usage:\n/eval x = 5; x = x + 4; return x"
end