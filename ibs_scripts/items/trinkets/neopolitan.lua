--三色杯

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()

local Neopolitan = mod.IBS_Class.Trinket(mod.IBS_TrinketID.Neopolitan)

--临时数据
function Neopolitan:GetData(player)
	local data = self:GetIBSData('temp')
	data.Neopolitan = data.Neopolitan or {}
	return data.Neopolitan
end

--新房间记录
function Neopolitan:OnNewRoom()
	local data = self:GetData()
	local room = game:GetRoom()
	local roomType = room:GetType()
	if roomType ~= RoomType.ROOM_DEFAULT and room:IsFirstVisit() then	
		table.insert(data, roomType)
	end
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasTrinket(self.ID) then
			player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE, true)
		end
	end	
end
Neopolitan:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--新层清空记录
function Neopolitan:OnNewLevel()
	local data = self:GetData()
	for k,v in pairs(data) do
		data[k] = nil
	end
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasTrinket(self.ID) then
			player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE, true)
		end
	end	
end
Neopolitan:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

--属性
function Neopolitan:OnEvaluateCache(player, flag)
	if player:HasTrinket(self.ID) then
		local data = self:GetData()
		local mult = 0
		local num = 0
		local per = math.max(1, 4 - player:GetTrinketMultiplier(self.ID))
		
		for k,v in pairs(data) do
			num = num + 1
			if num >= per then
				num = 0
				mult = mult + 1
			end
		end
		
		if mult > 0 then
			if flag == CacheFlag.CACHE_SPEED then
				Stats:Speed(player, 0.1*mult)
			end
			if flag == CacheFlag.CACHE_FIREDELAY then
				Stats:TearsModifier(player, 0.35*mult)
			end
			if flag == CacheFlag.CACHE_DAMAGE then
				Stats:Damage(player, 0.5*mult)
			end
		end
	end
end
Neopolitan:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return Neopolitan