--内核加速

local mod = Isaac_BenightedSoul
local AbandonedItem = mod.IBS_Effect.AbandonedItem

local game = Game()

local Turbo = mod.IBS_Class.Item(mod.IBS_ItemID.Turbo)
local config = Isaac.GetItemConfig()

--获得时充能
function Turbo:OnGainItem(item, charge, first, Slot, varData, player)
	for slot = 0,2 do
		local item = player:GetActiveItem(slot)
		local itemConfig = config:GetCollectible(item)
		
		if itemConfig and (itemConfig.ChargeType ~= ItemConfig.CHARGE_SPECIAL) then				
			self._Players:ChargeSlot(player, slot, 2*itemConfig.MaxCharges, false, true, true, true)
		end
	end
end
Turbo:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', Turbo.ID)

--道具首次出现时触发
function Turbo:OnPickupFirstAppear(pickup)
	if pickup.SubType <= 0 then return end --非错误道具和空底座
	if pickup.SubType == self.ID then return end --非内核加速
	local itemConfig = config:GetCollectible(pickup.SubType)
		
	--非任务道具
	if itemConfig and itemConfig:HasTags(ItemConfig.TAG_QUEST) then
		return
	end

	local room = game:GetRoom()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID, true) then
			for i = 1,player:GetCollectibleNum(self.ID, true) do
				player:RemoveCollectible(self.ID, true)
			end
			local seija = mod.IBS_Compat.THI:SeijaBuff(player)
			local seijaBLevel = mod.IBS_Compat.THI:GetSeijaBLevel(player)
			local num = 1
		
			--里正邪额外生成
			if seijaBLevel > 1 then
				num = num + seijaBLevel - 1
			end
			
			local offset = seija and Vector(0,-40) or Vector.Zero
			
			Isaac.Spawn(5, 100, self.ID, pickup.Position + offset, Vector.Zero, nil)
			
			if num > 1 then
				for i = 1,num-1 do
					local pos = room:FindFreePickupSpawnPosition(pickup.Position + offset, 0, true)
					Isaac.Spawn(5, 90, 1, pos, Vector.Zero, nil)
				end
			end
			

			--正邪增强(东方mod),不移除
			if not seija then
				--特效
				if itemConfig.GfxFileName then
					AbandonedItem:Spawn(pickup.Position, itemConfig.GfxFileName, RandomVector() * 0.1 * math.random(7, 12))
				end	
				pickup:Remove()
			end
		end
	end
end
Turbo:AddCallback(mod.IBS_CallbackID.PICKUP_FIRST_APPEAR, 'OnPickupFirstAppear', 100)


return Turbo