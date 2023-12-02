--抹大拉的伪忆

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Pocket = mod.IBS_Pocket
local Ents = mod.IBS_Lib.Ents
local Stats = mod.IBS_Lib.Stats

local sfx = SFXManager()

--装扮
local Costume = Isaac.GetCostumeIdByPath("gfx/ibs/characters/falsehood_bmaggy.anm2")

--临时数据
local function GetFalsehoodData(player)
	local data = Ents:GetTempData(player)
	data.FALSEHOOD_BMAGGY = data.FALSEHOOD_BMAGGY or {TimeOut = 1}
	
	return data.FALSEHOOD_BMAGGY
end

--使用
local function OnUse(_,card, player, flag)
	local data = GetFalsehoodData(player)
	data.TimeOut = data.TimeOut + 420
	player:SetMinDamageCooldown(480)
	player:AddNullCostume(Costume)
	player:AddCacheFlags(CacheFlag.CACHE_SPEED)
	player:EvaluateItems()
	
	local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position, Vector.Zero, player)				
	poof.SpriteScale = Vector(1.5,1.5)
	poof.Color = Color(0.5,0.5,0.5)
	sfx:Play(SoundEffect.SOUND_BLACK_POOF, 4)	
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, OnUse, IBS_Pocket.falsehood_bmaggy)

--生成震荡波和圣光
local function OnUpdate(_,player)
	local data = Ents:GetTempData(player).FALSEHOOD_BMAGGY
	
	if data then
		if data.TimeOut > 0 then
			data.TimeOut = data.TimeOut - 1
			
			if player.FrameCount % 7 == 0 then
				local light = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, player.Position, Vector.Zero, player)
				light.SpriteScale = Vector(1.5,1.5)
				
				for _,target in pairs(Isaac.FindInRadius(player.Position, 80, EntityPartition.ENEMY)) do
					if Ents:IsEnemy(target) then
						target:TakeDamage(math.max(14, player.Damage * 3), 0, EntityRef(player), 1)
					end
				end
				
				local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, player.Position, Vector.Zero, player):ToEffect()
				wave.Parent = player
				wave:SetTimeout(14)
				wave:SetRadii(0,49)
				Game():ShakeScreen(2)
				
				player:AddCacheFlags(CacheFlag.CACHE_SPEED)
				player:EvaluateItems()
			end
		else
			Ents:GetTempData(player).FALSEHOOD_BMAGGY = nil
			player:TryRemoveNullCostume(Costume)	
			player:AddCacheFlags(CacheFlag.CACHE_SPEED)
			player:EvaluateItems()			
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnUpdate, 0)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_,player, flag)
	local data = Ents:GetTempData(player).FALSEHOOD_BMAGGY

	if data and (data.TimeOut > 0) then
		if flag == CacheFlag.CACHE_SPEED then
			Stats:Speed(player, 0.7)
		end
	end	
end)