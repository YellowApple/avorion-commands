package.path = package.path .. ";data/scripts/lib/?.lua"

include ("stringutility")
include ("tableutility")
weapon_types = include ("weapons")
include ("rarities")
include ("materials")
include ("upgrades")

include ("common")
include ("galaxy")
include ("randomext")
TurretGenerator = include("turretgenerator")
 
local Required_Args = {}
Required_Args["type"] = ""
Required_Args["material"] = ""
Required_Args["rarity"] = ""

local Optional_Args = {}
Optional_Args["tech"] = ""
Optional_Args["amount"] = ""
Optional_Args["mode"] = ""

local description_string = "\n"
	.. "Required Arguments:\n"
	.. "[type] Weapon Type\n"
	.. "[material] Weapon Material\n"
	.. "[rarity] Weapon Rarity\n"
	.. "[tech] Weapon Tech\n"
	.. "[amount] Weapon Amount\n"
	.. "\n"
	.. "Boolean Arguments:\n"
	.. "[mode] Uniform or Random Generation (0): 0 for identical, 1 for random\n"
	.. "[automatic] Independent Targeting (nil): nil = generator default, 0 = no independent targeting, 1 = always independent targeting. {turret.automatic}\n"
	.. "[coaxial] Coaxial (nil): nil = generator default, 0 = no independent targeting, 1 = always independent targeting. {turret.coaxial}\n"
	.. "[simultaneous] Multiple Projectile (nil): nil = generator default, 0 = no mult, 1 = always mult. {turret.simultaneousShooting}\n"
	.. "\n"
	.. "[beam] Beam or Projectile (nil): nil = generator default, 0 = projectile, 1 = beam. {weapon.setBeam(), weapon.setProjectile()}\n"
	.. "[continuous] Continuous Beam (nil): nil = generator default, 0 = false, 1 = true. {weapon.continuousBeam}\n"
	.. "[deathexplosion] Projectile Explodes on Death (nil): nil = generator default, 0 = false, 1 = true. {weapon.deathExplosion}\n"
	.. "[impactexplosion] Projectile Explodes on Impact (nil): nil = generator default, 0 = false, 1 = true. {weapon.impactExplosion}\n"
	.. "[projectile] Beam or Projectile (nil): nil = generator default, 0 = beam, 1 = projectile. {weapon.setBeam(), weapon.setProjectile()}\n"
	.. "[seeker] Seeking Missiles (nil): nil = generator default, 0 = never seeking, 1 = always seeking. {weapon.seeker}\n"
	.. "[timeddeath] Projectile Has Timed Death (nil): nil = generator default, 0 = false, 1 = true. {weapon.timedDeath}\n"
	.. "\n"
	--[[.. "Enum Arguments:\n"
	.. "[coolingtype] Weapon Cooling Type (nil): nil = generator default, [levenshtein-matched string] = new cooling type. {turret.coolingType} -- CoolingType\n"
	.. "\n"
	.. "[damagetype] Weapon Damage Type (nil): nil = generator default, [levenshtein-matched string] weapon damage type. {weapon.damageType} -- DamageType\n"
	.. "[salvagematerial] Mining/Salvaging Material Grade (nil): nil = generator default, [levenshtein-matched string] salvaging/mining material. {weapon.smaterial} -- MaterialType\n"
	.. "[shape] Weapon Projectile/Beam Shape (nil): nil = generator default, [levenshtein-matched string] projectile/beam shape type {weapon.pshape, weapon.bshape} -- ProjectileShape, BeamShape\n"
	.. "\n"]]
	.. "Int Arguments:\n"
	.. "[crew] Crew Required (nil): nil = generator default, [int] = number of gunners needed. {turret.crew}\n"
	.. "[turretsize] Weapon Size (nil): nil = generator default, [0.5*n] = absolute size. {turret.size}\n"
	.. "[slots] Weapon Slots (nil): nil = generator default, [1,2,3,4,5,6] = number of slots used. {turret.slots}\n"
	.. "\n"
	.. "[blockpenetration] Block Penetration (nil): nil = generator default, [int] = number of blocks to penetrate {weapon.blockPenetration}\n"
	.. "[shots] Number of Shots (nil): nil = generator default, [1,2,3,4] = number of shots fired. {weapon.shotsFired}\n"
	.. "[barrels] Number of Barrels (nil): nil = generator default, [1,2,3,4] = number of barrels. {turret:addWeapons()}\n"
	.. "\n"
	.. "Tuple Arguments:\n"
	.. "[color] Weapon Color (nil): nil = generator default, [tuple] = color to be used {weapon.pcolor, weapon.binnerColor, weapon.bouterColor}\n"
	.. "\n"
	.. "Multiplicator Arguments:\n"
	.. "[baseenergy] = function(turret, target) turret.baseEnergyPerSecond=turret.baseEnergyPerSecond*target end\n"
	.. "[cooling] = function(turret, target) turret.coolingRate=turret.coolingRate*target end\n"
	.. "[energyincrease] = function(turret, target) turret.energyIncreasePerSecond=turret.energyIncreasePerSecond*target end\n"
	.. "[maxheat] = function(turret, target) turret.maxHeat=turret.maxHeat*target end\n"
	.. "[rotation] = function(turret, target) turret.turningSpeed=turret.turningSpeed*target end\n"
	.. "[shotheat] = function(turret, target) turret.heatPerShot=turret.heatPerShot*target end\n"
	.. "\n"
	.. "[damage] = function(weapon, target) weapon.damage=weapon.damage*target end\n"
	.. "[explosionradius] = function(weapon, target) weapon.explosionRadius=weapon.explosionRadius*target end\n"
	.. "[firerate] = function(weapon, target) weapon.fireRate=weapon.fireRate*target end\n"
	.. "[hullrepair] = function(wepaon, target) wepaon.hullRepair = wepaon.hullRepair*target end\n"
	.. "[otherforce] = function(weapon, target) weapon.otherForce=weapon.otherForce*target end\n"
	.. "[projectilelife] = function(weapon, target) weapon.pmaximumTime=weapon.pmaximumTime*target end\n"
	.. "[projectilevelocity] = function(weapon, target) weapon.pvelocity=weapon.pvelocity*target end\n"
	.. "[reach] = function(weapon, target) weapon.reach=weapon.reach*target end\n"
	.. "[recoil] = function(weapon, target) weapon.recoil=weapon.recoil*target end\n"
	.. "[selfforce] = function(weapon, target) weapon.selfForce=weapon.selfForce*target end\n"
	.. "[shieldrepair] = function(weapon, target) weapon.shieldRepair=weapon.shieldRepair*target end\n"
	.. "[projectilesize] = function(weapon.psize, weapon.bshapeSize, weapon.bwidth, weapon.blength, wepaon, target) weapon.psize, weapon.bshapeSize, weapon.bwidth, weapon.blength, wepaon.bauraWidth=weapon.psize, weapon.bshapeSize, weapon.bwidth, weapon.blength, wepaon.bauraWidth*target end\n"
	.. "\n"
	.. "Absolute Arguments:\n"
	.. "[accuracy] Weapon Accuracy (nil): nil = generator default, [float] = absolute weapon accuracy. {weapon.accuracy}\n"
	.. "[efficiency] Weapon Mining/Salvage Efficiency (nil): nil = generator default, [float] = absolute efficiency. {weapon.stoneRefinedEfficiency, weapon.metalRefinedEfficiency, weapon.stoneRawEfficiency, weapon.metalRawEfficiency}\n"
	.. "[hulldamage] Weapon Hull Damage Multiplier (nil): nil = generator default, [float] = absolute damage to hull multiplier {weapon.hullDamageMultiplicator}\n"
	.. "[shielddamage] Weapon Shield Damage Multiplier (nil): nil = generator default, [float] = absolute damage to shield multiplier {weapon.shieldDamageMultiplicator}\n"
	.. "[stonedamage] Weapon Stone Damage Multiplier (nil): nil = generator default, [float] = absolute damage percentage change to stone {weapon.stoneDamageMultiplicator}\n"
	.. "[shieldpenetration] Shield Penetration (nil): nil = generator default, [float] = absolute shield penetration percentage {weapon.shieldPenetration}\n"


