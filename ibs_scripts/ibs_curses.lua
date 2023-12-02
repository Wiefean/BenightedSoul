--诅咒

local function LoadScripts(scripts)
    for _, v in ipairs(scripts) do
        include("ibs_scripts.curses."..v)
    end
end

local curses = {
	"moving",
	"forgotten",
	"d7",
	"binding",
}
LoadScripts(curses)


local mod = Isaac_BenightedSoul
local IBS_Curse = mod.IBS_Curse
local Ents = mod.IBS_Lib.Ents
local IBS_RNG1 = mod:GetUniqueRNG("ApplyIBSCurse")
local IBS_RNG2 = mod:GetUniqueRNG("ChooseIBSCurse")

local config = Isaac.GetItemConfig()

--尝试添加诅咒
local function ApplyCurse(_,curse)
	if IBS_RNG1:RandomInt(99) < 19 then
		local game = Game()
		local int = IBS_RNG2:RandomInt(4) + 1
		local setting = mod:GetIBSData("Setting")

		if (int == 1) and setting["curse_moving"] then
			curse = IBS_Curse.moving
		end
		if (int == 2) and setting["curse_forgotten"] and not game:IsGreedMode() then
			curse = IBS_Curse.forgotten
		end
		if (int == 3) and setting["curse_d7"] and not game:IsGreedMode() then
			curse = IBS_Curse.d7
		end
		if (int == 4) and setting["curse_binding"] then
			curse = IBS_Curse.binding
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
	[1] = {Curse = IBS_Curse.moving, Sprite = GetCurseSprite(0)},
	[2] = {Curse = IBS_Curse.forgotten, Sprite = GetCurseSprite(1)},
	[3] = {Curse = IBS_Curse.d7, Sprite = GetCurseSprite(2)},
	[4] = {Curse = IBS_Curse.binding, Sprite = GetCurseSprite(3)},
}

--获取诅咒
local function GetCursesToRender()
	local result = {}
	local curses = Game():GetLevel():GetCurses() 
	
	for k,v in ipairs(CurseList) do
		if (curses & v.Curse > 0) then
			table.insert(result, v)
		end	
	end
	
	return result
end

--是否按住地图键
local function IsMapPressed()
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then
			return true
		end
	end
	return false
end

--不透明度
local alpha = 0

--诅咒图标渲染
local function CurseRender(_,shaderName)
	if shaderName ~= "IBS_Empty" then return end
	local game = Game()
	if game:GetHUD():IsVisible() then
		local X = Isaac.GetScreenWidth() / 2
		local Y = Isaac.GetScreenHeight() / 3.5
		local curses = GetCursesToRender()
		X = X - 8*(#curses - 1)
		
		--调整透明度
		if not game:IsPaused() then
			if IsMapPressed() then
				if alpha < 1 then alpha = alpha + 0.05 end
			else
				if alpha > 0 then alpha = alpha - 0.05 end
			end
		end	
		
		for k,v in ipairs(curses) do
			v.Sprite.Color = Color(1,1,1,alpha)
			v.Sprite:Render(Vector(X,Y))
			X = X + 16
		end
	end
end
mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, CurseRender)

