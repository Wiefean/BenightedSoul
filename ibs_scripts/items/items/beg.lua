--乞讨

local mod = Isaac_BenightedSoul
local Pools = mod.IBS_Lib.Pools

local game = Game()
local sfx = SFXManager()

local Beg = mod.IBS_Class.Item(mod.IBS_ItemID.Beg)


--使用效果
function Beg:OnUse(item, rng, player, flags, slot)
	if rng:RandomInt(100) < 5 then
		for _,ent in ipairs(Isaac.GetRoomEntities()) do
			if ent:IsActiveEnemy() and self._Ents:IsEnemy(ent, true, false, true) then
				Isaac.Spawn(5,20,1, ent.Position, RandomVector(), nil)
				Isaac.Spawn(1000,15,0, ent.Position, Vector.Zero, nil)
				
				--美德书
				if player:HasCollectible(584) and (flags & UseFlag.USE_NOANIM <= 0 or flags & UseFlag.USE_ALLOWWISPSPAWN > 0) then
					player:AddWisp(0, player.Position)
				end
				
				--彼列书
				if player:HasCollectible(59) then
					Isaac.Spawn(5,40,1, ent.Position, RandomVector(), nil)
				end
				
				ent:Remove()
				
				break
			end
		end
	end
	sfx:Play(143, 0.5, 15, false, 0.1*math.random(12, 20))
	return true
end
Beg:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', Beg.ID)


return Beg