--瓷

local mod = Isaac_BenightedSoul
local IronHeart = mod.IBS_Class.IronHeart()
local TempIronHeart = mod.IBS_Class.TempIronHeart()

local game = Game()

local China = mod.IBS_Class.Item(mod.IBS_ItemID.China)

--获得心时给铁心
function China:OnGainHeart(player, num, flag)
	if num > 0 and (flag & AddHealthType.NONE <= 0) and (flag & AddHealthType.MAX <= 0) and (flag & AddHealthType.BONE <= 0) and (flag & AddHealthType.BROKEN <= 0) and player:HasCollectible(self.ID) then
		local playerType = player:GetPlayerType()
		local mult = player:GetCollectibleNum(self.ID)

		--表表抹
		if playerType == (mod.IBS_PlayerID.BMaggy) then
			local data = IronHeart:GetData(player)
			data.Extra = data.Extra + mult*num
		else
			local data = TempIronHeart:GetData(player)
			data.Num = data.Num + mult*num
		end
	end
end
China:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_HEARTS, 'OnGainHeart')


return China
