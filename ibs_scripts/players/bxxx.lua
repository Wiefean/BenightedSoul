--昧化???
--(魂心角色设置部分在ibs_players.lua文件中)

local mod = Isaac_BenightedSoul
local IBS_API = mod.IBS_API
local IBS_CallbackID = mod.IBS_CallbackID
local IBS_PocketID = mod.IBS_PocketID
local CharacterLock = mod.IBS_Achiev.CharacterLock
local Pools = mod.IBS_Lib.Pools

local game = Game()
local Memories = mod.IBS_Class.Memories()
local BXXXOrb = mod.IBS_Familiar.BXXXOrb

local BXXX = mod.IBS_Class.Character(mod.IBS_PlayerID.BXXX, {})

--[[槽位ID图示:
 1  2  3
 4  5  6 (持有长子权时才使用这三槽)
-1 -2 -3 (从左到右分别为"合成伪忆","分解掉落物","炸弹")
]]

--变身
function BXXX:Benighted(player, fromMenu)
	if CharacterLock.BXXX:IsLocked() then return end

	local CAN = false 

	--检测答辩
	for slot = 0,1 do
		if player:GetActiveItem(slot) == 36 then
			player:RemoveCollectible(36, true, slot)
			CAN = true
			break
		end	
	end
	if player:GetActiveItem(2) == 36 then CAN = true end
	
	if CAN or fromMenu then
		player:ChangePlayerType(self.ID)

		--完成挑战后生成伪忆
		if self:GetIBSData('persis')['bc5'] then
			local room = game:GetRoom()
			local pos = room:FindFreePickupSpawnPosition((room:GetCenterPos()), 0, true)
			Isaac.Spawn(5, 100, mod.IBS_ItemID.FalsehoodOfXXX, pos, Vector(0,0), nil)
		end

		Memories:Add(70)
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
		
		if not fromMenu then
			player:AnimateSad()
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, nil)
		end
	end
end
BXXX:AddCallback(IBS_CallbackID.BENIGHTED, 'Benighted', PlayerType.PLAYER_BLUEBABY)


--获取数据
function BXXX:GetData(player)
	local data = self._Players:GetData(player)
	if not data.BXXX then data.BXXX = {
		Selection = -3,
		Falsehoods = {},
		BJBEMimics = {},
		FalowerseUsed = false,
	}
	end
	return data.BXXX
end

--是否扩容
function BXXX:ShouldBoost(player)
	if player and player:GetPlayerType() == self.ID then
		if player:HasCollectible(619) or self:GetData(player).FalowerseUsed then
			return true
		end
	end
	return false
end

--属性
function BXXX:OnEvaluateCache(player, flag)
	if player:GetPlayerType() == self.ID then
		local mult = 0.7

		if flag & CacheFlag.CACHE_SPEED > 0 then
			player.MoveSpeed = player.MoveSpeed * mult + 0.3
		end
		if flag & CacheFlag.CACHE_FIREDELAY > 0 then
			self._Stats:TearsMultiples(player, 1 + 0.01*(Memories:GetNum()))
		end
		if flag & CacheFlag.CACHE_DAMAGE > 0 then
			player.Damage = player.Damage * mult
		end
		if flag & CacheFlag.CACHE_RANGE > 0 then
			player.TearRange = player.TearRange * mult
		end
		if flag & CacheFlag.CACHE_SHOTSPEED > 0 then
			player.ShotSpeed = player.ShotSpeed * mult
		end
		if flag & CacheFlag.CACHE_LUCK > 0 then
			player.Luck = player.Luck * mult - 3
		end
	end
end
BXXX:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, 'OnEvaluateCache')

