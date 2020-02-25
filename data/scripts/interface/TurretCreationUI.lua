--[[----------------------------------------------------------------------------

The structure of this interface module was reverse engineered from the
Turret Engineering Mod by:

- darkconsole <darkcee.legit@gmail.com>

Certain sections remain as-is due to a lack of understanding as to their purpose
or just the general efficiency of the code.
----------------------------------------------------------------------------]]--


-------------------- The Window Object Itself ----------------------------------
local Win = {
	Title = "Turret Customization",
	UI = nil,
	Res = nil,
	Size = nil,

	-- customize meta-parameters
	Material = nil,
	Rarity = nil,
	Tech = nil,
	Amount = nil,

	-- click selection id.
	-- the ui api really was not expecting anyone to do more than two
	-- selections per window so i have to track where drags start from as its
	-- not sent as an argument
	CurrentSelectID = nil,

	-- Did we drag from the auto-generated templates
	MagicTemplate = false,

	-- the window itself.
	Window = nil,

	-- the item we wish to mod.
	Item      = nil,
	ItemLabel = nil,

	-- the the resultant item.
	Bin      = nil,
	BinLabel = nil,

	-- the sample generated templates.
	Templates      = nil,

	-- the player's inventory.
	Inv      = nil,
	InvLabel = nil,

	-- store the Modifications UI items
	ModsUIElems = nil,

	-- Button Mapping for handling button presses
	ModsButtonMapping = nil,
	ModsTextBoxMapping = nil,
	ModsCheckBoxMapping = nil,
	ModsComboBoxMapping = nil,
	ComboEnumMapping = nil
}

-------------------- Initialization of required libs ---------------------------
package.path = package.path
.. ";data/scripts/lib/?.lua"
.. ";data/scripts/sector/?.lua"
.. ";data/scripts/?.lua"
.. ";data/scripts/interface/?.lua"

include("galaxy")
include("utility")
include("faction")
include("player")
include("randomext")
include("tableutility")
include("stringutility")
include("callable")

local SellableInventoryItem = include("sellableinventoryitem")
local TurretLib = include("TurretLib")
local UILib = include("TurretCreationUILib")

include("weapontype")
local Weapon_Types = WeaponType
local Armed_Types = WeaponTypes.armedTypes
local num_weapon_types = 0
local num_armed_types = 0
for _, ind in pairs(Weapon_Types) do
	num_weapon_types = num_weapon_types + 1
	if try_catch_table(Armed_Types, ind) then
		num_armed_types = num_armed_types + 1
	end
end
local Debug = true

local MaterialUtility = include("materials")
local RarityUtility = include("rarities")

local MaterialStringsTable = MaterialUtility['Material_Strings_Table']
local RarityStringsTable = RarityUtility['Rarity_Strings_Table']

--------------------------------------------------------------------------------
function Win:OnInit()

	self.Res = getResolution()
	self.Size = vec2(1200,700)
	self.UI = ScriptUI(Player().craftIndex)

	self.Window = self.UI:createWindow(Rect(
		(self.Res * 0.05),
		(self.Res * 0.95)
	))

	self.Window.caption = self.Title
	self.Window.showCloseButton = 1
	self.Window.moveable = 1
	self.UI:registerWindow(self.Window,self.Title)

	self:BuildUI()
	
	self.Item:clear()
	self.Item:addEmpty()

	self.Bin:clear()
	self.Bin:addEmpty()

	self.Templates:clear()
	for i=1, (num_armed_types) do
		self.Templates:addEmpty()
	end

	self.Inv:clear()
	self.Inv:addEmpty()

	-- Generic field updating is handled by the specific callbacks
	-- Fields will only be globally updated on initialization

		-- On initialization, initialize default variables
		if not self.Rarity then
			self.Rarity = -1
		end
		if not self.Material then
			self.Material = 0
		end
		if not self.Tech then
			self.Tech = 10
		end

		if not self.Templates:getItem(ivec2(0,0)) then
			self:OnClickedBtnRerollTemplates()
		end

		self:UpdateTemplateAmountLabel()
		self:UpdateCustomizedAmountLabel()

		self:UpdateMaterialLabel()
		self:UpdateRarityLabel()
		self:UpdateTechLabel()

		UpdateShowFields(self)

	self:PopulateInventory()

	self.ModsUIElems["beamscale"]["textbox"].text = "1"
	return
end

