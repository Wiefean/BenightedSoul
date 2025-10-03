--破损的迷途之镜

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()
local sfx = SFXManager()

local WilderingMirror2 = mod.IBS_Class.Item(IBS_ItemID.WilderingMirror2)

--使用
function WilderingMirror2:OnUse(item, rng, player, flag, slot)
	if player:GetNumCoins() > 10 then
		player:AddCoins(-10)
		player:AddCollectible(IBS_ItemID.WilderingMirror, 0, false)
		game:GetLevel():RemoveCurses(LevelCurse.CURSE_OF_THE_LOST)
		sfx:Play(274)
		return {ShowAnim = true, Discharge = true, Remove = true}
	end
	return {ShowAnim = false, Discharge = false}
end
WilderingMirror2:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', WilderingMirror2.ID)


return WilderingMirror2