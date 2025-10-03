--已定义

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID

local game = Game()
local sfx = SFXManager()

local BEden = mod.IBS_Player.BEden
local Defined = mod.IBS_Class.Item(mod.IBS_ItemID.Defined)

--清理房间充能
function Defined:Charge()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		for slot = 0,2 do
			if player:GetActiveItem(slot) == self.ID then
				local charges = self._Players:GetSlotCharges(player, slot, true, true)
				local chargeTimes = (self._Levels:IsInBigRoom() and 2) or 1
				local maxCharges = 12
				
				--昧化伊甸备用电池技能
				if player:GetPlayerType() == BEden.ID and BEden:GetData(player).battery > 0 then
					maxCharges = 24
				end
	
				for i = 1,chargeTimes do
					if charges < maxCharges then
						self._Players:ChargeSlot(player, slot, 1, true, true, true)

						--音效
						charges = charges + 1
						if charges == 12 or charges == 24 then
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
Defined:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'Charge')
Defined:AddCallback(IBS_CallbackID.GREED_NEW_WAVE, 'Charge') --贪婪模式波次充能

--目的地
Defined.Destination = {
	{Type = RoomType.ROOM_DEFAULT, Charge = 0, Lv = 0, AnimFrame = 1},
	{Type = RoomType.ROOM_BOSS, Charge = 4, Lv = 1, AnimFrame = 2},
	{Idx = GridRooms.ROOM_EXTRA_BOSS_IDX, Charge = 6, Lv = 3, AnimFrame = 3},
	{Type = RoomType.ROOM_MINIBOSS, Charge = 0, Lv = 0, AnimFrame = 4},
	{Type = RoomType.ROOM_TREASURE, Charge = 3, Lv = 1, AnimFrame = 5},
	{Type = RoomType.ROOM_PLANETARIUM, Charge = 3, Lv = 1, AnimFrame = 6},
	{Idx = GridRooms.ROOM_DUNGEON_IDX, Charge = 5, Lv = 2, AnimFrame = 7},
	{Type = RoomType.ROOM_LIBRARY, Charge = 3, Lv = 1, AnimFrame = 8},
	{Type = RoomType.ROOM_SHOP, Charge = 2, Lv = 1, AnimFrame = 9},
	{Idx = GridRooms.ROOM_BLACK_MARKET_IDX, Charge = 6, Lv = 3, AnimFrame = 10},
	{Idx = GridRooms.ROOM_SECRET_SHOP_IDX, Charge = 5, Lv = 3, AnimFrame = 11},
	{Type = RoomType.ROOM_CURSE, Charge = 2, Lv = 1, AnimFrame = 12},
	{Type = RoomType.ROOM_SACRIFICE, Charge = 0, Lv = 0, AnimFrame = 13},
	{Type = RoomType.ROOM_ARCADE, Charge = 0, Lv = 0, AnimFrame = 14},
	{Type = RoomType.ROOM_CHEST, Charge = 4, Lv = 1, AnimFrame = 15},
	{Type = RoomType.ROOM_DICE, Charge = 3, Lv = 1, AnimFrame = 16},
	{Type = RoomType.ROOM_ISAACS, Charge = 4, Lv = 1, AnimFrame = 17},
	{Type = RoomType.ROOM_BARREN, Charge = 3, Lv = 1, AnimFrame = 18},
	{Type = RoomType.ROOM_CHALLENGE, Charge = 3, Lv = 2, AnimFrame = 19},
	{Type = RoomType.ROOM_SECRET, Charge = 2, Lv = 2, AnimFrame = 20},
	{Type = RoomType.ROOM_SUPERSECRET, Charge = 4, Lv = 2, AnimFrame = 21},
	{Type = RoomType.ROOM_ULTRASECRET, Charge = 9, Lv = 4, AnimFrame = 22},
	{Type = RoomType.ROOM_DEVIL, Charge = 12, Lv = 4, AnimFrame = 23},
	{Type = RoomType.ROOM_GREED_EXIT, Charge = 0, Lv = 0, AnimFrame = 24},
}

