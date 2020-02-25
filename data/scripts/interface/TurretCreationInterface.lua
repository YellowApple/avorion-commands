--[[----------------------------------------------------------------------------

The structure of this interface module was reverse engineered from the
Turret Engineering Mod by:

- darkconsole <darkcee.legit@gmail.com>

Certain sections remain as-is due to a lack of understanding as to their purpose
or just the general efficiency of the code.
----------------------------------------------------------------------------]]--

package.path = package.path.. ";data/scripts/interface/?.lua"

local Win = include("TurretCreationUI")
local UILib = include("TurretCreationUILib")

-- these are methods that the ui access of the game needs.

function interactionPossible(Player)
	return true, ""
end

function getIcon(Seed, Rarity)

	return "Textures/TurretCreationIcon.png"
end

--------------------------------------------------------------------------------

function onCloseWindow()
	-- on window close, do nothing. want to keep data for re-opening.
	-- on logging out, can wipe data, because then you don't care
	--
	-- Hide all fields when closing window for safety, since not directly tied to window
	UpdateHideFields(Win)
	return
end

function onShowWindow()
	-- on window open, the only changes that should populate are inventory changes.
	-- Thus, only populate the inventory section of the screen.
	-- 
	-- However, on closing window, we hide all UI elements, so need to show them again
	local CurrentItem = GetCurrentItem(Win)
	local NewCurrentIndex = nil
	if CurrentItem then
		NewCurrentIndex = CurrentItem.uvalue
	end
	Win:PopulateInventory(NewCurrentIndex)

	CopyModdedParameters(Win)
	UpdateMutexBeamHeat(Win)
	UpdateShowFields(Win)
	return
end

--------------------------------------------------------------------------------

function initialize()
-- script bootstrapping.

	print("TurretCreation:initalize")

	-- script added, game loaded: executes both server and client.
	-- jump to new sector: executes on the client only and the locals
	-- get dumped...

	-- used to need this for config. has been removed since unnecessary

	return
end

function initUI()
	-- ui bootstrapping.

	if(onServer()) then return end

	Win:OnInit()
	return
end


