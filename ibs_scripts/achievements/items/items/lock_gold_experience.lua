--解锁黄金体验

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local Achievement = mod.IBS_Class.Achievement

local game = Game()

local GoldExperience = Achievement('geUnlocked', {
	PaperNames = {'ge'},
	Items = {IBS_ItemID.GoldExperience}
})


--表里店主死在硬币旁以解锁
function GoldExperience:OnKilled(ent)
	if self:IsLocked() and not game:AchievementUnlocksDisallowed() then
		local player = ent:ToPlayer()
		if player then
			local playerType = player:GetPlayerType()
			if playerType == 14 or playerType == 33 then
				for _,pickup in pairs(Isaac.FindInRadius(player.Position, 70, EntityPartition.PICKUP)) do
					if pickup.Variant == 20 then
						self:Unlock(true, true)
						break
					end
				end
			end
		end
	end	
end
GoldExperience:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnKilled', EntityType.ENTITY_PLAYER)


return GoldExperience