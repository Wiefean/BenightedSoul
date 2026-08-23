--节制之骨增强EID

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
		
		if (Type == 5) and (Variant == 100) and (SubType == IBS_ItemID.BOT) then
			if mod:GetIBSData('persis')["BForgotten"].Delirium then
				return true
			end
		end
			
		return false
	end

	--添加额外内容
	local function callback(desc)
		local info = Translate('处于其他攻击方式时附加眼泪', 'When in other attack modes, additionally fire tears', LANG)
		local add = '#{{ColorGold}}'..info..'{{CR}}'

		EID:appendToDescription(desc, add)
		
		return desc
	end
	EID:addDescriptionModifier('ibsBOTUp'..'_'..LANG, condition, callback)
end