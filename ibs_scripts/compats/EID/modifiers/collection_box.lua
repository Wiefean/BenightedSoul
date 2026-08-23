--募捐箱EID

local mod = Isaac_BenightedSoul
local IBS_SlotID = mod.IBS_SlotID
local IBS_PocketID = mod.IBS_PocketID

--翻译
local function Translate(text_zh, text_en, LANG)
	return (LANG == 'zh_cn' and text_zh) or text_en
end


return function(LANG)
	--触发条件
	local function condition(desc)
		local Type = desc.ObjType
		local Variant = desc.ObjVariant

		--检查语言
		local lang = EID:getLanguage()
		if lang ~= 'zh_cn' then lang = 'en_us' end
		if lang ~= LANG then
			return false
		end
		
		if (Type == 6) and (Variant == IBS_SlotID.CollectionBox.Variant) then
			return true
		end
			
		return false
	end

	--添加额外内容
	local function callback(desc)
		local CollectionBox = (mod.IBS_Slot and mod.IBS_Slot.CollectionBox)
		local add = '#'

		if CollectionBox then
			local data = CollectionBox:GetData()
			local boxLevel = CollectionBox:GetLevel()

			--升级提示
			if boxLevel < 5 then
				local threshold = CollectionBox.BoxLevelToCoin[boxLevel+1]
				if threshold then
					local coin = threshold - data.Coins
					add = add..Translate(
						'升级还需{{Coin}}硬币 x ', 
						'To upgrade needs {{Coin}}coin x ',
						LANG
					)..coin
				end
			end

			--统计触发事件
			local chance = string.format("%.1f", (math.min(7 + 7 * boxLevel + data.Coins, 250) / 10))
			add = add..'#'..Translate(
				'投入{{Coin}}硬币时，有', 
				'When Insert {{Coin}}coins, ',
				LANG
			)..chance..Translate(
				'%概率触发：', 
				'% chance to trigger:',
				LANG
			)
			
			--消除碎心或加幸运
			add = add..'#'..Translate(
				'消除1{{BrokenHeart}}碎心；若没有则全体角色获得0.5{{Luck}}幸运，最多10', 
				'Clear 1 {{BrokenHeart}}Broken Heart; Or all characters get 0.5 {{Luck}}luck up to 10',
				LANG
			)
				
			--消灭店长和贪婪
			if boxLevel >= 2 then
				add = add..'#'..Translate(
					'消灭贪婪和场景店主', 
					'Destroy Greed and scenery Keeper',
					LANG
				)
			end
			
			--生成乞丐
			if boxLevel >= 3 and not data.BeggerSpawned then
				add = add..'#'..Translate(
					'生成乞丐', 
					'Spawn a beggar',
					LANG
				)
			end
			
			--生成偷来的一年
			if boxLevel >= 4 and not data.CardSpawned then
				add = add..'#'..Translate(
					'生成{{Card'..(IBS_PocketID.StolenYear)..'}}偷来的一年', 
					'Spawn {{Card'..(IBS_PocketID.StolenYear)..'}}Stolen Year',
					LANG
				)
			end				
			
			--生成天梯
			if boxLevel >= 5 and not data.StairSpawned then
				add = add..'#'..Translate(
					'生成天梯实体', 
					'Spawn a stairway entity',
					LANG
				)
			end
			
			EID:appendToDescription(desc, add)
		end
		
		return desc
	end
	EID:addDescriptionModifier('ibsCollectionBox'..'_'..LANG, condition, callback)
end