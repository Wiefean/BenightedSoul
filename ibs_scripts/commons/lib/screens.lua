--屏幕相关函数

local mod = Isaac_BenightedSoul 

local Screens = {}

local game = Game()
local sfx = SFXManager()

--获取屏幕尺寸
--(这个函数真的有存在的必要吗...)
function Screens:GetScreenSize() 
	return Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight())
end

--获取屏幕中央位置
function Screens:GetScreenCenter() 
	return Vector(Isaac.GetScreenWidth()/2, Isaac.GetScreenHeight()/2)
end


--游戏位置转屏幕位置
--[[
输入:世界位置(矢量), 屏幕位置修正(矢量), 忽略房间摄像头滚动效果(是否), 忽略屏幕晃动效果(是否),
	 忽略镜世界翻转效果(是否)

输出:屏幕位置(矢量)

包含镜世界位置修正和屏幕摇晃同步,
但不知为何,贴图(Sprite)可以同步晃动,而字体(Font)不能
]]
function Screens:WorldToScreen(worldPos, screenOffset, ignoreRoomScroll, ignoreShake, ignoreMirror)
	screenOffset = screenOffset or Vector.Zero
	local room = game:GetRoom()
	local offset = Vector.Zero 

	if not ignoreRoomScroll then
		offset = offset + room:GetRenderScrollOffset()
	end	
	
	if not ignoreShake then
		offset = offset + game.ScreenShakeOffset
	end
	
	local pos = Isaac.WorldToScreen(worldPos) + screenOffset - offset
	
	--镜世界修正
	if not ignoreMirror and room:IsMirrorWorld() then
		return Vector(Isaac.GetScreenWidth() - pos.X , pos.Y)
	end
	
	return pos
end


--获取实体在屏幕上的位置
--[[
输入:实体, 屏幕位置修正(矢量), 实体世界位置修正(矢量), 实体世界位置修正是否忽略倒影效果(是否)
输出:屏幕位置(矢量)

在对应的实体渲染回调中才能使用,因为其提供了offset参数
]]
function Screens:GetEntityRenderPosition(entity, screenOffset, worldOffset, ignoreReflection)
	screenOffset = screenOffset or Vector.Zero
	worldOffset = worldOffset or Vector.Zero
	
	--可选择实体世界位置修正是否忽略倒影效果
	if (not ignoreReflection) and (game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT) then
		worldOffset = -worldOffset
	end

	return Screens:WorldToScreen(entity.Position + entity.PositionOffset + worldOffset, screenOffset, false, false, true)
end


--获取鼠标位置
--[[
输入:由屏幕位置调整为世界位置(是否)
输出:屏幕位置或世界位置(矢量)

这个函数主要是用于获取鼠标世界位置的,
因为屑官方没有给鼠标镜世界位置做修正
]]
function Screens:GetMousePosition(toWorldPos)
	toWorldPos = toWorldPos or false
	local pos = Input.GetMousePosition(toWorldPos)
	local room = game:GetRoom()
	
	--镜世界修正
	if toWorldPos and room:IsMirrorWorld() then
		local mouse_pos_render = Isaac.WorldToScreen(pos)
		local middle_render = Isaac.WorldToRenderPosition(Vector(320,240))
		return Vector(
			pos.X - 2 * Isaac.ScreenToWorldDistance(mouse_pos_render - middle_render).X,
			pos.Y
		)
	end
	
	return pos
end


do --玩家HUD区(充满模组作者怨念的区域)

--[[玩家号数一般获取方法:
local controllers = {} --用于为控制器编号
local idx = 0
local slot = 1

for i = 0, Game():GetNumPlayers() -1 do
	local player = Isaac.GetPlayer(i)
	local cid = player.ControllerIndex

	if not controllers[cid] then
		Screens:GetActiveSlotRenderInfo(player, idx, slot)
		
		--对于以扫,需要额外判断
		if (player:GetPlayerType() == PlayerType.PLAYER_JACOB) and player:GetOtherTwin() then
			local player2 = player:GetOtherTwin()
				Screens:GetActiveSlotRenderInfo(player2, idx, slot)
			end
		end
		
		controllers[cid] = true
		idx = idx + 1
	end	
end
]]


