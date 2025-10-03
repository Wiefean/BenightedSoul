--地精容貌

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local GremlinMask = mod.IBS_Class.Trinket(mod.IBS_TrinketID.GremlinMask)

--进房上状态
function GremlinMask:OnNewRoom()	
	if self._Finds:ClosestEnemy(Vector.Zero, true) ~= nil then
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasTrinket(self.ID) then
				local mult = player:GetTrinketMultiplier(self.ID)
				player:AddFear(EntityRef(player), 30)
				
				for _,ent in ipairs(Isaac.GetRoomEntities()) do
					if self._Ents:IsEnemy(ent, true) then
						ent:SetBossStatusEffectCooldown(0)
						ent:AddWeakness(EntityRef(tear), 120*mult)
						ent:SetBossStatusEffectCooldown(0)
						ent:AddFear(EntityRef(tear), 150)
					end
				end
			end
		end
	end	
end
GremlinMask:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, 999, 'OnNewRoom')


return GremlinMask