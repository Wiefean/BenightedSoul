--角色通关标记Class

--[[
"PlayerKey"指的是数据存读系统中对应的角色索引

"info_tbl"可包含内容:
{
	Heart, --心脏
	Isaac, --以撒
	BlueBaby, --蓝人
	Satan, --撒旦
	Lamb, --羔羊
	MegaSatan, --超级撒旦
	BossRush, --车轮战
	Hush, --死寂
	Delirium, --精神错乱
	Witness, --见证者
	Beast, --祸兽
	Greed, --贪婪
	FINISHED, --全红
}

以上元素的通用模版:
{

--成就贴图名
PaperNames = {
	'贴图名',
	'贴图名',
	'贴图名',
	...
}, 

Items, --解锁的道具(表)
Trinkets, --解锁的饰品(表)
Pockets, --解锁的口袋物品(表)
}

]]

local mod = Isaac_BenightedSoul

local Component = mod.IBS_Class.Component

local game = Game()

--Boss信息(用于检查是否能获得标记)
local BossInfo = {
	Heart = {Stage = 8}, --心脏
	Isaac = {Stage = 10, BossID = BossType.ISAAC}, --以撒
	BlueBaby = {Stage = 11, BossID = BossType.BLUE_BABY}, --蓝人
	Satan = {Stage = 10, BossID = BossType.SATAN}, --撒旦
	Lamb = {Stage = 11, BossID = BossType.LAMB}, --羔羊
	MegaSatan = {Stage = 11, BossID = BossType.MEGA_SATAN}, --超级撒旦
	Hush = {Stage = 9, BossID = BossType.HUSH}, --死寂
	Delirium = {Stage = 12, BossID = BossType.DELIRIUM}, --精神错乱
	Witness = {Stage = 8, BossID = BossType.MOTHER}, --见证者
	Beast = {Stage = 13}, --祸兽
	Greed = {Stage = 7, BossID = BossType.ULTRA_GREED}, --贪婪
}

