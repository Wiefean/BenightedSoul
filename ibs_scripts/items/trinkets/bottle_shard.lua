--酒瓶碎片

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local BottleShard = mod.IBS_Class.Trinket(mod.IBS_TrinketID.BottleShard)


--打怪概率造成流血
function BottleShard:OnTakeDMG(ent, dmg, flag, source, cd)
	if (flag & DamageFlag.DAMAGE_CLONES <= 0) and self._Ents:IsEnemy(ent) then
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasTrinket(self.ID) then
				local chance = math.min(50, 10 * player:GetTrinketMultiplier(self.ID))
				
				if player:GetTrinketRNG(self.ID):RandomInt(100) < chance then
					ent:AddBleeding(EntityRef(player), 180)
					ent:TakeDamage(3, DamageFlag.DAMAGE_IGNORE_ARMOR |DamageFlag.DAMAGE_CLONES, EntityRef(player), 0)
					sfx:Play(540,0.8,15)
				end
			end	
		end
	end
end
BottleShard:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, 'OnTakeDMG')


return BottleShard