--贪婪目的地
Defined.GreedDestination = {
	{Type = RoomType.ROOM_DEFAULT, Charge = 0, Lv = 0, AnimFrame = 1},
	{Type = RoomType.ROOM_BOSS, Charge = 0, Lv = 0, AnimFrame = 2},
	{Type = RoomType.ROOM_MINIBOSS, Charge = 0, Lv = 0, AnimFrame = 4},
	{Type = RoomType.ROOM_TREASURE, Charge = 2, Lv = 1, AnimFrame = 5},
	{Type = RoomType.ROOM_PLANETARIUM, Charge = 2, Lv = 1, AnimFrame = 6},
	{Idx = GridRooms.ROOM_DUNGEON_IDX, Charge = 5, Lv = 2, AnimFrame = 7},
	{Type = RoomType.ROOM_LIBRARY, Charge = 2, Lv = 1, AnimFrame = 8},
	{Type = RoomType.ROOM_SHOP, Charge = 0, Lv = 1, AnimFrame = 9},
	{Idx = GridRooms.ROOM_BLACK_MARKET_IDX, Charge = 6, Lv = 3, AnimFrame = 10},
	{Idx = GridRooms.ROOM_SECRET_SHOP_IDX, Charge = 5, Lv = 3, AnimFrame = 11},
	{Type = RoomType.ROOM_CURSE, Charge = 2, Lv = 1, AnimFrame = 12},
	{Type = RoomType.ROOM_SACRIFICE, Charge = 0, Lv = 0, AnimFrame = 13},
	{Type = RoomType.ROOM_ARCADE, Charge = 0, Lv = 1, AnimFrame = 14},
	{Type = RoomType.ROOM_CHEST, Charge = 3, Lv = 1, AnimFrame = 15},
	{Type = RoomType.ROOM_DICE, Charge = 3, Lv = 1, AnimFrame = 16},
	{Type = RoomType.ROOM_ISAACS, Charge = 3, Lv = 1, AnimFrame = 17},
	{Type = RoomType.ROOM_BARREN, Charge = 2, Lv = 1, AnimFrame = 18},
	{Type = RoomType.ROOM_CHALLENGE, Charge = 3, Lv = 2, AnimFrame = 19},
	{Type = RoomType.ROOM_SECRET, Charge = 2, Lv = 2, AnimFrame = 20},
	{Type = RoomType.ROOM_SUPERSECRET, Charge = 3, Lv = 2, AnimFrame = 21},
	{Type = RoomType.ROOM_ULTRASECRET, Charge = 6, Lv = 2, AnimFrame = 22},
	{Type = RoomType.ROOM_DEVIL, Charge = 4, Lv = 2, AnimFrame = 23},
	{Type = RoomType.ROOM_GREED_EXIT, Charge = 2, Lv = 1, AnimFrame = 24},
}

--获取数据
function Defined:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.DEFINED = data.DEFINED or {
		Selection = 1,
		Page = 1,
		Wait = 0,
		List = {}
	}
	return data.DEFINED
end

--获取记录
function Defined:GetRecord()
	local data = self:GetIBSData('level')
	data.DEFINED = data.DEFINED or {
		RoomType = {},
		RoomIdx = {},
	}
	return data.DEFINED
end

--记录本层已用功能
function Defined:Record(roomType, idx)
	local data = self:GetRecord()
	
	if type(roomType) == 'number' then
		data.RoomType[tostring(roomType)] = true
	end
	if type(idx) == 'number' then
		data.RoomIdx[tostring(idx)] = true
	end
end

--是否已记录
function Defined:IsRecorded(roomType, idx)
	local data = self:GetIBSData('level').DEFINED
	
	if data then
		if type(roomType) == 'number' and data.RoomType[tostring(roomType)] then
			return true
		end
		if type(idx) == 'number' and data.RoomIdx[tostring(idx)] then
			return true
		end
	end
	
	return false
