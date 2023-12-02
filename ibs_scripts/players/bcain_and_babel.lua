--昧化该隐&亚伯

local mod = Isaac_BenightedSoul
local IBS_API = mod.IBS_API
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local IBS_Player = mod.IBS_Player
local IBS_Sound = mod.IBS_Sound
local Pools = mod.IBS_Lib.Pools
local Finds = mod.IBS_Lib.Finds
local Ents = mod.IBS_Lib.Ents
local Players = mod.IBS_Lib.Players
local Stats = mod.IBS_Lib.Stats

local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local ErrorTipName = "IBS_API.BCBA"
IBS_API.BCBA = {}

local ExcludedActive = {}

--添加处于副角色状态时不临时移除的主动道具
--(默认包含原版所有主动)
function IBS_API.BCBA:AddExcludedActiveItem(item)
	local err,mes = mod:CheckArgType(item, "number", nil, 1, ErrorTipName)
	if err then error(mes, 2) end

	ExcludedActive[item] = true
end

--获取另一玩家
function IBS_API.BCBA:GetOtherTwin(player)
	local err,mes = mod:CheckArgType(player, "userdata", "player", 1, ErrorTipName)
	if err then error(mes, 2) end

	local data = Ents:GetTempData(player).BCBA
	if data and data.Twin then
		return data.Twin
	end
	return nil
end

--是否为主角色
function IBS_API.BCBA:IsMainPlayer(player)
	local err,mes = mod:CheckArgType(player, "userdata", "player", 1, ErrorTipName)
	if err then error(mes, 2) end

	local data = Players:GetData(player).BCBAInfo
	if data and data.State and (data.State ~= "Second") then
		return true
	end
	return false
end

--是否为副角色
function IBS_API.BCBA:IsSecondPlayer(player)
	local err,mes = mod:CheckArgType(player, "userdata", "player", 1, ErrorTipName)
	if err then error(mes, 2) end

	local data = Players:GetData(player).BCBAInfo
	if data and data.State and (data.State == "Second") then
		return true
	end
	return false
end

--是否为初始玩家
function IBS_API.BCBA:IsOriginPlayer(player)
	local err,mes = mod:CheckArgType(player, "userdata", "player", 1, ErrorTipName)
	if err then error(mes, 2) end

	local data = Players:GetData(player).BCBAInfo
	if data and data.Origin then
		return true
	end
	return false
end

--任意主副角色拥有道具
function IBS_API.BCBA:AnyHasCollectible(player, item)
	local err,mes = mod:CheckArgType(player, "userdata", "player", 1, ErrorTipName)
	if err then error(mes, 2) end
	err,mes = mod:CheckArgType(item, "number", nil, 1, ErrorTipName)
	if err then error(mes, 2) end

	local has = false
	local player2 = IBS_API.BCBA:GetOtherTwin(player)
	
	has = player:HasCollectible(item)
	
	if (not has) and player2 and player2:Exists() and not player2:IsDead() then
		has = player2:HasCollectible(item)
	end
	
	return has
end

--获取处于副角色的时间(60 = 1秒)
--(大于462时,自动重置为0)
--(对非副角色则返回0)
local function GetInSecondFrameCount(player)
	local data = Ents:GetTempData(player).BCBA
	if data then
		return data.InSecondFrameCount or 0
	end
	return 0
end


--临时数据
local function GetBCBATempData(player)
	local data = Ents:GetTempData(player)
	data.BCBA = data.BCBA or {
		Twin = nil,
		InSecondFrameCount = 0,
		ShockDamage = 0,
		RedeathTimeOut = 0,
		QuickRedeathWait = 42
	}

	return data.BCBA
end

--长久数据
local function GetBCBAData(player)
	local data = Players:GetData(player)
	data.BCBAInfo = data.BCBAInfo or {
		State = "",
		TwinIndex = "",
		Origin = false,
		SavedActive = {}
	}

	return data.BCBAInfo
end

--获取玩家的索引(道具种子)
local function GetPlayerIndex(player)
	local idx = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_IBS):GetSeed()
	return tostring(idx)
end

