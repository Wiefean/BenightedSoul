--永乐大典

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()
local config = Isaac.GetItemConfig()

local Yongle = mod.IBS_Class.Item(mod.IBS_ItemID.Yongle)


--黑名单
Yongle.BlackList = {
	[545] = true, --骨书
	[584] = true, --美德书
	[IBS_ItemID.ChubbyCookbook] = true, --蛆虫食谱
	[IBS_ItemID.BookOfSeen] = true, --全知之书
	[IBS_ItemID.Yongle] = true, --永乐大典
}

--缓存
local cachedResult = {}

--获取准备触发的书
function Yongle:GetBooks(seed)
	seed = seed or game:GetSeeds():GetStartSeed()
	
	--尝试直接从缓存获取
	if cachedResult[seed] then
		return cachedResult[seed]
	end
	
	--清空缓存
	for k,_ in pairs(cachedResult) do
		cachedResult[k] = nil
	end
	
	local result = {}
	local itemPool = game:GetItemPool()
	local cache = {}

	for id = 1, config:GetCollectibles().Size do
		if not self.BlackList[id] then
			local itemConfig = config:GetCollectible(id)
			if itemConfig and itemConfig:IsAvailable() and itemConfig.Type == 3 and itemConfig:HasTags(ItemConfig.TAG_BOOK) and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
				--充能不为0,且类型为常规充能
				if itemConfig.MaxCharges > 0 and itemConfig.ChargeType == ItemConfig.CHARGE_NORMAL then
					table.insert(cache, {ID = id, Charge = itemConfig.MaxCharges})
				end
			end
		end
	end	

	--抽取直到充能达到20
	local charge = 0
	local rng = RNG(seed)
	while (#cache > 0 and charge < 20) do
		local tbl = cache[rng:RandomInt(1, #cache)] or {ID = 34, Charge = 3}
		charge = charge + tbl.Charge
		table.insert(result, tbl.ID)
		for k,v in ipairs(cache) do
			if v.ID == tbl.ID then			
				table.remove(cache, k)
			end
		end
	end	

	--缓存
	cachedResult[seed] = cachedResult[seed] or {}
	for _,id in ipairs(result) do
		table.insert(cachedResult[seed], id)
	end

	return result
end

--使用
function Yongle:OnUse(item, rng, player)

	--触发效果
	for _,id in ipairs(self:GetBooks()) do
		player:UseActiveItem(id, UseFlag.USE_NOANIM | UseFlag.USE_ALLOWWISPSPAWN | UseFlag.USE_VOID)
		
		--美德书魂火
		if player:HasCollectible(584) then		
			player:AddWisp(id, player.Position, true)
		end		
	end

	return true
end
Yongle:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', Yongle.ID)



return Yongle
