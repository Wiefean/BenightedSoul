--骨猪一掷

local mod = Isaac_BenightedSoul
local Damage = mod.IBS_Class.Damage()

local game = Game()

local BaconSaver = mod.IBS_Class.Trinket(mod.IBS_TrinketID.BaconSaver)

--是否应该移除
function BaconSaver:ShouldRemove(player, flag, source)
	return Damage:IsPenalt(player, flag, source)
end

--效果
function BaconSaver:OnTakeDMG(ent, dmg, flag, source)
	if dmg <= 0 then return end
	local player = ent:ToPlayer()
	if player and player:HasTrinket(self.ID) and self:ShouldRemove(player, flag, source) then
		player:TryRemoveTrinket(self.ID)
		self:DelayFunction(function()
			player:UseCard(56, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
			player:UseCard(49, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
			SFXManager():Play(267)
		end, 1)
	end
end
BaconSaver:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')


return BaconSaver