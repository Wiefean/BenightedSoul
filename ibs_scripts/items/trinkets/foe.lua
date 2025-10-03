--杜弗尔的头

local mod = Isaac_BenightedSoul

local sfx = SFXManager()

local Foe = mod.IBS_Class.Trinket(mod.IBS_TrinketID.Foe)

--更新
function Foe:OnTrinketUpdate(pickup)
	local golden = (pickup.SubType == self.ID + 32768)
	if not (pickup.SubType == self.ID or golden) then return end
	local box = PlayerManager.AnyoneHasCollectible(439)
	
	--变大
	if golden or box then
		local scale = 1
		local gridPoints = 12
		
		--金饰品+妈盒
		if golden and box then
			scale = 2
			gridPoints = 24
		elseif golden or box then --金饰品或妈盒
			scale = 1.5
			gridPoints = 16
		end

		pickup.SpriteScale = Vector(scale,scale)
		pickup:SetSize(pickup.Size, Vector(scale,scale), gridPoints)
	end
	
	--阻挡敌弹
	for _,ent in pairs(Isaac.FindByType(9)) do
		local proj = ent:ToProjectile()
		if proj and self._Ents:AreColliding(ent, pickup) then
			if not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
				proj:Die()
			end
		end
	end
end
Foe:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, 'OnTrinketUpdate', PickupVariant.PICKUP_TRINKET)


return Foe