--R剑

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local KilleR = mod.IBS_Class.Item(mod.IBS_ItemID.KilleR)


--临时数据
function KilleR:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.KilleR = data.KilleR or {mult = 1}

	return data.KilleR
end

--角色效果更新
function KilleR:OnPlayerUpdate(player)
	if player:HasCollectible(self.ID) and Input.IsActionPressed(ButtonAction.ACTION_RESTART, 0) then
		if player:IsFrame(3,0) then		
			local data = self:GetData(player)
			data.mult = math.min(2.3, data.mult + 0.1)
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_TEARFLAG, true)
		end
	elseif player:IsFrame(1,0) then
		--衰减
		local data = self._Ents:GetTempData(player).KilleR
		if data then
			if data.mult > 1 then
				data.mult = data.mult - 0.1
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_TEARFLAG, true)
			end
		end
	end
end
KilleR:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')


--伤害加成
function KilleR:OnEvaluateCache(player, flag)
	if player:HasCollectible(self.ID) then
		if flag == CacheFlag.CACHE_DAMAGE then
			self._Stats:Damage(player, 0.16 * player:GetCollectibleNum(self.ID))
		end
	end	
end
KilleR:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')

--属性
function KilleR:OnEvaluateCache2(player, flag)
	local data = self._Ents:GetTempData(player).KilleR
	if data and player:HasCollectible(self.ID) then
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * math.max(1, data.mult)
		end
		if flag == CacheFlag.CACHE_TEARFLAG and data.mult > 1.3 then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
		end
	end	
end
KilleR:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 100, 'OnEvaluateCache2')


return KilleR