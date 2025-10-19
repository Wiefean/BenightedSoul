--角色菜单

local mod = Isaac_BenightedSoul
local zh = (mod.Language == 'zh')
local IBS_ChallengeID = mod.IBS_ChallengeID
local IBS_PlayerKey = mod.IBS_PlayerKey

--获取修正后位置
local function GetFixedPos(pos)
	return Isaac.WorldToMenuPosition(MainMenuType.CHARACTER, pos)
end

local show = false
local music = Isaac.GetMusicIdByName('愚昧角色菜单')

--按键提示
local widget = Sprite('gfx/ibs/ui/main menu/widget.anm2')
widget:Play('Idle')

--角色菜单
local menu = Sprite('gfx/ibs/ui/main menu/book.anm2')
menu.Scale = Vector(1.5, 1.5)
menu:Play('Idle')

--滤镜
local filter = Sprite('gfx/ibs/ui/main menu/filter.anm2')
filter.Scale = Vector(2, 2)
filter:SetFrame('Out', 99)

--角色图标
local portrait = Sprite('gfx/ibs/ui/main menu/characterportraits.anm2')
portrait:Play('Unknown')

--箭头旁的小角色图标
local lastPortrait = Sprite('gfx/ibs/ui/main menu/characterportraits.anm2')
lastPortrait:Play('Unknown')
lastPortrait.Scale = Vector(0.5, 0.5)
local nextPortrait = Sprite('gfx/ibs/ui/main menu/characterportraits.anm2')
nextPortrait:Play('Unknown')
nextPortrait.Scale = Vector(0.5, 0.5)

--通关标记提示
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
local reminder = Sprite('gfx/ibs/ui/achievements/marks.anm2')
reminder:SetFrame("In", 99)

local show = false --展示菜单
local lastInMenu = false --上一帧在角色菜单
local wait = 0 --等待时间
local Y = 300
local primaryY = 300 --角色菜单初始纵轴位置
local finalY = -60 --角色菜单最终纵轴位置

--物品槽图标
local slot = Sprite('gfx/ibs/ui/main menu/icons.anm2')
slot:Play('Slot')

--字体
local color = KColor(55/255, 43/255, 45/255, 1)
local fnt = Font('font/teammeatfontextended10.fnt')
local fntBold = Font('font/teammeatfontextended16bold.fnt')
if not zh then
	fnt = Font('font/teammeatfont10.fnt')
	fntBold = Font('font/teammeatfont16bold.fnt')
end

--角色锁
local lock = mod.IBS_Achiev.CharacterLock

