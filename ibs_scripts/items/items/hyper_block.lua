--超能格挡

local mod = Isaac_BenightedSoul
local IBS_PocketID = mod.IBS_PocketID
local Damage = mod.IBS_Class.Damage()

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local HyperBlock = mod.IBS_Class.Item(mod.IBS_ItemID.HyperBlock)

--主要效果
function HyperBlock:MainEffect(player)
	local rng = player:GetCollectibleRNG(self.ID)
	
	--3秒护盾
	self._Players:AddShield(player, 90)
	
	--获得伪忆或魂石
	if rng:RandomInt(100) < 50 then
		player:AddCard(rng:RandomInt(81,97))
	else
		player:AddCard(rng:RandomInt(IBS_PocketID.BIsaac, IBS_PocketID.BJBE))
	end
end

--检测剩余次数
function HyperBlock:TryRemove(player, slot)
	if slot < 0 or slot > 2 then return end
	local varData = player:GetActiveItemDesc(slot).VarData
	player:SetActiveVarData(varData+1, slot)
	if varData+1 >= 3 then
		player:RemoveCollectible(self.ID, true, slot, false)
	end
end

--使用
function HyperBlock:OnUse(item, rng, player, flags, slot)
	if flags & UseFlag.USE_CARBATTERY <= 0 then --车载电池
		self:MainEffect(player)
		
		--手动车载电池兼容
		if player:HasCollectible(356) then
			self:MainEffect(player)
		end

		--拥有且非虚空触发
		if flags & UseFlag.USE_OWNED > 0 and flags & UseFlag.USE_VOID <= 0 then
			self:TryRemove(player, slot)
		end
		
		sfx:Play(33, 1, 2, false, 4)
		Isaac.Spawn(1000, 16, 2, player.Position, Vector.Zero, nil)	
		
		return {ShowAnim = false, Discharge = true}
	end
end
HyperBlock:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', HyperBlock.ID)

--是否应该保护
function HyperBlock:ShouldProtect(player, flag, source)
	return Damage:CanHurtPlayer(player, flag, source) and not Damage:IsPlayerSelfDamage(player, flag, source)
end

--在即将受伤时生效
function HyperBlock:PrePlayerTakeDMG(player, dmg, flag, source)
	if dmg <= 0 then return end
	if not Damage:CanHurtPlayer(player, flag, source) then return end --可伤害角色
	
	--充能
	for slot = 0,2 do
		if player:GetActiveItem(slot) == (self.ID) then
			local charge = player:GetCollectibleRNG(self.ID):RandomInt(1,3)
			
			--美德书
			if player:HasCollectible(584) then
				charge = charge + 1
			end
			
			self._Players:ChargeSlot(player, slot, charge, true, false, true, true)
		end
	end

	--惩罚性伤害
	if not Damage:IsPenalt(player, flag, source) then return end
	
	for slot = 0,2 do
		if player:GetActiveItem(slot) == (self.ID) then
			local discharge = 8
			if player:HasCollectible(116) then discharge = discharge - 1 end --9伏特

			--成功消耗充能才触发效果
			if self._Players:DischargeSlot(player, slot, discharge, true, false, true, true) then
				self:MainEffect(player)
				self:TryRemove(player, slot)
				
				--车载电池兼容
				if player:HasCollectible(356) then
					self:MainEffect(player)
				end
				
				--比列书兼容
				if player:HasCollectible(59) then
					player:UseActiveItem(34, false, false)
					player:UseActiveItem(34, false, false)
				end

				--尝试恢复上限骰(东方mod)
				if slot ~= 2 then
					mod.IBS_Compat.THI:TryRestoreDice(player, HyperBlock.ID, slot)
				end

				sfx:Play(33, 1, 2, false, 4)
				Isaac.Spawn(1000, 16, 2, player.Position, Vector.Zero, nil)		
				
				return false
			end
		end
	end	
end
HyperBlock:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, 'PrePlayerTakeDMG')

--清理boss房恢复1次数
function HyperBlock:OnRoomCleaned()
	local room = game:GetRoom()
	local roomType = room:GetType()
	if roomType == RoomType.ROOM_BOSS or roomType == RoomType.ROOM_BOSSRUSH then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			for slot = 0,2 do
				if player:GetActiveItem(slot) == (self.ID) then
					local varData = player:GetActiveItemDesc(slot).VarData
					player:SetActiveVarData(math.max(0, varData-1), slot)				
				end
			end
		end
	end
end
HyperBlock:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')

--显示剩余次数
local fnt = Font()
fnt:Load("font/pftempestasevencondensed.fnt")
function HyperBlock:OnActiveRender(player, slot, offset, alpha, scale)
	if player:GetActiveItem(slot) ~= self.ID then return end
	local varData = player:GetActiveItemDesc(slot).VarData

	local stringNum = tostring(math.max(0, 3-varData))
	local color = KColor(1,1,1,1)

	--红色提醒快炸了
	if varData >= 2 then
		color = KColor(1,0,0,1)
	end
	
	local pos = Vector(scale, scale) + offset
	stringNum = "x"..stringNum
	fnt:DrawStringScaled(stringNum, pos.X, pos.Y, scale * 0.75, scale * 0.75, color)
end
HyperBlock:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, 'OnActiveRender')


return HyperBlock