--自定义池Class

--[[

主要用于实现内容会减少的池

"KEY"指的是在数据存读系统中的索引,会自动加上"_Pool"的后缀

]]

local mod = Isaac_BenightedSoul

local Component = mod.IBS_Class.Component

local CustomPool = mod.Class(Component, function(self, KEY)
	Component._ctor(self)
	
	self.InitPool = {}
	KEY = KEY..'_Pool'

	--获取数据
	function self:GetData()
		local data = self:GetIBSData('temp')
		data[KEY] = data[KEY] or {}
		return data[KEY]		
	end

	--向初始池中加入内容
	function self:AddToInitPool(content, num)
		for i = 1,num do
			table.insert(self.InitPool, content)
		end
	end
	
	--通过表向初始池中加入内容
	function self:AddToInitPoolByTable(tbl)
		for _,content in ipairs(tbl) do
			table.insert(self.InitPool, content)
		end
	end
	
	--向池中加入内容
	function self:AddToPool(content, num)
		local data = self:GetData()
		for i = 1,num do
			table.insert(data, content)
		end
	end

	--通过表向池中加入内容
	function self:AddToPoolByTable(tbl)
		local data = self:GetData()
		for _,content in ipairs(tbl) do
			table.insert(data, content)
		end
	end

	--初始化池
	function self:Initialize(isContinued)
		if not isContinued then
			local data = self:GetData()
			for k,_ in ipairs(data) do
				data[k] = nil
			end
			for k,v in ipairs(self.InitPool) do
				data[k] = v
			end
		end
	end
	self:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.IMPORTANT, 'Initialize')

	--从池中抽取内容(建议根据具体情况修改该函数)
	function self:GetFromPool(seed, default, decrease)
		local data = self:GetData()

		if #data > 0 then
			local key = RNG(seed):RandomInt(1,#data)
			local content = data[key] or default
			if key and decrease then
				table.remove(data, key)
			end
			return content
		end

		return default
	end	

	--道具被原版方法降权后移出自定义道具池
	function self:_OnPoolGetCollectible(item, pool, decrease, seed)
		if decrease then
			for key,v in pairs(self:GetData()) do
				if v == item then
					local data = self:GetData()
					table.remove(data, key)
				end
			end
		end		
	end
	self:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, '_OnPoolGetCollectible')


end)


return CustomPool
