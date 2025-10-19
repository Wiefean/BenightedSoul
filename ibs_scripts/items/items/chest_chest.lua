--箱中箱宝库

local mod = Isaac_BenightedSoul
local IBS_ChallengeID = mod.IBS_ChallengeID
local IBS_CallbackID = mod.IBS_CallbackID
local IBS_PlayerID = mod.IBS_PlayerID
local BLost = mod.IBS_Player.BLost

local game = Game()
local sfx = SFXManager()

local ChestChest = mod.IBS_Class.Item(mod.IBS_ItemID.ChestChest)

--获取数据
function ChestChest:GetData()
	local data = self:GetIBSData('temp')
	data.ChestChestChests = data.ChestChestChests or {}
	return data.ChestChestChests
end

--获取角色临时数据
function ChestChest:GetPlayerData(player)
	local data = self._Ents:GetTempData(player)
	if not data.ChestChest then
		local bar = Sprite('gfx/ibs/ui/chargebar.anm2')
		bar:SetFrame("Disappear", 99)
	
		data.ChestChest = {
			Selection = 1,
			LastSelection = 1,
			TargetPtr = 0,
			LastTargetPtr = 0,
			Action = '',
			LastAction = '',
			Wait = 0,
			Charge = 0,
			ChargeBar = bar,
			HighLight = Sprite(),
		}
	end
	return data.ChestChest
end

--是否能存箱子
function ChestChest:CanStore(pickup, player)
	--昧化游魂
	if player:GetPlayerType() == BLost.ID then
		local chestName = BLost:GetChestName(pickup.Variant)
		
		--大箱和妈箱只能作为护甲
		if chestName == 'Mega' or chestName == 'Mom' then
			local data = self:GetPlayerData(player)
			if data.Selection ~= 2 then
				return false
			end
		end
	
		--打开的木箱不能作为护甲
		if chestName == 'Wooden' and not self._Pickups:IsChestClosed(pickup) then
			local data = self:GetPlayerData(player)
			if data.Selection == 2 then
				return false
			end
		end
	
		return self._Pickups:IsChest(pickup.Variant) and chestName ~= nil and pickup.Position:Distance(player.Position) <= 120
	else
		return self._Pickups:IsChest(pickup.Variant) and self._Pickups:IsChestClosed(pickup)
	end
end

--使用
function ChestChest:OnUse(item, rng, player, flags, slot)
	if (flags & UseFlag.USE_OWNED > 0) and (flags & UseFlag.USE_CARBATTERY <= 0) and (flags & UseFlag.USE_VOID <= 0) then
	
		--正在握住时直接跳过
		if self._Players:IsHoldingItem(player, self.ID) then
			return {ShowAnim = false, Discharge = false}
		end		
	
		--昧化游魂副手
		if slot == 2 and player:GetPlayerType() == BLost.ID then
			self._Players:TryHoldItem(self.ID, player, flags, slot)
			return {Discharge = false, ShowAnim = false}
		end
	
		local did = false
		local data = self:GetData()

		--记录箱子
		--正邪(东方mod)可用空箱子
		for _,ent in ipairs(Isaac.FindByType(5)) do
			local pickup = ent:ToPickup()
			if pickup and self:CanStore(pickup, player) then
				local variant = pickup.Variant
			
				--美德书魂火
				if player:HasCollectible(584) then
					player:AddWisp(1, pickup.Position, true)
				end

				--彼列书
				--普通箱变红箱
				if variant == 50 and player:HasCollectible(59) and rng:RandomInt(100) < 50 then
					variant = 360
				end			
			
				table.insert(data, variant)
				table.insert(data, variant)
				Isaac.Spawn(1000, 15, 0, pickup.Position, Vector.Zero, nil) --烟雾特效
				pickup:Remove()
				did = true
			end
		end		
		
		if did then
			return true
		end
		
		return false
	end
end
ChestChest:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', ChestChest.ID)

--新层生成箱子
function ChestChest:OnNewLevel()
	local room = game:GetRoom()
	local data = self:GetIBSData('temp').ChestChestChests
	
	if data then
		for _,variant in ipairs(data) do
			local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
			local chest = Isaac.Spawn(5, variant, 0, pos, Vector.Zero, nil):ToPickup()
			
			--普通箱子防变
			if variant == 50 then
				chest:Morph(5, variant, 1, true, true, true)
			end
		end
		self:GetIBSData('temp').ChestChestChests = nil
	end
end
ChestChest:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

