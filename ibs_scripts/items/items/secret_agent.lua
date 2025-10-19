--秘密特工

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID

local game = Game()
local config = Isaac.GetItemConfig()

local SecretAgent = mod.IBS_Class.Item(mod.IBS_ItemID.SecretAgent)

--获取数据
function SecretAgent:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.SecretAgent = data.SecretAgent or {
		Selection = 1,
		Page = 1,
		Wait = 0,
		List = {}
	}
	return data.SecretAgent
end

--获取道具贴图
local function GetItemSprite(id)
	local spr = Sprite('gfx/ibs/ui/items/any.anm2')
	local gfx = ''
	local itemConfig = config:GetCollectible(id)

	if itemConfig then   
		gfx = itemConfig.GfxFileName
	end

	if gfx == '' or not gfx then
		gfx = 'gfx/items/collectibles/placeholder.png'
	end

	spr:ReplaceSpritesheet(0, gfx, true)
	spr:Play('Idle')
	spr.Scale = Vector(0.5,0.5)

	return spr
end

--刷新列表
function SecretAgent:RefreshList(player)
	local data = self:GetData(player)
	local cache = {}
	
	for k,_ in pairs(data.List) do
		data.List[k] = nil
	end

	local page = 1

	local MAX = config:GetCollectibles().Size - 1
	for id = 1, MAX do
		local itemConfig = config:GetCollectible(id)
		
		if id ~= self.ID and itemConfig and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
			local has = false
			
			--排除副手主动
			if itemConfig.Type == ItemType.ITEM_ACTIVE then
				for slot = 0,1 do
					if player:GetActiveItem(slot) == id then
						has = true
					end
				end
			elseif player:HasCollectible(id, true) then
				has = true
			end

			if has then			
				table.insert(cache, {Sprite = GetItemSprite(id), ID = id})
			end
		end
	end	
	
	for _,tbl in ipairs(cache) do
		data.List[page] = data.List[page] or {}
		table.insert(data.List[page], tbl)
		if #data.List[page] >= 20 then --一页最多展示20个
			page = page + 1
		end
	end		
	
	--第一页始终存在
	data.List[1] = data.List[1] or {}
	
	--为最后一页补齐空位
	if data.List[page] and #data.List[page] < 20 then
		for i = 1, 20 - #data.List[page] do
			local spr = Sprite('gfx/ibs/ui/selection.anm2')
			spr:SetFrame("Idle", 1)
			table.insert(data.List[page], {Sprite = spr})
		end
	end
end

--计算充能消耗
function SecretAgent:GetDischarge(player)
	local discharge = 3
	if player:HasCollectible(116) then discharge = discharge - 1 end --9伏特
	if discharge < 0 then discharge = 0 end
	return discharge
end

--使用效果
function SecretAgent:OnUse(_, rng, player, flag, slot)
	if (slot >= 0 and slot <= 2) and (flag & UseFlag.USE_OWNED > 0) and (flag & UseFlag.USE_CARBATTERY <= 0) and (flag & UseFlag.USE_VOID <= 0) then
		local data = self:GetData(player)
		local discharge = self:GetDischarge(player)
		local varData = player:GetActiveItemDesc(slot).VarData

		if varData <= 0 then --无记录时
		
			--正在握住则触发效果,否则尝试握住
			if self._Players:IsHoldingItem(player, self.ID) and data.Wait <= 0 then
				local item = data.List[data.Page] and data.List[data.Page][data.Selection] and data.List[data.Page][data.Selection].ID
				local itemModified = false
				
				if not item or item <= 0 then				
					--美德书
					if player:HasCollectible(584) then
						item = 33
						itemModified = true
					end
					
					--彼列书
					if player:HasCollectible(59) then
						item = 51
						itemModified = true
					end				
				end
				
				if (item and item > 0) and self._Players:DischargeSlot(player, slot, discharge) then								
					local itemConfig = config:GetCollectible(item)

					--记录
					player:SetActiveVarData(item, slot)
						
					--主动道具需要额外检测,防止移除副手和套装效果
					if not itemModified then					
						if itemConfig.Type == ItemType.ITEM_ACTIVE then
							for _slot = 0,1 do
								if player:GetActiveItem(_slot) == item then
									player:RemoveCollectible(item, true, _slot, false)
								end
							end
						elseif player:HasCollectible(item, true) then
							player:RemoveCollectible(item, true)
						end
					end

					--尝试恢复上限骰(东方mod)
					mod.IBS_Compat.THI:TryRestoreDice(player, self.ID, slot)
					
					--结束握住
					self._Players:EndHoldItem(player, true)
				end
			else
				self._Players:TryHoldItem(self.ID, player, flag, slot)
			end
		else --有记录时
			if self._Players:DischargeSlot(player, slot, discharge) then	
				local pos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true)
				Isaac.Spawn(5, 100, varData, pos, Vector.Zero, player)
				player:SetActiveVarData(0, slot) --清除记录
				player:AnimateCollectible(self.ID, 'UseItem')
			end
		end
		
		return {ShowAnim = false, Discharge = false}
	end
