--死亡回放

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Redeath = mod.IBS_Class.Item(mod.IBS_ItemID.Redeath)

Redeath.ChestVariant = {
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_LOCKEDCHEST,
}

Redeath.ReadyToRoll = {
	114514, --箱子
	114514, --箱子
	PickupVariant.PICKUP_GRAB_BAG,
	PickupVariant.PICKUP_GRAB_BAG,
	PickupVariant.PICKUP_GRAB_BAG,
	PickupVariant.PICKUP_GRAB_BAG,
	PickupVariant.PICKUP_GRAB_BAG,
	PickupVariant.PICKUP_COLLECTIBLE,
	PickupVariant.PICKUP_TRINKET,
}

--使用效果
function Redeath:OnUse(item, rng, player, flags, slot)
	if (flags & UseFlag.USE_CARBATTERY <= 0) then --拒绝车载电池
		for _,ent in pairs(Isaac.FindByType(5,100,0)) do
			local itemPool = Game():GetItemPool()
			local variant = 100
			local subType = 0
			local result = self.ReadyToRoll[rng:RandomInt(10) + 1] or 114514
			
			--箱子
			if (result == 114514) then
				variant = self.ChestVariant[rng:RandomInt(18) + 1] or PickupVariant.PICKUP_CHEST
			else
				variant = result
			end
			
			--抽取掉落物
			--(虽然部分掉落物有替换机制,但为了提高稀有掉落物出现概率还是做了随机)
			if (variant == PickupVariant.PICKUP_GRAB_BAG) then
				subType = 1
			
			elseif (variant == PickupVariant.PICKUP_COLLECTIBLE) then
				local seed = self._Levels:GetRoomUniqueSeed()
				local pool = self._Pools:GetRoomPool(seed)
				subType = itemPool:GetCollectible(pool, true, seed)
				
			elseif (variant == PickupVariant.PICKUP_TRINKET) then
				subType = itemPool:GetTrinket() + 32768
			end
			
			local pickup = Isaac.Spawn(5, variant, subType, ent.Position, Vector.Zero, nil):ToPickup()
			ent:Remove()

			--无美德书20秒后消失
			local virtue = player:HasCollectible(584) and (flags & UseFlag.USE_NOANIM <= 0 or flags & UseFlag.USE_ALLOWWISPSPAWN > 0)
			if not virtue then
				pickup.Timeout = 600
				pickup:SetColor(Color(0.5,0.5,0.5,0.5), -1, 3, false, true)
			end

			--无彼列书加尖刺
			if not player:HasCollectible(59) then
				self._Pickups:SetSpikePrice(pickup)
			end

			--特效
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 0, pickup.Position, Vector.Zero, nil)
			game:ShakeScreen(15)
			sfx:Play(SoundEffect.SOUND_DEATH_CARD)
		end
		
		return {ShowAnim = false, Discharge = true}
	end	
end
Redeath:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', Redeath.ID)


return Redeath