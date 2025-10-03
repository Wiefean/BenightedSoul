--天妒英才挑战

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

local BC10 = mod.IBS_Class.Challenge(10, {
	PaperNames = {'beden_up'},
	Destination = 'Isaac'
})

--角色初始化
function BC10:OnPlayerInit(player)
	if not self:Challenging() then return end
	self:DelayFunction2(function()
		if self:Challenging() and not self:IsGameContinued() then
			player:AddBombs(-1)
			player:ChangePlayerType(mod.IBS_PlayerID.BEden)
			player:SetPocketActiveItem(IBS_ItemID.Defined, ActiveSlot.SLOT_POCKET, false)
		end
	end, 1)		
end
BC10:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, 'OnPlayerInit')

--全员嫉妒
function BC10:PreGetCol(player)
	if not self:Challenging() then return end
	return IBS_ItemID.Envy
end
BC10:AddPriorityCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, 666, 'PreGetCol')

--完成
function BC10:TryFinish()
	if self:IsUnfinished() and self:AtDestination() then
		self:Finish(true, true)
	end
end
BC10:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'TryFinish')


return BC10