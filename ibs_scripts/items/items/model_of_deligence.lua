--勤奋偶像

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()

local MODE = mod.IBS_Class.Item(mod.IBS_ItemID.MODE)

--获取数据
function MODE:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.ModelOfDeligence = data.ModelOfDeligence or {
		WheatCollected = 0,
		tears = 0,
		spd = 0,
	}
	return data.ModelOfDeligence
end

--增加计数,达到一定值时生成魂火
function MODE:AddWheatCollected(player, num)
	local data = self:GetData(player)
	for i = 1,num do
		data.WheatCollected = data.WheatCollected + 1
		if data.WheatCollected >= 4 then
			data.WheatCollected = data.WheatCollected - 4
			data.tears = data.tears + 0.25
			data.spd = data.spd + 0.15
			player:AddWisp(290, player.Position) --心魂火
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED, true)
		end
	end
end

--新房间清除数据
function MODE:OnNewRoom()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = self._Ents:GetTempData(player).ModelOfDeligence
		if data then
			data.tears = 0
			data.spd = 0
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED, true)			
		end
	end
end
MODE:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


--属性
function MODE:OnEvaluateCache(player, flag)
	if player:HasCollectible(self.ID) then
		local data = self:GetData(player)
		if flag == CacheFlag.CACHE_SPEED then
			Stats:Speed(player, data.spd)
		end		
		if flag == CacheFlag.CACHE_FIREDELAY then
			Stats:TearsModifier(player, data.tears)
		end
		if flag == CacheFlag.CACHE_LUCK then
			Stats:Luck(player, 1)
		end				
	end
end
MODE:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return MODE