--检查伪忆球信息
function BXXX:OnEvaluateCache2(player, flag)
	if flag & CacheFlag.CACHE_FAMILIARS > 0 then
		if player:GetPlayerType() == self.ID then
			local data = self:GetData(player)
			for k,subType in pairs(BXXXOrb.SubType) do			
				local num = 0
				
				for _,v in pairs(data.Falsehoods) do
					if v == IBS_PocketID[k] then
						num = num + 1
					end
				end

				--挑战特殊规则
				if subType == BXXXOrb.SubType.BApollyon and Isaac.GetChallenge() == mod.IBS_ChallengeID[5] then 
					num = num + 1
				end
				
				player:CheckFamiliar(BXXXOrb.Variant, num, RNG(1), nil, subType)
			end
		else
			for k,subType in pairs(BXXXOrb.SubType) do			
				player:CheckFamiliar(BXXXOrb.Variant, 0, RNG(1), nil, subType)
			end			
		end	
	end
end
BXXX:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, -725, 'OnEvaluateCache2')

--查找伪忆球
function BXXX:FindOrbs(player, subType)	
	return BXXXOrb:FindOrbs(player, subType)
end

--获取图标
local function GetIconSprite(frame)
	local spr = Sprite()
	spr:Load("gfx/ibs/ui/players/bxxx_hud.anm2", true)
	spr:Play("Idle")
	spr:SetFrame(frame)
	
	return spr
end

--图标
local Icon = {
	SelectionSprite = GetIconSprite(0),
	SlotSprite = GetIconSprite(1),
	FalowerseSprite = GetIconSprite(2),
	MemorySprite = GetIconSprite(3),
	BombSprite = GetIconSprite(4)
}

--记忆碎片图标和字体
local memorySpr = GetIconSprite(5)
local memoryFnt = Font()
memoryFnt:Load("font/pftempestasevencondensed.fnt")

--伪忆信息表(部分装扮还没做)
local FalsehoodList = {}
local FileName = {'bisaac', 'bmaggy', 'bcain', "babel", 'bjudas', 'beve', 'bsamson', 'bazazel', 'blazarus', 'beden', 'blost', 'blilith', 'bkeeper', 'bapollyon', 'bforgotten', 'bbeth', 'bjbe'}
local a = 6
for FH = IBS_PocketID.BIsaac, IBS_PocketID.BJBE do
	FalsehoodList[FH] = {Sprite = GetIconSprite(a), Costume = Isaac.GetCostumeIdByPath("gfx/ibs/characters/bxxx_"..FileName[a-5]..".anm2")}
	a = a + 1
end

--更新装扮
function BXXX:UpdateCoustume(player, falsehood)
	for k,v in pairs(FalsehoodList) do
		if k <= IBS_PocketID.BJudas then
			if k == falsehood then
				player:AddNullCostume(v.Costume)
			else
				player:TryRemoveNullCostume(v.Costume)
			end
		end
	end
end

--使用伪忆时更新装扮与记录
function BXXX:OnUseFalsehood(card, player, flag)
	if player:GetPlayerType() == self.ID and FalsehoodList[card] then
		self:UpdateCoustume(player, card)

		--双子球兼容
		if card ~= IBS_PocketID.BJBE then
			for k,subType in pairs(BXXXOrb.SubType) do
				if IBS_PocketID[k] == card then
					local record = self:GetData(player).BJBEMimics
					table.insert(record, 1, subType)
					if #record >= 3 then
						for i = 3,#record do
							record[i] = nil
						end
					end
				end
			end
		end
	end
end
BXXX:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUseFalsehood')

