--打标系统

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local IBS_Player = mod.IBS_Player
local EggBlackList = mod.EggBlackList
local BigBooks = mod.IBS_Lib.BigBooks

local LANG = Options.Language


--对应成就贴图
local Paper = {

[IBS_Player.bisaac] = {
	IBSL = "bottleshard",
	MegaSatan = "czd6",
	BRH = "bc1",
	Delirium = "lightd6",
	Witness = "dadspromise",
	Beast = "nop",
	Greed = "ssg",
	FINISHED = "temperance_boss"
},

[IBS_Player.bmaggy] = {
	IBSL = "divineretaliation",
	MegaSatan = nil,
	BRH = nil,
	Delirium = "gheart",
	Witness = "toughheart",
	Beast = nil,
	Greed = nil,
	FINISHED = nil
},

}

--将角色ID转换为字符串索引
local PlayerTypeToKey = {
	[IBS_Player.bisaac] = "bisaac",
	[IBS_Player.bmaggy] = "bmaggy",
}
local function ToKey(playerType)
	local key = PlayerTypeToKey[playerType]

	return key or "NILLLLLLLLLLLLLLLLLL"
end




--播放成就纸张动画
local function ShowPaper(playerType, mode)
	local paper = "TEST"

	--以撒,蓝人,撒旦,羔羊
	if mode == "IBSL" then
		paper = Paper[playerType].IBSL
		
	--超级撒旦	
	elseif mode == "MegaSatan" then
		paper = Paper[playerType].MegaSatan
		
	--Boss车轮战,死寂	
	elseif mode == "BRH" then
		paper = Paper[playerType].BRH
		
	--精神错乱	
	elseif mode == "Delirium" then
		paper = Paper[playerType].Delirium
		
	--见证者	
	elseif mode == "Witness" then
		paper = Paper[playerType].Witness
	
	--祸兽
	elseif mode == "Beast" then
		paper = Paper[playerType].Beast
		
	--贪婪	
	elseif mode == "Greed" then
		paper = Paper[playerType].Greed
		
	--全部完成
	elseif mode == "FINISHED" then
		paper = Paper[playerType].FINISHED		
	end
	
	paper = paper or "TEST"
	
	--检测语言
	if LANG == "zh" then
		paper = paper.."_zh"
	end
	
	paper = paper..".png"	
	BigBooks:PlayPaper(paper)
end

--获得标记条件
local function IsMarkable(bossLevel)
	local notInChallenge = Isaac.GetChallenge() <= 0
	local notCustomSeed = Game():GetSeeds():IsCustomRun() == false
	local notInLap = Game():GetVictoryLap() <= 0
	local hardMode = (Game().Difficulty == 1) or (Game().Difficulty == 3)
	local bossRoom = (Game():GetRoom():GetType() == RoomType.ROOM_BOSS) or (Game():GetRoom():GetType() == RoomType.ROOM_BOSSRUSH)
	local level = Game():GetLevel():GetStage()
	
	--考虑不能达成成就的彩蛋种子
	for _,egg in ipairs(EggBlackList) do
		if (Game():GetSeeds():HasSeedEffect(egg)) then
			return false
		end
	end
	
	--非自定种子,非挑战,非跑圈,困难
	if notCustomSeed and notInChallenge and notInLap and hardMode then
		if bossLevel then --Boss房和楼层判定
			if bossRoom and level == bossLevel then
				return true
			end
		else
			return true
		end	
	end

	return false
end



