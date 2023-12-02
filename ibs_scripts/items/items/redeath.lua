--死亡回放

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local Pools = mod.IBS_Lib.Pools
local Players = mod.IBS_Lib.Players

--用于昧化该隐&亚伯
mod.IBS_API.BCBA:AddExcludedActiveItem(IBS_Item.redeath)

local ChestVariant = {
	PickupVariant.PICKUP_CHEST,
	PickupVariant.PICKUP_CHEST,
	PickupVariant.PICKUP_CHEST,
	PickupVariant.PICKUP_CHEST,
	PickupVariant.PICKUP_CHEST,
	PickupVariant.PICKUP_CHEST,
	PickupVariant.PICKUP_CHEST,
	PickupVariant.PICKUP_SPIKEDCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_MIMICCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_HAUNTEDCHEST,
	PickupVariant.PICKUP_LOCKEDCHEST,
	PickupVariant.PICKUP_LOCKEDCHEST,
	PickupVariant.PICKUP_REDCHEST,
	PickupVariant.PICKUP_REDCHEST,
	PickupVariant.PICKUP_REDCHEST
}

local ReadyToRoll = {
	114514, --箱子
	PickupVariant.PICKUP_GRAB_BAG,
	PickupVariant.PICKUP_GRAB_BAG,
	PickupVariant.PICKUP_PILL,
	PickupVariant.PICKUP_PILL,
	PickupVariant.PICKUP_COLLECTIBLE,
	PickupVariant.PICKUP_TAROTCARD,
	PickupVariant.PICKUP_TAROTCARD,
	PickupVariant.PICKUP_TRINKET
}

--使用效果
local function Roll(_,item, rng, player, flags, slot)
	if (flags & UseFlag.USE_CARBATTERY <= 0) then --拒绝车载电池
		
		for _,ent in pairs(Isaac.FindByType(5,100,0)) do
			local itemPool = Game():GetItemPool()
			local variant = 100
			local subType = 0
			local result = ReadyToRoll[rng:RandomInt(10) + 1] or 114514
			
			--箱子
			if (result == 114514) then
				variant = ChestVariant[rng:RandomInt(18) + 1] or PickupVariant.PICKUP_CHEST
			else
				variant = result
			end
			
			--抽取掉落物
			--(虽然部分掉落物有替换机制,但为了提高稀有掉落物出现概率还是做了随机)
			if (variant == PickupVariant.PICKUP_GRAB_BAG) then
				subType = rng:RandomInt(2) + 1
				
			elseif (variant == PickupVariant.PICKUP_PILL) then
				subType = itemPool:GetPill(rng:Next())
			
			elseif (variant == PickupVariant.PICKUP_COLLECTIBLE) then
				local pool = Pools:GetRoomPool(rng:GetSeed())
				subType = itemPool:GetCollectible(pool, true, rng:Next(), 25)
				
			elseif (variant == PickupVariant.PICKUP_TAROTCARD) then
				subType = itemPool:GetCard(rng:Next(), true, true, false)
				
			elseif (variant == PickupVariant.PICKUP_TRINKET) then
				subType = itemPool:GetTrinket()
			end
			
			local pickup = Isaac.Spawn(5, variant, subType, ent.Position, Vector.Zero, nil):ToPickup()
			pickup.AutoUpdatePrice = false
			ent:Remove()
			
			--无美德书6秒后消失
			local virtue = player:HasCollectible(584) and (flags & UseFlag.USE_NOANIM <= 0 or flags & UseFlag.USE_ALLOWWISPSPAWN > 0)
			if not virtue then
				pickup.Timeout = 180
				pickup:SetColor(Color(0.5,0.5,0.5,0.5), -1, 3, false, true)
			end
			
			--无彼列书加尖刺
			if not player:HasCollectible(59) then
				pickup.Price = PickupPrice.PRICE_SPIKES
			end

			--特效
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 0, pickup.Position, Vector.Zero, nil)
			Game():ShakeScreen(30)
			SFXManager():Play(SoundEffect.SOUND_DEATH_CARD)
		end
		
		return {ShowAnim = false, Discharge = true}
	end	
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, Roll, IBS_Item.redeath)
