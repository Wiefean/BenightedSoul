--巧克力

local mod = Isaac_BenightedSoul

local game = Game()

local Chocolate = mod.IBS_Class.Item(mod.IBS_ItemID.Chocolate)

--最大剩余机会
Chocolate.MaxLeft = 2

--临时眼泪数据
function Chocolate:GetTearData(tear)
	local data = self._Ents:GetTempData(tear)
	data.CHOCOLATE_TEAR = data.CHOCOLATE_TEAR or {Player = nil}
	
	return data.CHOCOLATE_TEAR
end

--设置特殊眼泪
function Chocolate:SetTear(tear, player)
	local data = self:GetTearData(tear)
	data.Player = player
end

--临时玩家数据
function Chocolate:GetPlayerData(player)
	local data = self._Ents:GetTempData(player)
	data.CHOCOLATE_PLAYER = data.CHOCOLATE_PLAYER or {Left = 0}

	return data.CHOCOLATE_PLAYER
end

--敌人受击变友好
function Chocolate:OnHitEnemy(target, dmg, flags, source)
	if self._Ents:IsEnemy(target, false, false, true) and source.Entity and source.Entity:ToTear() then
		local tear = source.Entity
		local data = self._Ents:GetTempData(tear).CHOCOLATE_TEAR
	
		if data then
			target:AddCharmed(EntityRef(data.Player), -1)
			target.MaxHitPoints = target.MaxHitPoints * 2.14
			target.HitPoints = target.MaxHitPoints * 2.14
		end	
	end
end
Chocolate:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -300, 'OnHitEnemy')

--双击发射
function Chocolate:OnDoubleTap(player, type, dir)
	if (type == 1) and not Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then
		if player:HasCollectible(self.ID) and player:IsExtraAnimationFinished() and not player:IsCoopGhost() then
			local data = self:GetPlayerData(player)
			if data.Left > 0 then
				data.Left = data.Left - 1
				
				local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, player.Position, self._Maths:DirectionToVector(dir)*10, player):ToTear()
				self:SetTear(tear, player)
				tear.CollisionDamage = 0.214
				tear.FallingAcceleration = 0.0214
				tear:SetColor(Color(1,0.5,0.3,1),-1,0)
				tear.Scale = 2.14
				tear:Update()
			end
		end
	end	
end
Chocolate:AddCallback(mod.IBS_CallbackID.DOUBLE_TAP, 'OnDoubleTap')

--获得机会
function Chocolate:ResetLeft(player)
	if player:HasCollectible(self.ID) then
		local data = self:GetPlayerData(player)
		data.Left = self.MaxLeft
		player:SetColor(Color(92/255, 47/255, 22/255),20,2,true)
		SFXManager():Play(SoundEffect.SOUND_BIRD_FLAP)
	end
end

--新房间获得机会
function Chocolate:OnNewRoom()
	if game:GetRoom():IsFirstVisit() then
		for i = 0, game:GetNumPlayers() -1 do
			self:ResetLeft(Isaac.GetPlayer(i))
		end
	end
end
Chocolate:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--贪婪新贪次获得机会
function Chocolate:OnGreedNewWave()
	for i = 0, game:GetNumPlayers() -1 do
		self:ResetLeft(Isaac.GetPlayer(i))
	end
end
Chocolate:AddCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, 'OnGreedNewWave')


return Chocolate