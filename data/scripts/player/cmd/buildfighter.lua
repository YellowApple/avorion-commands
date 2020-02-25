package.path = package.path .. ";data/scripts/lib/?.lua"

function initialize(...)
	local flag, msg = false, ""

	player = Player()

	flag, msg = buildFighter(player, ...)

	player:sendChatMessage("Fighter", 0, msg)
	terminate()
end

function buildFighter(player, squad, amount)
	local number = tonumber(amount)
	local ship = Entity(player.craftIndex)

	-- check if the ship has a hangar
	if not ship:hasComponent(ComponentType.Hangar) then
		return false, "Ship must have a hangar"
	end	

	local hangar = Hangar(ship.index);

	local squad_bp = hangar:getBlueprint(squad)
	-- check if the squad has a blueprint
	if squad_bp==nil then 
		return false, string.format("No blueprint found for squad at index %d", squad)
	end

	local req_space = squad_bp.volume*number

	-- check if there is enough space in ship
	if hangar.freeSpace < req_space then
		return false, string.format("You don't have enough space in your hangar: %f available, %f required.", hangar.freeSpace, req_space)
	end

	--check if there's enough space in the squad
	if hangar:getSquadFreeSlots(squad) < number then
		return false, string.format("Not enough free slots in squad: %d free slots, %d required.",hangar:getSquadFreeSlots(squad),number)
	end

	for i = 1,number do
		hangar:addFighter(squad, squad_bp)
	end

	return true, string.format("%d fighters added to squad %s", number, hangar:getSquadName(squad))
end