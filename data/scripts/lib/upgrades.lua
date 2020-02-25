package.path = package.path .. ";data/scripts/lib/?.lua"
include ("stringutility")
local UpgradeGenerator = include ("upgradegenerator")
local ActualGenerator = UpgradeGenerator["new"]
local scripts_list = ActualGenerator("totally_random_seed")["scripts"]


local upgrade_names = {}
for k, _ in pairs(scripts_list) do
	if k then
		local list = k:split("/")
		list = list[#list]
		local script_name = list:split(".")[1]
		upgrade_names[script_name] = k
	end
end

-- Run levenshtein matching, to get script which closest matches
function getUpgradeScript(upgrade)
	local min_dist = nil
	local min_upgrade = nil

	for name, script in pairs(upgrade_names) do
		local curr_dist = levenshtein(string.lower(upgrade), string.lower(name))

		-- must be at least half the same to be a valid match
		if curr_dist <= string.len(name) / 2 then
			if min_dist == nil then
				min_dist = curr_dist
				min_upgrade = script
			else
				if curr_dist < min_dist then
					min_dist = curr_dist
					min_upgrade = script
				end
			end
		end
	end
	return min_upgrade
end

return upgrade_names