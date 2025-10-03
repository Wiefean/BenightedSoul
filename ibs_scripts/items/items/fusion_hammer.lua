--融合之锤

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local FusionHammer = mod.IBS_Class.Item(mod.IBS_ItemID.FusionHammer)

--吞饰品
function FusionHammer:SmeltTrinkets(player)
	for i = 0,1 do
		local trinket = player:GetTrinket(0)
		if trinket > 0 then
			player:TryRemoveTrinket(trinket)
			if trinket < 32768 then trinket = trinket + 32768 end
			player:AddSmeltedTrinket(trinket, false)
			sfx:Play(mod.IBS_Sound.Dang)
		end
	end	
end

--拾取时自动吞饰品
function FusionHammer:OnGain(item, charge, first, slot, varData, player)
	if first then
		self:SmeltTrinkets(player)
	end
end
FusionHammer:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', FusionHammer.ID)

--饰品变成金色
function FusionHammer:OnTrinketUpdate(pickup)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	if pickup.SubType < 32768 then
		pickup:Morph(5, 350, pickup.SubType + 32768, true, true, true)
	end
end
FusionHammer:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnTrinketUpdate', 350)

--阻止替换饰品
function FusionHammer:PrePickupCollision(pickup, other)
	local player = other:ToPlayer()
	if player and player:HasCollectible(self.ID) then
		local MAX = player:GetMaxTrinkets() --获取最多能拾取的饰品数量
		local num = 0
		
		for slot = 0,1 do
			local trinket = player:GetTrinket(slot)
			if trinket > 0 then
				num = num + 1
				if num >= MAX then
					return false
				end
			end
		end			
		
	end	
end
FusionHammer:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, 233, 'PrePickupCollision', 350)

--属性
function FusionHammer:OnEvaluateCache(player, flag)
	if player:HasCollectible(self.ID) then
		local num = player:GetCollectibleNum(self.ID)
		if flag == CacheFlag.CACHE_DAMAGE then
			self._Stats:Damage(player, 0.75*num)
		end
	end	
end
FusionHammer:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


--硬核禁止丢弃饰品
--在移除角色身上饰品的一瞬间进行检测
--兼容性欠佳
local cache = {}
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	for k,v in ipairs(cache) do
		if v.Timeout > 0 then
			v.Timeout = v.Timeout - 1
		else
			table.remove(cache, k)
		end
	end
end)

function FusionHammer:OnTrinketInit(pickup)
	if pickup.SubType <= 0 then return end
	local ent = pickup.SpawnerEntity
	if ent and ent:ToPlayer() and config:GetTrinket(pickup.SubType) then
		table.insert(cache, {ID = pickup.SubType, Pickup = pickup, Timeout = 1})
	end
end
FusionHammer:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnTrinketInit', 350)

function FusionHammer:OnLoseTrinket(player, trinket)
	if player:HasCollectible(self.ID) and trinket > 0 and Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
		for k,v in ipairs(cache) do
			if v.ID == trinket or (v.ID - 32768) == trinket then
				local pickup = v.Pickup
				if self._Ents:IsTheSame(player, pickup.SpawnerEntity) then
					player:QueueItem(config:GetTrinket(pickup.SubType), 0, true, true, pickup:GetVarData())
					player:AnimateCollectible(self.ID)
					pickup:Remove()
					table.remove(cache, k)
					sfx:Play(mod.IBS_Sound.Dang)
				end
			end
		end		
	end
end
FusionHammer:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, 'OnLoseTrinket')



return FusionHammer