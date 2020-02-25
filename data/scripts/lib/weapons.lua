package.path = package.path .. ";data/scripts/lib/?.lua"
include ("stringutility")
include ("weapontype")

local reverse_WeaponType = {}
for k,v in pairs(WeaponType) do
	reverse_WeaponType[v] = k
end

-- Run levenshtein matching, to return closest weapon id
function getWeapon(r)
	local min_dist = nil
	local min_weapon = nil
	for k, v in pairs(WeaponType) do
		local curr_dist = levenshtein(string.lower(r), string.lower(k))

		-- must be at least half the same to be a valid match
		if curr_dist <= string.len(k) / 2 then
			if min_dist == nil then
				min_dist = curr_dist
				min_weapon = v
			else
				if curr_dist < min_dist then
					min_dist = curr_dist
					min_weapon = v
				end
			end
		end
	end
	return min_weapon
end

return reverse_WeaponType
