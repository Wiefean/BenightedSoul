--表表游魂额外描述EID

local mod = Isaac_BenightedSoul
local IBS_PlayerID = mod.IBS_PlayerID
local IBS_ItemID = mod.IBS_ItemID
local Players = mod.IBS_Lib.Players

local game = Game()
local config = Isaac.GetItemConfig()

--翻译
local function Translate(text_zh, text_en, LANG)
	return (LANG == 'zh_cn' and text_zh) or text_en
end

local Chest = include('ibs_scripts.compats.EID.descriptions.blost')

--是否可以显示EID
local function CanShowEID(ent)
	if ent and (ent.Type == 5) and Chest[ent.Variant] then
		local player = EID:ClosestPlayerTo(ent)
		if player and player:GetPlayerType() == (IBS_PlayerID.BLost) then
			return true
		end
	end
	return false
end

--前期处理
for _,LANG in ipairs({'zh_cn', 'en_us'}) do
	for variant,tbl in pairs(Chest) do
		local name = Translate(tbl.Name[1], tbl.Name[2], LANG)
		EID:addEntity(5, variant, -1, name, "", LANG)
		for i = 0,100 do			
			EID:addEntity(5, variant, i, name, "", LANG)
			EID:AddIconToObject(5, variant, i, tbl.Icon)
		end
		
		--没有描述时隐藏
		mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_,pickup)
			if pickup.FrameCount < 2 or pickup:IsFrame(90,0) then
				if CanShowEID(pickup) then
					EID:setEntityData(pickup, "EID_Hide", nil)
				else
					EID:setEntityData(pickup, "EID_Hide", true)
				end
			end
		end, variant)
	end
end

return function(LANG)
	--触发条件
	local function condition(desc)
		local Type = desc.ObjType
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType
	
		--检查语言
		local lang = EID:getLanguage()
		if lang ~= 'zh_cn' then lang = 'en_us' end
		if lang ~= LANG then
			return false
		end
		
		--道具
		if (Type == 5) and (Variant == 100) and (SubType > 0) and desc.Entity then
			local player = EID:ClosestPlayerTo(desc.Entity)
			if player and player:GetPlayerType() == (IBS_PlayerID.BLost) then
				return true
			end
		end
		
		--箱子
		if (Type == 5) and Chest[Variant] and desc.Entity then
			if CanShowEID(desc.Entity) then
				return true
			end
		end

		return false
	end

	--添加额外内容
	local function callback(desc)
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType
		local BLost = (mod.IBS_Player and mod.IBS_Player.BLost)
		
		if not BLost then return desc end
		
		--分解道具提示
		if Variant == 100 then
			local itemConfig = config:GetCollectible(SubType)
			if itemConfig and (BLost.DecomposeItem[SubType] or itemConfig:HasTags(ItemConfig.TAG_NO_LOST_BR)) then
				local num = 1 + 2 ^ itemConfig.Quality
				local add = Translate('将被分解为{{Key}}钥匙', 'Would be decomposed into {{Key}}keys', LANG)
				add = '#{{Player'..(IBS_PlayerID.BLost)..'}} '..add..' x '..math.floor(num)
				
				if itemConfig.Quality >= 2 then
					add = add..Translate(' 和箱子', ' and chests', LANG)..' x '..math.floor(itemConfig.Quality - 1)
				end
				
				EID:appendToDescription(desc, add)
			end
		else--箱子描述
			local add = ''
			
			--大箱子钥匙花费温馨提示,拒绝赌狗
			if EID.Config["ShowObjectID"] and Variant == PickupVariant.PICKUP_MEGACHEST and SubType > 0 then
				local keys = ' x '..SubType
				add = Translate('#开启还需{{Key}}钥匙', '#To be open needs {{Key}}keys', LANG)..keys..add
			end				
			
			local player = EID:ClosestPlayerTo(desc.Entity)
			local ChestChest = (mod.IBS_Item and mod.IBS_Item.ChestChest)
			if BLost and player and Players:IsHoldingItem(player, IBS_ItemID.ChestChest)
				and ChestChest and ChestChest:CanStore(desc.Entity, player)
			then
				local selection = ChestChest:GetPlayerData(player).Selection
				local megaArmor = (BLost:GetMechaData(player)[2].Chest == 'Mega')
				local descType = ''
				local icon = ''
				
				--大箱护甲吸收箱子
				if megaArmor and selection == 2 then
					local bigger = (Variant == PickupVariant.PICKUP_MEGACHEST or Variant == PickupVariant.PICKUP_MOMSCHEST)
					icon = '#{{MegaChest}} {{IBSBlostArmor}}'
				
					--大箱或妈箱直接回满
					if bigger then
						add = add..icon..Translate(
							'耐久回满',
							'Full durability',
							LANG
						)
					else
						local num = (SubType > 0 and 1) or 0.4
						add = add..icon..Translate(
							'耐久恢复',
							'Durability recovers ',
							LANG
						)..num
					end
					
					--提升耐久上限并降低移速
					local mega = BLost:GetMegaAbsorption(player)
					if not mega[tostring(Variant)] then
						local num = (bigger and 3) or 1
						add = add..icon..Translate(
							'耐久上限提升',
							'Max durability increases ',
							LANG
						)..num
						add = add..icon..Translate(
							'无敌时间提升',
							'Invincible time increases',
							LANG
						)..(0.1*num)..Translate('秒', 's', LANG)
						add = add..icon..Translate(
							'↓{{Speed}}移速 - ',
							'↓{{Speed}}spd - ',
							LANG
						)..(0.1*num)
					end
				else
					if selection == 1 or selection == 3 then
						descType = 'Weapon'
						icon = '{{IBSBlostWeapon}} '						
					elseif selection == 2 then
						descType = 'Armor'
						icon = '{{IBSBlostArmor}} '
					elseif selection >= 4 and selection <= 6 then
						descType = 'Float'
						icon = '{{IBSBlostFloat}} '					
					end
					
					local chestDesc = Chest[Variant][descType]
					if chestDesc then
						for k,v in ipairs(chestDesc[LANG]) do						
							add = add..'#'..icon..v
						end
					end
					
					--贪婪模式特殊描述
					if game:IsGreedMode() and selection ~= 2 then
						if Variant == PickupVariant.PICKUP_REDCHEST then
							add = add..'#'..icon..'{{GreedMode}}'..Translate('贪婪模式：耐久消耗速度减半', 'Greed: Half durability consumption', LANG)
						elseif Variant ~= PickupVariant.PICKUP_ETERNALCHEST then
							add = add..'#'..icon..'{{GreedMode}}'..Translate('贪婪模式：50%概率不消耗耐久', 'Greed: 50% chance not to decrease durability', LANG)
						end
					end
				end
				
			end
			
			EID:appendToDescription(desc, add)
		end
		
		return desc
	end
	EID:addDescriptionModifier('ibsBLost'..'_'..LANG, condition, callback)
end