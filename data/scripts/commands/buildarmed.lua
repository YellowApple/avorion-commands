
function execute(PlayerID, Command, Action, ...)

	if(not onServer()) then
		print("OOGABOOGA")
		return
	end

	Player(PlayerID)
	:removeScript("cmd/TurretCustomizer")

	Player(PlayerID)
	:addScript("cmd/TurretCustomizer",Action,...)

	return 0, "", ""
end