local Marks = mod.Class(Component, function(self, playerID, info_tbl)
	Component._ctor(self)

	self.PlayerID = playerID
	self.PlayerKey = mod.IBS_PlayerID._ToKey(playerID)
	self.Info = info_tbl or {}

	--获取数据
	function self:GetData()
		return self:GetIBSData('persis')[self.PlayerKey]
	end

	--是否已解锁
	function self:IsUnlocked(mark)
		return self:GetData()[mark]
	end

	--是否未解锁
	function self:IsLocked(mark)
		return (not self:GetData()[mark])
	end

	--锁
	function self:Lock(mark, instantSave)
		self:GetData()[mark] = false
		
		--即时保存
		if instantSave then
			self:SaveIBSData()
		end
	end

	--解锁
	function self:Unlock(mark, showPaper, instantSave)
		self:GetData()[mark] = true

		--弹出纸张
		if showPaper and self.Info[mark] and self.Info[mark].PaperNames then
			for _,v in pairs(self.Info[mark].PaperNames) do
				self._Screens:PlayPaper(v)
			end
		end
		
		--即时保存
		if instantSave then
			self:SaveIBSData()
		end		
	end	


	--将未解锁物品从池中移除
	function self:RemoveTheLockedFromPool(isContinue)
		if not isContinue then
			local itemPool = game:GetItemPool()
		
			for mark,v in pairs(self.Info) do
				if self:IsLocked(mark) then
					if v.Items then --道具
						for _,id in pairs(v.Items) do
							itemPool:RemoveCollectible(id)
						end				
					end
					if v.Trinkets then --饰品
						for _,id in pairs(v.Trinkets) do
							itemPool:RemoveTrinket(id)
						end
					end						
				end
			end
		end
	end
	self:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.IMPORTANT, 'RemoveTheLockedFromPool')


	--避免从池中抽取未解锁道具
	function self:AvoidLockedItems(id, pool, decrease, seed)
		for mark,v in pairs(self.Info) do
			if self:IsLocked(mark) and v.Items then
				for _,_id in pairs(v.Items) do
					if _id == id then
						local itemPool = game:GetItemPool()
						itemPool:RemoveCollectible(id)
						return itemPool:GetCollectible(pool, decrease, seed)
					end
				end
			end
		end
	end
	self:AddPriorityCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, CallbackPriority.IMPORTANT, 'AvoidLockedItems')

	--避免从池中抽取未解锁饰品
	function self:AvoidLockedTrinkets(id)
		for mark,v in pairs(self.Info) do
			if self:IsLocked(mark) and v.Trinkets then
				for _,_id in pairs(v.Trinkets) do
					if _id == id then
						local itemPool = game:GetItemPool()
						itemPool:RemoveTrinket(id)
						return itemPool:GetTrinket()
					end
				end
			end
		end
	end
	self:AddPriorityCallback(ModCallbacks.MC_GET_TRINKET, CallbackPriority.IMPORTANT, 'AvoidLockedTrinkets')


	--避免从池中抽取未解锁口袋物品
	function self:AvoidLockedPockets(rng, id, includePlayingCards, includeRunes, onlyRunes)
		for mark,v in pairs(self.Info) do
			if self:IsLocked(mark) and v.Pockets then
				for _,_id in pairs(v.Pockets) do
					if _id == id then
						local itemPool = game:GetItemPool()
						return itemPool:GetCard(rng:Next(), includePlayingCards, includeRunes, onlyRunes)
					end
				end
			end
		end
	end
	self:AddPriorityCallback(ModCallbacks.MC_GET_CARD, CallbackPriority.IMPORTANT, 'AvoidLockedPockets')


	------------------
	--以下为打标系统--
	------------------


	--是否能解锁
	function self:CanUnlock(mark)
		if game:AchievementUnlocksDisallowed() then
			return false
		end

		--已解锁的情况下也返回false
		if self:IsUnlocked(mark) then
			return false
		end

		--困难才能打标(偷懒)
		local diffculty = game.Difficulty
		if diffculty ~= Difficulty.DIFFICULTY_HARD and diffculty ~= Difficulty.DIFFICULTY_GREEDIER then
			return false
		end


		local info = BossInfo[mark] or {}
		local room = game:GetRoom()
		local roomType = game:GetRoom():GetType()

		--检测房间和楼层是否正确
		if mark ~= 'BossRush' and mark ~= 'Beast' and roomType ~= RoomType.ROOM_BOSS then
			return false
		end		
		if mark == 'BossRush' and (roomType ~= RoomType.ROOM_BOSSRUSH or not room:IsAmbushDone()) then
			return false
		end
		if info.BossID and info.BossID ~= room:GetBossID() then
			return false
		end
		if info.Stage and info.Stage ~= game:GetLevel():GetStage() then
			return false
		end

		--贪婪标记只有贪婪模式能拿
		if mark == 'Greed' and not game:IsGreedMode() then
			return false
		end

		return true
	end

	--全红检测
	function self:TryFinish()
		if self:IsLocked('FINISHED') then
			local canFinish = true
			
			for k,v in pairs(self:GetData()) do
				if k ~= 'Unlocked' and k ~= 'FINISHED' and v == false then
					canFinish = false
					break
				end
			end

			if canFinish then
				self:Unlock('FINISHED', true, true)
			end
		end
	end	

	--尝试解锁
	function self:TryUnlock(mark)
		if self:CanUnlock(mark) then
			for i = 0, game:GetNumPlayers() -1 do
				if Isaac.GetPlayer(i):GetPlayerType() == self.PlayerID then
					self:Unlock(mark, true, true)
					self:TryFinish()
					break
				end
			end
		end		
	end


	--心脏标记
	function self:Mark_Heart()
		self:TryUnlock('Heart')
	end
	self:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, 'Mark_Heart', EntityType.ENTITY_MOMS_HEART)

	--以撒和蓝人标记
	function self:Mark_Isaac_BlueBaby(ent)
		local variant = ent.Variant
	
		if variant == 0 then
			self:TryUnlock('Isaac')
		elseif variant == 1 then
			self:TryUnlock('BlueBaby')
		end			
	end
	self:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, 'Mark_Isaac_BlueBaby', EntityType.ENTITY_ISAAC)

	--撒旦标记
	function self:Mark_Satan()
		self:TryUnlock('Satan')
	end
	self:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'Mark_Satan')

	--羔羊标记
	function self:Mark_Lamb()
		self:TryUnlock('Lamb')
	end
	self:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, 'Mark_Lamb', EntityType.ENTITY_THE_LAMB)

	--超级撒旦标记
	function self:Mark_MegaSatan()
		self:TryUnlock('MegaSatan')
	end
	self:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'Mark_MegaSatan', EntityType.ENTITY_MEGA_SATAN_2)
	self:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, 'Mark_MegaSatan', EntityType.ENTITY_MEGA_SATAN_2)

	--车轮战标记
	function self:Mark_BossRush()
		self:TryUnlock('BossRush')
	end
	self:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'Mark_BossRush')

	--死寂标记
	function self:Mark_Hush()
		self:TryUnlock('Hush')
	end
	self:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, 'Mark_Hush', EntityType.ENTITY_HUSH)

	--精神错乱标记
	function self:Mark_Delirium()
		self:TryUnlock('Delirium')
	end
	self:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, 'Mark_Delirium', EntityType.ENTITY_DELIRIUM)

	--见证者标记
	function self:Mark_Witness()
		self:TryUnlock('Witness')
	end
	self:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'Mark_Witness')

	--祸兽标记
	function self:Mark_Beast(ent)
		if ent.Variant == 0 and ent.SubType == 0 then
			self:TryUnlock('Beast')
		end	
	end
	self:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'Mark_Beast', EntityType.ENTITY_BEAST)
	self:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, 'Mark_Beast', EntityType.ENTITY_BEAST)

	--贪婪标记
	function self:Mark_Greed()
		self:TryUnlock('Greed')
	end
	self:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'Mark_Greed')

