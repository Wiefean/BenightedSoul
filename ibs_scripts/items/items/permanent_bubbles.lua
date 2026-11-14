--永久泡泡水

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local PermanentBubbles = mod.IBS_Class.Item(IBS_ItemID.PermanentBubbles)

--获取数据
function PermanentBubbles:GetData(player)
	local data = self._Players:GetData(player)
	data.PermanentBubbles = data.PermanentBubbles or {}
	return data.PermanentBubbles
end

--设置永久效果
function PermanentBubbles:SetPermanent(player, id)
	self:GetData(player)[id] = true
end

--直接拾取
function PermanentBubbles:OnPickItem(player, item, touched)
	self:SetPermanent(player, self.ID)
	self._Ents:GetTempData(player).PermanentBubblesPicking = true
end
PermanentBubbles:AddPriorityCallback(mod.IBS_CallbackID.PICK_COLLECTIBLE, CallbackPriority.LATE, 'OnPickItem', PermanentBubbles.ID)

--获得
function PermanentBubbles:OnGainItem(item, charge, first, slot, varData, player)
	player:RemoveCollectible(self.ID)

	if not self._Ents:GetTempData(player).PermanentBubblesPicking then	
		player:AddCollectible(IBS_ItemID.Wheat, 0, first)
	end
	self._Ents:GetTempData(player).PermanentBubblesPicking = nil
end
PermanentBubbles:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', PermanentBubbles.ID)

--移除检测
function PermanentBubbles:OnRemoveItem(player, item)
	local data = self._Players:GetData(player).PermanentBubbles
	if data and item > 0 and item ~= self.ID then
		local itemConfig = config:GetCollectible(item)
		if itemConfig and itemConfig.Type ~= 3 and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then		
			self:SetPermanent(player, item)
		end
	end
end
PermanentBubbles:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, 'OnRemoveItem')


--添加隐藏道具
function PermanentBubbles:OnPEffectUpdate(player)
	if not player:IsFrame(90,0) then return end --限制更新频率
	local data = self._Players:GetData(player).PermanentBubbles
	
	if data then
		local did = false
	
		for id,_ in pairs(data) do
			if not player:HasCollectible(id) then			
				player:AddInnateCollectible(id, 1)
				did = true
			end
		end	
		
		if did then
			player:AnimateCollectible(self.ID, "UseItem")
			sfx:Play(157)
		end
	end
end
PermanentBubbles:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, 'OnPEffectUpdate')

return PermanentBubbles