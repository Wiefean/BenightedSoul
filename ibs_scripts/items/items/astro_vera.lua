--星际芦荟

local mod = Isaac_BenightedSoul

local game = Game()

local AstroVera = mod.IBS_Class.Item(mod.IBS_ItemID.AstroVera)


--心数限制
function AstroVera:OnHeartLimit(player, limit, isKeeper)
	if not player:HasCollectible(self.ID) then return end
	if player:GetPlayerType() == PlayerType.PLAYER_THESOUL then return end --排除骨魂
	local healthType = player:GetHealthType()
	
	--仅对红心角色和魂心角色生效
	if healthType == 0 or healthType == 1 then
		return limit + 20
	end
end
AstroVera:AddCallback(ModCallbacks.MC_PLAYER_GET_HEART_LIMIT, 'OnHeartLimit')



return AstroVera