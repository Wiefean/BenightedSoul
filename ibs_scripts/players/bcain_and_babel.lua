--昧化该隐&亚伯

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID
local IBS_PlayerID = mod.IBS_PlayerID
local IBS_ItemID = mod.IBS_ItemID

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local BCBA = mod.IBS_Class.Component()

BCBA.BCain = mod.IBS_Class.Character(IBS_PlayerID.BCain, {
	BossIntroName = 'bcain',
	SpritePath = 'gfx/ibs/characters/player_bcain.anm2',
	SpritePathFlight = 'gfx/ibs/characters/player_bcain.anm2',
	PocketActive = IBS_ItemID.PortableFarm,
})
BCBA.BAbel = mod.IBS_Class.Character(IBS_PlayerID.BAbel, {
	BossIntroName = 'babel',
	PocketActive = IBS_ItemID.Goatify,
})

--添加处于副角色状态时不临时移除的主动道具,用于模组兼容
--(默认包含原版所有主动)
BCBA.ExcludedActive = {}

function BCBA:AddExcludedActiveItem(item)
	self.ExcludedActive[item] = true
end

--愚昧模组道具
for k,v in pairs(IBS_ItemID) do
	BCBA:AddExcludedActiveItem(v)
end

--获取另一玩家
function BCBA:GetOtherTwin(player)
	local data = self._Ents:GetTempData(player).BCBA
	if data and data.Twin then
		return data.Twin
	end
	return nil
end

--是否为主角色
function BCBA:IsMainPlayer(player)
	local data = self._Players:GetData(player).BCBAInfo
	if data and data.State and (data.State ~= "Second") then
		return true
	end
	return false
end

--是否为副角色
function BCBA:IsSecondPlayer(player)
	local data = self._Players:GetData(player).BCBAInfo
	if data and data.State and (data.State == "Second") then
		return true
	end
	return false
end

--是否为初始玩家
function BCBA:IsOriginPlayer(player)
	local data = self._Players:GetData(player).BCBAInfo
	if data and data.Origin then
		return true
	end
	return false
end

--任意主副角色拥有道具
function BCBA:AnyHasCollectible(player, item)
	local has = false
	local player2 = self:GetOtherTwin(player)
	
	has = player:HasCollectible(item)
	
	if (not has) and player2 and player2:Exists() and not player2:IsDead() then
		has = player2:HasCollectible(item)
	end
	
	return has
end

--获取处于副角色的时间(60 = 1秒)
--(大于462时,自动重置为0)
--(对非副角色则返回0)
local function GetInSecondFrameCount(player)
	local data = BCBA._Ents:GetTempData(player).BCBA
	if data then
		return data.InSecondFrameCount or 0
	end
	return 0
end


--临时数据
function BCBA:GetTempData(player)
	local data = self._Ents:GetTempData(player)
	data.BCBA = data.BCBA or {
		Twin = nil,
		InSecondFrameCount = 0,
		SwitchTimeOut = 0,
		QuickRedeathWait = 42
	}

	return data.BCBA
end

--长久数据
function BCBA:GetData(player)
	local data = self._Players:GetData(player)
	data.BCBAInfo = data.BCBAInfo or {
		State = "",
		TwinIndex = "",
		Origin = false,
		SavedActive = {}
	}

	return data.BCBAInfo
end

--获取玩家的索引(道具种子)
local function GetPlayerIndex(player)
	local idx = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_IBS):GetSeed()
	return tostring(idx)
end

--用索引获取玩家
local function GetPlayerByIndex(index)
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if GetPlayerIndex(player) == index then
			return player
		end
	end
	return nil
end

--正在退出游戏,用于修正
local EXITING = false

