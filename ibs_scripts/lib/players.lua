--玩家实体相关函数

local mod = Isaac_BenightedSoul

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
function Players:ChargeSlot(player, slot, amount, includeSpecial, force)
	if (slot < ActiveSlot.SLOT_PRIMARY or slot > ActiveSlot.SLOT_POCKET or amount < 0) then return end
	local type = config:GetCollectible(player:GetActiveItem(slot)).ChargeType
	local special = (type == ItemConfig.CHARGE_SPECIAL)
	
	for i = 1,amount do
		if player:NeedsCharge(slot) or (special and SpecialNeedsCharge(player, slot)) or force then --当force为true时,充能满了还会继续充能(即使没有蓄电池)
			local charges = Players:GetSlotCharges(player, slot, true, true)
			
			--可选择是否为特殊充能道具充能
			if (type == ItemConfig.CHARGE_NORMAL) or (special and includeSpecial) then
				player:SetActiveCharge(charges + 1, slot)
			elseif (type == ItemConfig.CHARGE_TIMED) then --直接为自充道具充满
				player:FullCharge(slot)
			end
		else
			break
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
function Players:DisChargeSlot(player, slot, amount, includeSpecial, force, ignoreSoul, ignoreBlood)
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
		if (charges >= amount) or force then
			player:SetActiveCharge(charges - amount, slot)
			SUCCESS = true
		elseif (totalCharges >= amount) then
			player:SetActiveCharge(0, slot)
			amount = amount - charges	
			if (player:GetSoulCharge() > 0) then
				player:AddSoulCharge(-amount)
			elseif (player:GetBloodCharge() > 0) then
				player:AddBloodCharge(-amount)
			end
			SUCCESS = true
		end
	elseif timed then --自充
		--charges已经被转换成常规充能数,这里再获取一次充能数
		local realCharges = Players:GetSlotCharges(player, slot, true, true)
	
		if (charges >= amount) or force then
			player:SetActiveCharge(realCharges - maxCharges, slot)
			SUCCESS = true
		elseif (totalCharges >= amount) then
			player:SetActiveCharge(0, slot)
			amount = amount - charges
			if (player:GetSoulCharge() > 0) then
				player:AddSoulCharge(-amount)
			elseif (player:GetBloodCharge() > 0) then
				player:AddBloodCharge(-amount)
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
function Players:DisChargeTimedSlot(player, slot, amount, force, ignoreSoul, ignoreBlood)
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
	
	if (charges >= amount) or force then
		player:SetActiveCharge(charges - amount, slot)
		SUCCESS = true
	elseif (totalCharges >= amount) then
		amount = amount - charges
		amount = math.floor(amount/maxCharges) --将自充道具的充能数转换为常规充能数
		
		if (player:GetSoulCharge() > 0) then
			player:AddSoulCharge(-amount)
		elseif (player:GetBloodCharge() > 0) then
			player:AddBloodCharge(-amount)
		end
		SUCCESS = true
	end
	
	return SUCCESS
end


return Players