--获取主动道具渲染信息
--[[
输入:玩家(实体), 玩家号数(整数), 主动槽位(整数)
输出:屏幕位置(矢量), 主动槽尺寸(矢量)

以扫为P1时才显示主动槽
]]
function Screens:GetActiveSlotRenderInfo(player, idx, slot)
	local screenSize = Screens:GetScreenSize()
	local X,Y = 0,0
	local offset = Options.HUDOffset
	local slotScale = Vector(1,1)
	local playerType = player:GetPlayerType()

	--获取第一主动槽位置
	if (idx == 0) then --P1
		if (playerType == PlayerType.PLAYER_ESAU) and player:GetOtherTwin() then --以扫
			X = screenSize.X - 20 - 16*offset
			Y = screenSize.Y - 23 - 6*offset
		else
			X = 20 + 20*offset
			Y = 16 + 12*offset
		end
	elseif (idx == 1) then --P2
		X = screenSize.X - 139 - 24*offset
		Y = 16 + 12*offset
	elseif (idx == 2) then --P3
		X = 30 + 22*offset
		Y = screenSize.Y - 23 - 6*offset
	else --P4或其他
		X = screenSize.X - 147 - 16*offset
		Y = screenSize.Y - 23 - 6*offset
	end

	--第二主动和副手主动兼容
	--(第二主动和非P1玩家副手主动的贴图是缩小一半的)
	if (slot == ActiveSlot.SLOT_SECONDARY) then
		X = X - 17
		Y = Y - 8
		slotScale = Vector(0.5,0.5)
	elseif (slot == ActiveSlot.SLOT_POCKET) then
		if (idx == 0) then --P1
			if (playerType == PlayerType.PLAYER_JACOB) then
				X = 3 + 20*offset
				Y = 39 + 12*offset		
			elseif (playerType == PlayerType.PLAYER_ESAU) and player:GetOtherTwin() then
				X = screenSize.X - 15 - 16*offset
				Y = screenSize.Y - 46 - 6*offset
			else
				X = screenSize.X - 20 - 16*offset
				Y = screenSize.Y - 14 - 6*offset
			end
		else --其他
			X = X - 24
			Y = Y + 18
			slotScale = Vector(0.5,0.5)
		end
	end		
	
	return Vector(X,Y), slotScale
end


--获取角色血量渲染信息
--[[
输入:玩家(实体), 玩家号数(整数), 血量槽位(整数)

输出:输入的槽位屏幕位置(矢量), 第一个槽位屏幕位置(矢量), 
当前行已排列血量槽数(整数), 角色最大血量列数(整数), 每个槽位的X坐标间隔(整数)


一个血量槽位的宽为12像素,高为10像素
P1的血量最多排6列,其他则为3列
以扫P1时才显示血量,且反向排列
]]
function Screens:GetPlayerHpRenderInfo(player, idx, slot)
	local screenSize = Screens:GetScreenSize()
	local X,Y = 0,0
	local column,maxColumn = 1,6 --P1的血量最多排6列,其他则为3列
	local offset = Options.HUDOffset
	local isEsau = (player:GetPlayerType() == PlayerType.PLAYER_ESAU) --以扫

	--获取第一个血量槽位置
	if (idx == 0) then --P1
		if isEsau and player:GetOtherTwin() then --以扫
			X = screenSize.X - 47 - 16*offset
			Y = screenSize.Y - 28 - 6*offset
		else
			X = 48 + 20 * offset
			Y = 12 + 12 * offset
		end
	elseif (idx == 1) then --P2
		X = screenSize.X - 111 - 24*offset
		Y = 12 + 12 * offset
	elseif (idx == 2) then --P3
		X = 58 + 22 * offset
		Y = screenSize.Y - 27 - 6*offset
	else --P4或其他
		X = screenSize.X - 119 - 16*offset
		Y = screenSize.Y - 27 - 6*offset
	end

	local savedX,savedY = X,Y --第一个血量槽位置
	local intervalX = 12
	if isEsau then intervalX = -12 end --以扫的血量是反向排序的

	--获取其他血量槽位置
	if slot >= 2 then
		if (idx ~= 0) then maxColumn = 3 end --P1的一行血量有6心,其他则有3心
		
		for i = 2,slot do
			X = X + intervalX
			column = column + 1
			
			if column > maxColumn then
				column = 1
				X = savedX
				Y = Y + 10
			end
		end
	end

	return Vector(X,Y), Vector(savedX,savedY), column, maxColumn, intervalX
end


--获取副角色血量渲染信息
--[[
输入:玩家(实体), 血量槽位(整数), 屏幕位置修正(矢量)

输出:输入的槽位屏幕位置(矢量), 第一个槽位屏幕位置(矢量), 
当前行已排列血量槽数(整数), 角色最大血量列数(整数)


一个血量槽位的宽为12像素,高为10像素
副角色的血量最多排3列,显示在角色头顶
]]
function Screens:GetSubPlayerHpRenderInfo(player, slot, screenOffset)
	screenOffset = screenOffset or Vector.Zero
	local column,maxColumn = 1,3

	--计算总血量槽数,用于调整X坐标
	local slots = math.ceil(player:GetMaxHearts() / 2) + math.ceil(player:GetSoulHearts() / 2) + player:GetBoneHearts() + player:GetBrokenHearts()

	--获取第一个血量槽位置
	local pos = Screens:GetEntityRenderPosition(player, player:GetFlyingOffset() + screenOffset)
	local X = pos.X + 5 - 5 * math.min(6, slots)
	local Y = pos.Y - 30
	local savedX,savedY = X,Y

	--获取其他血量槽位置
	if slot >= 2 then
		for i = 2,slot do
			X = X + 12
			column = column + 1

			if column > maxColumn then
				column = 1
				X = savedX
				Y = Y + 10
			end
		end
	end
	
	return Vector(X,Y), Vector(savedX,savedY), column, maxColumn