--尝试切换主副角色
function BCBA:TrySwitch(player, force)
	EXITING = false
	local SUCCESS = false
	local tdata = self._Ents:GetTempData(player).BCBA

	if tdata and tdata.Twin then
		local player2 = tdata.Twin
		
		--检测副角色状态
		if player2:Exists() and not player2:IsDead() and (force or not player2:IsCoopGhost()) then
			local data = self:GetData(player)
			local data2 = self:GetData(player2)

			--副切主
			player2.Parent = nil
			player2:ClearEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK)
			player2:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
			player2:SetColor(Color(1,1,0,0.5,1,1,0), 30, 7, true, false)
			if data2.State == "Second" then data2.State = "Main" end
			
			--主切副
			player.Parent = player2
			player:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK)
			player:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
			if data.State == "Main" then data.State = "Second" end
			
			do --副角色临时移除模组主动
				for slot = 0,2 do
					local item = player:GetActiveItem(slot)
					local charges = 0
					
					if (item > 733) and not self.ExcludedActive[item] then 
						charges = self._Players:GetSlotCharges(player, slot, true, true)
						
						if (slot == 2) then
							player:SetPocketActiveItem(0, ActiveSlot.SLOT_POCKET)
						else
							player:RemoveCollectible(item, true, slot, false)
						end
					else
						item = 0
					end
					
					data.SavedActive[slot] = {Item = item, Charges = charges}
					
					local active2 = data2.SavedActive[slot]
					if active2 and (active2.Item > 0) then
						if (slot == 2) then
							player2:SetPocketActiveItem(active2.Item, ActiveSlot.SLOT_POCKET)
							player2:SetActiveCharge(active2.Charges, slot)
						else
							player2:AddCollectible(active2.Item, active2.Charges, false, slot)
						end	
					end
				end
			end			
			
			--刷新角色属性
			player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
			player2:AddCacheFlags(CacheFlag.CACHE_ALL, true)
			
			game:GetHUD():AssignPlayerHUDs()

			--屑官方的API还要面板变动才让更新道具列表
			--只能先用口水币安排一下了
			player2:AddSmeltedTrinket(32769, false)
			player2:TryRemoveSmeltedTrinket(32769)

			SUCCESS = true
		end
	end

	return SUCCESS
end

--接触时切换主副角色
function BCBA:CollisionSwitch(player)
	if game:GetRoom():GetFrameCount() < 15 then return end
	if not self:IsMainPlayer(player) then return end

	local other = self._Finds:ClosestEntity(player.Position, 1, 0, -1, function(ent)
		return ent:ToPlayer() and (not ent:ToPlayer():IsCoopGhost()) and (not self._Ents:IsTheSame(ent, player)) and (player.Position:DistanceSquared(ent.Position) <= 150)
	end)
	if not other then return end
	local data = self._Ents:GetTempData(player).BCBA

	if data and (data.SwitchTimeOut <= 0) and self:TrySwitch(player) then
		local tdata = self:GetTempData(player)
		tdata.SwitchTimeOut = 75
		local player2 = tdata.Twin
		
		if player2 and self._Ents:IsTheSame(other, player2) and player2:Exists() and not player2:IsDead() and not player2:IsCoopGhost() then
			local tdata2 = self:GetTempData(player2)
			tdata2.SwitchTimeOut = 75		
			player2:AddCacheFlags(CacheFlag.CACHE_ALL, true)
			player2:SetMinDamageCooldown(60)
		end

		player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
		player:SetMinDamageCooldown(60)
	end	
end
BCBA:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'CollisionSwitch')


--角色属性(部分已在xml中实现)
function BCBA:OnEvaluateCache(player, flag)
	local playerType = player:GetPlayerType()
	if playerType == (IBS_PlayerID.BCain) then
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 1.2
		end
	end	
	if playerType == (IBS_PlayerID.BAbel) then
		if flag == CacheFlag.CACHE_FIREDELAY then
			self._Stats:TearsMultiples(player, 1.2)
		end
	end
	
	--副角色幽灵泪
	if flag == CacheFlag.CACHE_TEARFLAG and self:IsSecondPlayer(player) then
		player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL
	end
end
BCBA:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, 'OnEvaluateCache')


