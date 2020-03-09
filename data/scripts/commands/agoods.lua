package.path = package.path .. ";data/scripts/lib/?.lua"
include ("common")
include ("goodsindex")
include ("goods")

function execute(sender, commandName, name, quantity, subType)
    local player = Player(sender)
    if not player or not player.craft then
        return 1, "", "Agoods: You're not in a ship!"
    end
    if not name then
        return 1, "", "Agoods: No good name was specified!"
    end
    quantity = math.floor(tonumber(quantity) or 1) -- make sure that quantity is an int number
    if quantity == 0 then quantity = 1 end
    if not subType then subType = "" end

    player:sendChatMessage(player.name, 0, commandName.." "..name.." "..quantity.." "..subType)

    -- convert everything to lower case to provide case-insensitive search
    name = string.gsub(name:lower(), "_", " ")
    local lowerCaseGoods = {}
    for k, v in pairs(goods) do
        lowerCaseGoods[k:lower()] = v
    end
    if not lowerCaseGoods[name] then
        return 1, "", "Agoods: Couldn't find a good with name '"..name.."'!"
    end

    local ship = player.craft
    local good = tableToGood(lowerCaseGoods[name])

    -- add suspicious/stolen flag
    subType = string.lower(subType)
    if subType == "suspicious" then
        good.suspicious = true
    elseif subType == "stolen" then
        good.stolen = true
    end
    
    if quantity >= 1 then -- add goods
        local freeCargo = ship.freeCargoSpace or 0
        if freeCargo < good.size then
            return 1, "", string.format("Agoods: Ship [%s] has only %.2f remaining cargo space. While good '%s' has the size of %.2f!", ship.name, freeCargo, name, good.size)
        else
            ship:addCargo(good, quantity)
            return 0, "", string.format("Agoods: Added %i instances of %s '%s' to the ship [%s]", math.min(math.floor(freeCargo / good.size), quantity), subType, name, ship.name)
        end
    else -- remove goods
        local currentStock = ship:getCargoAmount(good) or 0
        ship:removeCargo(good, 0 - quantity)
        return 0, "", string.format("Agoods: Removed %i instances of %s '%s' from the ship [%s]", math.min(math.abs(quantity), currentStock), subType, name, ship.name)
    end
end

function getDescription()
    return "Adds goods to currently boarded ship."
end

function getHelp()
    return "Adds goods to currently boarded ship. Usage:\n/agoods <good name> <quantity> [|suspicious|stolen]"
end