function Win:BuildUI()

	local WPane = UIHorizontalSplitter(
		Rect(self.Window.size),
		10, 10, 0.8
	)
	local TPane = UIHorizontalSplitter(
		WPane.top,
		0, 0, 0.3
	)
	local Pane = UIVerticalSplitter(
		TPane.top,
		5, 5, 0.3
	)
	local TTPane = UIHorizontalSplitter(
		Pane.right,
		0, 0, 0.4
	)

	local inventoryRect = WPane.bottom

	-- The bit that shows template and final product
	local LPane = UIVerticalSplitter(
		Pane.left,
		5, 0, 0.5
	)
	local templateSplit = UIHorizontalSplitter(
		LPane.left,
		5, 0, 0.6
	)
	local customizedSplit = UIHorizontalSplitter(
		LPane.right,
		5, 0, 0.6
	)

	local templateRect = templateSplit.top
	local customizedRect = customizedSplit.top
	local templateAmountRect = templateSplit.bottom
	local customizedAmountRect = customizedSplit.bottom

	-- The bit where you roll templates, and show modification abilities
	

	local templateRowRect = TTPane.top
	local templateParametersRect = TTPane.bottom

	-- The bit where you have all of the modification options
	local modsRect = TPane.bottom

	-- label stuffs
	local FontSize1 = 20
	local FontSize2 = 14
	local FontSize3 = 12
	local LineHeight1 = FontSize1 + 4

	-- Inventory management/selection boxes
		-- create the template item box
		self.Item = self.Window:createSelection(MaxSquareRect(templateRect),1)
		self.Item.dropIntoEnabled = 1
		self.Item.entriesSelectable = 0
		self.Item.onClickedFunction = "TurretCreationUI_OnItemClicked"
		self.Item.onReceivedFunction = "TurretCreationUI_OnItemAdded"

		-- create the created item box
		self.Bin = self.Window:createSelection(MaxSquareRect(customizedRect),1)
		self.Bin.dropIntoEnabled = 1
		self.Bin.entriesSelectable = 0
		self.Bin.onClickedFunction = "TurretCreationUI_OnBinClicked"
		self.Bin.onReceivedFunction = "TurretCreationUI_OnBinAdded"

		-- create the list of template turrets
		self.Templates = self.Window:createSelection(templateRowRect, num_armed_types)
		self.Templates.dropIntoEnabled = 1
		self.Templates.entriesSelectable = 0
		self.Templates.onClickedFunction = "TurretCreationUI_OnTemplatesClicked"
		self.Templates.onReceivedFunction = "TurretCreationUI_OnTemplatesAdded"

		-- create the list of things in your inventory
		self.Inv = self.Window:createSelection(inventoryRect,24)
		self.Inv.dropIntoEnabled = 1
		self.Inv.entriesSelectable = 0
		self.Inv.onClickedFunction = "TurretCreationUI_OnInvClicked"
		self.Inv.onReceivedFunction = "TurretCreationUI_OnInvAdded"

	-- Amount label/buttons
		self.TemplateFrame = self.Window:createFrame(templateAmountRect)
		self.CustomizedFrame = self.Window:createFrame(customizedAmountRect)

		-- Template Amount label (says how many are in the stack)
		self.ItemAmountLabel = self.Window:createLabel(
			Rect(),
			"Amount:   ----",
			FontSize1
		)
		self.ItemAmountLabel.rect = FramedRect(self.TemplateFrame, 1, 1, 1, 1)
		self.ItemAmountLabel.centered = true
		self.ItemAmountLabel:setCenterAligned()

		-- Customized Bin Amount Label text (just the bit that says "Amount: ")
		self.BinAmountLabel = self.Window:createLabel(
			Rect(),
			"Amount: ",
			FontSize1
		)
		self.BinAmountLabel.rect = FramedRect(self.CustomizedFrame, 1, 1, 2, 1)
		self.BinAmountLabel.centered = true
		self.BinAmountLabel:setCenterAligned()

		-- Customized Bin Amount label text (the bit that says how much you're going to change)
		self.BinAmountTextLabel = self.Window:createLabel(
			Rect(),
			"----",
			FontSize1
		)
		self.BinAmountTextLabel.rect = FramedRect(self.CustomizedFrame, 3.5, 1, 4, 1)
		self.BinAmountTextLabel.centered = true
		self.BinAmountTextLabel:setCenterAligned()

		-- Button that increases the amount you're going to change
		self.BtnBinAmountPlus = self.Window:createButton(
			Rect(),
			"+",
			"TurretCreationUI_OnClickedBtnBinAmountPlus"
		)
		self.BtnBinAmountPlus.textSize = FontSize2
		self.BtnBinAmountPlus.rect = MaxSquareRect(FramedRect(self.CustomizedFrame, 5, 1, 8, 1))

		-- Button that ddcreases the amount you're going to change
		self.BtnBinAmountMinus = self.Window:createButton(
			Rect(),
			"-",
			"TurretCreationUI_OnClickedBtnBinAmountMinus"
		)
		self.BtnBinAmountMinus.textSize = FontSize2
		self.BtnBinAmountMinus.rect = MaxSquareRect(FramedRect(self.CustomizedFrame, 8, 1, 8, 1))

	-- Template Parameters
		self.ParametersFrame = self.Window:createFrame(templateParametersRect)

		self.BtnMaterialPlus = self.Window:createButton(
			Rect(),
			"+",
			"TurretCreationUI_OnClickedBtnMaterialPlus"
		)
		self.BtnMaterialPlus.textSize = FontSize1
		self.BtnMaterialPlus.rect = MaxSquareRect(FramedRect(self.ParametersFrame, 7, 1, 24, 3))

		self.BtnMaterialMinus = self.Window:createButton(
			Rect(),
			"-",
			"TurretCreationUI_OnClickedBtnMaterialMinus"
		)
		self.BtnMaterialMinus.textSize = FontSize1
		self.BtnMaterialMinus.rect = MaxSquareRect(FramedRect(self.ParametersFrame, 8, 1, 24, 3))

		self.BtnRarityPlus = self.Window:createButton(
			Rect(),
			"+",
			"TurretCreationUI_OnClickedBtnRarityPlus"
		)
		self.BtnRarityPlus.textSize = FontSize1
		self.BtnRarityPlus.rect = MaxSquareRect(FramedRect(self.ParametersFrame, 15, 1, 24, 3))

		self.BtnRarityMinus = self.Window:createButton(
			Rect(),
			"-",
			"TurretCreationUI_OnClickedBtnRarityMinus"
		)
		self.BtnRarityMinus.textSize = FontSize1
		self.BtnRarityMinus.rect = MaxSquareRect(FramedRect(self.ParametersFrame, 16, 1, 24, 3))

		self.BtnTechPlus = self.Window:createButton(
			Rect(),
			"+",
			"TurretCreationUI_OnClickedBtnTechPlus"
		)
		self.BtnTechPlus.textSize = FontSize1
		self.BtnTechPlus.rect = MaxSquareRect(FramedRect(self.ParametersFrame, 23, 1, 24, 3))

		self.BtnTechMinus = self.Window:createButton(
			Rect(),
			"-",
			"TurretCreationUI_OnClickedBtnTechMinus"
		)
		self.BtnTechMinus.textSize = FontSize1
		self.BtnTechMinus.rect = MaxSquareRect(FramedRect(self.ParametersFrame, 24, 1, 24, 3))

		self.BtnRerollTemplates = self.Window:createButton(
			Rect(),
			"Reroll Templates",
			"TurretCreationUI_OnClickedBtnRerollTemplates"
		)
		self.BtnRerollTemplates.textSize = FontSize1
		self.BtnRerollTemplates.rect = FramedRect(self.ParametersFrame, 2, 2, 2, 3)

		self.BtnCopyMetaParams = self.Window:createButton(
			Rect(),
			"Copy Metaparameters",
			"TurretCreationUI_OnClickedBtnCopyMetaParams"
		)
		self.BtnCopyMetaParams.textSize = FontSize1
		self.BtnCopyMetaParams.rect = FramedRect(self.ParametersFrame, 1, 2, 2, 3)


		self.MaterialLabel = self.Window:createLabel(
			Rect(),
			"$LABEL$",
			FontSize1
		)
		self.MaterialLabel.rect = FramedRect(self.ParametersFrame, 1, 1, 4, 3)
		self.MaterialLabel.centered = true
		self.MaterialLabel:setRightAligned()

		self.RarityLabel = self.Window:createLabel(
			Rect(),
			"$LABEL$",
			FontSize1
		)
		self.RarityLabel.rect = FramedRect(self.ParametersFrame, 3.5, 1, 6, 3)
		self.RarityLabel.centered = true
		self.RarityLabel:setRightAligned()

		self.TechLabel = self.Window:createLabel(
			Rect(),
			"Tech: ",
			FontSize1
		)
		self.TechLabel.rect = FramedRect(self.ParametersFrame, 10, 1, 12, 3)
		self.TechLabel.centered = true
		self.TechLabel:setRightAligned()

		self.TechAmountLabel = self.Window:createLabel(
			Rect(),
			"$LABEL$",
			FontSize1
		)
		self.TechAmountLabel.rect = FramedRect(self.ParametersFrame, 11, 1, 12, 3)
		self.TechAmountLabel.centered = true
		self.TechAmountLabel:setCenterAligned()

		self.BtnClearMods = self.Window:createButton(
			Rect(),
			"Clear Modifications",
			"TurretCreationUI_OnClickedBtnClearMods"
		)
		self.BtnClearMods.textSize = FontSize1
		self.BtnClearMods.rect = FramedRect(self.ParametersFrame, 2, 3, 2, 3)

		self.BtnApplyMods = self.Window:createButton(
			Rect(),
			"Apply Modifications",
			"TurretCreationUI_OnClickedBtnApplyMods"
		)
		self.BtnApplyMods.textSize = FontSize1
		self.BtnApplyMods.rect = FramedRect(self.ParametersFrame, 1, 3, 2, 3)

	-- Modification Parameters
	self.ModsRect = modsRect
	BuildModificationParametersUI(self)
	return
end

--------------------- Turret Selection/Inventory Management --------------------

	function Win:PopulateInventory(NewCurrentIndex)
	-- most of the structure for this function was stolen from the vanilla research
	-- station script. it reads your inventory and creates a visible list of all
	-- the turrets you can drag drop.
	
		local ItemList = {}
		local Me = Player()
		local Count = 0
		local Item = nil
	
		self.Inv:clear()
	
		-- throw everything that makes sense into a table so we can sort it.
	
		for Iter, Thing in pairs(Me:getInventory():getItems()) do
			if (Thing.item.itemType == InventoryItemType.Turret or Thing.item.itemType == InventoryItemType.TurretTemplate) then
				local weapons = {Thing.item:getWeapons()}
				local armed = false
				for _,weapon in pairs(weapons) do
					armed = weapon.armed
					break
				end
				if armed then
					local Item = SellableInventoryItem(Thing.item,Iter,Me)
					table.insert(ItemList,Item)
				end
			end
		end
	
		-- sort starred items to the front of the list, trash to the end.
	
		table.sort(ItemList,function(a,b)
			if(a.item.favorite and not b.item.favorite) then
				return true
			else
				if(b.item.trash and not a.item.trash) then
					return true
				else
					return false
				end
			end
		end)
	
		-- now create items in our dialog to represent the inventory items.
		-- are are unstacking items for this.
	
		for Iter, Thing in pairs(ItemList) do
			Item = InventorySelectionItem()
			Item.item = Thing.item
			Item.uvalue = Thing.index
			Item.amount = Thing.amount

			if((NewCurrentIndex ~= nil) and (NewCurrentIndex == Item.uvalue)) then
				-- handle when the server says an item was modded.
				--[[self.Item:clear()
				self.Item:add(Item)
				NewCurrentIndex = nil

				-- empty the bin
				self.Bin:clear()
				self.Bin:addEmpty()

				self:UpdateCustomizedItem(Item)]]--
				self.Inv:addEmpty()
			else
				-- populate the normal inventory.
				self.Inv:add(Item)
			end
		end
		
		return
	end

	function Win:UpdateCustomizedItem(NewItem)
		local ItemCopy = InventorySelectionItem()
		ItemCopy.item = NewItem.item
		ItemCopy.uvalue = NewItem.uvalue
		ItemCopy.amount = self.Amount

		self.Bin:clear()
		self.Bin:add(ItemCopy)
		return
	end

	function Win:OnItemClicked(SelectID, FX, FY, Item, Button)
		self.CurrentSelectID = SelectID
		return
	end

	function Win:OnBinClicked(SelectID, FX, FY, Item, Button)
		self.CurrentSelectID = SelectID
		return
	end

	function Win:OnTemplatesClicked(SelectID, FX, FY, Item, Button)
		self.CurrentSelectID = SelectID
		return
	end

	function Win:OnInvClicked(SelectID, FX, FY, Item, Button)
		self.CurrentSelectID = SelectID
		return
	end

	function Win:OnItemAdded(SelectID, FX, FY, Item, FromIndex, ToIndex, TX, TY)

		local FromVec = ivec2(FX,FY)

		if(SelectID == self.CurrentSelectID) then
			print("[TurretCustomizer] Template Bin was source and dest.")
			return
		end

		-- We can move stuff to template box from either Inventory or Templates
		if (self.CurrentSelectID ~= self.Bin.index) then

			local Template_Item = GetCurrentItem(self)
			local ItemVec = ivec2(0,0)
			self.Item:remove(ItemVec)

			-- If Template came from Inventory, want to return it
			if not (self.MagicTemplate) then
				self.Inv:add(Template_Item)
			end

			-- In case removing from inventory, want to remove the item from there
			if (self.CurrentSelectID == self.Inv.index) then
				self.Inv:remove(FromVec)
				self.MagicTemplate = false
			elseif (self.CurrentSelectID == self.Templates.index) then
				self.MagicTemplate = true
			end

			-- add Item to template bin, update associated labels
			self.Item:add(Item)
			self.Amount = Item.amount
			self:UpdateTemplateAmountLabel()
			self:UpdateCustomizedAmountLabel()

			-- Update all stats and template stuffs
			self:UpdateCustomizedItem(Item) -- populate new Bin first, because we need that for mod parameters

			CopyModdedParameters(self)
			CopyBaselineParameters(self)
			HandleColorSlider()
			UpdateMutexBeamHeat(self)
			UpdateShowFields(self) -- update what gets shown in the mods window. will auto-populate with copy of fields

			print("[TurretCustomizer] Added to Template Slot: " .. Item.item.weaponName)

			--------
		else
			-- Illegal
			print("[TurretCustomizer] Attempted to replace Template with Customized Item.")
		end
		return
	end

	function Win:OnBinAdded(SelectID, FX, FY, Item, FromIndex, ToIndex, TX, TY)
		if(SelectID == self.CurrentSelectID) then
			print("[TurretCustomizer] Customized Bin was source and dest.")
		else
			print("[TurretCustomizer] Invalid Operation: attempt to move item into protected location 'Customized Bin'.")
		end
		return
	end

	function Win:OnTemplatesAdded(SelectID, FX, FY, Item, FromIndex, ToIndex, TX, TY)
		if(SelectID == self.CurrentSelectID) then
			print("[TurretCustomizer] Template Bin was source and dest.")
		else
			print("[TurretCustomizer] Invalid Operation: attempt to move item into protected location 'Template Bin'.")
		end
		return
	end

	function Win:OnInvAdded(SelectID, FX, FY, Item, FromIndex, ToIndex, TX, TY)

		local FromVec = ivec2(FX,FY)

		if(SelectID == self.CurrentSelectID) then
			print("[TurretCustomizer] Inv was source and dest.")
			return
		end

		self.Inv:add(Item)
		print("[TurretCustomizer] Added to Inv: " .. Item.item.weaponName)

		--------

		if(self.CurrentSelectID == self.Item.index) then
			-- clear Amount and update labels
			self.Amount = nil

			-- Update Player Inventory
			if self.MagicTemplate then -- we just clear from self.Item, add new to inventory
				self:UpdatePlayerInventory(Player().index, Item, nil, GetCurrentItemCount(self))
			else -- have to remove it from the inventory
				self:UpdatePlayerInventory(Player().index, Item, GetCurrentItemIndex(self), GetCurrentItemCount(self))
			end

			-- remove item from source
			self.Item:remove(FromVec)

			-- clear bin as a result
			self.Bin:clear()
			self.Bin:addEmpty()

			-- Update amounts
			self:UpdateTemplateAmountLabel()
			self:UpdateCustomizedAmountLabel()

			-- Update Mods UI by updating what gets shown
			CopyModdedParameters(self)
			ClearBaselineParameters(self)
			HandleColorSlider()
			UpdateMutexBeamHeat(self)
			UpdateShowFields(self)

		elseif(self.CurrentSelectID == self.Bin.index) then
			-- clear Amount and update labels
			self.Amount = nil

			-- Update Player Inventory
			if self.MagicTemplate then -- we just clear from self.Item, add new to inventory
				self:UpdatePlayerInventory(Player().index, Item, nil, GetCurrentBinItemCount(self))
			else -- have to remove it from the inventory
				self:UpdatePlayerInventory(Player().index, Item, GetCurrentItemIndex(self), GetCurrentBinItemCount(self))
			end

			-- remove item from source
			self.Bin:remove(FromVec)

			-- clear bin as a result
			self.Bin:clear()
			self.Bin:addEmpty()

			-- clear Item as a result
			self.Item:clear()
			self.Item:addEmpty()

			-- Update Amounts
			self:UpdateTemplateAmountLabel()
			self:UpdateCustomizedAmountLabel()

			-- Update Mods UI by updating what gets shown
			CopyModdedParameters(self)
			ClearBaselineParameters(self)
			HandleColorSlider()
			UpdateMutexBeamHeat(self)
			UpdateShowFields(self)
		end

		return
	end

	function Win:UpdatePlayerInventory(PlayerID, NewItem, OldIndex, Count)
		if (onClient()) then
			return invokeServerFunction(
				"ServerCallback_UpdatePlayerInventory",
				PlayerID,
				NewItem.item,
				OldIndex,
				Count
			)
		end
		return
	end
	function ServerCallback_UpdatePlayerInventory(PlayerID, NewItem, OldIndex, Count)
		local Armory = Player(PlayerID):getInventory()

		if OldIndex then
			local Old = Armory:find(OldIndex)
			local Count = Armory:amount(Index)

			NewItem.favorite = Old.favorite
			NewItem.trash = Old.trash

			-- handle stacked items.
			Armory:removeAll(OldIndex)
		end

		for i=1,Count do
			Armory:add(NewItem)
		end
		return
	end
	callable(nil, "ServerCallback_UpdatePlayerInventory")

------------------------- Meta-Variable Button Handling ------------------------

	----------------------- Amount Labels and Buttons --------------------------
		function Win:UpdateTemplateAmountLabel()
			local CurrentItem = GetCurrentItem(self)
			if CurrentItem then
				self.ItemAmountLabel.caption = "Amount:   " .. centerNumber(CurrentItem.amount, 4)
			else
				self.ItemAmountLabel.caption = "Amount:   ----"
			end
		end

		function Win:UpdateCustomizedAmountLabel()
			if self.Amount then
				self.BinAmountTextLabel.caption = centerNumber(self.Amount, 4)
			else
				self.BinAmountTextLabel.caption = "----"
			end
		end

		function Win:OnClickedBtnBinAmountPlus()
			if self.Amount then
				self.Amount = self.Amount + 1
				local TempItem = self.Bin:getItem(ivec2(0,0))
				self.Bin:remove(ivec2(0,0))
				TempItem.amount = self.Amount
				self.Bin:add(TempItem)
			end
			self:UpdateCustomizedAmountLabel()
			return
		end

		function Win:OnClickedBtnBinAmountMinus()
			if self.Amount and self.Amount > 1 then
				self.Amount = self.Amount - 1
				local TempItem = self.Bin:getItem(ivec2(0,0))
				self.Bin:remove(ivec2(0,0))
				TempItem.amount = self.Amount
				local TurretItem = TempItem.item
				if TurretItem.automatic then
					TurretItem.automatic = false
				else
					TurretItem.automatic = true
				end
				TurretItem:updateStaticStats()
				TempItem.item = TurretItem
				self.Bin:add(TempItem)
			end
			self:UpdateCustomizedAmountLabel()
			return
		end

	----------------- Template Parameters Labels and Buttons -------------------

		function Win:UpdateMaterialLabel(delta)
			if not delta then delta = 0 end
			local proposed = self.Material + delta
			local material = try_catch_table(MaterialStringsTable, proposed)
			if material then
				self.Material = proposed
				self.MaterialLabel.caption = material
				self.MaterialLabel.color = Material(proposed).color
				return true
			else
				return false
			end
		end

		function Win:UpdateRarityLabel(delta)
			if not delta then delta = 0 end
			local proposed = self.Rarity + delta
			local rarity = try_catch_table(RarityStringsTable, proposed)
			if rarity then
				self.Rarity = proposed
				self.RarityLabel.caption = rarity
				self.RarityLabel.color = Rarity(proposed).color
				return true
			else
				return false
			end
		end

		function Win:UpdateTechLabel(delta)
			if not delta then delta = 0 end
			local proposed = self.Tech + delta
			if proposed > 0 then
				self.Tech = proposed
				self.TechAmountLabel.caption = tostring(proposed)
				return true
			else
				return false
			end
		end

		function Win:UpdateBinMaterial()
			local TempItem = self.Bin:getItem(ivec2(0,0))
			if TempItem then
				local TurretItem = TempItem.item
				local weapons = {TurretItem:getWeapons()}

				TurretItem:clearWeapons()
				for _,weapon in pairs(weapons) do
					weapon.material = Material(self.Material)
					TurretItem:addWeapon(weapon)
				end
				TurretItem:updateStaticStats()
				TempItem.item = TurretItem

				self.Bin:remove(ivec2(0,0))
				self.Bin:add(TempItem)
			end
		end

		function Win:UpdateBinRarity()
			local TempItem = self.Bin:getItem(ivec2(0,0))
			if TempItem then
				local TurretItem = TempItem.item
				local weapons = {TurretItem:getWeapons()}

				TurretItem:clearWeapons()
				for _,weapon in pairs(weapons) do
					weapon.rarity = Rarity(self.Rarity)
					TurretItem:addWeapon(weapon)
				end
				TurretItem:updateStaticStats()
				TempItem.item = TurretItem

				self.Bin:remove(ivec2(0,0))
				self.Bin:add(TempItem)
			end
		end

		function Win:UpdateBinTech()
			local TempItem = self.Bin:getItem(ivec2(0,0))
			if TempItem then
				local TurretItem = TempItem.item
				local weapons = {TurretItem:getWeapons()}

				TurretItem:clearWeapons()
				for _,weapon in pairs(weapons) do
					weapon.tech = self.Tech
					TurretItem:addWeapon(weapon)
				end
				TurretItem:updateStaticStats()
				TempItem.item = TurretItem

				self.Bin:remove(ivec2(0,0))
				self.Bin:add(TempItem)
			end
		end

		function Win:OnClickedBtnMaterialPlus()
			return self:UpdateMaterialLabel(1)
		end
		function Win:OnClickedBtnMaterialMinus()
			return self:UpdateMaterialLabel(-1)
		end
		
		function Win:OnClickedBtnRarityPlus()
			return self:UpdateRarityLabel(1)
		end
		function Win:OnclickedBtnRarityMinus()
			return self:UpdateRarityLabel(-1)
		end
		
		function Win:OnClickedBtnTechPlus()
			return self:UpdateTechLabel(1)
		end
		function Win:OnClickedBtnTechMinus()
			return self:UpdateTechLabel(-1)
		end

		function Win:OnClickedBtnRerollTemplates()
			self.Templates:clear()
			for _,id in pairs(Armed_Types) do
				local dps = Balancing_TechWeaponDPS(self.Tech)
				local rand = random()
				local seed = rand:createSeed()
				local item = TurretGenerator.generateSeeded(seed, id, dps, self.Tech, Rarity(self.Rarity), Material(self.Material))
				
				
				local Item = InventorySelectionItem()
				Item.item = InventoryTurret(item)
				Item.uvalue = nil
				Item.amount = 1

				self.Templates:add(Item)
			end
		end

		function Win:OnClickedBtnCopyMetaParams()
			local TempItem = GetCurrentItem(self)
			if TempItem then
				local TurretItem = TempItem.item
				local weapons = {TurretItem:getWeapons()}

				for _,weapon in pairs(weapons) do
					self.Tech = weapon.tech
					self.Material = weapon.material.value
					self.Rarity = weapon.rarity.value
					break
				end
			end
			self:UpdateRarityLabel()
			self:UpdateMaterialLabel()
			self:UpdateTechLabel()
			self:OnClickedBtnRerollTemplates()
		end

----------------- Modification Parameters Labels and Buttons -------------------

	function Win:OnClickedBtnClearMods()
	-- Clear all modifications, i.e. set them all to default values of what's in item
		CopyModdedParameters(self)
		HandleColorSlider()
		return
	end

	function Win:ValidateFields()
	-- Validate all field values: (text field only, rest is guaranteed compatible)
	--    - set them to ERROR: value, if error
	--    - set to default if blank (fetch default from the bin)
		local all_clear = true
		for modname,UIElems in pairs(Win.ModsUIElems) do
			local res,_ = try_catch_table(UILib.UIGroupMembers, modname)
			local toconsider = false
			if res then
				if try_catch_table(res, Win.MutexBeam) or try_catch_table(res, Win.MutexHeat) then
					toconsider = true
				end
			else
				toconsider = true
			end

			if toconsider then
				local textbox,_ = try_catch_table(UIElems, "textbox")
				if textbox then
					local data = tonumber(textbox.text)
					if not data then
						all_clear = false
						textbox.text = "ERROR: " .. textbox.text
					else
						-- perform some data correction here too
						if modname == "accuracy" then
							if data > 1 then textbox.text = "1" end
							if data <= 0 then
								all_clear = false
								textbox.text = "BAD ACCURACY"
							end
						elseif modname == "rotation" then
							if Win.ModsUIElems["coaxial"]["checkbox"].checked then
								textbox.text = "0"
							elseif data < 0 then
								all_clear = false
								textbox.text = "BAD ROTATION"
							end
						elseif modname == "projectilevelocity" then if data <= 100 then textbox.text = "100" end
						elseif modname == "projectilelife" then if data <= 0 then textbox.text = "0.25" end
						elseif modname == "firerate" then if data <= 0 then textbox.text = "0.1" end
						elseif modname == "beamscale" then if data <= 0 then textbox.text = "0.1" end
						else if data < 0 then textbox.text = "0" end
						end
					end
				end
			end
		end

		return all_clear
	end

	function Win:OnClickedBtnApplyMods()
		if GetCurrentItem(self) then
			if self:ValidateFields() then
				self:UpdateBinRarity()
				self:UpdateBinMaterial()
				self:UpdateBinTech()

				self:OnClickedBtnRerollTemplates()

				-- apply actual mods to bin item
				ApplyAllValidMods(self)

				self.ModsUIElems["beamscale"]["textbox"].text = "1"

				-- Use this convenient wrapper for copying over new data in case of conflict resolution
				UpdateMutexBeamHeat(self)
				UpdateShowFields(self)
			end
		end
	end

--------------------------------------------------------------------------------

	-- NOTA BENE: on clicked button gets called with the Button Object as primary

---------------------------- Function Wrappers ---------------------------------

	-- Initialization
		function TurretCreationUI_OnInit(...) Win:OnInit(...) end

	-- Inventory/drag selection mechanics
		function TurretCreationUI_OnItemClicked(...) Win:OnItemClicked(...) end
		function TurretCreationUI_OnItemAdded(...) Win:OnItemAdded(...) end
		function TurretCreationUI_OnBinClicked(...) Win:OnBinClicked(...) end
		function TurretCreationUI_OnBinAdded(...) Win:OnBinAdded(...) end
		function TurretCreationUI_OnTemplatesClicked(...) Win:OnTemplatesClicked(...) end
		function TurretCreationUI_OnTemplatesAdded(...) Win:OnTemplatesAdded(...) end
		function TurretCreationUI_OnInvClicked(...) Win:OnInvClicked(...) end
		function TurretCreationUI_OnInvAdded(...) Win:OnInvAdded(...) end

	-- Amount +/- buttons
		function TurretCreationUI_OnClickedBtnBinAmountPlus(...) Win:OnClickedBtnBinAmountPlus(...) end
		function TurretCreationUI_OnClickedBtnBinAmountMinus(...) Win:OnClickedBtnBinAmountMinus(...) end

	-- Template Parameters Buttons
		function TurretCreationUI_OnClickedBtnMaterialPlus(...) Win:OnClickedBtnMaterialPlus(...) end
		function TurretCreationUI_OnClickedBtnMaterialMinus(...) Win:OnClickedBtnMaterialMinus(...) end
		function TurretCreationUI_OnClickedBtnRarityMinus(...) Win:OnclickedBtnRarityMinus(...) end
		function TurretCreationUI_OnClickedBtnRarityPlus(...) Win:OnClickedBtnRarityPlus(...) end
		function TurretCreationUI_OnClickedBtnRarityMinus(...) Win:OnclickedBtnRarityMinus(...) end
		function TurretCreationUI_OnClickedBtnTechPlus(...) Win:OnClickedBtnTechPlus(...) end
		function TurretCreationUI_OnClickedBtnTechMinus(...) Win:OnClickedBtnTechMinus(...) end
		function TurretCreationUI_OnClickedBtnRerollTemplates(...) Win:OnClickedBtnRerollTemplates(...) end
		function TurretCreationUI_OnClickedBtnCopyMetaParams(...) Win:OnClickedBtnCopyMetaParams(...) end

	-- Clear Modifications button
		function TurretCreationUI_OnClickedBtnClearMods(...) Win:OnClickedBtnClearMods(...) end
		function TurretCreationUI_OnClickedBtnApplyMods(...) Win:OnClickedBtnApplyMods(...) end

	-- Modifications Button stuffs
		function HandlePlusButton(button)
			local ind = button.index
			local modname = Win.ModsButtonMapping[ind]
			local proposed = tonumber(Win.ModsUIElems[modname]["var"].caption)
			if proposed then
				proposed = proposed + 1
				if modname == "turretsize" then
					proposed = proposed - 0.5
					proposed = math.max(proposed,0.5)
				elseif modname == "barrels" then
					proposed = math.min(4, math.max(proposed, 1))
				elseif modname == "shots" then
					proposed = math.max(proposed,1)
				elseif modname == "slots" then
					proposed = math.max(proposed,1)
				else
					proposed = math.max(proposed,0)
				end
				Win.ModsUIElems[modname]["var"].caption = tostring(proposed)
			end
		end

		function HandleMinusButton(button)
			local ind = button.index
			local modname = Win.ModsButtonMapping[ind]
			local proposed = tonumber(Win.ModsUIElems[modname]["var"].caption)
			if proposed then
				proposed = proposed - 1
				if modname == "turretsize" then
					proposed = proposed + 0.5
					proposed = math.max(proposed,0.5)
				elseif modname == "barrels" then
					proposed = math.min(4, math.max(proposed, 1))
				elseif modname == "shots" then
					proposed = math.max(proposed,1)
				elseif modname == "slots" then
					proposed = math.max(proposed,1)
				else
					proposed = math.max(proposed,0)
				end
				Win.ModsUIElems[modname]["var"].caption = tostring(proposed)
			end
		end

		function HandleCheckBox(checkbox)
		end

		function HandleTextBox(textbox)
		end

		function HandleComboBox(combobox)
			UpdateMutexBeamHeat(Win)
			UpdateShowFields(Win)
		end

		function HandleColorSlider(...)
			local UIElems = Win.ModsUIElems["color"]
			local H = UIElems["hueslider"].value
			local S = UIElems["satslider"].value
			local V = UIElems["valslider"].value
			local color = Color()
			color:setHSV(H, S, V)

			UIElems["frame"].backgroundColor = color
			return
		end
--------------------------------------------------------------------------------

return Win