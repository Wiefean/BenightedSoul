--EID

local mod = Isaac_BenightedSoul
local IBS_Player = mod.IBS_Player
local IBS_Pocket = mod.IBS_Pocket

----加载图标----

do --角色
	local player_spr = Sprite()
	player_spr:Load("ibsEIDicons/players.anm2", true)
	EID:addIcon("Player"..(IBS_Player.bisaac), "player", 0, 32, 32, 5, 5, player_spr)
	EID:addIcon("Player"..(IBS_Player.bmaggy), "player", 1, 32, 32, 5, 5, player_spr)
end

--铜锌合金骰
do
	local spr = Sprite()
	spr:Load("ibsEIDicons/pickups.anm2", true)
	EID:addIcon("Card"..(IBS_Pocket.czd6), "object", 0, 8, 8, 7, 7, spr)
end

---------------


--加载介绍
include("ibs_scripts.compats.EID.Chinese")
include("ibs_scripts.compats.EID.English")