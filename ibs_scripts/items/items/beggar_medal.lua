--乞丐章

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local Pools = mod.IBS_Lib.Pools

local game = Game()

local BeggarMedal = mod.IBS_Class.Item(IBS_ItemID.BeggarMedal)


--使用效果
function BeggarMedal:OnUse(item, rng, player, flags, slot)
	if (flags & UseFlag.USE_OWNED > 0 or flags & UseFlag.USE_VOID > 0) and (flags & UseFlag.USE_CARBATTERY <= 0) then
		local data = self._Players:GetData(player)
		data.BeggarMedalUsed = true
		
		--美德书
		if player:HasCollectible(584) and (flags & UseFlag.USE_NOANIM <= 0 or flags & UseFlag.USE_ALLOWWISPSPAWN > 0) then
			player:AddItemWisp(IBS_ItemID.SOG, player.Position, true)
		end
		
		--彼列书
		if player:HasCollectible(59) then
			data.BeggarMedalUsedB = true
		end		
		
		player:AddCollectible(144)
		player:AddCollectible(278)
		player:AddCollectible(388)
		
		return {ShowAnim = true, Remove = true}
	end
end
BeggarMedal:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', BeggarMedal.ID)

function BeggarMedal:OnNewLevel()
	if game:GetLevel():GetStage() == 1 then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = self._Players:GetData(player)
		if data.BeggarMedalUsed then
			player:RemoveCollectible(144, true)
			player:RemoveCollectible(388, true)
			
			--彼列书不移除恶魔乞丐
			if not data.BeggarMedalUsedB then			
				player:RemoveCollectible(278, true)
			end
			
			data.BeggarMedalUsed = nil
			data.BeggarMedalUsedB = nil
		end
	end
end
BeggarMedal:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, -1, 'OnNewLevel')


return BeggarMedal