--游魂的伪忆

local mod = Isaac_BenightedSoul

local game = Game()

local BLost = mod.IBS_Class.Pocket(mod.IBS_PocketID.BLost)


--将非白箱箱子变为白箱,否则生成一个
function BLost:OnUse(card, player, flag)
	local did = false

	for _,ent in ipairs(Isaac.FindByType(5)) do
		local pickup = ent:ToPickup()
		if pickup and self._Pickups:IsChest(pickup.Variant) and pickup.Variant ~= 53 then
			pickup:Morph(5, 53, 2, true, true, true)
			Isaac.Spawn(1000, 15, 0, pickup.Position, Vector.Zero, nil) --烟雾特效
			did = true
		end
	end
	
	if not did then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(player.Position + Vector(0,80), 0, true)
		Isaac.Spawn(5, 53, 2, pos, Vector.Zero, nil)
		Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil) --烟雾特效
	end
end
BLost:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', BLost.ID)


--符文佩剑(东方mod)
if mod.IBS_Compat.THI:IsEnabled() then
	local RuneSword = THI.Collectibles.RuneSword

	mod.IBS_Compat.THI:AddRuneSwordCompat(BLost.ID, {
		png = "gfx/ibs/items/pick ups/falsehoods/blost.png",
		textKey = "FALSEHOOD_BLOST",
		name = {
			zh = "游魂的伪忆",
			en = "Falsehood of the Lost",
		},
		desc = {
			zh = "钥匙眼泪",
			en = "Key tears",
		}, 
	})
	
	--钥匙眼泪
	function BLost:OnFireTear(tear)
		local player = self._Ents:IsSpawnerPlayer(tear, true)

		if player and RuneSword:HasInsertedRune(player, self.ID) then
			local rng = player:GetCollectibleRNG(623)
			local chance = 25*RuneSword:GetInsertedRuneNum(player, self.ID)
			if rng:RandomInt(100) < chance then
				tear:ChangeVariant(43)				
				local scale = self._Maths:TearDamageToScale(tear.CollisionDamage+1)
				tear.SpriteScale = Vector(scale, scale)
				tear:Update()
			end
		end
	end
	BLost:AddPriorityCallback(ModCallbacks.MC_POST_FIRE_TEAR, 200, 'OnFireTear')
	
end

return BLost