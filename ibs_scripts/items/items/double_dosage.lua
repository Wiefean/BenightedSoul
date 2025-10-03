--双倍剂量

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local DoubleDosage = mod.IBS_Class.Item(mod.IBS_ItemID.DoubleDosage)


--拾取效果
function DoubleDosage:OnGainItem(item, charge, first, slot, varData, player)
	if first then 
		if item == self.ID then
			local cache = {}
			
			--复制之前拾取过的针套部件
			for id,num in pairs(player:GetCollectiblesList()) do
				if id ~= self.ID and num > 0 then			
					local itemConfig = config:GetCollectible(id)
					if itemConfig and itemConfig.Type ~= ItemType.ITEM_ACTIVE and itemConfig:HasTags(ItemConfig.TAG_SYRINGE) then
						cache[id] = num
					end
				end
			end
			for id,num in pairs(cache) do
				for i = 1,num do			
					player:AddCollectible(id, 0, false)
				end
			end
		elseif player:HasCollectible(self.ID) then
			local itemConfig = config:GetCollectible(item)
			if itemConfig and itemConfig.Type ~= ItemType.ITEM_ACTIVE and itemConfig:HasTags(ItemConfig.TAG_SYRINGE) then
				player:AddCollectible(item, 0, false)
			end
		end
	end
	
	--计算针套数量,超过一定值则噩耗
	if player:HasCollectible(self.ID) then
		local itemConfig = config:GetCollectible(item)
		if itemConfig and itemConfig:HasTags(ItemConfig.TAG_SYRINGE) then
			local total = 0
			local threshold = 11
			for id,num in pairs(player:GetCollectiblesList()) do		
				local itemConfig = config:GetCollectible(id)
				if itemConfig and itemConfig:HasTags(ItemConfig.TAG_SYRINGE) then
					total = total + num
					if total > threshold then
						player:Die()
						break
					end
				end
			end	
		end	
	end
end
DoubleDosage:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem')


return DoubleDosage