--美德七面骰

local mod = Isaac_BenightedSoul
local IBS_Boss = mod.IBS_Boss

local game = Game()

local V7 = mod.IBS_Class.Item(mod.IBS_ItemID.V7)

--召唤列表
V7.SpawnList = {
	IBS_Boss.Diligence, --勤劳
	IBS_Boss.Fortitude, --坚韧
	IBS_Boss.Temperance, --节制
	IBS_Boss.Generosity, --慷慨
	IBS_Boss.Humility, --谦逊
}


--效果
function V7:OnUse(item, rng, player)
	local key = rng:RandomInt(1, #self.SpawnList)

	--暗室/玩具箱不出谦逊
	if key == 4 and game:GetLevel():GetStage() == 11 then key = 3 end

	local virtue = self.SpawnList[key] or IBS_Boss.Temperance
	--local virtue = IBS_Boss.Diligence
	
	local SubType = {}
	if type(virtue.SubType) == "number" then
		table.insert(SubType, virtue.SubType)
	elseif type(virtue.SubType) == "table" then
		for _,v in pairs(virtue.SubType) do
			table.insert(SubType, v)
		end
	end
	
	for _,subType in ipairs(SubType) do
		local pos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true)
		local ent = Isaac.Spawn(virtue.Type, virtue.Variant, subType, pos, Vector.Zero, player)
		ent:AddCharmed(EntityRef(player), -1)
		ent:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
		ent:AddEntityFlags(EntityFlag.FLAG_NO_SPIKE_DAMAGE)
		ent.MaxHitPoints = ent.MaxHitPoints * 2
		ent.HitPoints = ent.HitPoints * 2
		
		--烟雾
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position, Vector.Zero, nil)	
	end

	return true	
end
V7:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', V7.ID)

return V7