package.path = package.path .. ";data/scripts/lib/?.lua"
include ("stringutility")

-- Table of materialTypes for use with `findString()` from `lib.cmd.common`
local material_table = {}
material_table['Iron'] = Material(0)
material_table['Titanium'] = Material(1)
material_table['Naonite'] = Material(2)
material_table['Trinium'] = Material(3)
material_table['Xanion'] = Material(4)
material_table['Ogonite'] = Material(5)
material_table['Avorion'] = Material(6)

--[[local index = 0
local a = nil
local name = ""

-- iterate downwards
while true do
	index = index - 1
	a = Material(index)
	if a and a.name~=nil then
		material_table[a.name] = a
	else
		break
	end
end
-- iterate upwards
index = 0
while true do
	index = index + 1
	a = Material(index)
	if a and a.name~=nil then
		material_table[a.name] = a
	else
		break
	end
end--]]

-- Run levenshtein matching, to return closest Material class
function getMaterial(r)
	local min_dist = nil
	local min_material = nil
	for k, v in pairs(material_table) do
		local curr_dist = levenshtein(string.lower(r), string.lower(k))

		-- must be at least half the same to be a valid match
		if curr_dist <= string.len(k) / 2 then
			if min_dist == nil then
				min_dist = curr_dist
				min_material = v
			else
				if curr_dist < min_dist then
					min_dist = curr_dist
					min_material = v
				end
			end
		end
	end
	return min_material
end

return material_table