--增殖的G

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local MaxxC = mod.IBS_Class.Item(mod.IBS_ItemID.MaxxC)

--获取满足要求的道具ID
function MaxxC:GetItemID(player, seed)
	local itemPool = game:GetItemPool()
	local result = {}
	
	--有彼列书且无混沌则为恶魔池,否则随机池
	local pool = (player:HasCollectible(59) and not PlayerManager.AnyoneHasCollectible(402) and 3)
				 or itemPool:GetRandomPool(RNG(seed))
	
	--品质高于1的被动道具
	for _,v in ipairs(itemPool:GetCollectiblesFromPool(pool)) do
		local id = v.itemID
		local itemConfig = config:GetCollectible(id)
		if itemConfig and itemConfig:IsAvailable() and itemConfig:HasTags(ItemConfig.TAG_SUMMONABLE) and itemConfig.Quality >= 2 and itemConfig.Type ~= ItemType.ITEM_ACTIVE then
			table.insert(result, id)
		end	
	end	
	
	--抽取一个
	if #result > 0 then
		return result[RNG(seed):RandomInt(1, #result)] or result[1]
	end
	
	--默认悲伤洋葱
	return 1
end

--尝试使用
function MaxxC:OnTryUse(slot, player)
	return 0
end
MaxxC:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MIN_USABLE_CHARGE, 'OnTryUse', MaxxC.ID)

--使用
function MaxxC:OnUse(item, rng, player, flags, slot)
	if (flags & UseFlag.USE_CARBATTERY > 0) or (flags & UseFlag.USE_OWNED <= 0) then
		return
	end

	--消耗1格充能
	if not self._Players:DischargeSlot(player, slot, 1, true, false, true, true) then
		--尝试恢复上限骰(东方mod)
		if slot ~= 2 then
			mod.IBS_Compat.THI:TryRestoreDice(player, self.ID, slot)
		end	
		return {ShowAnim = false, Discharge = false}
	end

	self._Ents:GetTempData(player).MaxxC = true

	return {ShowAnim = true, Discharge = false}
end
MaxxC:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', MaxxC.ID)

--新生成敌人时生成道具魂火
function MaxxC:OnNpcInit(npc)
	if game:GetRoom():GetFrameCount() < 3 then return end
	if not self._Ents:IsEnemy(npc, true) then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if self._Ents:GetTempData(player).MaxxC then
			local rng = player:GetCollectibleRNG(self.ID)
			local wisp = player:AddItemWisp(self:GetItemID(player, rng:Next()), player.Position, true)
			local hp = 2
			
			--美德书
			if player:HasCollectible(584) then
				hp = 4
			end

			wisp.MaxHitPoints = hp
			wisp.HitPoints = hp
		end
	end
end
MaxxC:AddPriorityCallback(ModCallbacks.MC_POST_NPC_INIT, CallbackPriority.LATE, 'OnNpcInit')

--新房间清除数据
function MaxxC:OnNewRoom()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		self._Ents:GetTempData(player).MaxxC = nil
	end
end
MaxxC:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, -1000, 'OnNewRoom')


return MaxxC