--用索引获取玩家
local function GetPlayerByIndex(index)
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if GetPlayerIndex(player) == index then
			return player
		end
	end
	return nil
end

--尝试切换主副角色
function IBS_API.BCBA:TrySwitch(player)
	local err,mes = mod:CheckArgType(player, "userdata", "player", 1, ErrorTipName)
	if err then error(mes, 2) end

	local tdata = Ents:GetTempData(player).BCBA

	if tdata and tdata.Twin then
		local player2 = tdata.Twin
		
		--检测副角色状态
		if player2:Exists() and not player2:IsDead() then
			local data = GetBCBAData(player)
			local data2 = GetBCBAData(player2)

			--副切主
			player2.Parent = nil
			player2:ClearEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK)
			player2:SetColor(Color(1,1,0,0.5,1,1,0), 30, 7, true, false)
			if data2.State == "Second" then data2.State = "Main" end
			
			--主切副
			player.Parent = player2
			player:ClearEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK)
			if data.State == "Main" then data.State = "Second" end
			
			do --副角色临时移除模组主动
				for slot = 0,2 do
					local item = player:GetActiveItem(slot)
					local charges = 0
					
					if (item > 733) and not ExcludedActive[item] then 
						charges = Players:GetSlotCharges(player, slot, true, true)
						
						if (slot == 2) then
							player:SetPocketActiveItem(0, ActiveSlot.SLOT_POCKET)
						else
							player:RemoveCollectible(item, true, slot, false)
						end
					else
						item = 0
					end
					
					data.SavedActive[slot] = {Item = item, Charges = charges}
					
					local active2 = data2.SavedActive[slot]
					if active2 and (active2.Item > 0) then
						if (slot == 2) then
							player2:SetPocketActiveItem(active2.Item, ActiveSlot.SLOT_POCKET)
							player2:SetActiveCharge(active2.Charges, slot)
						else
							player2:AddCollectible(active2.Item, active2.Charges, false, slot)
						end	
					end
				end
			end			
			
			Game():GetHUD():AssignPlayerHUDs()
		end
	end
end

--角色初始化
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_,player)
	local game = Game()
	local playerType = player:GetPlayerType()

	--该隐自带亚伯
	if playerType == (PlayerType.PLAYER_CAIN) then
		player:AddCollectible(CollectibleType.COLLECTIBLE_ABEL)
	end
end)

--角色属性
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_,player, flag)
	local playerType = player:GetPlayerType()

	if playerType == (IBS_Player.bcain) then
		if flag == CacheFlag.CACHE_RANGE then
			Stats:Range(player, -1)
		end
		if flag == CacheFlag.CACHE_LUCK then
			Stats:Luck(player, -1)
		end		
	end
	
	if playerType == (IBS_Player.babel) then
		if flag == CacheFlag.CACHE_RANGE then
			Stats:Range(player, 2)
		end
		if flag == CacheFlag.CACHE_SHOTSPEED then
			Stats:ShotSpeed(player, -0.1)
		end
		if flag == CacheFlag.CACHE_LUCK then
			Stats:Luck(player, -2)
		end			
	end
end)
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, function(_,player, flag)
	local playerType = player:GetPlayerType()

	if playerType == (IBS_Player.bcain) then
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 1.2
		end
	end	
	if playerType == (IBS_Player.babel) then
		if flag == CacheFlag.CACHE_FIREDELAY then
			Stats:TearsMultiples(player, 1.2)
		end	
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 0.9
		end
	end
	
	--副角色属性衰减
	if flag == CacheFlag.CACHE_DAMAGE then
		local f = GetInSecondFrameCount(player)
		if f > 0 then
			local mult = math.max(0, 1 - (f/1020))
			player.Damage = player.Damage * mult
		end
	end	
end)

