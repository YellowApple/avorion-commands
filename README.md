AVORION COMMANDS

LICENSE: MIT

Original Author: Aki @ https://github.com/nthirtyone
Contributers: Chip Patton, k7755g, NovaBreaker, Vweegit, CaptPatrick01

---------- ABOUT ----------

This package contains commands for use of server administrators and general use of players.
All commands are meant to be server-side only to avoid incompatibility with clients and make
it easier to install and use on servers.

-------- COMMANDS ---------

- /crew
Adds or removes crew to currently boarded ship. Usage:
- /crew help or /crew for help
- /crew add <profession> [rank] [level] [amount]
- /crew fill
- /crew clear

- /inventory also: /inv
Modifies inventory of a player. Usage:
- /inventory turret <type> [rarity] [material] [tech] [amount]
- /inventory upgrade <script> [rarity] [amount]

- /price
Prints price of currently boarded ship. Usage: /price

- /sethome
Allows player to change home sector to current if friendly or own station is present. Usage: /sethome

- /whereis
Gets the position of a player. Usage: /whereis <name>

- /list
Lists possible variables for /inventory or /crew. Usage: 
- /list <type>
- /list help or /list for help.

- /agoods
Adds goods to currently boarded ship. Usage:
- /agoods <good name> <quantity>

Must capitalize all names
Must replace spaces with _(underscore)
Can not add more then your hold can handle

- /agood Steel 100
- /agood Steel_Tube 10

- /fighter
Adds a fighter to the payers hanger. Usage:
- /fighter add <weapons> [rarity] [material] [tech]

---------- FILES ----------

scripts/
├───commands/
│       crew.lua
│       inv.lua
│       inventory.lua
│       list.lua
│       price.lua
│       sethome.lua
│       whereis.lua
│       agoods.lua
│       fighter.lua
│
├───lib/cmd/
│       common.lua
│       materials.lua
│       professions.lua
│       ranks.lua
│       rarities.lua
│       upgrades.lua
│       weapons.lua
│
└───player/cmd/
        crew.lua
        price.lua
        sethome.lua
        tellposition.lua
        whereis.lua
        agoods.lua
        fighter.lua

------ INSTALLATION ------ 
You can download current package from GitHub: download link.
Once you have downloaded and unpacked, move scripts/ directory into your <Avorion>/mods/ directory.

If you plan to host a public server with some of these commands available for players/moderators/other groups, you will need to configure admin.xml located in your galaxy root directory.

If you want you can clone it into <Avorion>/mods. and then use git for updating.