local info_zh = {
	[0] = {
		Portrait = {Anim = 'Unknown'},
		Name = {Str = '未知'},
	},
	[1] = {
		PlayerKey = IBS_PlayerKey.BIsaac,
		LockCheck = {
			Lock = lock.BIsaac,
			Desc = {
				{Str = '阴间之撒但夺去生命'},
				{Str = '人间之以撒夺回生命', Offset = Vector(0, 25)},
			}
		},
		Portrait = {Anim = 'BIsaac'},
		Name = {Str = '以撒'},
		Desc = {
			{Str = '命运权衡'},
			{Str = '二元庇佑', Offset = Vector(0, 16)},
		},
		Thing = {
			{Str = '光辉六面骰'},
			{Str = '骰子碎片', Offset = Vector(7, 25), ConditionKey = 'bc1'},
		},
	},
	[2] = {
		PlayerKey = IBS_PlayerKey.BMaggy,
		LockCheck = {
			Lock = lock.BMaggy,
			Desc = {
				{Str = '重视鲜血尖刺', Offset = Vector(30, 0)},
				{Str = '驱逐七只恶鬼', Offset = Vector(30, 25)},
			}
		},
		Portrait = {Anim = 'BMaggy'},	
		Name = {Str = '抹大拉', Offset = Vector(-14, 0)},
		Desc = {
			{Str = '坚贞之心'},
			{Str = '+', Offset = Vector(50, 0), ConditionKey = 'bc2'},
			{Str = '石破天惊', Offset = Vector(0, 16)},
		},
		Thing = {
			{Str = '发光的心', Offset = Vector(8, 0)},
		},
	},
	[3] = {
		PlayerKey = IBS_PlayerKey.BCBA,
		LockCheck = {
			Lock = lock.BCBA,
			Desc = {
				{Str = '汝为祭', Offset = Vector(60, 0)},
				{Str = '墓为地', Offset = Vector(60, 25)},
			}
		},
		Portrait = {Anim = 'BCBA'},	
		Name = {Str = '该隐&亚伯', Offset = Vector(-30, 0)},
		Desc = {
			{Str = '阴阳两隔', Offset = Vector(0, 8)},
		},
		Thing = {
			{Str = '移动农场', Offset = Vector(-40, 0)},
			{Str = '变羊术', Offset = Vector(70, 25)},
			{Str = '伪忆 x 2', Offset = Vector(0, 50), ConditionKey = "bc3"},
		},
	},
	[4] = {
		PlayerKey = IBS_PlayerKey.BJudas,
		LockCheck = {
			Lock = lock.BJudas,
			Desc = {
				{Str = '翻开隐藏的书页', Offset = Vector(25, 0)},
				{Str = '撒但圣经', Offset = Vector(50, 25)},
			}
		},
		Portrait = {Anim = 'BJudas'},
		Name = {Str = '犹大'},
		Desc = {
			{Str = '亡魂冲击'},
			{Str = '弱化敌人', Offset = Vector(0, 16), ConditionKey = 'bc4'},
		},
		Thing = {
			{Str = '犹大福音', Offset = Vector(8, 0)},
			{Str = '混沌信仰', Offset = Vector(7, 25), ConditionKey = 'bc4'},
		},
	},
	[5] = {
		PlayerKey = IBS_PlayerKey.BXXX,
		LockCheck = {
			Lock = lock.BXXX,
			Desc = {
				{Str = '家中奇点', Offset = Vector(52, 8)},
			}
		},
		Portrait = {Anim = 'BXXX'},	
		Name = {Str = '???'},
		Desc = {
			{Str = '伪忆走马灯', Offset = Vector(-7, 8)},
		},
		Thing = {
			{Str = '??? 的伪忆', Offset = Vector(-7, 0), ConditionKey = "bc5"},
		},
	},
	[6] = {
		PlayerKey = IBS_PlayerKey.BEve,
		LockCheck = {
			Lock = lock.BEve,
			Desc = {
				{Str = 'K13', Offset = Vector(70, 0)},
				{Str = 'C122', Offset = Vector(60, 25)},
				{Str = '------', Offset = Vector(44, 25)},
			}
		},
		Portrait = {Anim = 'BEve'},	
		Name = {Str = '夏娃', Offset = Vector(-3,0)},
		Desc = {
			{Str = '一回生', Offset = Vector(-20, 0)},
			{Str = '二回熟', Offset = Vector(20, 0)},
			{Str = '三回转', Offset = Vector(2, 16), ConditionKey='bc6'},
		},
		Thing = {
			{Str = '我果', Offset = Vector(22, 0)},
			{Str = '我过', Offset = Vector(17, 25)},
		},
	},	
	[10] = {
		PlayerKey = IBS_PlayerKey.BEden,
		LockCheck = {
			Lock = lock.BEden,
			Desc = {
				{Str = '等等', Offset = Vector(72, 8)},
			}
		},
		Portrait = {Anim = 'BEden'},
		Name = {Str = '伊甸'},
		Desc = {
			{Str = '常无变幻', Offset = Vector(0, 8)},
			{Str = '+', Offset = Vector(50, 7), ConditionKey = 'bc10'},
		},
		Thing = {
			{Str = '已定义', Offset = Vector(14, 0)},
		},
	},
	[11] = {
		PlayerKey = IBS_PlayerKey.BLost,
		LockCheck = {
			Lock = lock.BLost,
			Desc = {
				{Str = '1...2...3...4', Offset = Vector(40, 0)},
				{Str = '就像以前一样...', Offset = Vector(25, 25)},
				{Str = '不过仅一人当...', Offset = Vector(15, 50)},
			}
		},
		Portrait = {Anim = 'BLost'},
		Name = {Str = '游魂', Offset = Vector(-4, 0)},
		Desc = {
			{Str = '箱中孤魂', Offset = Vector(-3, 0)},
			{Str = '钥匙眼泪', Offset = Vector(-3, 16)},
		},
		Thing = {
			{Str = '箱中箱宝库'},
			{Str = '箱子', Offset = Vector(20, 25)},
			{Str = '又一个箱子', Offset = Vector(-10, 50), ConditionKey = 'bc11'},
		},
	},	
	[13] = {
		PlayerKey = IBS_PlayerKey.BKeeper,
		LockCheck = {
			Lock = lock.BKeeper,
			Desc = {
				{Str = '慷慨地捐款', Offset = Vector(40, 0)},
				{Str = '贪婪地慷慨', Offset = Vector(40, 25)},
			}
		},
		Portrait = {Anim = 'BKeeper'},
		Name = {Str = '店主'},
		Desc = {
			{Str = '牵挂慷慨', Offset = Vector(0, 8)},
		},
		Thing = {
			{Str = '异业', Offset = Vector(22, 0)},
			{Str = 'XX-审判', Offset = Vector(2, 25), ConditionKey = 'bc13'},
		},
	},
	
}