--变身
local function Henshin(_,player)
	local canHenshin = false
	
	--检测1钥匙,道具亚伯和幸运脚,饰品回形针
	if (player:GetNumKeys() > 0) and player:HasCollectible(CollectibleType.COLLECTIBLE_ABEL) and player:HasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT) then	
		for slot = 0,1 do
			if player:GetTrinket(slot) == TrinketType.TRINKET_PAPER_CLIP then
				player:TryRemoveTrinket(TrinketType.TRINKET_PAPER_CLIP)
				player:AddKeys(-1)
				player:RemoveCollectible(CollectibleType.COLLECTIBLE_ABEL, true)
				player:RemoveCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT, true)
				canHenshin = true
				break
			end
		end
	end

	if canHenshin then
		player:ChangePlayerType(IBS_Player.bcain)

		local tdata = GetBCBATempData(player)
		local data = GetBCBAData(player)
		
		--生成副角色
		if not tdata.Twin and (data.TwinIndex == "") then
			local game = Game()
			Isaac.ExecuteCommand("addplayer "..tostring(IBS_Player.babel).." "..tostring(player.ControllerIndex))

			local player2 = Isaac.GetPlayer(game:GetNumPlayers() - 1)
			local tdata2 = GetBCBATempData(player2)
			local data2 = GetBCBAData(player2)
			
			mod:DelayFunction(function() player2:AnimateAppear() end, 1)
			player2:AddControlsCooldown(90)
			player2.Position = player.Position
			player2.Velocity = Vector(7,0)
			player2.Parent = player
			tdata2.Twin = player
			data2.State = "Second"
			data2.TwinIndex = GetPlayerIndex(player)
			
			mod:DelayFunction(function() player:AnimateAppear() end, 1)
			player:AddControlsCooldown(90)
			player:SetColor(Color(1,1,0,0.5,1,1,0), 30, 7, true, false)
			player.Velocity = Vector(-7,0)
			tdata.Twin = player2
			data.State = "Main"
			data.TwinIndex = GetPlayerIndex(player2)
			data.Origin = true
			
			game:GetHUD():AssignPlayerHUDs()
			game:ShakeScreen(20)
			SFXManager():Play(SoundEffect.SOUND_LAZARUS_FLIP_DEAD)
			SFXManager():Play(SoundEffect.SOUND_LAZARUS_FLIP_ALIVE)
		end
	end	
end
mod:AddCallback(IBS_Callback.BENIGHTED_HENSHIN, Henshin, PlayerType.PLAYER_CAIN)

--频率限制,用于修正
local OffsetTimeOut = 0
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if OffsetTimeOut > 0 then
		OffsetTimeOut = OffsetTimeOut - 1
	end	
end)

--死亡回放/生死逆转切换主副角色
local function Switch(_,item, rng, player, flags, slot)
	local data = Ents:GetTempData(player).BCBA
	
	if data and (data.RedeathTimeOut <= 0) and (OffsetTimeOut <= 0) and (flags & UseFlag.USE_CARBATTERY <= 0) then
		local tdata = GetBCBATempData(player)
		local player2 = tdata.Twin
		
		if player2 and player2:Exists() and not player2:IsDead() then
			local tdata2 = GetBCBATempData(player2)
			
			tdata2.RedeathTimeOut = 60
			
			--切换时尝试对周围的敌人造成伤害
			if tdata2.ShockDamage > 0 then
				for _,target in pairs(Isaac.FindInRadius(player2.Position, 100, EntityPartition.ENEMY)) do
					if Ents:IsEnemy(target) then
						target:TakeDamage(tdata2.ShockDamage, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0)
					end
				end
				player2:SetMinDamageCooldown(60)
				sfx:Play(SoundEffect.SOUND_DEATH_CARD, 1)
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 5, player2.Position, Vector.Zero, nil)
				Game():ShakeScreen(30)
				
				tdata2.ShockDamage = 0
			end				
			
			--刷新角色属性
			player2:AddCacheFlags(CacheFlag.CACHE_ALL)
			player2:EvaluateItems()
		end
	
		data.RedeathTimeOut = 60
		tdata.ShockDamage = 0
		OffsetTimeOut = 2
		IBS_API.BCBA:TrySwitch(player)
		
		--刷新角色属性
		player:AddCacheFlags(CacheFlag.CACHE_ALL)
		player:EvaluateItems()		
		
		return {ShowAnim = false, Discharge = true}
	end	
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, Switch, IBS_Item.redeath)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, Switch, CollectibleType.COLLECTIBLE_FLIP)