do --标记提示器(硬核还原)
	local function GetScreenSize()	--获取屏幕尺寸
		local room = Game():GetRoom()
		local pos = Isaac.WorldToScreen(Vector(0,0)) - room:GetRenderScrollOffset() - Game().ScreenShakeOffset
		
		local rx = pos.X + 60 * 26 / 40
		local ry = pos.Y + 140 * (26 / 40)
		
		return rx*2 + 13*26, ry*2 + 7*26
	end

	--状态表
	local states = {
		["UNPAUSED"] = {
			Hide = true,
			[ButtonAction.ACTION_PAUSE] = "RESUME",
			[ButtonAction.ACTION_MENUBACK] = "RESUME",
			[Keyboard.KEY_GRAVE_ACCENT] = "IN_CONSOLE",
		},
		["UNPAUSING"] = {},
		["UNPAUSING_HIDDEN"] = { Hide = true },
		["OPTIONS"] = {
			[ButtonAction.ACTION_PAUSE] = "UNPAUSING",
			[ButtonAction.ACTION_MENUBACK] = "UNPAUSING",
			[ButtonAction.ACTION_MENUCONFIRM] = "IN_OPTIONS",
			[ButtonAction.ACTION_MENUDOWN] = "RESUME",
			[ButtonAction.ACTION_MENUUP] = "EXIT",
			[Keyboard.KEY_GRAVE_ACCENT] = "UNPAUSING",
		},
		["RESUME"] = {
			[ButtonAction.ACTION_PAUSE] = "UNPAUSING",
			[ButtonAction.ACTION_MENUBACK] = "UNPAUSING",
			[ButtonAction.ACTION_MENUCONFIRM] = "UNPAUSING",
			[ButtonAction.ACTION_MENUDOWN] = "EXIT",
			[ButtonAction.ACTION_MENUUP] = "OPTIONS",
			[Keyboard.KEY_GRAVE_ACCENT] = "UNPAUSING",
		},
		["EXIT"] = {
			[ButtonAction.ACTION_PAUSE] = "UNPAUSING",
			[ButtonAction.ACTION_MENUBACK] = "UNPAUSING",
			[ButtonAction.ACTION_MENUDOWN] = "OPTIONS",
			[ButtonAction.ACTION_MENUUP] = "RESUME",
			[Keyboard.KEY_GRAVE_ACCENT] = "UNPAUSING",
		},
		["IN_OPTIONS"] = {
			Hide = true,
			Ignore = ButtonAction.ACTION_PAUSE,
			[ButtonAction.ACTION_MENUBACK] = "OPTIONS",
			[Keyboard.KEY_GRAVE_ACCENT] = "UNPAUSING_HIDDEN",
		},
		["IN_CONSOLE"] = {
			Hide = true,
			[ButtonAction.ACTION_PAUSE] = "IN_CONSOLE",
			[ButtonAction.ACTION_MENUBACK] = "UNPAUSED",
		},
	}

	local currentState = "UNPAUSED"

	--更新状态
	local function UpdateState()
		local cid = Game():GetPlayer(0).ControllerIndex
		if not Game():IsPaused() then
			currentState = "UNPAUSED"
			return ""
		end
		if states[currentState].Ignore and Input.IsActionTriggered(states[currentState].Ignore, cid) then
			return ""
		end
		for buttonAction, state in pairs(states[currentState]) do
			if type(buttonAction) == "number" and (Input.IsActionTriggered(buttonAction, cid) or Input.IsButtonTriggered(buttonAction, cid)) then
				currentState = state
				return "" 
			end
		end
	end

	local reminder = Sprite()
	reminder:Load("gfx/ibs/ui/achievements/marks.anm2", true)
	reminder:Play("Out",false)
	
	--[[动画ID:
		0 - 纸
		1 - 精神错乱纸
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
	local function ReminderRender(_,shaderName)
		if shaderName ~= "IBS_Empty" then return end
		local playerType = Isaac.GetPlayer(0):GetPlayerType()
		local X,Y = GetScreenSize()
		local pos = Vector(X/3.1, Y/5.8)
		local NULL = ""	
		--reminder.Scale = Vector(0.6,0.6)
		
		if (Isaac.GetFrameCount() % 2 == 0) then
			reminder:Update()
		end
		
		if IBS_Data.Setting[ToKey(playerType)] and IsMarkable() then
			NULL = UpdateState()
			if currentState == "UNPAUSING" or not Game():IsPaused() then
				reminder:Play("Out",false)
			elseif not states[currentState].Hide then
				reminder:Play("In",false)
			end
			
			if IBS_Data.Setting[ToKey(playerType)].Delirium then
				reminder:RenderLayer(1,pos)
			else
				reminder:RenderLayer(0,pos)
			end
			
			if IBS_Data.Setting[ToKey(playerType)].Heart then
				reminder:RenderLayer(2,pos)
			end			
			if IBS_Data.Setting[ToKey(playerType)].Isaac then
				reminder:RenderLayer(3,pos)
			end				
			if IBS_Data.Setting[ToKey(playerType)].Satan then
				reminder:RenderLayer(4,pos)
			end
			if IBS_Data.Setting[ToKey(playerType)].BossRush then
				reminder:RenderLayer(5,pos)
			end
			if IBS_Data.Setting[ToKey(playerType)].BlueBaby then
				reminder:RenderLayer(6,pos)
			end			
			if IBS_Data.Setting[ToKey(playerType)].Lamb then
				reminder:RenderLayer(7,pos)
			end
			if IBS_Data.Setting[ToKey(playerType)].MegaSatan then
				reminder:RenderLayer(8,pos)
			end			
			if IBS_Data.Setting[ToKey(playerType)].Greed then
				reminder:RenderLayer(9,pos)
			end
			if IBS_Data.Setting[ToKey(playerType)].Hush then
				reminder:RenderLayer(10,pos)
			end	
			if IBS_Data.Setting[ToKey(playerType)].Witness then
				reminder:RenderLayer(11,pos)
			end			
			if IBS_Data.Setting[ToKey(playerType)].Beast then
				reminder:RenderLayer(12,pos)
			end
		else
			reminder:Play("Out",false)
		end
	end
	mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, ReminderRender)
end




--尝试完成
local function TryFinish(playerType)
	if IBS_Data.Setting[ToKey(playerType)] then
		if not IBS_Data.Setting[ToKey(playerType)].FINISHED and (IBS_Data.Setting[ToKey(playerType)].Heart) and
		(IBS_Data.Setting[ToKey(playerType)].Isaac and IBS_Data.Setting[ToKey(playerType)].BlueBaby and IBS_Data.Setting[ToKey(playerType)].Satan and IBS_Data.Setting[ToKey(playerType)].Lamb) and
		(IBS_Data.Setting[ToKey(playerType)].MegaSatan) and (IBS_Data.Setting[ToKey(playerType)].BossRush and IBS_Data.Setting[ToKey(playerType)].Hush) and
		(IBS_Data.Setting[ToKey(playerType)].Delirium) and (IBS_Data.Setting[ToKey(playerType)].Witness) and (IBS_Data.Setting[ToKey(playerType)].Beast) and (IBS_Data.Setting[ToKey(playerType)].Greed) then
			ShowPaper(playerType, "FINISHED")
			IBS_Data.Setting[ToKey(playerType)].FINISHED = true
		end
	end
end

--心脏标记
local function Mark_Heart()
	if IsMarkable(8) then
		for i = 0, Game():GetNumPlayers() -1 do
			local playerType = Isaac.GetPlayer(i):GetPlayerType()
			if IBS_Data.Setting[ToKey(playerType)] then
				IBS_Data.Setting[ToKey(playerType)].Heart = true
				TryFinish(playerType)
				mod:SaveIBSData()
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Mark_Heart, EntityType.ENTITY_MOMS_HEART)

