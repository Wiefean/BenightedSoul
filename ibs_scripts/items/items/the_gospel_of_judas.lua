--犹大福音

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local IBS_Callback = mod.IBS_Callback
local Ents = mod.IBS_Lib.Ents
local Players = mod.IBS_Lib.Players
local Stats = mod.IBS_Lib.Stats

--临时数据
local function GetGospelData(player)
	local data = Ents:GetTempData(player)
	data.TGOJ = data.TGOJ or {
		Points = 0,
		DMGUp = 0,
		ChargeTimeOut = 0
	}
	
	return data.TGOJ
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
	return {Discharge = false, ShowAnim = false}
end, IBS_Item.tgoj)

mod:AddCallback(IBS_Callback.TRY_HOLD_ITEM, function(_,item, player, flag, slot)
	
	--提前消耗2点充能防止触发充满音效
	Players:DischargeTimedSlot(player, slot, 2, true)

	return {
		CanHold = (flag & UseFlag.USE_OWNED > 0), --持有时才尝试握住
		CanCancel = true, --满充能时的取消
	}
end, IBS_Item.tgoj)

--未满充能时的取消
mod:AddCallback(IBS_Callback.TRY_USE_ITEM, function(_,item, player, slot, charges)
	if charges < 180 then
		local data = Ents:GetTempData(player).HoldItemCallback
		if data then
			if data.Holding and (data.Item == IBS_Item.tgoj) and (data.Slot == slot) then
				data.Holding = false
			end
		end
	end	
end, IBS_Item.tgoj)

--正在握住
local function OnHolding(_,item, player, flag, slot)
	local data = GetGospelData(player)
	local rng = player:GetCollectibleRNG(IBS_Item.tgoj)
	local discharge = 2
	
	--9伏特和车载电池兼容
	if player:HasCollectible(116) or player:HasCollectible(356) then
		discharge = 1
	end

	--消耗充能,由于消耗充能速度是恢复充能速度的两倍(更新频率更快),相当于消耗充能
	if Players:DischargeTimedSlot(player, slot, discharge, false, true, true) then
		local pos = Vector(0,-50)*(player.SpriteScale) + player.Position
	
		--吸收敌弹
        for _,bullet in pairs(Isaac.FindInRadius(pos, 80, EntityPartition.BULLET)) do
			bullet.Velocity = (pos - bullet.Position):Resized(7)
			if bullet.Position:Distance(pos) <= math.max(20, 20*(player.SpriteScale.X), 15*(player.SpriteScale.Y)) then
				bullet:Remove()
				
				data.Points = data.Points + 1
				if data.Points >= 30 then
					data.Points = data.Points - 30
					Isaac.Spawn(1000, 189, 0, player.Position, Vector.Zero, player) --炼狱恶鬼裂缝

					--美德书兼容
					if player:HasCollectible(584) then
						local wisp = 33
						local int = rng:RandomInt(99)
						if int < 50 then wisp = 34 end
						player:AddWisp(wisp, player.Position)
					end					
				end
				
				--彼列书兼容
				if player:HasCollectible(59) then
					data.DMGUp = data.DMGUp + 0.2
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
					player:EvaluateItems()					
				end
			end
        end	
	else
		--充能不够时消耗魂红充能,每个魂红充能提供1.5秒或3秒持续时间
		if data.ChargeTimeOut > 0 then
			data.ChargeTimeOut = data.ChargeTimeOut - 1
			player:SetActiveCharge(0, slot)
		else
			if (player:GetSoulCharge() > 0) then
				player:AddSoulCharge(-1)
				data.ChargeTimeOut = data.ChargeTimeOut + math.floor(180/discharge)
			elseif (player:GetBloodCharge() > 0) then
				player:AddBloodCharge(-1)	
				data.ChargeTimeOut = data.ChargeTimeOut +  math.floor(180/discharge)
			else
				return false
			end
		end
	end
end
mod:AddCallback(IBS_Callback.HOLDING_ITEM, OnHolding, IBS_Item.tgoj)

--握住该道具时无视泪弹
mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, function(_,proj, other)
	local player = (other and other:ToPlayer())
	if player then
		local data = Ents:GetTempData(player).HoldItemCallback
		if data and data.Holding and (data.Item == IBS_Item.tgoj) then
			return true
		end
	end
end)

--伤害加成
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_,player, flag)
	local data = Ents:GetTempData(player).TGOJ
	if data and (data.DMGUp > 0) then
		if flag == CacheFlag.CACHE_DAMAGE then
			Stats:Damage(player, data.DMGUp)
		end
	end	
end)

--伤害衰减
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_,player)
	if player.FrameCount % 5 == 0 then
		local data = Ents:GetTempData(player).TGOJ
		if data and player:HasCollectible(IBS_Item.tgoj) then
			if data.DMGUp >= 0.1 then
				data.DMGUp = data.DMGUp - 0.1
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:EvaluateItems()
			end
		end
	end	
end)
	
