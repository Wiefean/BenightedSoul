--主动槽渲染回调

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback

--获取屏幕尺寸
local function GetScreenSize()
	local room = Game():GetRoom()
	local pos = Isaac.WorldToScreen(Vector(0,0)) - room:GetRenderScrollOffset() - Game().ScreenShakeOffset
	
	local rx = pos.X + 60 * 26 / 40
	local ry = pos.Y + 140 * (26 / 40)
	
	return Vector(rx*2 + 13*26, ry*2 + 7*26)
end

--获取渲染信息
local function GetActiveSlotRender(player, idx, slot)
	local screenSize = GetScreenSize()
	local X,Y = 0,0
	local offset = Options.HUDOffset
	local slotScale = Vector(1,1)
	local playerType = player:GetPlayerType()

	if (idx == 0) then --P1
		if (playerType == PlayerType.PLAYER_ESAU) then
			X = screenSize.X - 20 - 16*offset
			Y = screenSize.Y - 23 - 6*offset
		else
			X = 20 + 20*offset
			Y = 16 + 12*offset
		end
	elseif (idx == 1) then --P2
		X = screenSize.X - 139 - 24*offset
		Y = 16 + 12*offset
	elseif (idx == 2) then --P3
		X = 30 + 22*offset
		Y = screenSize.Y - 23 - 6*offset
	else --P4或其他
		X = screenSize.X - 147 - 16*offset
		Y = screenSize.Y - 23 - 6*offset
	end
	
	--第二主动和副手主动兼容
	--(第二主动和非P1玩家副手主动的贴图是缩小一半的)
	if (slot == ActiveSlot.SLOT_SECONDARY) then
		X = X - 17
		Y = Y - 8
		slotScale = Vector(0.5,0.5)
	elseif (slot == ActiveSlot.SLOT_POCKET) then
		if (idx == 0) then --P1
			if (playerType == PlayerType.PLAYER_JACOB) then
				X = 3 + 20*offset
				Y = 39 + 12*offset		
			elseif (playerType == PlayerType.PLAYER_ESAU) then
				X = screenSize.X - 15 - 16*offset
				Y = screenSize.Y - 46 - 6*offset
			else
				X = screenSize.X - 20 - 16*offset
				Y = screenSize.Y - 14 - 6*offset
			end
		else --其他
			X = X - 24
			Y = Y + 18
			slotScale = Vector(0.5,0.5)
		end
	end		
	
	return Vector(X,Y), slotScale
end

--运行
local function RunCallback(player, idx)
	for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do
		if (slot ~= ActiveSlot.SLOT_POCKET) or (player:GetCard(0) <= 0 and player:GetPill(0) <= 0) then --副手主动不在第一卡槽时不触发
			local item = player:GetActiveItem(slot)
			local slotPosition, slotScale = GetActiveSlotRender(player, idx, slot)
			Isaac.RunCallbackWithParam(IBS_Callback.ACTIVE_SLOT_RENDER, item, item, player, slot, slotPosition, slotScale)
		end
	end
end

local function ActiveSlotRenderCallback(_,shaderName)
	if shaderName ~= "IBS_Empty" then return end
	if Game():GetHUD():IsVisible() then
		local controllers = {} --用于为控制器编号
		local index = 0
		
		for i = 0, Game():GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			local cid = player.ControllerIndex
			
			if (player.Variant == 0) and not player.Parent and not player:IsCoopGhost() and not controllers[cid] then
				for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do
					if (slot ~= ActiveSlot.SLOT_POCKET) or (player:GetCard(0) <= 0 and player:GetPill(0) <= 0) then --副手主动不在第一卡槽时不触发
						local item = player:GetActiveItem(slot)
						local slotPosition, slotScale = GetActiveSlotRender(player, index, slot)
						Isaac.RunCallbackWithParam(IBS_Callback.ACTIVE_SLOT_RENDER, item, item, player, slot, slotPosition, slotScale)
					end
				end
				
				--双子兼容
				if (player:GetPlayerType() == PlayerType.PLAYER_JACOB) then
					local player2 = player:GetOtherTwin()
					for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do
						if (slot ~= ActiveSlot.SLOT_POCKET) or (player2:GetCard(0) <= 0 and player2:GetPill(0) <= 0) then --副手主动不在第一卡槽时不触发
							local item = player2:GetActiveItem(slot)
							local slotPosition, slotScale = GetActiveSlotRender(player2, index, slot)
							Isaac.RunCallbackWithParam(IBS_Callback.ACTIVE_SLOT_RENDER, item, item, player2, slot, slotPosition, slotScale)
						end
					end
				end
				
				controllers[cid] = true
				index = index + 1
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, ActiveSlotRenderCallback)