function number_to_boolean(x)
	if x == 0 then
		return false
	else
		return true
	end
end

local Turret_Args = {}
local Weapon_Args = {}

-- Boolean_Arguments
Turret_Args["automatic"] = function(turret, target) turret.automatic=number_to_boolean(target) end
Turret_Args["coaxial"] = function(turret, target) turret.coaxial=number_to_boolean(target); turret.turningSpeed = 0.1 end
Turret_Args["simultaneous"] = function(turret, target) turret.simultaneousShooting=number_to_boolean(target) end

Weapon_Args["template"] = function(weapon, target) if number_to_boolean(target) then weapon.localPosition = vec3(0,0,0); weapon.shotCreationPosition = vec3(0,0,0) end end
Weapon_Args["beam"] = function(weapon, target) if number_to_boolean(target) then weapon.setBeam() end end
Weapon_Args["continuous"] = function(weapon, target) weapon.continuousBeam=number_to_boolean(target) end
Weapon_Args["deathexplosion"] = function(weapon, target) weapon.deathExplosion=number_to_boolean(target) end
Weapon_Args["impactexplosion"] = function(weapon, target) weapon.impactExplosion=number_to_boolean(target) end
Weapon_Args["projectile"] = function(weapon, target) if number_to_boolean(target) then weapon.setProjectile() end end
Weapon_Args["seeker"] = function(weapon, target) weapon.seeker=number_to_boolean(target) end
Weapon_Args["timeddeath"] = function(weapon, target) weapon.timedDeath=number_to_boolean(target) end