local info_en = {
	[0] = {
		Portrait = {Anim = 'Unknown'},
		Name = {Str = 'UNKNOWN', Offset = Vector(-45, 0)},
	},
	[1] = {
		PlayerKey = IBS_PlayerKey.BIsaac,
		LockCheck = {
			Lock = lock.BIsaac,
			Desc = {
				{Str = 'Die from Satan', Offset = Vector(8, 0)},
				{Str = 'Live through Satan', Offset = Vector(-12, 25)},
			}
		},
		Portrait = {Anim = 'BIsaac'},
		Name = {Str = 'Isaac', Offset = Vector(-8, 0)},
		Desc = {
			{Str = 'Balanced Destiny', Offset = Vector(-24, 0)},
			{Str = 'Dualistic Shelter', Offset = Vector(-24, 16)},
		},
		Thing = {
			{Str = 'The Light D6', Offset = Vector(-16, 0)},
			{Str = 'Dice Shard', Offset = Vector(-8, 25), ConditionKey = 'bc1'},
		},
	},
	[2] = {
		PlayerKey = IBS_PlayerKey.BMaggy,
		LockCheck = {
			Lock = lock.BMaggy,
			Desc = {
				{Str = 'Review bloody spikes', Offset = Vector(-12, 0)},
				{Str = 'Drive sins away', Offset = Vector(16, 25)},
			}
		},
		Portrait = {Anim = 'BMaggy'},	
		Name = {Str = 'Magdalene', Offset = Vector(-40, 0)},
		Desc = {
			{Str = 'Iron Heart', Offset = Vector(-14, 0)},
			{Str = '+', Offset = Vector(56, 0), ConditionKey = 'bc2'},
			{Str = 'Charge Under Stone', Offset = Vector(-38, 16)},
		},
		Thing = {
			{Str = 'Glowing Heart', Offset = Vector(-16, 0)},
		},
	},
	[3] = {
		PlayerKey = IBS_PlayerKey.BCBA,
		LockCheck = {
			Lock = lock.BCBA,
			Desc = {
				{Str = 'Sacrifice', Offset = Vector(50, 0)},
				{Str = 'Graveyard', Offset = Vector(40, 25)},
			}
		},
		Portrait = {Anim = 'BCBA'},	
		Name = {Str = 'Cain&Abel', Offset = Vector(-30, 0)},
		Desc = {
			{Str = 'Between', Offset = Vector(0, 8)},
		},
		Thing = {
			{Str = 'Portable Farm', Offset = Vector(-40, -5)},
			{Str = 'Goatify', Offset = Vector(60, 25)},
			{Str = 'Falsehoods x 2', Offset = Vector(-36, 50), ConditionKey = "bc3"},
		},
	},
	[4] = {
		PlayerKey = IBS_PlayerKey.BJudas,
		LockCheck = {
			Lock = lock.BJudas,
			Desc = {
				{Str = 'Secret sheet', Offset = Vector(25, 0)},
				{Str = 'Satan Bible', Offset = Vector(36, 25)},
			}
		},
		Portrait = {Anim = 'BJudas'},
		Name = {Str = 'Judas', Offset = Vector(-10, 0)},
		Desc = {
			{Str = 'Ghost Splash', Offset = Vector(-14, 0)},
			{Str = 'Weaken Enemies', Offset = Vector(-20, 16), ConditionKey = 'bc4'},
		},
		Thing = {
			{Str = 'TGOJ', Offset = Vector(20, 0)},
			{Str = 'Chaotic Belief', Offset = Vector(-20, 25), ConditionKey = 'bc4'},
		},
	},
	[5] = {
		PlayerKey = IBS_PlayerKey.BXXX,
		LockCheck = {
			Lock = lock.BXXX,
			Desc = {
				{Str = 'Home singularity', Offset = Vector(10, 8)},
			}
		},
		Portrait = {Anim = 'BXXX'},	
		Name = {Str = '???'},
		Desc = {
			{Str = 'Falsehoods go round', Offset = Vector(-40, 8)},
		},
		Thing = {
			{Str = 'Falsehood of ???', Offset = Vector(-40, 0), ConditionKey = "bc5"},
		},
	},	
	[6] = {
		PlayerKey = IBS_PlayerKey.BEve,
		LockCheck = {
			Lock = lock.BEve,
			Desc = {
				{Str = 'K13', Offset = Vector(70, 0)},
				{Str = 'C122', Offset = Vector(60, 25)},
				{Str = '------', Offset = Vector(44, 25)},
			}
		},
		Portrait = {Anim = 'BEve'},	
		Name = {Str = 'Eve'},
		Desc = {
			{Str = 'First raw', Offset = Vector(-35, 0)},
			{Str = 'Then saw', Offset = Vector(30, 0)},
			{Str = 'And haw', Offset = Vector(-4, 16), ConditionKey='bc6'},
		},
		Thing = {
			{Str = 'My Fruit', Offset = Vector(8, 0)},
			{Str = 'My Fault', Offset = Vector(4, 25)},
		},
	},		
	[10] = {
		PlayerKey = IBS_PlayerKey.BEden,
		LockCheck = {
			Lock = lock.BEden,
			Desc = {
				{Str = 'Wait', Offset = Vector(72, 8)},
			}
		},
		Portrait = {Anim = 'BEden'},
		Name = {Str = 'Eden', Offset = Vector(-3, 0)},
		Desc = {
			{Str = 'Never Changing', Offset = Vector(-20, 8)},
			{Str = '+', Offset = Vector(72, 8), ConditionKey = 'bc10'},
		},
		Thing = {
			{Str = 'Defined', Offset = Vector(8, 0)},
		},
	},
	[11] = {
		PlayerKey = IBS_PlayerKey.BLost,
		LockCheck = {
			Lock = lock.BLost,
			Desc = {
				{Str = '1...2...3...4', Offset = Vector(40, 0)},
				{Str = 'Just like before...', Offset = Vector(10, 25)},
				{Str = 'But needs only one...', Offset = Vector(-17, 50)},
			}
		},
		Portrait = {Anim = 'BLost'},
		Name = {Str = 'The Lost', Offset = Vector(-30, 0)},
		Desc = {
			{Str = 'Chester Alone', Offset = Vector(-18, 0)},
			{Str = 'Key Tears', Offset = Vector(-8, 16)},
		},
		Thing = {
			{Str = 'Chest Chest', Offset = Vector(-10, 0)},
			{Str = 'Chest', Offset = Vector(15, 25)},
			{Str = 'Another Chest', Offset = Vector(-30, 50), ConditionKey = 'bc11'},
		},
	},		
	[13] = {
		PlayerKey = IBS_PlayerKey.BKeeper,
		LockCheck = {
			Lock = lock.BKeeper,
			Desc = {
				{Str = 'Be generous', Offset = Vector(-15, 0)},
				{Str = 'to donate', Offset = Vector(90, 20)},
				{Str = 'Be greedy', Offset = Vector(-15, 50)},
				{Str = 'to be generous', Offset = Vector(40, 70)},
			}
		},
		Portrait = {Anim = 'BKeeper'},
		Name = {Str = 'Keeper', Offset = Vector(-19,0)},
		Desc = {
			{Str = 'Generosity is hanging on', Offset = Vector(-47, 8)},
		},
		Thing = {
			{Str = 'Another Karma', Offset = Vector(-25, 0)},
			{Str = 'XX - Judgement', Offset = Vector(-36, 25), ConditionKey = 'bc13'},
		},
	},	
	
}

