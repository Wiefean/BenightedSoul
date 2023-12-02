--书页动画相关函数

local mod = Isaac_BenightedSoul 
local sfx = SFXManager()

local BigBooks = {}


--获取屏幕中心
local function GetScreenCenter()
	 return Vector(Isaac.GetScreenWidth() / 2, Isaac.GetScreenHeight() / 2)
end

--利用桦树符文硬核暂停
local function HackyPause()
	Isaac.GetPlayer(0):UseCard(Card.RUNE_BERKANO, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)

	--移除生成的蓝苍蝇和蓝蜘蛛
	for _, bluefly in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, -1, false, false)) do
		if bluefly:Exists() and bluefly.FrameCount <= 0 then
			bluefly:Remove()
		end
	end
	for _, bluespider in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER, -1, false, false)) do
		if bluespider:Exists() and bluespider.FrameCount <= 0 then
			bluespider:Remove()
		end
	end
end

--播放原版书本动画
local bigBook = Sprite()
local maxFrames = { ["Appear"] = 33,  ["Shake"] = 36,  ["ShakeFire"] = 32,  ["Flip"] = 33 }
local bookColors = { [0] = Color(1, 1, 1, 1, 0, 0, 0), [1] = Color(1, 1, 1, 1, 0, 0, 0), [2] = Color(1, 1, 1, 1, 0, 0, 0), [3] = Color(1, 1, 1, 1, 0, 0, 0), [4] = Color(1, 1, 1, 1, 0, 0, 0), [5] = Color(1, 1, 1, 1, 0, 0, 0) }
local bookLength = 0
local bookHideBerkano = false
--[[动画层:
layer #0 - popup
layer #1 - screen (color 2)
layer #2 - dust poof (color 1)
layer #3 - dust poof (color 1)
layer #4 - swirl poof (color 3)
layer #5 - fire
]]
function BigBooks:PlayVanillaBook(_animName, _popup, _poofColor, _bgColor, _poof2Color, _soundName, _notHide) 
	bigBook:Load("gfx/ui/giantbook/giantbook.anm2", true)
	bigBook:ReplaceSpritesheet(0, "gfx/ibs/ui/giantbook/" .. _popup)
	bigBook:LoadGraphics()
	bigBook:Play(_animName, true)
	bookLength = maxFrames[_animName]
	bookColors[1] = _bgColor
	bookColors[2] = _poofColor
	bookColors[3] = _poofColor
	bookColors[4] = _poof2Color
	bookHideBerkano = true
	if not _notHide then
		HackyPause()
		if (_soundName) then
			sfx:Play(_soundName, 0.8, 0, false, 1)
		end
	end
end
local function BookRender()
	if bookLength > 0 then
		if (Isaac.GetFrameCount() % 2 == 0) then
			bigBook:Update()
			bookLength = bookLength - 1
		end
		for i = 5, 0, -1 do
			bigBook.Color = bookColors[i]
			bigBook:RenderLayer(i, GetScreenCenter())
		end
	end
	if bookLength == 0 and bookHideBerkano then
		bookHideBerkano = false
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, BookRender)

--还原桦树符文的原版动画
local function useBerkano()
	if not bookHideBerkano then
		BigBooks:PlayVanillaBook("Appear", "berkano.png", Color(0.2, 0.1, 0.3, 1, 0, 0, 0), Color(0.117, 0.0117, 0.2, 1, 0, 0, 0), Color(0, 0, 0, 0.8, 0, 0, 0), nil, true)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useBerkano, Card.RUNE_BERKANO)



--播放自定义书本动画
local bigCustomAnim = Sprite()
local customAnimLength = 0
function BigBooks:PlayBook(_fileName, _animName, _soundName)
	bigCustomAnim:Load("gfx/ibs/ui/giantbook/" .. _fileName, true)
	bigCustomAnim:LoadGraphics()
	bigCustomAnim:Play(_animName, true)
	customAnimLength = 32
	bookHideBerkano = true
	if not _notHide then
		HackyPause()
		if (_soundName) then
			sfx:Play(_soundName, 0.8, 0, false, 1)
		end
	end
end
local function CustomBookRender()
	if customAnimLength > 0 then
		if (Isaac.GetFrameCount() % 2 == 0) then
			bigCustomAnim:Update()
			customAnimLength = customAnimLength - 1
		end
		bigCustomAnim:Render(GetScreenCenter())
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, CustomBookRender)



--播放自定义纸张动画
local achievementQueue = {}
local bigPaper = Sprite()
local paperFrames = 0
local paperSwitch = false
function BigBooks:PlayPaper(_drawingSprite)
	if Options.DisplayPopups then
		table.insert(achievementQueue, #achievementQueue+1, _drawingSprite)
	end	
end
local function PaperRender()
	if (paperFrames <= 0) then
		if paperSwitch then
			for i = 1, #achievementQueue-1 do
				achievementQueue[i] = achievementQueue[i+1]
			end
			achievementQueue[#achievementQueue] = nil
			paperSwitch = false
		end
		if (not paperSwitch) and (#achievementQueue > 0) then
			bigPaper:Load("gfx/ibs/ui/achievements/achievement.anm2", true)
			bigPaper:ReplaceSpritesheet(2, "gfx/ibs/ui/achievements/" .. achievementQueue[1])
			bigPaper:LoadGraphics()
			bigPaper:Play("Idle", true)
			paperFrames = 41
			paperSwitch = true
			bookHideBerkano = true
			HackyPause()			
		end
	else
		local num = 3
		if paperFrames < 10 then
			num = 2
		end
		if (Isaac.GetFrameCount() % num == 0) then
			bigPaper:Update()
			paperFrames = paperFrames - 1
		end
		for i = 0, 3, 1 do
			bigPaper:RenderLayer(i, GetScreenCenter())
		end
	end
	
	if bigPaper:IsEventTriggered("paperIn") then
		sfx:Play(SoundEffect.SOUND_PAPER_IN, 1, 0, false, 1)
	end
	if bigPaper:IsEventTriggered("paperOut") then
		sfx:Play(SoundEffect.SOUND_PAPER_OUT, 1, 0, false, 1)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, PaperRender)

return BigBooks