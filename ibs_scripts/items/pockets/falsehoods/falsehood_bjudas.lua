--犹大的伪忆

local mod = Isaac_BenightedSoul
local IBS_Sound = mod.IBS_Sound
local Ents = mod.IBS_Lib.Ents

local game = Game()
local sfx = SFXManager()

local BJudas = mod.IBS_Class.Pocket(mod.IBS_PocketID.BJudas)


--临时玩家数据
function BJudas:GetPlayerData(player)
	local data = Ents:GetTempData(player)
	data.FALSEHOOD_BJUDAS = data.FALSEHOOD_BJUDAS or {
		Timeout = 1,
		Mimic = false
	}
	
	return data.FALSEHOOD_BJUDAS
end

--临时眼泪数据
function BJudas:GetTearData(tear)
	local data = Ents:GetTempData(tear)
	data.FALSEHOOD_BJUDAS_TEAR = data.FALSEHOOD_BJUDAS_TEAR or {Bonus = true}
	
	return data.FALSEHOOD_BJUDAS_TEAR
end

--使用
function BJudas:OnUse(card, player, flag)
	local data = self:GetPlayerData(player)
	data.Timeout = data.Timeout + 210
	game:Darken(1, 100)
	sfx:Play(IBS_Sound.Falsehood_Bjudas_Ready)
	
	if (flag & UseFlag.USE_MIMIC > 0) then	
		data.Mimic = true
	else
		data.Mimic = false
	end
end
BJudas:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', BJudas.ID)


--发射
function BJudas:OnPlayerUpdate(player)
	local data = Ents:GetTempData(player).FALSEHOOD_BJUDAS
	
	if data then
		if data.Timeout > 0 then
			if (player:GetFireDirection() ~= Direction.NO_DIRECTION) then
				local dir = self._Players:GetAimingVector(player)
				local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BALLOON, 0, player.Position, dir*39, player):ToTear()
				self:GetTearData(tear).Bonus = (not data.Mimic)
				tear.CollisionDamage = math.max(65, 13*(player.Damage))
				
				local color = Color(0.6,0.6,0.6,0.3)
				color:SetColorize(1,1,1,1)
				tear.Color = color
	
				tear.Scale = 1.69
				tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING | TearFlags.TEAR_BURN)
				tear:Update()
				
				sfx:Play(SoundEffect.SOUND_GFUEL_GUNSHOT_SPREAD, 2, 2, false, 0.9)
				game:ShakeScreen(7)
				data.Timeout = 0
			end
			data.Timeout = data.Timeout - 1
		else
			Ents:GetTempData(player).FALSEHOOD_BJUDAS = nil	
		end
	end
end
BJudas:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)

--命中判定
function BJudas:OnTearCollision(tear, other)
	local data = Ents:GetTempData(tear).FALSEHOOD_BJUDAS_TEAR
	
	if data and Ents:IsEnemy(other, true) then
		local player = Ents:IsSpawnerPlayer(tear)
		if player and data.Bonus then
			data.Bonus = false
			player:AddCard(self.ID)
		end
	end
end
BJudas:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, 'OnTearCollision')

--符文佩剑(东方mod)
if mod.IBS_Compat.THI:IsEnabled() then
	local RuneSword = THI.Collectibles.RuneSword

	mod.IBS_Compat.THI:AddRuneSwordCompat(BJudas.ID, {
		png = "gfx/ibs/items/pick ups/falsehoods/bjudas.png",
		textKey = "FALSEHOOD_BJUDAS",
		name = {
			zh = "犹大的伪忆",
			en = "Falsehood of Judas",
		},
		desc = {
			zh = "弱化敌人",
			en = "Weaken enemies",
		}, 
	})
	
	--虚弱敌人
	function BJudas:OnPlayerUpdate(player)
		if player:IsFrame(90,0) then
			local num = RuneSword:GetInsertedRuneNum(player, self.ID)
			if num > 0 then			
				for _,target in ipairs(Isaac.FindInRadius(player.Position, 130, EntityPartition.ENEMY)) do
					if self._Ents:IsEnemy(target) then
						target:AddWeakness(EntityRef(familiar), 45*num)
					end
				end
			end
		end
	end
	BJudas:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')
	
end

return BJudas
