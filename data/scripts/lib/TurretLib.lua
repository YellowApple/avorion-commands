
local TurretLib = {
	MetaParametersTable = nil,
	WriteParametersTable = nil,
	ReadParametersTable = nil,
	ParameterConversionTable = nil
}

package.path = package.path .. ";data/scripts/lib/?.lua"
include ("stringutility")
include ("tableutility")
include ("rarities")
include ("materials")
include ("upgrades")

include ("common")
include ("galaxy")
include ("randomext")

include ("weapontype")
TurretGenerator = include("turretgenerator")

----------------- Write Vals Function Table ------------------------------------
	local Turret_Args = {}
	local Weapon_Args = {}

	-- Boolean_Arguments
	Turret_Args["automatic"] = function(turret, target) turret.automatic=target end
	Turret_Args["coaxial"] = function(turret, target) turret.coaxial=target; if turret.turningSpeed <= 0 then turret.turningSpeed = 0.1 end end
	Turret_Args["simultaneous"] = function(turret, target) turret.simultaneousShooting=target end

	Weapon_Args["template"] = function(weapon, target) end
	Weapon_Args["beam"] = function(weapon, target) end
	Weapon_Args["continuous"] = function(weapon, target) end -- weapon.continuousBeam=target
	Weapon_Args["deathexplosion"] = function(weapon, target) weapon.deathExplosion=target end
	Weapon_Args["impactexplosion"] = function(weapon, target) weapon.impactExplosion=target end
	Weapon_Args["projectile"] = function(weapon, target) end
	Weapon_Args["seeker"] = function(weapon, target) weapon.seeker=target end
	Weapon_Args["timeddeath"] = function(weapon, target) weapon.timedDeath=target end

	-- Enum_Arguments (NOT SUPPORTED ATM)
	Turret_Args["coolingtype"] = function(turret, target) turret.coolingType=target end
	Weapon_Args["damagetype"] = function(weapon, target) weapon.damageType=target end
	Weapon_Args["beamshape"] = function(weapon, target) weapon.bshape=target end
	Weapon_Args["projshape"] = function(weapon, target) weapon.pshape=target end

	-- Int_Arguments
	Turret_Args["crew"] = function(turret, target) local crew=Crew(); crew:add(math.max(math.floor(target), 0), CrewMan(CrewProfessionType.Gunner)); turret.crew=crew end
	Turret_Args["turretsize"] = function(turret, target) turret.size=math.max(math.floor(target*2), 1)/2 end
	Turret_Args["slots"] = function(turret, target) turret.slots=math.max(math.floor(target), 1) end
	Turret_Args["barrels"] = function(turret, target) end

	Weapon_Args["blockpenetration"] = function(weapon, target) weapon.blockPenetration=math.floor(target) end
	Weapon_Args["shots"] = function(weapon, target) weapon.shotsFired=math.max(math.floor(target), 1) end

	-- Tuple_Arguments
	Weapon_Args["color"] = function(weapon, target) weapon.pcolor,weapon.binnerColor,weapon.bouterColor = target, target, target end

	-- Multiplicator_Arguments
	Turret_Args["baseenergy"] = function(turret, target) turret.baseEnergyPerSecond=target end
	Turret_Args["cooling"] = function(turret, target) turret.coolingRate=target end
	Turret_Args["energyincrease"] = function(turret, target) turret.energyIncreasePerSecond=target end
	Turret_Args["maxheat"] = function(turret, target) turret.maxHeat=target end
	Turret_Args["rotation"] = function(turret, target) turret.turningSpeed=target end
	Turret_Args["shotheat"] = function(turret, target) turret.heatPerShot=target end

	Weapon_Args["damage"] = function(weapon, target) weapon.damage=target end
	Weapon_Args["explosionradius"] = function(weapon, target) weapon.explosionRadius=target end
	Weapon_Args["firerate"] = function(weapon, target) weapon.fireRate=target end
	Weapon_Args["hullrepair"] = function(wepaon, target) wepaon.hullRepair=target end
	Weapon_Args["otherforce"] = function(weapon, target) weapon.otherForce=target end
	Weapon_Args["projectilelife"] = function(weapon, target) weapon.pmaximumTime=target end
	Weapon_Args["projectilevelocity"] = function(weapon, target) weapon.pvelocity=target end
	Weapon_Args["range"] = function(weapon, target) weapon.reach=target end
	Weapon_Args["recoil"] = function(weapon, target) weapon.recoil=target end
	Weapon_Args["selfforce"] = function(weapon, target) weapon.selfForce=target end
	Weapon_Args["shieldrepair"] = function(weapon, target) weapon.shieldRepair=target end
	Weapon_Args["projectilesize"] = function(weapon, target) weapon.psize=target end
	Weapon_Args["beamscale"] = function(weapon, target) weapon.bshapeSize,weapon.bwidth,weapon.blength,weapon.bauraWidth = weapon.bshapeSize*target,weapon.bwidth*target,weapon.blength*target,weapon.bauraWidth*target end

	-- Absolute_Arguments
	Weapon_Args["accuracy"] = function(weapon, target) weapon.accuracy=target end
	Weapon_Args["efficiency"] = function(weapon, target) if weapon.stoneRefinedEfficiency and weapon.stoneRefinedEfficiency > 0 then weapon.stoneRefinedEfficiency=target end if weapon.metalRefinedEfficiency and weapon.metalRefinedEfficiency > 0 then weapon.metalRefinedEfficiency=target end if weapon.stoneRawEfficiency and weapon.stoneRawEfficiency > 0 then weapon.stoneRawEfficiency=target end if weapon.metalRawEfficiency and weapon.metalRawEfficiency > 0 then weapon.metalRawEfficiency=target end end
	Weapon_Args["hulldamage"] = function(weapon, target) weapon.hullDamageMultiplicator=target end
	Weapon_Args["shielddamage"] = function(weapon, target) weapon.shieldDamageMultiplicator=target end
	Weapon_Args["stonedamage"] = function(weapon, target) weapon.stoneDamageMultiplicator=target end
	Weapon_Args["shieldpenetration"] = function(weapon, target) weapon.shieldPenetration=target end

	TurretLib.WriteParametersTable = {}
	TurretLib.WriteParametersTable["Weapon"] = Weapon_Args
	TurretLib.WriteParametersTable["Turret"] = Turret_Args

