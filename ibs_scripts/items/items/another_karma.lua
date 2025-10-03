--异业

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID
local IBS_PlayerID = mod.IBS_PlayerID

local game = Game()
local config = Isaac.GetItemConfig()

local AnotherKarma = mod.IBS_Class.Item(mod.IBS_ItemID.AnotherKarma)

--临时数据
function AnotherKarma:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.AnotherKarma = data.AnotherKarma or {
		Selection = 1,
		Page = 1,
		Wait = 0,
		List = {}
	}
	return data.AnotherKarma
end

--获取饰品贴图
local function GetTrinketSprite(id)
	local spr = Sprite('gfx/ibs/ui/items/another_karma.anm2')
	local gfx = ''
	local itemConfig = config:GetTrinket(id)

	if itemConfig then   
		gfx = itemConfig.GfxFileName
	end

	if gfx == '' or not gfx then
		gfx = 'gfx/items/collectibles/placeholder.png'
	elseif id > 32768 then --金饰品特效
		spr:SetRenderFlags(AnimRenderFlags.GOLDEN)
	end

	spr:ReplaceSpritesheet(0, gfx, true)
	spr:Play('Idle')
	spr.Scale = Vector(0.5,0.5)

	return spr
end

--刷新饰品列表
function AnotherKarma:RefreshList(player)
	if player:GetPlayerType() ~= IBS_PlayerID.BKeeper then return end
	local data = self:GetData(player)

	for k,_ in pairs(data.List) do
		data.List[k] = nil
	end

	local page = 1

	for id,tbl in ipairs(player:GetSmeltedTrinkets()) do
		if self._Pools:IsPennyTrinket(id) then
			if tbl.trinketAmount > 0 then
				local itemConfig = config:GetTrinket(id)
				if itemConfig then
					data.List[page] = data.List[page] or {}
					table.insert(data.List[page], {Sprite = GetTrinketSprite(id), ID = id})
					if #data.List[page] >= 5 then --一页最多展示5个
						page = page + 1
					end
				end
			end
			if tbl.goldenTrinketAmount > 0 then --金饰品
				local goldenID = id + 32768
				local itemConfig = config:GetTrinket(goldenID)
				if itemConfig then
					data.List[page] = data.List[page] or {}
					table.insert(data.List[page], {Sprite = GetTrinketSprite(goldenID), ID = goldenID})
					if #data.List[page] >= 5 then --一页最多展示5个
						page = page + 1
					end
				end			
			end
		end
	end
	
	--第一页始终存在
	data.List[1] = data.List[1] or {}
	
	--为最后一页补齐空位
	if data.List[page] and #data.List[page] < 5 then
		for i = 1, 5 - #data.List[page] do
			local spr = Sprite('gfx/ibs/ui/selection.anm2')
			spr:SetFrame("Idle", 1)
			table.insert(data.List[page], {Sprite = spr, ID = 0})
		end
	end
end

--尝试移除选中的饰品
function AnotherKarma:TryRemoveSelected(player)
	local data = self:GetData(player)
	local trinket = data.List[data.Page] and data.List[data.Page][data.Selection]
	
	if trinket and trinket.ID > 0 and player:HasTrinket(trinket.ID) then
		player:TryRemoveSmeltedTrinket(trinket.ID)
		return true,trinket.ID
	end
	
	return false,0
end

--生成奖励
function AnotherKarma:SpawnBonus(player, pos, rng)
	local room = game:GetRoom()

	--慷慨模式挑战
	if Isaac.GetChallenge() ~= mod.IBS_ChallengeID[13] then
		--生成乞丐
		if #Isaac.FindByType(6) < 7 then
			local id = (player:HasCollectible(59) and 5) or self._Pools:GetRandomBeggar(rng, {
				[4] = 7, --提高普通乞丐权重
			})
			Isaac.Spawn(6, id, 0, room:FindFreePickupSpawnPosition(pos + Vector(0,-40), 0, true), Vector.Zero, nil)
		end
	end

	--生成硬币
	for i = 1,rng:RandomInt(3,5) do
		Isaac.Spawn(5, 20, 0, room:FindFreePickupSpawnPosition(pos + Vector(0,40), 0, true), RandomVector(), nil)
	end
	
	--生成硬币饰品
	if rng:RandomInt(100) < 50 then
		local id = self._Pools:GetRandomPennyTrinket(rng)
		Isaac.Spawn(5, 350, id, room:FindFreePickupSpawnPosition(pos + Vector(0,40), 0, true), RandomVector(), nil)
	end	
end

--美德书兼容
function AnotherKarma:CheckVirtuesBook(player, flags)
	if player:HasCollectible(584) and (flags & UseFlag.USE_NOANIM <= 0 or flags & UseFlag.USE_ALLOWWISPSPAWN > 0) then
		player:AddWisp(349, player.Position)
		player:AddWisp(349, player.Position)
		player:AddWisp(349, player.Position)
	end
end

