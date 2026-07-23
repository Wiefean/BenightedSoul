--参孙技能
--愚者

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(1, {
	CalmStateTrans = 1,
	WrathStateTrans = 0,
	
	CalmCost = 1,
	WrathCost = 1,
})

--切换房间触发
function Skill:OnNewRoom()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if self:HasCard(player) then
			local data = self._Players:GetData(player).Posture
			if data then
				for i = 5,1,-1 do
					local id = data.Cards[i]
					if id and id > 0 then		
						data.DoingSelection = i
						break
					end
				end
				data.NextSelection = 1
			end
		end
	end	
end
Skill:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

return Skill