--音乐盒

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local MusicBox = mod.IBS_Class.Item(mod.IBS_ItemID.MusicBox)

--拾取道具
function MusicBox:OnPickItem(player, item, touched)
	if touched then return end 
	
	if player:HasCollectible(self.ID) then
		local itemConfig = config:GetCollectible(item)
		if itemConfig and itemConfig.Type ~= ItemType.ITEM_ACTIVE
			and itemConfig:HasTags(ItemConfig.TAG_OFFENSIVE)
			and not itemConfig:HasTags(ItemConfig.TAG_QUEST) 
		then
			player:AddItemWisp(item, player.Position, true)
		end
	end
	
end
MusicBox:AddPriorityCallback(mod.IBS_CallbackID.PICK_COLLECTIBLE, CallbackPriority.LATE, 'OnPickItem')


return MusicBox