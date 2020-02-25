--[[----------------------------------------------------------------------------

The structure of this interface module was reverse engineered from the
Turret Engineering Mod by:

- darkconsole <darkcee.legit@gmail.com>

Certain sections remain as-is due to a lack of understanding as to their purpose
or just the general efficiency of the code.
----------------------------------------------------------------------------]]--

local UILib = {
	UIArmedMapping = nil,
	UIUnarmedMapping = nil,
	UIMutexGroups = nil,
	UIGroupMembers = nil,
	UIConstructorArgs = nil
}

package.path = package.path .. ";data/scripts/lib/?.lua"

include ("randomext")
include("tableutility")

TurretGenerator = include("turretgenerator")
local TurretLib = include("TurretLib")
local WriteTable = TurretLib.WriteParametersTable
local ReadTable = TurretLib.ReadParametersTable
local MetaTable = TurretLib.MetaParametersTable
local ConversionTable = TurretLib.ParameterConversionTable

------------------------- Debug Print Utility Funcs ----------------------------
	function PrintServer(TheMessage)
	-- only print this message on the server.

		if(onServer()) then
			print("[TurretCustomizer] " .. TheMessage)
		end

		return
	end

	function PrintDebug(TheMessage)
	-- show debugging messages in the console.

		if (Debug) then
			print("[TurretCustomizer] " .. TheMessage)
		end

		return
	end

	function PrintError(TheMessage)
	-- show error messages to the user.
		displayChatMessage(TheMessage,"TurretCustomizer",1)
		return
	end

	function PrintInfo(TheMessage)
	-- show info messages to the user.
		displayChatMessage(TheMessage,"TurretCustomizer",3)
		return
	end

	function PrintWarning(TheMessage)
	-- show info messages to the user.
		displayChatMessage(TheMessage,"TurretCustomizer",2)
		return
	end

	function PrintFrameRect(Frame)
		local rect = Frame.rect
		return PrintRect(rect)
	end

	function PrintRect(rect)
		print('(' .. tostring(rect.topLeft.x) .. ',' .. tostring(rect.topLeft.y)
				.. ') ==> ' .. "(" .. tostring(rect.bottomRight.x) .. ','
				.. tostring(rect.bottomRight.y) .. ')')
		return
	end

------------------------- Generic UI Utility Func-------------------------------
	function FramedRect(Container,X,Y,Cols,Rows,Padding)
	-- for this trained rekt. give it a container you want to grid things out into
	-- the column,row you are trying to put the thing in, how many columns and rows
	-- there should be, and optionally padding. get a rect that will work sometimes.

		if(Padding == nil)
		then Padding = 4 end

		local TopLeft = vec2(
			(Container.rect.topLeft.x + ((Container.rect.width / Cols) * (X - 1))) + Padding,
			(Container.rect.topLeft.y + ((Container.rect.height / Rows) * (Y - 1))) + Padding
		)

		local BottomRight = vec2(
			(TopLeft.x + (Container.rect.width / Cols)) - (Padding*2),
			(TopLeft.y + (Container.rect.height / Rows)) - (Padding*2)
		)

		return Rect(TopLeft,BottomRight)
	end

	function RectFramedRect(Rect,X,Y,Cols,Rows,Padding)
	-- for this trained rekt. give it a container you want to grid things out into
	-- the column,row you are trying to put the thing in, how many columns and rows
	-- there should be, and optionally padding. get a rect that will work sometimes.

		if(Padding == nil)
		then Padding = 4 end

		local TopLeft = vec2(
			(Rect.topLeft.x + ((Rect.width / Cols) * (X - 1))) + Padding,
			(Rect.topLeft.y + ((Rect.height / Rows) * (Y - 1))) + Padding
		)

		local BottomRight = vec2(
			(TopLeft.x + (Rect.width / Cols)) - (Padding*2),
			(TopLeft.y + (Rect.height / Rows)) - (Padding*2)
		)

		return Rect(TopLeft,BottomRight)
	end

	function MaxSquareRect(Bad_Rect)
	-- Given a rectangular Rect, finds the Maximum square rect that fits within this
	-- rectangular Rect
		local topLeft = Bad_Rect.topLeft
		local width = Bad_Rect.width
		local height = Bad_Rect.height
		local new_TopLeft = Bad_Rect.topLeft
		local new_BottomRight = Bad_Rect.bottomRight
		local deltax = 0
		local deltay = 0
		if width <= height then
			deltay = (height - width)/2
		else
			deltax = (width - height)/2
		end
		new_TopLeft.x = new_TopLeft.x + deltax
		new_TopLeft.y = new_TopLeft.y + deltay
		new_BottomRight.x = new_BottomRight.x - deltax
		new_BottomRight.y = new_BottomRight.y - deltay
		return Rect(new_TopLeft, new_BottomRight)
	end

	function centerNumber(number, digits)
		local str = tostring(number)
		local strlen = string.len(str)

		if (strlen % 2) ~= (digits % 2) then
			str = " " .. str
			strlen = strlen + 1
		end

		local prefix = ""
		local iters = (digits - strlen) / 2
		for i=1,iters do
			prefix = prefix .. " "
		end

		return prefix .. str .. prefix
	end

