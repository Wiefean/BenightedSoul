--嗝屁猫砂盆

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local GuppysPotty = mod.IBS_Class.Item(mod.IBS_ItemID.GuppysPotty)

--清理房间后生成大便
function GuppysPotty:OnRoomClened()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			player:UseActiveItem(36, false, false)
		end
	end
end
GuppysPotty:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomClened')
GuppysPotty:AddCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, 'OnRoomClened')


--拾取时吞下2个小幼虫
function GuppysPotty:OnGainItem(item, charge, first, slot, varData, player)
	if first then
		for i = 1,2 do
			player:AddSmeltedTrinket(86)
		end
		sfx:Play(SoundEffect.SOUND_VAMP_GULP)
	end
end
GuppysPotty:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', GuppysPotty.ID)



return GuppysPotty