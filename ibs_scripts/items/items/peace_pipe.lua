--宁静烟斗
--(该道具在5月31日上线)
--(意义不明的注释XD)

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local IBS_CallbackID = mod.IBS_CallbackID
local AbandonedItem = mod.IBS_Effect.AbandonedItem

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local PeacePipe = mod.IBS_Class.Item(IBS_ItemID.PeacePipe)

--黑名单
--(除非持有,否则不展示的道具)
--(主要是没有在图鉴中隐藏且不属于任何道具池的道具)
PeacePipe.BlackList = {
	[474] = true, --损坏玻璃大炮
	[IBS_ItemID.Edge2] = true, --伤疤之秘
	[IBS_ItemID.Edge3] = true, --破碎之秘
}

--获取数据
function PeacePipe:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.PEACEPIPE = data.PEACEPIPE or {
		Selection = 1,
		Page = 1,
		Wait = 0,
		Wait2 = 0,
		Wait3 = 0,
		MaxWait3 = 60,
		List = {}
	}
	return data.PEACEPIPE
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
function PeacePipe:RefreshList(player)
	local data = self:GetData(player)
	local itemPool = game:GetItemPool()
	local cache = {}
	
	for k,_ in pairs(data.List) do
		data.List[k] = nil
	end

	local page = 1

	local MAX = config:GetCollectibles().Size - 1
	for id = 1, MAX do
		local itemConfig = config:GetCollectible(id)
		
		if itemConfig and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
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
			
			--持有或道具池里有
			if has or (itemConfig:IsAvailable() and (not self.BlackList[id]) and itemPool:HasCollectible(id)) then			
				table.insert(cache, {Sprite = GetItemSprite(id), ID = id, Quality = itemConfig.Quality or 0, Has = has})
			end
		end
	end	
	
	--优先把角色持有的排最下面,然后按品质升序,最后按id升序
	table.sort(cache, function(a,b)
		if a.Has ~= b.Has then
			return (a.Has == false)
		elseif a.Quality ~= b.Quality then
			return (a.Quality < b.Quality)
		else
			return (a.ID < b.ID)
		end
	end)
	
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
			table.insert(data.List[page], {Sprite = spr, Has = false})
		end
	end
end

--清理房间充能
function PeacePipe:Charge()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		for slot = 0,2 do
			if player:GetActiveItem(slot) == self.ID then
				local charge = (self._Levels:IsInBigRoom() and 6) or 3
				local varData = player:GetActiveItemDesc(slot).VarData
				player:SetActiveVarData(math.min(999, varData + charge), slot)
			end
		end
	end	
end
PeacePipe:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'Charge')
PeacePipe:AddCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, 'Charge') --贪婪模式波次充能


--使用
function PeacePipe:OnUse(item, rng, player, flag, slot)
	if (slot >= 0 and slot <= 2) and (flag & UseFlag.USE_OWNED > 0) and (flag & UseFlag.USE_CARBATTERY <= 0) and (flag & UseFlag.USE_VOID <= 0) then
		local data = self:GetData(player)
			
		--正在握住则触发效果,否则尝试握住
		if self._Players:IsHoldingItem(player, self.ID) and data.Wait <= 0 then
			local item = data.List[data.Page] and data.List[data.Page][data.Selection] and data.List[data.Page][data.Selection].ID
			local varData = player:GetActiveItemDesc(slot).VarData
			local debug8 = (game:GetDebugFlags() & DebugFlag.INFINITE_ITEM_CHARGES > 0)
			
			--debug8兼容,不限次数
			if item and (varData > 0 or debug8) then
				local itemConfig = config:GetCollectible(item)
				local has = false
				
				player:SetActiveVarData(math.max(0, varData - 1))
				game:GetItemPool():RemoveCollectible(item)
				
				--抽烟减寿,好孩子不要抽烟
				game.TimeCounter = math.max(30, game.TimeCounter - 30*5)				
				
				--主动道具需要额外检测,防止移除副手和套装效果
				if itemConfig.Type == ItemType.ITEM_ACTIVE then
					for _slot = 0,1 do
						if player:GetActiveItem(_slot) == item then
							player:RemoveCollectible(item, true, _slot, false)
							has = true
						end
					end
				elseif player:HasCollectible(item, true) then
					player:RemoveCollectible(item, true)
					has = true
				end
				
				--删除持有的道具会返还计数
				if has then				
					player:SetActiveVarData(math.min(999, varData + (itemConfig.Quality or 0)^2))
				end
				
				--美德书
				if player:HasCollectible(584) then
					self._Stats:PersisTearsModifier(player, 0.005, true)
				end				
				
				--彼列书
				if player:HasCollectible(59) then
					self._Stats:PersisDamage(player, 0.01, true)
					sfx:Play(34)
				end

				--不能用时立刻结束握住
				if (varData <= 1 and not debug8) or (item == self.ID) then				
					self._Players:EndHoldItem(player, true)
				else
					self:RefreshList(player)
				end

				--尝试恢复上限骰(东方mod)
				mod.IBS_Compat.THI:TryRestoreDice(player, self.ID, slot)

				--特效
				if itemConfig.GfxFileName then
					AbandonedItem:Spawn(player.Position, itemConfig.GfxFileName, RandomVector() * 0.1 * math.random(10, 15))
				end				
				sfx:Play(267)
			end
		else
			self._Players:TryHoldItem(self.ID, player, flag, slot)
		end
	end

	return {ShowAnim = false, Discharge = false}
