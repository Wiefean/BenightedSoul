--夏娃的伪忆

local mod = Isaac_BenightedSoul

local game = Game()

local BEve = mod.IBS_Class.Pocket(mod.IBS_PocketID.BEve)

--祝福列表
BEve.BlessList = {
	[1] = {zh = '预知祝福...', en = 'Bless of the Foreknown...'},
	[2] = {zh = '光明祝福...', en = 'Bless of the Light...'},
	[3] = {zh = '羽翼祝福...', en = 'Bless of the Wing...', noGreed = true},
	[4] = {zh = '丰收祝福...', en = 'Bless of the Harvest...'},
}

--获取数据
function BEve:GetData()
	local data = self:GetIBSData('level')
	data.FalsehoodBeve = data.FalsehoodBeve or {}
	return data.FalsehoodBeve
end

--获取可用祝福总数
function BEve:GetAvailableBlessNum()
	local num = #self.BlessList

	--考虑贪婪模式不出现的祝福
	if game:IsGreedMode() then
		for _,v in ipairs(self.BlessList) do
			if v.noGreed then
				num = num - 1
			end
		end
	end

	return num
end

--获取祝福
function BEve:GetBless(seed)
	local data = self:GetData()

	--尝试获取不重复值
	local greed = game:IsGreedMode()
	local result = {}
	for bless,v in ipairs(self.BlessList) do
		if (not greed) or not v.noGreed then
			if not data[bless] then
				table.insert(result, bless)
			end
		end
	end
	
	if #result > 0 then
		return result[RNG(seed):RandomInt(1, #result)] or result[1]
	end

	return 0
end

--启用祝福
function BEve:EnableBless(bless)
	local data = self:GetData()
	data[bless] = true
end

--是否有祝福
function BEve:HasBless(bless)
	local data = self:GetIBSData('level').FalsehoodBeve
	if data and data[bless] then
		return true
	end
	return false
end

--是否有所有祝福
function BEve:HasAllBlesses()
	local data = self:GetIBSData('level').FalsehoodBeve
	if data then
		local greed = game:IsGreedMode()
		for bless,v in ipairs(self.BlessList) do
			if (not greed) or not v.noGreed then
				if not data[bless] then
					return false
				end
			end
		end
		return true
	end
	return false	
end

--使用效果
function BEve:OnUse(card, player, flag)
	local bless = BEve:GetBless(player:GetCardRNG(self.ID):Next())

	if self.BlessList[bless] then
		self:EnableBless(bless)
		game:GetHUD():ShowFortuneText(self:ChooseLanguageInTable(self.BlessList[bless]))	
	end

	--已有所有祝福时移除3碎心
	if self:HasAllBlesses() and player:GetBrokenHearts() > 0 then
		player:AddBrokenHearts(-3)
		SFXManager():Play(266)
	end

	--移除诅咒
	local level = game:GetLevel()
	level:RemoveCurses(level:GetCurses())
	
	--刷新角色属性
	player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
end
BEve:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', BEve.ID)


--生成
local function Spawn(T, V, S)
	local room = game:GetRoom()
	local pos = room:FindFreePickupSpawnPosition((room:GetCenterPos()), 0, true)
	Isaac.Spawn(T, V, S, pos, Vector.Zero, nil)
end

--清理房间触发
function BEve:OnRoomCleaned()
	if game:IsGreedMode() then return end
	local rng = self:GetRNG('Pocket_Falsehood_BEve')

	--预知祝福
	if self:HasBless(1) and rng:RandomInt(100) < 50 then
		Spawn(5, 300, rng:RandomInt(1, 22))
	end

	--丰收祝福
	if self:HasBless(4) then
		Isaac.GetPlayer(0):UseActiveItem(476, false, false)
	end	
end
BEve:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')

--贪婪模式新波次触发
function BEve:OnGreedNewWave()
	local rng = self:GetRNG('Pocket_Falsehood_BEve')

	--预知祝福
	if self:HasBless(1) and rng:RandomInt(100) < 25 then
		Spawn(5, 300, rng:RandomInt(1, 22))
	end
	
	--丰收祝福
	if self:HasBless(4) then
		Isaac.GetPlayer(0):UseActiveItem(476, false, false)
	end	
end
BEve:AddCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, 'OnGreedNewWave')


--光明祝福
function BEve:OnPEffectUpdate(player)
	if self:HasBless(2) then
		local effects = player:GetEffects()
		if not effects:HasNullEffect(60) then
			effects:AddNullEffect(60)
		end
	end
end
BEve:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, 'OnPEffectUpdate')

--新层触发
function BEve:OnNewLevel()
	
	--硬核清除光明祝福
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		player:GetEffects():RemoveNullEffect(60)
	end	
end
BEve:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

--新房间触发
function BEve:OnNewRoom()
	--羽翼祝福
	if self:HasBless(3) then
		local room = game:GetRoom()
		for slot = 0,7 do
			local door = room:GetDoor(slot)
			if door then
				door:Open()
			end
		end
	end
end
BEve:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--属性
function BEve:OnEvaluateCache(player, flag)
	if self:HasBless(3) then
		if flag & CacheFlag.CACHE_SPEED > 0 then
			self._Stats:Speed(player, 0.3)
		end
	end
end
BEve:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')



--符文佩剑(东方mod)
if mod.IBS_Compat.THI:IsEnabled() then
	local RuneSword = THI.Collectibles.RuneSword

	mod.IBS_Compat.THI:AddRuneSwordCompat(BEve.ID, {
		png = "gfx/ibs/items/pick ups/falsehoods/beve.png",
		textKey = "FALSEHOOD_BEVE",
		name = {
			zh = "夏娃的伪忆",
			en = "Falsehood of Eve",
		},
		desc = {
			zh = "头目战后清除诅咒",
			en = "Clear curses after Boss",
		}, 
	})
	
	--清理boss房后清除诅咒
	function BEve:OnRoomCleaned(player)
		if not RuneSword:HasGlobalRune(self.ID) then return end
		if game:GetRoom():GetType() ~= RoomType.ROOM_BOSS then return end
		local level = game:GetLevel()
		level:RemoveCurses(level:GetCurses())
	end
	BEve:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')
	
	--boss波次
	function BEve:OnWaveEndState(state)
		if state == 2 and RuneSword:HasGlobalRune(self.ID) then
			local level = game:GetLevel()
			level:RemoveCurses(level:GetCurses())
		end
	end
	BEve:AddCallback(mod.IBS_CallbackID.GREED_WAVE_END_STATE, 'OnWaveEndState')	
	
end

return BEve