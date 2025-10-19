--玩家实体相关函数

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID
local IBS_ItemID = mod.IBS_ItemID
local Ents = mod.IBS_Lib.Ents
local Screens = mod.IBS_Lib.Screens

local game = Game()
local config = Isaac.GetItemConfig()

local Players = {}


--读取玩家数据(保存一整局)
--(可选择是否区分表骨与其灵魂的数据)
--(发光沙漏兼容在 /ibs_scripts/ibs_commons.lua)
function Players:GetData(player, differForgottenSoul)
	local seedReference = CollectibleType.COLLECTIBLE_SAD_ONION
	local playerType = player:GetPlayerType()

	--对于里拉,换一个道具种子对于表骨和其灵魂则可选择是否换
	if (playerType == PlayerType.PLAYER_LAZARUS2_B) then
		seedReference = CollectibleType.COLLECTIBLE_INNER_EYE
	elseif (playerType == PlayerType.PLAYER_THESOUL) and differForgottenSoul then
		seedReference = CollectibleType.COLLECTIBLE_SPOON_BENDER
	elseif (playerType ~= PlayerType.PLAYER_ESAU) then --以扫需要独立数据,故不获取主玩家
		player = player:GetMainTwin() --获取主玩家(针对对里骨等)
	end

	--每个玩家获取的道具种子不同且固定,用作索引再合适不过
	local idx = player:GetCollectibleRNG(seedReference):GetSeed()
	idx = tostring(idx)

	--尝试初始化数据
	local data = mod:GetIBSData('pdata')
	data[idx] = data[idx] or {}

	return data[idx]
end

--读取玩家另一个形态的数据(保存一整局)
--[[
对于里拉和表骨之外的角色,该函数返回nil
对于里拉,返回另一个形态的数据
对于表骨,返回其灵魂的独立数据(当上一函数"differForgottenSoul"为true时储存的数据)
对于表骨灵魂,返回表骨的数据

这个函数出现的原因是官方的player:GetOtherTwin(),player:GetSubPlayer()分别获取
里拉,表骨的另一形态时,获取的是另一个实体(可能是官方用于硬核储存玩家数据的),
导致上一函数无法正确获取另一形态的数据

发光沙漏兼容在 /ibs_scripts/ibs_commons.lua
]]
function Players:GetDataOfAnotherForm(player)
	local seedReference = CollectibleType.COLLECTIBLE_SAD_ONION
	local playerType = player:GetPlayerType()

	if (playerType == PlayerType.PLAYER_LAZARUS_B) then
		seedReference = CollectibleType.COLLECTIBLE_INNER_EYE
	elseif (playerType == PlayerType.PLAYER_LAZARUS2_B) then
		seedReference = CollectibleType.COLLECTIBLE_SAD_ONION
	elseif (playerType == PlayerType.PLAYER_THEFORGOTTEN) then
		seedReference = CollectibleType.COLLECTIBLE_SPOON_BENDER
	elseif (playerType == PlayerType.PLAYER_THESOUL) then
		seedReference = CollectibleType.COLLECTIBLE_SAD_ONION
	else
		return nil
	end

	--每个玩家获取的道具种子不同且固定,用作索引再合适不过
	local idx = player:GetCollectibleRNG(seedReference):GetSeed()
	idx = tostring(idx)

	--尝试初始化数据
	local data = mod:GetIBSData('pdata')
	data[idx] = data[idx] or {}

	return data[idx]
end

--使用主动是否能生成魂火
function Players:CanSpawnWisp(player, useFlags)
	return player:HasCollectible(584) and (useFlags & UseFlag.USE_NOANIM <= 0 or useFlags & UseFlag.USE_ALLOWWISPSPAWN > 0)
end

--添加护盾(调用影之书效果)
function Players:AddShield(player, frames)
	if frames <= 0 then return end
	local effects = player:GetEffects()
	local effect = effects:GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
	if not effect then
		effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
		effect = effects:GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
		effect.Cooldown = 0
	end
	effect.Cooldown = (effect.Cooldown or 0) + frames
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


