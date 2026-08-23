--亚波伦的伪忆EID

local mod = Isaac_BenightedSoul
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
		local SubType = desc.ObjSubType
	
		--检查语言
		local lang = EID:getLanguage()
		if lang ~= 'zh_cn' then lang = 'en_us' end
		if lang ~= LANG then
			return false
		end
		
		if (Type == 5) and (Variant == 300) and (SubType == IBS_PocketID.BApollyon) then
			return true
		end
			
		return false
	end

	--添加额外内容
	local function callback(desc)
		local data = mod:GetIBSData('temp').FalsehoodBApollyon or {41, 41, 41}
	
		if data then
			local add = Translate('#将生成：', '#Will Spawn: ', LANG)
			for _,id in ipairs(data) do
				add = add..'{{Card'..id..'}} '
			end
			EID:appendToDescription(desc, add)
		end

		return desc
	end
	EID:addDescriptionModifier('ibsBApollyonFalsehood'..'_'..LANG, condition, callback)
end