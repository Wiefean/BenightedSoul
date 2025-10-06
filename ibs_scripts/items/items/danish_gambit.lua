--丹麦弃兵

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local DanishGambit = mod.IBS_Class.Item(mod.IBS_ItemID.DanishGambit)

--计算充能消耗
function DanishGambit:GetDischarge(player)
	local discharge = 4
	if player:HasCollectible(116) then discharge = discharge - 1 end --9伏特
	if discharge < 0 then discharge = 0 end
	return discharge
end

--尝试使用
function DanishGambit:OnTryUse(slot, player)
	return 0
end
DanishGambit:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MIN_USABLE_CHARGE, 'OnTryUse', DanishGambit.ID)

--获取符合条件的掉落物
function DanishGambit:AbsorbPickups(player, slot)
	local absorbed = false
	local trinkets = Isaac.FindByType(5,350) --饰品
	local items = Isaac.FindByType(5,100) --道具
	local currentCharges = self._Players:GetSlotCharges(player, slot, true, true)
	
	--检测正在拾取的物品
	if not player:IsItemQueueEmpty() then
		local queued = player.QueuedItem.Item
		local ID = queued.ID

		--饰品
		if (queued.Type == ItemType.ITEM_TRINKET) then
			local charge = (ID > 32768 and 3) or 1 --金饰品提供3充能
			self._Players:ChargeSlot(player, slot, charge, true, true)
			currentCharges = currentCharges + charge		
			
			player:FlushQueueItem()
			player:TryRemoveTrinket(ID)
			absorbed = true	
			Isaac.Spawn(1000, 15, 0, player.Position, Vector.Zero, nil) --烟雾特效
		else
			local itemConfig = config:GetCollectible(ID)
			
			--非便条
			if ID ~= 0 and ID ~= 668 and (itemConfig and itemConfig.Quality < 2) then
				local charge = (itemConfig.Quality == 1 and 2) or 1
				self._Players:ChargeSlot(player, slot, charge, true, true)
				currentCharges = currentCharges + charge							
				
				--移除道具
				player:FlushQueueItem()
				player:RemoveCollectible(ID, true)
				absorbed = true
				Isaac.Spawn(1000, 15, 0, player.Position, Vector.Zero, nil) --烟雾特效
			end	
		end
	end	
	
	--满6充能直接结束
	if currentCharges >= 6 then
		return absorbed,currentCharges
	end	
	
	for _,ent in ipairs(trinkets) do
		local trinket = ent:ToPickup()
		if trinket then
			local charge = (trinket.SubType > 32768 and 3) or 1 --金饰品提供3充能
			self._Players:ChargeSlot(player, slot, charge, true, true)
			currentCharges = currentCharges + charge		
			
			Isaac.Spawn(1000, 15, 0, trinket.Position, Vector.Zero, nil) --烟雾特效
			trinket:Remove()
			absorbed = true
			
			--满6充能直接结束
			if currentCharges >= 6 then
				return absorbed,currentCharges
			end
		end
	end
	
	for _,ent in ipairs(items) do
		local item = ent:ToPickup()
		if item then		
			local itemConfig = config:GetCollectible(item.SubType)
			if itemConfig and itemConfig.Quality < 2 then
				local charge = (itemConfig.Quality == 1 and 2) or 1
				self._Players:ChargeSlot(player, slot, charge, true, true)
				currentCharges = currentCharges + charge		
				
				Isaac.Spawn(1000, 15, 0, item.Position, Vector.Zero, nil) --烟雾特效
				item:TryRemoveCollectible()
				absorbed = true
				
				--满6充能直接结束
				if currentCharges >= 6 then
					return absorbed,currentCharges
				end
			end
		end
	end	
	
	return absorbed,currentCharges
end

--使用效果
function DanishGambit:OnUse(item, rng, player, flags, slot)
	if (flags & UseFlag.USE_CARBATTERY <= 0) and (flags & UseFlag.USE_VOID <= 0) and (flags & UseFlag.USE_OWNED > 0) then
		local closestItem = self._Finds:ClosestCollectible(player.Position)
		local charges = self._Players:GetSlotCharges(player, slot, true, true)
		
		--充能不足时使用
		if charges < 4 then
			local absorbed,currentCharges = self:AbsorbPickups(player, slot)
			
			--充能动画和音效
			if absorbed then
				game:GetHUD():FlashChargeBar(player, slot)
				if currentCharges == 4 or currentCharges == 8 then
					sfx:Play(SoundEffect.SOUND_BATTERYCHARGE)
				else
					sfx:Play(SoundEffect.SOUND_BEEP)
				end	
				return {ShowAnim = true, Discharge = false}
			end	
		else
			if self._Players:DischargeSlot(player, slot, self:GetDischarge(player), true, false, true, true) then

				--重置品质3及以下的道具为品质+1的随机道具,但不会超过3
				for _,ent in ipairs(Isaac.FindByType(5,100)) do
					local pickup = ent:ToPickup()
					local itemConfig = config:GetCollectible(ent.SubType)
					if pickup and pickup.SubType > 0 and itemConfig and itemConfig.Quality <= 3 then
						local pool = game:GetItemPool():GetRandomPool(rng)
					
						--默认随机池,有美德书改为天使,彼列书恶魔,都有则抽一个
						local virtue,belial = player:HasCollectible(584),player:HasCollectible(59)
						if virtue and belial then
							pool = ItemPoolType.POOL_ANGEL
							if rng:RandomInt(100) < 50 then
								pool = ItemPoolType.POOL_DEVIL
							end
						elseif virtue then
							pool = ItemPoolType.POOL_ANGEL
						elseif belial then
							pool = ItemPoolType.POOL_DEVIL
						end					
	
						newItem = self._Pools:GetCollectibleWithQuality(rng:Next(), math.min(3, itemConfig.Quality + 1), pool, true)
						pickup:Morph(5,100,newItem,true)
						pickup.Touched = false

						Isaac.Spawn(1000, 15, 0, pickup.Position, Vector.Zero, nil) --烟雾特效
					end
				end
				
				return {ShowAnim = true, Discharge = false}
			end
			
		end
	end	
	
	return {ShowAnim = false, Discharge = false}
end
DanishGambit:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', DanishGambit.ID)


return DanishGambit