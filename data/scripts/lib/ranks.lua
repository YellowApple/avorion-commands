package.path = package.path .. ";data/scripts/lib/?.lua"
include ("stringutility")

local ranks_table = {}
ranks_table[0] = "Untrained"
ranks_table[1] = "Professional"

-- if not provided, return 0 for untrained
function getRank(r)
	if not r then
		return 0
	end

	local min_dist = nil
	local min_rank = nil
	for k, v in pairs(ranks_table) do
		local curr_dist = levenshtein(string.lower(r), string.lower(v))

		-- must be at least half the same to be a valid match
		if curr_dist <= string.len(v) / 2 then
			if min_dist == nil then
				min_dist = curr_dist
				min_rank = k
			else
				if curr_dist < min_dist then
					min_dist = curr_dist
					min_rank = k
				end
			end
		end
	end
	return min_rank
end

return ranks_table