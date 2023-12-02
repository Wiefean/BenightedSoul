--玩家实体相关函数

local mod = Isaac_BenightedSoul
local Ents = mod.IBS_Lib.Ents

local config = Isaac.GetItemConfig()

local Players = {}


--读取玩家数据(保存一整局)
function Players:GetData(player)
	local seedReference = CollectibleType.COLLECTIBLE_SAD_ONION
	local playerType = player:GetPlayerType()

	--以扫和里拉特殊对待
	if playerType == PlayerType.PLAYER_LAZARUS2_B then
		seedReference = CollectibleType.COLLECTIBLE_INNER_EYE
	elseif playerType ~= PlayerType.PLAYER_ESAU then
		player = player:GetMainTwin() --获取主玩家(针对对里骨等)
	end

	--每个玩家获取的道具种子不同且固定,用作索引再合适不过
	local idx = player:GetCollectibleRNG(seedReference):GetSeed()
	idx = tostring(idx)

	--尝试初始化数据
	IBS_Data.GameState.Temp.PlayerData[idx] = IBS_Data.GameState.Temp.PlayerData[idx] or {}

	return IBS_Data.GameState.Temp.PlayerData[idx]
end


--获取玩家的射击瞄准方向向量
function Players:GetAimingVector(player, ignoreMouse, mouseCenter)
	mouseCenter = mouseCenter or player.Position --鼠标中心位置,默认为角色位置
	if (not ignoreMouse) and (player.ControllerIndex == 0) and Input.IsMouseBtnPressed(0) then 
		return (Input.GetMousePosition(true) - mouseCenter):Normalized()
	end

    return player:GetShootingJoystick()
end


--传送至特定位置
function Players:TeleportToPosition(player, pos, showAnim, playSound, dmgCD)
	if showAnim then
		local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position,Vector.Zero, nil)
		local spr = poof:GetSprite()
		spr:Load(player:GetSprite():GetFilename(), true)
		spr:Play("TeleportUp")
		player:AnimateTeleport(false)
	end
	
	if playSound then
		SFXManager():Play(SoundEffect.SOUND_HELL_PORTAL1)
		SFXManager():Play(SoundEffect.SOUND_HELL_PORTAL2)
	end
	
	if dmgCD then
		player:SetMinDamageCooldown(dmgCD)
	end
	
    player.Position = pos
end


--以特定条件获取玩家身上的道具ID和符合条件的道具数量
--(不建议频繁触发该函数)
--[[条件示例:
local function condition(itemConfig, num)
	if itemConfig.Quality ~= 4 then  --不为四级道具则不算
		return 0
	end
	
	if num > 3 then num = 3 end  --最多算三个该道具
	
	return num
end
]]
function Players:GetPlayerCollectibles(player, condition)
    local results = {}
    local totalNum = 0

    for id = 1, config:GetCollectibles().Size do
        local itemConfig = config:GetCollectible(id)
        if (itemConfig) then
            local num = player:GetCollectibleNum(id, true)
			
			--没有输入条件时不处理
            if (condition ~= nil) then
                num = condition(itemConfig, num) or num
            end
			
            if (num > 0) then
                results[id] = num
                totalNum = totalNum + num
            end
        end
    end
	
    return results, totalNum
end


--获取所有玩家拥有指定道具的数量
function Players:GetTotalCollectibleNum(item, ignoreEffect)
	ignoreEffect = ignoreEffect or false
	local num = 0

	for i = 0, Game():GetNumPlayers(0) - 1 do
		local player= Isaac.GetPlayer(i)
		num = num + player:GetCollectibleNum(item, ignoreEffect)
	end
	
	return num
end


--任意玩家拥有指定道具
function Players:AnyHasCollectible(item, ignoreEffect)
	ignoreEffect = ignoreEffect or false
	for i = 0, Game():GetNumPlayers(0) - 1 do
		local player= Isaac.GetPlayer(i)
		if player:HasCollectible(item, ignoreEffect) then
			return true
		end
	end
	
	return false
end


--获取所有玩家拥有指定饰品的倍率
--[[倍率解释:
普通饰品 + 1
金饰品 + 2
持有妈妈的盒子 + 1 (不叠加)
]]
function Players:GetTotalTrinketMult(trinket)
	local mult = 0

	for i = 0, Game():GetNumPlayers(0) - 1 do
		local player= Isaac.GetPlayer(i)
		mult = mult + player:GetTrinketMultiplier(trinket)
	end
	
	return mult
end