--渲染
local function RenderInfo(info, Y, lastInfo, nextInfo)
	local locked = (info.LockCheck and info.LockCheck.Lock:IsLocked()) or false
	--local locked = false

	do --角色图标
		local offset = info.Portrait.Offset or Vector.Zero
		local anim = info.Portrait.Anim
		if locked then anim = anim..'Locked' end
		portrait:Play(anim)
		portrait:Render(GetFixedPos(Vector(-275 + offset.X, Y + offset.Y)))
	end
	
	if lastInfo then --左箭头旁的小角色图标
		local offset = (lastInfo.Portrait.Offset or Vector.Zero)*0.5
		local anim = lastInfo.Portrait.Anim
		local lastLocked = (lastInfo.LockCheck and lastInfo.LockCheck.Lock:IsLocked()) or false
		if lastLocked then anim = anim..'Locked' end
		lastPortrait:Play(anim)
		lastPortrait:Render(GetFixedPos(Vector(-100 + offset.X, 30 + Y + offset.Y)))
	end
	if nextInfo then --右箭头旁的小角色图标
		local offset = (nextInfo.Portrait.Offset or Vector.Zero)*0.5
		local anim = nextInfo.Portrait.Anim
		local nextLocked = (nextInfo.LockCheck and nextInfo.LockCheck.Lock:IsLocked()) or false
		if nextLocked then anim = anim..'Locked' end
		nextPortrait:Play(anim)
		nextPortrait:Render(GetFixedPos(Vector(40 + offset.X, 25 + Y + offset.Y)))
	end
	
	do --角色名称
		local offset = info.Name.Offset or Vector.Zero
		local pos = GetFixedPos(Vector(175 + offset.X, Y + 120 + offset.Y))
		fntBold:DrawStringScaledUTF8(info.Name.Str, pos.X, pos.Y, 1.25, 1.25, color)
	end
	
	--解锁提示
	if locked then
		if zh then
			local pos = GetFixedPos(Vector(181, Y + 153))	
			fnt:DrawStringScaledUTF8('(锁定)', pos.X, pos.Y, 1, 1, color)
		else
			local pos = GetFixedPos(Vector(169, Y + 155))	
			fnt:DrawStringScaledUTF8('(LOCKED)', pos.X, pos.Y, 1, 1, color)		
		end
		for _,desc in ipairs(info.LockCheck.Desc) do
			local offset = desc.Offset or Vector.Zero
			local pos = GetFixedPos(Vector(105 + offset.X, Y + 175 + offset.Y))	
			fntBold:DrawStringScaledUTF8(desc.Str, pos.X, pos.Y, 1, 1, color)
		end

		return
	end
	
	--角色介绍
	if info.Desc then 
		for _,desc in ipairs(info.Desc) do
			if desc.ConditionKey == nil or mod:GetIBSData('persis')[desc.ConditionKey] then
				local offset = desc.Offset or Vector.Zero
				local pos = GetFixedPos(Vector(175 + offset.X, Y + 150 + offset.Y))	
				fnt:DrawStringScaledUTF8(desc.Str, pos.X, pos.Y, 1, 1, color)
			end
		end
	end
	
	--物品
	if info.Thing then
		for _,thing in ipairs(info.Thing) do
			if thing.ConditionKey == nil or mod:GetIBSData('persis')[thing.ConditionKey] then
				local offset = thing.Offset or Vector.Zero
				local pos = GetFixedPos(Vector(157 + offset.X, Y + 190 + offset.Y))
				slot:Render(Vector(pos.X - 16, pos.Y + 11))
				fntBold:DrawStringScaledUTF8(thing.Str, pos.X, pos.Y, 1, 1, color)
			end
		end
	end
	
	--伊甸使用次数
	if info.Portrait.Anim == 'BEden' then
		local token = Isaac.GetPersistentGameData():GetEventCounter(EventCounter.EDEN_TOKENS)
		local pos = GetFixedPos(Vector(110, Y + 256))
		fntBold:DrawStringScaledUTF8(token, pos.X, pos.Y, 1, 1, color, 148, true)		
	end
