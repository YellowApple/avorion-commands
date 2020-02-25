if onServer() then
	package.path = package.path .. ";data/scripts/lib/?.lua"
	include ("common")
	professions = include ("professions")
	ranks = include ("ranks")

	function initialize(help, action, ...)
		local flag, msg = false, ""
		player = Player()

		if action then
			local args = {...}
			local rest_command = ""
			if #args > 0 then
				for i,v in pairs(args) do
					rest_command = rest_command .. " " .. tostring(v)
				end
			end
			player:sendChatMessage(player.name, 0, "/crew " .. action .. rest_command)
		else
			player:sendChatMessage(player.name, 0, "/crew")
		end

		if action == "fill" then
			local ship = Entity(Player().craftIndex)
			ship.crew = ship.minCrew
			ship:addCrew(1, CrewMan(CrewProfessionType.Captain, 1))
			player:sendChatMessage("Crew", 0, "Minimal crew has boarded the ship!")
		elseif action == "add" then
			local ship = Entity(Player().craftIndex)
			flag, msg = addCrew(ship, ...)
			player:sendChatMessage("Crew", 0, msg)
		elseif action == "clear" then
			Entity(Player().craftIndex).crew = Crew()
			player:sendChatMessage("Crew", 0, "Current ship's crew has been cleared.")
		elseif action == "help" or action == nil then
			player:sendChatMessage("Crew", 0, help)
		else
			player:sendChatMessage("Crew", 0, "Unknown action: " .. action)
		end
		terminate()
	end

	function addCrew(ship, profession, rank, level, amount)
		-- absolutely require a desired profession
		if profession then
			local adj_level = limit(tonumber(level or 1), 4, 1)
			local profession_id = getCrewProfession(profession)
			if profession_id then
				local profession_ent = CrewProfession(profession_id)
				if profession_ent == nil then
					return false, "ERROR: " .. profession .. " not recognized profession"
				end
				-- If no rank parameter passed, assume rest is 1, 1, 1
				local adj_rank = getRank(rank)
				if adj_rank then
					if adj_rank == 0 then
						adj_level = 1
					end
					if tonumber(amount or 1) then
						ship:addCrew(tonumber(amount or 1), CrewMan(profession_ent, adj_rank, adj_level))
						return true, string.format("%ix Level %i %s added.", tonumber(amount or 1), adj_level, professions[profession_id])
					else
						return false, "ERROR: " .. amount .. " not a valid bnumber"
					end
				else
					return false, "ERROR: " .. rank .. " is invalid rank"
				end
			else
				return false, "ERROR: " .. profession .. " not recognized profession"
			end
		else
			return false, ("ERROR: not enough arguments")
		end
	end
end