--任意玩家拥有指定饰品
function Players:AnyHasTrinket(trinket, ignoreEffect)
	ignoreEffect = ignoreEffect or false
	for i = 0, Game():GetNumPlayers(0) - 1 do
		local player= Isaac.GetPlayer(i)
		if player:HasTrinket(trinket, ignoreEffect) then
			return true
		end
	end
	
	return false
end


--添加吞下的饰品(硬核)
function Players:AddMeltedTrinket(player, trinket, num, touched)
	local GoodPosition = Vector(-7250,-7250)
	local mainSlot = player:GetTrinket(0)
	local secondSlot = player:GetTrinket(1)
	
	--移除原有饰品及其掉落物
	if (mainSlot + secondSlot > 0) then
		player:DropTrinket(GoodPosition, true)
		for _,pickup in pairs(Isaac.FindInRadius(GoodPosition, 20, EntityPartition.PICKUP)) do
			if (pickup.Variant == PickupVariant.PICKUP_TRINKET) and (pickup.FrameCount <= 1) then
				pickup:Remove()
			end	
		end		
	end
	
	--添加并吞下选定饰品
	for i = 1,num do
		player:AddTrinket(trinket, touched)
		player:UseActiveItem(479, false, false)		
	end
	
	--归还原有饰品
	if mainSlot > 0 then player:AddTrinket(mainSlot, false) end
	if secondSlot > 0 then player:AddTrinket(secondSlot, false) end
end


--吞下选定饰品(硬核)
--(成功吞下返回true,否则返回false)
function Players:MeltTrinket(player, trinket)
	local SUCCESS = false
	local GoodPosition = Vector(-7250,-7250)
	local mainSlot = player:GetTrinket(0)
	local secondSlot = player:GetTrinket(1)
	local fixedMainSlot = mainSlot
	local fixedSecondSlot = secondSlot
	
	--金饰品修正
	if fixedMainSlot > 32768 then fixedMainSlot = fixedMainSlot - 32768 end
	if fixedSecondSlot > 32768 then fixedSecondSlot = fixedSecondSlot - 32768 end
	
	--分类讨论
	if (fixedMainSlot == trinket) and (fixedSecondSlot == trinket) then --两个都是直接吞
		player:UseActiveItem(479, false, false)	
	elseif (fixedMainSlot == trinket) and (fixedSecondSlot ~= trinket) then --主是副不是
		SUCCESS = true
		player:DropTrinket(GoodPosition, true)
		player:AddTrinket(trinket, false)
		player:UseActiveItem(479, false, false)
		if secondSlot > 0 then player:AddTrinket(secondSlot, false) end
	elseif (fixedMainSlot ~= trinket) and (fixedSecondSlot == trinket) then --主不是副是
		SUCCESS = true
		player:DropTrinket(GoodPosition, true)
		player:AddTrinket(trinket, false)
		player:UseActiveItem(479, false, false)
		if mainSlot > 0 then player:AddTrinket(mainSlot, false) end	
	end
	
	--移除饰品掉落物
	if SUCCESS then
		for _,pickup in pairs(Isaac.FindInRadius(GoodPosition, 20, EntityPartition.PICKUP)) do
			if (pickup.Variant == PickupVariant.PICKUP_TRINKET) and (pickup.FrameCount <= 1) then
				pickup:Remove()
			end	
		end		
	end
	
	return SUCCESS
end


--无视雪花盒添加魂心(硬核)
function Players:AddRawSoulHearts(player, num)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_ALABASTER_BOX, true) then
        local alabasterCharges = {}
        for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do   
            if (player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_ALABASTER_BOX) then
                alabasterCharges[slot] = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
                if (num > 0) then
                    player:SetActiveCharge(12, slot)
                else
                    player:SetActiveCharge(0, slot)
                end
            end
        end

        player:AddSoulHearts(num)

        for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do   
            if (player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_ALABASTER_BOX) then
                player:SetActiveCharge(alabasterCharges[slot], slot)
            end
        end
    else
        player:AddSoulHearts(num)
    end
end


--无视雪花盒添加黑心(硬核)
function Players:AddRawBlackHearts(player, num)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_ALABASTER_BOX, true) then
        local alabasterCharges = {}
        for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do   
            if (player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_ALABASTER_BOX) then
                alabasterCharges[slot] = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
                if (num > 0) then
                    player:SetActiveCharge(12, slot)
                else
                    player:SetActiveCharge(0, slot)        
                end
            end
        end

        player:AddBlackHearts(num)

        for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do   
            if (player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_ALABASTER_BOX) then
                player:SetActiveCharge(alabasterCharges[slot], slot)
            end
        end
    else
        player:AddBlackHearts(num)
    end