------------------------ Fetch Data UI Utility Funcs ---------------------------
	function GetCurrentItemIndex(Win)
	-- get the index of the real item that this mock item is pointing to. this
	-- returns the value we stored in the uvalue property.

		local Item = Win.Item:getItem(ivec2(0,0))

		if(Item == nil)
		then return nil end

		return Item.uvalue
	end

	function GetCurrentItemCount(Win)
	-- get the amount in the stack we are currently editing.

		return Win.Item:getItem(ivec2(0,0)).amount
	end

	function GetCurrentItemReal(Win)
	-- get the actual turret we are editing.

		return Player():getInventory():find(
			Win:GetCurrentItemIndex()
		)
	end

	function GetCurrentItem(Win)
	-- get the mock turret we are editing.

		return Win.Item:getItem(ivec2(0,0))
	end

	function GetCurrentItems(Win)
	-- get the currently selected item and the real item it is a mock for.
		return Win:GetCurrentItem(), Win:GetCurrentItemReal()
	end

	function GetCurrentBinItemIndex(Win)
	-- get the index of the real item that this mock item is pointing to. this
	-- returns the value we stored in the uvalue property.
		local Item = Win.Bin:getItem(ivec2(0,0))

		if(Item == nil)
		then return nil end

		return Item.uvalue
	end

	function GetCurrentBinItemCount(Win)
	-- get the amount in the stack we are currently editing.
		return Win.Bin:getItem(ivec2(0,0)).amount
	end

	function GetCurrentBinItemReal(Win)
	-- get the actual turret we are editing.
		return Player():getInventory():find(
			Win:GetCurrentBinItemIndex()
		)
	end

	function GetCurrentBinItem(Win)
	-- get the mock turret we are editing.
		return Win.Bin:getItem(ivec2(0,0))
	end

	function GetCurrentBinItems(Win)
	-- get the currently selected item and the real item it is a mock for.
		return Win:GetCurrentBinItem(), Win:GetCurrentBinItemReal()
	end

