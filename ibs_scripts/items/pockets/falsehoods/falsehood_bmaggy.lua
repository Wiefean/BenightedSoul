--抹大拉的伪忆

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local BMaggy = mod.IBS_Class.Pocket(mod.IBS_PocketID.BMaggy)

--装扮
local Costume = Isaac.GetCostumeIdByPath('gfx/ibs/characters/falsehood_bmaggy.anm2')

--临时数据
function BMaggy:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.FALSEHOOD_BMAGGY = data.FALSEHOOD_BMAGGY or {Timeout = 1}
	
	return data.FALSEHOOD_BMAGGY
end

--使用
function BMaggy:OnUse(card, player, flag)
	local data = self:GetData(player)
	data.Timeout = data.Timeout + 420
	player:SetMinDamageCooldown(480)
	player:AddNullCostume(Costume)
	player:AddCacheFlags(CacheFlag.CACHE_SPEED)
	player:EvaluateItems()
	
	local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position, Vector.Zero, player)				
	poof.SpriteScale = Vector(1.5,1.5)
	poof.Color = Color(0.5,0.5,0.5)
	sfx:Play(SoundEffect.SOUND_BLACK_POOF, 4)	
end
BMaggy:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', BMaggy.ID)

--生成震荡波和圣光
function BMaggy:OnPlayerUpdate(player)
	local data = self._Ents:GetTempData(player).FALSEHOOD_BMAGGY
	
	if data then
		if data.Timeout > 0 then
			data.Timeout = data.Timeout - 1
			
			if player.FrameCount % 10 == 0 then
				local light = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, player.Position, Vector.Zero, player)
				light.SpriteScale = Vector(1.5,1.5)
				
				for _,target in pairs(Isaac.FindInRadius(player.Position, 80, EntityPartition.ENEMY)) do
					if self._Ents:IsEnemy(target) then
						target:TakeDamage(math.max(3.5, player.Damage), 0, EntityRef(player), 1)
					end
				end
				
				local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, player.Position, Vector.Zero, player):ToEffect()
				wave.Parent = player
				wave:SetTimeout(14)
				wave:SetRadii(0,49)
				game:ShakeScreen(2)
				
				player:AddCacheFlags(CacheFlag.CACHE_SPEED)
				player:EvaluateItems()
			end
		else
			self._Ents:GetTempData(player).FALSEHOOD_BMAGGY = nil
			player:TryRemoveNullCostume(Costume)	
			player:AddCacheFlags(CacheFlag.CACHE_SPEED)
			player:EvaluateItems()			
		end
	end
end
BMaggy:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)

--移速
function BMaggy:OnEvalueateCache(player, flag)
	local data = self._Ents:GetTempData(player).FALSEHOOD_BMAGGY

	if data and (data.Timeout > 0) then
		if flag == CacheFlag.CACHE_SPEED then
			self._Stats:Speed(player, 0.7)
		end
	end	
end
BMaggy:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache')

--符文佩剑(东方mod)
if mod.IBS_Compat.THI:IsEnabled() then
	local RuneSword = THI.Collectibles.RuneSword
	local IronHeart = mod.IBS_Class.IronHeart()
	local TempIronHeart = mod.IBS_Class.TempIronHeart()

	mod.IBS_Compat.THI:AddRuneSwordCompat(BMaggy.ID, {
		png = "gfx/ibs/items/pick ups/falsehoods/bmaggy.png",
		textKey = "FALSEHOOD_BMAGGY",
		name = {
			zh = "抹大拉的伪忆",
			en = "Falsehood of Magdalene",
		},
		desc = {
			zh = "更硬",
			en = "Be harder",
		}, 
	})
	
	--新房间加铁心
	function BMaggy:OnNewRoom()
		if not game:GetRoom():IsFirstVisit() then return end
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			local num = RuneSword:GetInsertedRuneNum(player, self.ID)
			if num > 0 then
				--表表抹
				if player:GetPlayerType() == (mod.IBS_PlayerID.BMaggy) then
					local data = IronHeart:GetData(player)
					data.Extra = data.Extra + num
				else
					local data = TempIronHeart:GetData(player)
					data.Num = data.Num + num
				end
			end
		end
	end
	BMaggy:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

end

return BMaggy