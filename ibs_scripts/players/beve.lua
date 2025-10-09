--昧化夏娃

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local CharacterLock = mod.IBS_Achiev.CharacterLock

local game = Game()
local sfx = SFXManager()

local BEve = mod.IBS_Class.Character(mod.IBS_PlayerID.BEve, {
	BossIntroName = 'beve',
	PocketActive = mod.IBS_ItemID.MyFruit,
})

--新层尝试换回我果
function BEve:OnPlayerNewLevel(player)
	if player:GetPlayerType() == self.ID then
		local slot = 2
		local item = player:GetActiveItem(slot)
		if item == mod.IBS_ItemID.MyFault then
			local varData = player:GetActiveItemDesc(slot).VarData
			if varData < 4 then
				player:SetPocketActiveItem(IBS_ItemID.MyFruit, slot, false)
				player:SetActiveVarData(varData, slot)
			end
		end
	end
end
BEve:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, 'OnPlayerNewLevel')

return BEve