----------------------- Update UI Utility Funcs --------------------------------
	function UpdateShowFields(Win)
	-- Update which fields are shown in the window
	-- Only expect to be called in these cases:
	--    - on init (through UpdateFields)
	--    - When take item to inventory, now empty bin (2 cases)
	--    - When add something to item, now full bin (1 case)
	-- Copies over all parameters to mod window as well

		-- always show 
		Win.Inv:show()
		Win.Item:show()
		Win.Bin:show()

		-- Amount stuff
		Win.ItemAmountLabel:show()

		Win.BinAmountLabel:show()
		Win.BinAmountTextLabel:show()
		Win.BtnBinAmountPlus:show()
		Win.BtnBinAmountMinus:show()

		-- Prefab template stuff
		Win.BtnMaterialPlus:show()
		Win.BtnMaterialMinus:show()
		Win.MaterialLabel:show()

		Win.BtnRarityPlus:show()
		Win.BtnRarityMinus:show()
		Win.RarityLabel:show()

		Win.BtnTechPlus:show()
		Win.BtnTechMinus:show()
		Win.TechLabel:show()
		Win.TechAmountLabel:show()

		Win.BtnRerollTemplates:show()
		Win.BtnClearMods:show()
		Win.BtnApplyMods:show()

		-- In-depth modifications stuff
		ShowProperMods(Win)

		return
	end

	function UpdateMutexBeamHeat(Win)
	-- Update what the proper mutex is to determine what is and isn't shown
	-- Always have proper Proj/Beam to what's in the bin
	--    But, Heat/energy can and should be changeable
		local MutexBeam = "NoBeamProj"
		local MutexHeat = "NoHeatEnergy"
		local TempItem = GetCurrentBinItem(Win)

		-- If have item in bin, then we have stats being shown
		if TempItem then
			-- do proj/beam first
			local TurretItem = TempItem.item
			local weapons = {TurretItem:getWeapons()}

			for _,weapon in pairs(weapons) do
				if weapon.isProjectile then
					MutexBeam = "Proj"
				else
					MutexBeam = "Beam"
				end
				break
			end

			local modname = "coolingtype"
			if Win.ComboEnumMapping["indexmap"][modname][Win.ModsUIElems[modname]['combobox'].selectedIndex] == CoolingType.Standard then
				MutexHeat = "Heat"
				Win.ModsUIElems["cooling"]["label"].caption = "Cooling/sec"
				Win.ModsUIElems["shotheat"]["label"].caption = "Heat/shot"
				Win.ModsUIElems["maxheat"]["label"].caption = "Maximum Heat"
			else
				if MutexBeam == "Proj" then
					MutexHeat = "ShotEnergy"
					Win.ModsUIElems["cooling"]["label"].caption = "Charge/sec"
					Win.ModsUIElems["shotheat"]["label"].caption = "Energy/shot"
					Win.ModsUIElems["maxheat"]["label"].caption = "Maximum Energy"
				else
					MutexHeat = "ContinuousEnergy"
					Win.ModsUIElems["cooling"]["label"].caption = "Charge/sec"
					Win.ModsUIElems["shotheat"]["label"].caption = "Energy/tick"
					Win.ModsUIElems["maxheat"]["label"].caption = "Maximum Energy"
				end
			end
		end

		Win.MutexBeam = MutexBeam
		Win.MutexHeat = MutexHeat
	end

	function UpdateHideFields(Win)
	-- Hide all fields

		-- always on
		Win.Inv:hide()
		Win.Item:hide()
		Win.Bin:hide()

		-- Amount stuff
		Win.ItemAmountLabel:hide()

		Win.BinAmountLabel:hide()
		Win.BinAmountTextLabel:hide()
		Win.BtnBinAmountPlus:hide()
		Win.BtnBinAmountMinus:hide()

		-- Prefab template stuff
		Win.BtnMaterialPlus:hide()
		Win.BtnMaterialMinus:hide()
		Win.MaterialLabel:hide()

		Win.BtnRarityPlus:hide()
		Win.BtnRarityMinus:hide()
		Win.RarityLabel:hide()

		Win.BtnTechPlus:hide()
		Win.BtnTechMinus:hide()
		Win.TechLabel:hide()
		Win.TechAmountLabel:hide()

		Win.BtnRerollTemplates:hide()

		-- In-depth modifications stuff
		HideAllMods(Win)
		Win.BtnClearMods:hide()
		Win.BtnApplyMods:hide()
		return
	end

	function ShowProperMods(Win)
		if Win.ModsUIElems then
			for modname,modUIElems in pairs(Win.ModsUIElems) do
				local res,_ = try_catch_table(UILib.UIGroupMembers, modname)
				local toshow = false
				if res then
					if try_catch_table(res, Win.MutexBeam) or try_catch_table(res, Win.MutexHeat) then
						toshow = true
					end
				else
					toshow = true
				end
				for _,UIElem in pairs(modUIElems) do
					if toshow then
						UIElem:show()
					else
						UIElem:hide()
					end
				end
			end
		end
	end

	function HideAllMods(Win)
		if Win.ModsUIElems then
			for modname,modUIElems in pairs(Win.ModsUIElems) do
				for _,UIElem in pairs(modUIElems) do
					UIElem:hide()
				end
			end
		end
	end

	-- helper for copying parameters
	function CopyParameters(Win, TempItem)
		-- If have item in bin, then we have stats being shown
		if TempItem then
			local TurretItem = TempItem.item
			local weapons = {TurretItem:getWeapons()}
			local weapon = nil

			for _,weap in pairs(weapons) do
				weapon = weap
				break
			end

			-- do the reading of the data
			for modname, scope in pairs(MetaTable) do
				-- TurretLib is common to both armed and unarmed, so want to check if param exists here
				local in_scope,_ = try_catch_table(Win.ModsUIElems, modname)
				if in_scope then
					if modname ~= "template" then
						local data = nil
						if scope == "Turret" then
							data = ReadTable[scope][modname](TurretItem)
						else
							data = ReadTable[scope][modname](weapon)
						end

						-- if data parsing function is provided, use it. else, data goes to waste
						local converter,err = try_catch_table(ConversionTable, modname)
						if converter then -- if we have a special case, then use the provided function to convert to Win format
							converter(Win, modname, data)
						end
					end
				end
			end
		else -- else, reset all to default values
			for modname, converter in pairs(ConversionTable) do
				local in_scope,_ = try_catch_table(Win.ModsUIElems, modname)
				if in_scope then
					converter(Win, modname, nil)
				end
			end
		end
	end

	-- Copy over all parameters. only exclusionary case: "template"
	function CopyModdedParameters(Win)
		local TempItem = GetCurrentItem(Win)
		CopyParameters(Win, TempItem)
		return
	end

	-- Copy over all parameters, this time from the bin tho (to preserve progress)
	function CopyLastModdedParameters(Win)
		local TempItem = GetCurrentBinItem(Win)
		CopyParameters(Win, TempItem)
		return
	end

	-- Set the baseline on all of the text fields as background so you have something to work with
	--    - Expect this to only ever be called on new item in itemslot
	function CopyBaselineParameters(Win)
		local TempItem = GetCurrentItem(Win)

		-- If have item in bin, then we have stats being shown
		if TempItem then
			local TurretItem = TempItem.item
			local weapons = {TurretItem:getWeapons()}
			local weapon = nil

			for _,weap in pairs(weapons) do
				weapon = weap
				break
			end

			-- do the reading of the data
			for modname, scope in pairs(MetaTable) do
				-- TurretLib is common to both armed and unarmed, so want to check if param exists here
				local UIElems,_ = try_catch_table(Win.ModsUIElems, modname)
				if UIElems then
					local textbox,_ = try_catch_table(UIElems, "textbox")
					if textbox then
						local data = nil
						if scope == "Turret" then
							data = ReadTable[scope][modname](TurretItem)
						else
							data = ReadTable[scope][modname](weapon)
						end

						textbox.backgroundText = tostring(data)
					end
				end
			end
		end
		return
	end

	-- Clear the baseline on all of the text fields so you have less data corruption
	--    - Expect this to only ever be when moved item to inventory
	function ClearBaselineParameters(Win)
		-- do the iteration
		for modname, scope in pairs(MetaTable) do
			-- TurretLib is common to both armed and unarmed, so want to check if param exists here
			local UIElems,_ = try_catch_table(Win.ModsUIElems, modname)
			if UIElems then
				local textbox,_ = try_catch_table(UIElems, "textbox")
				if textbox then
					textbox.backgroundText = tostring("")
				end
			end
		end
		return
	end

