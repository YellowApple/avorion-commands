-- Returns Player of a given id or name.
-- Returns nil and an error message if not found.
function findPlayerByName(request_name)
	-- In case if player index is passed.
	-- Players have indices starting from 1. Their list ends with faction === nil.
	local player_table = {Galaxy():getPlayerNames()}
	local located = false
	for k,name in pairs(player_table) do
		if request_name == name then
			return Player(k)
		end
	end
	return nil
end

-- Returns n limited between max and min.
function limit(n, max, min)
	return math.min(max, math.max(min, n))
end

-- Looks for a str(ing) in a formatted table. Returns nil if not found.
-- Format: item = {function that checks string, return value, list name}
function findString(table, str)
	for _,item in pairs(table) do
		if item[1](str) then
			return item[2]
		end
	end
end

-- Formats Arguments
function format_args(args)
	if args then
		local str = ""
		for _,v in pairs(args) do
			str = str .. v .. " "
		end
		return str
	else
		return ""
	end
end

-- Add amount of items to the inventory of a faction (or player).
function addItems(faction, item, amount)
	local amount = amount or 1
	for i=1,amount do
		faction:getInventory():add(item)
	end
end