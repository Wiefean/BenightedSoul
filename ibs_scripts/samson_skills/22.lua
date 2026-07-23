--参孙技能
--审判

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(22, {
	CalmCost = 6,
	WrathCost = 6,
})

--平静使用
Skill.CalmOnUse = function(player, compats)
	local room = Game():GetRoom()
	local rng = player:GetCardRNG(22)
	for i = 1,5 do
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
		Isaac.Spawn(5, 300, rng:RandomInt(1,21), pos, Vector.Zero, nil)
	end
	sfx:Play(268)
end

--暴怒使用
Skill.WrathOnUse = function(player, compats)
	local room = Game():GetRoom()
	local rng = player:GetCardRNG(22)
	for i = 1,5 do
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
		Isaac.Spawn(5, 300, rng:RandomInt(1,21), pos, Vector.Zero, nil)
	end
	sfx:Play(268)
end

return Skill