end
SecretAgent:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', SecretAgent.ID)


--尝试握住
function SecretAgent:OnTryHoldItem(item, player, flag, slot, holdingItem)
	if holdingItem <= 0 then 
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
end
SecretAgent:AddCallback(IBS_CallbackID.TRY_HOLD_ITEM, 'OnTryHoldItem', SecretAgent.ID)

--正在握住
function SecretAgent:OnHoldingItem(item, player, flag, slot)
	if game:IsPaused() then return end
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

	local UP2 = Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, cid)
	local DOWN2 = Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, cid)
	local LEFT2 = Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, cid)
	local RIGHT2 = Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, cid)

	local UP3 = false
	local DOWN3 = false
	local LEFT3 = false
	local RIGHT3 = false

	--按住滚动检测
	if UP2 or DOWN2 or LEFT2 or RIGHT2 then
		if data.Wait2 < 15 then		
			data.Wait2 = data.Wait2 + 1
		else
			UP3 = UP2
			DOWN3 = DOWN2
			
			--左右切换要慢些
			if player:IsFrame(2,0) then
				LEFT3 = LEFT2
				RIGHT3 = RIGHT2
			end
		end
	else
		data.Wait2 = 0
	end

	--左右切换
	if LEFT or LEFT3 then
		if data.Selection > 1 then
			data.Selection = data.Selection - 1
		else
			data.Selection = 20
		end
	end
	if RIGHT or RIGHT3 then
		if data.Selection < 20 then
			data.Selection = data.Selection + 1
		else
			data.Selection = 1
		end
	end
	
	--上下切换
	local MAX = #data.List
	if UP or UP3 then
		if data.Selection > 5 then
			data.Selection = data.Selection - 5
		else
			if data.Page > 1 then
				data.Page = data.Page - 1
				data.Selection = data.Selection + 15
			elseif not UP3 then
				data.Page = MAX
				data.Selection = data.Selection + 15
			end
		end
	end
	if DOWN or DOWN3 then
		if data.Selection <= 15 then
			data.Selection = data.Selection + 5
		else	
			if data.Page < MAX then
				data.Page = data.Page + 1
				data.Selection = data.Selection - 15
			elseif not DOWN3 then
				data.Page = 1
				data.Selection = data.Selection - 15				
			end	
		end
	end
end
SecretAgent:AddCallback(IBS_CallbackID.HOLDING_ITEM, 'OnHoldingItem', SecretAgent.ID)


local selectionSpr = Sprite('gfx/ibs/ui/selection.anm2')
selectionSpr:Play("Idle")

local fnt = Font()
fnt:Load("font/pftempestasevencondensed.fnt")

--渲染
function SecretAgent:OnHUDRender()
	if not game:GetHUD():IsVisible() then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local isHolding,slot = self._Players:IsHoldingItem(player, self.ID)
		
		if isHolding then
			local data = self:GetData(player)

			if data.Wait > 0 then
				data.Wait = data.Wait - 1
			end
			
			local pos = self._Screens:WorldToScreen(player.Position, Vector(0,-102), true)
			
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
			do
				--房间索引转列行
				local column = (data.Selection-1) % 5
				local row = math.floor((data.Selection-1)/5)
			
				local offsetX = (column * 16) - 32
				local offsetY = row * 16
				selectionSpr:Render(Vector(pos.X + offsetX, pos.Y + offsetY))
			end

			--显示页码
			fnt:DrawStringScaled(tostring(data.Page)..'/'..tostring(#data.List), pos.X - 16, pos.Y + 58, 1, 1, KColor(1,1,1,1), 32, true)
		end
	end
end
SecretAgent:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, 'OnHUDRender')


--显示在主动位置的道具图标
local Icon = Sprite()
Icon:Load("gfx/ibs/ui/items/secret_agent.anm2", true)
Icon:Play(Icon:GetDefaultAnimation())

--把记录的道具贴图贴在主动槽上
function SecretAgent:OnActiveRender(player, slot, offset, alpha, scale)
	if player:GetActiveItem(slot) ~= self.ID then return end
	local varData = player:GetActiveItemDesc(slot).VarData
	if varData > 0 then
		local itemConfig = config:GetCollectible(varData)

		if itemConfig and itemConfig.GfxFileName then
			Icon:ReplaceSpritesheet(1, itemConfig.GfxFileName, true)
		end

		Icon.Scale = Vector(scale, scale)
		Icon.Color = Color(1,1,1,alpha)
		Icon:Render(offset + Vector(16*scale,16*scale))
	end
end
SecretAgent:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, 'OnActiveRender')


return SecretAgent

