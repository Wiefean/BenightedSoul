--对流层EID

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

		if (Type == 5) and (Variant == 100) and (SubType > 0) then
			if not PlayerManager.AnyoneHasCollectible(IBS_ItemID.Troposphere) then return false end
			local Troposphere = (mod.IBS_Item and mod.IBS_Item.Troposphere)
			if Troposphere and Troposphere:CanSwap(SubType) then
				return true
			end		
		end
			
		return false
	end

	--添加额外内容
	local function callback(desc)
		local add = Translate('允许对流层交换', 'Troposphere Available', LANG)
		add = '#{{Collectible'..(IBS_ItemID.Troposphere)..'}} '..add
		EID:appendToDescription(desc, add)
		return desc
	end
	EID:addDescriptionModifier('ibsTroposphere'..'_'..LANG, condition, callback)	
end