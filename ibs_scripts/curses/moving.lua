--动人诅咒

local mod = Isaac_BenightedSoul

local Moving = mod.IBS_Class.Curse(mod.IBS_CurseID.Moving)

local game = Game()

--读秒
function Moving:Tick(player)
	if self:IsApplied() and not (game:IsPaused() or game:GetRoom():GetBossID() == BossType.MEGA_SATAN) then
		local data = self._Ents:GetTempData(player)
		data.CurseMovingTimeout = data.CurseMovingTimeout or 180

		if player.Velocity:Length() > 1 then
			data.CurseMovingTimeout = 180
		else
			if data.CurseMovingTimeout > 0 then
				data.CurseMovingTimeout = data.CurseMovingTimeout - 1
			else
				data.CurseMovingTimeout = 180
				
				--昧化伊甸耸肩无视1级免疫伤害
				local BEden = mod.IBS_Player and mod.IBS_Player.BEden
				if (not BEden) or player:GetPlayerType() ~= mod.IBS_PlayerID.BEden or BEden:GetData(player).shrug_it_off <= 0 then
					player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_CLONES, EntityRef(player), 0)
				end
			end
		end
	else
		self._Ents:GetTempData(player).CurseMovingTimeout = nil
	end	
end
Moving:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'Tick', 0)


local fnt = Font()
fnt:Load("font/pftempestasevencondensed.fnt")

--显示秒数
function Moving:OnPlayerRender(player, offset)
	local room = game:GetRoom()

	if self:IsApplied() and (room:GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT) and room:GetBossID() ~= BossType.MEGA_SATAN then
		local data = self._Ents:GetTempData(player)

		if data.CurseMovingTimeout then
			local timeout = data.CurseMovingTimeout
			local color = KColor(1, timeout/180, timeout/180,1,0,0,0)
			local pos =  self._Screens:GetEntityRenderPosition(player, Vector(-7,-50) + offset)
			fnt:DrawString(self._Maths:Cut(timeout/60, 1), pos.X, pos.Y, color)
		end
	end	
end
Moving:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, 'OnPlayerRender', 0)


return Moving