--尝试握住
function ChestChest:OnTryHoldItem(item, player, flag, slot, holdingItem)
	if holdingItem <= 0 and player:GetPlayerType() == BLost.ID then
		local canHold = true

		if (flag & UseFlag.USE_OWNED <= 0) or (flag & UseFlag.USE_CARBATTERY > 0) or (flag & UseFlag.USE_VOID > 0) then
			canHold = false
		end

		--刷新
		if canHold then
			BLost:RefreshHUD(player)
			local data = self:GetPlayerData(player)
			data.Wait = 20
		end

		return {CanHold = canHold}
	end
	return {CanHold = false}
end
ChestChest:AddCallback(IBS_CallbackID.TRY_HOLD_ITEM, 'OnTryHoldItem', ChestChest.ID)

--正在握住
function ChestChest:OnHoldingItem(item, player, flag, slot)
	if game:IsPaused() then return end
	if player:GetPlayerType() ~= BLost.ID then return false end
	local cid = player.ControllerIndex

	--按丢弃键结束握住
	if Input.IsActionTriggered(ButtonAction.ACTION_DROP, cid) then
		return false
	end
	
	local data = self:GetPlayerData(player)
	local UP = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, cid)
	local DOWN = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, cid)
	local LEFT = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, cid)
	local RIGHT = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, cid)

	if data.Wait > 0 then
		data.Wait = data.Wait - 1
	end

	--切换
	if LEFT then
		if data.Selection > 1 then
			data.Selection = data.Selection - 1
		end
	end
	if RIGHT then
		if data.Selection < 6 then
			data.Selection = data.Selection + 1
		end
	end
	if UP then
		if data.Selection > 3 then
			data.Selection = data.Selection - 3
		end
	end
	if DOWN then
		if data.Selection < 4 then
			data.Selection = data.Selection + 3
		end	
	end
end
ChestChest:AddCallback(IBS_CallbackID.HOLDING_ITEM, 'OnHoldingItem', ChestChest.ID)

--背景贴图
local weaponIconSpr = Sprite('gfx/ibs/ui/players/blost_hud.anm2')
weaponIconSpr:Play("Weapon")
local armorIconSpr = Sprite('gfx/ibs/ui/players/blost_hud.anm2')
armorIconSpr:Play("Armor")
local floatIconSpr = Sprite('gfx/ibs/ui/players/blost_hud.anm2')
floatIconSpr:Play("Float")
local keyIconSpr = Sprite('gfx/ibs/ui/players/blost_hud.anm2')
keyIconSpr:Play("Key")
local changeIconSpr = Sprite('gfx/ibs/ui/players/blost_hud.anm2')
changeIconSpr:Play("Change")
local plusIconSpr = Sprite('gfx/ibs/ui/players/blost_hud.anm2')
plusIconSpr:Play("Plus")
local bombIconSpr = Sprite('gfx/ibs/ui/players/blost_hud.anm2')
bombIconSpr:Play("Bomb")

local selectionSpr = Sprite('gfx/ibs/ui/selection.anm2')
selectionSpr:Play("Idle")

local fnt = Font('font/pftempestasevencondensed.fnt')

