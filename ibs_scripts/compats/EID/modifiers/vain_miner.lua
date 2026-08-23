--帘锁挖掘EID

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local config = Isaac.GetItemConfig()

--翻译
local function Translate(text_zh, text_en, LANG)
	return (LANG == 'zh_cn' and text_zh) or text_en
end

--ID转EID贴图
local function ToIcon(id, LANG)
	local icon = ''
	local itemConfig = config:GetCollectible(id)

	if id > 0 and itemConfig and itemConfig:IsAvailable() then
		icon = '{{Collectible'..tostring(id)..'}}'
	else
		icon = Translate('错误道具', 'Error', LANG)
	end
	
	return icon
end

return function(LANG)
	--触发条件
	local function condition(desc)
		local ent = desc.Entity
		local Type = desc.ObjType
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType	
	
		--检查语言
		local lang = EID:getLanguage()
		if lang ~= 'zh_cn' then lang = 'en_us' end
		if lang ~= LANG then
			return false
		end
		
		if ent and (Type == 5) and (Variant == 100) and (SubType > 0) then
			return PlayerManager.AnyoneHasCollectible(IBS_ItemID.VainMiner)
		end
			
		return false
	end

	--添加额外内容
	local function callback(desc)
		local ent = desc.Entity
		local VainMiner = (mod.IBS_Item and mod.IBS_Item.VainMiner)
		if VainMiner and ent then
			local left = mod:GetIBSData('level').VainMinerCount
			
			--检查剩余次数
			if (not left) or left < 1 then
				local id = VainMiner:GetItem(ent.SubType, ent.InitSeed)
				
				local add = '#{{Collectible'..IBS_ItemID.VainMiner..'}} '..
							 Translate('将生成：', 'Next: ', LANG)..
							 ToIcon(id, LANG)
							
				EID:appendToDescription(desc, add)				
			end
		end
		return desc
	end
	EID:addDescriptionModifier('ibsVainMiner'..'_'..LANG, condition, callback)
end