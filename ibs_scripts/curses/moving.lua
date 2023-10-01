--动人诅咒

local mod = Isaac_BenightedSoul
local IBS_Curse = mod.IBS_Curse
local Ents = mod.IBS_Lib.Ents

local fnt = Font()
fnt:Load("font/pftempestasevencondensed.fnt")

--读秒
local function TimeOut(_,player)
	local game = Game()
	if (game:GetLevel():GetCurses() & IBS_Curse.moving > 0) and not game:IsPaused() then
		local data = Ents:GetTempData(player)
		data.CurseMovingTimeOut = data.CurseMovingTimeOut or 180
		
		if player.Velocity:Length() > 1 then
			data.CurseMovingTimeOut = 180
		else
			if data.CurseMovingTimeOut > 0 then
				data.CurseMovingTimeOut = data.CurseMovingTimeOut - 1
			else
				data.CurseMovingTimeOut = 180
				player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_CLONES, EntityRef(player), 0)
			end
		end
		
	else
		Ents:GetTempData(player).CurseMovingTimeOut = nil
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, TimeOut, 0)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = Ents:GetTempData(player)
		if data.CurseMovingTimeOut then
			data.CurseMovingTimeOut = nil
		end
	end
end)

--显示秒数
local function OnRender(_,player, offset)
	local game = Game()
	if (game:GetLevel():GetCurses() & IBS_Curse.moving > 0) and (game:GetRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT) then
		local data = Ents:GetTempData(player)
		if data.CurseMovingTimeOut and data.CurseMovingTimeOut then
			local timeOut = data.CurseMovingTimeOut
			local color = KColor(1, timeOut/180, timeOut/180,1,0,0,0)
		
			local pos = Isaac.WorldToScreen(Vector(-4,-50) + player.Position + player.PositionOffset) + offset - game:GetRoom():GetRenderScrollOffset() - game.ScreenShakeOffset			
			fnt:DrawString(math.floor(timeOut / 60), pos.X, pos.Y, color)
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, OnRender, 0)