--以撒和蓝人标记
local function Mark_Isaac_And_BlueBaby()
	if IsMarkable(10) then
		for i = 0, Game():GetNumPlayers() -1 do
			local playerType = Isaac.GetPlayer(i):GetPlayerType()
			if IBS_Data.Setting[ToKey(playerType)] then
				if not IBS_Data.Setting[ToKey(playerType)].Isaac and (IBS_Data.Setting[ToKey(playerType)].BlueBaby and IBS_Data.Setting[ToKey(playerType)].Satan and IBS_Data.Setting[ToKey(playerType)].Lamb) then
					ShowPaper(playerType, "IBSL")
				end
				IBS_Data.Setting[ToKey(playerType)].Isaac = true
				TryFinish(playerType)
				mod:SaveIBSData()
			end
		end
	elseif IsMarkable(11) then
		for i = 0, Game():GetNumPlayers() -1 do
			local playerType = Isaac.GetPlayer(i):GetPlayerType()
			if IBS_Data.Setting[ToKey(playerType)] then
				if not IBS_Data.Setting[ToKey(playerType)].BlueBaby and (IBS_Data.Setting[ToKey(playerType)].Isaac and IBS_Data.Setting[ToKey(playerType)].Satan and IBS_Data.Setting[ToKey(playerType)].Lamb) then
					ShowPaper(playerType, "IBSL")
				end
				IBS_Data.Setting[ToKey(playerType)].BlueBaby = true
				TryFinish(playerType)
				mod:SaveIBSData()
			end
		end
	end			
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Mark_Isaac_And_BlueBaby, EntityType.ENTITY_ISAAC)