-- Enum_Arguments (NOT SUPPORTED ATM)
--[[Turret_Args["coolingtype"] Weapon Cooling Type (nil): nil = generator default, [levenshtein-matched string] = new cooling type. {turret.coolingType} -- CoolingType

Weapon_Args["damagetype"] Weapon Damage Type (nil): nil = generator default, [levenshtein-matched string] weapon damage type. {weapon.damageType} -- DamageType
Weapon_Args["salvagematerial"] Mining/Salvaging Material Grade (nil): nil = generator default, [levenshtein-matched string] salvaging/mining material. {weapon.smaterial} -- MaterialType
Weapon_Args["shape"] Weapon Projectile/Beam Shape (nil): nil = generator default, [levenshtein-matched string] projectile/beam shape type {weapon.pshape, weapon.bshape} -- ProjectileShape, BeamShape
]]

-- Int_Arguments
Turret_Args["crew"] = function(turret, target) local crew=Crew(); crew:add(math.max(math.floor(target), 0), CrewMan(CrewProfessionType.Gunner)); turret.crew=crew end
Turret_Args["turretsize"] = function(turret, target) turret.size=math.max(math.floor(target*2), 1)/2 end
Turret_Args["slots"] = function(turret, target) turret.slots=math.max(math.floor(target), 1) end
Turret_Args["barrels"] = function(turret, target) return nil end

Weapon_Args["blockpenetration"] = function(weapon, target) weapon.blockPenetration=math.floor(target) end
Weapon_Args["shots"] = function(weapon, target) weapon.shotsFired=math.max(math.floor(target), 1) end

-- Tuple_Arguments
Weapon_Args["color"] = function(weapon, target) local color = ColorRGB(target[1], target[2], target[3]); weapon.pcolor,weapon.binnerColor,weapon.bouterColor = color,color,color end

-- Multiplicator_Arguments
Turret_Args["baseenergy"] = function(turret, target) turret.baseEnergyPerSecond=turret.baseEnergyPerSecond*target end
Turret_Args["cooling"] = function(turret, target) turret.coolingRate=turret.coolingRate*target end
Turret_Args["energyincrease"] = function(turret, target) turret.energyIncreasePerSecond=turret.energyIncreasePerSecond*target end
Turret_Args["maxheat"] = function(turret, target) turret.maxHeat=turret.maxHeat*target end
Turret_Args["rotation"] = function(turret, target) turret.turningSpeed=turret.turningSpeed*target end
Turret_Args["shotheat"] = function(turret, target) turret.heatPerShot=turret.heatPerShot*target end

Weapon_Args["damage"] = function(weapon, target) weapon.damage=weapon.damage*target end
Weapon_Args["explosionradius"] = function(weapon, target) weapon.explosionRadius=weapon.explosionRadius*target end
Weapon_Args["firerate"] = function(weapon, target) weapon.fireRate=weapon.fireRate*target end
Weapon_Args["hullrepair"] = function(wepaon, target) wepaon.hullRepair=weapon.hullRepair*target end
Weapon_Args["otherforce"] = function(weapon, target) weapon.otherForce=weapon.otherForce*target end
Weapon_Args["projectilelife"] = function(weapon, target) weapon.pmaximumTime=weapon.pmaximumTime*target end
Weapon_Args["projectilevelocity"] = function(weapon, target) weapon.pvelocity=weapon.pvelocity*target end
Weapon_Args["range"] = function(weapon, target) weapon.reach=weapon.reach*tonumber(target) end
Weapon_Args["recoil"] = function(weapon, target) weapon.recoil=weapon.recoil*target end
Weapon_Args["selfforce"] = function(weapon, target) weapon.selfForce=weapon.selfForce*target end
Weapon_Args["shieldrepair"] = function(weapon, target) weapon.shieldRepair=weapon.shieldRepair*target end
Weapon_Args["projectilesize"] = function(weapon, target) if weapon.isBeam then weapon.bshapeSize,weapon.bwidth,weapon.blength,wepaon.bauraWidth=weapon.bshapeSize*target,weapon.bwidth*target,weapon.blength*target,weapon.bauraWidth*target else weapon.psize=weapon.psize*target end end