end


do --充能区 

--临时充能数据
local function GetChargeData(player)
	local data = Ents:GetTempData(player)
	data.SETCHARGE = data.SETCHARGE or {}

	return data.SETCHARGE
end

--设置充能数据
function Players:SetChargeData(player, slot, charge, soul, blood)
	local data = GetChargeData(player)
	if (not data[slot]) then
		data[slot] = {
			SetCharge = charge,
			SoulCost = soul or 0,
			BloodCost = blood or 0
		}
	end
end

--更新充能数据
local function UpdateChargeData(_,player)
	local data = GetChargeData(player)

	for slot,v in pairs(data) do
		player:SetActiveCharge(math.max(0, v.SetCharge), slot)
		player:AddSoulCharge(-v.SoulCost)
		player:AddBloodCharge(-v.BloodCost)
		data[slot] = nil	
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, UpdateChargeData)

--获取一个主动槽的已充能数
--(自充道具的充能数是逻辑帧数,30逻辑帧为1秒,建议获取时忽略魂心/红心充能)
function Players:GetSlotCharges(player, slot, ignoreSoul, ignoreBlood)
	if (slot < ActiveSlot.SLOT_PRIMARY or slot > ActiveSlot.SLOT_POCKET) then return 0 end
	local charges = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
	
	--可选择是否忽略魂心/红心充能
	if not ignoreSoul then
		charges = charges + player:GetEffectiveSoulCharge()
	end
	if not ignoreBlood then
		charges = charges + player:GetEffectiveBloodCharge()
	end
	
	return charges
end


--获取一个主动槽的已充能数,但针对自充主动
--(与上一个函数基本一致,但充能单位由格改为逻辑帧,30逻辑帧为1秒.对非自充主动只会返回0)
function Players:GetTimedSlotCharges(player, slot, ignoreSoul, ignoreBlood)
	if (slot < ActiveSlot.SLOT_PRIMARY or slot > ActiveSlot.SLOT_POCKET) then return 0 end
	local itemConfig = config:GetCollectible(player:GetActiveItem(slot))
	local type = itemConfig.ChargeType
	if (type ~= ItemConfig.CHARGE_TIMED) then return 0 end
	
	local charges = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
	local maxCharges = itemConfig.MaxCharges
	
	--可选择是否忽略魂心/红心充能
	if not ignoreSoul then
		charges = charges + maxCharges*(player:GetEffectiveSoulCharge())
	end
	if not ignoreBlood then
		charges = charges + maxCharges*(player:GetEffectiveBloodCharge())
	end
	
	return charges
end


--由于官方自带的NeedsCharge函数对特殊充能道具无效,这里又定义了一个(缺点挺大的,用于特殊充能道具就好)
local function SpecialNeedsCharge(player, slot)
	local charges = Players:GetSlotCharges(player, slot, true, true)
	local maxCharges = config:GetCollectible(player:GetActiveItem(slot)).MaxCharges
	
	return charges < maxCharges
end

--为一个主动槽充能
--[[说明:
为自充道具充能一格视为充满一次
当force为true时,充能满了还会继续充能(即使没有蓄电池)
]]
--[[
充能槽动画和音效可以自行添加
Game():GetHUD():FlashChargeBar(player, slot) --动画
SFXManager():Play(SoundEffect.SOUND_BEEP) --充能音效
SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE) --充满音效
]]
function Players:ChargeSlot(player, slot, amount, includeSpecial, force, showAnim, playSound)
	if (slot < ActiveSlot.SLOT_PRIMARY or slot > ActiveSlot.SLOT_POCKET or amount < 0) then return end
	local itemConfig = config:GetCollectible(player:GetActiveItem(slot))
	local type = itemConfig.ChargeType
	local special = (type == ItemConfig.CHARGE_SPECIAL)
	local charged = false
	
	for i = 1,amount do
		if player:NeedsCharge(slot) or (special and SpecialNeedsCharge(player, slot)) or force then --当force为true时,充能满了还会继续充能(即使没有蓄电池)
			local charges = Players:GetSlotCharges(player, slot, true, true)
			
			--可选择是否为特殊充能道具充能
			if (type == ItemConfig.CHARGE_NORMAL) or (special and includeSpecial) then
				player:SetActiveCharge(charges + 1, slot)
				charged = true
			elseif (type == ItemConfig.CHARGE_TIMED) then --直接为自充道具充满
				player:FullCharge(slot)
				charged = true
			end
		else
			break
		end
	end
	
	if charged then
		if showAnim then
			Game():GetHUD():FlashChargeBar(player, slot)
		end	
		if playSound then
			local curCharges = Players:GetSlotCharges(player, slot, true, true)
			local maxCharges = itemConfig.MaxCharges
			
			if curCharges < maxCharges then
				SFXManager():Play(SoundEffect.SOUND_BEEP)
			elseif curCharges >= maxCharges then
				SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE)
			end	
		end	
	end
