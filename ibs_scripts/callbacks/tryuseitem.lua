--尝试使用主动回调

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local Players = mod.IBS_Lib.Players

local config = Isaac.GetItemConfig()

--检测主动按键是否触发
local function IsActiveButtonTriggered(player, slot)
	local playerType = player:GetPlayerType()
	local cid = player.ControllerIndex

	--双子
	if player:GetOtherTwin() then
		if (playerType == PlayerType.PLAYER_JACOB) or (playerType == PlayerType.PLAYER_ESAU) then
			local action = ButtonAction.ACTION_ITEM
			
			--以扫
			if (playerType == PlayerType.PLAYER_ESAU) then 
				action = ButtonAction.ACTION_PILLCARD 
			end
			
			if (slot == ActiveSlot.SLOT_PRIMARY) then
				return Input.IsActionTriggered(action, cid) and not Input.IsActionPressed(ButtonAction.ACTION_DROP, cid)
			elseif (slot == ActiveSlot.SLOT_POCKET) then
				return (player:GetCard(0) <= 0 and player:GetPill(0) <= 0) and Input.IsActionTriggered(action, cid)	and Input.IsActionPressed(ButtonAction.ACTION_DROP, cid)		
			end
		end	
	else --其他
		if not Input.IsActionPressed(ButtonAction.ACTION_DROP, cid) then --这里主要是为了某些模组的兼容(但也会导致按住切换键时会返回false,总体来说无伤大雅)
			if (slot == ActiveSlot.SLOT_PRIMARY) then
				return Input.IsActionTriggered(ButtonAction.ACTION_ITEM, cid)
			elseif (slot == ActiveSlot.SLOT_POCKET) then
				return (player:GetCard(0) <= 0 and player:GetPill(0) <= 0) and Input.IsActionTriggered(ButtonAction.ACTION_PILLCARD, cid)
			end
		end	
	end
	
	return false
end

--频率限制(用于修正)
local TryUseTimeOut = 0
mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
	TryUseTimeOut = TryUseTimeOut + 2
end)
mod:AddCallback(ModCallbacks.MC_USE_CARD, function()
	TryUseTimeOut = TryUseTimeOut + 2
end)
mod:AddCallback(ModCallbacks.MC_USE_PILL, function()
	TryUseTimeOut = TryUseTimeOut + 2
end)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if TryUseTimeOut > 0 then
		TryUseTimeOut = TryUseTimeOut - 1
	end
end)

--尝试使用主动回调
--[[说明:
这个回调主要是用来触发主动的
在相应使用道具回调(ModCallbacks.MC_USE_ITEM)中应返回{DisCharge = false}
之后的充能消耗和魂火生成要自行添加
]]
--尝试使用主动回调
--[[说明:
这个回调主要是用来触发主动的
在相应使用道具回调(ModCallbacks.MC_USE_ITEM)中应返回{DisCharge = false}
之后的充能消耗和魂火生成要自行添加
]]
local function TryUseItemCallback(_, ent)
    local player = ent and ent:ToPlayer()
	if (TryUseTimeOut <= 0) and player and not player.Parent then
		if (not Game():IsPaused()) and (player:AreControlsEnabled()) then
			for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET, 2 do --只考虑第一主动和副手主动槽
				local item = player:GetActiveItem(slot)
				local itemConfig = config:GetCollectible(item)
				
				--非错误道具,主动按键触发
				if (item > 0) and IsActiveButtonTriggered(player, slot) then
					local canUse = false
					local flags = UseFlag.USE_OWNED --已经自动添加使用标签"拥有"
					local ignoreSharpPlug = false --是否无视锋利插头
					local charges = 0
					local maxCharges = itemConfig.MaxCharges
					local chargeType = itemConfig.ChargeType
					if (chargeType == ItemConfig.CHARGE_TIMED) then
						charges = Players:GetTimedSlotCharges(player, slot)
					else	
						charges = Players:GetSlotCharges(player, slot)
					end
					
					for _, callback in ipairs(Isaac.GetCallbacks(IBS_Callback.TRY_USE_ITEM)) do
						if (not callback.Param) or (callback.Param == item) then
							local result = callback.Function(callback.Mod, item, player, slot, charges, maxCharges, chargeType)

							if result ~= nil then
								if type(result) == "table" then
									canUse = result.CanUse or false
									if (canUse) then
										flags = (result.UseFlags and (flags | result.UseFlags)) or flags
										ignoreSharpPlug = result.IgnoreSharpPlug or false
									end
								elseif type(result) == "boolean" then
									canUse = result
								end
							end	
						end
					end
								
					if (canUse) then
						player:UseActiveItem(item, flags, slot)
						TryUseTimeOut = TryUseTimeOut + 2
						
						--先充满主动,再设置原有充能,以此无视锋利插头(按太快还是会触发)
						if ignoreSharpPlug and player:HasCollectible(CollectibleType.COLLECTIBLE_SHARP_PLUG) then
							player:SetActiveCharge(math.max(0, maxCharges), slot)
							Players:SetChargeData(player, slot, charges)
						end
					end	
				end 
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, TryUseItemCallback, InputHook.IS_ACTION_TRIGGERED)