--使用
function AnotherKarma:OnUse(item, rng, player, flags, slot)
	if (flags & UseFlag.USE_CARBATTERY <= 0) and (flags & UseFlag.USE_VOID <= 0) then --拒绝车载电池和虚空
	
		--正在握住时直接跳过
		if self._Players:IsHoldingItem(player, self.ID) then
			return {ShowAnim = false, Discharge = false}
		end
	
		--检测正在拾取的道具
		if not player:IsItemQueueEmpty() then
			local queued = player.QueuedItem.Item

			--非饰品
			if (queued.Type ~= ItemType.ITEM_TRINKET) then
				local ID = queued.ID
				local itemConfig = config:GetCollectible(ID)
				
				--非便条
				if ID ~= 0 and ID ~= 668 and itemConfig then
					local pos = player.Position
					self:SpawnBonus(player, pos, rng)
					
					--烟雾
					Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil)
					
					--移除道具
					player:FlushQueueItem()
					player:RemoveCollectible(ID, true)

					self:CheckVirtuesBook(player, flags)
			
					return true
				end	
			end
		end	
	
		--距离最近的道具
		local ent = self._Finds:ClosestCollectible(player.Position)
		if ent and ent.SubType ~= 0 and ent:ToPickup() and (ent:ToPickup().Price >= 0 or ent:ToPickup().Price == -1000) then
			local pickup = ent:ToPickup()		
			local pos = pickup.Position
			self:SpawnBonus(player, pos, rng)

			
			--移除组中掉落物
			local idx = pickup.OptionsPickupIndex
			if idx ~= 0 then
				for _,p in pairs(self._Pickups:GetPickupsByOptionsIndex(idx)) do
					p:Remove()
					Isaac.Spawn(1000, 15, 0, p.Position, Vector.Zero, nil)
				end			
			else
				pickup:Remove()
				Isaac.Spawn(1000, 15, 0, pickup.Position, Vector.Zero, nil)
			end
			
			self:CheckVirtuesBook(player, flags)
			
			return true
		end	

		--表表店兼容
		if player:GetPlayerType() == IBS_PlayerID.BKeeper then
			if (flags & UseFlag.USE_OWNED > 0) and slot == 2 then
				self._Players:TryHoldItem(self.ID, player, flags, slot)
			end
		end

		return {ShowAnim = false, Discharge = false}
	end	
end
AnotherKarma:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', AnotherKarma.ID)

--尝试握住
function AnotherKarma:OnTryHoldItem(item, player, flag, slot, holdingItem)
	if holdingItem <= 0 and player:GetPlayerType() == IBS_PlayerID.BKeeper then
		local canHold = true

		if (flag & UseFlag.USE_OWNED <= 0) or (flag & UseFlag.USE_CARBATTERY > 0) or (flag & UseFlag.USE_VOID > 0) then
			canHold = false
		end

		--刷新
		if canHold then
			self:RefreshList(player)
			local data = self:GetData(player)
			data.Wait = 10
			data.Page = math.min(data.Page, #data.List)
		end

		return {CanHold = canHold}
	end
	return {CanHold = false}
end
AnotherKarma:AddCallback(IBS_CallbackID.TRY_HOLD_ITEM, 'OnTryHoldItem', AnotherKarma.ID)

--正在握住
function AnotherKarma:OnHoldingItem(item, player, flag, slot)
	if game:IsPaused() then return end
	if player:GetPlayerType() ~= IBS_PlayerID.BKeeper then return false end
	local cid = player.ControllerIndex

	--按丢弃键结束握住
	if Input.IsActionTriggered(ButtonAction.ACTION_DROP, cid) then
		return false
	end
	
	local data = self:GetData(player)
	local UP = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, cid)
	local DOWN = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, cid)
	local LEFT = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, cid)
	local RIGHT = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, cid)

	--切换饰品
	if LEFT then
		if data.Selection > 1 then
			data.Selection = data.Selection - 1
		else
			data.Selection = 5
		end
	end
	if RIGHT then
		if data.Selection < 5 then
			data.Selection = data.Selection + 1
		else
			data.Selection = 1
		end
	end
	
	--切换页码
	local MAX = #data.List
	if UP then
		if data.Page > 1 then
			data.Page = data.Page - 1
		else
			data.Page = MAX
		end
	end
	if DOWN then
		if data.Page < MAX then
			data.Page = data.Page + 1
		else
			data.Page = 1
		end	
	end
end
AnotherKarma:AddCallback(IBS_CallbackID.HOLDING_ITEM, 'OnHoldingItem', AnotherKarma.ID)



local fnt = Font('font/pftempestasevencondensed.fnt')

local selectionSpr = Sprite('gfx/ibs/ui/selection.anm2')
selectionSpr:Play("Idle")

--渲染
function AnotherKarma:OnHUDRender()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == IBS_PlayerID.BKeeper and self._Players:IsHoldingItem(player, self.ID) then
			local data = self:GetData(player)
			
			--按口袋物品键操作
			if data.Wait <= 0 and not game:IsPaused() and Input.IsActionTriggered(ButtonAction.ACTION_PILLCARD, player.ControllerIndex) then
				local removed,id = self:TryRemoveSelected(player)
				if removed then
					for i = 1, (id > 32768 and 2) or 1 do
						self:SpawnBonus(player, player.Position, player:GetCollectibleRNG(self.ID))
						self:CheckVirtuesBook(player, 0)
					end
					self._Players:EndHoldItem(player, true)
					player:DischargeActiveItem(2)
					
					--烟雾
					Isaac.Spawn(1000, 15, 0, player.Position, Vector.Zero, nil)					
				end
			end
			if data.Wait > 0 then
				data.Wait = data.Wait - 1
			end
			
			local pos = self._Screens:WorldToScreen(player.Position, Vector(0,-64), true)
			
			--显示饰品
			local X,Y = pos.X - 32, pos.Y
			local tbl = data.List[data.Page]
			if tbl then
				for _,trinket in ipairs(tbl) do
					trinket.Sprite:Render(Vector(X,Y))
					X = X + 16
				end
			end
			
			--显示选择框
			selectionSpr:Render(Vector(pos.X + data.Selection * 16 - 48, pos.Y))

			--显示页码
			fnt:DrawStringScaled(tostring(data.Page)..'/'..tostring(#data.List), pos.X - 16, pos.Y + 15, 1, 1, KColor(1,1,1,1), 32, true)
		end
	end
end
AnotherKarma:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, 'OnHUDRender')

return AnotherKarma