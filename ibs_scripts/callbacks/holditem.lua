--握住主动回调

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local Ents = mod.IBS_Lib.Ents
local Players = mod.IBS_Lib.Players

local config = Isaac.GetItemConfig()

--临时数据
local function GetHoldData(player)
	local data = Ents:GetTempData(player)
	data.HoldItemCallback = data.HoldItemCallback or {
		Item = 0,
		UseFlags = 0,
		NoLiftAnim = false,
		NoHideAnim = false,
		Slot = -1,
		TimeOut = -1,
		AllowHurt = false,
		AllowNewRoom = false,
		CanCancel = false,
		Cancel_Active = false,
		Cancel_TimeOut = false,
		Cancel_Hurt = false,
		Cancel_NewRoom = false,
		Holding = false
	}
	
	return data.HoldItemCallback
end

--尝试握住主动回调
local function TryHoldItemCallback(_,item, rng, player, flag, slot)
	local data = GetHoldData(player)
	local canHold = false
	local noLiftAnim = false
	local noHideAnim = false
	local canCancel = false
	local allowHurt = false
	local allowNewRoom = false
	local timeOut = -1
	
	for _, callback in ipairs(Isaac.GetCallbacks(IBS_Callback.TRY_HOLD_ITEM)) do
		if (not callback.Param) or (callback.Param == item) then
			local result = callback.Function(callback.Mod, item, player, flag, slot, data.Item)
			
			if result ~= nil then
				canHold = result.CanHold or false
				noLiftAnim = result.NoLiftAnim or false
				noHideAnim = result.NoHideAnim or false
				canCancel = result.CanCancel or false
				allowHurt = result.AllowHurt or false
				allowNewRoom = result.AllowNewRoom or false
				timeOut = result.TimeOut or -1
			end
		end
	end
	
	if canHold then
		if data.Holding then
			if canCancel and (data.Item == item) and (data.Slot == slot) then 
				data.Cancel_Active = true --满充能时的取消
				data.Holding = false
			end	
		elseif (data.Item <= 0) then
			data.Item = item
			data.UseFlags = flag
			data.NoLiftAnim = noLiftAnim
			data.NoHideAnim = noHideAnim
			data.Slot = slot
			data.TimeOut = timeOut
			data.CanCancel = canCancel
			data.AllowHurt = allowHurt
			data.AllowNewRoom = allowNewRoom
			data.Holding = true
		end	
	end	 
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, TryHoldItemCallback)

--未满充能时的取消
local function TryCancel(_,item, player, slot, charges, maxCharges)
	if charges < maxCharges then
		local data = Ents:GetTempData(player).HoldItemCallback
		if data and data.CanCancel and data.Holding and (data.Item == item) and (data.Slot == slot) then
			data.Cancel_Active = true
			data.Holding = false
		end
	end	
end
mod:AddCallback(IBS_Callback.TRY_USE_ITEM, TryCancel)

--正在握住主动回调和结束握住主动回调
local function HoldingAndEndHoldCallback(_,player)
    local data = Ents:GetTempData(player).HoldItemCallback
	if data then
	
		--限时
		if data.TimeOut > 0 then
			data.TimeOut = data.TimeOut - 1
		elseif data.TimeOut ~= -1 then
			data.TimeOut = -1
			data.Cancel_TimeOut = true
			data.Holding = false
		end

		if (data.Item > 0) then
			local item = data.Item
			if data.Holding then	
				if (not data.NoLiftAnim) and player:IsExtraAnimationFinished() then
					player:AnimateCollectible(item, "LiftItem")
				end		
				
				for _, callback in ipairs(Isaac.GetCallbacks(IBS_Callback.HOLDING_ITEM)) do
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
				
				Isaac.RunCallbackWithParam(IBS_Callback.END_HOLD_ITEM, item, item, player, data.UseFlags, data.Slot, data.Cancel_Active, data.Cancel_TimeOut, data.Cancel_Hurt, data.Cancel_NewRoom)
				Ents:GetTempData(player).HoldItemCallback = nil
			end
		else
			Ents:GetTempData(player).HoldItemCallback = nil
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, HoldingAndEndHoldCallback)

--受伤结束握住
local function OnTakeDMG(_,ent)
	local player = ent:ToPlayer()
	
    if player then
        local player = ent:ToPlayer()
		local data = Ents:GetTempData(player).HoldItemCallback
		if data and not data.AllowHurt then
			data.Cancel_Hurt = true
			data.Holding = false
		end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, OnTakeDMG)

--新房间结束握住
local function OnNewRoom()
 	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = Ents:GetTempData(player).HoldItemCallback
		if data and not data.AllowNewRoom then
			data.Cancel_NewRoom = true
			data.Holding = false
		end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OnNewRoom)

--举起道具时屏蔽丢弃键(防止bug)
local function BanDropKey(_,ent, hook, action)
	local player = (ent and ent:ToPlayer())
	
    if player then
		local data = Ents:GetTempData(player).HoldItemCallback
        if data and data.Holding and (action == ButtonAction.ACTION_DROP) and (hook == InputHook.IS_ACTION_TRIGGERED) then
			return false
        end
    end
end
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, BanDropKey)