--更新
local function OnUpdate(_,player)
	local data = Players:GetData(player).BCBAInfo

	if data then
		local tdata = GetBCBATempData(player)
		if tdata.RedeathTimeOut > 0 then tdata.RedeathTimeOut = tdata.RedeathTimeOut - 1 end
		if not tdata.Twin then tdata.Twin = GetPlayerByIndex(data.TwinIndex) end
		
		local player2 = tdata.Twin
		local MAIN = (data.State == "Main")
		local SECOND = (data.State == "Second")

		--副角色存在时,调整Parent以及死亡回放
		if player2 and (player2:Exists() and not player2:IsDead()) then
			if MAIN and player.Parent then
				player.Parent = nil
			elseif SECOND and not player.Parent then
				player.Parent = player2
			end
			
			--将死亡回放添加至2号副主动(同骰子袋)
			if (player:GetActiveItem(ActiveSlot.SLOT_POCKET2) == 0) then
				player:SetPocketActiveItem(IBS_Item.redeath, ActiveSlot.SLOT_POCKET2, false)
			end
			
			--长按丢弃键快速切换至死亡回放(覆盖骰子袋给的骰子)
			if Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
				if tdata.QuickRedeathWait > 0 then
					tdata.QuickRedeathWait = tdata.QuickRedeathWait - 1
				else				
					player:SetPocketActiveItem(IBS_Item.redeath, ActiveSlot.SLOT_POCKET2, false)
				end
			else
				if tdata.QuickRedeathWait ~= 42 then tdata.QuickRedeathWait = 42 end
			end			
		end

		--主
		if MAIN then
			if tdata.InSecondFrameCount ~= 0 then tdata.InSecondFrameCount = 0 end
		end

		--副
		if SECOND then
			local f = tdata.InSecondFrameCount
			
            player:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK)
			player:SetColor(Color(0.5,0.5,0.5, math.max(0.1, 1 - f / 1140)), 1, 1, true, true)
			tdata.InSecondFrameCount = tdata.InSecondFrameCount + 1
			
			--17秒前无敌
			if (f < 1020) then
				player:SetMinDamageCooldown(2)
			end
			
			---美德书/生死逆转固定时间
			if IBS_API.BCBA:AnyHasCollectible(player, CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) or IBS_API.BCBA:AnyHasCollectible(player, CollectibleType.COLLECTIBLE_FLIP) then				
				tdata.InSecondFrameCount = 0
			end
			
			--冲击波可发动提示
			if (f == 421) then
				sfx:Play(SoundEffect.SOUND_BEEP, 2, 0, false, 0.5)
				local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 0, player.Position, Vector.Zero, nil):ToEffect()
				poof.Parent = player
				poof:FollowParent(player)
			end
			
			--超过17秒后扣血
			if (f > 1020) then
				tdata.InSecondFrameCount = 1201
				player:TakeDamage(3, DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_IV_BAG, EntityRef(player), 30)
			end
			
			--刷新角色攻击力
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()			
			
			--记录冲击伤害
			tdata.ShockDamage = (f > 420 and 7 * f/30) or tdata.ShockDamage
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnUpdate)

--模拟清理房间充能
local function CleanChargeSimulation()
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = Players:GetData(player).BCBAInfo
		
		if data and data.SavedActive then
			for slot = 0,2 do
				local active = data.SavedActive[slot]
				
				if active and (active.Item > 0) then
					local itemConfig = config:GetCollectible(active.Item)
					local chargeType = itemConfig.ChargeType
					local normal = (chargeType == ItemConfig.CHARGE_NORMAL)
					local timed = (chargeType == ItemConfig.CHARGE_TIMED)
					
					if normal or timed then
						local maxCharges = itemConfig.MaxCharges
						
						if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
							maxCharges = maxCharges * 2
						end
						
						if active.Charges < maxCharges then
							if normal then
								active.Charges = active.Charges + 1
							elseif timed then
								active.Charges = math.min(active.Charges + itemConfig.MaxCharges, maxCharges)
							end

							if active.Charges >= maxCharges then
								sfx:Play(SoundEffect.SOUND_BATTERYCHARGE)
							else
								sfx:Play(SoundEffect.SOUND_BEEP)
							end
						end
					end
				end
			end	
		end	
	end	
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CleanChargeSimulation)
mod:AddCallback(IBS_Callback.GREED_NEW_WAVE, CleanChargeSimulation)

