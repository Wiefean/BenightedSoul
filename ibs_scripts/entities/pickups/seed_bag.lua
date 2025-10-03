--种子袋

local mod = Isaac_BenightedSoul
local IBS_PickupID = mod.IBS_PickupID
local Pickups = mod.IBS_Lib.Pickups

local game = Game()
local sfx = SFXManager()

local SeedBag = mod.IBS_Class.Pickup{
	Variant = IBS_PickupID.SeedBag.Variant,
	SubType = IBS_PickupID.SeedBag.SubType,
	Name = {zh = '种子袋', en = 'Seed Bag'}
}

--概率替换福袋
function SeedBag:TryReplace(pickup)
	if not self:GetIBSData('persis')["BCBA"].MegaSatan then return end
	if pickup.Variant == 69 and pickup.SubType == 1 and RNG(pickup.InitSeed):RandomInt(100) < 10 then
		pickup:Morph(5, self.Variant, self.SubType, true, true)
	end
end
SeedBag:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'TryReplace', 69)


--更新
function SeedBag:OnPickupUpdate(pickup)
	if pickup.SubType ~= self.SubType then return end
	
	--音效
	if pickup:GetSprite():IsEventTriggered('DropSound') then
		sfx:Play(SoundEffect.SOUND_FETUS_JUMP)
	end
	
	--挥动拾取检测
	local player = Pickups:GetSwingPickupPlayer(pickup)
	if player then
		Pickups:TryCollect(pickup, player)
	end
end
SeedBag:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnPickupUpdate', SeedBag.Variant)

--拾取
function SeedBag:OnCollision(pickup, collider)
	if pickup.SubType ~= self.SubType then return end
	local player = collider:ToPlayer()
	if player and Pickups:CanCollect(pickup, player) then
		Pickups:PlayCollectAnim(pickup)
		local rng = RNG(pickup.InitSeed)
		local id = mod.IBS_TrinketID.WheatSeeds
		
		--必定生成一个种子
		Isaac.Spawn(5,350, id, pickup.Position, RandomVector() * 3, pickup)

		--尝试额外生成种子或咕噜药
		for i = 1,4 do
			if rng:RandomInt(100) < 50 then
				if rng:RandomInt(100) < 50 then
					Isaac.Spawn(5,350, id, pickup.Position, RandomVector() * 3, pickup)
				else
					local itemPool = game:GetItemPool()
					local pillColor = itemPool:ForceAddPillEffect(43)
					itemPool:IdentifyPill(pillColor)
					Isaac.Spawn(5,70, pillColor, pickup.Position, RandomVector() * 3, pickup)
				end
			end		
		end
		
		pickup:Remove()
		sfx:Play(SoundEffect.SOUND_SHELLGAME)
	end	
end
SeedBag:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, 'OnCollision', SeedBag.Variant)


return SeedBag