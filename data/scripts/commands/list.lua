package.path = package.path .. ";data/scripts/lib/?.lua"

include ("stringutility")

function string_first(table)
	local str = "Available:"
	for k,_ in pairs(table) do
		str = str .. "\n" .. k
	end
	str = str .. "\n"
	return str
end

function number_first(table)
	local str = "Available:"
	for _,v in pairs(table) do
		str = str .. "\n" .. v
	end
	str = str .. "\n"
	return str
end

local professions = include ("professions")
local materials = include ("materials")
local rarities = include ("rarities")
local ranks = include ("ranks")
local upgrades = include ("upgrades")
local weapons = include ("weapons")

local lists = {}
lists['professions'] = {number_first, professions}
lists['materials'] = {string_first, materials}
lists['rarities'] = {string_first, rarities}
lists['ranks'] = {number_first, ranks}
lists['upgrades'] = {string_first, upgrades}
lists['weapons'] = {number_first, weapons}

-- Run levenshtein matching, to get script which closest matches
function get_best_fit(name)
	local min_dist = nil
	local min_fit = nil

	for k, v in pairs(lists) do
		local curr_dist = levenshtein(string.lower(name), string.lower(k))
		
		-- must be at least half the same to be a valid match
		if curr_dist <= string.len(k) / 2 then
			if min_dist == nil then
				min_dist = curr_dist
				min_fit = v
			else
				if curr_dist < min_dist then
					min_dist = curr_dist
					min_fit = v
				end
			end
		end
	end
	return min_fit
end

function execute(sender, commandName, name, ...)
	local player = Player(sender)
    local args = {...}
    local rest_command = ""
    for i,v in pairs(args) do
        rest_command = rest_command .. " " .. tostring(v)
	end
	if name then
		player:sendChatMessage(player.name, 0, commandName .. " " .. name .. rest_command)
	else
		player:sendChatMessage(player.name, 0, commandName .. rest_command)
	end

	local msg = "You can't see this message. (An error)"

	if name then
		-- if name is present look for a type
		local list = get_best_fit(name)
		if list ~= nil then
			local func = list[1]
			local table = list[2]
			msg = func(table)
			player:sendChatMessage("List", 0, msg)
		else
			msg = string.format("ERROR: Could not locate type %s.", name)
			player:sendChatMessage("List", 0, msg)
		end
	else
		-- print all if no name present
		msg = "Available:\nProfessions\nRanks\nMaterials\nRarities\nUpgrades\nWeapons\n"
		player:sendChatMessage("List", 0, msg)
	end

	return 0, "", ""
end

function printAvailable(table)
	local str = "Available:"
	for _,item in ipairs(table) do
		str = str .. "\n" .. item[3]
	end
	return true, str
end

function getDescription()
	return "Lists possible variables for /inventory or /crew."
end

function getHelp()
	return "Lists possible variables for /inventory or /crew. Usage: /list [type]. Use /list to print types."
end