--缓存角色位置,并在切换房间后自动复原(一般用于原地传送房间)
local cachedPlayerPos = {}
function Players:CachePosition(player)
    table.insert(cachedPlayerPos, {Player = player, Pos = player.Position})
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for k,v in pairs(cachedPlayerPos) do
		v.Player.Position = v.Pos
		table.remove(cachedPlayerPos, k)
	end
end)


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


do --多发区(用于兼容内眼等,利用了忏悔龙修复的MultiShotParams)

--发射多发眼泪
--[[
"loopFunc"是带参数"tear"的函数,用于为眼泪设置额外参数，以下的""loopFunc"类似
]]
function Players:FireTears(player, loopFunc, pos, vel, canBeEye, noTractorBeam, canTriggerStreakEnd, source, dmgMulti)
	local params = player:GetMultiShotParams(WeaponType.WEAPON_TEARS)
	for i = 0,params:GetNumTears()-1 do
		local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_TEARS, vel:Normalized(), player.ShotSpeed, params)
		local tear = player:FireTear(pos + posVel.Position, posVel.Velocity:Resized(vel:Length()), canBeEye, noTractorBeam, canTriggerStreakEnd, source, dmgMulti)
		if loopFunc ~= nil then
			loopFunc(tear)
			tear:Update()
		end
	end
end

--发射多发激光
function Players:FireTechLasers(player, loopFunc, pos, offsetID, vel, leftEye, oneHit, source, dmgMulti)
	local params = player:GetMultiShotParams(WeaponType.WEAPON_LASER)
	for i = 0,params:GetNumTears()-1 do
		local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_LASER, vel:Normalized(), player.ShotSpeed, params)
		local laser = player:FireTechLaser(pos + posVel.Position, offsetID, posVel.Velocity:Normalized(), leftEye, oneHit, source, dmgMulti)
		if loopFunc ~= nil then
			loopFunc(laser)
			laser:Update()
		end
	end
end

--发射多发硫磺火
function Players:FireBrimstones(player, loopFunc, pos, vel, source, dmgMulti)
	local params = player:GetMultiShotParams(WeaponType.WEAPON_BRIMSTONE)
	for i = 0,params:GetNumTears()-1 do
		local posVel = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_BRIMSTONE, vel:Normalized(), player.ShotSpeed, params)
		local laser = player:FireBrimstone(posVel.Velocity:Normalized(), source, dmgMulti)
		laser.Position = pos + posVel.Position
		if loopFunc ~= nil then
			loopFunc(laser)
		end
		laser:Update()
	end
end



end


do --血量区

--获取黑心数量(无法判断半黑心,对官方API非常无语)
function Players:GetBlackHearts(player)
	local decimalism = player:GetBlackHearts()
	local num = 0
	local t = {}

	while decimalism > 0 do
		rest = math.floor(decimalism % 2)
		t[#t+1] = rest
		decimalism = (decimalism - rest) / 2
	end
	for k,v in ipairs(t) do
		if v == 1 then 
			num = num + 2
		end
	end

	return math.max(0, num)
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



--以下为又臭又长的硬核获取血量方法(屑官方居然连血量判定都不给API)

--血量列表
local HpList = {

--红心
["Red"] = function(player)
	return player:GetHearts()
end,

--魂黑心
["SoulBlack"] = function(player)
	return player:GetSoulHearts()
end,

--白心
["Eternal"] = function(player)
	return player:GetEternalHearts()
end,

--骨心
["Bone"] = function(player)
	return player:GetBoneHearts()
end,

--腐心
["Rotten"] = function(player)
	return math.ceil(player:GetRottenHearts() / 2)
end,

--神圣屏障(无用,不能作为血量)
-- ["Mantle"] = function(player)
	-- return player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
-- end,

}

--是否忽略
local function IsIgnored(hpName, ignoration)
	if ignoration then
		for name,_ in pairs(ignoration) do
			if name == hpName then
				return true
			end
		end
	end	
	return false
end

--获取血量(ignoration为包含需要忽略的血量字符串名称的表)
function Players:GetHp(player, ignoration)
	local num = 0
	
	for name,func in pairs(HpList) do
		if not IsIgnored(name, ignoration) then
			local result = func(player)
			if type(result) == "number" then
				num = num + result
			end
		end
	end
	
	return num
end

end


do --按键输入区


--获取玩家的射击瞄准方向向量
function Players:GetAimingVector(player, ignoreMouse, mouseCenter)
	local markedPos = player:GetMarkedTarget()

	--十字准星兼容
    if markedPos then
        return (markedPos.Position - player.Position):Normalized()
    end

	mouseCenter = mouseCenter or player.Position --鼠标中心位置,默认为角色位置
	if (not ignoreMouse) and Options.MouseControl and (player.ControllerIndex == 0) and Input.IsMouseBtnPressed(0) then 
		return (Screens:GetMousePosition(true) - mouseCenter):Normalized()
	end


    return player:GetShootingJoystick():Normalized()
end

--是否在射击
function Players:IsShooting(player, ignoreControlCheck)
	--禁止控制中
	if (not ignoreControlCheck) and not player:AreControlsEnabled() then
		return false
	end
	
	--额外动画没播完
	if not player:IsExtraAnimationFinished() then
		return false
	end	
	
	--检测按键
	local cid = player.ControllerIndex
	local pressed = Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, cid) or
					Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, cid) or
					Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, cid) or
					Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, cid) or
					(cid == 0 and Options.MouseControl and Input.IsMouseBtnPressed(0))

	--射击方向向量为0
	if not pressed and self:GetAimingVector(player):Length() <= 0 then
		return false
	end

    return true