--变身
function BCBA:Benighted(player, fromMenu)
	local CAN = false
	
	--检测幸运脚
	if player:HasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT) then	
		for slot = 0,1 do
			if player:GetTrinket(slot) == TrinketType.TRINKET_PAPER_CLIP then
				player:TryRemoveTrinket(TrinketType.TRINKET_PAPER_CLIP)
				break
			end
		end
		player:AddKeys(-1)
		player:RemoveCollectible(CollectibleType.COLLECTIBLE_ABEL, true)
		player:RemoveCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT, true)
		CAN = true
	end

	if CAN or fromMenu then
		player:ChangePlayerType(IBS_PlayerID.BCain)

		local tdata = self:GetTempData(player)
		local data = self:GetData(player)
		
		--生成副角色
		if not tdata.Twin and (data.TwinIndex == "") then
			local game = game
			Isaac.ExecuteCommand("addplayer "..tostring(IBS_PlayerID.BAbel).." "..tostring(player.ControllerIndex))

			local player2 = Isaac.GetPlayer(game:GetNumPlayers() - 1)
			local tdata2 = self:GetTempData(player2)
			local data2 = self:GetData(player2)
			

			player2:SetPocketActiveItem(IBS_ItemID.Goatify, ActiveSlot.SLOT_POCKET, false)
			player2.Position = player.Position
			player2.Velocity = Vector(7,0)
			player2.Parent = player
			player2:SetControllerIndex(player.ControllerIndex)
			tdata2.Twin = player
			data2.State = "Second"
			data2.TwinIndex = GetPlayerIndex(player)
			
			player:SetPocketActiveItem(IBS_ItemID.PortableFarm, ActiveSlot.SLOT_POCKET, false)
			player:SetColor(Color(1,1,0,0.5,1,1,0), 30, 7, true, false)
			player.Velocity = Vector(-7,0)
			tdata.Twin = player2
			data.State = "Main"
			data.TwinIndex = GetPlayerIndex(player2)
			data.Origin = true
			
			game:GetHUD():AssignPlayerHUDs()
			
			--完成挑战后生成伪忆
			if self:GetIBSData('persis')['bc3'] then
				local room = game:GetRoom()
				Isaac.Spawn(5, 300, mod.IBS_PocketID.BCain, room:FindFreePickupSpawnPosition(player2.Position + Vector(40,0), 0, true), Vector.Zero, nil)
				Isaac.Spawn(5, 300, mod.IBS_PocketID.BAbel, room:FindFreePickupSpawnPosition(player.Position + Vector(-40,0), 0, true), Vector.Zero, nil)
			end
			
			if not fromMenu then
				player:AddControlsCooldown(90)
				self:DelayFunction(function() player:AnimateAppear() end, 1)

				player2:AddControlsCooldown(90)
				self:DelayFunction(function() player2:AnimateAppear() end, 1)

				game:ShakeScreen(20)
				SFXManager():Play(SoundEffect.SOUND_LAZARUS_FLIP_DEAD)
				SFXManager():Play(SoundEffect.SOUND_LAZARUS_FLIP_ALIVE)
			end
		end
	end	
end
BCBA:AddCallback(IBS_CallbackID.BENIGHTED, 'Benighted', PlayerType.PLAYER_CAIN)

--更新
function BCBA:OnPlayerUpdate(player)
	local data = self._Players:GetData(player).BCBAInfo

	if data then
		local tdata = self:GetTempData(player)
		if tdata.SwitchTimeOut > 0 then tdata.SwitchTimeOut = tdata.SwitchTimeOut - 1 end
		if not tdata.Twin then tdata.Twin = GetPlayerByIndex(data.TwinIndex) end
		
		local player2 = tdata.Twin
		local MAIN = (data.State == "Main")
		local SECOND = (data.State == "Second")

		--副角色存在时,调整Parent
		if player2 and (player2:Exists() and not player2:IsDead()) then
			if MAIN and player.Parent then
				player.Parent = nil
			elseif SECOND and not player.Parent then
				player.Parent = player2
			end			
		end

		--主
		if MAIN then
			if tdata.InSecondFrameCount ~= 0 then tdata.InSecondFrameCount = 0 end
			
			--为鬼魂玩家时自动切换
			if (not EXITING) and player:IsCoopGhost() and player2 and player2:Exists() and not player2:IsDead() and not player2:IsCoopGhost() then
				self:TrySwitch(player)
			end
		end

		--副
		if SECOND and not player:IsCoopGhost() then
			local f = tdata.InSecondFrameCount
            player:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK)
			tdata.InSecondFrameCount = tdata.InSecondFrameCount + 1
			player:SetColor(Color(0.2,0.2,0.2, math.max(0.1, 0.8 - (f / 28 / 60))), 2, 100, false, true)

			--28秒前无敌
			if (f < 28*60) then
				player:SetMinDamageCooldown(2)
			end

			--每隔7秒提示一次
			if (f == 7*60) or (f == 14*60) or (f == 21*60) then
				sfx:Play(SoundEffect.SOUND_BEEP, 3, 0, false, 0.5)
				local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 0, player.Position, Vector.Zero, nil):ToEffect()
				poof.Parent = player
				poof:FollowParent(player)
			end

			--超过28秒后扣血
			if (f > 28*60) then
				player:TakeDamage(3, DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_IV_BAG, EntityRef(player), 30)
			end
		end
	end
