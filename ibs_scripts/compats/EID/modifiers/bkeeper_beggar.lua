--表表店硬币饰品额外描述EID

local mod = Isaac_BenightedSoul
local IBS_PlayerID = mod.IBS_PlayerID
local Pools = mod.IBS_Lib.Pools

--翻译
local function Translate(text_zh, text_en, LANG)
	return (LANG == 'zh_cn' and text_zh) or text_en
end

--是否可以显示EID
local function CanShowEID(Type, Variant, SubType)
	if PlayerManager.AnyoneHasCollectible(402) then
		return false
	end				
	
	if not PlayerManager.AnyoneIsPlayerType(IBS_PlayerID.BKeeper) then 
		return false
	end			
	
	if (Type == 6) and Pools:IsBeggar(Variant) and SubType == 0 then
		return true
	end
	
	return false
end

--前期处理
for _,LANG in ipairs({'zh_cn', 'en_us'}) do
	local Beggar = {
		[4] = {
			Name = Translate('乞丐', 'Beggar', LANG),
			Icon = 'Beggar',
		},
		[5] = {
			Name = Translate('恶魔乞丐', 'Devil Beggar', LANG),
			Icon = 'DemonBeggar',
		},
		[7] = {
			Name = Translate('钥匙大师', 'Key Master', LANG),
			Icon = 'KeyBeggar',
		},
		[9] = {
			Name = Translate('炸弹乞丐', 'Bomb Bum', LANG),
			Icon = 'BombBeggar',
		},
		[13] = {
			Name = Translate('电池乞丐', 'Battery Bum', LANG),
			Icon = 'BatteryBeggar',
		},
		[18] = {
			Name = Translate('腐烂乞丐', 'Rotten Beggar', LANG),
			Icon = 'RottenBeggar',
		},
					
	}
	
	for variant,tbl in pairs(Beggar) do
		EID:addEntity(6, variant, 0, tbl.Name, "", LANG)
		EID:AddIconToObject(6, variant, 0, tbl.Icon)
		
		--没有描述时隐藏
		mod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, function(_,slot)
			if slot.FrameCount < 2 or slot:IsFrame(90,0) then				
				if CanShowEID(slot.Type, slot.Variant, slot.SubType) then
					EID:setEntityData(slot, "EID_Hide", nil)
				else
					EID:setEntityData(slot, "EID_Hide", true)
				end
			end
		end, variant)
	end
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
			
		return CanShowEID(Type, Variant, SubType)
	end

	--添加额外内容
	local function callback(desc)
		local add = '#{{Player'..(IBS_PlayerID.BKeeper)..'}} '
		local beggarPool = Pools.BeggarToBeggarPool[desc.ObjVariant]
		local cache = {}
		local total = 28

		--硬核计算概率
		if beggarPool and mod.IBS_Player.BKeeper.PoolForPennyTrinket[beggarPool] then
			cache[beggarPool] = 28
		
			for trinket,pools in pairs(mod.IBS_Player.BKeeper.PoolForPennyTrinket[beggarPool]) do
				local mult = PlayerManager.GetTotalTrinketMultiplier(trinket)
				if mult > 0 then
					for i2 = 1,mult do
						for _,v in ipairs(pools) do
							cache[v.Pool] = cache[v.Pool] or 0
							cache[v.Pool] = cache[v.Pool] + v.Times
							total = total + v.Times
						end
					end
				end
			end
			
			for pool,times in pairs(cache) do
				local chance = math.floor(100*(times/total)+0.5)..'% '
			
				if pool == 'Random' then
					add = add..'{{QuestionMark}}:'..chance
				else
					add = add..(EID.ItemPoolTypeToMarkup[pool])..':'..chance
				end
			end

			EID:appendToDescription(desc, add)
		end
		
		return desc
	end
	EID:addDescriptionModifier('ibsBKeeperBeggarDesc'..'_'..LANG, condition, callback)
end