end


--是否按住或触发使用主动的按键
--(对于副主动2号位暂时没有处理方法,因此不能用于副主动2号位)
local function CheckActiveButtonInput(player, slot, Hook)
	if slot < 0 or slot > 2 then return false end
	if player:HasCurseMistEffect() then return false end --矿坑逃亡
	if not player:AreControlsEnabled() then return false end

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
				return Hook(action, cid) and not Input.IsActionPressed(ButtonAction.ACTION_DROP, cid)
			elseif (slot == ActiveSlot.SLOT_POCKET) then
				local pocket = player:GetPocketItem(0)
				return (pocket:GetSlot() ~= 0 and pocket:GetType() == PocketItemType.ACTIVE_ITEM) and Hook(action, cid) and Input.IsActionPressed(ButtonAction.ACTION_DROP, cid)		
			end
		end	
	else --其他
		if not Input.IsActionPressed(ButtonAction.ACTION_DROP, cid) then --这里主要是为了某些模组的兼容(但也会导致按住切换键时会返回false,总体来说无伤大雅)
			if (slot == ActiveSlot.SLOT_PRIMARY) then
				return Hook(ButtonAction.ACTION_ITEM, cid)
			elseif (slot == ActiveSlot.SLOT_POCKET) then
				local pocket = player:GetPocketItem(0)
				return (pocket:GetSlot() ~= 0 and pocket:GetType() == PocketItemType.ACTIVE_ITEM) and Hook(ButtonAction.ACTION_PILLCARD, cid)
			end
		end	
	end
	
	return false
end


--是否触发使用主动的按键
function Players:IsActiveButtonTriggered(player, slot)
	return CheckActiveButtonInput(player, slot, Input.IsActionTriggered)
end


--是否触发使用特定主动的按键
function Players:IsActiveItemButtonTriggered(player, item)
	for slot = 0,2 do
		if (player:GetActiveItem(slot) == item) and Players:IsActiveButtonTriggered(player, slot) then
			return true, slot
		end
	end
	
	return false, -1
end


--是否按住使用主动的按键
function Players:IsActiveButtonPressed(player, slot)
	return CheckActiveButtonInput(player, slot, Input.IsActionPressed)
end


--是否按住使用特定主动的按键
function Players:IsActiveItemButtonPressed(player, item)
	for slot = 0,2,2 do
		if (player:GetActiveItem(slot) == item) and Players:IsActiveButtonPressed(player, slot) then
			return true, slot
		end
	end
	
	return false, -1
end


end


do --充能区 

--临时充能数据
local function GetChargeData(player)
	local data = Ents:GetTempData(player)
	data.IBS_LIB_PLAYERS_SETCHARGE = data.IBS_LIB_PLAYERS_SETCHARGE or {}

	return data.IBS_LIB_PLAYERS_SETCHARGE
end

