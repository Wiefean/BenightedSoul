--参孙的伪忆

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local BSamson = mod.IBS_Class.Pocket(mod.IBS_PocketID.BSamson)

--获取数据
function BSamson:GetData(player)
	local data = self._Players:GetData(player)
	data.FalsehoodBSamson = data.FalsehoodBSamson or {
		Recording = 0,
		HurtTimes = 0,
		TotalHurtTimes = 0,
		maxMult = 1,
		mult = 1,
	}
	return data.FalsehoodBSamson
end

--属性流失
function BSamson:OnPlayerUpdate(player)
	if player:IsFrame(3,0) then
		local data = self._Players:GetData(player).FalsehoodBSamson
		if data and data.mult > 1 then
			data.mult = math.max(1, data.mult - 0.02)
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SHOTSPEED, true)
		end
	end
end
BSamson:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')

--使用后开始记录受伤次数
function BSamson:OnUse(card, player, flag)
	local data = self:GetData(player)
	data.Recording = data.Recording + 1
	
	--在boss房使用时恢复属性已衰减的部分
	local roomType = game:GetRoom():GetType()
	if roomType == RoomType.ROOM_BOSS or roomType == RoomType.ROOM_BOSSRUSH then		
		data.mult = math.max(data.mult, data.maxMult)
	end	

	sfx:Play(594)
end
BSamson:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', BSamson.ID)

--清空记录并触发效果
function BSamson:Trigger(player, decreaseRecording)
	local data = self._Players:GetData(player).FalsehoodBSamson
	if data and data.Recording > 0 then
		data.mult = math.min(3, data.mult + 1 + 0.15 * data.HurtTimes)
		data.maxMult = data.mult
		data.HurtTimes = 0
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SHOTSPEED, true)
		
		if decreaseRecording then
			data.Recording = data.Recording - 1
		end	
			
		return true
	end
	return false
end

--记录受伤次数
--在即将受伤时生效
function BSamson:OnTakeDMG(ent, dmg, flag, source)
	local player = ent:ToPlayer()
	if not player then return end
	if dmg <= 0 then return end
	local data = self._Players:GetData(player).FalsehoodBSamson
	if data then
		if data.Recording > 0 then		
			data.HurtTimes = data.HurtTimes + 1
			data.TotalHurtTimes = data.TotalHurtTimes + 1
			sfx:Play(594, 0.7)
		end
	end
end
BSamson:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, 'OnTakeDMG')

--进入Boss房后
function BSamson:OnNewRoom()
	local room = game:GetRoom()
	if room:IsFirstVisit() and room:GetType() == RoomType.ROOM_BOSS then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			local data = self._Players:GetData(player).FalsehoodBSamson
			if data then
				if data.Recording > 0 then
					self:Trigger(player, true)
					sfx:Play(592)
				end
			end
		end
	end
end
BSamson:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--boss波次
function BSamson:OnWaveEndState(state)
	if state == 2 then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			local data = self._Players:GetData(player).FalsehoodBSamson
			if data then
				if data.Recording > 0 then
					self:Trigger(player, true)
					sfx:Play(592)
				end
			end
		end
	end
end
BSamson:AddCallback(mod.IBS_CallbackID.GREED_WAVE_END_STATE, 'OnWaveEndState')	

--属性
function BSamson:OnEvaluateCache(player, flag)
	local data = self._Players:GetData(player).FalsehoodBSamson
	if data and data.mult > 1 then
		local roomType = game:GetRoom():GetType()
		if roomType == RoomType.ROOM_BOSS or roomType == RoomType.ROOM_BOSSRUSH then
			if flag == CacheFlag.CACHE_FIREDELAY then
				self._Stats:TearsMultiples(player, data.mult)
			end
			if flag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage * data.mult
			end
			if flag == CacheFlag.CACHE_SHOTSPEED then
				player.ShotSpeed = player.ShotSpeed + 1
			end			
		end
	end	
end
BSamson:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, 'OnEvaluateCache')

--符文佩剑(东方mod)
if mod.IBS_Compat.THI:IsEnabled() then
	local RuneSword = THI.Collectibles.RuneSword

	mod.IBS_Compat.THI:AddRuneSwordCompat(BSamson.ID, {
		png = "gfx/ibs/items/pick ups/falsehoods/bsamson.png",
		textKey = "FALSEHOOD_BSAMSON",
		name = {
			zh = "参孙的伪忆",
			en = "Falsehood of Samson",
		},
		desc = {
			zh = "头目战爆发",
			en = "Fight against Boss",
		}, 
	})
	
	--进入Boss房后触发
	function BSamson:OnNewRoom()
		local room = game:GetRoom()
		if room:GetType() ~= RoomType.ROOM_BOSS then return end
		if not room:IsFirstVisit() then return end	

		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			local num = RuneSword:GetInsertedRuneNum(player, self.ID)
			if num > 0 then
				for i = 1,num do
					player:UseCard(self.ID, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
				end
				self:Trigger(player, true)
			end
		end
	end
	BSamson:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.EARLY, 'OnNewRoom')
	
	--boss波次
	function BSamson:OnWaveEndState(state)
		if state == 2 then
			for i = 0, game:GetNumPlayers() - 1 do
				local player = Isaac.GetPlayer(i)
				local num = RuneSword:GetInsertedRuneNum(player, self.ID)
				if num > 0 then
					for i = 1,num do
						player:UseCard(self.ID, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
					end
					self:Trigger(player, true)
				end
			end
		end
	end
	BSamson:AddPriorityCallback(mod.IBS_CallbackID.GREED_WAVE_END_STATE, CallbackPriority.EARLY, 'OnWaveEndState')		
	
end

return BSamson