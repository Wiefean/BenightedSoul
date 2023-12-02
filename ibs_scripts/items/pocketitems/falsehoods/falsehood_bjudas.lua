--犹大的伪忆

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Pocket = mod.IBS_Pocket
local IBS_Sound = mod.IBS_Sound
local Ents = mod.IBS_Lib.Ents
local Maths = mod.IBS_Lib.Maths
local Players = mod.IBS_Lib.Players

local sfx = SFXManager()

--临时玩家数据
local function GetFalsehoodData(player)
	local data = Ents:GetTempData(player)
	data.FALSEHOOD_BJUDAS = data.FALSEHOOD_BJUDAS or {
		TimeOut = 1,
		Mimic = false
	}
	
	return data.FALSEHOOD_BJUDAS
end

--临时眼泪数据
local function GetTearData(tear)
	local data = Ents:GetTempData(tear)
	data.FALSEHOOD_BJUDAS_TEAR = data.FALSEHOOD_BJUDAS_TEAR or {Bonus = true}
	
	return data.FALSEHOOD_BJUDAS_TEAR
end

--使用
local function OnUse(_,card, player, flag)
	local data = GetFalsehoodData(player)
	data.TimeOut = data.TimeOut + 180
	Game():Darken(1, 100)
	sfx:Play(IBS_Sound.falsehood_bjudas_ready)
	
	if (flag & UseFlag.USE_MIMIC > 0) then	
		data.Mimic = true
	else
		data.Mimic = false
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, OnUse, IBS_Pocket.falsehood_bjudas)


--发射
local function OnUpdate(_,player)
	local data = Ents:GetTempData(player).FALSEHOOD_BJUDAS
	
	if data then
		if data.TimeOut > 0 then
			if (player:GetFireDirection() ~= Direction.NO_DIRECTION) then
				local dir = Players:GetAimingVector(player)
				local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BALLOON, 0, player.Position, dir*36, player):ToTear()
				GetTearData(tear).Bonus = (not data.Mimic)
				tear.CollisionDamage = math.max(26, 6.7*(player.Damage))
				tear.Color = Color(0.6,0.6,0.6,1,0.8,0.8,0.8)
				tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING | TearFlags.TEAR_BURN)
				tear:Update()
				
				sfx:Play(SoundEffect.SOUND_GFUEL_GUNSHOT_SPREAD, 2, 2, false, 0.9)
				Game():ShakeScreen(7)
				data.TimeOut = 0
			end
			data.TimeOut = data.TimeOut - 1
		else
			Ents:GetTempData(player).FALSEHOOD_BJUDAS = nil	
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnUpdate, 0)

--命中判定
local function OnCollision(_,tear, other)
	local data = Ents:GetTempData(tear).FALSEHOOD_BJUDAS_TEAR
	
	if data and Ents:IsEnemy(other, true) then
		local player = Ents:IsSpawnerPlayer(tear)
		if player and data.Bonus then
			data.Bonus = false
			player:AddCard(IBS_Pocket.falsehood_bjudas)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, OnCollision)