--设置充能数据
local function SetChargeData(player, slot, charge, soul, blood)
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
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, -9999, UpdateChargeData)

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
		if force or player:NeedsCharge(slot) or (special and SpecialNeedsCharge(player, slot)) then --当force为true时,充能满了还会继续充能(即使没有蓄电池)
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
			SetChargeData(player, slot, charges-amount)
			SUCCESS = true
		elseif (totalCharges >= amount) then
			amount = amount - charges	
			if (player:GetSoulCharge() > 0) then
				SetChargeData(player, slot, 0, amount)
			elseif (player:GetBloodCharge() > 0) then
				SetChargeData(player, slot, 0, 0, amount)
			end
			SUCCESS = true
		end
	elseif timed then --自充
		--charges已经被转换成常规充能数,这里再获取一次充能数
		local realCharges = Players:GetSlotCharges(player, slot, true, true)
	
		if force or (charges >= amount) then
			SetChargeData(player, slot, realCharges-maxCharges)
			SUCCESS = true
		elseif (totalCharges >= amount) then
			amount = amount - charges
			if (player:GetSoulCharge() > 0) then
				SetChargeData(player, slot, 0, amount)
			elseif (player:GetBloodCharge() > 0) then
				SetChargeData(player, slot, 0, 0, amount)
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
		SetChargeData(player, slot, charges-amount)
		SUCCESS = true
	elseif (totalCharges >= amount) then
		if (player:GetSoulCharge() > 0) then
			SetChargeData(player, slot, 0, 1)
		elseif (player:GetBloodCharge() > 0) then
			SetChargeData(player, slot, 0, 0, 1)
		end
		SUCCESS = true
	end
	
	return SUCCESS
end


end


do --特殊角色判定区

--是否为复得游魂(实际为2P宝宝)
function Players:IsFoundSoul(player)
	return (player.Variant == 1 and player.SubType == BabySubType.BABY_FOUND_SOUL)
end

--是否为稻草人(暂时没有更好的方法)
function Players:IsStrawMan(player)
	if Players:GetData(player).StrawMan then
		return true
	end
	return false
end
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function()
	local player = Isaac.GetPlayer(Game():GetNumPlayers() - 1)
	if (player.Parent ~= nil) and (player:GetPlayerType() == PlayerType.PLAYER_KEEPER) then
		Players:GetData(player).StrawMan = true
	end
end, CollectibleType.COLLECTIBLE_STRAW_MAN)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_,player)
	local data = Players:GetData(player)
	if (player.Parent == nil) and data.StrawMan then
		data.StrawMan = nil
	end
end)


end


do --虚空区

--采用白名单制
local Whitelist = {
	[IBS_ItemID.CursedMantle] = true, --诅咒屏障
}

--获取虚空吸收的道具数量(目前只对主动道具有效)
function Players:GetVoidCollectibleNum(player, item)
	local data = Players:GetData(player).Void
	
	item = tostring(item)
	if data and data[item] then
		return data[item]
	end
	
	return 0
end

--获取虚空数据(目前只用于存放吸收的主动道具)
function Players:GetVoidData(player)
	local data = Players:GetData(player)
	data.Void = data.Void or {}

	return data.Void	
end

--以下为又臭又长的硬核记录虚空吸收的道具方法


--频率限制,用于修正(主要是防止车载电池)
local RecordTimeout = 0
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if RecordTimeout > 0 then
		RecordTimeout = RecordTimeout - 1
	end
end)

