-- Short alias for inventory command.
package.path = package.path .. ";data/scripts/commands/?.lua"
include ("inventory")

function getDescription()
	return "Alias for /inventory."
end