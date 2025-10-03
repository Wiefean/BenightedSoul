--乾坤十掷挑战

local mod = Isaac_BenightedSoul

local game = Game()

local BC1 = mod.IBS_Class.Challenge(1, {
	PaperNames = {'bisaac_up'},
	Destination = 'Foot'
})


--10次以撒魂
function BC1:RollTen()
	if self:Challenging() and game:GetRoom():IsFirstVisit() then
		for i = 1,10 do
			Isaac.GetPlayer(0):UseCard(81, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
		end
					
		--移除烟雾特效
		for _,poof in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.POOF01)) do
			poof:Remove()
		end
	end
end
BC1:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'RollTen')

--完成
function BC1:TryFinish()
	if self:IsUnfinished() and self:AtDestination() then
		self:Finish(true, true)
	end
end
BC1:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, 'TryFinish', EntityType.ENTITY_MOM)


return BC1