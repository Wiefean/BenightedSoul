--钥湿

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Kear = mod.IBS_Class.Item(mod.IBS_ItemID.Kear)

--临时数据
function Kear:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.Kear = data.Kear or {TearsUp = 0}

	return data.Kear
end

--射速加成
function Kear:OnEvaluateCache(player, flag)
	local data = self._Ents:GetTempData(player).Kear
	if data and (data.TearsUp > 0) then
		if flag == CacheFlag.CACHE_FIREDELAY then
			self._Stats:TearsModifier(player, data.TearsUp)
		end
	end	
end
Kear:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')

--加成衰减
function Kear:OnPlayerUpdate(player)
	if player:IsFrame(90,0) then
		local data = self._Ents:GetTempData(player).Kear
		if data then
			if data.TearsUp > 0.1 then
				data.TearsUp = data.TearsUp - 0.1
			else
				self._Ents:GetTempData(player).Kear = nil
			end
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
		end
	end
end
Kear:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')

--失去钥匙时触发
function Kear:OnKeyNumChange(delta)
	if delta < 0 then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) then
				local data = self:GetData(player)
				data.TearsUp = math.min(5, data.TearsUp + 0.7)
				player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
			end
		end
	end
end
Kear:AddCallback(mod.IBS_CallbackID.NUM_CHANGE_KEY,'OnKeyNumChange')

return Kear