end
BCBA:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')

--模拟清理房间充能
local function CleanChargeSimulation()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = BCBA._Players:GetData(player).BCBAInfo
		
		if data and data.SavedActive then
			for slot = 0,2 do
				local active = data.SavedActive[slot]
				
				if active and (active.Item > 0) then
					local itemConfig = config:GetCollectible(active.Item)
					local chargeType = itemConfig.ChargeType
					local normal = (chargeType == ItemConfig.CHARGE_NORMAL)
					local timed = (chargeType == ItemConfig.CHARGE_TIMED)
					
					if normal or timed then
						local maxCharges = itemConfig.MaxCharges
						
						if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
							maxCharges = maxCharges * 2
						end
						
						if active.Charges < maxCharges then
							if normal then
								active.Charges = active.Charges + 1
							elseif timed then
								active.Charges = math.min(active.Charges + itemConfig.MaxCharges, maxCharges)
							end

							if active.Charges >= maxCharges then
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
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CleanChargeSimulation)
mod:AddCallback(IBS_CallbackID.GREED_NEW_WAVE, CleanChargeSimulation)

--模拟自充
local function TimedChargeSimulation()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = BCBA._Players:GetData(player).BCBAInfo
		
		if data and data.SavedActive then
			for slot = 0,2 do
				local active = data.SavedActive[slot]
				
				if active and (active.Item > 0) then
					local itemConfig = config:GetCollectible(active.Item)
					local chargeType = itemConfig.ChargeType
					
					if (chargeType == ItemConfig.CHARGE_TIMED) then
						local maxCharges = itemConfig.MaxCharges
						
						if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
							maxCharges = maxCharges * 2
						end
						
						if active.Charges < maxCharges then
							active.Charges = active.Charges + 1
							
							if (active.Charges == maxCharges - 1) or (active.Charges == itemConfig.MaxCharges - 1) then
								sfx:Play(SoundEffect.SOUND_BEEP)
							end
						end
					end
				end
			end	
		end	
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, TimedChargeSimulation)

--必需修正
--在退出游戏时切换至初始角色(顺便刷新副角色状态时长),防止控制器判断出错导致无法进行游戏
local function NecessaryOffset()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = BCBA._Players:GetData(player).BCBAInfo

		if data then
			local tdata = BCBA:GetTempData(player)
			if (data.State == "Main") and not data.Origin then
				EXITING = true
				if tdata.Twin then
					player:SetControllerIndex(tdata.Twin.ControllerIndex)
				end
				BCBA:TrySwitch(player, true)
			end
			if (data.State == "Second") then
				if tdata.InSecondFrameCount ~= 0 then
					tdata.InSecondFrameCount = 0
				end
			end
		end
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, CallbackPriority.IMPORTANT, NecessaryOffset)

--必需修正2
--在使用创世纪时切换至非初始角色,防止其消失
local function NecessaryOffset2()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = BCBA._Players:GetData(player).BCBAInfo
		
		if data and (data.State == "Main") and data.Origin then
			BCBA:TrySwitch(player, true)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, NecessaryOffset2, CollectibleType.COLLECTIBLE_GENESIS)

--必需修正3
--在进入游戏时设置控制器ID
local function NecessaryOffset3()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = BCBA._Players:GetData(player).BCBAInfo
		if data and data.TwinIndex ~= '' and not data.Origin then
			local twin = GetPlayerByIndex(data.TwinIndex)
			if twin then
				player:SetControllerIndex(twin.ControllerIndex)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, NecessaryOffset3)

