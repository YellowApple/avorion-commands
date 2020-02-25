package.path = package.path .. ";data/scripts/lib/?.lua"
include ("stringutility")

-- Table of rarityTypes for use with `findString()` from `lib.cmd.common`
local rarity_table = {}
rarity_table['Petty'] = Rarity(-1)
rarity_table['Common'] = Rarity(0)
rarity_table['Uncommon'] = Rarity(1)
rarity_table['Rare'] = Rarity(2)
rarity_table['Exceptional'] = Rarity(3)
rarity_table['Exotic'] = Rarity(4)
rarity_table['Legendary'] = Rarity(5)

--[[local index = 0
local a = nil
local name = ""

-- iterate downwards
while true do
	index = index - 1
	a = Rarity(index)
	if a and a.name~=nil then
		rarity_table[a.name] = a
	else
		break
	end
end
-- iterate upwards
index = 0
while true do
	index = index + 1
	a = Rarity(index)
	if a and a.name~=nil then
		rarity_table[a.name] = a
	else
		break
	end
end--]]

-- Run levenshtein matching, to return closest Rarity class
function getRarity(r)
	local min_dist = nil
	local min_rarity = nil
	for k, v in pairs(rarity_table) do
		local curr_dist = levenshtein(string.lower(r), string.lower(k))

		-- must be at least half the same to be a valid match
		if curr_dist <= string.len(k) / 2 then
			if min_dist == nil then
				min_dist = curr_dist
				min_rarity = v
			else
				if curr_dist < min_dist then
					min_dist = curr_dist
					min_rarity = v
				end
			end
		end
	end
	return min_rarity
end

return rarity_table