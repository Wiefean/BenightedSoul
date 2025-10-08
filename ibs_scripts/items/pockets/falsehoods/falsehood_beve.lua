--夏娃的伪忆

local mod = Isaac_BenightedSoul
local MyFruit = mod.IBS_Item.MyFruit

local game = Game()

local BEve = mod.IBS_Class.Pocket(mod.IBS_PocketID.BEve)

--使用效果
function BEve:OnUse(card, player, flag)
	MyFruit:EnableRandomBless(player:GetCardRNG(self.ID):Next(), true)

	--已有所有祝福时移除3碎心
	if MyFruit:HasAllBlesses() and player:GetBrokenHearts() > 0 then
		player:AddBrokenHearts(-3)
		SFXManager():Play(266)
	end

	--移除诅咒
	local level = game:GetLevel()
	level:RemoveCurses(level:GetCurses())
end
BEve:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', BEve.ID)


--符文佩剑(东方mod)
if mod.IBS_Compat.THI:IsEnabled() then
	local RuneSword = THI.Collectibles.RuneSword

	mod.IBS_Compat.THI:AddRuneSwordCompat(BEve.ID, {
		png = "gfx/ibs/items/pick ups/falsehoods/beve.png",
		textKey = "FALSEHOOD_BEVE",
		name = {
			zh = "夏娃的伪忆",
			en = "Falsehood of Eve",
		},
		desc = {
			zh = "头目战后清除诅咒",
			en = "Clear curses after Boss",
		}, 
	})
	
	--清理boss房后清除诅咒
	function BEve:OnRoomCleaned(player)
		if not RuneSword:HasGlobalRune(self.ID) then return end
		if game:GetRoom():GetType() ~= RoomType.ROOM_BOSS then return end
		local level = game:GetLevel()
		level:RemoveCurses(level:GetCurses())
	end
	BEve:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')
	
	--boss波次
	function BEve:OnWaveEndState(state)
		if state == 2 and RuneSword:HasGlobalRune(self.ID) then
			local level = game:GetLevel()
			level:RemoveCurses(level:GetCurses())
		end
	end
	BEve:AddCallback(mod.IBS_CallbackID.GREED_WAVE_END_STATE, 'OnWaveEndState')	
	
end

return BEve