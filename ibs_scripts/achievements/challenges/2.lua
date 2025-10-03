--易碎品挑战

local mod = Isaac_BenightedSoul
local IronHeart = mod.IBS_Class.IronHeart()

local game = Game()

local BC2 = mod.IBS_Class.Challenge(2, {
	PaperNames = {'bmaggy_up'},
	Destination = 'Heart'
})

--角色初始化
function BC2:OnPlayerInit(player)
    if not self:Challenging() then return end
	self:DelayFunction2(function()
		if not self:IsGameContinued() then
			player:AddSmeltedTrinket(88) --用于拒绝主动道具

			if player:GetActiveItem(2) == 45 then --去除副手美心
				player:SetPocketActiveItem(0, ActiveSlot.SLOT_POCKET, true)
			end
		end
	end, 1)
end
BC2:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, 'OnPlayerInit')

--检查铁心
function BC2:CheckIronHeart(player)
	if self:Challenging() then
		return true
	end
end
BC2:AddCallback(mod.IBS_CallbackID.CHECK_IRON_HEART, 'CheckIronHeart')


--完成
function BC2:TryFinish()
	if self:IsUnfinished() and self:AtDestination() then
		self:Finish(true, true)
	end
end
BC2:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, 'TryFinish', EntityType.ENTITY_MOMS_HEART)


return BC2