--角色更新
function BXXX:OnPlayerUpdate(player)
	local playerType = player:GetPlayerType()

	if (playerType ~= self.ID) then
		local data = self._Players:GetData(player).BXXX
		if data then
			self:UpdateCoustume(player, -1)
			self._Players:GetData(player).BXXX = nil

			--蓝人
			if playerType == 4 then
				player:ChangePlayerType(self.ID)
			end
		end
		return
	end
	
	local data = self:GetData(player)
	local stored = data.Falsehoods
	local sel = data.Selection
	local spr = player:GetSprite()
	local cid = player.ControllerIndex
	
	--为副角色时跳转
	if player.Parent then goto skip end

	if (sel ~= -3) and Input.IsActionTriggered(ButtonAction.ACTION_BOMB, cid) then
		local room = game:GetRoom()

		--选择伪忆槽
		if (sel >= 1) and (sel <= 6) then
			local ID = player:GetCard(0)
		
			if stored[sel] == nil then
				if FalsehoodList[ID] then
					stored[sel] = ID
					player:RemovePocketItem(0)
					player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
				else				
					self:UpdateCoustume(player, -1)
				end
			else
				player:UseCard(stored[sel])	
				stored[sel] = nil
				player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
			end
		end

		--选择合成伪忆
		if (sel == -1) then		
			if Memories:GetNum() >= 21 then
				Memories:Add(-21)
				local idx = self._Pickups:GetUniqueOptionsIndex()
				for _ = 1,3 do
					local falsehood = Pools:GetRandomFalsehood(self:GetRNG("Player_BXXX"))
					local pickup = Isaac.Spawn(5, 300, falsehood, player.Position, Vector.Zero, player):ToPickup()
					pickup.OptionsPickupIndex = idx
					pickup.Velocity = RandomVector()
					pickup.Wait = 45
				end
				player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
			end
		end

		--选择分解掉落物
		if (sel == -2) and player:IsExtraAnimationFinished() then
			if Memories:DecomposePickupsInRadius(player.Position, 70, true) then
				player:AnimateSad()
			end
		end
	end
	
	--按丢弃键切换槽位
	if Input.IsActionTriggered(ButtonAction.ACTION_DROP, cid) then
		local maxSlot = 3
		if self:ShouldBoost(player) then maxSlot = 6 end --具有增强效果时,增加3个槽位
		
		--按住地图键时,切换至上一槽
		if Input.IsActionPressed(ButtonAction.ACTION_MAP, cid) then
			if (sel < 0) then
				if (sel < -1) then
					data.Selection = sel + 1
				else
					data.Selection = maxSlot
				end
			else
				if (sel > 1) then
					data.Selection = sel - 1
				else
					data.Selection = -3
				end
			end
		else --没有按住地图键时,切换至下一槽
			if (sel < 0) then
				if (sel > -3) then
					data.Selection = sel - 1
				else
					data.Selection = 1
				end
			else
				if (sel < maxSlot) then
					data.Selection = sel + 1
				elseif (sel >= maxSlot) then
					data.Selection = -1
				end
			end
		end	
	end
	
	::skip::
end
BXXX:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)


--获取图标渲染位置
function BXXX:GetIconRenderPosition(idx)
	local screenSizeX, screenSizeY = Isaac.GetScreenWidth(), Isaac.GetScreenHeight()
	local X,Y = 0,0
	local offset = Options.HUDOffset

	if (idx == 0) then --P1
		X = 48 + 20*offset
		Y = 50 + 12*offset
	elseif (idx == 1) then --P2
		X = screenSizeX - 116 - 24*offset
		Y = 64 + 12*offset
	elseif (idx == 2) then --P3
		X = 100 + 22*offset
		Y = screenSizeY - 32 - 6*offset
	else --P4或其他
		X = screenSizeX - 80 - 16*offset
		Y = screenSizeY - 48 - 6*offset
	end
	
	return X,Y
end

--获取记忆碎片渲染位置
function BXXX:GetMemoryRenderPosition()
	local offset = Options.HUDOffset
	
	return 56 + 20*offset, 34 + 12*offset
end

local alpha = 1

