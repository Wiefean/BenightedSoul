--伯大尼的伪忆

local mod = Isaac_BenightedSoul

local game = Game()

local Relic = mod.IBS_Pickup.Relic
local BXXXOrb = mod.IBS_Familiar.BXXXOrb

local BBeth = mod.IBS_Class.Pocket(mod.IBS_PocketID.BBeth)

--持有时生成虚影道具
function BBeth:OnNewRoom()
	local room = game:GetRoom()
	if not room:IsFirstVisit() then return end
	local num = 0

	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		for slot = 0,3 do
			if player:GetCard(slot) == self.ID then
				num = num + 1
			end
		end
	end

	--考虑伪忆球
	for _,ent in pairs(Isaac.FindByType(3, BXXXOrb.Variant, BXXXOrb.SubType.BBeth)) do
		num = num + 1
	end	

	if num > 0 then
		local rng = RNG(self._Levels:GetRoomUniqueSeed())
		for i = 1,num do		
			Relic:Spawn(Relic:GetItemFromPool(rng:Next()))
		end
	end
end
BBeth:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--触发最近记录的效果
function BBeth:OnUse(card, player, flag)
	local data = Relic:GetData()
	for k,id in ipairs(data) do
		player:UseActiveItem(id, false, false)
	end
	
	--贪婪模式
	if game:IsGreedMode() then
		if #data >= 4 then
			local room = game:GetRoom()
			local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
			Isaac.Spawn(5, 300, self.ID, pos, Vector.Zero, nil)
		end
		for k,id in ipairs(data) do
			data[k] = nil
		end
	end
end
BBeth:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', BBeth.ID)

--记录满四个时在下一层再获得一个
function BBeth:OnNewLevel()
	local data = Relic:GetData()
	local level = game:GetLevel()

	if not self:IsStartingRun() and not game:IsGreedMode() then
		if #data >= 4 then
			local room = game:GetRoom()
			local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
			Isaac.Spawn(5, 300, self.ID, pos, Vector.Zero, nil)
		end
	end
	for k,id in ipairs(data) do
		data[k] = nil
	end	
end
BBeth:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

--符文佩剑(东方mod)
if mod.IBS_Compat.THI:IsEnabled() then
	local RuneSword = THI.Collectibles.RuneSword

	mod.IBS_Compat.THI:AddRuneSwordCompat(BBeth.ID, {
		png = "gfx/ibs/items/pick ups/falsehoods/BBeth.png",
		textKey = "FALSEHOOD_BBETH",
		name = {
			zh = "伯大尼的伪忆",
			en = "Falsehood of Bethany",
		},
		desc = {
			zh = "联动",
			en = "Resonance",
		}, 
	})
	
	--使用符文佩剑
	function BBeth:OnUseItem(item, rng, player)
		local num = RuneSword:GetInsertedRuneNum(player, self.ID)
		if num > 0 then
			for i = 1,2*num do
				local item = Relic:GetItemFromPool(rng:Next())
				player:UseActiveItem(item, false, false)
			end
		end
	end
	BBeth:AddPriorityCallback(ModCallbacks.MC_USE_ITEM,  CallbackPriority.EARLY, 'OnUseItem', RuneSword.Item)
	
end

return BBeth