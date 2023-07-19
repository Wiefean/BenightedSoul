--钻石(dia-moon-d)

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local IBS_Sound = mod.IBS_Sound
local Ents = mod.IBS_Lib.Ents
local Maths = mod.IBS_Lib.Maths
local Stats = mod.IBS_Lib.Stats

local sfx = SFXManager()

--眼泪特效
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_,tear)
    local ent = tear.SpawnerEntity
	local player = (ent and ent:ToPlayer())
	
    if player and player:HasCollectible(IBS_Item.diamoond) then
		local rng = player:GetCollectibleRNG(IBS_Item.diamoond)
		local chance = rng:RandomInt(99) + 1
		local chance2 = rng:RandomInt(99) + 1

		if chance <= 33 then
			tear:ChangeVariant(18)
			tear:AddTearFlags(TearFlags.TEAR_BURN)
			tear:SetColor(Color(1,0.8,0,1,0.3,0,0),-1,0, false, true)
			tear:Update()
		end
		if chance2 <= 33 then
			local color = Color(1,1,1)
			color:SetColorize(1,1,1,1)
			tear:ChangeVariant(18)
			tear:AddTearFlags(TearFlags.TEAR_SLOW)
			tear:SetColor(color,-1,0, false, true)
			tear:Update()		
		end
    end
end)

--冰冻判定
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_,target, dmg)
	if target:IsEnemy() and target:IsVulnerableEnemy() and not target:IsBoss() then
		for i = 0, Game():GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(IBS_Item.diamoond) then
				if target:HasEntityFlags(EntityFlag.FLAG_SLOW) and target:HasEntityFlags(EntityFlag.FLAG_BURN) then 
					target:AddEntityFlags(EntityFlag.FLAG_ICE)
					target.HitPoints = 0
				end
			end	
		end
	end
end)

--概率替换小石头或煤块
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_,type, variant, subtype, pos, velocity, spawner, seed)
	if IBS_Data.Setting["bmaggy"]["Beast"] then
		if (type == 5) and (variant == 100) and (subtype == 90 or subtype == 132) and not spawner then
			for i = 0, Game():GetNumPlayers() -1 do
				local player = Isaac.GetPlayer(i)
				local rng = player:GetCollectibleRNG(IBS_Item.diamoond)

				if rng:RandomInt(99)+1 <= 6 then
					return {5, 100, IBS_Item.diamoond, seed}
				end
			end
		end
	end	
end)