-------------------- Armed UI Modification Mappings ----------------------------
	-- Armed locations
		local ArmedMap = {}

		-- Column 1
		ArmedMap["color"] = ivec3(1,1,2)
		ArmedMap["automatic"] = ivec3(1,3,1)
		ArmedMap["coaxial"] = ivec3(1,4,1)
		ArmedMap["simultaneous"] = ivec3(1,5,1)
		ArmedMap["template"] = ivec3(1,6,1)
	
		ArmedMap["beamshape"] = ivec3(1,8,1)
		ArmedMap["projshape"] = ivec3(1,8,1)

		ArmedMap["beam"] = ivec3(1,7,1)
		ArmedMap["continuous"] = ivec3(1,9,1)
		ArmedMap["beamscale"] = ivec3(1,10,1)
	
		ArmedMap["NotBeam"] = vec3(1,5,2)
		ArmedMap["NotBeamProj"] = vec3(1,10/4,4)

		-- Column 2
		ArmedMap["projectile"] = ivec3(2,1,1)
		ArmedMap["projectilevelocity"] = ivec3(2,2,1)
		ArmedMap["recoil"] = ivec3(2,3,1)
		ArmedMap["impactexplosion"] = ivec3(2,4,1)
		ArmedMap["projectilelife"] = ivec3(2,5,1)
		ArmedMap["timeddeath"] = ivec3(2,6,1)
		ArmedMap["deathexplosion"] = ivec3(2,7,1)
		ArmedMap["projectilesize"] = ivec3(2,8,1)
		ArmedMap["seeker"] = ivec3(2,9,1)
		ArmedMap["explosionradius"] = ivec3(2,10,1)

		ArmedMap["NotProj"] = ivec3(2,1,10)
		ArmedMap["NotProjBeam"] = ivec3(2,1,10)

		-- Column 3
		ArmedMap["crew"] = ivec3(3,1,1)
		ArmedMap["turretsize"] = ivec3(3,2,1)
		ArmedMap["slots"] = ivec3(3,3,1)
		ArmedMap["barrels"] = ivec3(3,4,1)
		ArmedMap["blockpenetration"] = ivec3(3,5,1)
		ArmedMap["shots"] = ivec3(3,6,1)

		ArmedMap["coolingtype"] = ivec3(3,7,1)
		ArmedMap["baseenergy"] = ivec3(3,8,1)
		ArmedMap["energyincrease"] = ivec3(3,9,1)

		ArmedMap["cooling"] = ivec3(3,8,1)
		ArmedMap["shotheat"] = ivec3(3,9,1)
		ArmedMap["maxheat"] = ivec3(3,10,1)

		ArmedMap["NotHeatEnergy"] = vec3(3,10/3,3)

		-- Absolute_Arguments
		ArmedMap["accuracy"] = ivec3(4,1,1)
		ArmedMap["damage"] = ivec3(4,2,1)
		ArmedMap["range"] = ivec3(4,3,1)
		ArmedMap["firerate"] = ivec3(4,4,1)
		ArmedMap["rotation"] = ivec3(4,5,1)
		ArmedMap["damagetype"] = ivec3(4,6,1)
		ArmedMap["hulldamage"] = ivec3(4,7,1)
		ArmedMap["shielddamage"] = ivec3(4,8,1)
		ArmedMap["stonedamage"] = ivec3(4,9,1)
		ArmedMap["shieldpenetration"] = ivec3(4,10,1)

		UILib.UIArmedMapping = ArmedMap
-------------------------- UI Mutex Mappings -----------------------------------
	-- Mutex Locations
		local MutexGroups = {}
		MutexGroups["Proj"] = {}
		MutexGroups["Beam"] = {}
		MutexGroups["Heat"] = {}
		MutexGroups["Energy"] = {}
		MutexGroups["NoBeamProj"] = {}
		MutexGroups["NoHeatEnergy"] = {}

		MutexGroups["Proj"]["Beam"] = 1
		MutexGroups["Beam"]["Proj"] = 1
		MutexGroups["Heat"]["Energy"] = 1
		MutexGroups["Energy"]["Heat"] = 1
		MutexGroups["NoBeamProj"]["Beam"] = 1
		MutexGroups["NoHeatEnergy"]["Heat"] = 1

		MutexGroups["Proj"]["NoBeamProj"] = 1
		MutexGroups["Beam"]["NoBeamProj"] = 1
		MutexGroups["Heat"]["NoHeatEnergy"] = 1
		MutexGroups["Energy"]["NoHeatEnergy"] = 1
		MutexGroups["NoBeamProj"]["Proj"] = 1
		MutexGroups["NoHeatEnergy"]["Energy"] = 1

		UILib.UIMutexGroups = MutexGroups

	-- Group Members (for use with Mutex)
		local GroupMembers = {}
		GroupMembers["projectile"] = {Proj=1}
		GroupMembers["projectilevelocity"] = {Proj=1}
		GroupMembers["recoil"] = {Proj=1}
		GroupMembers["impactexplosion"] = {Proj=1}
		GroupMembers["projectilelife"] = {Proj=1}
		GroupMembers["timeddeath"] = {Proj=1}
		GroupMembers["deathexplosion"] = {Proj=1}
		GroupMembers["projectilesize"] = {Proj=1}
		GroupMembers["seeker"] = {Proj=1}
		GroupMembers["explosionradius"] = {Proj=1}

		GroupMembers["beamshape"] = {Beam=1}
		GroupMembers["projshape"] = {Proj=1}

		GroupMembers["beam"] = {Beam=1}
		GroupMembers["continuous"] = {Beam=1}
		GroupMembers["beamscale"] = {Beam=1}

		-- So apparently these vars have been deprecated
		-- keeping then under Energy, because HeatMutex never changes to Energy
		GroupMembers["baseenergy"] = {NO_MATCH=1}
		GroupMembers["energyincrease"] = {NO_MATCH=1}

		GroupMembers["cooling"] = {Heat=1,ShotEnergy=1,ContinuousEnergy=1}
		GroupMembers["shotheat"] = {Heat=1,ShotEnergy=1,ContinuousEnergy=1}
		GroupMembers["maxheat"] = {Heat=1,ShotEnergy=1,ContinuousEnergy=1}

		GroupMembers["NotProj"] = {Beam=1}
		GroupMembers["NotBeam"] = {Proj=1}
		GroupMembers["NotBeamProj"] = {NoBeamProj=1}
		GroupMembers["NotProjBeam"] = {NoBeamProj=1}

		GroupMembers["NotHeatEnergy"] = {NoHeatEnergy=1}

		UILib.UIGroupMembers = GroupMembers