--渲染图标
function BXXX:OnRender()
	if not game:GetHUD():IsVisible() then return end
	local bxxxFound = false
	local controllers = {} --用于为控制器编号
	local index = 0
	
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local cid = player.ControllerIndex
		
		if (player.Variant == 0) and (player:GetPlayerType() == self.ID) and not player:IsCoopGhost() then
			bxxxFound = true
			if (not player.Parent) and (not controllers[cid]) then
				local data = self:GetData(player)
				local stored = data.Falsehoods
				local maxSlot = 3
				
				if self:ShouldBoost(player) then
					maxSlot = 6
				end
				
				local X,Y = self:GetIconRenderPosition(cid)
				local savedX = X
				
				for i = 1,maxSlot do
					Icon.SlotSprite:Render(Vector(X,Y))
					
					if stored[i] then
						FalsehoodList[stored[i]].Sprite:Render(Vector(X,Y))
					end
					
					if (i == data.Selection) then
						Icon.SelectionSprite:Render(Vector(X,Y))
					end
					
					if (i == 3) or (i == 6) then
						X = savedX
						Y = Y + 16
					else
						X = X + 16
					end
				end
				
				for i = 1,3 do
					if (i == 1) then
						Icon.FalowerseSprite:Render(Vector(X,Y))
					elseif (i == 2) then
						Icon.MemorySprite:Render(Vector(X,Y))
					elseif (i == 3) then
						Icon.BombSprite:Render(Vector(X,Y))
					end
					
					if (-i == data.Selection) then
						Icon.SelectionSprite:Render(Vector(X,Y))
					end					
					
					X = X + 16
				end
			end	
			controllers[cid] = true
			index = index + 1
		end
	end
	
	if bxxxFound then
		local num = Memories:GetNum()
		local stringNum = tostring(num)
		local X,Y = self:GetMemoryRenderPosition()
		
		if num < 10 then
			stringNum = "0"..stringNum
		end
		
		memorySpr:Render(Vector(X,Y))
		memoryFnt:DrawStringScaled(stringNum, X + 10, Y - 6, 1, 1, KColor(1,1,1,1))
	
		--调整透明度
		if not game:IsPaused() then
			if game:GetRoom():IsClear() then
				if alpha < 1 then alpha = alpha + 0.05 end
			else
				if alpha > 0.35 then alpha = alpha - 0.05 end
			end
			
			for k,spr in pairs(Icon) do
				spr.Color = Color(1,1,1,alpha)
			end
			
			for k,v in pairs(FalsehoodList) do
				v.Sprite.Color = Color(1,1,1,alpha)
			end
		end
	end
	
	--EID显示位置稍微调下面一些
	if EID and game:GetRoom():GetFrameCount() > 0 then
		if EID.player and (EID.player:GetPlayerType() == self.ID) then
			local eidOffset = Vector(0,48)
			if self:ShouldBoost(EID.player) then
				eidOffset = Vector(0,64)
			end
			EID:addTextPosModifier("IBS_BXXX", eidOffset)
		else
			EID:removeTextPosModifier("IBS_BXXX")
		end
	end	
end
BXXX:AddPriorityCallback(ModCallbacks.MC_POST_RENDER, CallbackPriority.EARLY, 'OnRender')


--操作
function BXXX:CheckInput(ent, hook, action)
	local player = (ent and ent:ToPlayer())
	
	if player and (action == ButtonAction.ACTION_BOMB) then
		local Press = (hook == InputHook.IS_ACTION_PRESSED)
		local Trigger = (hook == InputHook.IS_ACTION_TRIGGERED)
		local GetValue = (hook == InputHook.GET_ACTION_VALUE)
		local cid = player.ControllerIndex
	
		--为主角色时,忽略炸弹键
		if not player.Parent then
			if (player:GetPlayerType() == self.ID) and (self:GetData(player).Selection ~= -3) then
				if Press or Trigger then
					return false
				elseif GetValue then
					return 0
				end
			end
		else --为副角色时,跟着主角色忽略炸弹键
			local player2 = player.Parent:ToPlayer()		
			if player2 and (player2:GetPlayerType() == self.ID) and (self:GetData(player).Selection ~= -3) then
				if Press or Trigger then
					return false
				elseif GetValue then
					return 0
				end
			end
		end
	end
end
BXXX:AddPriorityCallback(ModCallbacks.MC_INPUT_ACTION, -999, 'CheckInput')




return BXXX