end

--获取目的地贴图
local function GetDestinationSprite(frame)
	local spr = Sprite('gfx/ibs/ui/items/defined.anm2')
	spr:SetFrame('Idle', frame)
	spr.Scale = Vector(0.5,0.5)
	return spr
end

--计算修改后的充能消耗
function Defined:GetModifieredDischarge(player, discharge, roomType, roomIdx)
	discharge = discharge or 0
	
	--已有记录则为0
	if self:IsRecorded(roomType, roomIdx) then
		return 0
	end

	if player:HasCollectible(584) then discharge = discharge - 1 end --美德书
	if player:HasCollectible(59) then discharge = discharge - 1 end --彼列书
	if player:HasCollectible(116) then discharge = discharge - 1 end --9伏特

	--昧化伊甸九伏增压技能
	if player:GetPlayerType() == BEden.ID and BEden:GetData(player).volt9 > 0  then
		discharge = discharge - 1
	end
	
	return math.max(0, discharge)
end

--刷新目的地列表
function Defined:RefreshDestinations(player)
	local data = self:GetData(player)
	local isBEden = (player:GetPlayerType() == BEden.ID) --昧化伊甸
	local level = game:GetLevel()
	local destinations = (game:IsGreedMode() and self.GreedDestination) or self.Destination

	for k,_ in pairs(data.List) do
		data.List[k] = nil
	end

	local page = 1

	--非主世界或镜世界只能用愚者
	local dimension = game:GetLevel():GetDimension()
	if dimension ~= Dimension.NORMAL and dimension ~= Dimension.MIRROR then
		local idx = level:GetStartingRoomIndex()
		if idx then
			data.List[page] = data.List[page] or {}
			table.insert(data.List[page], {Sprite = GetDestinationSprite(1), Idx = idx, Charge = 0})
		end
	else
		for _,tbl in ipairs(destinations) do
			local stage = level:GetStage()
		
			--检查昧化伊甸等级
			if (not isBEden) or BEden:GetData(player).definition_up >= tbl.Lv then
				local idx = tbl.Idx

				if idx == nil and tbl.Type then
					if (tbl.Type == RoomType.ROOM_DEFAULT) then
						idx = level:GetStartingRoomIndex() --初始房间
					else
						idx = level:QueryRoomTypeIndex(tbl.Type, false, player:GetCollectibleRNG(self.ID), true)
						
						--检查房间类型是否符合(排除恶魔房重定向为天使房的情况)
						local roomData = level:GetRoomByIdx(idx).Data
						if roomData and roomData.Type ~= tbl.Type and not (tbl.Type == RoomType.ROOM_DEVIL and roomData.Type == RoomType.ROOM_ANGEL) then
							idx = nil
						end
					end
				end

				--倒皇帝9层后无效
				if idx == GridRooms.ROOM_EXTRA_BOSS_IDX and stage > 9 then
					idx = nil
				end

				--13层没有高级商店
				if idx == GridRooms.ROOM_SECRET_SHOP_IDX and stage == 13 then
					idx = nil
				end

				if idx then
					data.List[page] = data.List[page] or {}
					table.insert(data.List[page], {Sprite = GetDestinationSprite(tbl.AnimFrame), Type = tbl.Type, Idx = idx, Charge = tbl.Charge})
					if #data.List[page] >= 10 then --一页最多展示10个
						page = page + 1
					end
				end
			end
		end
	end

	
	--第一页始终存在
	data.List[1] = data.List[1] or {}
	
	--为最后一页补齐空位
	if data.List[page] and #data.List[page] < 10 then
		for i = 1, 10 - #data.List[page] do
			local spr = Sprite('gfx/ibs/ui/selection.anm2')
			spr:SetFrame("Idle", 1)
			table.insert(data.List[page], {Sprite = spr})
		end
	end
