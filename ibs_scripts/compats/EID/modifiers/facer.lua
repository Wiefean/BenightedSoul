--换脸商EID

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local IBS_SlotID = mod.IBS_SlotID

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
		
		--换脸商或一张张脸
		if (Type == 6) and (Variant == IBS_SlotID.Facer.Variant) then
			return true
		end
		if (Type == 5) and (Variant == 100) and (SubType == IBS_ItemID.AFaces) then
			return true
		end
			
		return false
	end

	--添加额外内容
	local function callback(desc)
		local AFaces = (mod.IBS_Item and mod.IBS_Item.AFaces)
		local add = ''

		if AFaces then
			local cache = {}
			
			for _,id in ipairs(AFaces.TrinketList) do
				if not cache[id] then
					cache[id] = true
					add = add..'{{Trinket'..id..'}}'
				end
			end
			
			EID:appendToDescription(desc, add)
		end
		
		return desc
	end
	EID:addDescriptionModifier('ibsFacer'..'_'..LANG, condition, callback)
end