--------------------------- UI Constructor Funcs -------------------------------
	-- label stuffs
	local FontSize1 = 20
	local FontSize2 = 14
	local FontSize3 = 12
	local LineHeight1 = FontSize1 + 4

	-- Special constructor for the color field
	function colorConstructor(Rect, modname, labelText, labelRatio, tooltip, Win)
		-- common initialization
		local UIElem = {}
		local frame = Win.Window:createFrame(Rect)

		local textLabel = Win.Window:createLabel(
			Rect(),
			labelText,
			FontSize1
		)
		textLabel.rect = FramedRect(frame, 1, 1, 1, 1/labelRatio)
		textLabel.centered = true
		textLabel:setCenterAligned()

		local HSlider = Win.Window:createSlider(
			Rect(),
			0, 360, 18,
			"", "HandleColorSlider"
		)
		HSlider.showValue = false
		HSlider.rect = FramedRect(frame, 1, 1/labelRatio, 3, 1/labelRatio)

		local SSlider = Win.Window:createSlider(
			Rect(),
			0, 1, 10,
			"", "HandleColorSlider"
		)
		SSlider.showValue = false
		SSlider.rect = FramedRect(frame, 2, 1/labelRatio, 3, 1/labelRatio)

		local VSlider = Win.Window:createSlider(
			Rect(),
			0, 1, 10,
			"", "HandleColorSlider"
		)
		VSlider.showValue = false
		VSlider.rect = FramedRect(frame, 3, 1/labelRatio, 3, 1/labelRatio)

		UIElem["label"] = textLabel
		UIElem["frame"] = frame
		UIElem["hueslider"] = HSlider
		UIElem["satslider"] = SSlider
		UIElem["valslider"] = VSlider

		Win.ModsUIElems[modname] = UIElem
		return
	end

	white = ColorRGB(1.00, 1.00, 1.00)
	-- constructor for dropdown menus
	function comboboxConstructor(Rect, modname, labelText, labelRatio, tooltip, Win)
		-- common initialization
		local UIElem = {}
		local frame = Win.Window:createFrame(Rect)

		local textLabel = Win.Window:createLabel(
			Rect(),
			labelText,
			FontSize1
		)
		textLabel.rect = FramedRect(frame, 1, 1, 1/labelRatio, 1)
		textLabel.centered = true
		textLabel:setLeftAligned()

		local combobox = Win.Window:createComboBox(
			FramedRect(frame, 1/labelRatio, 1, 1/labelRatio, 1),
			"HandleComboBox"
		)
		combobox.rect = FramedRect(frame, 1/labelRatio, 1, 1/labelRatio, 1)
		combobox.clampTextAtArrow = false
		Win.ModsComboBoxMapping[combobox.index] = combobox

		combobox:addEntry("", white)
		ind = 1
		for id,str in pairs(Win.ComboEnumMapping[modname]) do
			combobox:addEntry(str, white)
			Win.ComboEnumMapping['indexmap'][modname][ind] = id
			ind = ind + 1
		end

		UIElem["label"] = textLabel
		UIElem["frame"] = frame
		UIElem['combobox'] = combobox

		Win.ModsUIElems[modname] = UIElem
		return
	end

	-- constructor for boolean fields
	function checkboxConstructor(Rect, modname, labelText, labelRatio, tooltip, Win)
		-- common initialization
		local UIElem = {}
		local frame = Win.Window:createFrame(Rect)

		local textLabel = Win.Window:createLabel(
			Rect(),
			labelText,
			FontSize1
		)
		textLabel.rect = FramedRect(frame, 1, 1, 1/labelRatio, 1)
		textLabel.centered = true
		textLabel:setLeftAligned()

		local checkbox = Win.Window:createCheckBox(
			MaxSquareRect(FramedRect(frame, 1/labelRatio, 1, 1/labelRatio, 1)),
			"",
			"HandleCheckBox"
		)
		checkbox.rect = MaxSquareRect(FramedRect(frame, 1/labelRatio, 1, 1/labelRatio, 1))
		checkbox.size = vec2(checkbox.rect.height, checkbox.rect.width)
		Win.ModsCheckBoxMapping[checkbox.index] = checkbox

		UIElem["label"] = textLabel
		UIElem["frame"] = frame
		UIElem["checkbox"] = checkbox

		Win.ModsUIElems[modname] = UIElem
		return
	end

	-- constructor for input value fields
	function textboxConstructor(Rect, modname, labelText, labelRatio, tooltip, Win)
		-- common initialization
		local UIElem = {}
		local frame = Win.Window:createFrame(Rect)

		local textLabel = Win.Window:createLabel(
			Rect(),
			labelText,
			FontSize1
		)
		textLabel.rect = FramedRect(frame, 1, 1, 1/labelRatio, 1)
		textLabel.centered = true
		textLabel:setLeftAligned()

		local textbox = Win.Window:createTextBox(
			Rect(),
			"HandleTextBox"
		)
		textbox.rect = FramedRect(frame, 1/labelRatio, 1, 1/labelRatio, 1)
		textbox.clearOnClick = true
		textbox.editable = true
		textbox:forbidInvalidFilenameChars()
		Win.ModsTextBoxMapping[textbox.index] = textbox

		UIElem["label"] = textLabel
		UIElem["frame"] = frame
		UIElem["textbox"] = textbox

		Win.ModsUIElems[modname] = UIElem
		return
	end

	-- constructor for plus/minus fields
	function plusminusConstructor(Rect, modname, labelText, labelRatio, tooltip, Win)
		-- common initialization
		local UIElem = {}
		local frame = Win.Window:createFrame(Rect)

		local plusButton = Win.Window:createButton(
			Rect(),
			"+",
			"HandlePlusButton"
		)
		plusButton.textSize = FontSize2
		plusButton.rect = MaxSquareRect(FramedRect(frame, 4/(1-labelRatio) - 3, 1, 4/(1-labelRatio), 1))
		Win.ModsButtonMapping[plusButton.index] = modname

		local minusButton = Win.Window:createButton(
			Rect(),
			"-",
			"HandleMinusButton"
		)
		minusButton.textSize = FontSize2
		minusButton.rect = MaxSquareRect(FramedRect(frame, 4/(1-labelRatio), 1, 4/(1-labelRatio), 1))
		Win.ModsButtonMapping[minusButton.index] = modname

		local varLabel = Win.Window:createLabel(
			Rect(),
			"----",
			FontSize1
		)
		varLabel.rect = FramedRect(frame, 2/(1-labelRatio)-0.5, 1, 2/(1-labelRatio), 1)
		varLabel.centered = true
		varLabel:setCenterAligned()

		local textLabel = Win.Window:createLabel(
			Rect(),
			labelText,
			FontSize1
		)
		textLabel.rect = FramedRect(frame, 1, 1, 1/labelRatio, 1)
		textLabel.centered = true
		textLabel:setLeftAligned()

		UIElem["label"] = textLabel
		UIElem["var"] = varLabel
		UIElem["minus"] = plusButton
		UIElem["plus"] = minusButton
		UIElem["frame"] = frame

		Win.ModsUIElems[modname] = UIElem
		return
	end

	-- constructor for mutex replacements: just a label over the rect
	function labelConstructor(Rect, modname, labelText, labelRatio, tooltip, Win)
		-- common initialization
		local UIElem = {}
		local frame = Win.Window:createFrame(Rect)
		Win.ModsFrameMapping[modname] = frame

		local textLabel = Win.Window:createLabel(
			Rect,
			labelText,
			FontSize1
		)
		textLabel.centered = true
		textLabel:setCenterAligned()

		UIElem["label"] = textLabel
		UIElem["frame"] = frame

		Win.ModsUIElems[modname] = UIElem
		return
	end

	-- Overall constructor
	function BuildModificationParametersUI(Win)
		-- Initialize relevant parameters
		Win.ModsUIElems = {}
		Win.ModsButtonMapping = {}
		Win.ModsTextBoxMapping = {}
		Win.ModsCheckBoxMapping = {}
		Win.ModsComboBoxMapping = {}
		Win.ModsFrameMapping = {}

		Win.ComboEnumMapping = {}
		-- Populate Enum Mappings
			Win.ComboEnumMapping["indexmap"] = {}
			Win.ComboEnumMapping["damagetype"] = {}
			Win.ComboEnumMapping["coolingtype"] = {}
			Win.ComboEnumMapping["beamshape"] = {}
			Win.ComboEnumMapping["projshape"] = {}
			Win.ComboEnumMapping["indexmap"]["damagetype"] = {}
			Win.ComboEnumMapping["indexmap"]["coolingtype"] = {}
			Win.ComboEnumMapping["indexmap"]["beamshape"] = {}
			Win.ComboEnumMapping["indexmap"]["projshape"] = {}

			Win.ComboEnumMapping["coolingtype"][0] = "Standard"
			Win.ComboEnumMapping["coolingtype"][1] = "EnergyPerShot"
			Win.ComboEnumMapping["coolingtype"][2] = "EnergyContinuous"
			Win.ComboEnumMapping["coolingtype"][3] = "BatteryCharge"

			Win.ComboEnumMapping["damagetype"][-1] = "Invalid"
			Win.ComboEnumMapping["damagetype"][0] = "Physical"
			Win.ComboEnumMapping["damagetype"][1] = "Energy"
			Win.ComboEnumMapping["damagetype"][2] = "Collision"
			Win.ComboEnumMapping["damagetype"][3] = "Decay"
			Win.ComboEnumMapping["damagetype"][4] = "Arbitrary"
			Win.ComboEnumMapping["damagetype"][5] = "Fragments"
			Win.ComboEnumMapping["damagetype"][6] = "Torpedo"

			Win.ComboEnumMapping["projshape"][0] = "Default"
			Win.ComboEnumMapping["projshape"][1] = "Plasma"
			Win.ComboEnumMapping["projshape"][2] = "Rocket"

			Win.ComboEnumMapping["beamshape"][0] = "None"
			Win.ComboEnumMapping["beamshape"][1] = "Straight"
			Win.ComboEnumMapping["beamshape"][2] = "Lightning"
			Win.ComboEnumMapping["beamshape"][3] = "Swirly"

		-- Pull the associated params
		for modname, mapvec in pairs(UILib.UIArmedMapping) do
			-- print(modname .. ": " .. tostring(mapvec.x) .. "," .. tostring(mapvec.y) .. "," .. tostring(mapvec.z))
			local cons_args = UILib.UIConstructorArgs[modname]
			local constructor = cons_args['constructor']

			constructor(RectFramedRect(Win.ModsRect, mapvec.x, mapvec.y, 4, 10 / mapvec.z),
						modname, cons_args['labelText'], cons_args['labelRatio'],
						cons_args['tooltip'], Win)
		end

		-- Handle some special cases
		Win.ModsUIElems["beam"]["checkbox"].active = false
		Win.ModsUIElems["continuous"]["checkbox"].active = false
		Win.ModsUIElems["projectile"]["checkbox"].active = false

		return
	end