--新房间设置副角色位置
function BCBA:OnNewRoom()
	local room = game:GetRoom()
	local centerPos = room:GetCenterPos()
	
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		
		if self:IsSecondPlayer(player) and not self:AnyHasCollectible(player, CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			local pos = player.Position
			player.Position = room:FindFreePickupSpawnPosition(Vector(2*(centerPos.X) - pos.X , 2*(centerPos.Y) - pos.Y))
		end
	end
end
BCBA:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--摄像头位置修正
function BCBA:OnCameraUpdate()
	local players = PlayerManager.GetPlayers()
	for _,player in ipairs(players) do
		if self:IsMainPlayer(player) then
			local room = game:GetRoom()
			room:GetCamera():SetFocusPosition(player.Position)
			break
		end
	end
end
BCBA:AddCallback(ModCallbacks.MC_POST_UPDATE, 'OnCameraUpdate')
	
--死亡判定
function BCBA:OnPlayerKilled(ent)
	local player = ent:ToPlayer()
	
	if player and self._Players:GetData(player).BCBAInfo and (player:GetExtraLives() <= 0 or not player:WillPlayerRevive()) then
		local deathPosition = player.Position
		local data = self:GetData(player)		
		local tdata = self:GetTempData(player)
		local player2 = tdata.Twin
		--local data2 = (player2 and self:GetData(player2))
		-- local cachedItems = self._Players:GetPlayerCollectibles(player)
		-- local cachedDataActive = data.SavedActive
		-- local cachedActive = {}
		
		if player2 and player2:Exists() and not player2:IsDead() and not player2:IsCoopGhost() then
			self:TrySwitch(player)
			player:MorphToCoopGhost() --变为鬼魂玩家
		end

		--缓存主动道具
		-- for Slot = 0,1 do
			-- local item = player:GetActiveItem(Slot)
			-- local charges = 0
			
			-- if item > 0 then 
				-- charges = self._Players:GetSlotCharges(player, Slot, true, true)
			-- end
			
			-- cachedActive[Slot] = {Item = item, Charges = charges}
		-- end
		
		--延迟2秒,检测是否真的死亡(同时兼容部分模组复活效果)
		-- self:DelayFunction(function()
			-- if (not player:Exists()) or player:IsDead() then
				-- if player2 then
					-- player2:AnimateSad()
					-- player2:AddBrokenHearts(6)
					-- data2.Origin = true --变为初始角色
				-- end
				
				-- do --掉落主动道具
					-- for slot = 0,1 do
						-- local active = cachedDataActive[slot]
						
						-- if active and (active.Item > 0) then
							-- local item = active.Item
							-- local pos = game:GetRoom():FindFreePickupSpawnPosition(deathPosition, 0, true)
							-- local pickup = Isaac.Spawn(5, 100, item, pos, Vector.Zero, nil):ToPickup()

							-- pickup.Touched = true
							-- pickup:Morph(5, 100, item, false, false, true) --防止某些替换道具的效果
							-- pickup.Charge = active.Charges
							-- pickup.Wait = 60
						-- end
					-- end	
				-- end

				-- do --掉落主动道具
					-- for slot,active in pairs(cachedActive) do
						-- local item = active.Item
						
						-- if item > 0 then 
							-- local pos = game:GetRoom():FindFreePickupSpawnPosition(deathPosition, 0, true)
							-- local pickup = Isaac.Spawn(5, 100, item, pos, Vector.Zero, nil):ToPickup()
							
							-- pickup.Touched = true
							-- pickup:Morph(5, 100, item, false, false, true) --防止某些替换道具的效果
							-- pickup.Charge = active.Charges
							-- pickup.Wait = 60
						-- end
					-- end	
				-- end

				-- do --被动道具继承
					-- if player2 then
						-- for item,num in pairs(cachedItems) do
							-- if (config:GetCollectible(item).Type ~= ItemType.ITEM_ACTIVE) then
								-- for i = 1,num do
									-- player2:AddCollectible(item, 0, false)
								-- end
							-- end	
						-- end
					-- end	
				-- end
			-- end
		-- end, 60)
	end	
end
BCBA:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnPlayerKilled', EntityType.ENTITY_PLAYER)

--鬼魂玩家复活
function BCBA:ReviveGhostAfterBoss()
	if game:GetRoom():GetType() == RoomType.ROOM_BOSS then
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if (self:IsMainPlayer(player) or self:IsSecondPlayer(player)) and player:IsCoopGhost() then
				local data = self:GetTempData(player)
				data.InSecondFrameCount = 0
				player:ReviveCoopGhost()
				player:SetMinDamageCooldown(120)
				player:AddControlsCooldown(90)
			end
		end	
	end
end
BCBA:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'ReviveGhostAfterBoss')

