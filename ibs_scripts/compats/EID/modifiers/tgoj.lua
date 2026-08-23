--犹大福音增强EID

local mod = Isaac_BenightedSoul
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
		local SubType = desc.ObjSubType	
	
		--检查语言
		local lang = EID:getLanguage()
		if lang ~= 'zh_cn' then lang = 'en_us' end
		if lang ~= LANG then
			return false
		end
		
		if (Type == 5) and (Variant == 100) and (SubType == IBS_ItemID.TGOJ) then
			local BC4 = mod.IBS_Achiev.Challenge[4]
			if BC4:IsFinished() or BC4:Challenging() then
				return true
			end	
		end
			
		return false
	end

	--添加额外内容
	local function callback(desc)
		local info = Translate('范围内的敌人获得虚弱效果', 'Weaken enemies within range', LANG)
		local add = '#{{ColorGold}}'..info..'{{CR}}'

		EID:appendToDescription(desc, add)
		
		return desc
	end
	EID:addDescriptionModifier('ibsTGOJUp'..'_'..LANG, condition, callback)
end