------------------ Read Vals Function Table ------------------------------------
	local Read_Turret_Args = {}
	local Read_Weapon_Args = {}
	-- Boolean_Arguments
	Read_Turret_Args["automatic"] = function(turret) return turret.automatic end
	Read_Turret_Args["coaxial"] = function(turret) return turret.coaxial end
	Read_Turret_Args["simultaneous"] = function(turret) return turret.simultaneousShooting end

	Read_Weapon_Args["template"] = function(weapon) return nil end
	Read_Weapon_Args["beam"] = function(weapon) return weapon.isBeam end
	Read_Weapon_Args["continuous"] = function(weapon) return weapon.continuousBeam end
	Read_Weapon_Args["deathexplosion"] = function(weapon) return weapon.deathExplosion end
	Read_Weapon_Args["impactexplosion"] = function(weapon) return weapon.impactExplosion end
	Read_Weapon_Args["projectile"] = function(weapon) return not weapon.isBeam end
	Read_Weapon_Args["seeker"] = function(weapon) return weapon.seeker end
	Read_Weapon_Args["timeddeath"] = function(weapon) return weapon.timedDeath end


	Read_Turret_Args["coolingtype"] = function(turret) return turret.coolingType end
	Read_Weapon_Args["damagetype"] = function(weapon) return weapon.damageType end
	Read_Weapon_Args["beamshape"] = function(weapon) return weapon.bshape end
	Read_Weapon_Args["projshape"] = function(weapon) return weapon.pshape end

	-- Int_Arguments
	Read_Turret_Args["crew"] = function(turret) return turret.crew.gunners end
	Read_Turret_Args["turretsize"] = function(turret) return turret.size end
	Read_Turret_Args["slots"] = function(turret) return turret.slots end
	Read_Turret_Args["barrels"] = function(turret) return turret.numWeapons end

	Read_Weapon_Args["blockpenetration"] = function(weapon) return weapon.blockPenetration end
	Read_Weapon_Args["shots"] = function(weapon) return weapon.shotsFired end

	-- Tuple_Arguments
	Read_Weapon_Args["color"] = function(weapon) if weapon.isBeam then return weapon.binnerColor else return weapon.pcolor end end

	-- Multiplicator_Arguments
	Read_Turret_Args["baseenergy"] = function(turret) return turret.baseEnergyPerSecond end
	Read_Turret_Args["cooling"] = function(turret) return turret.coolingRate end
	Read_Turret_Args["energyincrease"] = function(turret) return turret.energyIncreasePerSecond end
	Read_Turret_Args["maxheat"] = function(turret) return turret.maxHeat end
	Read_Turret_Args["rotation"] = function(turret) return turret.turningSpeed end
	Read_Turret_Args["shotheat"] = function(turret) return turret.heatPerShot end

	Read_Weapon_Args["damage"] = function(weapon) return weapon.damage end
	Read_Weapon_Args["explosionradius"] = function(weapon) return weapon.explosionRadius end
	Read_Weapon_Args["firerate"] = function(weapon) return weapon.fireRate end
	Read_Weapon_Args["hullrepair"] = function(wepaon) return wepaon.hullRepair end
	Read_Weapon_Args["otherforce"] = function(weapon) return weapon.otherForce end
	Read_Weapon_Args["projectilelife"] = function(weapon) return weapon.pmaximumTime end
	Read_Weapon_Args["projectilevelocity"] = function(weapon) return weapon.pvelocity end
	Read_Weapon_Args["range"] = function(weapon) return weapon.reach end
	Read_Weapon_Args["recoil"] = function(weapon) return weapon.recoil end
	Read_Weapon_Args["selfforce"] = function(weapon) return weapon.selfForce end
	Read_Weapon_Args["shieldrepair"] = function(weapon) return weapon.shieldRepair end
	Read_Weapon_Args["projectilesize"] = function(weapon) return weapon.psize end
	Read_Weapon_Args["beamscale"] = function(weapon) return 1 end

	-- Absolute_Arguments
	Read_Weapon_Args["accuracy"] = function(weapon) return weapon.accuracy end
	Read_Weapon_Args["efficiency"] = function(weapon) if weapon.stoneRefinedEfficiency and weapon.stoneRefinedEfficiency > 0 then return weapon.stoneRefinedEfficiency end if weapon.metalRefinedEfficiency and weapon.metalRefinedEfficiency > 0 then return weapon.metalRefinedEfficiency end if weapon.stoneRawEfficiency and weapon.stoneRawEfficiency > 0 then return weapon.stoneRawEfficiency end if weapon.metalRawEfficiency and weapon.metalRawEfficiency > 0 then return weapon.metalRawEfficiency end end
	Read_Weapon_Args["hulldamage"] = function(weapon) return weapon.hullDamageMultiplicator end
	Read_Weapon_Args["shielddamage"] = function(weapon) return weapon.shieldDamageMultiplicator end
	Read_Weapon_Args["stonedamage"] = function(weapon) return weapon.stoneDamageMultiplicator end
	Read_Weapon_Args["shieldpenetration"] = function(weapon) return weapon.shieldPenetration end

	TurretLib.ReadParametersTable = {}
	TurretLib.ReadParametersTable["Weapon"] = Read_Weapon_Args
	TurretLib.ReadParametersTable["Turret"] = Read_Turret_Args

