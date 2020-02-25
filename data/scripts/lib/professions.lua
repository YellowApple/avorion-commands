package.path = package.path .. ";data/scripts/lib/?.lua"
include ("stringutility")

-- Table of professionTypes for use with `findString()` from `lib.cmd.common`
local profession_table = {}
profession_table[0] ="None"
profession_table[1] ="Engine"
profession_table[2] ="Gunner"
profession_table[3] ="Miner"
profession_table[4] ="Mechanic"
profession_table[5] ="Pilot"
profession_table[6] ="Security"
profession_table[7] ="Boarder"
profession_table[8] ="Sergeant"
profession_table[9] ="Lieutenant"
profession_table[10] ="Commander"
profession_table[11] ="General"
profession_table[12] ="Captain"
profession_table[13] ="Number"

-- Run levenshtein matching, to return closest CrewProfession class
function getCrewProfession(r)
	local min_dist = nil
	local min_profession = nil
	for k, v in pairs(profession_table) do
		local curr_dist = levenshtein(string.lower(r), string.lower(v))

		-- must be at least half the same to be a valid match
		if curr_dist <= string.len(v) / 2 then
			if min_dist == nil then
				min_dist = curr_dist
				min_profession = k
			else
				if curr_dist < min_dist then
					min_dist = curr_dist
					min_profession = k
				end
			end
		end
	end
	return min_profession
end

return profession_table