end

--尝试使用
function Defined:OnTryUse(slot, player)
	return 0
end
Defined:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MIN_USABLE_CHARGE, 'OnTryUse', Defined.ID)

--使用
function Defined:OnUse(item, rng, player, flag, slot)
	if (flag & UseFlag.USE_OWNED > 0) and (flag & UseFlag.USE_CARBATTERY <= 0) and (flag & UseFlag.USE_VOID <= 0) then
		local level = game:GetLevel()
		
		--防止与昧化伊甸面板冲突
		if slot == 2 and BEden:CanOpenConsole(player) then
			--啥也不做
		else
			local data = self:GetData(player)
			
			--正在握住则传送,否则尝试握住
			if self._Players:IsHoldingItem(player, self.ID) and data.Wait <= 0 then
				local destination = data.List[data.Page] and data.List[data.Page][data.Selection]
				
				if destination.Idx and self._Players:DischargeSlot(player, slot, self:GetModifieredDischarge(player, destination.Charge, destination.Type, destination.Idx), true, false, true, true) then
					self:Record(destination.Type, destination.Idx) --记录

					--立刻结束握住
					self._Players:EndHoldItem(player, true)

					--尝试恢复上限骰(东方mod)
					if not mod.IBS_Compat.THI:TryRestoreDice(player, self.ID, slot) then
						--正邪削弱(东方mod)
						--概率变为未定义
						if (slot == 0 or slot == 1) and mod.IBS_Compat.THI:SeijaNerf(player) then	
							if rng:RandomInt(5) == 0 then
								player:RemoveCollectible(self.ID, true, slot)
								player:AddCollectible(324, 6, false, slot)
							end
						end
					end
					
					--未知原因,倒皇帝额外boss房只能触发卡牌进入
					if destination.Idx == GridRooms.ROOM_EXTRA_BOSS_IDX then
						player:UseCard(60, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
					else
						--只会传送至主世界或镜世界
						game:StartRoomTransition(destination.Idx, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player, (game:GetLevel():GetDimension() == Dimension.MIRROR and -1) or 0)
					end
				end
			else
				self._Players:TryHoldItem(self.ID, player, flag, slot)
			end
		end

		return {ShowAnim = false, Discharge = false}
	end	
end
Defined:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', Defined.ID)

--尝试握住
function Defined:OnTryHoldItem(item, player, flag, slot, holdingItem)
	if holdingItem <= 0 and (slot ~= 2 or not BEden:CanOpenConsole(player)) then --防止与昧化伊甸面板冲突
		local canHold = true

		if (flag & UseFlag.USE_OWNED <= 0) or (flag & UseFlag.USE_CARBATTERY > 0) or (flag & UseFlag.USE_VOID > 0) then
			canHold = false
		end

		--刷新
		if canHold then
			self:RefreshDestinations(player)
			local data = self:GetData(player)
			data.Wait = 10
			data.Page = math.min(data.Page, #data.List)
		end

		return {CanHold = canHold, NoHideAnim = true}
	end
end
Defined:AddCallback(IBS_CallbackID.TRY_HOLD_ITEM, 'OnTryHoldItem', Defined.ID)

--正在握住
function Defined:OnHoldingItem(item, player, flag, slot)
	if game:IsPaused() then return end
	if slot == 2 and BEden:CanOpenConsole(player) then return end --防止与昧化伊甸面板冲突
	local cid = player.ControllerIndex

	--按丢弃键结束握住
	if Input.IsActionTriggered(ButtonAction.ACTION_DROP, cid) then
		player:PlayExtraAnimation("HideItem")
		return false
	end
	
	local data = self:GetData(player)
	local UP = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, cid)
	local DOWN = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, cid)
	local LEFT = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, cid)
	local RIGHT = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, cid)

	--左右切换
	if LEFT then
		if data.Selection > 1 then
			data.Selection = data.Selection - 1
		else
			data.Selection = 10
		end
	end
	if RIGHT then
		if data.Selection < 10 then
			data.Selection = data.Selection + 1
		else
			data.Selection = 1
		end
	end
	
	--上下切换
	local MAX = #data.List
	if UP then
		if data.Selection > 5 then
			data.Selection = data.Selection - 5
		else
			if data.Page > 1 then
				data.Page = data.Page - 1
				data.Selection = data.Selection + 5
			end
		end
	end
	if DOWN then
		if data.Selection <= 5 then
			data.Selection = data.Selection + 5
		else	
			if data.Page < MAX then
				data.Page = data.Page + 1
				data.Selection = data.Selection - 5
			end	
		end
	end
