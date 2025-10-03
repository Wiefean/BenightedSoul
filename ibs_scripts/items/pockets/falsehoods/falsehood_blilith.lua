--莉莉丝的伪忆

local mod = Isaac_BenightedSoul
local AbandonedItem = mod.IBS_Effect.AbandonedItem

local game = Game()
local config = Isaac.GetItemConfig()

local BLilith = mod.IBS_Class.Pocket(mod.IBS_PocketID.BLilith)

--获取角色身上品质最低的被动道具(非任务道具)
function BLilith:GetLowestItem(player, seed)
	local lowest = 114514 --大一些以防万一(悲)
	local lastLowest = 113514
	local result = {}
	
	local MAX = config:GetCollectibles().Size - 1
	for id = -MAX, MAX do
		local itemConfig = config:GetCollectible(id)
		if itemConfig and itemConfig:IsAvailable() and itemConfig.Type ~= 3 and player:HasCollectible(id, true) and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
			if itemConfig.Quality < lowest then
				lowest = itemConfig.Quality
				
				--如果比之前的品质更低,重置表
				if lowest < lastLowest then
					for k,_ in pairs(result) do
						result[k] = nil
					end
				end
				lastLowest = lowest
				
				table.insert(result, id)
			end
		end
	end	
	
	--从表中随机抽取一个
	if #result > 0 then
		return result[RNG(seed):RandomInt(1, #result)] or result[1], lowest
	end
end

--使用效果
function BLilith:OnUse(card, player, flag)
	local rng = player:GetCardRNG(self.ID)
	local item,quality = self:GetLowestItem(player, rng:Next())

	if item then
		player:RemoveCollectible(item, true)
		
		--特效
		local itemConfig = config:GetCollectible(item)
		if itemConfig.GfxFileName then
			AbandonedItem:Spawn(player.Position, itemConfig.GfxFileName, RandomVector() * 0.1 * math.random(10, 15))
		end
		
		local itemPool = game:GetItemPool()
		local pool = self._Pools:GetRoomPool(self._Levels:GetRoomUniqueSeed())

		--从池中移除同品质的15个道具
		for i = 1,15 do
			local id = self._Pools:GetCollectibleWithQuality(rng:Next(), quality, pool, true, 25, true)
			local itemConfig = config:GetCollectible(id)

			if itemConfig and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
				itemPool:RemoveCollectible(id)
				
				--特效
				if id ~= 25 and itemConfig.GfxFileName then
					AbandonedItem:Spawn(player.Position, itemConfig.GfxFileName, RandomVector() * 0.1 * math.random(10, 15))
				end
			end
		end

		SFXManager():Play(267)
	end
end
BLilith:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', BLilith.ID)


--符文佩剑(东方mod)
if mod.IBS_Compat.THI:IsEnabled() then
	local RuneSword = THI.Collectibles.RuneSword

	mod.IBS_Compat.THI:AddRuneSwordCompat(BLilith.ID, {
		png = "gfx/ibs/items/pick ups/falsehoods/blilith.png",
		textKey = "FALSEHOOD_BLILITH",
		name = {
			zh = "莉莉丝的伪忆",
			en = "Falsehood of Lilith",
		},
		desc = {
			zh = "弃子战术",
			en = "Tactics",
		}, 
	})
	
	--镶嵌改动
	local oldfn = RuneSword.InsertRune
	function RuneSword:InsertRune(player, rune, ...)
		if rune == BLilith.ID then
			local itemPool = game:GetItemPool()
			local pool = BLilith._Pools:GetRoomPool(BLilith._Levels:GetRoomUniqueSeed())		
		
			--从池中移除同品质2以下的道具
			local rng = player:GetCardRNG(BLilith.ID)
			for i = 1,30 do
				local id = BLilith._Pools:GetCollectibleWithQuality(rng:Next(), 1, pool, true, 25, true, false, true)
				local itemConfig = config:GetCollectible(id)

				if itemConfig and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
					itemPool:RemoveCollectible(id)
					
					--特效
					if id ~= 25 and itemConfig.GfxFileName then
						AbandonedItem:Spawn(player.Position, itemConfig.GfxFileName, RandomVector() * 0.1 * math.random(10, 15))
					end
				end
			end
		end
		return oldfn(self, player, rune, ...)
	end
end

return BLilith