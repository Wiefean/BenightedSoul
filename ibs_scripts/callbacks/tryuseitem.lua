--尝试使用主动回调

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback

local config = Isaac.GetItemConfig()

--检测主动按键是否触发
local function IsActiveButtonTriggered(player, slot)
	local playerType = player:GetPlayerType()
	local cid = player.ControllerIndex

	if (playerType == PlayerType.PLAYER_JACOB) or (playerType == PlayerType.PLAYER_ESAU) then
		local action = ButtonAction.ACTION_ITEM
		if (playerType == PlayerType.PLAYER_ESAU) then action = ButtonAction.ACTION_PILLCARD end
		
		if (slot == ActiveSlot.SLOT_PRIMARY) then
			return Input.IsActionTriggered(action, cid) and not Input.IsActionPressed(ButtonAction.ACTION_DROP, cid)
		elseif (slot == ActiveSlot.SLOT_POCKET) then
			return Input.IsActionTriggered(ButtonAction.ACTION_PILLCARD, cid)			
		end
	else
		if not Input.IsActionPressed(ButtonAction.ACTION_DROP, cid) then --这里主要是为了某些模组的兼容(但也会导致按住切换键时会返回false,总体来说无伤大雅)
			if (slot == ActiveSlot.SLOT_PRIMARY) then
				return Input.IsActionTriggered(ButtonAction.ACTION_ITEM, cid)
			elseif (slot == ActiveSlot.SLOT_POCKET) then
				return Input.IsActionTriggered(ButtonAction.ACTION_PILLCARD, cid)
			end
		end	
	end
	
	return false
end

--尝试使用主动回调
--[[说明:
这个回调主要是用来触发主动的
在相应使用道具回调(ModCallbacks.MC_USE_ITEM)中应返回{DisCharge = false}
之后的充能消耗和魂火生成要自行添加
]]
local function TryUseItemCallback(mod, player)
	if (not Game():IsPaused()) and (player:AreControlsEnabled()) and (Game():GetRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT) then
		for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET, 2 do --只考虑第一主动和副手主动槽
			local item = player:GetActiveItem(slot)
			local itemConfig = config:GetCollectible(item)
			
			--非错误道具,非零充主动,主动按键触发
			if (item > 0) and (itemConfig.MaxCharges > 0) and IsActiveButtonTriggered(player, slot) then
				local canUse = false
				local flags = UseFlag.USE_OWNED --已经自动添加使用标签"拥有"
				
				for _, callback in ipairs(Isaac.GetCallbacks(DMM_Callback.TRY_USE_ITEM)) do
					if (not callback.Param) or (callback.Param == item) then
						local result = callback.Function(mod, item, player, slot) or false
						if type(result) == "table" then
							canUse = result.CanUse or false
							if (canUse) then
								flags = (result.UseFlags and (flags | result.UseFlags)) or flags
								break
							end
						elseif type(result) == "boolean" then
							canUse = result
							if (canUse) then break end
						end
					end
				end
							
				if (canUse) then
					player:UseActiveItem(item, flags, slot)
				end	
			end 
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, TryUseItemCallback, 0)