end
Defined:AddCallback(IBS_CallbackID.HOLDING_ITEM, 'OnHoldingItem', Defined.ID)

--切换房间时记录
function Defined:OnNewRoom()
	local level = game:GetLevel()
	local roomDesc = level:GetCurrentRoomDesc()
	local roomData = roomDesc.Data
	if roomData.Type ~= Room.ROOM_DEFAULT then
		self:Record(roomData.Type, roomDesc.SafeGridIndex)
	end
end
Defined:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

local fnt = Font('font/pftempestasevencondensed.fnt')

local selectionSpr = Sprite('gfx/ibs/ui/selection.anm2')
selectionSpr:Play("Idle")

local batterySpr = Sprite('gfx/ibs/ui/battery.anm2')
batterySpr.Scale = Vector(0.5,0.5)
batterySpr:SetFrame("Idle", 1)

--渲染
function Defined:OnHUDRender()
	if not game:GetHUD():IsVisible() then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local isHolding,slot = self._Players:IsHoldingItem(player, self.ID)
		
		if isHolding and (slot ~= 2 or not BEden:CanOpenConsole(player)) then --防止与昧化伊甸面板冲突
			local data = self:GetData(player)

			if data.Wait > 0 then
				data.Wait = data.Wait - 1
			end
			
			local pos = self._Screens:WorldToScreen(player.Position, Vector(0,-80), true)
			
			local X,Y = pos.X - 32, pos.Y
			local column = 1
			local tbl = data.List[data.Page]
			if tbl then
				for _,v in ipairs(tbl) do
					v.Sprite:Render(Vector(X,Y))
					X = X + 16
					column = column + 1
					
					--换行
					if column > 5 then
						column = 1
						X = pos.X - 32
						Y = Y + 16
					end
				end
			end
			
			--显示选择框
			local offsetX = ((data.Selection > 5 and (data.Selection - 5) * 16) or data.Selection * 16) - 48
			local offsetY = (data.Selection > 5 and 16) or 0
			selectionSpr:Render(Vector(pos.X + offsetX, pos.Y + offsetY))

			--显示页码
			fnt:DrawStringScaled(tostring(data.Page)..'/'..tostring(#data.List), pos.X - 16, pos.Y + 20, 1, 1, KColor(1,1,1,1), 32, true)
			
			--显示充能消耗
			local destination = data.List[data.Page] and data.List[data.Page][data.Selection]
			if destination and destination.Charge then
				local discharge = self:GetModifieredDischarge(player, destination.Charge, destination.Type, destination.Idx)
				local color = KColor(1,1,1,1)
			
				--不消耗充能时变为绿色
				if discharge <= 0 then
					color = KColor(0,1,0,1)
				elseif self._Players:GetSlotCharges(player, slot, true, true) < discharge then
					--充能不足变为红色
					color = KColor(1,0,0,1)
				end
			
				batterySpr:Render(Vector(pos.X - 8, pos.Y - 14))
				fnt:DrawStringScaled(discharge, pos.X, pos.Y - 21, 1, 1, color)
			end
		end
	end
end
Defined:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, 'OnHUDRender')




return Defined