end
	

end





do --播放成就纸张动画

local achievementQueue = {}
local paperID = Isaac.GetGiantBookIdByName('IBS_Paper')
local paperFrames = 0

function Screens:PlayPaper(fileName, skipLanguageCheck)
	if Options.DisplayPopups then
		fileName = fileName or '' --防止"fileName"为nil时报错

		--检测语言
		if (not skipLanguageCheck) and mod.Language == 'zh' then
			fileName = fileName..'_zh'
		end

		table.insert(achievementQueue, fileName..'.png')
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	--切换成就纸张
	if (not game:IsPaused()) and paperFrames <= 0 and #achievementQueue > 0 then
		ItemOverlay.Show(paperID)
		local spr = ItemOverlay.GetSprite()
		spr:ReplaceSpritesheet(2, "gfx/ibs/ui/achievements/"..achievementQueue[1], true)
		paperFrames = 105
		table.remove(achievementQueue, 1)
	end

	local spr = ItemOverlay.GetSprite()
	
	--硬核判断是否在播放成就纸张动画
	if spr:GetFilename() ~= 'gfx/ibs/ui/giantbook/achievement.anm2' then return end

	--尝试按键跳过动画
	if (paperFrames > 9) and (paperFrames < 100) then
		for i = 0, game:GetNumPlayers() -1 do
			if Input.IsActionTriggered(ButtonAction.ACTION_MENUCONFIRM, Isaac.GetPlayer(i).ControllerIndex) then
				spr:SetFrame(97)
				paperFrames = 9
				break
			end
		end	
	end
end)
mod:AddCallback(ModCallbacks.MC_POST_ITEM_OVERLAY_UPDATE, function()
	local spr = ItemOverlay.GetSprite()

	--硬核判断是否在播放成就纸张动画
	if spr:GetFilename() ~= 'gfx/ibs/ui/giantbook/achievement.anm2' then return end

	if paperFrames > 0 then
		paperFrames = paperFrames - 1
	end

	if spr:IsEventTriggered("paperIn") then
		sfx:Play(SoundEffect.SOUND_PAPER_IN, 1, 0, false, 1)
	end
	if spr:IsEventTriggered("paperOut") then
		sfx:Play(SoundEffect.SOUND_PAPER_OUT, 1, 0, false, 1)
	end	
end)

--游戏开始时清空序列
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.EARLY, function()
	for k,_ in pairs(achievementQueue) do
		achievementQueue[k] = nil
	end
end)

end


--主界面浏览成就纸张
do

local achievementQueue = {}
local spr = Sprite('gfx/ibs/ui/giantbook/achievement_view.anm2')
spr:SetFrame('Out', 99)

function Screens:PlayPaperOnMainMenu(fileName, skipLanguageCheck)
	fileName = fileName or '' --防止"fileName"为nil时报错

	--检测语言
	if (not skipLanguageCheck) and mod.Language == 'zh' then
		fileName = fileName..'_zh'
	end

	table.insert(achievementQueue, fileName..'.png')
end
mod:AddPriorityCallback(ModCallbacks.MC_MAIN_MENU_RENDER, CallbackPriority.LATE, function()

	--切换成就纸张
	if #achievementQueue > 0 and spr:IsFinished('Out') then
		spr:ReplaceSpritesheet(2, "gfx/ibs/ui/achievements/"..achievementQueue[1], true)
		spr:Play('In', true)
		table.remove(achievementQueue, 1)
	end

	--任意键结束浏览
	if spr:IsFinished('In') then
		for btn = 0,7 do --鼠标
			if Input.IsMouseBtnPressed(btn) then
				spr:Play('Out', true)
				break
			end
		end
		for cid = 0,4 do
			for action = 0,26 do		
				if Input.IsActionTriggered(action, cid) then
					spr:Play('Out', true)
					break
				end
			end
		end
	end
		
	if spr:IsEventTriggered("paperIn") then
		sfx:Play(SoundEffect.SOUND_PAPER_IN, 1, 0, false, 1)
	end
	if spr:IsEventTriggered("paperOut") then
		sfx:Play(SoundEffect.SOUND_PAPER_OUT, 1, 0, false, 1)
	end	
	
	spr:Render(Screens:GetScreenCenter())
	spr:Update()
end)

end

return Screens