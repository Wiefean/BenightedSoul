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

local function GetCurseSprite(animName)
	local spr = Sprite()
	spr:Load("gfx/ibs/ui/curses.anm2", true)
	spr:Play(animName)
	return spr
end

local CurseList = {
	[1] = {ID = LevelCurse.CURSE_OF_DARKNESS},
	[2] = {ID = LevelCurse.CURSE_OF_LABYRINTH},
	[3] = {ID = LevelCurse.CURSE_OF_THE_LOST},
	[4] = {ID = LevelCurse.CURSE_OF_THE_UNKNOWN},
	[5] = {ID = LevelCurse.CURSE_OF_THE_CURSED},
	[6] = {ID = LevelCurse.CURSE_OF_MAZE},
	[7] = {ID = LevelCurse.CURSE_OF_BLIND},
	[8] = {ID = LevelCurse.CURSE_OF_GIANT},
	[9] = {ID = IBS_Curse.moving, Sprite = GetCurseSprite("moving")},
	[10] = {ID = IBS_Curse.forgotten, Sprite = GetCurseSprite("forgotten")},
	[11] = {ID = IBS_Curse.d7, Sprite = GetCurseSprite("d7")},
	[12] = {ID = IBS_Curse.binding, Sprite = GetCurseSprite("binding")},
}

--
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

--
-- local function CurseRender()
	-- if Game():GetHUD():IsVisible() then
		-- local X = Isaac.GetScreenWidth()
		-- local Y = Isaac.GetScreenHeight()
		
		-- local controllers = {} --
		-- local index = 0
		
		-- for i = 0, Game():GetNumPlayers() -1 do
			-- local player = Isaac.GetPlayer(i)
			-- local cid = player.ControllerIndex
			-- if (player.Variant == 0) and not player:IsCoopGhost()  and not controllers[cid] then
				-- if (player:GetPlayerType() == (IBS_Player.bmaggy) or IBSChallenge()) then
					-- local IronHeart = GetIronHeartData(player)
					-- local data = GetPlayerTempData(player)
					-- IronHeart.Num = math.floor(IronHeart.Num)
					-- IronHeart.Max = math.floor(IronHeart.Max)
					-- IronHeart.Extra = math.floor(IronHeart.Extra)
					
					-- local X,Y = GetIronHeartRenderPosition(index)
					-- local spr = data.IronHeart_Sprite
					-- local fnt = data.IronHeart_Font
					-- local inum = tostring(IronHeart.Num + IronHeart.Extra)
					-- local imax = tostring(IronHeart.Max)
					-- if IronHeart.Num < 10 then inum = " "..inum end
					
					--未知诅咒兼容
					-- if (Game():GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN > 0) then
						-- inum = " ?"
						-- imax = "?"
					-- end
					
					-- local inumColor = KColor(1,1,1,1,0,0,0)
					-- if (IronHeart.Num + IronHeart.Extra) > IronHeart.Max then inumColor = KColor(1,1,0,1,0,0,0) end
					
					-- local imaxColor = KColor(1,1,1,1,0,0,0)
					-- if IronHeart.Max < Init.IronHeart_Max then imaxColor = KColor(1,0,0,1,0,0,0) end
					-- if IronHeart.Max > Init.IronHeart_Max then imaxColor = KColor(0.5,1,1,1,0,0,0) end
					
					-- spr:Render(Vector(X,Y))
					-- fnt:DrawString(inum, X+7, Y-7, inumColor)
					-- fnt:DrawString("/", X+7+fnt:GetStringWidth(inum), Y-7, KColor(1,1,1,1,0,0,0))
					-- fnt:DrawString(imax, X+7+fnt:GetStringWidth("/"..inum), Y-7, imaxColor)	
					
					
					
					-- if EID then
						-- if EID.player then
							-- EID:addTextPosModifier("IBS_BMAGGY", Vector(0,20))
						-- else
							-- EID:removeTextPosModifier("IBS_BMAGGY")
						-- end
					-- end
				-- end	
				-- controllers[cid] = true
				-- index = index + 1
			-- end
		-- end
	-- end
-- end
-- mod:AddCallback(ModCallbacks.MC_POST_RENDER, CurseRender)

