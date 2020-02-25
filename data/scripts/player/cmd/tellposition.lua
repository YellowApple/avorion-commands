if onServer() then

function initialize(requestingPlayerIndex)
	local requestor = Player(requestingPlayerIndex)

	if requestor then
		local lx, ly = Sector():getCoordinates()
		me = Player()
		requestor:sendChatMessage(me.name, 0, "My current location is \\s(%i:%i).", lx, ly)
	end
	terminate()
end

end