--模拟自充
local function TimedChargeSimulation()
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = Players:GetData(player).BCBAInfo
		
		if data and data.SavedActive then
			for slot = 0,2 do
				local active = data.SavedActive[slot]
				
				if active and (active.Item > 0) then
					local itemConfig = config:GetCollectible(active.Item)
					local chargeType = itemConfig.ChargeType
					
					if (chargeType == ItemConfig.CHARGE_TIMED) then
						local maxCharges = itemConfig.MaxCharges
						
						if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
							maxCharges = maxCharges * 2
						end
						
						if active.Charges < maxCharges then
							active.Charges = active.Charges + 1
							
							if (active.Charges == maxCharges - 1) or (active.Charges == itemConfig.MaxCharges - 1) then
								sfx:Play(SoundEffect.SOUND_BEEP)
							end
						end
					end
				end
			end	
		end	
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, TimedChargeSimulation)

--必需修正
--在退出游戏时切换至初始角色(顺便刷新副角色状态时长),防止控制器判断出错导致无法进行游戏
local function NecessaryOffset()
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = Players:GetData(player).BCBAInfo

		if data then
			if (data.State == "Main") and not data.Origin then
				IBS_API.BCBA:TrySwitch(player)
			end
			if (data.State == "Second") then
				local tdata = GetBCBATempData(player)
				if tdata.InSecondFrameCount ~= 0 then
					tdata.InSecondFrameCount = 0
				end
			end
		end
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, CallbackPriority.IMPORTANT, NecessaryOffset)

--必需修正2
--在使用创世纪时切换至非初始角色,防止其消失
local function NecessaryOffset2()
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = Players:GetData(player).BCBAInfo
		
		if data and (data.State == "Main") and data.Origin then
			IBS_API.BCBA:TrySwitch(player)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, NecessaryOffset2, CollectibleType.COLLECTIBLE_GENESIS)

--新房间设置副角色位置
local function NewRoom()
	local room = Game():GetRoom()
	local centerPos = room:GetCenterPos()
	
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		
		if IBS_API.BCBA:IsSecondPlayer(player) and not IBS_API.BCBA:AnyHasCollectible(player, CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			local pos = player.Position
			player.Position = room:FindFreePickupSpawnPosition(Vector(2*(centerPos.X) - pos.X , 2*(centerPos.Y) - pos.Y))
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, NewRoom)
				