-- Absolute_Arguments
Weapon_Args["accuracy"] = function(weapon, target) weapon.accuracy=target end
Weapon_Args["efficiency"] = function(weapon, target) if weapon.stoneRefinedEfficiency and weapon.stoneRefinedEfficiency > 0 then weapon.stoneRefinedEfficiency=target end if weapon.metalRefinedEfficiency and weapon.metalRefinedEfficiency > 0 then weapon.metalRefinedEfficiency=target end if weapon.stoneRawEfficiency and weapon.stoneRawEfficiency > 0 then weapon.stoneRawEfficiency=target end if weapon.metalRawEfficiency and weapon.metalRawEfficiency > 0 then weapon.metalRawEfficiency=target end end
Weapon_Args["hulldamage"] = function(weapon, target) weapon.hullDamageMultiplicator=target end
Weapon_Args["shielddamage"] = function(weapon, target) weapon.shieldDamageMultiplicator=target end
Weapon_Args["stonedamage"] = function(weapon, target) weapon.stoneDamageMultiplicator=target end
Weapon_Args["shieldpenetration"] = function(weapon, target) weapon.shieldPenetration=target end

local scope_table = {}
scope_table["required"] = Required_Args
scope_table["optional"] = Optional_Args
scope_table["weapon"] = Weapon_Args
scope_table["turret"] = Turret_Args


-- Parses and returns the proper argument name, and input value
function parse_argument(arg)
	local list = arg:split("=")
	local argcmd = list[1]

	local min_dist = nil
	local min_argname = argcmd
	local scope = 'malformed'

	for tbl_scope,tbl in pairs(scope_table) do
		for argname,func in pairs(tbl) do
			local curr_dist = levenshtein(string.lower(argcmd), string.lower(argname))

			-- must be at least half the same to be a valid match
			if curr_dist <= string.len(argname) / 2 then
				if min_dist == nil or curr_dist < min_dist then
					min_dist = curr_dist
					min_argname = argname
					scope = tbl_scope
				end
			end
		end
	end

	local argval = try_catch_table(list, 2)
	if argval then
		local result, err = pcall(function() return transform_arg(min_argname, argval) end)
		if result then
			return min_argname, scope, transform_arg(min_argname, argval)
		else
			print("ERROR: " .. err)
			return min_argname, 'malformed', argval
		end
	else
		return min_argname, 'malformed', nil
	end
end


-- do the actual transformation once validated
function transform_arg(cmd, arg)
	for reqcmd,_ in pairs(Required_Args) do
		if cmd == reqcmd then
			return arg
		end
	end
	if cmd == 'color' then
		local rgb = arg:split(',')
		return {tonumber(rgb[1]), tonumber(rgb[2]), tonumber(rgb[3])}
	else
		return tonumber(arg)
	end
	return nil
end