end


--为一个主动槽充能,但针对自充主动
--[[说明:
与上一个函数基本一致,但充能单位由格改为逻辑帧,30逻辑帧为1秒
对非自充主动无效果
当force为true时,充能满了还会继续充能(即使没有蓄电池)
]]
function Players:ChargeTimedSlot(player, slot, amount, force)
	if (slot < ActiveSlot.SLOT_PRIMARY or slot > ActiveSlot.SLOT_POCKET or amount < 0) then return end
	local type = config:GetCollectible(player:GetActiveItem(slot)).ChargeType
	if (type ~= ItemConfig.CHARGE_TIMED) then return end
	
	for i = 1,amount do
		if player:NeedsCharge(slot) or force then --当force为true时,充能满了还会继续充能(即使没有蓄电池)
			local charges = Players:GetSlotCharges(player, slot, true, true)
			player:SetActiveCharge(charges + 1, slot)
		else
			break
		end
	end
end


--消耗一个主动槽的充能
--[[说明:
自充道具消耗一格视为消耗满充能数
当force为true时,即使已充能数不足,仍会消耗充能(配合includeSpecial可用于自制吸电苍蝇XD)
当force为true时,不影响魂心/红心充能,ignoreSoul和ignoreBlood无用
在成功消耗充能时返回true,否则返回false
]]
--[[
音效可以自行添加
SFXManager():Play(SoundEffect.SOUND_BATTERYDISCHARGE)
]]
function Players:DischargeSlot(player, slot, amount, includeSpecial, force, ignoreSoul, ignoreBlood)
	if (slot < ActiveSlot.SLOT_PRIMARY or slot > ActiveSlot.SLOT_POCKET or amount < 0) then return false end
	local SUCCESS = false
	local itemConfig = config:GetCollectible(player:GetActiveItem(slot))
	local type = itemConfig.ChargeType
	local normal = (type == ItemConfig.CHARGE_NORMAL)
	local special = (type == ItemConfig.CHARGE_SPECIAL)
	local timed = (type == ItemConfig.CHARGE_TIMED)
	local maxCharges = itemConfig.MaxCharges
	local charges = Players:GetSlotCharges(player, slot, true, true)
	if timed then charges = math.floor(charges/maxCharges) end --将自充道具的充能数转换为常规充能数
	
	--可选择是否忽略魂心/红心充能
	local totalCharges = charges
	if not ignoreSoul then
		totalCharges = totalCharges + player:GetSoulCharge()
	end
	if not ignoreBlood then
		totalCharges = totalCharges + player:GetBloodCharge()
	end
	
	--可选择是否消耗特殊充能道具的充能
	if normal or (special and includeSpecial) then --常规/特殊
		if force or (charges >= amount) then
			Players:SetChargeData(player, slot, charges-amount)
			SUCCESS = true
		elseif (totalCharges >= amount) then
			amount = amount - charges	
			if (player:GetSoulCharge() > 0) then
				Players:SetChargeData(player, slot, 0, amount)
			elseif (player:GetBloodCharge() > 0) then
				Players:SetChargeData(player, slot, 0, 0, amount)
			end
			SUCCESS = true
		end
	elseif timed then --自充
		--charges已经被转换成常规充能数,这里再获取一次充能数
		local realCharges = Players:GetSlotCharges(player, slot, true, true)
	
		if force or (charges >= amount) then
			Players:SetChargeData(player, slot, realCharges-maxCharges)
			SUCCESS = true
		elseif (totalCharges >= amount) then
			amount = amount - charges
			if (player:GetSoulCharge() > 0) then
				Players:SetChargeData(player, slot, 0, amount)
			elseif (player:GetBloodCharge() > 0) then
				Players:SetChargeData(player, slot, 0, 0, amount)
			end
			SUCCESS = true
		end
	end
	
	return SUCCESS
end