--撒旦标记
local function Mark_Satan()
	if Game():GetRoom():GetBossID() == 24 then
		if IsMarkable(10) then
			for i = 0, Game():GetNumPlayers() -1 do
				local playerType = Isaac.GetPlayer(i):GetPlayerType()
				if IBS_Data.Setting[ToKey(playerType)] then
					if not IBS_Data.Setting[ToKey(playerType)].Satan and (IBS_Data.Setting[ToKey(playerType)].Isaac and IBS_Data.Setting[ToKey(playerType)].BlueBaby and IBS_Data.Setting[ToKey(playerType)].Lamb) then
						ShowPaper(playerType, "IBSL")
					end
					IBS_Data.Setting[ToKey(playerType)].Satan = true
					TryFinish(playerType)
					mod:SaveIBSData()
				end
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, Mark_Satan)

--羔羊标记
local function Mark_Lamb()
	if IsMarkable(11) then
		for i = 0, Game():GetNumPlayers() -1 do
			local playerType = Isaac.GetPlayer(i):GetPlayerType()
			if IBS_Data.Setting[ToKey(playerType)] then
				if not IBS_Data.Setting[ToKey(playerType)].Lamb and (IBS_Data.Setting[ToKey(playerType)].Isaac and IBS_Data.Setting[ToKey(playerType)].BlueBaby and IBS_Data.Setting[ToKey(playerType)].Satan) then
					ShowPaper(playerType, "IBSL")
				end
				IBS_Data.Setting[ToKey(playerType)].Lamb = true
				TryFinish(playerType)
				mod:SaveIBSData()
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Mark_Lamb, EntityType.ENTITY_THE_LAMB)

--超级撒旦标记
local function Mark_MegaSatan()
	if IsMarkable(11) then
		for i = 0, Game():GetNumPlayers() -1 do
			local playerType = Isaac.GetPlayer(i):GetPlayerType()
			if IBS_Data.Setting[ToKey(playerType)] then
				if not IBS_Data.Setting[ToKey(playerType)].MegaSatan then
					ShowPaper(playerType, "MegaSatan")
				end
				IBS_Data.Setting[ToKey(playerType)].MegaSatan = true
				TryFinish(playerType)
				mod:SaveIBSData()
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Mark_MegaSatan, EntityType.ENTITY_MEGA_SATAN_2)

