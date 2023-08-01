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
		NoAnim = false,
		Slot = -1,
		TimeOut = -1,
		Holding = false
	}
	
	return data.HoldItemCallback
end

--尝试握住主动回调
local function TryHoldItemCallback(_,item, rng, player, flag, slot)
	local data = GetHoldData(player)
	local canHold = false
	local noAnim = false
	local canCancel = false
	local timeOut = -1
	
	for _, callback in ipairs(Isaac.GetCallbacks(IBS_Callback.TRY_HOLD_ITEM)) do
		if (not callback.Param) or (callback.Param == item) then
			local result = callback.Function(callback.Mod, item, player, flag, slot)
			
			if result ~= nil then
				if type(result) == "table" then
					canHold = result.CanHold or false
					noAnim = result.NoAnim or false
					canCancel = result.CanCancel or false
					timeOut = result.TimeOut or -1
				elseif type(result) == "boolean" then
					canHold = result
				end
			end
		end
	end
	
	if canHold then
		if data.Holding then
			if canCancel and (data.Item == item) and (data.Slot == slot) then
				data.Holding = false
			end	
		elseif (data.Item <= 0) then
			data.Item = item
			data.UseFlags = flag
			data.NoAnim = noAnim
			data.Slot = slot
			data.TimeOut = timeOut
			data.Holding = true
		end	
	end	 
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, TryHoldItemCallback)

--正在握住主动回调和结束握住主动回调
local function HoldingAndEndHoldCallback(_,player)
    local data = GetHoldData(player)

	--限时
	if data.TimeOut > 0 then
		data.TimeOut = data.TimeOut - 1
	elseif data.TimeOut ~= -1 then
		data.TimeOut = -1
		data.Holding = false
	end

	if (data.Item > 0) then
		local item = data.Item
		if data.Holding then	
			if (not data.NoAnim) and player:IsExtraAnimationFinished() then
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
			Isaac.RunCallbackWithParam(IBS_Callback.END_HOLD_ITEM, item, item, player, data.UseFlags, data.Slot)
			if not data.NoAnim then
				player:PlayExtraAnimation("HideItem")
			end
			data.Item = 0
			data.UseFlags = 0
			data.NoAnim = false
			data.Slot = -1
		end
	else
		data.Holding = false
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, HoldingAndEndHoldCallback)

--受伤重置
local function OnTakeDMG(_,ent)
	local player = ent:ToPlayer()
	
    if player then
        local player = ent:ToPlayer()
		Ents:GetTempData(player).HoldItemCallback = nil
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, OnTakeDMG)

--新房间重置
local function OnNewRoom()
 	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		Ents:GetTempData(player).HoldItemCallback = nil
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OnNewRoom)

--举起道具时屏蔽丢弃键(防止bug)
local function BanDropKey(_,ent, hook, action)
	local player = (ent and ent:ToPlayer())
	
    if player then
		local data = GetHoldData(player)
        if data.Holding and (action == ButtonAction.ACTION_DROP) and (hook == InputHook.IS_ACTION_TRIGGERED) then
			return false
        end
    end
end
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, BanDropKey)