end

mod:AddPriorityCallback(ModCallbacks.MC_MAIN_MENU_RENDER, CallbackPriority.EARLY, function()
	local id = CharacterMenu.GetSelectedCharacterID()
	local info = nil
	local lastInfo = nil
	local nextInfo = nil
	local canConfirm = true

	--没有对应角色屏蔽确认键
	if zh then
		info = info_zh[id]
		if id == 0 or not info then
			info = info or info_zh[0]
			canConfirm = false
		end

		lastInfo = info_zh[id-1] or info_zh[0]
		nextInfo = info_zh[id+1] or info_zh[0]
	else
		info = info_en[id]
		if id == 0 or not info then
			info = info or info_en[0]
			canConfirm = false			
		end	

		lastInfo = info_zh[id-1] or info_en[0]
		nextInfo = info_zh[id+1] or info_en[0]
	end

	local locked = (info.LockCheck and info.LockCheck.Lock:IsLocked()) or false
	--local locked = false

	--未解锁角色时屏蔽确认键
	if locked then
		canConfirm = false
	end

	if show then
		if Y > finalY then
			Y = Y - 15
		end
	else
		if Y < primaryY then
			Y = Y + 15
		end
	end
	
	if Y < primaryY then
		menu:Render(GetFixedPos(Vector(-330, Y)))
		RenderInfo(info, Y, lastInfo, nextInfo)

		--通关标记提示
		local KEY = info.PlayerKey
		if KEY and not locked then
			local marks = mod:GetIBSData('persis')[KEY]
			if marks then
				local pos = GetFixedPos(Vector(40, Y + 90))
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
		end

		--让被挡住的图标重新渲染一遍以抬高图层(天才
		do
			CharacterMenu.GetSeedPageSprite():Render(GetFixedPos(Vector(311,30)))
			CharacterMenu.GetDifficultyPageSprite():Render(GetFixedPos(Vector(326,105)))
			--CharacterMenu.GetEastereggPageSprite():Render(GetFixedPos(Vector(365,223)))
		end
	end

	--防止切换至里角色界面时冒出菜单
	if Input.IsActionTriggered(ButtonAction.ACTION_MENURT, 0) then
		wait = wait + 20
	end	

	if MenuManager.GetActiveMenu() == MainMenuType.CHARACTER and CharacterMenu.GetSelectedCharacterMenu() == 0 then
		--没有对应角色或未解锁时屏蔽确认键
		if show then
			local inputMask = MenuManager.GetInputMask()
			local canControl = (inputMask & ButtonActionBitwise.ACTION_MENUCONFIRM > 0)
			if canControl and not canConfirm then
				MenuManager.SetInputMask(inputMask &~ ButtonActionBitwise.ACTION_MENUCONFIRM)
			end
			if not canControl and canConfirm then
				MenuManager.SetInputMask(inputMask | ButtonActionBitwise.ACTION_MENUCONFIRM)
			end
			
			--提示音
			if Input.IsActionTriggered(ButtonAction.ACTION_MENUCONFIRM, 0) and not canConfirm then
				SFXManager():Play(187, 1, 30)
			end
		end
	
		--手柄右摇杆按键
		local rightStick = false
		for idx = 0,4 do
			if Input.IsButtonTriggered(13, idx) then
				rightStick = true
				break
			end
		end
	
		--按键切换菜单
		if wait <= 0 and (Input.IsButtonTriggered(Keyboard.KEY_I, 0) or rightStick) then
			local inputMask = MenuManager.GetInputMask()
			local canControl = (inputMask & ButtonActionBitwise.ACTION_MENURT > 0)

			--切换菜单并屏蔽切换至里角色按键
			if canControl then
				show = true
				filter:Play('In', true)
				MenuManager.SetInputMask(inputMask &~ ButtonActionBitwise.ACTION_MENURT)
				SFXManager():Play(SoundEffect.SOUND_PAPER_IN, 1, 2, false, 0.7)
				MusicManager():Crossfade(music, 0.01)
			else
				show = false
				filter:Play('Out', true)
				MenuManager.SetInputMask(inputMask | ButtonActionBitwise.ACTION_MENURT | ButtonActionBitwise.ACTION_MENUCONFIRM)
				SFXManager():Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12, 1, 2, false, 0.7)
				MusicManager():Crossfade(63, 0.01)
			end
			
			wait = wait + 30
		end	

		--按键提示
		if mod:GetIBSData('persis').tipI then
			widget:Render(Isaac.WorldToMenuPosition(MainMenuType.CHARACTER, Vector(30,220)))
		end
	else
		if MenuManager.GetActiveMenu() == MainMenuType.SPECIALSEEDS then
			MenuManager.SetInputMask(MenuManager.GetInputMask() | ButtonActionBitwise.ACTION_MENUCONFIRM)
		else
			if show then
				show = false
				filter:Play('Out', true)
				MenuManager.SetInputMask(MenuManager.GetInputMask() | ButtonActionBitwise.ACTION_MENURT | ButtonActionBitwise.ACTION_MENUCONFIRM)
				MusicManager():Crossfade(63, 0.01)
			end
		end
	end

	--滤镜
	filter:Render(Vector(Isaac.GetScreenWidth() / 2, Isaac.GetScreenHeight() / 2))
	filter:Update()

	if wait > 0 then
		wait = wait - 1
	end
end)

mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, 7^10, function(_,isContinued)
	if not isContinued then
		if show then
			local player = Isaac.GetPlayer(0)
			mod.IBS_Callback.Benighted:RunWithParam(player:GetPlayerType(), player, true)
		end
	end
end)


do--挑战解锁检测

--角色对应挑战
local PlayerChallenge = {

[IBS_ChallengeID[1]] = IBS_PlayerKey.BIsaac,
[IBS_ChallengeID[2]] = IBS_PlayerKey.BMaggy,
[IBS_ChallengeID[3]] = IBS_PlayerKey.BCBA,
[IBS_ChallengeID[4]] = IBS_PlayerKey.BJudas,
[IBS_ChallengeID[5]] = IBS_PlayerKey.BXXX,
[IBS_ChallengeID[6]] = IBS_PlayerKey.BEve,

[IBS_ChallengeID[10]] = IBS_PlayerKey.BEden,
[IBS_ChallengeID[11]] = IBS_PlayerKey.BLost,

[IBS_ChallengeID[13]] = IBS_PlayerKey.BKeeper,

}

--检查解锁状态
local function IsChallengeLocked(id)
	local playerKey = PlayerChallenge[id]
	if playerKey then
		local marks = mod:GetIBSData('persis')[playerKey]
		if marks and not marks.Unlocked then
			return true
		end
	end	
	return false