------------------ Meta-Params Function Table ----------------------------------
	TurretLib.MetaParametersTable = {}

	-- Boolean_Arguments
	TurretLib.MetaParametersTable["automatic"] = "Turret"
	TurretLib.MetaParametersTable["coaxial"] = "Turret"
	TurretLib.MetaParametersTable["simultaneous"] = "Turret"

	TurretLib.MetaParametersTable["template"] = "Weapon"
	TurretLib.MetaParametersTable["beam"] = "Weapon"
	TurretLib.MetaParametersTable["continuous"] = "Weapon"
	TurretLib.MetaParametersTable["deathexplosion"] = "Weapon"
	TurretLib.MetaParametersTable["impactexplosion"] = "Weapon"
	TurretLib.MetaParametersTable["projectile"] = "Weapon"
	TurretLib.MetaParametersTable["seeker"] = "Weapon"
	TurretLib.MetaParametersTable["timeddeath"] = "Weapon"


	TurretLib.MetaParametersTable["coolingtype"] = "Turret"
	TurretLib.MetaParametersTable["damagetype"] = "Weapon"
	TurretLib.MetaParametersTable["beamshape"] = "Weapon"
	TurretLib.MetaParametersTable["projshape"] = "Weapon"

	-- Int_Arguments
	TurretLib.MetaParametersTable["crew"] = "Turret"
	TurretLib.MetaParametersTable["turretsize"] = "Turret"
	TurretLib.MetaParametersTable["slots"] = "Turret"
	TurretLib.MetaParametersTable["barrels"] = "Turret"

	TurretLib.MetaParametersTable["blockpenetration"] = "Weapon"
	TurretLib.MetaParametersTable["shots"] = "Weapon"

	-- Tuple_Arguments
	TurretLib.MetaParametersTable["color"] = "Weapon"

	-- Multiplicator_Arguments
	TurretLib.MetaParametersTable["baseenergy"] = "Turret"
	TurretLib.MetaParametersTable["cooling"] = "Turret"
	TurretLib.MetaParametersTable["energyincrease"] = "Turret"
	TurretLib.MetaParametersTable["maxheat"] = "Turret"
	TurretLib.MetaParametersTable["rotation"] = "Turret"
	TurretLib.MetaParametersTable["shotheat"] = "Turret"

	TurretLib.MetaParametersTable["damage"] = "Weapon"
	TurretLib.MetaParametersTable["explosionradius"] = "Weapon"
	TurretLib.MetaParametersTable["firerate"] = "Weapon"
	TurretLib.MetaParametersTable["hullrepair"] = "Weapon"
	TurretLib.MetaParametersTable["otherforce"] = "Weapon"
	TurretLib.MetaParametersTable["projectilelife"] = "Weapon"
	TurretLib.MetaParametersTable["projectilevelocity"] = "Weapon"
	TurretLib.MetaParametersTable["range"] = "Weapon"
	TurretLib.MetaParametersTable["recoil"] = "Weapon"
	TurretLib.MetaParametersTable["selfforce"] = "Weapon"
	TurretLib.MetaParametersTable["shieldrepair"] = "Weapon"
	TurretLib.MetaParametersTable["projectilesize"] = "Weapon"
	TurretLib.MetaParametersTable["beamscale"] = "Weapon"

	-- Absolute_Arguments
	TurretLib.MetaParametersTable["accuracy"] = "Weapon"
	TurretLib.MetaParametersTable["efficiency"] = "Weapon"
	TurretLib.MetaParametersTable["hulldamage"] = "Weapon"
	TurretLib.MetaParametersTable["shielddamage"] = "Weapon"
	TurretLib.MetaParametersTable["stonedamage"] = "Weapon"
	TurretLib.MetaParametersTable["shieldpenetration"] = "Weapon"

