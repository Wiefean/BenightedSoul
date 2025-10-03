--记忆碎片

local mod = Isaac_BenightedSoul
local IBS_PickupID = mod.IBS_PickupID
local Pickups = mod.IBS_Lib.Pickups

local Memories = mod.IBS_Class.Memories()

local Memory = mod.IBS_Class.Pickup{
	Variant = IBS_PickupID.Memory.Variant,
	SubType = IBS_PickupID.Memory.SubType,
}

--更新
function Memory:OnPickupUpdate(pickup)
	local spr = pickup:GetSprite()
	if spr:IsFinished("Appear") then spr:Play("Idle") end
	
	--调整贴图大小(非常好偷懒方式)
	if (pickup.SubType == self.SubType.Small) then
		pickup.SpriteScale = Vector(0.5,0.5)
	end
	if (pickup.SubType == self.SubType.Big) then
		pickup.SpriteScale = Vector(0.75,0.75)
	end
	
	--挥动拾取检测
	local player = Pickups:GetSwingPickupPlayer(pickup)
	if player then
		Pickups:TryCollect(pickup, player)
	end
end
Memory:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnPickupUpdate', Memory.Variant)

--拾取
function Memory:OnCollision(pickup, collider)
	local player = collider:ToPlayer()

	if player and Pickups:CanCollect(pickup, player) then
		local value = 1 if (pickup.SubType == self.SubType.Big) then value = 5 end
		Memories:Add(value)
		Pickups:PlayCollectAnim(pickup)
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
		SFXManager():Play(math.random(1,832), 1, 0, false, 0.01*math.random(150,250))
		pickup:Remove()
	end	
end
Memory:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, 'OnCollision', Memory.Variant)


return Memory