--诅咒针剂

local mod = Isaac_BenightedSoul
local Pools = mod.IBS_Lib.Pools
local IBS_CallbackID = mod.IBS_CallbackID

local game = Game()
local config = Isaac.GetItemConfig()

local CurseSyringe = mod.IBS_Class.Item(mod.IBS_ItemID.CurseSyringe)

--获取数据
function CurseSyringe:GetData()
	local data = self:GetIBSData('temp')
	data.CurseSyringe = data.CurseSyringe or {}
	return data.CurseSyringe
end

--获取倍率
function CurseSyringe:GetMult()
	local mult = 1
	for k,v in pairs(self:GetData()) do
		mult = mult + 1
	end
	return mult
end

--属性变动
function CurseSyringe:OnEvalueateCache(player, flag)
	if player:HasCollectible(self.ID) then
		local mult = self:GetMult()
		if flag == CacheFlag.CACHE_DAMAGE then
			self._Stats:Damage(player, 0.3*mult)
		end
	end	
end
CurseSyringe:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache')

--新房间触发
function CurseSyringe:OnNewRoom()
	local level = game:GetLevel()
	local curses = game:GetLevel():GetCurses()

	if curses > 0 then	
		local data = self:GetData()
		local new = false
		for id = 0,66 do --硬核兼容模组诅咒,应该也不会加那么多吧
			local curse = (1 << id)
			if curses & curse > 0 then
				data[tostring(id)] = true
				new = true
			end
		end
		
		--有变动时刷新属性
		if new then
			for i = 0, game:GetNumPlayers() - 1 do
				local player = Isaac.GetPlayer(i)
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
			end
		end
	end
end
CurseSyringe:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, 10000, 'OnNewRoom')


return CurseSyringe