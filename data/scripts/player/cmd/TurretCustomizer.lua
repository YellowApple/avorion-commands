--[[----------------------------------------------------------------------------
AVORION: Turret Modding Command: /tmod
darkconsole <darkcee.legit@gmail.com>

This script handles applying and updating the weapons bay on the players ship.
----------------------------------------------------------------------------]]--

local TurretCreator = {}

package.path = package.path
.. ";data/scripts/lib/?.lua"
.. ";data/scripts/sector/?.lua"
.. ";data/scripts/?.lua"

include("utility")
include("callable")

function initialize(Command,...)

	-- house clean both sides of the isle.
	local ScriptFile = "interface/TurretCreationInterface"
	local PlayerRef = Player()
	local Ship = Entity(Player().craftIndex)

	-- but from here on, do server side authority.

	if onServer() then
		Ship:removeScript(ScriptFile)

		Ship:addScript(ScriptFile)
		terminate()
		return
	end
end

function TurretCreator:WeDoneHereAndThere(Title,Text)
	print("potato")
	if(onServer())
	then
		invokeClientFunction(Player(),"WeDoneHereAndThere",Title,Text)
		terminate()
		return
	end

	print("hai")
	displayMissionAccomplishedText(Title,Text)
	terminate()
	return
end

callable(TurretCreator,"WeDoneHereAndThere")
