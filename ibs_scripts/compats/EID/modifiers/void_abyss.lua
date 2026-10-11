--虚空/无底坑增强EID

local mod = Isaac_BenightedSoul

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
		
		if (Type == 5) and (Variant == 100) and (SubType == 477 or SubType == 706) then
			local Abyss = mod.IBS_Transformation and mod.IBS_Transformation.Abyss
			local player = EID:ClosestPlayerTo(desc.Entity)
			if player and Abyss and Abyss:IsOwned(player) then
				return true
			end
		end
			
		return false
	end

	--添加额外内容
	local function callback(desc)
		local info = Translate('对饰品生效', 'Available to trinkets', LANG)
		local add = '#{{IBSTrans_abyss}} {{ColorGold}}'..info..'{{CR}}'

		EID:appendToDescription(desc, add)
		
		return desc
	end
	EID:addDescriptionModifier('ibsVoidAbyssUp'..'_'..LANG, condition, callback)
end