--永乐大典EID

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
		
		if (Type == 5) and (Variant == 100) and (SubType == IBS_ItemID.Yongle) then
			return true
		end
			
		return false
	end

	--添加额外内容
	local function callback(desc)
		local Yongle = (mod.IBS_Item and mod.IBS_Item.Yongle)
	
		if Yongle then
			local add = Translate('#将触发：', '#Books to trigger: ', LANG)
			for _,id in ipairs(Yongle:GetBooks()) do
				add = add..'{{Collectible'..id..'}} '
			end
			EID:appendToDescription(desc, add)
		end

		return desc
	end
	EID:addDescriptionModifier('ibsYongle'..'_'..LANG, condition, callback)
end