end

local lastID = -1
local lastInChallengeMenu = false

--未解锁则不让进入
mod:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, function()
	if MenuManager.GetActiveMenu() == MainMenuType.MODCHALLENGES then
		local id = CustomChallengeMenu.GetSelectedChallengeID()
		local inputMask = MenuManager.GetInputMask()
		local canControl = (inputMask & ButtonActionBitwise.ACTION_MENUCONFIRM > 0)

		if IsChallengeLocked(id) then
			if canControl then
				MenuManager.SetInputMask(inputMask &~ ButtonActionBitwise.ACTION_MENUCONFIRM)
			end

			--提示音
			if Input.IsActionTriggered(ButtonAction.ACTION_MENUCONFIRM, 0) and not canConfirm then
				SFXManager():Play(187, 1, 30)
			end
			
			lastID = id
		elseif lastID > 0 then
			if not canControl then
				MenuManager.SetInputMask(inputMask | ButtonActionBitwise.ACTION_MENUCONFIRM)
			end
			lastID = -1
		end
		
		lastInChallengeMenu = true
	elseif lastInChallengeMenu then
		local inputMask = MenuManager.GetInputMask()
		local canControl = (inputMask & ButtonActionBitwise.ACTION_MENUCONFIRM > 0)
		if not canControl then
			MenuManager.SetInputMask(inputMask | ButtonActionBitwise.ACTION_MENUCONFIRM)
		end
		lastInChallengeMenu = false
	end
end)


end