--死亡判定
local function OnKilled(_,ent)
	local player = ent:ToPlayer()
	
	if player and Players:GetData(player).BCBAInfo and (player:GetExtraLives() <= 0 or not player:WillPlayerRevive()) then
		IBS_API.BCBA:TrySwitch(player) --自动切换角色,防止游戏结束
		
		local deathPosition = player.Position
		local data = GetBCBAData(player)		
		local tdata = GetBCBATempData(player)
		local player2 = tdata.Twin
		local data2 = (player2 and GetBCBAData(player2))
		local cachedItems = Players:GetPlayerCollectibles(player)
		local cachedDataActive = data.SavedActive
		local cachedActive = {}
		
		--缓存主动道具
		for Slot = 0,1 do
			local item = player:GetActiveItem(Slot)
			local charges = 0
			
			if item > 0 then 
				charges = Players:GetSlotCharges(player, Slot, true, true)
			end
			
			cachedActive[Slot] = {Item = item, Charges = charges}
		end
		
		--延迟2秒,检测是否真的死亡(同时兼容部分模组复活效果)
		mod:DelayFunction(function()
			if (not player:Exists()) or player:IsDead() then
				if player2 then
					player2:AnimateSad()
					player2:AddBrokenHearts(6)
					data2.Origin = true --变为初始角色
					
					--移除死亡回放
					if (player2:GetActiveItem(ActiveSlot.SLOT_POCKET2) == IBS_Item.redeath) then
						player2:SetPocketActiveItem(0, ActiveSlot.SLOT_POCKET2)
					end	
				end
				
				do --掉落主动道具
					for slot = 0,1 do
						local active = cachedDataActive[slot]
						
						if active and (active.Item > 0) then
							local item = active.Item
							local pos = Game():GetRoom():FindFreePickupSpawnPosition(deathPosition, 0, true)
							local pickup = Isaac.Spawn(5, 100, item, pos, Vector.Zero, nil):ToPickup()

							pickup.Touched = true
							pickup:Morph(5, 100, item, false, false, true) --防止某些替换道具的效果
							pickup.Charge = active.Charges
							pickup.Wait = 60
						end
					end	
				end

				do --掉落主动道具
					for slot,active in pairs(cachedActive) do
						local item = active.Item
						
						if item > 0 then 
							local pos = Game():GetRoom():FindFreePickupSpawnPosition(deathPosition, 0, true)
							local pickup = Isaac.Spawn(5, 100, item, pos, Vector.Zero, nil):ToPickup()
							
							pickup.Touched = true
							pickup:Morph(5, 100, item, false, false, true) --防止某些替换道具的效果
							pickup.Charge = active.Charges
							pickup.Wait = 60
						end
					end	
				end

				do --被动道具继承
					if player2 then
						for item,num in pairs(cachedItems) do
							if (config:GetCollectible(item).Type ~= ItemType.ITEM_ACTIVE) then
								for i = 1,num do
									player2:AddCollectible(item, 0, false)
								end
							end	
						end
					end	
				end
			end
		end, 60)
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, OnKilled, EntityType.ENTITY_PLAYER)

--操作
local function CheckInput(_,ent, hook, action)
	local player = (ent and ent:ToPlayer())
	
	if player then
		local Press = (hook == InputHook.IS_ACTION_PRESSED)
		local Trigger = (hook == InputHook.IS_ACTION_TRIGGERED)
		local GetValue = (hook == InputHook.GET_ACTION_VALUE)
		local cid = player.ControllerIndex
	
		--主角色按地图键立定
		if IBS_API.BCBA:IsMainPlayer(player) and (action >= 0 and action <= 3) and Input.IsActionPressed(ButtonAction.ACTION_MAP, cid) then
			if Press or Trigger then
				return false
			elseif GetValue then
				return 0
			end
		end
	
		--副角色
		if IBS_API.BCBA:IsSecondPlayer(player) then
			--无长子权则移动和射击操作反转
			if (action >= 0 and action <= 7) and GetValue and not IBS_API.BCBA:AnyHasCollectible(player, CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
				return -Input.GetActionValue(action, cid)
			end
			
			--忽略副角色的操作(但只对原版有效,无法忽略模组的操作检测)
			if (action == ButtonAction.ACTION_ITEM) or (action == ButtonAction.ACTION_PILLCARD) or (action == ButtonAction.ACTION_DROP) then
				if Press or Trigger then
					return false
				elseif GetValue then
					return 0
				end
			end
		end	
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_INPUT_ACTION, -999, CheckInput)

--副角色无敌
local function PreTakeDMG(_,ent, amount, flag, source)
	local player = ent:ToPlayer()
	if player and (source.Type ~= EntityType.ENTITY_SLOT) and IBS_API.BCBA:IsSecondPlayer(player) and (GetInSecondFrameCount(player) < 1020) then
		return false
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -999, PreTakeDMG)

--副角色无视碰撞
local function PrePlayerCollision(_,player)
	if IBS_API.BCBA:IsSecondPlayer(player) then
		return true
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, -999, PrePlayerCollision)

--副角色无视碰撞(对掉落物则1秒后再无视)
local function PreOtherCollision(_,ent, other)
	local player = other:ToPlayer()
	
	if player and IBS_API.BCBA:IsSecondPlayer(player) then
		if ent:ToPickup() then
			if (GetInSecondFrameCount(player) >= 60) then
				return true
			end
		else
			return true
		end
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_COLLISION, -999, PreOtherCollision)
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, -999, PreOtherCollision)