--------------------------- UI Constructor Args --------------------------------
	local ConstructorArgs = {}
	-- Column 1
	ConstructorArgs["color"] = {labelText="Colour HSV", labelRatio=0.5, Tooltip=nil, constructor=colorConstructor}
	ConstructorArgs["automatic"] = {labelText="Independent Targeting", labelRatio=0.5, Tooltip=nil, constructor=checkboxConstructor}
	ConstructorArgs["coaxial"] = {labelText="Coaxial", labelRatio=0.5, Tooltip=nil, constructor=checkboxConstructor}
	ConstructorArgs["simultaneous"] = {labelText="Synchronized Weapons", labelRatio=0.5, Tooltip=nil, constructor=checkboxConstructor}
	ConstructorArgs["template"] = {labelText="Template Design", labelRatio=0.5, Tooltip=nil, constructor=checkboxConstructor}
	ConstructorArgs["beamshape"] = {labelText="Beam Shape", labelRatio=0.5, Tooltip=nil, constructor=comboboxConstructor}
	ConstructorArgs["projshape"] = {labelText="Projectile Shape", labelRatio=0.5, Tooltip=nil, constructor=comboboxConstructor}

	ConstructorArgs["beam"] = {labelText="Beam", labelRatio=0.5, Tooltip=nil, constructor=checkboxConstructor}
	ConstructorArgs["continuous"] = {labelText="Continuous Beam", labelRatio=0.5, Tooltip=nil, constructor=checkboxConstructor}
	ConstructorArgs["beamscale"] = {labelText="Beam Size Scale %", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}

	ConstructorArgs["NotBeam"] = {labelText="Not a\nBeam Weapon", labelRatio=0.5, Tooltip=nil, constructor=labelConstructor}
	ConstructorArgs["NotBeamProj"] = {labelText="Stats unavailable\nwithout a weapon\nin the slot", labelRatio=0.5, Tooltip=nil, constructor=labelConstructor}

	-- Column 2
	ConstructorArgs["projectile"] = {labelText="Projectile", labelRatio=0.5, Tooltip=nil, constructor=checkboxConstructor}
	ConstructorArgs["projectilevelocity"] = {labelText="Projectile Velocity", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}
	ConstructorArgs["recoil"] = {labelText="Recoil", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}
	ConstructorArgs["impactexplosion"] = {labelText="Impact Explosion", labelRatio=0.5, Tooltip=nil, constructor=checkboxConstructor}
	ConstructorArgs["projectilelife"] = {labelText="Projectile Life", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}
	ConstructorArgs["timeddeath"] = {labelText="Timed Death", labelRatio=0.5, Tooltip=nil, constructor=checkboxConstructor}
	ConstructorArgs["deathexplosion"] = {labelText="Death Explosion", labelRatio=0.5, Tooltip=nil, constructor=checkboxConstructor}
	ConstructorArgs["projectilesize"] = {labelText="Projectile Size", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}
	ConstructorArgs["seeker"] = {labelText="Seeker Rounds", labelRatio=0.5, Tooltip=nil, constructor=checkboxConstructor}
	ConstructorArgs["explosionradius"] = {labelText="Explosion Radius", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}

	ConstructorArgs["NotProj"] = {labelText="Not a\nProjectile Weapon", labelRatio=0.5, Tooltip=nil, constructor=labelConstructor}
	ConstructorArgs["NotProjBeam"] = {labelText="Stats unavailable\nwithout a weapon\nin the slot", labelRatio=0.5, Tooltip=nil, constructor=labelConstructor}

	-- Column 3
	ConstructorArgs["crew"] = {labelText="Crew Needed", labelRatio=0.5, Tooltip=nil, constructor=plusminusConstructor}
	ConstructorArgs["turretsize"] = {labelText="Turret Size", labelRatio=0.5, Tooltip=nil, constructor=plusminusConstructor}
	ConstructorArgs["slots"] = {labelText="Turret Slots", labelRatio=0.5, Tooltip=nil, constructor=plusminusConstructor}
	ConstructorArgs["barrels"] = {labelText="Barrels", labelRatio=0.5, Tooltip=nil, constructor=plusminusConstructor}
	ConstructorArgs["blockpenetration"] = {labelText="Block Penetration", labelRatio=0.5, Tooltip=nil, constructor=plusminusConstructor}
	ConstructorArgs["shots"] = {labelText="Shots Fired", labelRatio=0.5, Tooltip=nil, constructor=plusminusConstructor}

	ConstructorArgs["coolingtype"] = {labelText="Cooling Type", labelRatio=0.5, Tooltip=nil, constructor=comboboxConstructor}
	ConstructorArgs["baseenergy"] = {labelText="Base Energy", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}
	ConstructorArgs["energyincrease"] = {labelText="Energy Increase", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}

	ConstructorArgs["cooling"] = {labelText="Cooling/sec", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}
	ConstructorArgs["shotheat"] = {labelText="Heat/shot", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}
	ConstructorArgs["maxheat"] = {labelText="Maximum Heat", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}

	ConstructorArgs["NotHeatEnergy"] = {labelText="Stats unavailable\nwithout a weapon\nin the slot", labelRatio=0.5, Tooltip=nil, constructor=labelConstructor}

	-- Absolute_Arguments
	ConstructorArgs["accuracy"] = {labelText="Accuracy %", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}
	ConstructorArgs["damage"] = {labelText="Damage", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}
	ConstructorArgs["range"] = {labelText="Range (10m)", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}
	ConstructorArgs["firerate"] = {labelText="Firerate", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}
	ConstructorArgs["rotation"] = {labelText="Rotation Speed", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}
	ConstructorArgs["damagetype"] = {labelText="Damage Type", labelRatio=0.5, Tooltip=nil, constructor=comboboxConstructor}
	ConstructorArgs["hulldamage"] = {labelText="Hull Damage %", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}
	ConstructorArgs["shielddamage"] = {labelText="Shield Damage %", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}
	ConstructorArgs["stonedamage"] = {labelText="Stone Damage %", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}
	ConstructorArgs["shieldpenetration"] = {labelText="Shield Penetration %", labelRatio=0.5, Tooltip=nil, constructor=textboxConstructor}

	TurretLib:GenerateTooltips(ConstructorArgs)
	UILib.UIConstructorArgs = ConstructorArgs

