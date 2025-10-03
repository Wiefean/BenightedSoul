--增殖

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Multiply = mod.IBS_Class.Item(mod.IBS_ItemID.Multiply)

--尝试使用
function Multiply:OnTryUse(slot, player)
	return 0
end
Multiply:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MIN_USABLE_CHARGE, 'OnTryUse', Multiply.ID)


--使用
function Multiply:OnUse(item, rng, player, flags, slot)
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

	local itemPool = game:GetItemPool()
	local num = 0

	--移除所有非boss敌人并生成黑暗球
	for _,ent in ipairs(Isaac.GetRoomEntities()) do
		if self._Ents:IsEnemy(ent, true, false, true) then
			local ball = Isaac.Spawn(404, 1, 0, ent.Position, Vector.Zero, player)
			ball:AddCharmed(EntityRef(player), -1)
			ent:Remove()
			num = num + 1
		end
	end

	--美德书
	if player:HasCollectible(584) then
		for i = 1,4 do
			player:AddWisp(self.ID, player.Position)
		end
	end	

	--彼列书
	if player:HasCollectible(59) and num < 6 then
		for i = 1,6-num do
			local ball = Isaac.Spawn(404, 1, 0, player.Position, Vector.Zero, player)
			ball:AddCharmed(EntityRef(player), -1)			
		end
	end

	return {ShowAnim = true, Discharge = false}
end
Multiply:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', Multiply.ID)

--敌人被黑暗球伤害时记录
function Multiply:OnTakeDamage(ent, dmg, flag, source)
	if dmg <= 0 then return end
	if not self._Ents:IsEnemy(ent, true) then return end
	if source.Type == 404 and source.Variant == 1 then
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) or player:VoidHasCollectible(self.ID) then			
				self._Ents:GetTempData(ent).MultiplyRecord = true
				break
			end
		end
	end	
end
Multiply:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, 'OnTakeDamage')

function Multiply:OnEntityKilled(ent)	
	--杀敌生成黑暗球
	if self._Ents:GetTempData(ent).MultiplyRecord then
		local num = 0
		
		--计数
		for _,_ball in ipairs(Isaac.FindByType(404, 1, 0)) do
			if _ball:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
				num = num + 1
			end
		end
	
		if num < 13 then
			local ball = Isaac.Spawn(404, 1, 0, ent.Position, Vector.Zero, player)
			ball:AddCharmed(EntityRef(player), -1)		
		end
	end
	
	--魂火熄灭
    if ent.Type == 3 and ent.Variant == 206 and ent.SubType == self.ID then
		local ball = Isaac.Spawn(404, 1, 0, ent.Position, Vector.Zero, player)
		ball:AddCharmed(EntityRef(player), -1)		
    end	
end
Multiply:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnEntityKilled')

--清理boss房
function Multiply:OnRoomCleaned()
	local room = game:GetRoom()
	if room:GetType() == RoomType.ROOM_BOSS then
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			for slot = 0,2 do
				if player:GetActiveItem(slot) == self.ID then
					local charges = self._Players:GetSlotCharges(player, slot, true, true)
					if charges < 3 then
						self._Players:ChargeSlot(player, slot, 1, true, true, true)

						--音效
						charges = charges + 1
						if charges == 7 or charges == 14 then
							sfx:Play(SoundEffect.SOUND_BATTERYCHARGE)		
						else
							sfx:Play(SoundEffect.SOUND_BEEP)
						end
					end
				end
			end
		end	
	end
end
Multiply:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')

--boss波次
function Multiply:OnWaveEndState(state)
	if state == 2 then
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasTrinket(self.ID) then
				self:OnRoomCleaned(player)
			end
		end
	end
end
Multiply:AddCallback(mod.IBS_CallbackID.GREED_WAVE_END_STATE, 'OnWaveEndState')


return Multiply