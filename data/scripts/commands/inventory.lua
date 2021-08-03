package.path = package.path .. ";data/scripts/lib/?.lua"

include ("randomext")
include ("galaxy")

include ("common")
weapon_types = include ("weapons")
include ("rarities")
include ("materials")
include ("upgrades")

TurretGenerator = include("turretgenerator")

-- Main function of the command, called by game when command is used.
function execute(sender, commandName, action, ...) -- weapontype, rarity, tech, material, amount, name
	local player = Player(Galaxy():findFaction(sender).index)
	local args = {...}
    local rest_command = ""
    for i,v in pairs(args) do
        rest_command = rest_command .. " " .. tostring(v)
    end
	player:sendChatMessage(player.name, 0, commandName .. " " .. action .. rest_command)

	local test = 5
	local flag, msg = false, ""
	if player then
		if action == "turret" then
			flag, msg = addTurrets(player, ...)
			player:sendChatMessage("Inventory Turret", 0, msg)
		elseif action == "upgrade" then
			flag, msg = addUpgrades(player, ...)
			player:sendChatMessage("Inventory Upgrade", 0, msg)
		elseif action == "help" or action == nil then
			flag, msg = true, getHelp()
			player:sendChatMessage("Inventory Help", 0, msg)
		else
			player:sendChatMessage("Inventory", 0, string.format("Unknown action: %s", action))
		end
	else
		player:sendChatMessage("Inventory", 0, string.format("Player %s couldn't be found.", name))
	end
	return 0, "", ""
end

-- Perform selected actions.
-- Adds turrets to selected faction inventory.
function addTurrets(faction, weapontype, rarity, material, tech, amount)
	local weapon_id = getWeapon(weapontype)
	if weapon_id then
		local rarity_ent = getRarity(rarity)
		if rarity_ent then
			local material_ent = getMaterial(material)
			if material_ent then
                amount = amount or 1
				if tonumber(amount) then
					local tech = math.max(1, tonumber(tech) or 6)
					local dps = Balancing_TechWeaponDPS(tech)
					local item = TurretGenerator.generateSeeded(random():createSeed(), weapon_id, dps, tech, rarity_ent, material_ent)
					print(tostring(addItems))
					addItems(faction, InventoryTurret(item), tonumber(amount))
					return true, amount .. " " .. rarity_ent.name .. " " .. material_ent.name .. " Tech-" .. tostring(tech) .. string.format(" %s added.", weapon_types[weapon_id])
				else
					return false, "ERROR: " .. amount .. " not a number"
				end
			else
				return false, "ERROR: " .. material .. " not recognized material"
			end
		else
			return false, "ERROR: " .. rarity .. " not recognized rarity"
		end
	else
		return false, "ERROR: " .. weapontype .. " not recognized weapon type"
	end
end

-- Adds system upgrades to selected faction inventory.
function addUpgrades(faction, script, rarity, amount)
	local upgrade_script = getUpgradeScript(script)
	if upgrade_script then
		local rarity_ent = getRarity(rarity)
		if rarity_ent then
			amount = amount or 1
			if tonumber(amount) then
				local seed = random():createSeed()
				local item = SystemUpgradeTemplate(upgrade_script, rarity_ent, seed)
				addItems(faction, item, tonumber(amount))
				return true, amount .. " " .. rarity_ent.name .. " " .. string.format( "%s added.", item.name)
			else
				return false, "ERROR: " .. amount .. " not a number"
			end
		else
			return false, "ERROR: " .. rarity .. " not recognized rarity"
		end
	else
		return false, "ERROR: " .. script .. " not recognized upgrade type"
	end
end

-- Functions used directly by Avorion.
-- Returns short description of a command.
function getDescription()
	return "Modifies inventory of a player."
end

-- This is printed when player use /help <command>.
function getHelp()
	return "Modifies inventory of a player. Usage:\n/inventory turret <type> [rarity] [material] [tech] [amount]\n/inventory upgrade <script> [rarity] [amount]"
end
