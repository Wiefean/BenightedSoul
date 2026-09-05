--鲜血钥匙

local mod = Isaac_BenightedSoul

local game = Game()

local BloodKeys = mod.IBS_Class.Item(mod.IBS_ItemID.BloodKeys)

--受伤
function BloodKeys:OnTakeDMG(ent)
	local player = ent:ToPlayer()

	if player and player:HasCollectible(self.ID) and player:GetNumKeys() > 0 then
		player:AddKeys(-1)
		for i = 1,2 do
			Isaac.Spawn(5, 30, 1, ent.Position, RandomVector(), nil)
		end
	end
end
BloodKeys:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')


return BloodKeys