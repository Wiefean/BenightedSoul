--美德七面骰

local mod = Isaac_BenightedSoul
local IBS_Boss = mod.IBS_Boss
local IBS_BossID = mod.IBS_BossID
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

local V7 = mod.IBS_Class.Item(IBS_ItemID.V7)

--召唤列表
V7.SpawnList = {
	IBS_Boss.Diligence, --勤劳
	IBS_Boss.Chastity, --贞洁
	IBS_Boss.Fortitude, --坚韧
	IBS_Boss.Temperance, --节制
	IBS_Boss.Generosity, --慷慨
	IBS_Boss.Humility, --谦逊
}


--效果
function V7:OnUse(item, rng, player, flags)
	local key = rng:RandomInt(1, #self.SpawnList)

	--暗室/玩具箱不出谦逊
	if key == 4 and game:GetLevel():GetStage() == 11 then key = 3 end

	local virtue = self.SpawnList[key] or IBS_Boss.Temperance
	--local virtue = IBS_Boss.Chastity
	
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
		
		--谦逊带一个主教
		if virtue.Variant == IBS_BossID.Humility.Variant then
			local pos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true)
			local ent = Isaac.Spawn(805, 0, 0, pos, Vector.Zero, player)
			ent:AddCharmed(EntityRef(player), -1)
			ent:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
			ent:AddEntityFlags(EntityFlag.FLAG_NO_SPIKE_DAMAGE)
			ent.MaxHitPoints = ent.MaxHitPoints * 0.5
			ent.HitPoints = ent.HitPoints * 0.5	
		end		
		
		--烟雾
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position, Vector.Zero, nil)	
	end

	--美德书生成宽容魂火
	if player:HasCollectible(584) and (flags & UseFlag.USE_NOANIM <= 0 or flags & UseFlag.USE_ALLOWWISPSPAWN > 0) then
		local canSpawn = true
	
		for _,ent in ipairs(Isaac.FindByType(3, 237, IBS_ItemID.Kindness)) do
			local familiar = ent:ToFamiliar()
			if familiar and self._Ents:IsTheSame(familiar.Player, player) then
				canSpawn = false
				break
			end
		end
		
		if canSpawn then
			player:AddItemWisp(IBS_ItemID.Kindness, player.Position, true)
		end
	end

	return true	
end
V7:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', V7.ID)

return V7