-------------------------- Apply All Valid Mods --------------------------------
function ApplyAllValidMods(Win)
	local TempItem = GetCurrentBinItem(Win)

		-- If have item in bin, then we have stats being shown
		if TempItem then
			local TurretItem = TempItem.item
			local weaponMods = {}
			local TemplateItem = TurretTemplate()

			-- Do stuff using a template for now
			-- generate turret template
			local rand = random()

			-- Do the applying of the stuffs
			if Win.ModsUIElems then
				-- loop through to collect data and apply turret args
				for modname,modUIElems in pairs(Win.ModsUIElems) do
					local res,_ = try_catch_table(UILib.UIGroupMembers, modname)
					local toconsider = false
					if res then
						if try_catch_table(res, Win.MutexBeam) or try_catch_table(res, Win.MutexHeat) then
							toconsider = true
						end
					else
						toconsider = true
					end
					
					local plusminus,_ = try_catch_table(modUIElems, 'var')
					local textbox,_ = try_catch_table(modUIElems, 'textbox')
					local checkbox,_ = try_catch_table(modUIElems, 'checkbox')
					local combobox,_ = try_catch_table(modUIElems, 'combobox')

					local hueslider,_ = try_catch_table(modUIElems, 'hueslider')
					local satslider,_ = try_catch_table(modUIElems, 'satslider')
					local valslider,_ = try_catch_table(modUIElems, 'valslider')

					local data = nil

					if toconsider then
						if plusminus then
							data = tonumber(plusminus.caption)

							-- since technically "barrels" is a turret arg, add it to weaponMods for later
							if modname == "barrels" then weaponMods[modname] = data end
						elseif textbox then
							data = tonumber(textbox.text)
						elseif checkbox then
							data = checkbox.checked
						elseif combobox then
							local indexmap = Win.ComboEnumMapping['indexmap'][modname] -- maps ind ==> id
							data = indexmap[Win.ModsUIElems[modname]['combobox'].selectedIndex]
						elseif hueslider then
							local H = hueslider.value
							local S = satslider.value
							local V = valslider.value
							local color = Color()
							color:setHSV(H, S, V)
							data = color
						end
					end

					local scope = MetaTable[modname]
					if scope == "Turret" then
						WriteTable[scope][modname](TemplateItem, data)
					else
						weaponMods[modname] = data
					end
				end

				-- now apply weapon args
				-- Loop to set the correct barrel number first
				local barrels = weaponMods['barrels']
				local weapons = {TurretItem:getWeapons()}
				TurretItem:clearWeapons()
				TurretGenerator.attachWeapons(rand, TemplateItem, weapons[1], barrels)

				-- Now apply the rest of the weapon mods
				weapons = {TemplateItem:getWeapons()}
				TemplateItem:clearWeapons()
				for _,weapon in pairs(weapons) do
					for modname,data in pairs(weaponMods) do
						-- don't want to do anything on barrels, because it doesn't exist in weapon scope
						if modname ~= "barrels" then WriteTable["Weapon"][modname](weapon, data) end
					end
					if not weapon.continuousBeam and weaponMods["template"] then
						weapon.localPosition = vec3(0, 0, 0)
					end
					TemplateItem:addWeapon(weapon)
				end

				TemplateItem:updateStaticStats()
				TempItem.item = InventoryTurret(TemplateItem)

				Win.Bin:remove(ivec2(0,0))
				Win.Bin:add(TempItem)
			end
		end
		return
end

return UILib