end, { {expectedType = 'number'}, {expectedType = 'table', allowNil = true} })



do --标记提示(硬核还原)

local reminder = Sprite('gfx/ibs/ui/achievements/marks.anm2')
reminder:SetFrame("Out", 8)

--[[动画层:
	0 - 背景纸张
	1 - 精神错乱背景纸张
	2 - 心脏
	3 - 以撒
	4 - 撒旦
	5 - BR
	6 - 蓝人
	7 - 羔羊
	8 - 超级撒旦
	9 - 贪婪
	10 - 死寂
	11 - 见证者
	12 - 祸兽
]]

--渲染
local function ReminderRender()
	--困难才能打标(偷懒)
	local diffculty = game.Difficulty
	if diffculty ~= Difficulty.DIFFICULTY_HARD and diffculty ~= Difficulty.DIFFICULTY_GREEDIER then
		return
	end

	local KEY = mod.IBS_PlayerID._ToKey(Isaac.GetPlayer(0):GetPlayerType())
	local marks = mod:GetIBSData('persis')[KEY]

	--检测玩家一是否为对应角色,以及当前状态是否能解锁成就
	if marks and not game:AchievementUnlocksDisallowed() then
		local X,Y = Isaac.GetScreenWidth(),Isaac.GetScreenHeight()
		local pos = Vector(X/3.1, Y/5.8)
		local pauseState = game:GetPauseMenuState()

		--在暂停页面显示提示器
		if game:IsPauseMenuOpen() then
			reminder:Play("In", false)

			--在关闭暂停页面后不要重新播放进入动画
			if (pauseState == PauseMenuStates.OPTIONS) then
				reminder:SetFrame("In", 8)
			end
		else
			reminder:Play("Out", false)
		end
		
		--不在设置界面才显示
		if (pauseState ~= PauseMenuStates.OPTIONS) then
			if marks.Delirium then
				reminder:RenderLayer(1,pos)
			else
				reminder:RenderLayer(0,pos)
			end
			
			if marks.Heart then
				reminder:RenderLayer(2,pos)
			end			
			if marks.Isaac then
				reminder:RenderLayer(3,pos)
			end				
			if marks.Satan then
				reminder:RenderLayer(4,pos)
			end
			if marks.BossRush then
				reminder:RenderLayer(5,pos)
			end
			if marks.BlueBaby then
				reminder:RenderLayer(6,pos)
			end			
			if marks.Lamb then
				reminder:RenderLayer(7,pos)
			end
			if marks.MegaSatan then
				reminder:RenderLayer(8,pos)
			end			
			if marks.Greed then
				reminder:RenderLayer(9,pos)
			end
			if marks.Hush then
				reminder:RenderLayer(10,pos)
			end	
			if marks.Witness then
				reminder:RenderLayer(11,pos)
			end			
			if marks.Beast then
				reminder:RenderLayer(12,pos)
			end
		end	
	else
		reminder:SetFrame("Out", 8) --不是对应人物时候隐藏提示器
	end
	
	--更新动画
	if (Isaac.GetFrameCount() % 2 == 0) then
		reminder:Update()
	end	
end
mod:AddCallback(mod.IBS_CallbackID.RENDER_OVERLAY, ReminderRender)

end




return Marks





