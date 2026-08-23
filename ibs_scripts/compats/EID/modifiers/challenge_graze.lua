--牧地挑战EID

local mod = Isaac_BenightedSoul
local IBS_ChallengeID = mod.IBS_ChallengeID
local IBS_ItemID = mod.IBS_ItemID

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
		
		if Isaac.GetChallenge() == IBS_ChallengeID[3] then
			if Type == 5 and Variant == 100 then
				return true
			end
		end
			
		return false
	end

	--添加额外内容
	local function callback(desc)
		local id = desc.ObjSubType
					
		--小麦
		if id == IBS_ItemID.Wheat then
			desc.Description = Translate(
				'为周围的山羊提升血量上限并回满血量',
				"Increase nearby goats' Hp", 
				LANG
			)
		end
	
		if id == IBS_ItemID.Goatify then
			desc.Description = Translate(
				'生成一只山羊',
				"Spawn a goat", 
				LANG
			)
		end

		return desc
	end
	EID:addDescriptionModifier('ibsBC3'..'_'..LANG, condition, callback)
end