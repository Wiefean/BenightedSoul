--剥落古老肉

local mod = Isaac_BenightedSoul

local game = Game()

local DeciduousMeat = mod.IBS_Class.Item(mod.IBS_ItemID.DeciduousMeat)

--获得时填充腐心
function DeciduousMeat:OnGain(item, charge, first, slot, varData, player)
	if first then
		player:AddRottenHearts(24)
		player:AddBloodCharge(12)
	end
end
DeciduousMeat:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', DeciduousMeat.ID)

--受伤概率生成腐心
function DeciduousMeat:OnTakeDMG(ent)
	local player = ent:ToPlayer()
	if player and player:HasCollectible(self.ID) and player:GetCollectibleRNG(self.ID):RandomInt(100) < 25 then
		local pickup = Isaac.Spawn(5, 10, 12, player.Position, 3*RandomVector(), nil):ToPickup()
		pickup.Wait = 60
	end	
end
DeciduousMeat:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')


return DeciduousMeat