--消耗一个主动槽的充能,但针对自充主动
--[[说明:
与上一个函数基本一致,但充能单位由格改为逻辑帧,30逻辑帧为1秒
对非自充主动无效果
当force为true时,即使已充能数不足,仍会消耗充能
当force为true时,不影响魂心/红心充能,ignoreSoul和ignoreBlood无用
在成功消耗充能时返回true,否则返回false
]]
function Players:DischargeTimedSlot(player, slot, amount, force, ignoreSoul, ignoreBlood)
	if (slot < ActiveSlot.SLOT_PRIMARY or slot > ActiveSlot.SLOT_POCKET or amount < 0) then return false end
	local itemConfig = config:GetCollectible(player:GetActiveItem(slot))
	if (itemConfig.ChargeType ~= ItemConfig.CHARGE_TIMED) then return false end
	
	local SUCCESS = false
	local charges = Players:GetSlotCharges(player, slot, true, true)
	local maxCharges = itemConfig.MaxCharges

	--可选择是否忽略魂心/红心充能
	local totalCharges = charges
	if not ignoreSoul then
		totalCharges = totalCharges + maxCharges*(player:GetSoulCharge())
	end
	if not ignoreBlood then
		totalCharges = totalCharges + maxCharges*(player:GetBloodCharge())
	end
	
	if force or (charges >= amount) then
		Players:SetChargeData(player, slot, charges-amount)
		SUCCESS = true
	elseif (totalCharges >= amount) then
		if (player:GetSoulCharge() > 0) then
			Players:SetChargeData(player, slot, 0, 1)
		elseif (player:GetBloodCharge() > 0) then
			Players:SetChargeData(player, slot, 0, 0, 1)
		end
		SUCCESS = true
	end
	
	return SUCCESS
end


end




--[[
do --隐藏道具魂火区

--妙妙位置
local GoodPosition = Vector(7250,7250)

--临时隐藏道具魂火数据
local function GetPlayerSecretWispData(player)
	local data = Ents:GetTempData(player)
	data.SECRETITEMWISP_PLAYER = data.SECRETITEMWISP_PLAYER or {}

	return data.SECRETITEMWISP_PLAYER
end

--设置隐藏道具魂火
local function SetSecretItemWisp(player, wisp)
	Ents:GetTempData(wisp).SECRETITEMWISP = {Player = player}
	wisp.Visible = false
	wisp.Position = GoodPosition
	wisp.Velocity = Vector.Zero	
	wisp:RemoveFromOrbit()
	wisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
end

--添加或移除隐藏道具魂火(在ModCallbacks.MC_EVALUATE_CACHE中判断CacheFlag.CACHE_FAMILIARS以使用)
function Players:EvaluateSecretItemWisp(player, item, num)
	local data = GetPlayerSecretWispData(player)
	if not data[item] then data[item] = 0 end
	data[item] = math.max(0, (data[item] + num))
	
	for i = 1,num do
		local wisp = player:AddItemWisp(item, GoodPosition)
		SetSecretItemWisp(player, wisp)
	end
end

--计算隐藏道具魂火数量
function Players:CountSecretItemWisps(player, item)
	local data = Ents:GetTempData(player).SECRETITEMWISP_PLAYER
	if data then
		return data[item]
	end
	return 0
end



--以下为又臭又长的处理道具魂火方法(顺便吐槽一下,明明直接给个添加隐藏道具的API就不用这么麻烦了,屑官方愣是不给)
--(其实就是把道具魂火集中在一个妙妙位置,再进行处理)

--查找隐藏道具魂火
local function FindSecretItemWisps(player, item)
	local result = {}
	for _,familiar in pairs(Isaac.FindInRadius(GoodPosition, 50, EntityPartition.FAMILIAR)) do
		if (familiar.Variant == FamiliarVariant.ITEM_WISP and familiar.SubType == item) then
			local data = Ents:GetTempData(familiar).SECRETITEMWISP
			if data and Ents:IsTheSame(data.Player, player) then
				table.insert(result, familiar)
			end
		end	
	end
	return result
end

--查找未处理的道具魂火
--(用于重新加载游戏,临时数据被清除时)
local function FindRawItemWisps(player, item)
	local result = {}
	for _,familiar in pairs(Isaac.FindInRadius(GoodPosition, 50, EntityPartition.FAMILIAR)) do
		if (familiar.Variant == FamiliarVariant.ITEM_WISP and familiar.SubType == item) then
			local data = Ents:GetTempData(familiar).SECRETITEMWISP
			if (not data) and Ents:IsTheSame(Ents:IsSpawnerPlayer(familiar, false), player) then
				table.insert(result, familiar)
			end
		end	
	end
	return result
end

--创造隐藏道具魂火
local function MakeSecretItemWisps(player, item, num)
	local rawWisps = FindRawItemWisps(player, item)
	
	if num <= #rawWisps then
		local made = 0
		for _,wisp in pairs(rawWisps) do
			SetSecretItemWisp(wisp)
			made = made + 1
			if made >= num then break end
		end
	else
		for _,wisp in pairs(rawWisps) do
			SetSecretItemWisp(wisp)
		end
		for i = 1,(num - #rawWisps) do
			local wisp = player:AddItemWisp(item, GoodPosition)
			SetSecretItemWisp(player, wisp)
		end		
	end
end

--更新隐藏道具魂火数据
local function UpdateSecretItemWispData(_, player)
	local data = Ents:GetTempData(player).SECRETITEMWISP_PLAYER
	if data then
		for item,num in pairs(data) do
			local secretWisps = FindSecretItemWisps(player, item)
			local diff = num - #secretWisps
			
			--少则添加,多则移除
			if diff > 0 then
				MakeSecretItemWisps(player, item, diff)
			elseif diff < 0 then
				local removed = 0
				for _,wisp in pairs(secretWisps) do
					wisp:Remove()
					removed = removed + 1
					if removed >= (-diff) then break end
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, UpdateSecretItemWispData)

--刷新数据
local function OnEvaluateCache(_,player, flag)
	if (flag == CacheFlag.CACHE_FAMILIARS) then
		local data = Ents:GetTempData(player).SECRETITEMWISP_PLAYER
		if data then
			for item,num in pairs(data) do
				data[item] = 0
			end
		end
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, -725, OnEvaluateCache)

--初始化隐藏道具魂火
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_,wisp)
	if Ents:GetTempData(wisp).SECRETITEMWISP then SetSecretItemWisp(wisp) end