function execute(sender, commandName, ...)
	local player = Player(sender)
	local args = {...}
	--[[local rest_command = ""
    for i,v in pairs(args) do
        rest_command = rest_command .. " " .. tostring(v)
    end]]
	player:sendChatMessage(player.name, 0, commandName .. " " .. format_args(args))

	local found_args = {}
	found_args["required"] = {}
	found_args["optional"] = {}
	found_args["malformed"] = {}
	found_args["weapon"] = {}
	found_args["turret"] = {}

	for _,arg in pairs(args) do
		local parsed_arg, scope, arg_value = parse_argument(arg)
		if parsed_arg == 'color' then
			print("Argument " .. parsed_arg .. ", scope " .. scope .. " has value " .. table_to_string(arg_value))
		else
			print("Argument " .. parsed_arg .. ", scope " .. scope .. " has value " .. arg_value)
		end
		found_args[scope][parsed_arg] = arg_value
	end
	if not table_empty(found_args["malformed"]) then
		player:sendChatMessage("CustomTurret", 0, "ERROR: Detected Malformed Arguments: \n" .. table_to_string(found_args["malformed"]))
	else
		local missing_required = {}
		for k,v in pairs(Required_Args) do
			if not try_catch_table(found_args["required"], k) then
				missing_required[k] = true
			end
		end
		if not table_empty(missing_required) then
			player:sendChatMessage("CustomTurret", 0, "ERROR: Missing Required Arguments: " .. table_key_to_string(missing_required) .. "\nOnly detected:\n " .. table_to_string(found_args["required"]))
		else
			local weapontype = found_args["required"]["type"]
			local rarity = found_args["required"]["rarity"]
			local material = found_args["required"]["material"]
			local tech = try_catch_table(found_args["optional"], 'tech')
			local amount = tonumber(try_catch_table(found_args["optional"], 'amount') or 1)

			local weapon_id = getWeapon(weapontype)
			if weapon_id then
				local rarity_ent = getRarity(rarity)
				if rarity_ent then
					local material_ent = getMaterial(material)
					if material_ent then
						if tonumber(amount) then
							randomized = try_catch_table(found_args["optional"], 'mode') == 1 or false
							if randomized then
								for i=1,amount do
									local tech = math.max(1, tonumber(tech) or 6)
									local dps = Balancing_TechWeaponDPS(tech)

									-- generate turret template
									local rand = random()
									local seed = rand:createSeed()
									local item = TurretGenerator.generateSeeded(seed, weapon_id, dps, tech, rarity_ent, material_ent)
									for cmd,target in pairs(found_args["turret"]) do
										Turret_Args[cmd](item, target)
									end

									local weapons = {item:getWeapons()}
									local numWeapons = item.numWeapons
									local barrels = try_catch_table(found_args['turret'], 'barrels')
									if barrels then
										numWeapons = barrels
									end
									item:clearWeapons()
									TurretGenerator.attachWeapons(rand, item, weapons[1], numWeapons)

									weapons = {item:getWeapons()}
									item:clearWeapons()
									for _,weapon in pairs(weapons) do
										for cmd,target in pairs(found_args["weapon"]) do
											Weapon_Args[cmd](weapon, target)
										end
										if not weapon.continuousBeam then
											weapon.localPosition = vec3(0, 0, 0)
										end
										item:addWeapon(weapon)
									end

									item:updateStaticStats()
									
									-- Add the stuff to the inventory
									addItems(player, InventoryTurret(item), 1)
									player:sendChatMessage("CustomTurret", 0, "Variant #" .. tostring(i) .. ": " .. rarity_ent.name .. " " .. material_ent.name .. " Tech-" .. tostring(tech) .. string.format(" %s added.", weapon_types[weapon_id]))
								end
							else
								local tech = math.max(1, tonumber(tech) or 6)
								local dps = Balancing_TechWeaponDPS(tech)

								-- generate turret template
								local rand = random()
								local seed = rand:createSeed()
								local item = TurretGenerator.generateSeeded(seed, weapon_id, dps, tech, rarity_ent, material_ent)
								for cmd,target in pairs(found_args["turret"]) do
									Turret_Args[cmd](item, target)
								end

								local weapons = {item:getWeapons()}
								local numWeapons = item.numWeapons
								local barrels = try_catch_table(found_args['turret'], 'barrels')
								if barrels then
									numWeapons = barrels
								end
								item:clearWeapons()
								TurretGenerator.attachWeapons(rand, item, weapons[1], numWeapons)

								weapons = {item:getWeapons()}
								item:clearWeapons()
								for _,weapon in pairs(weapons) do
									for cmd,target in pairs(found_args["weapon"]) do
										Weapon_Args[cmd](weapon, target)
									end
									if not weapon.continuousBeam then
										weapon.localPosition = vec3(0, 0, 0)
									end
									item:addWeapon(weapon)
								end

								item:updateStaticStats()

								-- Add the stuff to the inventory
								addItems(player, InventoryTurret(item), amount)
								player:sendChatMessage("CustomTurret", 0, amount .. ": " .. rarity_ent.name .. " " .. material_ent.name .. " Tech-" .. tostring(tech) .. string.format(" %s added.", weapon_types[weapon_id]))
							end
						else
							player:sendChatMessage("CustomTurret", 0, "ERROR: " .. amount .. " not a number")
						end
					else
						player:sendChatMessage("CustomTurret", 0, "ERROR: " .. material .. " not recognized material")
					end
				else
					player:sendChatMessage("CustomTurret", 0, "ERROR: " .. rarity .. " not recognized rarity")
				end
			else
				player:sendChatMessage("CustomTurret", 0, "ERROR: " .. weapontype .. " not recognized weapon type")
			end
		end
	end
	return 0, "", ""
end

function getDescription()
	return "Use this command for building highly customized turrets"
end

function getHelp()
	return description_string
end