function BCBA:ReviveGhostAfterBossWave(state)
	if state == 2 then
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if (self:IsMainPlayer(player) or self:IsSecondPlayer(player)) and player:IsCoopGhost() then
				local data = self:GetTempData(player)
				data.InSecondFrameCount = 0
				player:ReviveCoopGhost()
				player:SetMinDamageCooldown(120)
				player:AddControlsCooldown(90)
			end
		end	
	end
end
BCBA:AddCallback(IBS_CallbackID.GREED_WAVE_END_STATE, 'ReviveGhostAfterBossWave')



--操作
function BCBA:CheckInput(ent, hook, action)
	local player = (ent and ent:ToPlayer())
	
	if player then
		local Press = (hook == InputHook.IS_ACTION_PRESSED)
		local Trigger = (hook == InputHook.IS_ACTION_TRIGGERED)
		local GetValue = (hook == InputHook.GET_ACTION_VALUE)
		local cid = player.ControllerIndex
	
		--主角色按地图键立定
		if self:IsMainPlayer(player) and (action >= 0 and action <= 3) and Input.IsActionPressed(ButtonAction.ACTION_MAP, cid) then
			if Press or Trigger then
				return false
			elseif GetValue then
				return 0
			end
		end
	
		--副角色
		if self:IsSecondPlayer(player) then
			--无长子权则移动和射击操作反转
			if (action >= 0 and action <= 7) and GetValue and not self:AnyHasCollectible(player, CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
				return -Input.GetActionValue(action, cid)
			end
			
			--忽略副角色的操作(但只对原版有效,无法忽略模组的操作检测)
			if (action == ButtonAction.ACTION_ITEM) or (action == ButtonAction.ACTION_PILLCARD) or (action == ButtonAction.ACTION_DROP) then
				if Press or Trigger then
					return false
				elseif GetValue then
					return 0
				end
			end
		end	
	end
end
BCBA:AddPriorityCallback(ModCallbacks.MC_INPUT_ACTION, -9999, 'CheckInput')

--副角色无敌
function BCBA:PrePlayerTakeDMG(player, dmg, flag, source)
	if (source.Type ~= EntityType.ENTITY_SLOT) and self:IsSecondPlayer(player) and (GetInSecondFrameCount(player) < 28*60) then
		return false
	end
end
BCBA:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, -9999, 'PrePlayerTakeDMG')

--副角色无视障碍物
function BCBA:PrePlayerGridCollision(player)
	if self:IsSecondPlayer(player) and game:GetRoom():GetType() ~= RoomType.ROOM_DUNGEON then
		return true
	end
end
BCBA:AddCallback(ModCallbacks.MC_PRE_PLAYER_GRID_COLLISION, 'PrePlayerGridCollision')

--副角色无视碰撞
function BCBA:PrePlayerCollision(player, other)
	if self:IsSecondPlayer(player) then
		return true
	end
end
BCBA:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, -9999, 'PrePlayerCollision')

--副角色无视碰撞
function BCBA:PreOtherCollision(ent, other)
	local player = other:ToPlayer()
	if player and self:IsSecondPlayer(player) then
		return true
	end
end
BCBA:AddPriorityCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, -9999, 'PreOtherCollision')
BCBA:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_COLLISION, -9999, 'PreOtherCollision')
BCBA:AddPriorityCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, -9999, 'PreOtherCollision')
BCBA:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, -9999, 'PreOtherCollision')
BCBA:AddPriorityCallback(ModCallbacks.MC_PRE_SLOT_COLLISION, -9999, 'PreOtherCollision')

--副角色禁用炸弹
function BCBA:PreUseBomb(player)
	if self:IsSecondPlayer(player) then
		return false
	end
end
BCBA:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_USE_BOMB, -9999, 'PreUseBomb')

return BCBA