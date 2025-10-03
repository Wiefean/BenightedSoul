--双角斧

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

local TheHornedAxe = mod.IBS_Class.Item(IBS_ItemID.TheHornedAxe)

--游戏更新
function TheHornedAxe:OnUpdate()
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local room = game:GetRoom()
	if room:IsClear() then return end
	local frame = game:GetFrameCount()
	if frame > 0 and frame % 391 == 0 and self._Finds:ClosestEnemy(Vector.Zero) ~= nil then
		local player = Isaac.GetPlayer(0)
		player:UseCard(14, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
		self:DelayFunction(function()		
			player:UseCard(69, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)		
		end, 1)
	end
end
TheHornedAxe:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnUpdate', 0)

--属性变动
function TheHornedAxe:OnEvalueateCache(player, flag)
	if flag == CacheFlag.CACHE_DAMAGE and player:HasCollectible(self.ID) then
		self._Stats:Damage(player, 1.3)
	end
end
TheHornedAxe:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache')

return TheHornedAxe