end, FamiliarVariant.ITEM_WISP)

--保持隐藏道具魂火状态
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_,wisp)
	if Ents:GetTempData(wisp).SECRETITEMWISP then
		wisp.Visible = false
		wisp.Position = GoodPosition
		wisp.Velocity = Vector.Zero
	end	
end, FamiliarVariant.ITEM_WISP)

--无视隐藏道具魂火的碰撞
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_,wisp)
	if Ents:GetTempData(wisp).SECRETITEMWISP then return true end
end, FamiliarVariant.ITEM_WISP)

--无视隐藏道具魂火的伤害与被伤害
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_,ent, dmg, flag, source)
	local familiar = ent:ToFamiliar() or (source and source.Entity and source.Entity:ToFamiliar())
	if familiar and (familiar.Variant == FamiliarVariant.ITEM_WISP) and Ents:GetTempData(familiar).SECRETITEMWISP then
		return false
	end
end)

--隐藏道具魂火熄灭时,移除音效和特效
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_,familiar)
    if (familiar.Variant == FamiliarVariant.ITEM_WISP) and Ents:GetTempData(familiar).SECRETITEMWISP then
		SFXManager():Stop(SoundEffect.SOUND_STEAM_HALFSEC)
		for _,effect in pairs(Isaac.FindInRadius(familiar.Position, 2, EntityPartition.EFFECT)) do
			if (effect.Variant == EffectVariant.POOF01) or (effect.Variant == EffectVariant.TEAR_POOF_A) then
				effect:Remove()
			end
		end
    end
end, EntityType.ENTITY_FAMILIAR)

--移除隐藏道具魂火与美德书联动发射的眼泪
mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(_,tear)
	local familiar = (tear.SpawnerEntity and tear.SpawnerEntity:ToFamiliar())
	if familiar and (familiar.Variant == FamiliarVariant.ITEM_WISP) and Ents:GetTempData(familiar).SECRETITEMWISP then
		tear:Remove()
	end
end)

--在使用祭坛之前把隐藏道具魂火的归属玩家设为无,以此避免被移除
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function()
    for _,wisp in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP)) do
        if Ents:GetTempData(wisp).SECRETITEMWISP then
            wisp:ToFamiliar().Player = nil
        end
    end
end, CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR)

--使用祭坛之后再重新设置归属玩家
mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
    for _,wisp in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP)) do
		local data = Ents:GetTempData(wisp).SECRETITEMWISP
        if data then
            wisp:ToFamiliar().Player = data.Player
        end
    end
end, CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR)


end
]]

return Players