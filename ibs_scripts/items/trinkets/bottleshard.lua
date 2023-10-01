--酒瓶碎片

local mod = Isaac_BenightedSoul
local IBS_Trinket = mod.IBS_Trinket
local Ents = mod.IBS_Lib.Ents

local sfx = SFXManager()


--打怪概率造成流血
local function bleed(_,ent, amount, flag, source)
	if (flag & DamageFlag.DAMAGE_CLONES <= 0) then
		for i = 0, Game():GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasTrinket(IBS_Trinket.bottleshard) then
				if ent:IsEnemy() and ent:IsVulnerableEnemy() then
					local extra = 0.1*(player:GetTrinketMultiplier(IBS_Trinket.bottleshard) - 1)
					if extra > 0.4 then extra = 0.4 end
					
					if player:GetTrinketRNG(IBS_Trinket.bottleshard):RandomFloat() + extra >= 0.9 then
						Ents:AddBleed(ent, 60)
						ent:TakeDamage(3, DamageFlag.DAMAGE_IGNORE_ARMOR |DamageFlag.DAMAGE_CLONES , EntityRef(player), 2)
						sfx:Play(540,0.8,15)
					end
				end
			end	
		end
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, bleed)