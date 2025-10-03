--小麦

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

local Wheat = mod.IBS_Class.Item(IBS_ItemID.Wheat)

Wheat.Name = {zh = '小麦', en = 'Wheat'}
Wheat.Desc = {zh = '喂饱羊羊 !', en = 'Feed your goats!'}

--效果
function Wheat:OnGain(item, charge, first, slot, varData, player)
	--挑战3
	if Isaac.GetChallenge() == mod.IBS_ChallengeID[3] then 
		player:RemoveCollectible(self.ID, true)
		for _,goat in pairs(Isaac.FindByType(891,0,0)) do
			if goat.Position:Distance(player.Position) ^ 2 <= 200 ^ 2 then
				goat:AddCharmed(EntityRef(player), -1)
				goat.MaxHitPoints = goat.MaxHitPoints + 12
				goat.HitPoints = goat.MaxHitPoints
				goat:SetColor(Color(0, 1, 0, 1, 0, 0.25, 0),30,2,true)
			end
		end
	end 
end
Wheat:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', Wheat.ID)

--玩家更新
function Wheat:OnPlayerUpdate(player)
	if Isaac.GetChallenge() == mod.IBS_ChallengeID[3] then return end
	if player:GetCollectibleNum(self.ID, true) >= 3 then
		if #Isaac.FindByType(5, 100, IBS_ItemID.Bread) < 3 then	--最多同时生成三个面包	
			for i = 1,3 do
				player:RemoveCollectible(self.ID, true)
			end
			local room = game:GetRoom()
			local pos = room:FindFreePickupSpawnPosition(player.Position + Vector(0,80), 0, true)
			Isaac.Spawn(5,100, IBS_ItemID.Bread, pos, Vector.Zero, nil, 0, false)		
		end
	end
end
Wheat:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)

--属性
function Wheat:OnEvaluateCache(player, flag)
	if player:HasCollectible(self.ID) then
		local num = player:GetCollectibleNum(self.ID)
		if flag == CacheFlag.CACHE_SPEED then
			self._Stats:Speed(player, 0.2*num)
		end
	end	
end
Wheat:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')

--牧地挑战特殊描述
mod:AddCallback(mod.IBS_CallbackID.PICK_COLLECTIBLE, function(_,player, item)
	if Isaac.GetChallenge() == mod.IBS_ChallengeID[3] then
		game:GetHUD():ShowItemText(Wheat.Name[mod.Language], Wheat.Desc[mod.Language])
	end
end, Wheat.ID)


return Wheat