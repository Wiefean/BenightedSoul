--超紧急按钮

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

local SuperPanicButton = mod.IBS_Class.Item(IBS_ItemID.SuperPanicButton)

--切换房间触发
function SuperPanicButton:OnNewRoom()
	--移除主动形式
	for _,ent in pairs(Isaac.FindByType(5,100, IBS_ItemID.SuperPanicButton_Active)) do
		ent:Remove()
	end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(IBS_ItemID.SuperPanicButton_Active, true) then
			player:RemoveCollectible(IBS_ItemID.SuperPanicButton_Active, true)
		end
	end

	--每层的初始房间生成主动形式
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local room = game:GetRoom()
	local level = game:GetLevel()
	if room:IsFirstVisit() and level:GetStartingRoomIndex() == level:GetCurrentRoomDesc().SafeGridIndex then
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(-160,-80), 0, true)
		Isaac.Spawn(5,100, IBS_ItemID.SuperPanicButton_Active, pos, Vector.Zero, nil)
	end
end
SuperPanicButton:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--贪婪模式波次开始时主动形式消失
function SuperPanicButton:OnGreedWaveChange()
	for _,ent in pairs(Isaac.FindByType(5,100, IBS_ItemID.SuperPanicButton_Active)) do
		ent:Remove()
	end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(IBS_ItemID.SuperPanicButton_Active, true) then
			player:RemoveCollectible(IBS_ItemID.SuperPanicButton_Active, true)
		end
	end
end
SuperPanicButton:AddCallback(mod.IBS_CallbackID.GREED_WAVE_CHANGE, 'OnGreedWaveChange')

--使用效果
function SuperPanicButton:OnUse(item, rng, player, flags, slot)
	if (flags & UseFlag.USE_OWNED > 0) and (flags & UseFlag.USE_VOID <= 0) then
		self:GetIBSData('level').super_panic_button_used = true
		player:RemoveCollectible(self.ID, true)
		player:AddBoneHearts(1)
		player:AddHearts(6)
		player:SetMinDamageCooldown(60*75)

		--彼列书
		if player:HasCollectible(59) then
			self._Stats:PersisDamage(player, 2, true)
		end

		SFXManager():Play(SoundEffect.SOUND_BUTTON_PRESS, 4)

		return {ShowAnim = true, Remove = true}
	end
end
SuperPanicButton:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', IBS_ItemID.SuperPanicButton_Active)

--使用后本层的心不能被角色拾取
function SuperPanicButton:PreHeartCollision(pickup, other)
	local player = other:ToPlayer()
	if player and self:GetIBSData('level').super_panic_button_used then
		return false
	end
end
SuperPanicButton:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, 233, 'PreHeartCollision', PickupVariant.PICKUP_HEART)


return SuperPanicButton