--Boss车轮战标记
local function Mark_BossRush()
	local Room = Game():GetRoom()
	if (Room:GetType() == RoomType.ROOM_BOSSRUSH) and (Room:IsAmbushDone()) then
		if IsMarkable(6) then
			for i = 0, Game():GetNumPlayers() -1 do
				local playerType = Isaac.GetPlayer(i):GetPlayerType()
				if IBS_Data.Setting[ToKey(playerType)] then
					if not IBS_Data.Setting[ToKey(playerType)].BossRush and IBS_Data.Setting[ToKey(playerType)].Hush then
						ShowPaper(playerType, "BRH")
					end
					IBS_Data.Setting[ToKey(playerType)].BossRush = true
					TryFinish(playerType)
					mod:SaveIBSData()
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, Mark_BossRush)

--死寂标记
local function Mark_Hush()
	if IsMarkable(9) then
		for i = 0, Game():GetNumPlayers() -1 do
			local playerType = Isaac.GetPlayer(i):GetPlayerType()
			if IBS_Data.Setting[ToKey(playerType)] then
				if not IBS_Data.Setting[ToKey(playerType)].Hush and IBS_Data.Setting[ToKey(playerType)].BossRush then
					ShowPaper(playerType, "BRH")
				end
				IBS_Data.Setting[ToKey(playerType)].Hush = true
				TryFinish(playerType)
				mod:SaveIBSData()
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Mark_Hush, EntityType.ENTITY_HUSH)

--精神错乱标记
local function Mark_Delirium()
	if IsMarkable(12) then
		for i = 0, Game():GetNumPlayers() -1 do
			local playerType = Isaac.GetPlayer(i):GetPlayerType()
			if IBS_Data.Setting[ToKey(playerType)] then
				if not IBS_Data.Setting[ToKey(playerType)].Delirium then
					ShowPaper(playerType, "Delirium")
				end
				IBS_Data.Setting[ToKey(playerType)].Delirium = true
				TryFinish(playerType)
				mod:SaveIBSData()				
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Mark_Delirium, EntityType.ENTITY_DELIRIUM)

--见证者标记
local function Mark_Witness()
	if Game():GetRoom():GetBossID() == 88 then
		if IsMarkable(8) then
			for i = 0, Game():GetNumPlayers() -1 do
				local playerType = Isaac.GetPlayer(i):GetPlayerType()
				if IBS_Data.Setting[ToKey(playerType)] then
					if not IBS_Data.Setting[ToKey(playerType)].Witness then
						ShowPaper(playerType, "Witness")
					end
					IBS_Data.Setting[ToKey(playerType)].Witness = true
					TryFinish(playerType)
					mod:SaveIBSData()
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, Mark_Witness)

--祸兽标记
local function Mark_Beast(_,ent)
	if ent.Variant == 0 and ent.SubType == 0 then
		if IsMarkable() then
			for i = 0, Game():GetNumPlayers() -1 do
				local playerType = Isaac.GetPlayer(i):GetPlayerType()
				if IBS_Data.Setting[ToKey(playerType)] then
					if not IBS_Data.Setting[ToKey(playerType)].Beast then
						ShowPaper(playerType, "Beast")
					end
					IBS_Data.Setting[ToKey(playerType)].Beast = true
					TryFinish(playerType)
					mod:SaveIBSData()
				end
			end
		end	
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, Mark_Beast, EntityType.ENTITY_BEAST)

--贪婪标记
local function Mark_Greed()
	if Game():IsGreedMode() then
		if Game():GetRoom():GetBossID() == 62 then
			if IsMarkable(7) then
				for i = 0, Game():GetNumPlayers() -1 do
					local playerType = Isaac.GetPlayer(i):GetPlayerType()
					if IBS_Data.Setting[ToKey(playerType)] then
						if not IBS_Data.Setting[ToKey(playerType)].Greed then
							ShowPaper(playerType, "Greed")
						end
						IBS_Data.Setting[ToKey(playerType)].Greed = true
						TryFinish(playerType)
						mod:SaveIBSData()
					end
				end
			end
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, Mark_Greed)
