--握住主动回调

--调用在
--\ibs_scripts\commons\lib\players.lua

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID

local game = Game()
local config = Isaac.GetItemConfig()

local HoldItem = mod.IBS_Class.Callbacks{
	TRY_HOLD_ITEM = IBS_CallbackID.TRY_HOLD_ITEM,
	HOLDING_ITEM = IBS_CallbackID.HOLDING_ITEM,
	HOLD_ITEM_END = IBS_CallbackID.HOLD_ITEM_END
}


--临时数据
function HoldItem:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.HoldItemCallback = data.HoldItemCallback or {
		Item = 0,
		UseFlags = 0,
		NoLiftAnim = false,
		NoHideAnim = false,
		Slot = -1,
		Timeout = -1,
		AllowHurt = false,
		AllowNewRoom = false,
		CanCancel = false,
		Cancel_Active = false,
		Cancel_Timeout = false,
		Cancel_Hurt = false,
		Cancel_NewRoom = false,
		Holding = false
	}
	
	return data.HoldItemCallback
end


--正在握住主动回调和结束握住主动回调
function HoldItem:HoldingAndEndHoldCallback(player)
    local data = self._Ents:GetTempData(player).HoldItemCallback
	if not data then return end
	
	--限时
	if data.Timeout > 0 then
		data.Timeout = data.Timeout - 1
	elseif data.Timeout ~= -1 then
		data.Timeout = -1
		data.Cancel_Timeout = true
		data.Holding = false
	end

	if (data.Item > 0) and config:GetCollectible(data.Item) then
		local item = data.Item
		if data.Holding then	
			if (not data.NoLiftAnim) and player:IsExtraAnimationFinished() then
				player:AnimateCollectible(item, "LiftItem")
			end		
			
			for _, callback in ipairs(self:Get(self.IDs.HOLDING_ITEM)) do
				if (not callback.Param) or (callback.Param == item) then
					local result = callback.Function(callback.Mod, item, player, data.UseFlags, data.Slot)
					if (result ~= nil) and (result == false) then
						data.Holding = false
						break
					end
				end
			end				
		else
			if not data.NoHideAnim then
				player:PlayExtraAnimation("HideItem")
			end
			
			self:RunWithParam(self.IDs.HOLD_ITEM_END, item, item, player, data.UseFlags, data.Slot, data.Cancel_Active, data.Cancel_Timeout, data.Cancel_Hurt, data.Cancel_NewRoom)
			self._Ents:GetTempData(player).HoldItemCallback = nil
		end
	else
		self._Ents:GetTempData(player).HoldItemCallback = nil
	end
end
HoldItem:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'HoldingAndEndHoldCallback')

--受伤结束握住
function HoldItem:OnTakeDMG(ent)
	local player = ent:ToPlayer()
	
    if player then
		local data = self._Ents:GetTempData(player).HoldItemCallback
		if data and not data.AllowHurt then
			data.Cancel_Hurt = true
			data.Holding = false
		end
    end
end
HoldItem:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 7000, 'OnTakeDMG')

--新房间结束握住
function HoldItem:OnNewRoom()
 	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = self._Ents:GetTempData(player).HoldItemCallback
		if data and not data.AllowNewRoom then
			data.Cancel_NewRoom = true
			data.Holding = false
		end
    end
end
HoldItem:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--举起道具时屏蔽丢弃键(防止bug)
function HoldItem:BanDropKey(ent, hook, action)
	local player = (ent and ent:ToPlayer())
	
    if player then
		local data = self._Ents:GetTempData(player).HoldItemCallback
        if data and data.Holding and (action == ButtonAction.ACTION_DROP) then
			return false
        end
    end
end
HoldItem:AddCallback(ModCallbacks.MC_INPUT_ACTION, 'BanDropKey', InputHook.IS_ACTION_TRIGGERED)

--举起道具时通关防卡死
function HoldItem:PrePickupCollison(pickup, ent)
	local player = (ent and ent:ToPlayer())
	
    if player then
		local data = self._Ents:GetTempData(player).HoldItemCallback
        if data and data.Holding then
			return false
        end
    end
end
HoldItem:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, 'PrePickupCollison', PickupVariant.PICKUP_BIGCHEST)
HoldItem:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, 'PrePickupCollison', PickupVariant.PICKUP_TROPHY)


return HoldItem