--记录虚空吸收的道具
local function RecordVoid(_, item, rng, player)
	if RecordTimeout > 0 then return end
	RecordTimeout = 1
	local data = Players:GetVoidData(player)
	local savedOptIdx = {}
	
	--记录正在拾取的道具
	--(虚空可以吸收正在拾取的道具)
	if not player:IsItemQueueEmpty() then
		local queued = player.QueuedItem.Item

		--主动道具
		if (queued.Type == ItemType.ITEM_ACTIVE) then
			local ID = queued.ID
			local itemConfig = config:GetCollectible(ID)
			
			--白名单,非错误道具,非任务道具
			if Whitelist[ID] and (ID > 0) and itemConfig and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
				ID = tostring(ID)
				if not data[ID] then
					data[ID] = 1
				else
					data[ID] = data[ID] + 1
				end
			end	
		end
	end
	
	--记录房间里的道具
	--(虚空按道具生成顺序吸收道具,而Isaac.FindByType函数返回的表也按该顺序)
	--(推测虚空也使用了这个函数来获取道具实体,故这里使用ipairs)
	for _, entity in ipairs(Isaac.FindByType(5, 100, -1, true)) do
		local pickup = entity:ToPickup()
		local idx = pickup.OptionsPickupIndex
	
		--非错误道具,无价格,检查单选掉落物参数
		--(虚空只吸收具有相同单选掉落物参数的道具组的第一个)
		if (pickup.SubType > 0) and (pickup.Price == 0) and ((idx == 0) or not savedOptIdx[idx]) then
			local ID = pickup.SubType
			local itemConfig = config:GetCollectible(ID)
			
			--白名单,主动道具,非任务道具
			if Whitelist[ID] and itemConfig and (itemConfig.Type == ItemType.ITEM_ACTIVE) and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
				ID = tostring(ID)
				if not data[ID] then
					data[ID] = 1
				else
					data[ID] = data[ID] + 1
				end

				if idx ~= 0 then savedOptIdx[idx] = true end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, RecordVoid, CollectibleType.COLLECTIBLE_VOID)

end


do --握住道具区(调用自\ibs_scripts\callbacks\hold_item.lua)

--是否正在握住道具(限用于本模组的道具)
function Players:IsHoldingItem(player, item)
	local data = Ents:GetTempData(player).HoldItemCallback
	local hold = (data and data.Item > 0 and (item == nil or data.Item == item))

	if data and hold then
		return true,data.Slot
	end
	
	return false,-1
end

--尝试握住道具
function Players:TryHoldItem(item, player, flag, slot)
	local HoldItem = (mod.IBS_Callbacks and mod.IBS_Callbacks.HoldItem) or nil
	if not HoldItem then return false end

	local data = HoldItem:GetData(player)
	local canHold = false
	local noLiftAnim = false
	local noHideAnim = false
	local canCancel = false
	local allowHurt = false
	local allowNewRoom = false
	local timeOut = -1
	
	for _, callback in ipairs(Isaac.GetCallbacks(IBS_CallbackID.TRY_HOLD_ITEM)) do
		if (not callback.Param) or (callback.Param == item) then
			local result = callback.Function(callback.Mod, item, player, flag, slot, data.Item)
			
			if result ~= nil then
				canHold = result.CanHold or false
				noLiftAnim = result.NoLiftAnim or false
				noHideAnim = result.NoHideAnim or false
				canCancel = result.CanCancel or false
				allowHurt = result.AllowHurt or false
				allowNewRoom = result.AllowNewRoom or false
				timeOut = result.Timeout or -1
			end
		end
	end
	
	if canHold then
		if data.Holding then --重复尝试握住同一个道具且允许主动取消则取消握住
			if canCancel and (data.Item == item) and (data.Slot == slot) then 
				data.Cancel_Active = true
				data.Holding = false
			end	
		elseif (data.Item <= 0) then
			data.Item = item
			data.UseFlags = flag
			data.NoLiftAnim = noLiftAnim
			data.NoHideAnim = noHideAnim
			data.Slot = slot
			data.Timeout = timeOut
			data.CanCancel = canCancel
			data.AllowHurt = allowHurt
			data.AllowNewRoom = allowNewRoom
			data.Holding = true
			
			return true
		end	
	end
	
	return false
end

--结束握住道具
function Players:EndHoldItem(player, byActive, byTimeOut, byHurt, byNewRoom)
	local data = Ents:GetTempData(player).HoldItemCallback
	if data then
		data.Cancel_Active = byActive or false
		data.Cancel_Timeout = byTimeOut or false
		data.Cancel_Hurt = byHurt or false
		data.Cancel_NewRoom = byNewRoom or false
		data.Holding = false
	end	
end

end


--[[
do --隐藏道具魂火区(暂未使用,也没有进行测试)

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



--以下为又臭又长的处理道具魂火方法(明明直接给个添加隐藏道具的API就不用这么麻烦了,屑官方愣是不给)
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