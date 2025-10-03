--成就Class(不适用于角色成就)

--[[
"key"指的是数据存读系统中对应的索引

"info_tbl"可包含内容:
{

--成就贴图名
PaperNames = {
	'贴图名',
	'贴图名',
	'贴图名',
	...
}, 

Items, --解锁的道具(表)
Trinkets, --解锁的饰品(表)
Pockets, --解锁的口袋物品(表)
}

]]

local mod = Isaac_BenightedSoul

local game = Game()

local Component = mod.IBS_Class.Component

local Achievement = mod.Class(Component, function(self, key, info_tbl)
	Component._ctor(self)

	self.Key = key
	self.Info = info_tbl or {}

	--是否已解锁
	function self:IsUnlocked()
		return self:GetIBSData('persis')[self.Key]
	end

	--是否未解锁
	function self:IsLocked()
		return (not self:GetIBSData('persis')[self.Key])
	end

	--锁
	function self:Lock(instantSave)
		self:GetIBSData('persis')[self.Key] = false
		
		--即时保存
		if instantSave then
			self:SaveIBSData()
		end
	end

	--解锁
	function self:Unlock(showPaper, instantSave)
		self:GetIBSData('persis')[self.Key] = true

		--弹出纸张
		if showPaper and self.Info.PaperNames then
			for _,v in ipairs(self.Info.PaperNames) do
				self._Screens:PlayPaper(v)
			end
		end

		--即时保存
		if instantSave then
			self:SaveIBSData()
		end		
	end



	--将未解锁物品从池中移除
	function self:RemoveTheLockedFromPool(isContinue)
		if (not isContinue) and self:IsLocked() then
			local itemPool = game:GetItemPool()
			
			--道具
			if self.Info.Items then
				for _,id in pairs(self.Info.Items) do
					itemPool:RemoveCollectible(id)
				end
			end

			--饰品
			if self.Info.Trinkets then
				for _,id in pairs(self.Info.Trinkets) do
					itemPool:RemoveTrinket(id)
				end
			end
		end
	end
	self:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.IMPORTANT, 'RemoveTheLockedFromPool')


	--避免从池中抽取未解锁道具
	function self:AvoidLockedItems(id, pool, decrease, seed)
		if self:IsLocked() and self.Info.Items then
			for _,v in pairs(self.Info.Items) do
				if v == id then
					local itemPool = game:GetItemPool()
					itemPool:RemoveCollectible(id)
					return itemPool:GetCollectible(pool, decrease, seed)
				end
			end
		end
	end
	self:AddPriorityCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, CallbackPriority.IMPORTANT, 'AvoidLockedItems')

	--避免从池中抽取未解锁饰品
	function self:AvoidLockedTrinkets(id)
		if self:IsLocked() and self.Info.Trinkets then
			for _,v in pairs(self.Info.Trinkets) do
				if v == id then		
					local itemPool = game:GetItemPool()
					itemPool:RemoveTrinket(id)
					return itemPool:GetTrinket()
				end
			end
		end	
	end
	self:AddPriorityCallback(ModCallbacks.MC_GET_TRINKET, CallbackPriority.IMPORTANT, 'AvoidLockedTrinkets')


	--避免从池中抽取未解锁口袋物品
	function self:AvoidLockedPockets(rng, id, includePlayingCards, includeRunes, onlyRunes)
		if self:IsLocked() and self.Info.Pockets then
			for _,v in pairs(self.Info.Pockets) do
				if v == id then		
					local itemPool = game:GetItemPool()
					return itemPool:GetCard(rng:Next(), includePlayingCards, includeRunes, onlyRunes)
				end
			end		
		end	
	end
	self:AddPriorityCallback(ModCallbacks.MC_GET_CARD, CallbackPriority.IMPORTANT, 'AvoidLockedPockets')


end,{
	{expectedType = 'string'},
	{expectedType = 'table', allowNil = true}
})



return Achievement





