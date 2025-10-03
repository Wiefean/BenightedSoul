--银色手镯

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()
local sfx = SFXManager()

local SilverBracelet = mod.IBS_Class.Item(mod.IBS_ItemID.SilverBracelet)

--赌博游戏
SilverBracelet.GamblingSlot = {
	[1] = true, --老虎机
	[3] = true, --预言机
	[6] = true, --罐子游戏
	[15] = true, --地狱游戏
	[16] = true, --娃娃机
}

--使用
function SilverBracelet:OnUse(item, rng, player, flags)
	local belial = player:HasCollectible(59) --彼列书

	for _,ent in ipairs(Isaac.FindInRadius(player.Position, 200, EntityPartition.ENEMY)) do
		if self._Ents:IsEnemy(ent) then
			ent:SetBossStatusEffectCooldown(0)
			local int = rng:RandomInt(1,3)
			if int == 1 then
				ent:AddConfusion(EntityRef(player), 300)
			elseif int == 2 then
				ent:AddFear(EntityRef(player), 300)
			else
				ent:AddFreeze(EntityRef(player), 300)
			end

			if belial then
				ent:SetBossStatusEffectCooldown(0)
				ent:AddBurn(EntityRef(player), 300, math.max(3.5, player.Damage))
			end
		end
	end
	
	--赌博游戏爆炸
	for _,ent in ipairs(Isaac.FindByType(6)) do
		if self.GamblingSlot[ent.Variant] and ent:ToSlot() and ent:ToSlot():GetState() == 1 then
			Isaac.Explode(ent.Position, nil, 100)
		end
	end

	--赌博房所有可互动实体爆炸
	if game:GetRoom():GetType() == RoomType.ROOM_ARCADE then
		for _,ent in ipairs(Isaac.FindByType(6)) do
			if ent:ToSlot() and ent:ToSlot():GetState() == 1 then
				Isaac.Explode(ent.Position, nil, 100)
			end
		end
	end

	sfx:Play(SoundEffect.SOUND_CHAIN_BREAK)
	
	return true
end
SilverBracelet:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', SilverBracelet.ID)

--魂火熄灭
function SilverBracelet:OnWispKilled(familiar)
    if (familiar.Variant == FamiliarVariant.WISP and familiar.SubType == (self.ID)) then
		local player = self._Ents:IsSpawnerPlayer(familiar)
		if player then
			player:UseActiveItem(self.ID, false, false)
		end
    end
end
SilverBracelet:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnWispKilled', EntityType.ENTITY_FAMILIAR)

--清理魂火
function SilverBracelet:CleanWisps()
	for _,wisp in pairs(Isaac.FindByType(3,206, self.ID)) do
		wisp:Remove()	
	end
end
SilverBracelet:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'CleanWisps')


return SilverBracelet