--肥大虫

local mod = Isaac_BenightedSoul

local game = Game()

local BulkyWorm = mod.IBS_Class.Item(mod.IBS_TrinketID.BulkyWorm)

--大只
function BulkyWorm:OnTrinketUpdate(pickup)
	local golden = (pickup.SubType == self.ID + 32768)
	if not (pickup.SubType == self.ID or golden) then return end
	local scale = 1.5
	pickup.SpriteScale = Vector(scale,scale)
	pickup:SetSize(pickup.Size, Vector(scale,scale), 24)
end
BulkyWorm:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, 'OnTrinketUpdate', PickupVariant.PICKUP_TRINKET)

--眼泪
function BulkyWorm:OnFireTear(tear)
	local player = self._Ents:IsSpawnerPlayer(tear, true)
    if player and player:HasTrinket(self.ID) then
		local mult = 1 + player:GetTrinketMultiplier(self.ID)
		tear.Scale = tear.Scale * mult
		tear:Update()
    end
end
BulkyWorm:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, 'OnFireTear')

--激光
function BulkyWorm:OnFireLaser(laser)
	local player = self._Ents:IsSpawnerPlayer(laser, true)
    if player and player:HasTrinket(self.ID) then
		local mult = 1 + player:GetTrinketMultiplier(self.ID)
		laser:SetScale(laser:GetScale() * mult)
		laser:Update()
    end
end
BulkyWorm:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER, 'OnFireLaser')
BulkyWorm:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, 'OnFireLaser')
BulkyWorm:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, 'OnFireLaser')


return BulkyWorm