end
PeacePipe:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', PeacePipe.ID)

--尝试握住
function PeacePipe:OnTryHoldItem(item, player, flag, slot, holdingItem)
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
PeacePipe:AddCallback(IBS_CallbackID.TRY_HOLD_ITEM, 'OnTryHoldItem', PeacePipe.ID)

--正在握住
function PeacePipe:OnHoldingItem(item, player, flag, slot)
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

	local activePressed = self._Players:IsActiveButtonPressed(player, slot)

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

	--长按使用滚动检测
	if activePressed then
		if data.Wait3 < data.MaxWait3 then		
			data.Wait3 = data.Wait3 + 1
		else
			data.Wait3 = 0
			data.MaxWait3 = math.max(data.MaxWait3 - 15, 12)
			player:UseActiveItem(self.ID, UseFlag.USE_OWNED, slot)
		end
	else	
		data.Wait3 = 0
		data.MaxWait3 = 60
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
PeacePipe:AddCallback(IBS_CallbackID.HOLDING_ITEM, 'OnHoldingItem', PeacePipe.ID)


local selectionSpr = Sprite('gfx/ibs/ui/selection.anm2')
selectionSpr:Play("Idle")

local fnt = Font()
fnt:Load("font/pftempestasevencondensed.fnt")

--不透明度,主要用于移除道具提示
local alpha = 1
local down = false
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if down then
		if alpha > 0.5 then
			alpha = alpha - 0.05
		else
			down = false
		end
	else
		if alpha < 1 then
			alpha = alpha + 0.05
		else
			down = true
		end	
	end
end)

--渲染
function PeacePipe:OnHUDRender()
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
					
					--将从角色身上移除颜色描边提示
					if v.Has then
						v.Sprite.Color = Color(1,1,1,alpha,1,0,0)
						v.Sprite:Render(Vector(X,Y))
						v.Sprite:Render(Vector(X+1,Y))
						v.Sprite:Render(Vector(X-1,Y))
						v.Sprite:Render(Vector(X,Y+1))
						v.Sprite:Render(Vector(X,Y-1))
						v.Sprite.Color = Color(1,1,1,alpha)
					else
						v.Sprite.Color = Color(1,1,1,1)
					end
					
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
PeacePipe:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, 'OnHUDRender')


--显示剩余次数
function PeacePipe:OnActiveRender(player, slot, offset, alpha, scale)
	if player:GetActiveItem(slot) ~= self.ID then return end
	local varData = player:GetActiveItemDesc(slot).VarData

	local stringNum = tostring(varData)
	local color = KColor(1,1,1,1)

	--红色提醒用完了
	if varData <= 0 then
		color = KColor(1,0,0,1)
	end
	
	local pos = Vector(scale, scale) + offset
	stringNum = "x"..stringNum
	fnt:DrawStringScaled(stringNum, pos.X, pos.Y, scale * 0.75, scale * 0.75, color)
end
PeacePipe:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, 'OnActiveRender')


return PeacePipe