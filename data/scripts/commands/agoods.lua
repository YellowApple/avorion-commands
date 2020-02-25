package.path = package.path .. ";data/scripts/lib/?.lua"

include ("common")
include ("goodsindex")
include ("goods")


function execute(sender, commandName, name, quantity, ...)
    local player = Player(sender)

    if name then
        if quantity then
            local args = {...}
            local rest_command = ""
            if #args > 0 then
                for i,v in pairs(args) do
                    rest_command = rest_command .. " " .. tostring(v)
                end
            end
            player:sendChatMessage(player.name, 0, commandName .. " " .. name .. " " .. quantity .. rest_command)
        else
            player:sendChatMessage(player.name, 0, commandName .. " " .. name)
        end

        if tonumber(quantity or 1) then
	        local name = string.gsub(name, "_", " ")

            if goods[name] ~= nil then
                local ship = player.craft
                local good = tableToGood(goods[name])

                if tonumber(quantity or 1) >= 0 then
                    local free_cargo = ship.freeCargoSpace

                    if free_cargo < good.size then
                        player:sendChatMessage("Agoods", 0, "ERROR: Ship [" .. ship.name .. "] has " .. string.format("%.2f", free_cargo) .. " remaining cargo space. " .. name .. " is size " .. string.format("%.2f", good.size))
                    else
                        ship:addCargo(good, tonumber(quantity or 1))
                        player:sendChatMessage("Agoods", 0, "Added " .. tostring(math.min(math.floor(free_cargo / good.size), tonumber(quantity or 1))) .. " instances of " .. name .. " to ship [" .. ship.name .. "]")
                    end
                else
                    local current_stock = ship:getCargoAmount(good)
                    ship:removeCargo(good, 0 - tonumber(quantity))
                    player:sendChatMessage("Agoods", 0, "Removed " .. tostring(math.min(math.abs(quantity or 1), current_stock)) .. "  instances of " .. name .. " from ship [" .. ship.name .. "]")
                end
            else
                player:sendChatMessage("Agoods", 0, string.format("ERROR: %s is not a good!", name))
            end
        else
            player:sendChatMessage("Agoods", 0, string.format("ERROR: %s is not a number!", quantity))
        end
    else
        player:sendChatMessage(player.name, 0, "/agoods")
        player:sendChatMessage("Agoods", 0, "ERROR: no good name specified")
    end
    return 0, "", ""
end

function getDescription()
    return "Adds goods to currently boarded ship."
end

function getHelp()
    return "Adds goods currently boarded ship. Usage:\n/agoods <good name with _(underscore) instead of spaces> <quantity>"
end