--------------------- Parameter Conversion Table -------------------------------
	function ConvertColor(Win, modname, data)
		if data then
			Win.ModsUIElems[modname]["hueslider"]:setValueNoCallback(data.hue)
			Win.ModsUIElems[modname]["satslider"]:setValueNoCallback(data.saturation)
			Win.ModsUIElems[modname]["valslider"]:setValueNoCallback(data.value)
		else
			Win.ModsUIElems[modname]["hueslider"]:setValueNoCallback(0)
			Win.ModsUIElems[modname]["satslider"]:setValueNoCallback(0)
			Win.ModsUIElems[modname]["valslider"]:setValueNoCallback(0)
		end
	end

	function ConvertComboBox(Win, modname, data)
		local map = Win.ComboEnumMapping[modname]
		-- maps combobox index ==> enum id
		local indexmap = Win.ComboEnumMapping['indexmap'][modname]
		local index = 0

		if data then
			for ind,id in pairs(indexmap) do
				if id == data then
					index = ind
				end
			end
		end
		Win.ModsUIElems[modname]["combobox"]:setSelectedIndexNoCallback(index)
		return
	end

	function ConvertCheckBox(Win, modname, data)
		if data then
			Win.ModsUIElems[modname]["checkbox"]:setCheckedNoCallback(data)
		else
			Win.ModsUIElems[modname]["checkbox"]:setCheckedNoCallback(false)
		end
	end

	function ConvertTextBox(Win, modname, data)
		if data then
			Win.ModsUIElems[modname]["textbox"].text = tostring(data)
		else
			Win.ModsUIElems[modname]["textbox"].text = ""
		end
	end

	function ConvertPlusMinus(Win, modname, data)
		if data then
			Win.ModsUIElems[modname]["var"].caption = tostring(data)
		else
			Win.ModsUIElems[modname]["var"].caption = "----"
		end
	end


	TurretLib.ParameterConversionTable = {}

	-- Booleans
	TurretLib.ParameterConversionTable["automatic"] = ConvertCheckBox
	TurretLib.ParameterConversionTable["coaxial"] = ConvertCheckBox
	TurretLib.ParameterConversionTable["simultaneous"] = ConvertCheckBox

	TurretLib.ParameterConversionTable["beam"] = ConvertCheckBox
	TurretLib.ParameterConversionTable["continuous"] = ConvertCheckBox
	TurretLib.ParameterConversionTable["deathexplosion"] = ConvertCheckBox
	TurretLib.ParameterConversionTable["impactexplosion"] = ConvertCheckBox
	TurretLib.ParameterConversionTable["projectile"] = ConvertCheckBox
	TurretLib.ParameterConversionTable["seeker"] = ConvertCheckBox
	TurretLib.ParameterConversionTable["timeddeath"] = ConvertCheckBox


	TurretLib.ParameterConversionTable["coolingtype"] = ConvertComboBox
	TurretLib.ParameterConversionTable["damagetype"] = ConvertComboBox
	TurretLib.ParameterConversionTable["beamshape"] = ConvertComboBox
	TurretLib.ParameterConversionTable["projshape"] = ConvertComboBox

	-- Int_Arguments
	TurretLib.ParameterConversionTable["crew"] = ConvertPlusMinus
	TurretLib.ParameterConversionTable["turretsize"] = ConvertPlusMinus
	TurretLib.ParameterConversionTable["slots"] = ConvertPlusMinus
	TurretLib.ParameterConversionTable["barrels"] = ConvertPlusMinus

	TurretLib.ParameterConversionTable["blockpenetration"] = ConvertPlusMinus
	TurretLib.ParameterConversionTable["shots"] = ConvertPlusMinus

	-- Tuple_Arguments
	TurretLib.ParameterConversionTable["color"] = ConvertColor

	-- Multiplicator_Arguments
	TurretLib.ParameterConversionTable["baseenergy"] = ConvertTextBox
	TurretLib.ParameterConversionTable["cooling"] = ConvertTextBox
	TurretLib.ParameterConversionTable["energyincrease"] = ConvertTextBox
	TurretLib.ParameterConversionTable["maxheat"] = ConvertTextBox
	TurretLib.ParameterConversionTable["rotation"] = ConvertTextBox
	TurretLib.ParameterConversionTable["shotheat"] = ConvertTextBox

	TurretLib.ParameterConversionTable["damage"] = ConvertTextBox
	TurretLib.ParameterConversionTable["explosionradius"] = ConvertTextBox
	TurretLib.ParameterConversionTable["firerate"] = ConvertTextBox
	TurretLib.ParameterConversionTable["hullrepair"] = ConvertTextBox
	TurretLib.ParameterConversionTable["otherforce"] = ConvertTextBox
	TurretLib.ParameterConversionTable["projectilelife"] = ConvertTextBox
	TurretLib.ParameterConversionTable["projectilevelocity"] = ConvertTextBox
	TurretLib.ParameterConversionTable["range"] = ConvertTextBox
	TurretLib.ParameterConversionTable["recoil"] = ConvertTextBox
	TurretLib.ParameterConversionTable["selfforce"] = ConvertTextBox
	TurretLib.ParameterConversionTable["shieldrepair"] = ConvertTextBox
	TurretLib.ParameterConversionTable["projectilesize"] = ConvertTextBox
	-- missing: beam size (weapon.bshapeSize, weapon.bwidth, weapon.blength, wepaon.bauraWidth = target, target, target, target

	-- Absolute_Arguments
	TurretLib.ParameterConversionTable["accuracy"] = ConvertTextBox
	TurretLib.ParameterConversionTable["efficiency"] = ConvertTextBox
	TurretLib.ParameterConversionTable["hulldamage"] = ConvertTextBox
	TurretLib.ParameterConversionTable["shielddamage"] = ConvertTextBox
	TurretLib.ParameterConversionTable["stonedamage"] = ConvertTextBox
	TurretLib.ParameterConversionTable["shieldpenetration"] = ConvertTextBox

--------------------------------------------------------------------------------
function TurretLib:GenerateTooltips(table)
	return
end

return TurretLib