--渲染
function ChestChest:OnHUDRender()
	if not game:GetHUD():IsVisible() then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == BLost.ID and self._Players:IsHoldingItem(player, self.ID) then
			local challengeMode = (Isaac.GetChallenge() == IBS_ChallengeID[11])
			local room = game:GetRoom()
			local data = self:GetPlayerData(player)
			local selection = data.Selection
			local mecha = BLost:GetMechaData(player)
			local selected = mecha[selection] or {}
			
			local cost = BLost:GetRepairCost(selection, selected.Chest, selected.Left, selected.Max)
			local canRepair = BLost:CanRepair(player, selection)			
			
			--心(用于红箱子)
			local heart = nil
			if selected.Chest == 'Red' and selected.Left < selected.Max then
				heart = self._Finds:ClosestEntity(player.Position, 5, 10, -1, function(ent)
					if ent.Position:Distance(player.Position) > 120 then return false end
					local pickup = ent:ToPickup()
					if pickup and pickup.Price > 0 and player:GetNumCoins() < pickup.Price then
						return false
					end
					return true
				end)
			end
			
			local chest = nil
			if not heart then			
				chest = self._Finds:ClosestEntity(player.Position, 5, -1, -1, function(ent)
					return self:CanStore(ent, player)
				end)			
			end
			
			--高亮
			do
				local pickup = heart or chest
				if pickup then
					local spr = pickup:GetSprite()
					local fileName = spr:GetFilename()
					
					--加载动画文件
					if data.HighLight:GetFilename() ~= fileName then
						data.HighLight:Load(fileName, true)
					end

					--镜世界翻转
					if room:IsMirrorWorld() then
						data.HighLight.FlipX = true
					else
						data.HighLight.FlipX = false
					end

					data.HighLight:SetFrame(spr:GetAnimation(), spr:GetFrame())
					data.HighLight.Scale = pickup.SpriteScale
					data.HighLight.Color = Color(1, 1, 1, 1, 100/255, 100/255, 0)					
					data.HighLight:Render(self._Screens:WorldToScreen(pickup.Position, Vector.Zero, true))
					data.TargetPtr = GetPtrHash(pickup)
				end
			end

			local maxCharge = 60
			
			if (not chest) and (not heart) and canRepair then
				--护甲固定修复速度
				if selection ~= 2 then
					maxCharge = math.floor(math.max(30, 300*(1-selected.Left/selected.Max)))
				else
					local dura,init = BLost:GetChestDurability(selection, selected.Chest) or 270
					maxCharge = 120 * selected.Max
				end
			end
			
			--显示进度条
			do
				local pos = self._Screens:WorldToScreen(player.Position, Vector(0,32), true)	
				if data.Charge > 20 then
					data.ChargeBar:SetFrame("Charging", math.floor(100*(data.Charge-20)/maxCharge))
				else
					data.ChargeBar:Play("Disappear")
					if not game:IsPaused() then
						data.ChargeBar:Update()
					end
				end
				data.ChargeBar.Scale = Vector(1,1)
				data.ChargeBar:Render(pos)
			end	

			local red = (selected.Chest == 'Red') and (heart ~= nil)
			local store = (chest ~= nil)
			
			if red then
				data.Action = "AbsorbingHeart"
			elseif store then
				data.Action = "Storing"
			elseif canRepair then
				data.Action = "Repairing"
			end

			--与上一帧行为不一致时清空充能
			if data.LastSelection ~= data.Selection then
				data.LastSelection = data.Selection
				data.Charge = 0
			end
			if data.LastTargetPtr ~= data.TargetPtr then
				data.LastTargetPtr = data.TargetPtr
				data.Charge = 0
			end
			if data.LastAction ~= data.Action then
				data.LastAction = data.Action
				data.Charge = 0
			end

			--长按存箱子/修复箱子(红箱子为吸收心)
			if not game:IsPaused() and Input.IsActionPressed(ButtonAction.ACTION_PILLCARD, player.ControllerIndex) then
				if (red or store or canRepair) and data.Wait <= 0 then				
					data.Charge = data.Charge + 1
					
					
					if not red and not store then
						--长子权
						if player:HasCollectible(619) then 
							data.Charge = data.Charge + 1
						end
						
						--已清理房间
						if room:IsClear() then
							data.Charge = data.Charge + 3
						end
					end
				else
					data.Charge = 0
				end
				
				if data.Charge >= maxCharge+20 then
					data.Charge = 0

					--存箱子
					if store then
						data.Wait = 30
						local chestName = BLost:GetChestName(chest.Variant)
						
						--大箱子不会被换掉,而是吸收其他箱子
						if selected.Chest == 'Mega' then
							local mega = BLost:GetMegaAbsorption(player)
							
							--首次吸收一种箱子时增加耐久上限
							if not mega[tostring(chest.Variant)] then
								selected.Max = selected.Max + 1
								
								--若为大箱或妈箱则额外增加上限并回满耐久
								if chestName == 'Mega' or chestName == 'Mom' then
									selected.Max = selected.Max + 2
									selected.Left = selected.Max
								end
							end
							mega[tostring(chest.Variant)] = true
							
							--恢复耐久
							local num = (self._Pickups:IsChestClosed(chest) and 0.4) or 1
							selected.Left = math.min(selected.Max, selected.Left + num)
						else
							local dura,initDura = BLost:GetChestDurability(selection, chestName)
							
							--开过的箱子耐久更低
							if initDura and not self._Pickups:IsChestClosed(chest) then
								local mult = 0.15
								if selection == 2 or chestName == 'Stone' then
									mult = 0.5		
								end
								initDura = math.ceil(mult*initDura)
							end
							
							selected.Chest = chestName
							selected.Max = dura or 1
							selected.Left = initDura or 1
							BLost:RefreshHUD(player)
							
							--新大箱刷新记录
							if selection == 2 then
								local mega = BLost:GetMegaAbsorption(player)
								for k,v in pairs(mega) do
									mega[k] = nil
								end
							end
						end
						player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
						sfx:Play(mod.IBS_Sound.Dang)
						Isaac.Spawn(1000, 15, 0, chest.Position, Vector.Zero, nil)
						chest:Remove()
					elseif red then --红箱吸心
						BLost:TryAbsorbHeart(player, selection, heart)
						sfx:Play(157)
					elseif canRepair then --修复箱子
						--挑战改为用炸弹修复
						if challengeMode then
							if player:GetNumBombs() >= cost then
								player:AddBombs(-cost)
								selected.Left = selected.Max
								player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
								sfx:Play(mod.IBS_Sound.Dang)
							end						
						else
							if player:GetNumKeys() >= cost then
								player:AddKeys(-cost)
								selected.Left = selected.Max
								player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
								sfx:Play(mod.IBS_Sound.Dang)
							end
						end
					end
				end
			else
				data.Charge = 0
			end
			
			do
				local pos = self._Screens:WorldToScreen(player.Position, Vector(0,0), true)
				
				--显示箱子图标
				local X,Y = pos.X - 16, pos.Y
				local savedX = X
				local column = 1
				for k,spr in ipairs(BLost:GetHUDSpriteData(player)) do
					
					--背景贴图
					local percent = (mecha[k].Chest ~= "None" and mecha[k].Left/mecha[k].Max) or nil
					local color = Color(1,1,1,0.5)
					
					--颜色表示耐久损耗程度
					if percent then
						if percent > 0.7 then
							color = Color(0,1,0,0.5) --绿
						elseif percent > 0.35 and percent <= 0.7 then
							color = Color(1,1,0,0.5) --黄
						else
							color = Color(1,0,0,0.5) --红
						end
						
						--护甲耐久小于等于1直接显示红色
						if k == 2 then
							if mecha[k].Left <= 1 then
								color = Color(1,0,0,0.5)
							end
						elseif mecha[2].Chest == "Mom" then
							--武器和僚机在装备有妈箱护甲时耐久无限
							color = Color(1,0,1,0.5) --紫
						end
					end
					
					if k == 1 or k == 3 then
						weaponIconSpr.Color = color
						weaponIconSpr:Render(Vector(X,Y))
					end
					if k == 2 then
						armorIconSpr.Color = color
						armorIconSpr:Render(Vector(X,Y))
					end
					if k >= 4 and k <= 6 then
						floatIconSpr.Color = color
						floatIconSpr:Render(Vector(X,Y))
					end
				
					spr:Render(Vector(X,Y))
					
					--显示选择框
					if k == data.Selection then
						selectionSpr:Render(Vector(X,Y))
						
						if red then
							--显示恢复提示图标
							plusIconSpr:Render(Vector(X,Y))
						elseif store then
							--大箱子不会被换掉,而是吸收其他箱子
							if mecha[k].Chest == 'Mega' then
								plusIconSpr:Render(Vector(X,Y))
							else
								--显示更换提示图标
								changeIconSpr:Render(Vector(X,Y))
							end
						elseif canRepair then
							plusIconSpr:Render(Vector(X,Y))				
						end
					end
					
					X = X + 16
					column = column + 1
					
					if column > 3 then
						X = savedX
						Y = Y + 16
						column = 1
					end
				end

				
				--显示耐久和修复消耗
				if (not chest or selected.Chest == 'Mega') and selected.Chest ~= "None" then
					fnt:DrawStringScaled(math.ceil(selected.Left) ..'/'..selected.Max, pos.X + 32, pos.Y, 1, 1, KColor(1,1,1,1), 32, true)				
					
					if cost > 0 then
						local kColor = KColor(1,1,1,1)
						
						--挑战改为用炸弹修复
						if challengeMode then
							bombIconSpr:Render(Vector(pos.X - 48, pos.Y + 8))
							if player:GetNumBombs() < cost then
								kColor = KColor(1,0,0,1)
							end							
						else
							keyIconSpr:Render(Vector(pos.X - 48, pos.Y + 8))
							if player:GetNumKeys() < cost then
								kColor = KColor(1,0,0,1)
							end
						end
						
						fnt:DrawStringScaled(cost, pos.X - 54, pos.Y, 1, 1, kColor, 32, true)				
					end
				end			
			end

		end
	end
end
ChestChest:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, 'OnHUDRender')


return ChestChest