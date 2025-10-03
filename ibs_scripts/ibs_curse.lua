--诅咒


local mod = Isaac_BenightedSoul

local function Load(fileName)
	return include("ibs_scripts.curses."..fileName)
end

mod.IBS_Curse = {
	Moving = Load('moving'),
	D7 = Load('d7'),
}

local alpha = 0 ----贴图不透明度
local scale = Vector(1,1) ----贴图缩放

--让诅咒图标突出显示
function mod.IBS_Curse:_Emphasize()
	alpha = 5
	scale.X = 2
	scale.Y = 2
end

local IBS_Curse = mod.IBS_Curse
local IBS_CallbackID = mod.IBS_CallbackID
local Levels = mod.IBS_Lib.Levels
local Screens = mod.IBS_Lib.Screens

local game = Game()

--尝试添加诅咒
local function ApplyCurse(_,curse)
	local rng = RNG()
	rng:SetSeed(Levels:GetLevelUniqueSeed(), 35)

	if (curse > 0) and (rng:RandomInt(100) < 20) then
		local int = rng:RandomInt(2)
		local data = mod:GetIBSData("persis")
		local greed = game:IsGreedMode()

		if (int == 0) and data["curse_moving"] then
			curse = IBS_Curse.Moving.Bitmask
		end
		if (int == 1) and data["curse_d7"] and not greed then
			curse = IBS_Curse.D7.Bitmask
		end

		return curse
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_CURSE_EVAL, CallbackPriority.IMPORTANT, ApplyCurse)

--获取诅咒贴图
local function GetCurseSprite(frame)
	local spr = Sprite()
	spr:Load("gfx/ibs/ui/curses.anm2", true)
	spr:Play("Idle")
	spr:SetFrame(frame)
	
	return spr
end

--诅咒列表
local CurseList = {
	{ Curse = IBS_Curse.Moving.Bitmask, Sprite = GetCurseSprite(0) },
	{ Curse = IBS_Curse.D7.Bitmask, Sprite = GetCurseSprite(2) },
}

--获取诅咒
local function GetCursesToRender()
	local result = {}
	local curses = game:GetLevel():GetCurses() 
	
	for k,v in ipairs(CurseList) do
		if (curses & v.Curse > 0) then
			table.insert(result, v)
		end	
	end
	
	return result
end

--是否按住地图键
local function IsMapPressed()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then
			return true
		end
	end
	return false
end

--诅咒图标渲染
local function CurseRender()
	if (not game:GetHUD():IsVisible()) or (game:GetPauseMenuState() > 0) then return end
	local X = Isaac.GetScreenWidth() / 2
	local Y = Isaac.GetScreenHeight() / 3.5
	local curses = GetCursesToRender()
	X = X - 8*(#curses - 1)
	
	--调整贴图透明度和大小
	if not game:IsPaused() then
		if alpha > 1 then
			alpha = alpha - 0.05
		else
			if IsMapPressed() then
				if alpha < 1 then alpha = alpha + 0.05 end
			else
				if alpha > 0 then alpha = alpha - 0.05 end
			end
		end	
		if scale.X > 1 then scale.X = scale.X - 0.02 end
		if scale.Y > 1 then scale.Y = scale.Y - 0.02 end
	end	
	
	for k,v in ipairs(curses) do
		v.Sprite.Color = Color(1,1,1,alpha)
		v.Sprite.Scale = scale
		v.Sprite:Render(Vector(X,Y))
		X = X + 16
	end
end
mod:AddCallback(IBS_CallbackID.RENDER_OVERLAY, CurseRender)

--进入新层时调整贴图,使其更显眼
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	IBS_Curse:_Emphasize()
end)

